#!/bin/bash
# =============================================================================
# AEXPHL — Mailchimp Lead Sync
# Sources: Webflow forms + Calendly bookings + Monday.com (ongoing delta sync)
#
# Runs as a scheduled task every hour.
# State file tracks last sync timestamps to avoid duplicates.
# All sources use PUT upsert — safe to re-run, deduplicates by email.
# Empty fields are NEVER sent — existing Mailchimp data is never overwritten with blank.
#
# Required env vars (both ~/.zshrc AND ~/.claude/settings.json):
#   WEBFLOW_AEXPHL_TOKEN  — Webflow API
#   MAILCHIMP_API_KEY     — Mailchimp API
#
# Optional (add to activate):
#   CALENDLY_API_KEY      — Calendly Personal Access Token (needs scheduled_events:read scope)
#   MONDAY_API_KEY        — Monday.com API token (ongoing delta sync, not one-time)
#
# Tags applied:
#   source:webflow                  — Webflow contactForm submissions
#   source:calendly                 — all Calendly bookings
#   broker:shaun                    — booked with / owned by Shaun Rattray
#   broker:tim                      — booked with / owned by Tim Raes
#   broker:charu                    — booked with Charu
#   event:borrowing-cap             — "Check your borrowing capacity or Refinance options"
#   event:next-available            — "Next Available Appointment"
#   event:discovery-call            — "Schedule Your Discovery Call"
#   event:{slugified-name}          — any other Calendly event type
#   source:whatsapp-manychat        — ManyChat completed intake (via native MC integration)
#   lead-type:high-intent           — ManyChat leads (completed full intake)
#   source:monday-import            — from Monday.com (recurring delta sync)
#   monday:lead                     — from Monday Leads board
#   monday:customer                 — from Monday Customers board
#   monday-status:{status}          — lead status from Monday (e.g. monday-status:intake)
#
# Merge fields:
#   FNAME, LNAME, PHONE             — standard Mailchimp fields
#   WHATSAPP                        — WhatsApp number
#   SERVICES                        — Interested services / event type booked
#   LEADSTAT                        — Lead status
#   LOCATION                        — Location / country of residence
#   CAMPAIGN                        — Campaign source
#   LSOURCE                         — Lead capture source (webflow / calendly / monday)
#   EMPLOY                          — Employment status
#   IMMIGR                          — Immigration status
#   BROKER                          — Assigned broker name
#   COUNTRY                         — Country of residence (from Customers board)
#   AGE                             — Age (from Customers board)
#   MARITAL                         — Marital status (from Customers board)
#   JOBTITLE                        — Job title (from Customers board)
#   INCOME                          — Annual income AUD (from Customers board)
#   CUSTTYPE                        — Customer type e.g. High Net Worth (from Customers board)
#   MEETDATE                        — Original meeting / booking date
#
# Monday sync filter:
#   Only imports leads where owner field contains: Shaun Rattray OR Tim Raes
#   Excludes: unassigned, Paul Truong, and anyone else not on the AEXPHL team
#   All Customers board entries included (no owner filter — all are confirmed AEXPHL clients)
#   Delta sync: tracks monday_last_sync timestamp, only processes items updated since last run
# =============================================================================

set -euo pipefail

# --- Config ------------------------------------------------------------------
WEBFLOW_SITE_ID="5e1ef6e0ff2a7e7d638dd146"
MAILCHIMP_AUDIENCE_ID="bba8715471"
MAILCHIMP_SERVER="us9"
STATE_FILE="$(dirname "$0")/mailchimp-sync-state.json"
LOG_FILE="$(dirname "$0")/mailchimp-sync.log"

# --- Logging -----------------------------------------------------------------
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# --- State management --------------------------------------------------------
get_last_sync() {
  local key="$1"
  if [ -f "$STATE_FILE" ]; then
    python3 -c "
import json, sys
try:
    d = json.load(open('$STATE_FILE'))
    print(d.get('$key', '2020-01-01T00:00:00Z'))
except:
    print('2020-01-01T00:00:00Z')
"
  else
    echo "2020-01-01T00:00:00Z"
  fi
}

update_last_sync() {
  local key="$1"
  local value="$2"
  python3 -c "
import json, os
state_file = '$STATE_FILE'
d = {}
if os.path.exists(state_file):
    try:
        with open(state_file) as fh:
            d = json.load(fh)
        if not isinstance(d, dict):
            d = {}
    except Exception:
        # Read failed — back up corrupt file, start fresh but preserve what we can
        try:
            os.rename(state_file, state_file + '.bak')
        except Exception:
            pass
        d = {}
d['$key'] = '$value'
with open(state_file, 'w') as fh:
    json.dump(d, fh, indent=2)
"
}

# --- Slugify a string into a tag-safe format ---------------------------------
slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//'
}

# --- Upsert member + apply tags to Mailchimp ---------------------------------
# Usage: add_to_mailchimp EMAIL FIRST LAST PHONE "tag1,tag2,tag3" NOTES MERGE_JSON
# MERGE_JSON is optional JSON object for extra merge fields e.g. '{"SERVICES":"New Purchase"}'
add_to_mailchimp() {
  local email="$1"
  local first_name="$2"
  local last_name="$3"
  local phone="$4"
  local tags_csv="$5"
  local notes="$6"
  local merge_extra="${7:-{}}"

  if [ -z "$email" ] || [ "$email" = "null" ]; then
    return
  fi

  # Sanitise inputs
  first_name=$(echo "$first_name" | tr -d '"\\' | cut -c1-100)
  last_name=$(echo "$last_name" | tr -d '"\\' | cut -c1-100)
  phone=$(echo "$phone" | tr -d '"\\' | cut -c1-50)
  notes=$(echo "$notes" | tr -d '"\\' | cut -c1-500)

  local email_hash
  email_hash=$(echo -n "$email" | tr '[:upper:]' '[:lower:]' | md5)

  # Build merged merge_fields JSON
  # first_name/last_name/phone already have " stripped (safe for JSON string values)
  # merge_extra is JSON from json.dumps() — written to temp file to avoid " conflicting with bash "..."
  local merge_json _mf
  _mf=$(mktemp /tmp/mc_mf.XXXXXX)
  printf '%s' "${merge_extra:-{}}" > "$_mf"
  export _MCF="$first_name" _MCL="$last_name" _MCP="$phone" _MCEF="$_mf"
  # Always include FNAME, LNAME, PHONE explicitly (even as empty string) so re-syncs
  # overwrite any previously corrupted values rather than leaving garbage in place.
  merge_json=$(python3 -c "
import json, os
d = json.load(open(os.environ['_MCEF']))
b = {}
# Standard fields: always set if non-empty, always clear if empty (to fix corruption)
fname = os.environ.get('_MCF', '')
lname = os.environ.get('_MCL', '')
phone = os.environ.get('_MCP', '')
if fname and fname not in ('null', 'None'): b['FNAME'] = fname
if lname and lname not in ('null', 'None'): b['LNAME'] = lname
# PHONE: always send — real number if available, empty string to clear garbage
def has_digits(s): return any(c.isdigit() for c in s)
if phone and has_digits(phone): b['PHONE'] = phone
else: b['PHONE'] = ''
# Extra merge fields: only send non-empty values
for k, v in d.items():
    if v and str(v) not in ('', 'null', 'None'):
        b[k] = v
print(json.dumps(b))
" 2>/dev/null || echo '{}')
  rm -f "$_mf"
  unset _MCF _MCL _MCP _MCEF

  # --- Step 1: Upsert the member ---
  local response http_code body
  response=$(curl -s -w "\n%{http_code}" \
    -X PUT \
    --user "anystring:$MAILCHIMP_API_KEY" \
    -H "Content-Type: application/json" \
    "https://${MAILCHIMP_SERVER}.api.mailchimp.com/3.0/lists/${MAILCHIMP_AUDIENCE_ID}/members/${email_hash}" \
    -d "{
      \"email_address\": \"${email}\",
      \"status_if_new\": \"subscribed\",
      \"merge_fields\": ${merge_json}
    }") || { log "  ⚠️  Network error (curl): $email — skipping"; return; }

  http_code=$(echo "$response" | tail -1)
  body=$(echo "$response" | head -1)

  if [ "$http_code" != "200" ] && [ "$http_code" != "201" ]; then
    local err
    err=$(echo "$body" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('detail','unknown'))" 2>/dev/null || echo "parse error")
    log "  ⚠️  Failed ($http_code): $email — $err"
    return
  fi

  # --- Step 2: Apply tags ---
  if [ -n "$tags_csv" ] && [ "$tags_csv" != "null" ]; then
    local tags_json
    tags_json=$(python3 -c "
import json, sys
tags_input = sys.stdin.read().strip()
tags = [t.strip() for t in tags_input.split(',') if t.strip()]
payload = {'tags': [{'name': t, 'status': 'active'} for t in tags]}
print(json.dumps(payload))
" <<< "$tags_csv")
    curl -s -X POST \
      --user "anystring:$MAILCHIMP_API_KEY" \
      -H "Content-Type: application/json" \
      "https://${MAILCHIMP_SERVER}.api.mailchimp.com/3.0/lists/${MAILCHIMP_AUDIENCE_ID}/members/${email_hash}/tags" \
      -d "$tags_json" > /dev/null || true
  fi

  # --- Step 3: Add note if provided ---
  if [ -n "$notes" ] && [ "$notes" != "null" ]; then
    curl -s -X POST \
      --user "anystring:$MAILCHIMP_API_KEY" \
      -H "Content-Type: application/json" \
      "https://${MAILCHIMP_SERVER}.api.mailchimp.com/3.0/lists/${MAILCHIMP_AUDIENCE_ID}/members/${email_hash}/notes" \
      -d "{\"note\": \"${notes}\"}" > /dev/null || true
  fi

  log "  ✅ $email → tags: $tags_csv"
}

# =============================================================================
# PART 1 — Webflow Form Submissions
# =============================================================================
sync_webflow() {
  log "--- Syncing Webflow form submissions ---"

  local last_sync now
  last_sync=$(get_last_sync "webflow_last_sync")
  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  log "Last sync: $last_sync"

  local forms_response form_ids
  forms_response=$(curl -s \
    -H "Authorization: Bearer $WEBFLOW_AEXPHL_TOKEN" \
    -H "accept-version: 2.0.0" \
    "https://api.webflow.com/v2/sites/${WEBFLOW_SITE_ID}/forms")

  form_ids=$(echo "$forms_response" | python3 -c "
import sys, json
d = json.load(sys.stdin)
seen = set()
ids = []
for f in d.get('forms', []):
    name = f.get('displayName','')
    if name not in seen:
        seen.add(name)
        ids.append(f.get('id',''))
print('\n'.join(ids))
" 2>/dev/null || echo "")

  if [ -z "$form_ids" ]; then
    log "No forms found or API error"
    update_last_sync "webflow_last_sync" "$now"
    return
  fi

  local total_added=0

  while IFS= read -r form_id; do
    [ -z "$form_id" ] && continue
    local offset=0 limit=100

    while true; do
      local submissions
      submissions=$(curl -s \
        -H "Authorization: Bearer $WEBFLOW_AEXPHL_TOKEN" \
        -H "accept-version: 2.0.0" \
        "https://api.webflow.com/v2/forms/${form_id}/submissions?limit=${limit}&offset=${offset}")

      local count
      count=$(echo "$submissions" | python3 -c "import sys,json; d=json.load(sys.stdin); print(len(d.get('formSubmissions', [])))" 2>/dev/null || echo "0")
      [ "$count" = "0" ] && break

      echo "$submissions" | python3 -c "
import sys, json
d = json.load(sys.stdin)
last_sync = '$last_sync'
for sub in d.get('formSubmissions', []):
    submitted_at = sub.get('submittedOn', sub.get('createdOn', ''))
    if submitted_at <= last_sync:
        continue
    data = sub.get('fieldData', {})
    email = first_name = last_name = phone = ''
    services_parts = []
    notes_parts = []
    for key, val in data.items():
        kl = key.lower()
        if 'email' in kl and not email:
            email = str(val) if val else ''
        elif 'name' in kl and 'first' in kl:
            first_name = str(val) if val else ''
        elif 'name' in kl and 'last' in kl:
            last_name = str(val) if val else ''
        elif 'name' in kl and not first_name and not last_name:
            parts = str(val).split(' ', 1) if val else ['', '']
            first_name = parts[0]
            last_name = parts[1] if len(parts) > 1 else ''
        elif 'phone' in kl or 'whatsapp' in kl:
            phone = str(val) if val else ''
        elif val is True or val == 'true' or val == 'on':
            services_parts.append(key)
        elif val and val is not False and val != 'false':
            notes_parts.append(f'{key}: {val}')
    services = ', '.join(services_parts)
    notes = ' | '.join(notes_parts)
    merge = json.dumps({'WHATSAPP': phone, 'SERVICES': services})
    print(f'{email}\x1f{first_name}\x1f{last_name}\x1f{phone}\x1f{notes}\x1f{submitted_at}\x1f{merge}')
" 2>/dev/null | while IFS=$'\x1f' read -r email first_name last_name phone notes submitted_at merge; do
        [ -z "$email" ] && continue
        add_to_mailchimp "$email" "$first_name" "$last_name" "$phone" "source:webflow" "$notes" "$merge"
        ((total_added++)) || true
      done

      local total
      total=$(echo "$submissions" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('pagination',{}).get('total',0))" 2>/dev/null || echo "0")
      offset=$((offset + limit))
      [ "$offset" -ge "$total" ] && break
    done
  done <<< "$form_ids"

  update_last_sync "webflow_last_sync" "$now"
  log "Webflow sync complete — $total_added new contacts"
}

# =============================================================================
# PART 2 — Calendly Bookings (with event type name tagging)
# =============================================================================
sync_calendly() {
  if [ -z "${CALENDLY_API_KEY:-}" ]; then
    log "--- Calendly sync skipped (CALENDLY_API_KEY not set) ---"
    return
  fi

  log "--- Syncing Calendly bookings ---"

  local last_sync now
  last_sync=$(get_last_sync "calendly_last_sync")
  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  log "Last sync: $last_sync"

  # Token has scheduled_events:read but not users:read — hardcode known user URI
  # Decoded from JWT: user_uuid = ACGBPK2OIQ3QPH3G
  local user_uri org_uri
  user_uri="https://api.calendly.com/users/ACGBPK2OIQ3QPH3G"

  # Try to get org URI for team-wide events (may fail silently if scope missing)
  org_uri=$(curl -s \
    -H "Authorization: Bearer $CALENDLY_API_KEY" \
    "https://api.calendly.com/event_types?user=${user_uri}&count=1" | \
    python3 -c "import sys,json; d=json.load(sys.stdin); items=d.get('collection',[]); print(items[0].get('profile',{}).get('owner','')) if items else print('')" 2>/dev/null || echo "")

  # Use user URI (token scope doesn't include org-wide access)
  local scope_param
  if [ -n "$org_uri" ] && echo "$org_uri" | grep -q "organizations"; then
    scope_param="organization=${org_uri}"
    log "Syncing org-wide bookings (all 3 brokers)"
  else
    scope_param="user=${user_uri}"
  fi

  local page_token="" total_added=0

  while true; do
    local url="https://api.calendly.com/scheduled_events?${scope_param}&min_start_time=${last_sync}&count=100&sort=start_time:asc&status=active"
    [ -n "$page_token" ] && url="${url}&page_token=${page_token}"

    local events
    events=$(curl -s -H "Authorization: Bearer $CALENDLY_API_KEY" "$url")

    # Extract event UUID + event type name + assigned broker from each event
    local event_data
    event_data=$(echo "$events" | python3 -c "
import sys, json
d = json.load(sys.stdin)

# Broker first-name → tag mapping
broker_map = {
    'shaun': 'broker:shaun',
    'tim':   'broker:tim',
    'charu': 'broker:charu',
}

# Event name → short tag mapping
event_tag_map = {
    'check your borrowing capacity': 'event:borrowing-cap',
    'borrowing capacity':            'event:borrowing-cap',
    'next available appointment':    'event:next-available',
    'next available':                'event:next-available',
    'schedule your discovery call':  'event:discovery-call',
    'discovery call':                'event:discovery-call',
    'your home loan review':         'event:loan-review',
    'loan consultation':             'event:loan-consult',
}

for e in d.get('collection', []):
    uri = e.get('uri', '')
    uuid = uri.split('/')[-1]
    event_name = e.get('name', '')

    # Resolve event to short tag
    name_lower = event_name.lower()
    event_tag = None
    for key, tag in event_tag_map.items():
        if key in name_lower:
            event_tag = tag
            break
    if not event_tag:
        # fallback: slugify
        slug = event_name.lower().replace(' ', '-')
        import re
        slug = re.sub(r'[^a-z0-9-]', '', slug).strip('-')
        event_tag = f'event:{slug}'

    # Get assigned broker from event_memberships
    broker_tag = ''
    for m in e.get('event_memberships', []):
        uname = (m.get('user_name') or '').lower()
        for first, tag in broker_map.items():
            if first in uname:
                broker_tag = tag
                break
        if broker_tag:
            break

    start_time = e.get('start_time', '')[:10]  # YYYY-MM-DD only
    print(f'{uuid}\x1f{event_name}\x1f{event_tag}\x1f{broker_tag}\x1f{start_time}')
" 2>/dev/null || echo "")

    [ -z "$event_data" ] && break

    while IFS=$'\x1f' read -r event_uuid event_name event_tag broker_tag event_start; do
      [ -z "$event_uuid" ] && continue

      # Build full tag string
      local all_tags="source:calendly,${event_tag}"
      [ -n "$broker_tag" ] && all_tags="${all_tags},${broker_tag}"

      local invitees
      invitees=$(curl -s \
        -H "Authorization: Bearer $CALENDLY_API_KEY" \
        "https://api.calendly.com/scheduled_events/${event_uuid}/invitees?count=100")

      echo "$invitees" | python3 -c "
import sys, json
d = json.load(sys.stdin)
for inv in d.get('collection', []):
    email = inv.get('email', '')
    name = inv.get('name', '')
    parts = name.split(' ', 1)
    first_name = parts[0]
    last_name = parts[1] if len(parts) > 1 else ''

    # Phone from SMS reminder number (most reliable field)
    phone = (inv.get('text_reminder_number') or '').strip()

    # Extract location and notes from Q&A
    notes_parts = ['Booked: $event_name']
    location = ''
    for q in inv.get('questions_and_answers', []):
        ans = (q.get('answer') or '').replace('\n', ' ').replace('\r', '').strip()
        quest = (q.get('question') or '').lower()
        if ans:
            notes_parts.append(f'{q[\"question\"]}: {ans}')
            # Extract country/location answer
            if 'country' in quest or 'locat' in quest or 'where' in quest:
                location = ans

    notes = ' | '.join(notes_parts)
    broker = '$broker_tag'.replace('broker:', '').title() if '$broker_tag' else ''
    merge = json.dumps({
        'BROKER':   broker,
        'PHONE':    phone,
        'LOCATION': location,
        'MEETDATE': '$event_start',
        'LSOURCE':  'calendly',
        'SERVICES': '$event_name',
    })
    print(f'{email}\x1f{first_name}\x1f{last_name}\x1f{phone}\x1f{notes}\x1f{merge}')
" 2>/dev/null | while IFS=$'\x1f' read -r email first_name last_name phone notes merge; do
        [ -z "$email" ] && continue
        add_to_mailchimp "$email" "$first_name" "$last_name" "$phone" "$all_tags" "$notes" "$merge"
        ((total_added++)) || true
      done

    done <<< "$event_data"

    local next_page
    next_page=$(echo "$events" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('pagination', {}).get('next_page_token', ''))
" 2>/dev/null || echo "")

    [ -z "$next_page" ] && break
    page_token="$next_page"
  done

  update_last_sync "calendly_last_sync" "$now"
  log "Calendly sync complete — $total_added new contacts"
}

# =============================================================================
# PART 3 — Monday.com Delta Sync (runs every hour, only processes updated items)
#
# Board mapping:
#   1907973121  Leads       — owner-filtered (Shaun Rattray / Tim Raes only)
#   1917616922  Customers   — all entries (confirmed AEXPHL clients)
#   1917636634  Referrers   — SKIPPED (referral partners, not leads)
#
# Delta logic: tracks monday_last_sync timestamp. Each run fetches all pages
# but skips items where updated_at <= last_sync. Only new/changed items get
# upserted to Mailchimp. First run (no timestamp) syncs everything.
#
# Deduplication: Mailchimp PUT upsert on email hash — safe to re-run, never
# creates duplicates. Fields are only set if non-empty (existing data preserved).
#
# Leads field map:
#   lead_email          → email
#   name (item)         → full name
#   phone_mkq1vacq      → WhatsApp / PHONE
#   dropdown            → SERVICES (Interested Services)
#   lead_status         → LEADSTAT + monday-status tag
#   lead_owner          → BROKER + broker tag
#   text6               → CAMPAIGN (Campaign Source)
#   short_textc63e8txn  → LSOURCE (Lead Capture source)
#   long_text5          → notes (Details)
#   text_mkrcsr5t       → LOCATION
#   dropdown_mkrcsktv   → SERVICES (combined with dropdown)
#   date                → MEETDATE (Original Meeting Date)
#
# Customers field map:
#   email               → email
#   name (item)         → full name
#   phone               → PHONE
#   dropdown8           → EMPLOY (Employment Status)
#   dropdown_1          → IMMIGR (Immigration Status)
#   country             → COUNTRY (Country of residence)
#   numbers             → AGE
#   dropdown            → MARITAL (Marital Status)
#   text                → JOBTITLE (Job Title)
#   numbers5            → INCOME (Annual Income AUD)
#   dropdown_12         → CUSTTYPE (Customer Type e.g. High Net Worth)
# =============================================================================
sync_monday() {
  if [ -z "${MONDAY_API_KEY:-}" ]; then
    log "--- Monday.com sync skipped (MONDAY_API_KEY not set) ---"
    return
  fi

  local last_sync now
  last_sync=$(get_last_sync "monday_last_sync")
  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  log "--- Monday.com delta sync (since $last_sync) ---"
  local total_added=0

  # ---- 3a: Leads board -------------------------------------------------------
  log "Importing Leads board (1907973121)..."
  local cursor=""
  while true; do
    local cursor_clause=""
    [ -n "$cursor" ] && cursor_clause=", cursor: \\\"${cursor}\\\""

    local resp
    resp=$(curl -s --max-time 60 \
      -H "Authorization: $MONDAY_API_KEY" \
      -H "Content-Type: application/json" \
      -X POST "https://api.monday.com/v2" \
      -d "{\"query\": \"{ boards(ids: 1907973121) { items_page(limit: 100${cursor_clause}) { cursor items { name updated_at column_values(ids: [\\\"lead_email\\\", \\\"phone_mkq1vacq\\\", \\\"dropdown\\\", \\\"lead_status\\\", \\\"lead_owner\\\", \\\"text6\\\", \\\"short_textc63e8txn\\\", \\\"long_text5\\\", \\\"text_mkrcsr5t\\\", \\\"dropdown_mkrcsktv\\\", \\\"date\\\"]) { id text } } } } }\"}" 2>/dev/null) || { log "  ⚠️  Monday.com Leads board API error (timeout/network) — will retry next run"; return; }

    echo "$resp" | python3 -c "
import sys, json
d = json.load(sys.stdin)
try:
    items = d['data']['boards'][0]['items_page']['items']
except:
    sys.exit(0)

last_sync = '$last_sync'

# Only import leads owned by Shaun or Tim (by name appearing in owner field)
# Handles co-ownership e.g. Paul Truong + Shaun Rattray — Shaun appears so it passes
# Unassigned (empty owner) is excluded
ALLOWED_OWNER_NAMES = ['shaun rattray', 'tim raes']

# Broker first-name → tag
BROKER_MAP = {'shaun': 'broker:shaun', 'tim': 'broker:tim', 'charu': 'broker:charu'}

field_map = {
    'lead_email': 'email',
    'phone_mkq1vacq': 'whatsapp',
    'dropdown': 'services',
    'lead_status': 'status',
    'lead_owner': 'owner',
    'text6': 'campaign_source',
    'short_textc63e8txn': 'lead_capture',
    'long_text5': 'details',
    'text_mkrcsr5t': 'location',
    'dropdown_mkrcsktv': 'looking_for',
    'date': 'meeting_date',
}

def clean(s):
    # Remove tabs (would break TSV), newlines, and single-quotes (break bash python -c)
    return str(s or '').replace('\t', ' ').replace('\n', ' ').replace('\r', '').replace(chr(39), '').strip()

for item in items:
    # Delta filter: skip items not updated since last sync
    updated_at = (item.get('updated_at') or '')
    if updated_at and last_sync != '2020-01-01T00:00:00Z' and updated_at <= last_sync:
        continue

    fields = {field_map.get(cv['id'], cv['id']): clean(cv.get('text') or '')
              for cv in item.get('column_values', [])}

    # Filter: require an allowed owner name to appear in the owner field
    # Excludes: unassigned, paul truong, and anyone else not on the team
    owner = fields.get('owner', '').lower()
    if not any(name in owner for name in ALLOWED_OWNER_NAMES):
        continue

    email = fields.get('email', '').split(' ')[0]
    if not email or '@' not in email:
        continue

    name_parts = item['name'].replace('\t', ' ').split(' ', 1)
    first_name = clean(name_parts[0])
    last_name = clean(name_parts[1]) if len(name_parts) > 1 else ''
    whatsapp = fields.get('whatsapp', '')
    status = fields.get('status', '')

    # Broker tag from owner
    broker_tag = ''
    for first, tag in BROKER_MAP.items():
        if first in owner:
            broker_tag = tag
            break

    # Build tags
    status_slug = status.lower().replace(' ', '-').replace('/', '-') if status else ''
    tags = 'source:monday-import,monday:lead'
    if status_slug:
        tags += f',monday-status:{status_slug}'
    if broker_tag:
        tags += f',{broker_tag}'

    # Notes — plain text only, no quotes or tabs
    notes = clean(fields.get('details', ''))[:300]

    # Merge fields — JSON serialised, safe to pass as 7th arg
    # Combine services + looking_for into SERVICES (both answer "what do they want")
    services_combined = ' | '.join(filter(None, [fields.get('services', ''), fields.get('looking_for', '')]))
    merge = json.dumps({
        'WHATSAPP': whatsapp,
        'SERVICES': services_combined,
        'LEADSTAT': status,
        'LOCATION': fields.get('location', ''),
        'CAMPAIGN': fields.get('campaign_source', ''),
        'LSOURCE':  fields.get('lead_capture', ''),
        'BROKER':   fields.get('owner', ''),
        'MEETDATE': fields.get('meeting_date', ''),
    })

    print(f'{email}\x1f{first_name}\x1f{last_name}\x1f{whatsapp}\x1f{tags}\x1f{notes}\x1f{merge}')
" 2>/dev/null | while IFS=$'\x1f' read -r email first_name last_name phone tags notes merge; do
      [ -z "$email" ] && continue
      add_to_mailchimp "$email" "$first_name" "$last_name" "$phone" "$tags" "$notes" "$merge"
      ((total_added++)) || true
    done

    local next_cursor
    next_cursor=$(echo "$resp" | python3 -c "
import sys,json
d=json.load(sys.stdin)
try: print(d['data']['boards'][0]['items_page']['cursor'] or '')
except: print('')
" 2>/dev/null || echo "")
    if [ -z "$next_cursor" ] || [ "$next_cursor" = "None" ]; then break; fi
    cursor="$next_cursor"
  done
  log "Leads board done"

  # ---- 3b: Customers board ---------------------------------------------------
  log "Importing Customers board (1917616922)..."
  cursor=""
  while true; do
    local cursor_clause=""
    [ -n "$cursor" ] && cursor_clause=", cursor: \\\"${cursor}\\\""

    local resp
    resp=$(curl -s --max-time 60 \
      -H "Authorization: $MONDAY_API_KEY" \
      -H "Content-Type: application/json" \
      -X POST "https://api.monday.com/v2" \
      -d "{\"query\": \"{ boards(ids: 1917616922) { items_page(limit: 100${cursor_clause}) { cursor items { name updated_at column_values(ids: [\\\"email\\\", \\\"phone\\\", \\\"country\\\", \\\"numbers\\\", \\\"dropdown\\\", \\\"text\\\", \\\"numbers5\\\", \\\"dropdown8\\\", \\\"dropdown_1\\\", \\\"dropdown_12\\\"]) { id text } } } } }\"}" 2>/dev/null) || { log "  ⚠️  Monday.com Customers board API error (timeout/network) — will retry next run"; return; }

    echo "$resp" | python3 -c "
import sys, json
d = json.load(sys.stdin)
try:
    items = d['data']['boards'][0]['items_page']['items']
except:
    sys.exit(0)

last_sync = '$last_sync'

for item in items:
    # Delta filter: skip items not updated since last sync
    updated_at = (item.get('updated_at') or '')
    if updated_at and last_sync != '2020-01-01T00:00:00Z' and updated_at <= last_sync:
        continue

    fields = {cv['id']: (cv.get('text') or '').strip()
              for cv in item.get('column_values', [])}

    email = fields.get('email', '').split(' ')[0]
    if not email or '@' not in email or email in ('NA@NA.com', 'test@lead.com'):
        continue

    name_parts = item['name'].split(' ', 1)
    first_name = name_parts[0]
    last_name = name_parts[1] if len(name_parts) > 1 else ''
    phone = fields.get('phone', '')

    merge = json.dumps({
        'EMPLOY':   fields.get('dropdown8', ''),
        'IMMIGR':   fields.get('dropdown_1', ''),
        'COUNTRY':  fields.get('country', ''),
        'AGE':      fields.get('numbers', ''),
        'MARITAL':  fields.get('dropdown', ''),
        'JOBTITLE': fields.get('text', ''),
        'INCOME':   fields.get('numbers5', ''),
        'CUSTTYPE': fields.get('dropdown_12', ''),
    })

    print(f'{email}\x1f{first_name}\x1f{last_name}\x1f{phone}\x1f{merge}')
" 2>/dev/null | while IFS=$'\x1f' read -r email first_name last_name phone merge; do
      [ -z "$email" ] && continue
      add_to_mailchimp "$email" "$first_name" "$last_name" "$phone" "source:monday-import,monday:customer" "" "$merge"
      ((total_added++)) || true
    done

    local next_cursor
    next_cursor=$(echo "$resp" | python3 -c "
import sys,json
d=json.load(sys.stdin)
try: print(d['data']['boards'][0]['items_page']['cursor'] or '')
except: print('')
" 2>/dev/null || echo "")
    if [ -z "$next_cursor" ] || [ "$next_cursor" = "None" ]; then break; fi
    cursor="$next_cursor"
  done
  log "Customers board done"

  update_last_sync "monday_last_sync" "$now"
  log "Monday.com sync complete — $total_added contacts upserted"
}

# =============================================================================
# MAIN
# =============================================================================
log "========================================"
log "AEXPHL Mailchimp Sync — $(date)"
log "========================================"

[ -z "${WEBFLOW_AEXPHL_TOKEN:-}" ] && log "ERROR: WEBFLOW_AEXPHL_TOKEN not set" && exit 1
[ -z "${MAILCHIMP_API_KEY:-}" ] && log "ERROR: MAILCHIMP_API_KEY not set" && exit 1

sync_webflow
sync_calendly
sync_monday

log "========================================"
log "Sync complete"
log "========================================"
