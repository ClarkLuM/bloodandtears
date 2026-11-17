# Audit: the Scribe addon's window (17 Nov, addon 0.14.1)

Read from `addon/BloodAndTearsScribe/BloodAndTearsScribe.lua`. Not measured in the game: the before/after sheet is drawn from the code's numbers. Nothing is changed until Clark says yes. Kept as they are, by his earlier choices: the game's own red buttons, no all caps, the see-through panel.

| # | Where | Before: what is wrong | After: the fix | Why (source) |
|---|---|---|---|---|
| 1 | Top of each tab: Today sort at y -2, Dungeons drop-downs at -8, Loot search and filter at -24 under a title at -6, Recipes search at -6 with Back at -34 | The controls sit at a different height on every tab, so they jump as you switch tabs, and Loot spends two lines before the list starts | One control line on every tab at y -6; lists start at -36. Loot's count moves to the foot | The same thing in the same place (STD-visual-details-36: things that look the same behave the same) |
| 2 | Buttons: Today sort 96x18, Back 60x18, drop-downs 20 high (136, 150, 190 wide), Missing and Read 22, tabs 24 | Four button heights and four drop-down widths in one small window | Controls 22 high; drop-downs 150 wide; tabs stay 24 | Controls share one height scale, with no mixed sizes in a group (DC-L08-07) |
| 3 | "Pick one" controls: Today's Sort is a button that cycles on click; Week and Dungeons use the shared drop-down; Loot has its own hand-built copy | Three behaviours for the same job. "Sort: zone" is lower case while the others read "Sort: Most time" | Every one uses the shared drop-down, with labels in the same case | STD-visual-details-36 |
| 4 | Two-line rows: Recipes 38 apart, Alts 37, Dungeons 34 | Three spacings for the same kind of row | 36 everywhere | About eight sizes from one scale, none within 10% of another (preflight 7, written for text sizes; applied here to row heights, my own extension) |
| 5 | Recipes foot: a 92 px, six-line "How recipes get to the site" block, always shown | A quarter of the tab is instructions you need once | One line, with the three steps on hover. Search results and Missing grow from 6 rows to 8 | The most important thing is the most obvious (STD-visual-details-29) |
| 6 | Foot lines: heights 28, 30, 32, 44 and 92; bottom offsets 10 and 12 | Each tab's foot note sits and wraps differently | One line, 10 from the bottom, on every tab | My own idea |

Not changed: colours, fonts, the header, the tab row, the minimap button, the session summary.

## Status (17 Nov)

All six rows applied in addon 0.15.0 after a yes on the drawn sheet, plus class icons (Online list, Alts) and profession icons (Recipes, crafters in the search, Alts) at Clark's request. Run in the Lua test harness only; not yet seen in the game.
