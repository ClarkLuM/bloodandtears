# Design audit: Blood and Tears site (6 Nov 2026)

Measured on the test copy of the site (same code as live, with sample guild data) at 390 px and 1280 px wide, in dark and light, on Roster, a character page, Groups and Professions. Fonts from Google were blocked in the test, so headings show in Figtree instead of Alegreya Sans SC; nothing below depends on that.

**Verdict:** the site is tidy and readable, and it has no overflow, no tiny buttons and no contrast problems in its main text. But it still wears the old Loot Goblins colours underneath the new red. A few buttons compete for attention, and the character page leaves a big empty hole. Fixing the colour base changes the most.

| # | Where | Before: what is wrong | After: the fix | Why: what practice says (source) |
|---|---|---|---|---|
| 1 | `public/index.html:22-36`, the warm neutrals (`--base #201c17`, `--raised #2a241c`, light `--base #fffcf9`); `opendesigner/state.json` still has `brandColor #d4a24c` and `neutralBase #4a3b25` (read in the code) | Every background, border and grey is a gold-brown left over from Loot Goblins. The new red sits on leather-brown, so the site reads "tavern" more than "blood", and the red looks muddier than it is | Rebuild the greys from the red: near-black with a faint red or cool tint in dark mode, and off-white in light mode. Set the system's brand to `#b8282a` and regenerate the tokens. Three directions to compare before choosing | Greys are tinted toward the brand colour (`raw.neutralTint = "brand"`, D-0038), and the brand changed without the system being rebuilt. One value per colour from one system (STD-visual-details-26) |
| 2 | `index.html:652`, `AC.lvl:"#e6bc77"` in the achievement badges; light mode: #e6bc77 on #f9f3eb, **1.61:1** (measured) | In light mode the level numbers on achievement badges ("20", "10") are almost invisible | Use a gold token with a light and a dark value: #7a5f17 in light (5.06:1 on the pink badge), today's #e6bc77 in dark | Text needs 4.5:1 (WCAG 2.2 SC 1.4.3, a floor). Each colour has a light and a dark value (STD-visual-details-24) |
| 3 | `index.html:1152` "This is me" + `:1326` "⟳ Sync from armory", both `btn primary`; `:1052` "Plan an event" + "Post a group" on Groups (measured: 2 filled buttons in the first screen) | On a character page two red buttons ask for the first click. Groups has two as well | "This is me" keeps the red fill (it's the action the page exists for when unclaimed); Sync becomes an outline button. On Groups, "Post a group" keeps the fill and "Plan an event" becomes an outline | One primary button per view (preflight 36; DC-L08-05) |
| 4 | Character page at 1280 px: left column ends at about y=1090, right column at y=1940 (measured) | Below Talents there's an empty hole about 850 px tall, while Gear and Professions are stacked on the right | Move Professions to the left column under Talents, so both columns end close together | Sibling columns share a top edge and roughly a height (preflight 35). The exact split is my own call |
| 5 | Roster table at 1280 px: "Healer · 60" breaks after the dot, "Troll Combat Rogue" takes 3 lines, "Last seen" wraps (seen) | The table looks cramped and rows grow uneven | `white-space:nowrap` on Role · Level, and the class shown as "Rogue" with the race and spec underneath in small grey text | Labels never break across lines (preflight 40; review case MS-15) |
| 6 | `index.html:719`, `STAT_META` badges on the card: white on #2e9e3f, **3.45:1**; on #c9842a, **3.08:1** (measured) | The tiny "Ag", "AP" letters on the card's stat badges are hard to read | Darken the badge colours (e.g. #23802f, #9a6418) so white passes 4.5:1 | Text needs 4.5:1 (WCAG 2.2 SC 1.4.3) |
| 7 | Talent rank numbers and the card's mini labels: 8, 9 and 10 px (measured: 18 pieces of text under 12 px on the character page) | Some numbers are too small to read comfortably, especially the talent ranks | 11 px minimum for short labels and numbers, 12 px for anything else | 12 px on a web page, 11 px only for short labels (preflight 9) |
| 8 | Stylesheet declares 17 font sizes (8 to 40 px); 12 in use on the character page (read in the code, measured) | Sizes like 17, 19, 23 and 28 px sit very close to each other, so headings don't step up clearly | One scale: 12, 13, 14, 17, 20, 24, 29, 35 px (the card keeps its own small set) | About 8 sizes at most, from one scale, none within 10% of another (preflight 7) |
| 9 | Corner sizes 2, 4, 6, 8, 9, 10, 11, 12 and 16 px (read in the code) | Similar boxes have slightly different corners | Four steps: 4 (chips, bars), 6 (buttons, inputs), 8 (cards), 12 (dialogs), plus round | A short scale; delete any step no part needs (DC-L04-01) |
| 10 | Weight 800 on the card only (`index.html:191, 201, 208, 209`) | Four weights in use; 700 and 800 are hard to tell apart | Use 700 where 800 is | Three weights at most, clearly apart (DC-L19-24) |

Checks that passed: one interface typeface plus one display face for headings, no horizontal scroll at 390 px, every button at least 24 px, a visible focus ring, tabular numbers, and main text contrast in both themes.

Not checked here: the real character pictures and item icons (blocked in the test), and screen-reader names for every control.

## Status (6 Nov, after the Obsidian update and the fun-and-flavour batch)

- Row 1: done. Picked direction A, Obsidian: near-black greys in dark mode, neutral off-white in light, recorded in the design system (`raw.brandColor #b8282a`, `raw.neutralBase #171515`).
- Rows 2, 3, 4, 6 and 10: done.
- Row 5: done. Role · Level no longer wraps, and the class column shows the class with race and spec underneath.
- Row 7: talent ranks are 11 px now. The card keeps its own small labels on purpose (it's a designed object and exports as a picture).
- Row 8: merged the one near-duplicate outside the card (23 → 24 px). Correction to the row: 12, 13 and 14 px sit within 10% of each other too, but they're body, small and chip text that the whole site uses, so they stay.
- Row 9: the gear and stats boxes now use 8 px corners like the cards. 9, 11 and 16 px are the pill, the card's inner edge and the card itself.
- New, found after the audit: the keyboard focus ring was 2.92:1 against the dark page (WCAG 2.2 SC 1.4.11 needs 3:1). It now uses the lighter red in dark mode (#f07a6e, 6.68:1) and stays #b8282a in light mode (6.02:1).
- Re-measured all four pages at 390 and 1280 px in both themes: no text under its contrast minimum, one filled button per view, nothing under 24 px, no sideways scrolling.
