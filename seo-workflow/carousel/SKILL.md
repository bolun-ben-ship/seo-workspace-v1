---
name: carousel
description: >
  Instagram carousel generator. Collects brand details via questionnaire, auto-detects
  client logo, accepts multiple image uploads, generates a branded 7-slide swipeable
  HTML carousel, exports each slide as a 1080×1350px PNG, and saves everything to
  {client}/Design/Carousel-YYYY-MM-DD/. Use when user says "carousel",
  "instagram carousel", "create carousel", "make a carousel", "design carousel".
user-invocable: true
argument-hint: "(topic) — optional, will be asked in questionnaire"
---

# Instagram Carousel Generator

Creates a fully branded, export-ready Instagram carousel. Each slide is designed to be
exported as an individual 1080×1350px PNG for Instagram posting.

---

## Phase 0: Read Client Context

Before asking any questions, read the current workspace CLAUDE.md to extract:
- `WORKSPACE_ROOT` — the absolute path to the client folder (e.g. `~/Antigravity/RightClickAI-seo-workspace/clients/aexphl`)
- Brand/client name
- Platform (for reference only)

Then search for a logo file in the client folder. Check these locations in order:
1. `{WORKSPACE_ROOT}/context/logo.svg`
2. `{WORKSPACE_ROOT}/context/logo.png`
3. `{WORKSPACE_ROOT}/context/logo.jpg`
4. `{WORKSPACE_ROOT}/context/logo.jpeg`
5. `{WORKSPACE_ROOT}/context/logo.webp`
6. Any file matching `logo*` or `brand*` in `{WORKSPACE_ROOT}/context/`
7. Any file matching `logo*` or `brand*` in `{WORKSPACE_ROOT}/`

Note the result — you will report what you found to the user in the questionnaire.

---

## Phase 1: Questionnaire

Use the AskUserQuestion tool to collect all brand details in a single popup.
Present the questions clearly, one per line. Include what logo you found (or didn't find).

Ask the following questions:

All questions are optional — if skipped, use the default shown.

```
1. What is this carousel about? (topic / key message)
   — required, no default

2. Brand name — displayed on first and last slides
   [Pre-filled from CLAUDE.md if found] — default: client name from CLAUDE.md

3. Instagram handle — shown in the preview frame header
   — default: skip (omit handle from design entirely if not provided)

4. Primary brand color — hex code, describe it (e.g. "deep navy blue"), or type "logo" to extract from the logo file
   — default: #2563EB (clean blue)

5. Font style — choose one (or skip for default):
   a) Editorial / premium (Playfair Display + DM Sans)
   b) Modern / clean (Plus Jakarta Sans)          ← default
   c) Warm / approachable (Lora + Nunito Sans)
   d) Technical / sharp (Space Grotesk)
   e) Bold / expressive (Fraunces + Outfit)
   f) Classic / trustworthy (Libre Baskerville + Work Sans)
   g) Rounded / friendly (Bricolage Grotesque)

6. Tone — e.g. professional, casual, playful, bold, minimal
   — default: professional

7. Number of slides — 5, 6, 7, 8, 9, or 10
   — default: 7

8. Any specific content notes, key points, or sections to include?
   — default: skip, use best judgement based on topic

9. Logo: [Report what you found, e.g. "Found: context/logo.svg — will use this"
   or "No logo found in client folder"]
   Use it? (yes / no / brand initial) — default: yes if found, brand initial if not

10. Images — attach any photos, screenshots, or product images to include
    (drag and drop into this message) — default: skip, no images
```

Wait for the user's response before proceeding.
If the user replies with only a subset of answers, apply defaults for everything not mentioned.

---

## Phase 2: Process Inputs

After the user responds:

**Logo handling:**
- If logo was found AND user said yes → base64-encode the logo file
  - Use `file {path}` to detect actual format (SVG, PNG, JPEG)
  - For SVG: read raw text, embed as `data:image/svg+xml;base64,...`
  - For PNG: `base64 -i {path}` → embed as `data:image/png;base64,...`
  - For JPEG/JPG: `base64 -i {path}` → embed as `data:image/jpeg;base64,...`
- If no logo / user declined → use brand initial (first letter of brand name) in a colored circle
- If user chose "brand initial" → use initial

**Uploaded image handling:**
- For each image the user attached, base64-encode it
- Use the `file` command to detect actual format (JPEG vs PNG vs WEBP) — do NOT trust the file extension alone
- Embed each as the correct `data:{mime};base64,...` URI
- Assign a variable name (e.g. `IMG_1`, `IMG_2`) to reference in the HTML

**Instagram handle:**
- If user provided a handle → show it in the IG frame header and caption
- If skipped → omit the handle row from the IG frame header; show only the avatar. Remove handle from the caption entirely.

**Color derivation:**

If user typed "logo" (or "use logo colors" / "from logo"):
- If the logo is an SVG: read the raw SVG text and extract the first prominent fill or stroke hex color found in the markup. Use that as BRAND_PRIMARY.
- If the logo is a PNG/JPEG: run this Python snippet to extract the dominant color:
  ```python
  from PIL import Image
  import colorsys
  img = Image.open("{logo_path}").convert("RGB").resize((50, 50))
  pixels = list(img.getdata())
  # filter out near-white and near-black
  pixels = [p for p in pixels if not (all(c > 230 for c in p) or all(c < 25 for c in p))]
  if pixels:
      avg = tuple(sum(c[i] for c in pixels)//len(pixels) for i in range(3))
      print("#{:02x}{:02x}{:02x}".format(*avg))
  ```
  Use the printed hex as BRAND_PRIMARY. If Pillow is not installed, fall back to `#2563EB` and tell the user.
- If no logo is available and user said "logo" → fall back to `#2563EB` and inform user.

From the resolved BRAND_PRIMARY, derive the full 6-token palette:
```
BRAND_PRIMARY   = {resolved color}
BRAND_LIGHT     = {primary lightened ~20%}
BRAND_DARK      = {primary darkened ~30%}
LIGHT_BG        = {warm or cool off-white complementing the primary}
LIGHT_BORDER    = {slightly darker than LIGHT_BG}
DARK_BG         = {near-black with subtle brand tint}
```

Rules:
- LIGHT_BG: tinted off-white matching brand temperature (warm primary → warm cream e.g. #FAF8F5, cool → #F5F7FA)
- DARK_BG: near-black with brand tint (warm → #1A1918, cool → #0F172A, neutral → #141414)
- LIGHT_BORDER: ~10% darker than LIGHT_BG
- Gradient: `linear-gradient(165deg, BRAND_DARK 0%, BRAND_PRIMARY 50%, BRAND_LIGHT 100%)`

**Font selection:**
Map the user's font choice to heading + body Google Font names:
- a) Playfair Display (700) + DM Sans (400/600)
- b) Plus Jakarta Sans (700) + Plus Jakarta Sans (400)
- c) Lora (700) + Nunito Sans (400/600)
- d) Space Grotesk (700) + Space Grotesk (400)
- e) Fraunces (700) + Outfit (400/600)
- f) Libre Baskerville (700) + Work Sans (400/600)
- g) Bricolage Grotesque (700) + Bricolage Grotesque (400)

---

## Phase 3: Generate the HTML Carousel

Generate the HTML using Python (NEVER shell script — shell variable interpolation corrupts HTML content).

Write a Python script to `{WORKSPACE_ROOT}/Design/Carousel-{YYYY-MM-DD}/generate.py`
and run it. The script must write the complete HTML to `carousel.html` in the same folder.

### Output folder
```
{WORKSPACE_ROOT}/Design/Carousel-{YYYY-MM-DD}/
├── generate.py        ← Python script that writes carousel.html
├── carousel.html      ← self-contained HTML preview
└── slides/            ← created by export script (Phase 4)
    ├── slide_1.png
    ├── slide_2.png
    └── ...
```

### HTML structure

The HTML must be a fully self-contained file (no external image files — everything base64-embedded).

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{Brand Name} — Instagram Carousel</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family={HEADING_FONT}:wght@300;400;600;700&family={BODY_FONT}:wght@400;600&display=swap" rel="stylesheet">
  <style>
    /* Reset */
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body { background: #1a1a1a; display: flex; justify-content: center; align-items: flex-start; padding: 40px 20px; min-height: 100vh; font-family: system-ui, sans-serif; }

    /* Font classes */
    .serif { font-family: '{HEADING_FONT}', Georgia, serif; }
    .sans { font-family: '{BODY_FONT}', system-ui, sans-serif; }

    /* Instagram frame wrapper */
    .ig-frame { width: 420px; max-width: 420px; background: #fff; border-radius: 12px; box-shadow: 0 24px 80px rgba(0,0,0,0.5); overflow: hidden; }

    /* IG header */
    .ig-header { display: flex; align-items: center; gap: 10px; padding: 12px 14px; border-bottom: 1px solid #efefef; }
    .ig-avatar { width: 32px; height: 32px; border-radius: 50%; background: {BRAND_PRIMARY}; display: flex; align-items: center; justify-content: center; }
    .ig-handle { font-size: 13px; font-weight: 600; color: #000; }
    .ig-subtitle { font-size: 11px; color: #888; }
    .ig-dots-header { margin-left: auto; }
    .ig-dots-header span { display: block; width: 4px; height: 4px; border-radius: 50%; background: #333; margin: 2px; }

    /* Carousel viewport */
    .carousel-viewport { width: 420px; aspect-ratio: 4/5; overflow: hidden; cursor: grab; position: relative; }
    .carousel-viewport:active { cursor: grabbing; }
    .carousel-track { display: flex; height: 100%; transition: transform 0.3s ease; }
    .slide { min-width: 420px; height: 100%; position: relative; overflow: hidden; display: flex; flex-direction: column; }

    /* IG footer */
    .ig-actions { display: flex; align-items: center; padding: 10px 14px 6px; gap: 14px; }
    .ig-actions svg { width: 24px; height: 24px; }
    .ig-bookmark { margin-left: auto; }
    .ig-dots { display: flex; justify-content: center; gap: 4px; padding: 0 14px 8px; }
    .ig-dot { width: 6px; height: 6px; border-radius: 50%; background: #dbdbdb; transition: background 0.2s; }
    .ig-dot.active { background: {BRAND_PRIMARY}; }
    .ig-caption { padding: 4px 14px 14px; font-size: 13px; color: #333; }
    .ig-caption strong { font-weight: 600; }
    .ig-caption .timestamp { color: #8e8e8e; font-size: 11px; display: block; margin-top: 4px; }
  </style>
</head>
<body>

<div class="ig-frame">
  <!-- Header -->
  <div class="ig-header">
    <div class="ig-avatar">
      {LOGO_OR_INITIAL_SVG}
    </div>
    <div>
      <div class="ig-handle">{INSTAGRAM_HANDLE}</div>
      <div class="ig-subtitle">Sponsored</div>
    </div>
    <div class="ig-dots-header">
      <span></span><span></span><span></span>
    </div>
  </div>

  <!-- Carousel -->
  <div class="carousel-viewport" id="viewport">
    <div class="carousel-track" id="track">
      {ALL_SLIDES}
    </div>
  </div>

  <!-- Dot indicators -->
  <div class="ig-dots" id="dots">
    {DOT_INDICATORS}
  </div>

  <!-- Actions -->
  <div class="ig-actions">
    <!-- Heart -->
    <svg viewBox="0 0 24 24" fill="none" stroke="#333" stroke-width="1.5"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
    <!-- Comment -->
    <svg viewBox="0 0 24 24" fill="none" stroke="#333" stroke-width="1.5"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
    <!-- Share -->
    <svg viewBox="0 0 24 24" fill="none" stroke="#333" stroke-width="1.5"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
    <!-- Bookmark -->
    <svg class="ig-bookmark" viewBox="0 0 24 24" fill="none" stroke="#333" stroke-width="1.5"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>
  </div>

  <!-- Caption -->
  <div class="ig-caption">
    <strong>{INSTAGRAM_HANDLE}</strong> {SHORT_CAPTION}
    <span class="timestamp">2 HOURS AGO</span>
  </div>
</div>

<script>
  const track = document.getElementById('track');
  const viewport = document.getElementById('viewport');
  const dots = document.querySelectorAll('.ig-dot');
  const TOTAL = {TOTAL_SLIDES};
  let current = 0;
  let startX = 0;
  let isDragging = false;

  function goTo(idx) {
    current = Math.max(0, Math.min(TOTAL - 1, idx));
    track.style.transform = `translateX(${-current * 420}px)`;
    dots.forEach((d, i) => d.classList.toggle('active', i === current));
  }

  viewport.addEventListener('pointerdown', e => { startX = e.clientX; isDragging = true; viewport.setPointerCapture(e.pointerId); });
  viewport.addEventListener('pointerup', e => {
    if (!isDragging) return;
    isDragging = false;
    const dx = e.clientX - startX;
    if (dx < -40) goTo(current + 1);
    else if (dx > 40) goTo(current - 1);
  });
  goTo(0);
</script>
</body>
</html>
```

### Slide design rules

**Every slide must include:**

1. **Progress bar** (absolute bottom, always):
```html
<div style="position:absolute;bottom:0;left:0;right:0;padding:16px 28px 20px;z-index:10;display:flex;align-items:center;gap:10px;">
  <div style="flex:1;height:3px;background:{TRACK_COLOR};border-radius:2px;overflow:hidden;">
    <div style="height:100%;width:{PCT}%;background:{FILL_COLOR};border-radius:2px;"></div>
  </div>
  <span style="font-size:11px;color:{LABEL_COLOR};font-weight:500;">{IDX+1}/{TOTAL}</span>
</div>
```
- Light slides: track=`rgba(0,0,0,0.08)`, fill=BRAND_PRIMARY, label=`rgba(0,0,0,0.3)`
- Dark/gradient slides: track=`rgba(255,255,255,0.12)`, fill=`#fff`, label=`rgba(255,255,255,0.4)`

2. **Swipe arrow** (absolute right — ALL slides except the LAST):
```html
<div style="position:absolute;right:0;top:0;bottom:0;width:48px;z-index:9;display:flex;align-items:center;justify-content:center;background:linear-gradient(to right,transparent,{BG});">
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
    <path d="M9 6l6 6-6 6" stroke="{STROKE}" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
</div>
```
- Light slides: bg=`rgba(0,0,0,0.06)`, stroke=`rgba(0,0,0,0.25)`
- Dark/gradient slides: bg=`rgba(255,255,255,0.08)`, stroke=`rgba(255,255,255,0.35)`
- **LAST SLIDE: omit this entirely**

3. **Content padding**: use `padding-bottom: 52px` on content containers so text never overlaps the progress bar.

### Standard slide sequence (7 slides default)

| # | Type | Background | Content |
|---|------|------------|---------|
| 1 | Hero | LIGHT_BG | Bold hook statement, logo lockup, tagline |
| 2 | Problem | DARK_BG | Pain point with strikethrough pills or bullets |
| 3 | Solution | Brand gradient | The answer — quote/prompt box optional |
| 4 | Features | LIGHT_BG | Feature list with icons |
| 5 | Details | DARK_BG | Depth — customization, specs, or differentiators |
| 6 | How-to | LIGHT_BG | Numbered steps (01, 02, 03...) |
| 7 | CTA | Brand gradient | Logo lockup, tagline, CTA button. NO arrow. Full bar. |

Adapt the sequence to the topic. For 5–6 slides, drop the least relevant content slides.
For 8–10, add more feature/detail/step slides. Always start hero, end CTA.

### Reusable components

**Tag label** (above headings):
```html
<span class="sans" style="display:inline-block;font-size:10px;font-weight:600;letter-spacing:2px;color:{COLOR};margin-bottom:16px;">{TAG TEXT}</span>
```
- Light slides: BRAND_PRIMARY
- Dark slides: BRAND_LIGHT
- Gradient slides: rgba(255,255,255,0.6)

**Logo lockup** (hero and CTA slides):
```html
<div style="display:flex;align-items:center;gap:10px;margin-bottom:24px;">
  <div style="width:40px;height:40px;border-radius:50%;background:{BRAND_PRIMARY};display:flex;align-items:center;justify-content:center;overflow:hidden;">
    {LOGO_SVG_OR_INITIAL}
  </div>
  <span class="sans" style="font-size:13px;font-weight:600;letter-spacing:0.5px;color:{TEXT_COLOR};">{BRAND_NAME}</span>
</div>
```

**Feature list row**:
```html
<div style="display:flex;align-items:flex-start;gap:14px;padding:10px 0;border-bottom:1px solid {LIGHT_BORDER};">
  <span style="color:{BRAND_PRIMARY};font-size:15px;width:18px;text-align:center;">{ICON}</span>
  <div>
    <div class="sans" style="font-size:14px;font-weight:600;color:{DARK_BG};">{Label}</div>
    <div class="sans" style="font-size:12px;color:#8A8580;">{Description}</div>
  </div>
</div>
```

**Numbered step**:
```html
<div style="display:flex;align-items:flex-start;gap:16px;padding:14px 0;border-bottom:1px solid {LIGHT_BORDER};">
  <span class="serif" style="font-size:26px;font-weight:300;color:{BRAND_PRIMARY};min-width:34px;line-height:1;">01</span>
  <div>
    <div class="sans" style="font-size:14px;font-weight:600;color:{DARK_BG};">{Step title}</div>
    <div class="sans" style="font-size:12px;color:#8A8580;">{Step description}</div>
  </div>
</div>
```

**Strikethrough pill** (problem slides):
```html
<span style="font-size:11px;padding:5px 12px;border:1px solid rgba(255,255,255,0.1);border-radius:20px;color:#6B6560;text-decoration:line-through;">{Old thing}</span>
```

**Tag pill** (features/labels):
```html
<span style="font-size:11px;padding:5px 12px;background:rgba(255,255,255,0.06);border-radius:20px;color:{BRAND_LIGHT};">{Label}</span>
```

**Quote/prompt box**:
```html
<div style="padding:16px;background:rgba(0,0,0,0.15);border-radius:12px;border:1px solid rgba(255,255,255,0.08);">
  <p class="sans" style="font-size:13px;color:rgba(255,255,255,0.5);margin-bottom:6px;">{Label}</p>
  <p class="serif" style="font-size:15px;color:#fff;font-style:italic;line-height:1.4;">"{Quote}"</p>
</div>
```

**CTA button** (last slide only):
```html
<div style="display:inline-flex;align-items:center;gap:8px;padding:12px 28px;background:{LIGHT_BG};color:{BRAND_DARK};font-family:'{BODY_FONT}',sans-serif;font-weight:600;font-size:14px;border-radius:28px;">
  {CTA text}
</div>
```

### Typography scale
- Headings: 28–34px, weight 600, letter-spacing -0.3 to -0.5px, line-height 1.1–1.15
- Body: 14px, weight 400, line-height 1.5–1.55
- Tags/labels: 10px, weight 600, letter-spacing 2px, uppercase
- Step numbers: heading font, 26px, weight 300
- Small text: 11–12px

### Image embedding
If user uploaded images, embed them as `<img>` tags with base64 src.
Place on appropriate slides (hero background, feature illustration, etc.).
Always use `object-fit: cover` and constrain to the slide dimensions.
Use the correct MIME type based on the actual file format detected with `file` command.

---

## Phase 4: Preview

After writing carousel.html:

1. Tell the user:
   - The HTML file path: `{WORKSPACE_ROOT}/Design/Carousel-{YYYY-MM-DD}/carousel.html`
   - How to preview: "Open in your browser and swipe through the slides."
   - Invite feedback: "Let me know which slides to adjust before I export the PNGs."

2. **Wait for approval or feedback.** Iterate on specific slides as needed.
   - Do NOT regenerate the entire carousel unless the direction fundamentally changes.
   - Make targeted edits to specific slides via Python file writes.

---

## Phase 5: Export as PNGs

Once the user approves, write and run this export script as
`{WORKSPACE_ROOT}/Design/Carousel-{YYYY-MM-DD}/export.py`:

```python
import asyncio
from pathlib import Path

INPUT_HTML = Path("{WORKSPACE_ROOT}/Design/Carousel-{YYYY-MM-DD}/carousel.html")
OUTPUT_DIR = Path("{WORKSPACE_ROOT}/Design/Carousel-{YYYY-MM-DD}/slides")
OUTPUT_DIR.mkdir(exist_ok=True)

TOTAL_SLIDES = {N}   # set to actual slide count

VIEW_W = 420
VIEW_H = 525
SCALE  = 1080 / 420  # = 2.5714...

async def export_slides():
    from playwright.async_api import async_playwright
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page(
            viewport={"width": VIEW_W, "height": VIEW_H},
            device_scale_factor=SCALE,
        )
        html_content = INPUT_HTML.read_text(encoding="utf-8")
        await page.set_content(html_content, wait_until="networkidle")
        await page.wait_for_timeout(3000)  # wait for Google Fonts

        # Strip IG frame chrome, expose only the slide viewport
        await page.evaluate("""() => {
            document.querySelectorAll('.ig-header,.ig-dots,.ig-actions,.ig-caption')
                .forEach(el => el.style.display = 'none');
            const frame = document.querySelector('.ig-frame');
            frame.style.cssText = 'width:420px;height:525px;max-width:none;border-radius:0;box-shadow:none;overflow:hidden;margin:0;';
            const vp = document.querySelector('.carousel-viewport');
            vp.style.cssText = 'width:420px;height:525px;aspect-ratio:unset;overflow:hidden;cursor:default;';
            document.body.style.cssText = 'padding:0;margin:0;display:block;overflow:hidden;';
        }""")
        await page.wait_for_timeout(500)

        for i in range(TOTAL_SLIDES):
            await page.evaluate("""(idx) => {
                const track = document.querySelector('.carousel-track');
                track.style.transition = 'none';
                track.style.transform = 'translateX(' + (-idx * 420) + 'px)';
            }""", i)
            await page.wait_for_timeout(400)
            await page.screenshot(
                path=str(OUTPUT_DIR / f"slide_{i+1}.png"),
                clip={"x": 0, "y": 0, "width": VIEW_W, "height": VIEW_H},
            )
            print(f"Exported slide {i+1}/{TOTAL_SLIDES}")

        await browser.close()
        print(f"\nDone! {TOTAL_SLIDES} slides saved to: {OUTPUT_DIR}")

asyncio.run(export_slides())
```

**Before running, check Playwright is available:**
```bash
python3 -c "import playwright; print('ok')" 2>/dev/null || echo "NOT INSTALLED"
```

If not installed:
```bash
pip3 install playwright && python3 -m playwright install chromium
```

Then run:
```bash
python3 {WORKSPACE_ROOT}/Design/Carousel-{YYYY-MM-DD}/export.py
```

---

## Phase 6: Wrap Up

After export completes, report to the user:

```
✓ Carousel exported — {N} slides saved to:
  {WORKSPACE_ROOT}/Design/Carousel-{YYYY-MM-DD}/slides/

Files:
  carousel.html   ← browser preview
  slides/
    slide_1.png   ← 1080×1350px, ready for Instagram
    slide_2.png
    ...
    slide_{N}.png

Upload the slides/ folder contents to Instagram as a carousel post.
```

---

## Critical Rules

1. **Always use Python to generate HTML** — never shell scripts. Shell variable interpolation (`$`, backticks, numbers) corrupts HTML content.
2. **Never set viewport to 1080×1350** — keep at 420×525 and use `device_scale_factor`. Changing viewport reflows the layout.
3. **Always detect actual image format** with `file {path}` — do not trust file extensions. Use the correct MIME type.
4. **Content never overlaps the progress bar** — use `padding-bottom: 52px` on slide content.
5. **Last slide has no swipe arrow** — its absence signals the end.
6. **Logo search before questionnaire** — report what was found, let user confirm.
7. **Output always goes to** `{WORKSPACE_ROOT}/Design/Carousel-{YYYY-MM-DD}/`
8. **Iterate on specific slides** — never rebuild from scratch for minor changes.
