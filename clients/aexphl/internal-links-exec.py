#!/usr/bin/env python3
"""aexphl Internal Linking Execution — 2026-03-24"""

import os, re, json, sys, time, requests
from datetime import datetime

TOKEN = os.environ.get('WEBFLOW_AEXPHL_TOKEN', '')
if not TOKEN:
    print("ERROR: WEBFLOW_AEXPHL_TOKEN not set"); sys.exit(1)

COLLECTION_ID = '66104d468c50c15134bf0447'
BASE = 'https://api.webflow.com/v2'
HDRS = {
    'Authorization': f'Bearer {TOKEN}',
    'Content-Type': 'application/json',
    'accept': 'application/json'
}
FIELDS = ['content', 'content-2', 'second-section', 'third-seciton', 'fourth-section']

report = {'updated': [], 'skipped': [], 'errors': []}

def get_item(iid):
    r = requests.get(f'{BASE}/collections/{COLLECTION_ID}/items/{iid}', headers=HDRS)
    r.raise_for_status()
    return r.json().get('fieldData', {})

def patch_item(iid, fields):
    r = requests.patch(
        f'{BASE}/collections/{COLLECTION_ID}/items/{iid}',
        headers=HDRS,
        json={'fieldData': fields}
    )
    return r.status_code, r.text[:300]

def inject(html, phrase, url):
    """Wrap first occurrence of phrase in <a> if not already inside one."""
    if not html:
        return html, False
    m = re.search(re.escape(phrase), html, re.IGNORECASE)
    if not m:
        return html, False
    before = html[:m.start()]
    # Count open vs closed <a> tags before this match
    open_a = len(re.findall(r'<a[\s>]', before))
    close_a = before.count('</a>')
    if open_a > close_a:
        return html, False  # Already inside anchor tag
    new = html[:m.start()] + f'<a href="{url}">{m.group()}</a>' + html[m.end():]
    return new, True

def process(iid, name, links, cta=None):
    try:
        fd = get_item(iid)
    except Exception as e:
        report['errors'].append({'name': name, 'error': f'GET failed: {e}', 'changes': []})
        return

    updated_fd = {}
    post_changes = []

    for phrase, url in links:
        found = False
        for field in FIELDS:
            raw = fd.get(field)
            html = raw if isinstance(raw, str) else ''
            new_html, changed = inject(html, phrase, url)
            if changed:
                fd[field] = new_html
                updated_fd[field] = new_html
                post_changes.append({'status': 'added', 'field': field, 'phrase': phrase[:60], 'url': url})
                found = True
                break
        if not found:
            post_changes.append({'status': 'not_found', 'phrase': phrase[:60], 'url': url})

    # Append CTA block to last substantial content field (only if no book-appointment link yet)
    if cta:
        for field in reversed(FIELDS):
            raw = fd.get(field)
            html = raw if isinstance(raw, str) else ''
            if html and len(html.strip()) > 100:
                if '/book-appointment' not in html:
                    fd[field] = html + cta
                    updated_fd[field] = fd[field]
                    post_changes.append({'status': 'cta_added', 'field': field})
                else:
                    post_changes.append({'status': 'cta_exists', 'field': field})
                break

    if updated_fd:
        status, resp = patch_item(iid, updated_fd)
        if status in (200, 202):
            report['updated'].append({'name': name, 'http': status, 'changes': post_changes})
        else:
            report['errors'].append({'name': name, 'error': f'PATCH {status}: {resp}', 'changes': post_changes})
    else:
        report['skipped'].append({'name': name, 'changes': post_changes})

# ── CTAs ──────────────────────────────────────────────────────────────────────

CTA_BUY = (
    '\n<div style="margin-top:1.5em;padding:1em 1.25em;background:#f0f4ff;'
    'border-left:4px solid #1a56db;border-radius:4px">'
    '<p style="margin:0"><strong>Ready to move forward?</strong> '
    '<a href="/book-appointment">Book a free consultation</a> with an expat mortgage specialist, '
    '<a href="/calculators">check your borrowing capacity</a>, or use our '
    '<a href="/stamp-duty-calculator">stamp duty calculator</a> to estimate upfront costs.</p></div>'
)

CTA_STD = (
    '\n<div style="margin-top:1.5em;padding:1em 1.25em;background:#f0f4ff;'
    'border-left:4px solid #1a56db;border-radius:4px">'
    '<p style="margin:0"><strong>Ready to take the next step?</strong> '
    '<a href="/book-appointment">Book a free consultation</a> with an expat mortgage specialist, '
    'or <a href="/calculators">check your borrowing capacity</a>.</p></div>'
)

CTA_REFI = (
    '\n<div style="margin-top:1.5em;padding:1em 1.25em;background:#f0f4ff;'
    'border-left:4px solid #1a56db;border-radius:4px">'
    '<p style="margin:0"><strong>Want to know if you can get a better deal?</strong> '
    '<a href="/book-appointment">Book a free consultation</a> '
    'or <a href="/calculators">run the numbers first</a>.</p></div>'
)

# ── POSTS ─────────────────────────────────────────────────────────────────────
# (item_id, display_name, [(phrase_to_find, target_url), ...], cta_or_None)
#
# GSC top blog pages (high impressions — add as link targets from relevant posts):
#   /blog/australian-expat-home-loan           (3,594 impr — "Five Things You Must Know")
#   /blog/minimum-house-deposit-australia      (2,053 impr — "Minimum Deposit")
#   /blog/housing-interest-rates-australia     (2,039 impr — "Housing Interest Rate")
#   /blog/australia-home-loan                  (692 impr  — "Home Loans in Australia")

POSTS = [

    # ── PUBLISHED POSTS (zero links currently, need full treatment) ───────────

    ('69c111f7036b6533a4f64240', 'Buying Property Step-by-Step', [
        ('overseas income',                          '/blog/foreign-income-shading-australian-home-loan'),
        ('pre-approval',                             '/blog/expat-home-loan-pre-approval-australia'),
        ('documentation',                            '/blog/australian-expat-home-loan-documents-checklist'),
        ('use your time overseas',                   '/blog/making-the-most-of-your-time-overseas-building-assets-back-home'),
        ('minimum deposit',                          '/blog/minimum-house-deposit-australia'),   # GSC top page
    ], CTA_BUY),

    ('69b7bec355c714ea0e9bb09d', 'Making the Most of Your Time Overseas', [
        ('buying property in Australia while living overseas',  '/blog/australian-expat-buying-property-in-australia-complete-guide-2026'),
        ('overseas income',                          '/blog/foreign-income-shading-australian-home-loan'),
        ('building assets',                          '/blog/yield-vs-growth-aussie-expats-buying-property-australia'),
        ('five things',                              '/blog/australian-expat-home-loan'),        # GSC top page
    ], CTA_BUY),

    ('69afb7d783de1b43a6943d6b', 'Yield vs Growth', [
        ('expats looking to buy property',           '/blog/australian-expat-buying-property-in-australia-complete-guide-2026'),
        ('living overseas',                          '/blog/making-the-most-of-your-time-overseas-building-assets-back-home'),
        ('interest rate',                            '/blog/housing-interest-rates-australia'),  # GSC top page
    ], CTA_STD),

    ('69a54705aca690ce005b8497', 'Complete Guide 2026', [
        ('Documents Required',                       '/blog/australian-expat-home-loan-documents-checklist'),
        ('how much can',                             '/blog/how-much-can-australian-expat-singapore-borrow'),
        ('pre-approval',                             '/blog/expat-home-loan-pre-approval-australia'),
        ('income shading',                           '/blog/foreign-income-shading-australian-home-loan'),
        ('minimum deposit',                          '/blog/minimum-house-deposit-australia'),   # GSC top page
        ('interest rate',                            '/blog/housing-interest-rates-australia'),  # GSC top page
    ], CTA_BUY),

    ('69a1630749dba806db341c34', 'Construction to Land Transition', [
        ('foreign income',                           '/blog/foreign-income-shading-australian-home-loan'),
        ('refinanc',                                 '/blog/refinance-australian-mortgage-overseas'),
        ('reassess',                                 '/blog/is-it-time-to-reassess-your-home-loan-key-questions-for-expats-abroad'),
        ('home loan',                                '/blog/australia-home-loan'),               # GSC top page
    ], CTA_STD),

    ('68ba9da74baa518096c23518', 'Is It Time to Reassess', [
        ('switching lenders',                        '/blog/refinance-australian-mortgage-overseas'),
        ('lending rules',                            '/blog/rba-rate-hike-march-2026-australian-expats'),
        ('offset',                                   '/blog/australian-expat-buying-property-in-australia-complete-guide-2026'),
        ('interest rate',                            '/blog/housing-interest-rates-australia'),  # GSC top page
    ], CTA_REFI),

    # ── PIPELINE DRAFTS ───────────────────────────────────────────────────────
    # These already have /book-appointment + /calculators, so cta=None
    # unless they were missing CTAs (pre-approval post was missing them)

    ('69c0f82718732148ca257a87', 'Refinance from Overseas', [
        ('4.10%',                                    '/blog/rba-rate-hike-march-2026-australian-expats'),
        ('foreign income',                           '/blog/foreign-income-shading-australian-home-loan'),
        ('document',                                 '/blog/australian-expat-home-loan-documents-checklist'),
        ('borrowing capacity',                       '/blog/how-much-can-australian-expat-singapore-borrow'),
        ('minimum deposit',                          '/blog/minimum-house-deposit-australia'),   # GSC top page
    ], None),

    ('69c0f826160a92a016a00015', 'Documents Checklist', [
        ('pre-approval',                             '/blog/expat-home-loan-pre-approval-australia'),
        ('income shading',                           '/blog/foreign-income-shading-australian-home-loan'),
        ('Power of Attorney',                        '/blog/buying-property-in-australia-while-living-overseas-a-step-by-step-guide-for-aussie-expats'),
    ], None),

    ('69c0f825737ae96589972355', 'Singapore Borrowing Capacity', [
        ('income shading',                           '/blog/foreign-income-shading-australian-home-loan'),
        ('which lender',                             '/blog/australian-expat-buying-property-in-australia-complete-guide-2026'),
        ('DTI',                                      '/blog/apra-dti-cap-australian-expat-home-loan'),
        ('Bonus',                                    '/blog/australian-expat-home-loan-documents-checklist'),
        ('minimum deposit',                          '/blog/minimum-house-deposit-australia'),   # GSC top page
    ], None),

    ('69c0f82474911f1a6421c17e', 'Foreign Income Shading', [
        ('SGD',                                      '/blog/how-much-can-australian-expat-singapore-borrow'),
        ('how much you can borrow',                  '/blog/how-much-can-australian-expat-singapore-borrow'),
        ('wrong lender',                             '/blog/australian-expat-buying-property-in-australia-complete-guide-2026'),
        ('documents',                                '/blog/australian-expat-home-loan-documents-checklist'),
        ('interest rate',                            '/blog/housing-interest-rates-australia'),  # GSC top page
    ], None),

    ('69c0f822516496872957b969', 'RBA Rate Hike March 2026', [
        ('refinanc',                                 '/blog/refinance-australian-mortgage-overseas'),
        ('reviewed',                                 '/blog/is-it-time-to-reassess-your-home-loan-key-questions-for-expats-abroad'),
        ('borrowing capacity',                       '/blog/how-much-can-australian-expat-singapore-borrow'),
        ('home loan',                                '/blog/australia-home-loan'),               # GSC top page
    ], None),

    ('69bbbd7a45baf4116cfc8fc6', 'Pre-Approval for Expats', [
        ('foreign income shading',                   '/blog/foreign-income-shading-australian-home-loan'),
        ('documents',                                '/blog/australian-expat-home-loan-documents-checklist'),
        ('borrowing capacity',                       '/blog/how-much-can-australian-expat-singapore-borrow'),
        ('buying property',                          '/blog/australian-expat-buying-property-in-australia-complete-guide-2026'),
        ('minimum deposit',                          '/blog/minimum-house-deposit-australia'),   # GSC top page
    ], CTA_STD),  # this one had no CTAs

    ('69c0ffad36fa9a6300c3d752', 'APRA DTI Cap', [
        ('how much you can borrow',                  '/blog/how-much-can-australian-expat-singapore-borrow'),
        ('foreign income',                           '/blog/foreign-income-shading-australian-home-loan'),
        ('pre-approval',                             '/blog/expat-home-loan-pre-approval-australia'),
        ('interest rate',                            '/blog/housing-interest-rates-australia'),  # GSC top page
    ], None),

    ('69c0ffaf1391d83cd798c67e', 'Which Lenders Accept Expats 2026', [
        ('foreign income',                           '/blog/foreign-income-shading-australian-home-loan'),
        ('borrowing capacity',                       '/blog/how-much-can-australian-expat-singapore-borrow'),
        ('complete guide',                           '/blog/australian-expat-buying-property-in-australia-complete-guide-2026'),
        ('minimum deposit',                          '/blog/minimum-house-deposit-australia'),   # GSC top page
    ], None),

    ('69c0ffb4cf61a7d3e17d5ff7', 'Perth Brisbane vs Sydney', [
        ('yield',                                    '/blog/yield-vs-growth-aussie-expats-buying-property-australia'),
        ('borrowing capacity',                       '/blog/how-much-can-australian-expat-singapore-borrow'),
        ('living overseas',                          '/blog/making-the-most-of-your-time-overseas-building-assets-back-home'),
        ('interest rate',                            '/blog/housing-interest-rates-australia'),  # GSC top page
    ], None),

    ('69c0ffb2c87b968d3628331f', 'AED Income Dubai', [
        ('income shading',                           '/blog/foreign-income-shading-australian-home-loan'),
        ('borrowing capacity',                       '/blog/how-much-can-australian-expat-singapore-borrow'),
        ('documents',                                '/blog/australian-expat-home-loan-documents-checklist'),
        ('minimum deposit',                          '/blog/minimum-house-deposit-australia'),   # GSC top page
    ], None),

    ('69c0ffb11391d83cd798c774', 'HKD Income Hong Kong', [
        ('income shading',                           '/blog/foreign-income-shading-australian-home-loan'),
        ('borrowing capacity',                       '/blog/how-much-can-australian-expat-singapore-borrow'),
        ('documents',                                '/blog/australian-expat-home-loan-documents-checklist'),
        ('minimum deposit',                          '/blog/minimum-house-deposit-australia'),   # GSC top page
    ], None),
]

# ── RUN ───────────────────────────────────────────────────────────────────────

print(f"aexphl Internal Linking — {datetime.now().strftime('%Y-%m-%d %H:%M')}")
print(f"Processing {len(POSTS)} posts...\n")

for iid, name, links, cta in POSTS:
    print(f"  → {name}")
    process(iid, name, links, cta)
    time.sleep(0.4)

# ── PRINT REPORT ──────────────────────────────────────────────────────────────

print("\n" + "="*65)
print("EXECUTION REPORT")
print("="*65)

links_added = 0
ctas_added = 0
not_found = 0

print(f"\n✅ UPDATED ({len(report['updated'])} posts):")
for r in report['updated']:
    print(f"\n  {r['name']} (HTTP {r['http']})")
    for c in r['changes']:
        if c['status'] == 'added':
            print(f"    + [{c['field']}] \"{c['phrase']}\" → {c['url']}")
            links_added += 1
        elif c['status'] == 'cta_added':
            print(f"    + [{c['field']}] CTA block appended")
            ctas_added += 1
        elif c['status'] == 'cta_exists':
            print(f"    = [{c['field']}] CTA already present")
        elif c['status'] == 'not_found':
            print(f"    - NOT FOUND: \"{c['phrase']}\"")
            not_found += 1

print(f"\n⏭️  SKIPPED ({len(report['skipped'])} posts — no changes needed):")
for r in report['skipped']:
    print(f"\n  {r['name']}")
    for c in r['changes']:
        if c['status'] == 'not_found':
            print(f"    - NOT FOUND: \"{c['phrase']}\"")
            not_found += 1
        else:
            print(f"    {c}")

print(f"\n❌ ERRORS ({len(report['errors'])} posts):")
for r in report['errors']:
    print(f"\n  {r['name']}: {r['error']}")

print(f"""
{"="*65}
SUMMARY
{"="*65}
Posts processed : {len(POSTS)}
Posts updated   : {len(report['updated'])}
Posts skipped   : {len(report['skipped'])}
Posts errored   : {len(report['errors'])}
Links injected  : {links_added}
CTAs added      : {ctas_added}
Phrases missed  : {not_found}
""")

# Save JSON results for report
with open('/tmp/aexphl-linking-results.json', 'w') as f:
    json.dump(report, f, indent=2)
print("Full results saved to /tmp/aexphl-linking-results.json")
