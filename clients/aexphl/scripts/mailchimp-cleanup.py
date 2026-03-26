#!/usr/bin/env python3
"""
One-time cleanup script for AEXPHL Mailchimp audience.
Fixes garbled PHONE fields (names/tags stored instead of phone numbers)
and repopulates FNAME/LNAME from Monday.com for records with empty names.

Run once after fixing mailchimp-sync.sh.
"""

import os, json, hashlib, time
import urllib.request, urllib.error, ssl

# --- Config ------------------------------------------------------------------
MAILCHIMP_API_KEY = os.environ.get('MAILCHIMP_API_KEY', '')
MONDAY_API_KEY    = os.environ.get('MONDAY_API_KEY', '')
AUDIENCE_ID       = 'bba8715471'
MC_BASE           = 'https://us9.api.mailchimp.com/3.0'

if not MAILCHIMP_API_KEY or not MONDAY_API_KEY:
    print("ERROR: MAILCHIMP_API_KEY and MONDAY_API_KEY must be set")
    exit(1)

# SSL context that works on macOS without certifi
ssl_ctx = ssl.create_default_context()
ssl_ctx.check_hostname = False
ssl_ctx.verify_mode = ssl.CERT_NONE

# --- Helpers -----------------------------------------------------------------
def mc_get(path):
    import base64
    token = base64.b64encode(f'anystring:{MAILCHIMP_API_KEY}'.encode()).decode()
    req = urllib.request.Request(f'{MC_BASE}{path}',
        headers={'Authorization': f'Basic {token}', 'Content-Type': 'application/json'})
    return json.loads(urllib.request.urlopen(req, context=ssl_ctx).read())

def mc_patch(path, data):
    import base64
    token = base64.b64encode(f'anystring:{MAILCHIMP_API_KEY}'.encode()).decode()
    req = urllib.request.Request(f'{MC_BASE}{path}',
        data=json.dumps(data).encode(),
        headers={'Authorization': f'Basic {token}', 'Content-Type': 'application/json'},
        method='PATCH')
    try:
        return json.loads(urllib.request.urlopen(req, context=ssl_ctx).read())
    except urllib.error.HTTPError as e:
        return {'error': e.read().decode()}

def monday_query(q):
    import base64
    req = urllib.request.Request('https://api.monday.com/v2',
        data=json.dumps({'query': q}).encode(),
        headers={'Authorization': MONDAY_API_KEY, 'Content-Type': 'application/json'})
    return json.loads(urllib.request.urlopen(req, context=ssl_ctx).read())

def email_hash(email):
    return hashlib.md5(email.strip().lower().encode()).hexdigest()

def has_digits(s):
    return any(c.isdigit() for c in s)

def looks_like_garbage(s):
    """Returns True if PHONE value is clearly not a phone number."""
    if not s:
        return False
    if has_digits(s):
        return False  # Has digits → might be a real phone number
    if ':' in s or ',' in s:
        return True   # Tag string (e.g. source:monday-import,monday:lead,...)
    if len(s) <= 30 and s.replace(' ', '').isalpha():
        return True   # Looks like a name (James, Ben Simpfendorfer, etc.)
    return False

# --- Step 1: Build Monday email → name + phone map ---------------------------
print("Building Monday name map (Leads + Customers boards)...")
monday_map = {}  # email → {first, last, phone, country}

def process_monday_board(board_id, name_field, email_field, phone_field, country_field=None):
    cursor = None
    count = 0
    while True:
        cursor_clause = f', cursor: "{cursor}"' if cursor else ''
        cols = f'"{email_field}", "{phone_field}"'
        if country_field:
            cols += f', "{country_field}"'
        q = f'{{ boards(ids: {board_id}) {{ items_page(limit: 100{cursor_clause}) {{ cursor items {{ name updated_at column_values(ids: [{cols}]) {{ id text }} }} }} }} }}'
        resp = monday_query(q)
        try:
            page = resp['data']['boards'][0]['items_page']
            items = page['items']
        except (KeyError, IndexError):
            break

        for item in items:
            fields = {cv['id']: (cv.get('text') or '').strip() for cv in item.get('column_values', [])}
            email = fields.get(email_field, '').split(' ')[0].strip().lower()
            if not email or '@' not in email:
                continue
            name_parts = item['name'].strip().split(' ', 1)
            first = name_parts[0] if name_parts else ''
            last  = name_parts[1] if len(name_parts) > 1 else ''
            phone = fields.get(phone_field, '')
            country = fields.get(country_field, '') if country_field else ''
            if email not in monday_map:
                monday_map[email] = {'first': first, 'last': last, 'phone': phone, 'country': country}
            else:
                # Merge: fill blanks
                existing = monday_map[email]
                if not existing['first'] and first:
                    existing['first'] = first
                if not existing['last'] and last:
                    existing['last'] = last
                if not existing['phone'] and phone and has_digits(phone):
                    existing['phone'] = phone
                if not existing['country'] and country:
                    existing['country'] = country
            count += 1

        next_cursor = page.get('cursor') or ''
        if not next_cursor:
            break
        cursor = next_cursor

    return count

leads_count = process_monday_board(1907973121, 'name', 'lead_email', 'phone_mkq1vacq')
customers_count = process_monday_board(1917616922, 'name', 'email', 'phone', 'country')
print(f"  Leads: {leads_count} records, Customers: {customers_count} records")
print(f"  Total unique emails in Monday map: {len(monday_map)}")

# --- Step 2: Fetch all Mailchimp members -------------------------------------
print("Fetching all Mailchimp members...")
all_members = []
offset = 0
while True:
    data = mc_get(f'/lists/{AUDIENCE_ID}/members?count=1000&offset={offset}&fields=members.email_address,members.merge_fields,members.tags')
    batch = data.get('members', [])
    if not batch:
        break
    all_members.extend(batch)
    offset += len(batch)
    if len(batch) < 1000:
        break

print(f"  Fetched {len(all_members)} members")

# --- Step 3: Identify and fix bad records ------------------------------------
print("Scanning for records to fix...")

needs_fix = []
for m in all_members:
    email = m['email_address'].lower()
    mf = m.get('merge_fields', {})
    fname = mf.get('FNAME', '')
    lname = mf.get('LNAME', '')
    phone = mf.get('PHONE', '')
    country = mf.get('COUNTRY', '')

    patches = {}

    # Fix garbled PHONE
    if looks_like_garbage(phone):
        patches['PHONE'] = ''

    # Fix empty FNAME/LNAME using Monday map
    monday_data = monday_map.get(email, {})
    if not fname and monday_data.get('first'):
        patches['FNAME'] = monday_data['first']
    if not lname and monday_data.get('last'):
        patches['LNAME'] = monday_data['last']

    # Fix empty COUNTRY using Monday map
    if not country and monday_data.get('country'):
        patches['COUNTRY'] = monday_data['country']

    # Fix empty PHONE using Monday map (real phone number only)
    if not patches.get('PHONE', phone) and monday_data.get('phone') and has_digits(monday_data['phone']):
        patches['PHONE'] = monday_data['phone']

    if patches:
        needs_fix.append((email, patches))

print(f"  Records needing fixes: {len(needs_fix)}")
name_fixes    = sum(1 for _, p in needs_fix if 'FNAME' in p or 'LNAME' in p)
phone_clears  = sum(1 for _, p in needs_fix if p.get('PHONE') == '')
phone_fills   = sum(1 for _, p in needs_fix if p.get('PHONE', 'x') not in ('', 'x'))
country_fills = sum(1 for _, p in needs_fix if 'COUNTRY' in p)
print(f"    Name fixes: {name_fixes}")
print(f"    Phone clears (garbage): {phone_clears}")
print(f"    Phone fills (real number): {phone_fills}")
print(f"    Country fills: {country_fills}")

# --- Step 4: Apply fixes -----------------------------------------------------
print("Applying fixes...")
fixed = 0
errors = 0
for email, patches in needs_fix:
    h = email_hash(email)
    result = mc_patch(f'/lists/{AUDIENCE_ID}/members/{h}', {'merge_fields': patches})
    if 'error' in result:
        print(f"  ERROR {email}: {result['error'][:80]}")
        errors += 1
    else:
        fixed += 1
    if fixed % 50 == 0:
        print(f"  {fixed}/{len(needs_fix)} done...")
    time.sleep(0.05)  # Rate limit: ~20 req/sec

print(f"\nDone. Fixed: {fixed}, Errors: {errors}")
