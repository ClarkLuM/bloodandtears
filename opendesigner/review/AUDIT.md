# Blood and Tears: design audit, 15 Nov 2026

Measured on the test copy at 1280 px and 390 px, dark and light, on all eight pages (Roster, Dungeons, Raids, Cards, Professions, Records, Guild History, a character page). The accessibility checks (axe) already pass on every page in both themes; these are the things they don't catch.

Verdict: the site is consistent and passes its floors. What's left is a broken menu on phones, menus that make iPhones zoom, and fold arrows that still come in four looks.

| # | Where | Before: what is wrong | After: the fix | Why: what practice says (source) |
|---|---|---|---|---|
| 1 | Guild History, `#hist-kind` inside `.hist-tools`; 22 × 40 px at 390 px (measured) | On a phone the "Show" menu is squeezed to a sliver, so you can't see what it's set to | Put the search on its own line on phones and give the menu room (min-width about 8rem) | Nothing may be cut off at phone width (WCAG 2.2 SC 1.4.10) |
| 2 | `.r-sort select` 14 px (`index.html:692`), plus `#c-sort`, `#p-prof`, `#hist-q`, `#hist-kind` (measured 14 px) | Five menus and search boxes use 14 px text, so iPhones zoom the page in when you tap them | 16 px text in all of them, as the base rule at `index.html:107` already says | Inputs at 16 px or more, or iOS zooms in (STD-mobile-touch-11); your own DESIGN.md rule "Every input and menu: 16px text" |
| 3 | Dungeon rows (`.dg-chev`, `index.html:495`), "By class" and "Alliance-side" (▸ triangle), "What Drops" and History days (⌄ chevron) vs roster and profession rows (`.r-x`/`.cm-tog` bordered button) (seen) | Things that open still use four different arrows, so the site teaches the same action four ways | Rows that open (dungeon rows) get the same 36 px bordered arrow at the end; small in-card folds (By class, What Drops, Alliance-side, History days) share one small chevron that turns | Things that look the same behave the same (STD-visual-details-36); your DESIGN.md rule "Every row that opens has the same arrow button" |
| 4 | Cards page, `button.lg-tab` 69 × 23 px at 390 px (measured); Dungeons, "Other · Alliance-side" summary 22 px tall at 1280 px (measured) | A few tap targets are just under the minimum size | `min-height: 1.75rem` on both | Targets at least 24 × 24 CSS px (WCAG 2.2 SC 2.5.8) |
| 5 | Text sizes: 14 on the character page (8 to 35 px), 12 on the roster; 12, 13, 14 and 15 px all in use; page titles 35 px (measured) | Several sizes sit within a pixel of each other, so the levels blur; page titles are bigger than the 32 px the tidy-up set | Map to one scale: 12 (small), 14 (body), 16 (sub-heading), 20 (section), 32 (page); 13 → 12 or 14, 15 and 17 → 16 | About 8 sizes, none within 10% of another (preflight 7); your DESIGN.md heading scale |

Not findings (checked and fine): one filled button per view ("My character", "This is me"); two typefaces, each with a job (Figtree, Alegreya Sans SC for small headings); three weights (400, 600, 700); smallest text 11 px on short labels only, apart from the trading cards' own stamps, which are scaled like real cards; no tap targets under 24 px elsewhere; focus and contrast pass (axe).


## Status
All five fixed on 15 Nov 2026 (History and Dungeons first, then the rest of the site). Re-measured: no menus or search boxes under 16px, no folds or tabs under 24px tall, the browser's own fold triangles gone, page titles 32px.
