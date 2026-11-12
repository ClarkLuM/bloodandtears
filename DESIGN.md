---
version: alpha
name: "Blood and Tears"
description: "a roster, dungeons, professions and trading-card site for Blood and Tears, a Horde guild on WoW Forever"
colors:
  primary: "#a50d2c"
  on-primary: "#ffffff"
  surface: "#fefcfc"
  on-surface: "#272323"
  error: "#d93834"
typography:
  body-md: { fontFamily: "Figtree", fontSize: 14px, lineHeight: 20px }
rounded:
  control: 6px
  container: 8px
spacing:
  unit: 4px
---

# Blood and Tears

**Blood and Tears** is a roster, dungeons, professions and trading-card site for Blood and Tears, a Horde guild on WoW Forever.

- **For:** people who use it often, as an everyday app
- **Screens:** guild app (screens where people get work done)
- **Runs on:** web
- **Feel:** calm, minimal (deferential, minimal)
- **Brand color:** Your brand color (#A50D2C) is on the buttons exactly, with white text that reads clearly on it. In dark mode, buttons use a lighter shade of it (#E84E5A), so their dark text reads clearly.
- **Decided:** 13 answers you gave, 2 picked for you; everything else uses sourced defaults
- **Standards:** 289 house standards followed (locked, house standards v3), 8 of your own; see the Standards section
- **Next:** zoom into Colors, Layout, Elevation & Depth, or stop here: each level works
- **Licence risks:** Alegreya Sans SC: confirm the web licence (record it with engine.py set raw.fontLicence).

> Generated from `opendesigner/state.json` and `opendesigner/decisions.md`. Made with OpenDesigner 0.1.0. `opendesigner/tokens/` is the source of truth. Change the system with `engine.py set ...` and `engine.py build`, not by editing this file (notes inside `<!-- od:keep -->` blocks survive). Each section opens with one plain sentence; open **More** for the designer and engineer detail.

## Overview

> Zoom: broad (1 of 3), 5 decisions in this area. To zoom in, answer Q-scope-02, Q-scope-05, Q-brand-02.
<!-- od:zoom area=overview level=1 -->

**Blood and Tears feels deferential and minimal. Screens are comfortable, in a flat style.**
Designers: visual style: flat, tonal, glass · Code: `preset in state.json`

<details><summary>More</summary>

**Your answers here** (each one either sets tokens or is a rule for this section):
- Which overall look fits: flat, tonal, glass, neo-brutalist, soft, or bold and busy? **Flat 2.0** (chosen; tokens; Q-dir-01)
- What are these screens mostly for: selling, getting work done, reading, or enjoying an experience? **guild app (Operate)** (chosen; tokens; Q-scope-06)
- Where is the project now: an idea, being built, close to launch, or live with real users? **Close to launch** (assumed; owner input; Q-scope-07)

**Intent.** a roster, dungeons, professions and trading-card site for Blood and Tears, a Horde guild on WoW Forever

- Audience: people who use it often, as an everyday app
- The memorable thing: not recorded yet (Q-brand-02)
- Surfaces: guild app (Operate: density comfortable; no hero; cards only to group related data)
- Platforms: web; inputs: pointer, touch
- Direction: preset flat2; feel deferential, minimal (your words: calm, minimal)

**Principles (ranked).**
No principles recorded yet (Q-brand-07). Until they are, the dials act as the tie-breakers below.

**Dial positions.** Three posture dials set the overall stance. Five character dials fine-tune it.

- **Expression 15/100** (productive to expressive: productive): type ratio 1.2, hero moments: none, expressive motion: none, brand color role: reserved-accent, containment: whitespace.
- **Brand presence 20/100** (native to brand-led: native): typeface suggestion: system-font-per-platform, brand color placement: accent-only+content-layer, native component share about 92%, voice guidance: none.
- **Density 50/100** (spacious to compact: balanced): body 14px on the web, default control 40px, density mode comfortable, icons 20px; hit areas never shrink.
- **Energy 35/100** (calm to energetic: leaning calm): standard easing [0.77, 0, 0.175, 1], duration multiplier 0.94, spring damping 1.0, heading weight 650, navigation: neutral.
- **Roundness 45/100** (sharp to soft: balanced): control radius 6, icon corners default, caps round.
- **Depth 30/100** (flat to deep: flat): depth model: ring+faint-shadow.
- **Colorfulness 45/100** (monochrome to vivid: balanced): scheme tonalSpot, accent chroma 78.1 (HCT), 1 accent(s), surfaces: neutral+one-accent.
- **Warmth 50/100** (cool/formal to warm/friendly: balanced): neutral tint chroma 0.0 at hue 264, borders: default, title-case, contractions allowed.

**Zoom by area** (sketch, broad, defined, detailed). You can stop at any level; each one works.

| Area | Zoom | Next questions |
|---|---|---|
| Colors | sketch | Q-color-02 |
| Typography | broad | Q-type-02, Q-type-03, Q-type-04 |
| Layout | sketch | Q-space-01, Q-space-02, Q-space-03 |
| Elevation & Depth | sketch | Q-depth-01 |
| Shapes | sketch | Q-shape-01 |
| Components | sketch | Q-comp-01, Q-comp-02, Q-state-01 |
| Motion | sketch | Q-motion-01 |
| Modes and Themes | defined | Q-theme-02, Q-theme-04 |
| Iconography and Imagery | sketch | Q-icon-01, Q-icon-02, Q-icon-06 |
| Content and Voice | defined | Q-voice-05, Q-voice-06 |
| Accessibility | sketch | Q-aud-02, Q-aud-03, Q-aud-04 |
| Platforms and Devices | sketch | Q-plat-05, Q-plat-10, Q-plat-08 |

The tokens in `opendesigner/tokens/` (DTCG 2025.10 with `opendesigner.resolver.json`) are the source of truth. This file is a generated view.

Decisions: D-0006 (answers.Q-scope-07), D-0022 (macros), D-0025 (answers.Q-scope-06), D-0028 (answers.Q-aud-01), D-0034 (answers.Q-dir-01).

</details>

**Taste card.** How it looks and feels, in five lines for you, your team and any AI that builds with it. Nothing on it is invented: each line says where it comes from.
Designers: style brief, mood in words · Code: `taste.brief, taste.never`

| Line | What it says | From |
|---|---|---|
| In your words | "dark, like night mode, with a touch of Horde; we are Loot Goblins after all" | your words |
| Color | One accent color: your brand color `#a50d2c` (exactly) marks buttons, links and focus. Everything else stays neutral. Keep the accent to small areas, about 15% of a screen at most (a rule of thumb, DC-L15-03). | brand color; colorfulness 45/100 |
| Shape | Buttons and fields have 6px corners; cards have 8px corners. Cards get a faint outline and a very soft shadow. | roundness 45/100, depth 30/100 |
| Motion | Leaning calm. Most movements take 200ms. They turn into fades when a person asks for less motion. | energy 35/100 |
| Never | Nothing yet. Say what it should never look like, or rate real screens in the taste poll. | not asked yet |

## Colors

> Zoom: sketch (0 of 3), 5 decisions in this area. To zoom in, answer Q-color-02.
<!-- od:zoom area=color level=0 -->

**One accent color: your brand color `#a50d2c` (exactly) marks buttons, links and focus.** Everything else stays neutral.
Designers: primary or brand accent · Code: `color.bg.accent`

<details><summary>More</summary>

**Your answers here** (each one either sets tokens or is a rule for this section):
- How colorful should the palette be, from all gray to vivid? **Tonal, low to medium color** (chosen; tokens; Q-color-03)
- Your text, backgrounds and lines use grays. **Slight tint toward the accent hue (OKLCH chroma about 0.01-0.03 at mid steps)** (chosen; tokens; Q-color-09)

**Intent.** Brand color `#a50d2c` drives the accent ramp's hue; the Colorfulness dial (45) sets its chroma (scheme tonalSpot, peak HCT chroma 78.07). The brand's role is **reserved-accent** and it sits closest to accent step 9. Your brand color #A50D2C is on the buttons exactly (white text on it reads at 7.80:1). In dark mode, buttons use #E84E5A, a lighter shade of it, because the dark text on dark-mode buttons would read at only 2.34:1 on the exact color.

**How ramps are built.** Each hue gets twelve steps in OKLCH, placed by contrast. Step 8 reaches at least 3:1 (edges and focus). Steps 10 and 11 reach the text minimum on backgrounds 1-4. Step 12 reaches at least 7:1. Steps 2-6 are spaced evenly in lightness between step 1 and step 7. Light and dark ramps are solved separately. Dark solids are lighter and carry dark text (dark mode is a separate mapping, never an inversion). Text minimum: 4.5:1 (WCAG 2.2 AA).

| Ramp | Light steps 1-12 | Solid carries |
|---|---|---|
| `accent` | `#fffcfc` `#fff1f1` `#ffe6e5` `#ffdbda` `#ffcfce` `#ffc3c2` `#ffb7b7` `#d46367` `#a50d2c` `#930024` `#880020` `#5b2124` | light |
| `danger` | `#fffcfc` `#fff1ef` `#ffe6e3` `#ffdbd6` `#ffcfc9` `#ffc4bc` `#ffb8af` `#d76258` `#d93834` `#c72f2c` `#a82321` `#5c201c` | light |
| `info` | `#fbfdff` `#eaf6ff` `#d9efff` `#c7e7ff` `#b5e0ff` `#a3d8ff` `#8fd1ff` `#008ed1` `#007cb7` `#0070a6` `#005c8a` `#003755` | light |
| `neutral` | `#fefcfc` `#f6f3f3` `#eeebea` `#e6e2e2` `#dfd9d9` `#d7d0d0` `#cfc8c8` `#8c8585` `#7c7373` `#6a6262` `#5c5555` `#272323` | light |
| `success` | `#f9fef9` `#ebf7ed` `#d9f1dd` `#c6eccc` `#b2e7bc` `#9de2ab` `#87dc9a` `#089a47` `#00883d` `#007b36` `#00652c` `#003d17` | light |
| `warning` | `#fffcf8` `#f8f4ec` `#f5ead9` `#f1e1c6` `#eed8b3` `#ebce9f` `#e7c58b` `#aa7f2c` `#efb239` `#dda331` `#845d00` `#463001` | dark |

**Step-distance guarantee** (neutral, light; WCAG contrast of a foreground step on background steps 1-5):

| Foreground | on 1 | on 2 | on 3 | on 4 | on 5 |
|---|---|---|---|---|---|
| neutral 8 | 3.54 | 3.28 | 3.05 | 2.81 | 2.59 |
| neutral 9 | 4.51 | 4.18 | 3.89 | 3.59 | 3.31 |
| neutral 10 | 5.81 | 5.38 | 5.01 | 4.62 | 4.26 |
| neutral 11 | 7.12 | 6.60 | 6.14 | 5.66 | 5.22 |
| neutral 12 | 15.21 | 14.09 | 13.11 | 12.10 | 11.15 |

**States.** Hover is at least 1.15:1 from its fill and pressed at least 1.3:1, as shade steps (DC-L01-17). Where a color is unknown at design time, use the state opacities in `opacity.state.*`.

| Fill | Base | Hover | Pressed |
|---|---|---|---|
| `color.bg.action.primary` | `#a50d2c` | `#930024` (1.19:1) | `#85001f` (1.34:1) |
| `color.bg.accent.bold` | `#a50d2c` | `#930024` (1.19:1) | `#85001f` (1.34:1) |

**Semantic roles** (use these, never the ramps):

| Token | Light | Dark | Use |
|---|---|---|---|
| `color.bg.accent.bold` | `#a50d2c` | `#e84e5a` | Solid accent fill. |
| `color.bg.accent.bold-hover` | `#930024` | `#f85c67` | Hover: one step, at least 1.15:1 from the solid (DC-L01-17). |
| `color.bg.accent.bold-pressed` | `#85001f` | `#ff6b73` | Pressed: at least 1.3:1 from the solid. |
| `color.bg.accent.subtle` | `#ffe6e5` | `#3c2020` | Selected rows, accent badges. |
| `color.bg.accent.subtle-hover` | `#ffdbda` | `#4d2324` | Hover on accent subtle fills. |
| `color.bg.accent.subtle-pressed` | `#ffcfce` | `#5e2629` | Pressed accent subtle fills. |
| `color.bg.action.primary` | `#a50d2c` | `#e84e5a` | Primary action. One per view (DC-L15-03, L15 P08). |
| `color.bg.action.primary-hover` | `#930024` | `#f85c67` | Hover: one step, at least 1.15:1 from the solid (DC-L01-17). |
| `color.bg.action.primary-pressed` | `#85001f` | `#ff6b73` | Pressed: at least 1.3:1 from the solid. |
| `color.bg.brand` | `#a50d2c` | `#e84e5a` | Brand fill for signature surfaces; carries text.on-brand (brandAnchor rule, DC-L01-09). |
| `color.bg.danger.bold` | `#d93834` | `#db5c52` | Danger solid fill. |
| `color.bg.danger.bold-hover` | `#c72f2c` | `#ea6a5f` | Hover: one step, at least 1.15:1 from the solid (DC-L01-17). |
| `color.bg.danger.bold-pressed` | `#bc2323` | `#f57468` | Pressed: at least 1.3:1 from the solid. |
| `color.bg.danger.subtle` | `#ffe6e3` | `#39221f` | Danger banner and badge background. |
| `color.bg.disabled` | `#eeebea` | `#302d2d` | Disabled control fill. |
| `color.bg.field` | `#ffffff` | `#272424` | Text field fill: outlined fields sit on the raised surface (Q-form-01). |
| `color.bg.info.bold` | `#007cb7` | `#008bcd` | Info solid fill. |
| `color.bg.info.bold-hover` | `#0070a6` | `#0099e0` | Hover: one step, at least 1.15:1 from the solid (DC-L01-17). |
| `color.bg.info.bold-pressed` | `#006799` | `#00a3ee` | Pressed: at least 1.3:1 from the solid. |
| `color.bg.info.subtle` | `#d9efff` | `#062a40` | Info banner and badge background. |
| `color.bg.inverse` | `#272323` | `#ede8e8` | Tooltips and toasts: the inverted surface. |
| `color.bg.neutral.subtle` | `#eeebea` | `#3a3535` | Secondary buttons, chips, hovered rows. |
| `color.bg.neutral.subtle-hover` | `#e6e2e2` | `#433e3e` | Hover: +1 step (DC-L01-17). |
| `color.bg.neutral.subtle-pressed` | `#dfd9d9` | `#4d4747` | Pressed or selected: +2 steps (DC-L01-17). |
| `color.bg.success.bold` | `#00883d` | `#009845` | Success solid fill. |
| `color.bg.success.bold-hover` | `#007b36` | `#00a74c` | Hover: one step, at least 1.15:1 from the solid (DC-L01-17). |
| `color.bg.success.bold-pressed` | `#007132` | `#19b155` | Pressed: at least 1.3:1 from the solid. |
| `color.bg.success.subtle` | `#d9f1dd` | `#172c1c` | Success banner and badge background. |
| `color.bg.warning.bold` | `#efb239` | `#e6b55d` | Warning solid fill. |
| `color.bg.warning.bold-hover` | `#dda331` | `#f7c56e` | Hover: one step, at least 1.15:1 from the solid (DC-L01-17). |
| `color.bg.warning.bold-pressed` | `#d29921` | `#ffd388` | Pressed: at least 1.3:1 from the solid. |
| `color.bg.warning.subtle` | `#f5ead9` | `#2f2618` | Warning banner and badge background. |
| `color.border.accent` | `#d46367` | `#da565e` | Selected card or accent outline. |
| `color.border.danger` | `#d76258` | `#ce6157` | Danger boundary, for example an invalid field (3:1). |
| `color.border.default` | `#cfc8c8` | `#4d4747` | Outline buttons and table grids (decorative; the label carries meaning). |
| `color.border.focus` | `#a50d2c` | `#ff8a8c` | Focus ring (3:1 against every surface, DC-L04-09). |
| `color.border.info` | `#008ed1` | `#0089c9` | Info boundary, for example an invalid field (3:1). |
| `color.border.input` | `#8c8585` | `#867e7e` | Text field and select borders (3:1, DC-L01-16). |
| `color.border.separator` | `#e6e2e2` | `#3a3535` | Hairlines between table rows and list items, lighter than border.subtle; decorative, so never the only cue (DC-L23-05). |
| `color.border.strong` | `#8c8585` | `#867e7e` | Boundaries that are the only cue: inputs, checkboxes, switches (3:1, WCAG 1.4.11). |
| `color.border.subtle` | `#d7d0d0` | `#433e3e` | Dividers and card edges (decorative). |
| `color.border.success` | `#089a47` | `#199547` | Success boundary, for example an invalid field (3:1). |
| `color.border.warning` | `#aa7f2c` | `#a47b2f` | Warning boundary, for example an invalid field (3:1). |
| `color.icon.accent` | `#880020` | `#ff8a8c` | Selected and interactive icons. |
| `color.icon.default` | `#5c5555` | `#b1aaa9` | Icons beside text; same color as secondary text (DC-L05-08). |
| `color.icon.on-accent` | `#ffffff` | `#161515` | Icons on solid accent fills. |
| `color.icon.subtle` | `#6a6262` | `#9c9494` | Decorative icons. |
| `color.overlay.scrim` | `#272323 @0.45` | `#000000` | Modal backdrop (DC-L04-18; Q-depth-06). |
| `color.surface.base` | `#fefcfc` | `#1e1c1c` | The page background. |
| `color.surface.nav` | `#fefcfc` | `#1e1c1c` | Navigation on the page background. |
| `color.surface.overlay` | `#ffffff` | `#302d2d` | Menus, popovers, dialogs; always with elevation.floating or elevation.overlay. |
| `color.surface.raised` | `#ffffff` | `#272424` | Cards and panels on the page. |
| `color.surface.sunken` | `#f6f3f3` | `#161515` | Wells, code blocks, page gutters. |
| `color.text.accent` | `#880020` | `#ff8a8c` | Accent text and selected labels. |
| `color.text.danger` | `#a82321` | `#ff8c80` | Danger text and icons; pair with an icon or label (DC-L01-15). |
| `color.text.disabled` | `#8c8585` | `#867e7e` | Disabled labels; exempt from contrast minimums (WCAG 1.4.3 exception). |
| `color.text.info` | `#005c8a` | `#3ab6ff` | Info text and icons; pair with an icon or label (DC-L01-15). |
| `color.text.inverse` | `#ffffff` | `#161515` | Text on color.bg.inverse (tooltips, toasts). |
| `color.text.link` | `#880020` | `#ff8a8c` | Links. Underline them in running text so color is not the only cue. |
| `color.text.on-accent` | `#ffffff` | `#161515` | Text and icons on color.bg.accent.bold* (auto-picked light or dark, S-L06-094). |
| `color.text.on-action` | `#ffffff` | `#161515` | Text on the primary action fill. |
| `color.text.on-brand` | `#ffffff` | `#161515` | Text on color.bg.brand. |
| `color.text.on-danger` | `#ffffff` | `#161515` | Text on bg.danger.bold. |
| `color.text.on-info` | `#ffffff` | `#161515` | Text on bg.info.bold. |
| `color.text.on-success` | `#ffffff` | `#161515` | Text on bg.success.bold. |
| `color.text.on-warning` | `#272323` | `#161515` | Text on bg.warning.bold. |
| `color.text.primary` | `#272323` | `#ede8e8` | Body copy, headings, labels (guaranteed >= 7:1 on steps 1-5). |
| `color.text.secondary` | `#5c5555` | `#b1aaa9` | Supporting text (guaranteed >= the text minimum on surfaces and neutral fills 1-4). |
| `color.text.success` | `#00652c` | `#47c26c` | Success text and icons; pair with an icon or label (DC-L01-15). |
| `color.text.tertiary` | `#6a6262` | `#9c9494` | Captions and placeholders (still meets the text minimum on surfaces 1-4). |
| `color.text.warning` | `#845d00` | `#fecf7f` | Warning text and icons; pair with an icon or label (DC-L01-15). |

**Use / avoid.**
- Use one solid accent fill per view for the primary action; spend chroma on small, meaningful elements.
- Avoid gray text on colored fills; use the matching `text.on-*` role.
- Avoid color as the only signal: pair status colors with an icon or label.
- Charts: no chart palette yet (Q-color-19). Take chart colors from the status and accent hues, and check them separately.

**Tailwind classes:** `bg-action-primary`, `hover:bg-action-primary-hover`, `active:bg-action-primary-pressed`, `text-on-action`, `bg-surface-base`, `bg-surface-raised`, `text-fg-primary`, `text-fg-secondary`, `text-fg-link`, `border-line-subtle`, `border-line-input`, `outline-line-focus`, `bg-danger-bold`.

Decisions: D-0016 (answers.Q-theme-01), D-0036 (answers.Q-color-09), D-0037 (answers.Q-color-03), D-0092 (raw.brandColor), D-0093 (raw.neutralBase).

</details>

## Typography

> Zoom: broad (1 of 3), 3 decisions in this area. To zoom in, answer Q-type-02, Q-type-03, Q-type-04.
<!-- od:zoom area=typography level=1 -->

**Body text is 14px, and each larger size is about 1.2 times the one below.**
Designers: type scale: base size and ratio · Code: `font.size.14`

<details><summary>More</summary>

**Your answers here** (each one either sets tokens or is a rule for this section):
- Should it use the device's built-in font, a free plain font like Inter, or your brand font? **A free font with character** (chosen; tokens; Q-type-01)

**Intent.** Body text is 14px; sizes follow `round(14 x 1.2^n)` for n from -2 to 5, reaching about 2.5x body (product surfaces only). Sizes: 12, 14, 17, 20, 24, 29, 35px.

- Text face: Figtree, system-ui, -apple-system, Segoe UI, Roboto, Helvetica Neue, Arial, sans-serif. Licence status (hook H-type): **pending**.
- Licence by platform: text: Figtree (open licence or system font: web, apps and self-hosting); display: Alegreya Sans SC: licensed for nothing recorded; not recorded for web, apps, self-hosting.
- On iOS the Swift file uses Dynamic Type text styles (body 17 pt), so text follows the person's text size setting; Compose uses sp, which follows the Android font scale.
- Weights: body 400, label 400, heading 600 (two or three distinct weights per view).
- Emphasized variants: off (they turn on at Expression 67 and up, DC-L02-11).
- Line heights snap to a 4px grid: 1.5 up to 17px, 1.4 to 26px, 1.25 to 44px, 1.12 above.
- Letter spacing: +0.02em at 11-12px, -0.01em from 32px, -0.02em from 48px.
- Text scaling: CSS sizes are rem, line heights unitless, so text scales to 200% (WCAG 1.4.4); containers must grow with it.
- Scripts: Latin only; add scripts in raw.scripts to get per-script line heights (DC-L02-25).

| Style | Size/line (px) | Weight | Tracking | Use |
|---|---|---|---|---|
| `text.body.lg` | 17/24 | 400 | 0em | Long-form reading, onboarding copy. |
| `text.body.md` | 14/20 | 400 | 0em | Default UI text: forms, tables, descriptions. |
| `text.body.sm` | 12/16 | 400 | 0.02em | Helper text, timestamps, captions. |
| `text.code.md` | 14/20 | 400 | 0em | Code blocks, token names. |
| `text.code.sm` | 12/16 | 400 | 0.02em | Inline values, dense code rows. |
| `text.headline.lg` | 35/44 | 600 | -0.01em | Page and section titles. |
| `text.headline.md` | 29/36 | 600 | 0em | Page and section titles. |
| `text.headline.sm` | 24/32 | 600 | 0em | Page and section titles. |
| `text.label.lg` | 14/20 | 400 | 0em | Button and control labels. |
| `text.label.md` | 12/16 | 400 | 0.02em | Small control labels, badges, dense tabs. |
| `text.label.sm` | 12/16 | 400 | 0.05em caps | Overlines in capitals with wide tracking (DC-L02-18). |
| `text.numeric.lg` | 20/28 | 600 | 0em | Key numbers: balances, KPIs. |
| `text.numeric.md` | 14/20 | 400 | 0em | Amounts and table figures: tabular digits line up in columns; right-align numeric columns. |
| `text.title.lg` | 20/28 | 600 | 0em | Card, panel and group titles. |
| `text.title.md` | 17/24 | 600 | 0em | Card, panel and group titles. |
| `text.title.sm` | 14/20 | 600 | 0em | Table headers, field-group titles. |

**Use / avoid.**
- Use at most three sizes and two weights in one view; let color and weight carry hierarchy before size.
- Avoid all caps for sentences and in scripts without case; use weight for emphasis there.

**Tailwind classes:** `text-body-md`, `text-label-lg`, `text-title-md`, `text-headline-md`.

Decisions: D-0039 (answers.Q-type-01), D-0040 (raw.textFace), D-0041 (raw.displayFace).

</details>

## Layout

> Zoom: sketch (0 of 3), 0 decisions in this area. To zoom in, answer Q-space-01, Q-space-02, Q-space-03.
<!-- od:zoom area=layout level=0 -->

**Spacing comes in steps of 4px, and screens use comfortable spacing by default.**
Designers: spacing scale, 0 to 96 · Code: `space.0 to space.96`

<details><summary>More</summary>

**Intent.** Everything sits on a 4px unit: ladder 0, 2, 4, 6, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96. Density is a mode on the semantic layer (default **comfortable**). Primitives and minimum tap areas never change.

| Density | inset xs/sm/md/lg/xl | section sm/md/lg | control sm/md/lg | row sm/md/lg/two-line | outer:inner |
|---|---|---|---|---|---|
| spacious | 6 / 12 / 16 / 20 / 32 | 64 / 80 / 96 | 40 / 48 / 56 | 52 / 56 / 64 / 80 | 3.5 |
| comfortable (default) | 4 / 8 / 12 / 16 / 24 | 32 / 40 / 64 | 32 / 40 / 48 | 44 / 48 / 56 / 72 | 2.5 |
| compact | 2 / 6 / 8 / 12 / 20 | 16 / 24 / 40 | 24 / 32 / 40 | 36 / 40 / 48 / 64 | 2.0 |

- Target sizes: pointer 24px, touch 44px; `size.target.min` is the floor for the primary input, and `space.target.gap` separates adjacent targets.
- Inner gaps stay below outer gaps (at least half), so grouping reads without borders (L15 P16).
- Breakpoints and grid: not generated yet; use the platform defaults and keep layout spacing independent of density (DC-L03-17).

**Use / avoid.**
- Parents own spacing (padding and gap); children never set outer margins.
- Avoid values off the ladder; if one is needed, add it as a decision.

Decisions: none recorded yet; values are defaults from references/levers.json.

</details>

## Elevation & Depth

> Zoom: sketch (0 of 3), 0 decisions in this area. To zoom in, answer Q-depth-01.
<!-- od:zoom area=elevation level=0 -->

**Cards get a faint outline and a very soft shadow.**
Designers: flat, shadowed, tonal or glass · Code: `$extensions.opendesigner.model`

<details><summary>More</summary>

**Intent.** Depth 30/100 selects the **ring+faint-shadow** model. Shadow alpha in light mode is 0.107; dark mode doubles it and lifts surfaces by lightness instead (sunken, base, raised, overlay).

| Token | Layers (x y blur spread) | Use |
|---|---|---|
| `elevation.raised` | 0 0 0 1, 0 1 2 0 | Cards that lift on hover, sticky headers, dragged rows. |
| `elevation.floating` | 0 0 0 1, 0 1 2 0, 0 4 12 0 | Menus, popovers, dropdowns. |
| `elevation.overlay` | 0 0 0 1, 0 1 2 0, 0 12 32 0 | Dialogs and sheets (with color.overlay.scrim). |

- Borders: 1px default, 2px selected and focus, 4px emphasis; width changes use an inset shadow so layout does not jump.
- Stacking: page < raised < floating (menus) < overlay (dialogs with `color.overlay.scrim`).
- No materials or glass in this system.

Decisions: none recorded yet; values are defaults from references/levers.json.

</details>

## Shapes

> Zoom: sketch (0 of 3), 0 decisions in this area. To zoom in, answer Q-shape-01.
<!-- od:zoom area=shape level=0 -->

**Buttons and fields have 6px corners; cards have 8px corners.**
Designers: corner radius, sharp to pill · Code: `radius.control, CSS border-radius`

<details><summary>More</summary>

**Intent.** Roundness 45/100 gives controls a **6** radius; details 2px, containers 8px, overlays 12px, people full. Controls under 32px tall use `radius.control-sm` (4).

- Nested radius: inner = max(outer - padding, smallest step). Here it is 2px inside a container with `space.inset.lg` padding. Equal radii on nested shapes look uneven (DC-L04-05).
- Focus ring: 2px, 2px offset, radius = control radius + offset (8).
- Icons: default corners, round caps.
- Corners (Q-shape-04, DC-L04-04): the radii are the same everywhere; iOS draws them continuous (`DS.Radius.shape(...)`, `.continuous`), Android circular (`RoundedCornerShape`), the web and Figma circular.
- Signature shapes: none generated; a brand shape library is a designer asset (hook H-motif).

Decisions: none recorded yet; values are defaults from references/levers.json.

</details>

## Components

> Zoom: sketch (0 of 3), 0 decisions in this area. To zoom in, answer Q-comp-01, Q-comp-02, Q-state-01.
<!-- od:zoom area=components level=0 -->

**Version 1 plans 25 components, all built from these tokens.**
Designers: core set of about 25 components · Code: `button.* (proposed), APG pattern`

<details><summary>More</summary>

**Intent.** v1 components use the semantic tokens only. Base: not chosen yet (Q-comp-01). Buttons are 40px tall (comfortable), 6 radius, `text.label.lg`; one primary action per view.

| Component | Status |
|---|---|
| button | planned (tokens ready) |
| text-field | planned (tokens ready) |
| textarea | planned (tokens ready) |
| select | planned (tokens ready) |
| checkbox | planned (tokens ready) |
| radio | planned (tokens ready) |
| switch | planned (tokens ready) |
| slider | planned (tokens ready) |
| tabs | planned (tokens ready) |
| tooltip | planned (tokens ready) |
| popover | planned (tokens ready) |
| dialog | planned (tokens ready) |
| menu | planned (tokens ready) |
| progress-bar | planned (tokens ready) |
| spinner | planned (tokens ready) |
| banner | planned (tokens ready) |
| badge | planned (tokens ready) |
| avatar | planned (tokens ready) |
| card | planned (tokens ready) |
| list | planned (tokens ready) |
| table | planned (tokens ready) |
| link | planned (tokens ready) |
| breadcrumbs | planned (tokens ready) |
| side-navigation | planned (tokens ready) |
| accordion | planned (tokens ready) |

**Contested policies:** Validation timing and disabled submit: pending; Field style: pending; Toasts: pending; Undo versus confirm: pending; Danger actions: pending; Button emphasis levels: pending.

**Use / avoid.**
- Every interactive component shows hover, pressed, focus-visible and disabled states from the tokens.
- Inputs keep a 3:1 boundary (`color.border.input`); signifier strength: balanced.
- Component docs belong in `opendesigner/components/<name>.md` (spec 7.8).

Decisions: none recorded yet; values are defaults from references/levers.json.

</details>

<!-- od:keep -->
### Site components (written by hand, kept on every refresh)

These are the parts the site is built from today. New work should reuse them before inventing new ones.

- **Look: Obsidian.** Near-black greys in dark mode (`--base #171515`, `--raised #201d1d`), neutral off-white in light, with Blood and Tears red (`#b8282a`) as the only strong colour. Gold (`--lvl`) is kept for game moments: levels, the Hall of Firsts, guild milestones and Ding. Item colours follow WoW quality (green, blue, purple, orange).
- **Menu:** Roster, Dungeons, Cards, Professions. On phones it's a four-tab bar along the bottom; History and Duels are pages under Roster and Cards.
- **Roster rows:** a table on wide screens; on phones each person is two or three lines (name and tags with role · level; class, race and spec with last seen; professions and best loot when there are any).
- **Page order on phones (roster):** Since You Were Last Here (when there's news), totals, roster, In Game Today, Character of the Day, Guild Feed, Leaderboards, Guild Makeup, About, Site Use (officers).
- **Trading card:** 260 × 380, tier frame (Plain, Bronze 20, Silver 40, Gold foil 60), arched picture, three stat bars, flavour line, mini strip. Foil tiers shine on hover (fine pointers only, none with reduced motion). Cards flip (click, tap, Enter, Space) to a back with two tabs: Stats (stats, talents, professions with bars, Hall of Firsts) and Passport (35 dungeon stamps). Stamps (1st, 60, 300, Epic, PvP) sit on the picture. The card has its own small type sizes (8 to 11 px labels) because it's a designed object that also exports as a picture.
- **Class icons:** 18 px Wowhead class icons with a 1 px ring in the class colour; a colour dot if the icon fails.
- **More menu:** one ghost "More" button holding the less common actions, grouped under small headings; one filled button stays outside it.
- **Celebration (Ding), card reveal (picked 7 Nov from a review of today, card reveal, unit frame and a split):** a dialog over a dark scrim. The character's own card starts face down and turns over, a red wax seal with the level is pressed onto its right edge, then the title and what's new. One filled button (Copy for Discord) and Close; Escape and the scrim close it; no timer, since it has an action (STD-components-toasts-drawers-15). Reduced motion: no flip, a 200 ms fade.
- **Guild milestone toast (unit frame):** bottom-right (above the menu on phones), the in-game player frame: a gold-ringed portrait with the blood drop, a badge with the number, a full XP bar, the milestone in gold display type. Closes after 4 s, paused on hover, focus, drag and hidden tabs, swipes away. Celebrations queue one at a time.
- **Character page order:** two independent columns, not rows, so a short card never leaves a hole beside a tall one. Wide column: Gear (pane and stats side by side when the card is 640px or wider), Dungeon Passport, Professions. Side column (360px, 320px under 1000px): Card, Talents, Journey. The passport folds to cleared dungeons plus those within the character's level (from 3 below a dungeon's range to its top), topped up to three upcoming, with Show all. Under 900px the columns dissolve and `--o` restores the phone order. On phones the Overview, Gear and Professions tabs show one kind at a time.
- **Duel matchup notes:** the reason for a matchup point or spec bonus sits under the fighter's name in small gold text, so the bonus is never hidden in the number.
- **Roster toolbar:** one row: search, Filters (funnel icon plus a gold count badge), Sort (default Highest level, like the in-game roster), View (List, By class, Cards). Filters open as a sunken panel underneath; when it's shut, active filters show as removable chips.
- **Passport stamp states:** stamped (filled red seal, tilted) or not yet (dashed ring, level range). A stamp from loot is a full stamp too (the owner asked for that over a separate 'unconfirmed' look, 11 Nov 2026); its caption says 'Looted: <item>' instead of 'Cleared', so where it came from is still visible.
- **Recipe finder (Professions):** search plus a Profession select on one row (same toolbar as the roster). Each recipe row: name, a source pill (Known green, Trainer gold, Recipe needed neutral), profession and skill right-aligned, then who qualifies under a plain label. Inferred never looks confirmed: the labels say "can learn" and "skilled enough", never "knows", except for recipes the profession teaches automatically. 20 rows, then Show all.
- **Dungeon detail (Dungeons):** under Who's in Range, separated by hairlines: Who's Been (chips), then What Drops as a fold with bosses in a responsive grid (min 220px columns) and a gold note on items someone has.
- **Items everywhere:** one helper (`itemRef`) for any item name: [Name] in its quality colour linking to Wowhead with the hover tooltip, or, with no ID or quality, plain bold text. Never a guessed quality colour.
- **Talent tooltips:** the item tooltip box (`.whtip`) reused with name, rank in grey and the description in game gold (#ffd100). Hover only; touch keeps tap-to-open.
- **Phone tap targets (polish pass, 11 Nov):** chips 36px tall on phones, folds' headers 44px; the trading card's Stats/Passport tabs keep their 20px look but get an invisible 38px tap area.
- **Faded ("not seen in two weeks"):** dashed outline and secondary text colour, never opacity, so the name stays readable (4.5:1).
- **Gold text on light:** any gold label (duel matchup notes, loot owners, Trainer pills) uses #8a5a12 in light mode; #d4a24c only on dark.
- **Professions page order:** Who Can Make It? first, then "Who Has What" with the All / Primary / Secondary switch beside it, since that switch only filters the cards below.
- **Units:** type, spacing and sizes in rem (1rem = 16px), so everything follows the browser's text size; px only for 1-2px hairlines, borders, radii, shadows, outlines and breakpoints. Grids with a minimum column width use `minmax(min(100%, X), 1fr)` so they never force sideways scrolling at large text. Long names wrap rather than truncate in duel rounds; the phone roster's middle column is capped with `fit-content(50%)`.
- **Can make (character page):** inside the Professions card, under a hairline: a small "Can make" label, then one fold per crafting profession (count in the summary), listing known and trainer recipes with the same Known/Trainer pills as the finder, skill right-aligned.
- **Fold memory:** every fold compares a toggle with what's saved now, not what was saved when it was drawn.
- **Journey folds:** same pattern as Guild History. Each day is a fold; today is open, or the latest day if nothing happened today. Only hand toggles that differ from the default are remembered.
- **Roster:** search with a magnifier, a View switch (A to Z, By class, Cards), then labelled selects for the filters and sort; on phones the filters fold behind one Filters button with a count. A status line says how many are showing, with Clear filters. Rows are compact with a chevron at the end; the whole row opens in place on a subtle fill with three columns (professions, build, armory) and actions. By class adds a sunken heading row per class.
- **Armory state:** a small dot plus words, never colour alone: green Up to date, grey Data from …, gold Checked … (behind), hollow Waiting for the armory or Not on the armory yet.
- **Tags:** small rounded labels for You, Guild Master, Officer and Not in the guild. There's no Alt tag: every character is shown the same way.
- **Edit character:** first and last name, role, Can also play and when they joined (optional); race, class and level only until the armory finds the character. Gear and professions are read-only and come from the armory.
- **Totals and stats:** display-font numbers in tabular figures, a secondary label underneath, and "+N this week" in the accent text colour. A 3 px gold line along the bottom of each total shows the way to the next guild milestone (the number is in the tile's tooltip and for screen readers).
- **Since You Were Last Here:** a card at the top of the roster with the accent border and a faint red wash, display-font counts with plain labels, See what happened and Hide. History marks the same point with a thin red rule labelled You were last here.
- **Neck and neck:** lines at the top of the Guild Feed while two players share a level they both just reached, with "now" in gold where the time goes.
- **Guild Makeup:** a role bar split by count (tanks `#3d6fd6`, healers `#2e9e3f`, DPS `#b8282a`) with a legend, a one-line note on tanks and healers, then class icons with counts in two columns.
- **Exported pictures** (card, weekly recap, link preview): same Obsidian palette, drawn on a canvas; Discord-friendly sizes (card 520 × 760, recap 1080 wide, preview 1200 × 630).
- **Records:** boards are plain cards with an ordered list; medals are 1.5 rem circles (gold `#e2b552`, silver `#c3c9d0`, bronze `#c4834f`, dark number text) and places 4+ use a sunken circle, so the place is always readable as a number. Your row gets a 12% accent wash; last place sits under a small tertiary "··· Wooden spoon" divider instead of a tag, so rows stay one line. Main boards are a 2 × 2 grid (one column under 760px) showing the top 3 with a ghost See all button. Professions are one table card (grid rows, Profession / 1st / 2nd / 3rd / Last, 1px separators); under 760px each row stacks its podium vertically with a "Wooden spoon" label on the last line. The profession name is the expand button; the rest of the row also opens it on click. Rank lines on character pages are 13 px secondary text with a small medal for the top 3.
- **Dungeon list:** one card, grid rows (name + levels | in range | been, numbers right-aligned in tabular figures, zeros in tertiary), 1px separators, a chevron that turns when open, and the open dungeon's detail on a faint sunken wash under its row. Under 600px the counts drop to a second line ("4 in range · 8 been").
- **Who Has What:** 3 / 2 / 1 column grid at 960 / 600px; each card has an uppercase 11 px tertiary kicker (Gathering or Crafting), rows of name + skill with the bar below, top 5 then a ghost "N more" button.
- **This Week:** a card at the top of Records; each line starts with a fixed 3 rem badge (gold medal for a new number one, green "▲N" for a climb, a grey "+N" pill for a gain) then one sentence with names in bold.
- **Titles:** gold pill tags (12% gold wash, 35% gold border, a small crown cut with clip-path), three max then "+N more"; they link to Records.
- **Rival:** a card with the score as a centred pill ("You lead 4–2", green when you lead, red when behind), the two names left and right, then rows of value · label · value with the winner in bold primary ink.
- **Sync status:** one wrapping row of small tertiary text separated by "·" (stacked on phones), plus the sync chip, armory link and Sync now button.
- **Tabard colours (Nov 2026):** matched to the final in-game tabard and logo. Crimson `#a50d2c` (light `#9a0a26`) for filled buttons and the current menu item; gingerbread `#e0a862` (light `#7a4a1c`) for links, the site title and other accent text; bright green trim `#2f9a46` (light `#23803a`) as a 3px line under the header and on the recap picture. Neutrals lean red-brown (`#0f0a09` to `#4a3a39` dark; a cream `#fbf7f2` base in light). Always-dark panels use the same red-brown greys. The icon is traced from the in-game guild logo (outline smoothed and made symmetric, face redrawn as clean lines): a chunky, frowning gingerbread man (`#d69d56`, crimson face, bow tie and three buttons) on a crimson disc with a bronze rim. The round logo (`public/logo.svg`, no square behind it) sits left of the site title in the header (40px; 36px on phones, 30px under 360px). Both are drawn by `tools/icon/make_icon.py`; angry eyes are crimson half-moons cut at a slant under thick slanted brows.
- **Raid Readiness:** a summary strip (four numbers), an "Almost there" chip row, then one sunken tile per raid with a status tag (green "N groups ready", else "Need …") and three role bars that turn trim-green when full.
- **Open dungeon:** names are plain inline links (class dot, name, 12px level), never boxed chips; two columns (In Range 3fr, Who's Been 2fr) that stack under 760px.
- **Winter Veil strip:** crimson gradient with a dashed gingerbread bottom edge, centred text, 14 small CSS snowflakes (hidden under reduced motion), a 44px × button.
- **Card of the Week:** card left, info right (kicker, name, why, title tags, a four-number strip between hairlines, profession bars in two columns); stacks under 760px. Title ribbon on cards: uppercase gingerbread text on a crimson gradient with a gingerbread border.
- **App icon:** a red blood drop on near-black (`public/icon.svg`, plus 192 and 512 px PNGs for phones).
<!-- /od:keep -->

## Do's and Don'ts

**These rules keep screens clear and easy to read.** The engine checks the ones it can.
Designers: guardrails and design linting · Code: `engine.py validate, engine.py review`

<details><summary>More</summary>

**Enforced by construction.** The generator cannot break these:
- text contrast 4.5:1, and 3:1 for edges, in every mode
- text on colored fills picked automatically
- tap areas pointer 24px, touch 44px
- a 2px focus ring with a 2px offset
- a reduced-motion mode
- inner spacing smaller than outer spacing, three text colors, and nested radii

**Do**
- Use semantic tokens; never raw hex, px or ms values in components.
- Keep one primary action per view and at most three type sizes per view.
- Pair every status color with an icon or label; underline links in running text.

**Don't**
- Don't shrink hit areas in dense layouts; shrink visuals and extend the hit area.
- Don't use motion as the only signal, or flash more than three times a second.
- Don't copy another brand's identity from a reference (colors, typeface, logo, imagery, copy).

**Current validation findings:** none (errors 0, warnings 0).

**Waivers:** none.

</details>

## Standards

**Follow these rules when you build.** They come from sources marked non-negotiable, their values are locked, and `engine.py review` checks the ones it can.

House standards v3: 289 rules followed in this project, plus 8 of your own.

**Don't break these:**
- No motion on 100+ times-a-day actions (STD-when-to-animate-05).
- Never use ease-in on UI (STD-easing-duration-03).
- Never enter from scale(0) (STD-enter-exit-origin-01).
- Never use transition: all (STD-performance-properties-06).
- Never disable pinch zoom (STD-accessibility-motion-27).

**Project standards** (from sources the owner chose)
- Show a character's level as a plain number beside the role (e.g. 'Tank · 60'). No progress bars or countdowns toward level 60 (PRJ-02)
- WoW Forever characters have a first and a last name (e.g. 'Clark Clark'). Show the full name everywhere; forms ask for first name and last name; name fields fit two names without cutting off (PRJ-04)
- Profession skill shows a progress bar to 300, with marks where each rank ends (75, 150, 225) and gold when maxed. This is the only progress bar; character level stays a plain number (PRJ-05)
- Privacy: show character names only, never real names. Don't display the Google account name or email anywhere, and don't store real names on character records. Alts read 'Alt of <character name>' (PRJ-17)
- Journey wording: 'Joined Blood and Tears' (date the player enters, optional) and 'Added to the roster' (recorded when a character is created on the site) (PRJ-20)
- Labels, buttons and messages are bare and functional: no exclamation marks; no 'Awesome', 'Oops', 'Let's'; no hype words; no emoji; no over-explaining. Game flavour is the exception and lives in content only: Guild Feed slang ('dinged 24', 'looted', 'is LFG for'), the level-up 'Ding!' moment, card flavour text, the Hall of Firsts and Duels. Game terms like Epic are item names, not hype (PRJ-23)
- The site is hands-off: everything fills itself from the armory or is optional fun. Nothing asks people to sign up, post or keep something up to date (trade orders, availability, events and group posts were cut for this reason; groups are sorted in game and on Discord). The Dungeons page only shows who's the right level for each dungeon and when raids open (PRJ-24)
- Dungeon Passport: owners tap a dungeon on their character page to stamp it (tap again to remove). Optional and just for fun; the card back has Stats and Passport tabs (PRJ-25)

<details><summary>Every theme (225 rules)</summary>

- **When to animate** (14 rules, 12 must): Decide whether to animate first; Name a valid purpose for every animation; Scale motion down as frequency rises; No motion on 100+ times-a-day actions; Never animate keyboard-initiated actions; Remove or shrink motion seen tens-of-times daily; Spend delight only on rare moments; Explanatory motion only in marketing, onboarding; and 4 more must rules. Locks `motion.duration.instant` 0ms.
- **Easing and duration** (12 rules, 10 must): Pick easing by the motion's job; Strong custom curves, not built-in keywords; Never use ease-in on UI; UI motion under 300ms unless justified; Duration budget for each element; Nothing over 1s unless illustrative; Duration grows with size and distance; Slow deliberate phase, snappy response; and 2 more must rules. Locks `motion.easing.linear` [0, 0, 1, 1], `motion.easing.hover` [0.25, 0.1, 0.25, 1], `motion.easing.enter` [0.23, 1, 0.32, 1], `motion.easing.exit` [0.23, 1, 0.32, 1], `motion.easing.standard` [0.77, 0, 0.175, 1], `motion.duration.micro` 100ms, `motion.duration.short` 150ms, `motion.duration.medium` 200ms, `motion.duration.long` 250ms.
- **Enter, exit and origin** (29 rules, 16 must): Never enter from scale(0); No opacity-only fade entrances; Scale popovers from their trigger; Keep modals scaling from center; Exit the way it entered; Dropdowns and popovers: scale 0.95, 200ms; Tooltips: scale 0.97, 125ms; Delay only the first tooltip; and 8 more must rules. Locks `motion.scale.enter` 0.95, `motion.duration.medium` 200ms (STD-easing-duration-07 wins), `motion.duration.tooltip` 125ms, `motion.scale.enter-tooltip` 0.97, `motion.duration.instant` 0ms (STD-when-to-animate-05 wins), `motion.duration.modal` 250ms, `motion.scale.enter-modal` 0.96, `motion.duration.stagger` 50ms, `motion.duration.reveal` 600ms, `motion.blur.crossfade` 2px, `motion.easing.drawer` [0.32, 0.72, 0, 1], `motion.duration.drawer` 500ms.
- **Springs and gestures** (32 rules, 21 must): Springs for anything a finger drives; Default springs are critically damped; Bounce only after a momentum gesture; Keep bounce subtle, 0.1 to 0.3; Sheet and drawer spring values; Every animation can be grabbed mid-flight; Never block input during transitions; Start from the on-screen value; and 13 more must rules. Locks `motion.spring.spatial.dampingRatio` 1.0, `motion.spring.spatial.stiffness` 246.7, `motion.spring.momentum` a composite value (see standards.md), `motion.spring.sheet` a composite value (see standards.md), `motion.spring.rotation` a composite value (see standards.md), `motion.gesture.deceleration-rate` 0.998, `motion.gesture.dismiss-velocity` 0.11, `motion.gesture.rubberband-constant` 0.55, `motion.gesture.direction-threshold` 10px.
- **Performance and properties** (14 rules, 9 must): Animate only transform and opacity; Only clip-path, accordion height, childless width; Never use transition: all; Motion: animate the full transform string; Keep per-frame values out of React state; Set drag transforms on the moving element; Pick the cheapest animation tool; Treat dropped frames as a regression; and 1 more must rule.
- **Accessibility in motion** (18 rules, 11 must): Ship reduced motion with the animation; Reduced motion is gentler, never zero; Check reduced motion by toggling it; Reduced transparency makes surfaces solid; Increased contrast gets solid, bordered surfaces; Scale layout with the user's text size; Gate hover motion to fine pointers; Build overlays on accessible primitives; and 3 more must rules. Locks `raw.reducedMotion` "replace", `motion.duration.reduced-fade` 200ms, `reduced:motion.transition.enter` a composite value (see standards.md), `reduced:motion.transition.exit` a composite value (see standards.md), `reduced:motion.transition.expand` a composite value (see standards.md).
- **Toasts, drawers and overlays** (23 rules, 7 must): Fill gaps between toasts for hover; Pause toast timers in a hidden tab; Toast classNames need !important; Copy Sonner styles into shadow DOM; Drawer curve: cubic-bezier(0.32, 0.72, 0, 1); Feedback on press, commit on release; Hold to confirm: slow press, fast release. Locks `motion.duration.toast` 400ms, `motion.easing.toast` [0.25, 0.1, 0.25, 1], `component.toast.gap` 14px, `component.toast.visible` 3, `component.toast.duration` 4000ms, `component.toast.offset.desktop` 32px, `component.toast.offset.mobile` 16px, `motion.easing.drawer` [0.32, 0.72, 0, 1] (STD-enter-exit-origin-41 wins), `motion.gesture.drag-lock-after-scroll` 100ms.
- **Mobile and touch** (20 rules, 16 must): Detect touch by capability, never by device; Remove the tap highlight flash globally; Press feedback scales to 0.97, briefly; Remove the tap delay on tappables; Touch targets 44pt on iOS, 48dp on Android; Size full-height layouts with dvh and svh; Form inputs at 16px or larger; Contain overscroll in app layouts; and 8 more must rules. Locks `motion.scale.press` 0.97, `motion.duration.micro` 100ms (STD-easing-duration-07 wins), `size.target.touch` 44px, `size.target.min` 44px, `font.size.input` 16px.
- **Visual details** (49 rules, 19 must): Cap body text near 65ch; Tabular digits for changing numbers; Use the ellipsis character; Loosen tracking on uppercase labels; Make letter-spacing specific to size; Reserve underlines for links; Metric-matched fallback font stack; Never stack light translucent surfaces; and 11 more must rules.
- **Process, review and taste** (14 rules, 8 must): Motion that merely runs is not done; Self-check motion before finishing; Report review findings as one table; Close every motion review with Block or Approve; Make the motion call yourself; Keep the motion note to a few lines; Say when feel can't be judged from code; Judge feel on real hardware.

</details>

Every rule, with its values, reasons and sources: `opendesigner/standards.md` (it also has the 64 rules this file leaves out). Read the themes you touch before you build.

## Motion

> Zoom: sketch (0 of 3), 0 decisions in this area. To zoom in, answer Q-motion-01.
<!-- od:zoom area=motion level=0 -->

**Most movements take 200ms.** They turn into fades when a person asks for less motion.
Designers: motion system: duration, easing, springs · Code: `motion.duration.*, motion.easing.*`

<details><summary>More</summary>

**Intent.** Energy 35/100: the duration multiplier x0.94 scales the extra step (standards fix medium, long). Standard easing `cubic-bezier(0.77, 0, 0.175, 1)`, enter `cubic-bezier(0.23, 1, 0.32, 1)`, exit `cubic-bezier(0.23, 1, 0.32, 1)`. Spatial spring: damping 1.0, stiffness 246.7 (Apple duration 0.4s, bounce 0.0; web `linear()` sample over 590ms).

| Token | Value | Note |
|---|---|---|
| `motion.duration.instant` | 0ms | set by house standard STD-when-to-animate-05 |
| `motion.duration.micro` | 100ms | set by house standard STD-easing-duration-07 |
| `motion.duration.short` | 150ms | set by house standard STD-easing-duration-07 |
| `motion.duration.medium` | 200ms | set by house standard STD-easing-duration-07 |
| `motion.duration.long` | 250ms | set by house standard STD-easing-duration-07 |
| `motion.duration.extra` | 660ms | illustrative and marketing motion only, never UI (STD-easing-duration-06) |
| `motion.duration.medium-exit` | 160ms | derived: about 0.8 x medium |
| `motion.duration.long-exit` | 200ms | derived: about 0.8 x long |
| `motion.duration.drawer` | 500ms | set by house standard STD-enter-exit-origin-41 |
| `motion.duration.modal` | 250ms | set by house standard STD-enter-exit-origin-11 |
| `motion.duration.reduced-fade` | 200ms | set by house standard STD-accessibility-motion-02 |
| `motion.duration.reveal` | 600ms | set by house standard STD-enter-exit-origin-26 |
| `motion.duration.stagger` | 50ms | set by house standard STD-enter-exit-origin-13 |
| `motion.duration.toast` | 400ms | set by house standard STD-components-toasts-drawers-07 |
| `motion.duration.tooltip` | 125ms | set by house standard STD-enter-exit-origin-09 |

- Exits are derived, not set on their own: each is about 20% shorter than the entrance in force (medium-exit 160ms from medium 200ms, long-exit 200ms from long 250ms; STD-easing-duration-11). Change an entrance and its exit follows. Linear easing only for spinners and progress.
- Reduced motion (`prefers-reduced-motion` or `data-motion="reduced"`): travel becomes opacity, feedback stays, `motion.transition.move` is 0ms.
- Springs are stored as damping and stiffness in `$extensions.opendesigner.spring` because DTCG 2025.10 has no spring type.
- Haptics: medium intensity where the platform has them; sound: hook H-sound is pending.

Decisions: D-0007 (34 values, standards).

</details>

## Modes and Themes

> Zoom: defined (2 of 3), 2 decisions in this area. To zoom in, answer Q-theme-02, Q-theme-04.
<!-- od:zoom area=modes level=2 -->

**The system has light and dark color modes, three spacing densities and a reduced-motion mode.**
Designers: modes: light, dark, density, motion · Code: `resolver modifiers, Figma collection modes`

<details><summary>More</summary>

**Your answers here** (each one either sets tokens or is a rule for this section):
- Should the app have light and dark modes that follow the device, or just one mode? **Light and dark, plus a switch in the app** (chosen; tokens; Q-theme-01)

**Intent.** Modes live in the DTCG resolver (`opendesigner/tokens/opendesigner.resolver.json`); modifiers are orthogonal, so no two set the same token.

| Modifier | Contexts | Default |
|---|---|---|
| theme | light, dark | dark |
| density | spacious, comfortable, compact | comfortable |
| motion | standard, reduced | standard |

- Web: `prefers-color-scheme` with a `[data-theme]` override; `[data-density]`; `prefers-reduced-motion` with `[data-motion]` (see `opendesigner/build/css/tokens.css`).
- High-contrast themes are not generated; set `raw.contrastTarget` to AAA for 7:1 text everywhere.
- A second brand or a client re-skin may override the color primitives and `color.bg.brand`; semantic names never change.

Decisions: D-0016 (answers.Q-theme-01), D-0017 (raw.defaultTheme).

</details>

## Iconography and Imagery

> Zoom: sketch (0 of 3), 0 decisions in this area. To zoom in, answer Q-icon-01, Q-icon-02, Q-icon-06.
<!-- od:zoom area=iconography level=0 -->

**Icons are 20px by default.** The logo, photos and custom icons come from a person, not from the engine.
Designers: icon system: style, sizes, color · Code: `size.icon.*, icon.stroke.*, color.icon.*`

<details><summary>More</summary>

**Intent.** Default icon size 20px; sizes 16/20/24 pair with 14/16/20px text. Stroke follows the label weight: 1.5px at 16, 1.5px at 20, 2.0px at 24. Rest style: outline.

| Asset | Hook | Status |
|---|---|---|
| Logo and marks | H-logo | pending |
| Favicon set | H-favicon | pending |
| App icon | H-appicon | pending |
| Custom icons | H-icons | pending |
| Illustration | H-illus | pending |
| Photography | H-photo | pending |
| Motifs and brand shapes | H-motif | pending |

- Placeholders are labelled as placeholders. A generated stand-in is never shown as a finished brand asset.
- Icon-only buttons need an accessible name and a hit area of `size.target.min`.

Decisions: none recorded yet; values are defaults from references/levers.json.

</details>

## Content and Voice

> Zoom: defined (2 of 3), 3 decisions in this area. To zoom in, answer Q-voice-05, Q-voice-06.
<!-- od:zoom area=content level=2 -->

**Words stay plain and short, and every button says what it does.**
Designers: content: voice, tone, microcopy · Code: `DESIGN.md Content and Voice section`

<details><summary>More</summary>

**Your answers here** (each one either sets tokens or is a rule for this section):
- Do you have a voice guide? **Your own traits, set on NN/g's four tone scales, with words to avoid** (chosen; asset status; Q-voice-01)
- Capital letter only on the first word (sentence case), or on most words (title case)? **Title case for headings and main menus, sentence case for buttons (Mailchimp)** (chosen; a rule here; Q-voice-03)
- What school grade should the words suit: 6th-8th for everyone, or 10th-12th for experts? **Button and menu labels of 2-4 words, verb first, naming the result** (chosen; a rule here; Q-voice-04)

**Intent.** Draft: voice guidance level **none** (Brand presence 20); **title-case**; contractions **allowed** (Warmth 50). Voice guide hook H-voice: placeholder.

- Buttons say what they do in two to four words; errors say what happened and how to fix it.
- Reading level: plain language; avoid jargon in UI copy.
- Word list: not recorded yet (Q-voice-03).

Decisions: D-0027 (answers.Q-voice-01), D-0032 (answers.Q-voice-03), D-0033 (answers.Q-voice-04).

</details>

## Accessibility

> Zoom: sketch (0 of 3), 0 decisions in this area. To zoom in, answer Q-aud-02, Q-aud-03, Q-aud-04.
<!-- od:zoom area=accessibility level=0 -->

**Text passes WCAG 2.2 AA contrast in every mode, and focus is always visible.**
Designers: WCAG 2.2 AA target · Code: `raw.contrastTarget`

<details><summary>More</summary>

**Your answers here** (each one either sets tokens or is a rule for this section):
- Who uses it, and how often: all day for work, often, or now and then on the go? **Often, in an everyday app** (chosen; tokens; Q-aud-01)

**Intent.** Standard: WCAG 2.2 AA. APCA is reported as advice only.

**The system guarantees:**
- text and edge contrast in every mode
- visible focus (2px ring, 2px offset, 3:1)
- minimum target sizes for each kind of input
- a reduced-motion mode
- rem-based type, so text scales to 200%
- text on colored fills chosen automatically

**Product teams own:** accessible names and labels, alt text, reading and focus order, and never using color alone. Also: clear error messages, dialogs that can be closed, no pre-checked consent boxes, and captions for media.

**Test on each platform:**
- keyboard only
- a screen reader (VoiceOver, NVDA or TalkBack)
- 200% zoom
- forced colors (Windows High Contrast)
- reduced motion
- touch on a phone, for every surface that allows touch

Decisions: none recorded yet; values are defaults from references/levers.json.

</details>

## Platforms and Devices

> Zoom: sketch (0 of 3), 1 decision in this area. To zoom in, answer Q-plat-05, Q-plat-10, Q-plat-08.
<!-- od:zoom area=platforms level=0 -->

**It runs on web, and each platform keeps its own navigation.**
Designers: target platforms · Code: `raw.platforms; size.target.min`

<details><summary>More</summary>

**Your answers here** (each one either sets tokens or is a rule for this section):
- Where will it run first: web, iOS, Android or desktop? **Web** (assumed; tokens; Q-plat-01)

**Intent.** Platforms: web. Inputs: pointer, touch. Brand presence 20: each platform keeps its own shapes and materials: yes; each platform keeps its own body text size: yes.

- Navigation, back, sheets and pickers stay native on every platform (DC-L10-02).
- Swift and Compose files in `opendesigner/build/` use the same names as the CSS variables (Figma code syntax matches them).
- Fonts by platform: text: Figtree (open licence or system font: web, apps and self-hosting); display: Alegreya Sans SC: licensed for nothing recorded; not recorded for web, apps, self-hosting.

Decisions: D-0003 (answers.Q-plat-01).

</details>

## Decisions

**93 decisions so far.** Each one says who set it and why.
Designers: decision history with reasons · Code: `opendesigner/decisions.md`

<details><summary>More</summary>

Your own decisions first (the newest value per path), then your changes to standards, then one row per standards batch. Full log: [opendesigner/decisions.md](opendesigner/decisions.md).

| Id | Path | Value | Set by | Reason |
|---|---|---|---|---|
| D-0003 | `answers.Q-plat-01` | ["web"] | assumed | read from the files (HTML pages); say if that's wrong |
| D-0006 | `answers.Q-scope-07` | "near-launch" | assumed | read from the repo: code and deploy settings (firebase.json), but no released version yet; say if that's wrong |
| D-0014 | `context.market.competitors` | ["WowAudit", "Raid-Helper", "Warcraft Logs"] | delegated | the WoW tools to beat |
| D-0016 | `answers.Q-theme-01` | "light-dark-toggle" | chosen | they want it dark themed like night mode, and asked earlier for a switch; dark is what it opens in |
| D-0017 | `raw.defaultTheme` | "dark" | chosen | they want it dark themed, like night mode |
| D-0019 | `context.purpose` | "help a mixed guild of new and experienced players see who is ready for raids and who can craft what" | assumed | from their words |
| D-0022 | `macros` | ["deferential", "minimal"] | chosen | sketch: Level 0 answer (their words: calm, minimal) |
| D-0023 | `taste.feelWords` | ["calm", "minimal"] | chosen | sketch: the person's own feel words |
| D-0024 | `taste.brief` | "dark, like night mode, with a touch of Horde; we are Loot Goblins after all" | chosen | sketch: the person's picture of the look |
| D-0025 | `answers.Q-scope-06` | ["guild app:operate"] | chosen | sketch: Level 0 answer |
| D-0027 | `answers.Q-voice-01` | "custom" | chosen | bare and functional: just labels, no personality; basic is good. Traits: plain, short, functional; no jokes, no hype |
| D-0028 | `answers.Q-aud-01` | "regular" | chosen | they'll update their character every few days when they make progress |
| D-0029 | `context.goals` | ["every member keeps their own character up to date", "new players understand it at a glance", "see each other's goals so people can group up and do things together", "later: be raid-ready when raids open (kept low-key for now)"] | chosen | they want to see people's goals to find others to group up with |
| D-0031 | `taste.dislikes` | ["AI-generated tone: exclamation marks, Oops/Awesome, hype words, emoji in labels, over-explaining", "heavy full-on spreadsheet look"] | chosen | their words |
| D-0032 | `answers.Q-voice-03` | "title-headings" | chosen | title case for headings and menus, sentence case for buttons |
| D-0033 | `answers.Q-voice-04` | "labels-2-4" | chosen | everyday words, buttons of 2-4 words starting with a verb; no explanatory notes everywhere |
| D-0034 | `answers.Q-dir-01` | "flat2" | chosen | Quiet flat: the clean look they liked, in the dark |
| D-0036 | `answers.Q-color-09` | "hue-matched" | chosen | they like the warm gold-tinted surfaces of 'Warm tonal' with the layout of 'Quiet flat' |
| D-0037 | `answers.Q-color-03` | "tonal" | chosen | the coloured look of Warm tonal |
| D-0039 | `answers.Q-type-01` | "open-custom" | chosen | Figtree for everything, plus Alegreya Sans SC for page titles only |
| D-0040 | `raw.textFace` | "Figtree" | chosen | calm, readable, numbers line up |
| D-0041 | `raw.displayFace` | "Alegreya Sans SC" | chosen | one small WoW touch on page titles, the font they installed |
| D-0065 | `name` | "Blood and Tears" | chosen | guild renamed from Loot Goblins |
| D-0078 | `context.later` | ["Raid sign-ups and calendar, once people near 60 (raids open 9 December)", "Discord posts and slash commands (built, switched off until there are permissions)", "Glow-up pictures of a character at each 10 levels (needs saved armory pictures)", "Winter Veil look in December", "Feed reactions (maybe)", "Dungeon passport (being mocked up)"] | chosen | updated with the person, 7 Nov |
| D-0079 | `context.market.analogous` | "Strava clubs and Raider.IO guild pages (a group of members, a weekly leaderboard and an activity feed), plus trading-card games for the cards" | chosen | references used in the second design pass |
| D-0089 | `context.product` | "a roster, dungeons, professions and trading-card site for Blood and Tears, a Horde guild on WoW Forever" | chosen | group posting was cut; the menu is Roster, Dungeons, Cards and Professions |
| D-0092 | `raw.brandColor` | "#a50d2c" | chosen | Final tabard and in-game logo (owner's screenshots, 12 Nov): crimson field, gingerbread man, bright green trim, bronze rim. |
| D-0093 | `raw.neutralBase` | "#161010" | chosen | Neutrals lean red-brown to sit with the crimson tabard. |
| D-0054 | standards | remove PRJ-03 (project standard) | chosen | replaced: Looking for Group now has a site-level Join (notice board), the person's choice |
| D-0055 | standards | remove PRJ-07 (project standard) | chosen | superseded by PRJ-09 (wording without 'in game') |
| D-0056 | standards | remove PRJ-12 (project standard) | chosen | superseded by PRJ-13 (viewer's own time, no switch) |
| D-0061 | standards | remove PRJ-13 (project standard) | chosen | replaced by the time zone picker rule |
| D-0063 | standards | remove PRJ-18 (project standard) | chosen | replaced: abbreviation picker with a daylight saving tick box |
| D-0068 | standards | remove PRJ-10 (project standard) | chosen | Availability was cut from the site |
| D-0069 | standards | remove PRJ-09 (project standard) | chosen | Guild renamed to Blood and Tears |
| D-0071 | standards | remove PRJ-15 (project standard) | chosen | Availability and Discord posting are gone from Looking for Group |
| D-0073 | standards | remove PRJ-19 (project standard) | chosen | Availability rows are gone; time zones now only affect group times |
| D-0075 | standards | remove PRJ-01 (project standard) | chosen | the person asked for more fun and flavour (game slang, Ding, card flavour text) |
| D-0080 | standards | remove PRJ-21 (project standard) | chosen | group posting was cut: groups happen in game and on Discord |
| D-0083 | standards | remove PRJ-06 (project standard) | chosen | Remove all the useless stuff then please (the goals card was cut earlier) |

31 more in the full log.

</details>

## Open Items

**These parts are still defaults, guesses, or waiting for a person.**

- Still defaults (zoom 0, sketch): Colors, Layout, Elevation & Depth, Shapes, Components, Motion, Iconography and Imagery, Accessibility, Platforms and Devices
- Assets not final: Logo, wordmark, symbol, lockups (H-logo): pending; App icon (H-appicon): pending; Favicon set (H-favicon): pending; Custom icons, pictograms, spot icons (H-icons): pending; Illustration, characters, empty-state art (H-illus): pending; Photography and art direction (H-photo): pending; Brand typeface files (H-type): pending; Fixed brand colors (H-color): pending; Motion signature and rich media (H-motion): pending; Graphic devices, patterns, textures, brand gradients, signature shape (H-motif): pending; UI sounds and sonic logo (H-sound): pending; Custom haptic patterns (H-haptic): pending; Voice and tone guide (H-voice): placeholder; Brand guidelines PDF (H-brandbook): pending
- Answers taken on assumption or delegated: answers.Q-plat-01 (assumed), answers.Q-scope-07 (assumed), context.market.competitors (delegated), context.purpose (assumed)
- Waivers: none.
- Licence risks: Alegreya Sans SC: confirm the web licence (record it with engine.py set raw.fontLicence).
- Validation: 0 errors, 0 warnings.

## For Agents

**AI agents: read this file and the tokens before you change any screen.**

1. Before any visual work, read this file, PRODUCT.md and `opendesigner/tokens/` (start at `opendesigner/tokens/opendesigner.resolver.json`).
2. Use tokens, never raw values: CSS `var(--ds-...)`, Tailwind classes from `opendesigner/build/tailwind/theme.css`, `DS.*` in Swift. In Compose: colors from `LocalDsColors.current` (provide `DsLightColors` or `DsDarkColors`), then `DsSpace`, `DsType` and `DsMotion`.
3. Do not change a locked decision without asking the owner. Keep new screens inside the taste card at the top of the Overview, and never add anything on its Never list without asking.
4. To change the system: `engine.py set <path> <value> --why "..."`, then `engine.py generate`, `engine.py validate`, `engine.py design-md`.
5. To extend: add a decision (never hand-edit tokens or this file). Keep semantic names the same across modes. Deprecate instead of deleting.
6. After any implementation, run `engine.py review` and re-read this file.
7. Follow the Standards section. Change a standard only when the person explicitly asks: `engine.py standard override <id> --why "<their words>"`.

**Tailwind v4 classes** (one import: `@import "tailwindcss"; @import "<path>/opendesigner/build/tailwind/theme.css";`; Tailwind's default colors, text sizes, radii and shadows are switched off, so only these exist):

| Area | Classes |
|---|---|
| Color | `bg-action-primary`, `hover:bg-action-primary-hover`, `active:bg-action-primary-pressed`, `text-on-action`, `bg-surface-base`, `bg-surface-raised`, `text-fg-primary`, `text-fg-secondary`, `text-fg-link`, `border-line-subtle`, `border-line-input`, `outline-line-focus`, `bg-danger-bold` |
| Layout | `p-inset-md`, `gap-stack-md`, `gap-inline-sm`, `h-control-md`, `size-icon-md`, `min-h-target-min` |
| Shape | `rounded-control`, `rounded-container`, `rounded-overlay`, `rounded-full` |
| Elevation | `shadow-raised`, `shadow-floating`, `shadow-overlay` |
| Type | `text-body-md`, `text-label-lg`, `text-title-md`, `text-headline-md` |
| Motion | `transition-feedback`, `ease-enter`, `ease-exit`, `ease-hover` |
