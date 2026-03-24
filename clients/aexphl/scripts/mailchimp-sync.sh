#!/bin/bash
# =============================================================================
# AEXPHL — Mailchimp Lead Sync
# Sources: Webflow forms + Calendly bookings + Monday.com (one-time import)
#
# Runs as a scheduled task every hour.
# State file tracks last sync timestamps to avoid duplicates.
#
# Required env vars (both ~/.zshrc AND ~/.claude/settings.json):
#   WEBFLOW_AEXPHL_TOKEN  — Webflow API
#   MAILCHIMP_API_KEY     — Mailchimp API
#
# Optional (add to activate):
#   CALENDLY_API_KEY      — Calendly Personal Access Token
#   MONDAY_API_KEY        — Monday.com API token (for one-time import)
#
# Tags applied:
#   source:webflow-form             — Webflow contactForm submissions
#   source:calendly                 — all Calendly bookings
#   calendly:discovery-call         — "Schedule Your Discovery Call"
#   calendly:borrowing-capacity     — "Check your borrowing capacity or Refinance options"
#   calendly:next-available         — "Next Available Appointment"
#   calendly:home-loan-review       — "Your Home Loan review"
#   calendly:{slugified-name}       — any other event type
#   source:whatsapp-manychat        — ManyChat completed intake (via native MC integration)
#   source:monday-import            — historical Monday.com import (one-time)
#   lead-type:high-intent           — ManyChat leads (completed full intake)
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
try:
    d = json.load(open(state_file)) if os.path.exists(state_file) else {}
except:
    d = {}
d['$key'] = '$value'
json.dump(d, open(state_file, 'w'), indent=2)
"
}

# --- Slugify a string into a tag-safe format ---------------------------------
slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//'
}

# --- Upsert member + apply tags to Mailchimp ---------------------------------
# Usage: add_to_mailchimp EMAIL FIRST LAST PHONE "tag1,tag2,tag3" NOTES
add_to_mailchimp() {
  local email="$1"
  local first_name="$2"
  local last_name="$3"
  local phone="$4"
  local tags_csv="$5"   # comma-separated list of tags
  local notes="$6"

  if [ -z "$email" ] || [ "$email" = "null" ]; then
    return
  fi

  # Sanitise inputs
  first_name=$(echo "$first_name" | tr -d '"\\')
  last_name=$(echo "$last_name" | tr -d '"\\')
  phone=$(echo "$phone" | tr -d '"\\')
  notes=$(echo "$notes" | tr -d '"\\' | cut -c1-500)

  local email_hash
  email_hash=$(echo -n "${email,,}" | md5)

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
      \"merge_fields\": {
        \"FNAME\": \"${first_name}\",
        \"LNAME\": \"${last_name}\",
        \"PHONE\": \"${phone}\"
      }
    }")

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
tags = [t.strip() for t in '$tags_csv'.split(',') if t.strip()]
payload = {'tags': [{'name': t, 'status': 'active'} for t in tags]}
print(json.dumps(payload))
")
    curl -s -X POST \
      --user "anystring:$MAILCHIMP_API_KEY" \
      -H "Content-Type: application/json" \
      "https://${MAILCHIMP_SERVER}.api.mailchimp.com/3.0/lists/${MAILCHIMP_AUDIENCE_ID}/members/${email_hash}/tags" \
      -d "$tags_json" > /dev/null
  fi

  # --- Step 3: Add note if provided ---
  if [ -n "$notes" ] && [ "$notes" != "null" ]; then
    curl -s -X POST \
      --user "anystring:$MAILCHIMP_API_KEY" \
      -H "Content-Type: application/json" \
      "https://${MAILCHIMP_SERVER}.api.mailchimp.com/3.0/lists/${MAILCHIMP_AUDIENCE_ID}/members/${email_hash}/notes" \
      -d "{\"note\": \"${notes}\"}" > /dev/null
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
        elif val and val is not False and val != 'false':
            notes_parts.append(f'{key}: {val}')
    notes = ' | '.join(notes_parts)
    print(f'{email}|||{first_name}|||{last_name}|||{phone}|||{notes}|||{submitted_at}')
" 2>/dev/null | while IFS='|||' read -r email first_name last_name phone notes submitted_at; do
        [ -z "$email" ] && continue
        add_to_mailchimp "$email" "$first_name" "$last_name" "$phone" "source:webflow-form" "$notes"
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

  # Get organisation URI (needed for team-wide events)
  local org_uri user_uri
  local me_response
  me_response=$(curl -s \
    -H "Authorization: Bearer $CALENDLY_API_KEY" \
    "https://api.calendly.com/users/me")

  user_uri=$(echo "$me_response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('resource',{}).get('uri',''))" 2>/dev/null || echo "")
  org_uri=$(echo "$me_response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('resource',{}).get('current_organization',''))" 2>/dev/null || echo "")

  if [ -z "$user_uri" ]; then
    log "Failed to get Calendly user URI — check CALENDLY_API_KEY"
    return
  fi

  # Use org URI if available (gets all team bookings, not just one user)
  local scope_param
  if [ -n "$org_uri" ]; then
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

    # Extract event UUID + event type name from each event
    local event_data
    event_data=$(echo "$events" | python3 -c "
import sys, json, re
d = json.load(sys.stdin)
for e in d.get('collection', []):
    uri = e.get('uri', '')
    uuid = uri.split('/')[-1]
    name = e.get('name', '')   # Human-readable event type name
    print(f'{uuid}|||{name}')
" 2>/dev/null || echo "")

    [ -z "$event_data" ] && break

    while IFS='|||' read -r event_uuid event_name; do
      [ -z "$event_uuid" ] && continue

      # Slugify event name into a tag e.g. "calendly:discovery-call"
      local event_slug
      event_slug=$(slugify "$event_name")
      local event_tag="calendly:${event_slug}"

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
    # Pull any custom question answers as notes
    notes_parts = []
    for q in inv.get('questions_and_answers', []):
        question = q.get('question','')
        answer = q.get('answer','')
        if answer:
            notes_parts.append(f'{question}: {answer}')
    notes = 'Booked: $event_name' + (' | ' + ' | '.join(notes_parts) if notes_parts else '')
    print(f'{email}|||{first_name}|||{last_name}|||{notes}')
" 2>/dev/null | while IFS='|||' read -r email first_name last_name notes; do
        [ -z "$email" ] && continue
        add_to_mailchimp "$email" "$first_name" "$last_name" "" "source:calendly,${event_tag}" "$notes"
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
# PART 3 — Monday.com Historical Import (one-time, checks state flag)
# =============================================================================
sync_monday() {
  if [ -z "${MONDAY_API_KEY:-}" ]; then
    log "--- Monday.com sync skipped (MONDAY_API_KEY not set) ---"
    return
  fi

  # Only run once unless forced
  local already_imported
  already_imported=$(python3 -c "
import json, os
try:
    d = json.load(open('$STATE_FILE'))
    print(d.get('monday_imported', 'false'))
except:
    print('false')
" 2>/dev/null || echo "false")

  if [ "$already_imported" = "true" ]; then
    log "--- Monday.com sync skipped (already imported — delete state file to re-run) ---"
    return
  fi

  log "--- Monday.com one-time historical import ---"

  # Step 1: Get all boards
  local boards_response
  boards_response=$(curl -s \
    -H "Authorization: $MONDAY_API_KEY" \
    -H "Content-Type: application/json" \
    -X POST "https://api.monday.com/v2" \
    -d '{"query": "{ boards(limit: 50) { id name } }"}')

  log "Boards found:"
  echo "$boards_response" | python3 -c "
import sys, json
d = json.load(sys.stdin)
boards = d.get('data', {}).get('boards', [])
for b in boards:
    print(f'  {b[\"id\"]} | {b[\"name\"]}')
" 2>/dev/null | while IFS= read -r line; do log "$line"; done

  # Step 2: Pull items from all boards, look for email columns
  local total_added=0

  local board_ids
  board_ids=$(echo "$boards_response" | python3 -c "
import sys, json
d = json.load(sys.stdin)
boards = d.get('data', {}).get('boards', [])
print('\n'.join([b['id'] for b in boards]))
" 2>/dev/null || echo "")

  while IFS= read -r board_id; do
    [ -z "$board_id" ] && continue

    # Pull items with column values (paginated, 100 at a time)
    local cursor=""
    while true; do
      local cursor_param=""
      [ -n "$cursor" ] && cursor_param=", cursor: \"${cursor}\""

      local items_response
      items_response=$(curl -s \
        -H "Authorization: $MONDAY_API_KEY" \
        -H "Content-Type: application/json" \
        -X POST "https://api.monday.com/v2" \
        -d "{\"query\": \"{ boards(ids: ${board_id}) { items_page(limit: 100${cursor_param}) { cursor items { id name column_values { id text type } } } } }\"}")

      echo "$items_response" | python3 -c "
import sys, json
d = json.load(sys.stdin)
try:
    items = d['data']['boards'][0]['items_page']['items']
except:
    sys.exit(0)

for item in items:
    email = ''
    first_name = ''
    last_name = ''
    phone = ''
    notes_parts = [f'Monday board ID: $board_id']

    for col in item.get('column_values', []):
        text = col.get('text', '') or ''
        col_id = col.get('id', '').lower()
        col_type = col.get('type', '').lower()

        if col_type == 'email' and text and not email:
            email = text.split(' ')[0]  # Monday sometimes appends label
        elif col_type == 'phone' and text:
            phone = text
        elif 'name' in col_id and text and not first_name:
            parts = text.split(' ', 1)
            first_name = parts[0]
            last_name = parts[1] if len(parts) > 1 else ''
        elif text:
            notes_parts.append(f'{col_id}: {text}')

    # Fallback: use item name as contact name
    if not first_name and item.get('name'):
        parts = item['name'].split(' ', 1)
        first_name = parts[0]
        last_name = parts[1] if len(parts) > 1 else ''

    notes = ' | '.join(notes_parts[:8])  # cap notes length
    print(f'{email}|||{first_name}|||{last_name}|||{phone}|||{notes}')
" 2>/dev/null | while IFS='|||' read -r email first_name last_name phone notes; do
          [ -z "$email" ] && continue
          add_to_mailchimp "$email" "$first_name" "$last_name" "$phone" "source:monday-import" "$notes"
          ((total_added++)) || true
        done

      # Check for next page cursor
      local next_cursor
      next_cursor=$(echo "$items_response" | python3 -c "
import sys, json
d = json.load(sys.stdin)
try:
    print(d['data']['boards'][0]['items_page']['cursor'] or '')
except:
    print('')
" 2>/dev/null || echo "")

      [ -z "$next_cursor" ] || [ "$next_cursor" = "None" ] && break
      cursor="$next_cursor"
    done

  done <<< "$board_ids"

  # Mark as imported so it doesn't run again
  python3 -c "
import json, os
state_file = '$STATE_FILE'
try:
    d = json.load(open(state_file)) if os.path.exists(state_file) else {}
except:
    d = {}
d['monday_imported'] = 'true'
json.dump(d, open(state_file, 'w'), indent=2)
"

  log "Monday.com import complete — $total_added contacts imported"
  log "Monday.com import will NOT run again automatically (state flag set)"
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
