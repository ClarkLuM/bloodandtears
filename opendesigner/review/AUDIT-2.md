# Design audit 2: structure and navigation (7 Nov 2026)

Measured the test copy at 390 px and 1280 px, dark mode, on Roster, Groups, Professions, a character page, Duels and History. The test data has 5 characters; the real roster has more, so the phone numbers below grow with every member.

**Verdict:** the details hold up. No contrast problems, nothing under 24 px, three weights, no sideways scrolling on any page. The problem is the shape of the site. The roster on a phone is 4.4 screens long with 5 people (each person takes 185 px), and you scroll a full screen before the first name. Groups, the most time-sensitive card, sits at the very bottom. Duels and History can only be found through small links.

Reference products for the same problem (a group's members, a weekly leaderboard and an activity feed): Strava club pages, Raider.IO guild pages, and Discord's member list. All three put the people first, keep each member to one or two lines on a phone, and give their secondary areas their own tab.

| # | Where | Before: what is wrong | After: the fix | Why (source) |
|---|---|---|---|---|
| 1 | Roster table on phones (`@container (max-width:640px)`, `index.html:144`) | Each person is a 5-line label:value card, 185 px tall (measured). 20 guildies would be about 3,700 px of table | Two to three tight lines per person: name and tags with role · level on the right; class, race and spec with last seen; professions and best loot only when there is one. About 80 px each | Lists on phones keep each item scannable in one glance (Strava members list, Discord member list); preflight 35 (one reading line per item) |
| 2 | Roster page order on phones (`index.html:702`) | Totals (250 px) and Character of the Day (294 px) come before the roster: the first name is a screen down. The sidebar stacks last, so Groups lands at about 2,400 px | On phones only: claim banner, totals, filters, roster, then Groups and In Game Today, then Character of the Day, Guild Feed, Leaderboards, About. Desktop stays as it is | Put the thing people came for first, and actionable items before ambient ones (Strava club: members and leaderboard before the feed) |
| 3 | Guild totals on phones | Five tiles in a 2-column grid, 250 px | Three columns with 20 px numbers, about 130 px | Same content, less scroll |
| 4 | Navigation (`PAGES`, `index.html:613`) | Only Roster, Groups and Professions. Duels is a small link among the roster filters, the Cards view is a toggle, and History is a link under the feed | A fourth menu item, **Cards**: everyone's cards (the binder) with Card duels and Random duel at the top. The roster loses its List / Cards toggle and the duels link. History stays under the feed (it's the feed's own page) | Secondary areas get their own tab, not a toggle hidden in filters (Raider.IO guild tabs); four bottom tabs fit a phone comfortably |
| 5 | Header on phones (`header.top`) | "Light mode" and "Discord" wrap onto a second line under the name, about 90 px | The theme button becomes a sun or moon icon (named for screen readers), so the name and both buttons fit on one line | Keep the header to one line on phones (making.md, page chrome) |
| 6 | Roster filters on phones | Three rows: roles, List / Cards plus Card duels, Show alts | One row: roles and Show alts (the rest moves to Cards) | Follows from row 4 |

Checks that passed: contrast in both themes, one filled button per view, three weights, nothing under 24 px, no sideways scrolling, and focus rings.

Not changed: the desktop roster layout, the character page, Groups, Professions, Duels and History beyond the menu.

## Status (7 Nov)

All six rows applied to the site after a yes on the review copy. Phone roster: first name moved from 1,054 px to 503 px down the page; each person about half the height. Desktop roster unchanged apart from the Cards menu item. Re-measured afterwards: no contrast problems, no sideways scrolling, nothing under 24 px.
