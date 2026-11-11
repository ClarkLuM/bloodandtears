# Blood and Tears guild hub

A small web app for the Blood and Tears WoW Forever guild (formerly Loot Goblins), at https://bloodandtears.web.app: roster, dungeons, professions, trading cards and the Hall of Firsts. Almost everything fills itself in from the WoW Forever armory. Data lives in Firebase (Firestore), updates live for everyone, and keeps working offline.

## What's in here

| File | What it does |
|---|---|
| `public/index.html` | The whole app: layout, styles and code |
| `public/firebase-config.js` | Your Firebase project's config, plus the officer list |
| `public/sw.js` | Service worker that keeps the app available offline |
| `public/manifest.webmanifest`, `icon-*.png`, `icon.svg` | Lets people install it to their phone's home screen |
| `firestore.rules` | Who can read and change what (see below) |
| `firebase.json`, `.firebaserc` | Tells the Firebase CLI what to deploy and where |

## One-time setup

1. Paste your `firebaseConfig` values into `public/firebase-config.js`.
2. Put your project ID into `.firebaserc` in place of `PASTE_PROJECT_ID`.
3. Install the Firebase CLI (needs Node.js): `npm install -g firebase-tools`
4. Sign in: `firebase login`

## Deploy

From this folder:

```
firebase deploy
```

That publishes the app, the security rules and the functions. The app lives at `https://bloodandtears.web.app` (the `bloodandtears` Hosting site in this project). `bloodandtears.web.app` should be listed under Authentication → Settings → Authorized domains.

The old address, `https://loot-goblins-roster.web.app`, was switched off with `firebase hosting:disable --site loot-goblins-roster`.

**After the November clean-up:** the old gear search function `itemSearch` is gone, so the first deploy asks "Would you like to proceed with deletion?" for it. Answer `y`. (`itemLookup` is still there, but it now does a different job: see Item links and tooltips. If the deploy offers to delete it, answer `n`.) The `BLIZZARD_CLIENT_ID` and `BLIZZARD_CLIENT_SECRET` secrets aren't used any more; delete them in Google Cloud Secret Manager if you like.

To try it on your own computer first: `firebase serve` or `firebase emulators:start`.

## Pages

- **Roster**: the whole guild from the armory's guild list, claimed or not.
  - **Search** by name, class, race, spec or profession (every word has to match).
  - **Filters** that work together, folded behind a **Filters** button (with a count of how many are on): role, class, primary profession (First Aid, Cooking and Fishing are left out, since nearly everyone has them), level band (1–19, 20–39, 40–59, 60), and members (in the guild, not in the guild, everyone; your own characters always show). Officers also get a **Claimed (officers)** filter; nobody else sees which characters are claimed. With the panel shut, each filter that's on shows as a chip you can tap to remove.
  - Search, **Filters**, **Sort** (highest or lowest level, name, class, last seen) and three **views** (List, By class with a heading and count per class, and Cards) sit on one row. The default sort is **Highest level**, like the in-game guild roster. The view and sort are remembered in that browser; any sort saved before this change is reset to Highest level once.
  - Rows stay compact: name and tags, class with race and spec, role and level, professions, best loot, and last seen (the time wraps instead of running off the table). Tap a row (or its arrow) to open it in place: professions with skill bars, talent trees and best gear, the armory state explained, honourable kills and rank, and **Open their page**, **This is me** (for unclaimed characters) and **Duel this card**.
  - A line under the filters says how many are showing, with **Clear filters**, and a link to show the guildies hidden for not being in the guild any more.
- **Armory state** (roster rows and character pages): Up to date (data from the last day), Data from … (the armory updates when someone logs out, so it's their last logout), Waiting for the armory (level 10 and up, not found yet), Not on the armory yet (under level 10), or Checked … when the site hasn't managed its hourly check in over six hours. Each has a plain explanation on hover and in the opened row, so a slow armory never looks like a site error.
- **Claiming**: everyone in the guild is already listed; claiming only links a character to a device. New visitors see **Claim my character** (pick from the unclaimed guild list, or type a code from another device) and **Add a character** for anyone not on the guild list yet. Unclaimed rows offer **This is me** when opened. One device can claim as many characters as you play. Regular members never see claimed or unclaimed counts; those are in Site Use, for officers.
- **Since You Were Last Here** (top of the roster): if this device last had the site open over an hour ago, a short summary of what happened since (dings, new firsts, guild milestones, blues and epics found, new guildies, and who gained the most levels), with **See what happened** (History) and **Hide**. The time is kept in that browser only (`lg-last`), saved when the page is hidden or closed.
- **Guild totals** (top of the roster): levels gained, blue and epic items equipped, honourable kills and level 60s, with "+N this week" for levels and kills. A thin gold line along the bottom of each tile shows the way to the next guild milestone (hover for the number).
- **Guild milestones**: the guild's totals passing round numbers: levels gained 100, 250, 500, 1,000, 1,500, 2,000, 3,000; blue items on at once 10, 25, 50, 100, 200; epic items 1, 10, 25, 50; honourable kills 1,000, 5,000, 10,000, 25,000, 50,000; level 60s 1, 5, 10, 20. The server records when each is first passed (`milestones` in `guild/firsts`, worked out with the Hall of Firsts on every armory check; `MILESTONES` in `functions/index.js` and `MS_STEPS` in `public/index.html` must match). Each one gets a line in the Guild Feed and a celebration once on every device (`lg-ms`). The first count after deploying marks ones already passed as "by", so nothing old is celebrated, and a first visit on a device remembers what's there without a celebration.
- **Neck and neck** (top of the Guild Feed): two or more players on the same level who both dinged it in the last two days (from level 10 to 59). It only shows while it's true, and it never goes into History.
- **Guild Makeup** (roster sidebar): every character in the guild counted the same: how the roles split (tanks, healers, DPS), which classes the guild has and which nobody plays yet, and a note when there aren't enough tanks or healers for a group of five each (plus how many more can fill in on their second role). Paladins aren't listed as missing, since the guild is Horde.
- **Leaderboards**: **This week** (levels gained; in launch week everyone added that week counts from level 1), **Firsts** (the Hall of Firsts) and **Honour**.
- **Hall of Firsts**: first in the guild to level 10, 20 … 60, first blue and epic item, first PvP rank, first 100 honourable kills and first 300 in a profession. The server keeps these in `guild/firsts` (only the server can write it) and updates them with every armory check, so they stick even after a character's journey moves on. Someone who was already past a milestone when the site first saw them shows "by" that date. Right after deploying, tap **Sync everyone** to fill it in straight away.
- **Guild Feed**: levels, loot, firsts and guild milestones in game slang ("dinged 24", "looted [item]"), with any **Neck and neck** races on top.
- **Dungeons**: **Who's in Range**: pick a dungeon from the list to see who's the right level for it, split into tanks, healers and DPS, and **Suggest a group** for a balanced five to whisper. The raids are listed underneath with a countdown to 9 December. Nothing to sign up for: group posts, joins and events were cut, since groups are sorted out in game and on Discord. Old group data stays in the database, but the rules no longer let anyone read or change joins.
  - **Who's Been** and **What Drops** (under the chosen dungeon): everyone who has it in their passport (stamped by hand or from loot), then each boss's notable drops in the order you meet them, with a gold note on any item someone in the guild has. The drops come from the same list as the passport's loot stamps (`tools/dungeon-loot/`), so random world drops are left out. **What Drops** folds away, and stays as you left it per dungeon.
- **Professions**: who has what, with skill bars to 300. Primary split into gathering and crafting, a secondary table.
  - **Who Can Make It?** (top of the page): search any crafted item, or pick a profession to browse what the guild can make. Each recipe shows its profession, the skill it needs ("about" when the source only estimated it) and where it's learned, then who qualifies from their armory skill, in three plainly different groups: **Knows it** (learned automatically with the profession), **Can learn it at the trainer**, and **Skilled enough, once they find the recipe** (drops, vendors, quests and reputation; a name there means skilled enough, not that they have it). Nobody qualifying shows the closest person and their skill. Browsing starts on trainer and known recipes, with **Recipe** and **All** to switch. Only current members (and your own characters) count. The site can't see which recipes anyone actually knows, so nothing is shown as confirmed.
  - The recipe list (2,412 recipes across Alchemy, Blacksmithing, Cooking, Enchanting, Engineering, First Aid, Leatherworking, Mining smelts and Tailoring) comes from metabot.gg's WoW Forever profession pages and lives in `tools/recipes/lists/`, one plain file per profession (`Recipe|skill|A/T/R`, `*` after the skill if estimated). Edit one and run `python3 tools/recipes/build.py`; it writes `public/recipes.json`, which the page loads the first time someone opens Professions.
- **About the Guild** (on the roster): Guild Master, officers, loot rules and when the guild plays, which officers fill in.
- **Cards**: every character has a trading card. Tap one to flip it: the back has their stats, talents, professions and any Hall of Firsts they hold. Bronze, silver and gold foil cards catch the light when you point at them. Each card has a line of flavour text: the owner can write their own (40 characters, under the card on their page), or it's picked from their stats and gear, or their class.
- **Cards** (menu): everyone's trading card in a binder, highest level first, with a role filter, plus **Card duels** and **Random duel**.
- **Card Duels** (`#duel`, from **Card duels** on the Cards page or **Duel this card** on a card): pick 2 to 6 characters and their cards go head to head over eleven rounds (class matchup, level, health, armour, attack or spell power, crit, dodge, best profession, honourable kills, loot quality, Hall of Firsts). Each round's best gets a point, ties share it. **Class matchup** gives +1 for each opponent your class counters, with a short reason under the name (Rogue beats Mage and Priest; Mage beats Warrior; Warrior beats Rogue; Warlock beats Rogue and Warrior; Hunter beats Warrior and Druid; Priest beats Warlock; Shaman beats Hunter; Druid beats Shaman). Specs from the armory add small bonuses: healers +15% health, tanks +15% armour, burst specs (Arms, Combat, Fire, Destruction, Subtlety, Marksmanship) +10% attack or spell power. Tweak them in `COUNTERS` and the `*_SPECS` lists next to `DUEL_ROUNDS` in `public/index.html`. The picks are in the address, so **Copy link** shares the duel.
- **Dungeon Passport**: a stamp for every dungeon a character has cleared (35 dungeons). Owners tap a dungeon on their character page to stamp it, and tap again to take it off (saved as `cleared`). Older ticked-off dungeon goals count too. On the card's back, a **Passport** tab sits next to **Stats** (tapping a tab doesn't flip the card), and the card's mini strip shows the dungeon count.
  - **Stamped from loot**: the passport also stamps a dungeon automatically when a character wears, or has equipped or looted (from their Journey), an item that only that dungeon's bosses drop. It's a full stamp like any other, with **Looted: <item>** under it instead of the date (hover for the boss). Nothing extra is stored: it's worked out on the page each time, so there's nothing for the owner to take off. The item list (970 boss drops across 34 dungeons; Shaper's Terrace has no published loot yet) comes from wowtbc.gg's WoW Forever loot tables and lives in `tools/dungeon-loot/lists/`, one file per dungeon. Items more than one boss or dungeon drops, and well-known world drops, are left out because they don't prove anything. To fix or add an item, edit its list and run `python3 tools/dungeon-loot/build.py`, which rewrites the list inside `public/index.html`.
- **Card stamps**: little seals on a card's picture: 1st (in the Hall of Firsts), 60, 300 (in a profession), Epic (wearing one) and PvP (has a rank). They're listed under the card on its page too.
- **Guild History** (`#history`, from **Full history** under the Guild Feed): everything the feed knows, one fold per day: today is open (or the latest day, if nothing has happened yet today) and earlier days are rolled up with a count. Days you open or close stay that way while the page updates. A **You were last here** line marks where this device left off.
- **Copy weekly recap** (under the Guild Feed and on History): makes a picture of the last seven days (totals, top levellers, most kills, new Hall of Firsts, best loot) to paste into Discord. If the browser can't copy pictures, it downloads it instead.
- **In Game Today** (roster sidebar): who has logged off since midnight, from the armory.
- **Suggest a group** (Who's in Range): picks a tank, a healer and three DPS from people in range, favouring whoever played most recently, to whisper in game.
- **Claimed characters**: if someone opens a character that another device has claimed, the page tells them to use Use on another device there, or to ask an officer (named) to free it up with **Free up for claiming**.
- **Character page actions**: **Edit character** is the one main button; the rest (use on another device, and the officer actions) sit under **More**.
- **Site Use** (roster sidebar, officers only): how many characters are claimed, how many opened the site this week, and who hasn't claimed yet. Each device marks its own characters as visited (`visitedAt`) at most every 12 hours; nothing else is tracked.
- **Ding**: when one of your characters has gone up a level since you last opened the site, your trading card turns over in the middle of the screen with the new level pressed on as a red seal, plus what's new (first in the guild, a new card frame, or how far to the next one). **Copy for Discord** copies the card; Close, Escape or tapping outside closes it. With reduced motion it just fades in. The last level seen is kept in that browser only.
- **Guild milestone celebration**: a small player-frame toast in the corner with the guild's blood drop and the milestone. It closes after 4 seconds, waits while you point at it or in a hidden tab, and can be swiped away. Celebrations queue: one shows after the other closes.
- **Characters**: no mains and no alts. Every character is its own entry and its own row, card and duel fighter, whether it's claimed or not. One person can claim or add as many as they like (**Add another character**); the sorting and filters do the rest. Old `main` and `altOf` fields on existing records are left alone but no longer used. Adding a name that's already on the roster (say, from the guild list) uses that one, claiming it if nobody has. If two entries end up with the same name, **Merge them** (officers, or whoever owns both) keeps the armory-synced one and folds the other's journey, passport stamps, devices and flavour text into it. Old alts are moved over automatically by the next sync.
- **Roles**: a main role plus an optional **Can also play** role (a prot warrior who also DPSes). Role filters and group gaps count both. The sync sets Tank or Healer from a protection, holy, discipline or restoration spec, and from the guild roster's roles, until someone picks their role by hand.
- **Character pages**: two columns that stack on their own, so nothing leaves a gap: Gear (the character pane with its stats beside it when there's room), the Dungeon Passport and Professions on the left; the card, talents and journey on the right. The passport shows cleared dungeons plus the ones right for the character's level (or the next few), with **Show all 35** for the rest. On phones the Overview, Gear and Professions tabs show one kind at a time, as before. The Journey folds by day like Guild History: today (or the latest day) is open, earlier days roll up.
  - **Can make** (under the Professions bars): one fold per crafting profession, e.g. "Blacksmithing: 54 known or at the trainer · 107 more with a recipe". Opening it lists the recipes their armory skill covers that are learned automatically or taught by the trainer, hardest first, as item links (12 shown, then **See all in Who Can Make It?**). Recipes from drops, vendors or quests are only counted, since the site can't see which of those they've found. Folds you open stay open.

Character names only: the site never shows or saves anyone's Google name. Old entries that had one are cleaned up automatically.

Hovering a gear slot or an item link shows its Wowhead tooltip (the site draws it from Wowhead's tooltip data, Forever first, then Classic). Class icons come from Wowhead's icon set too; if one can't load, a coloured dot shows instead.

## Who can do what

- **No sign-in screen.** Each browser quietly gets its own anonymous ID (Firebase Anonymous sign-in, which must be turned on in the Firebase console under Authentication, Sign-in method).
- **You edit the characters you added on that device**, plus their passport stamps.
- **Another device:** on your character page, tap Use on another device to get a one-time code, then on the new device tap I'm already on here and type it.
- **Characters from the Google sign-in version** have no device yet. Their owner taps I'm already on here and picks their name to claim it.
- **Officers** can edit or remove anything, undo wrong claims, merge duplicates and set the Discord link and guild basics. To make someone an officer, add their character name to `OFFICER_NAMES` near the top of the guild roster code in `functions/index.js` and deploy. The server ties each name to the first character with that name and keeps their devices up to date in `guild/officers`, which only the server can change.

## Offline

- The app's files are cached by the service worker after the first visit.
- Firestore keeps a copy of the guild's data on each device. Changes made offline are saved locally and sync when the device reconnects.
- Opening the site the first time needs a connection.

## Polish pass (11 Nov)

Every page was checked on a phone and a desktop, in dark and light mode, for sideways scrolling, cut-off text, small tap targets, colour contrast (axe) and errors. Fixed: faint gold duel notes in light mode, faint "not seen lately" names on Dungeons, small chips and fold headers on phones, the squashed Sort box on the phone roster, and the Professions switch sitting above the search it doesn't control.

## Records (11 Nov)

A **Records** tab ranks everyone on what the armory already says: honourable kills, highest level, dungeons stamped, best geared (loot points: 1 per green, 2 per blue, 3 per purple, the same as card duels) and every profession. The four main boards (2 × 2) show the top 3 with gold, silver and bronze medals that also carry the number, then your own character if it isn't near the top, then whoever is last under a "Wooden spoon" label; See all lists everyone. Professions are one table: a row per profession with 1st, 2nd, 3rd and last across (stacked on phones); tap a row to see everyone. Ties share a place. Characters who've left the guild aren't counted. On a character's page each profession, and the honourable kills in PvP stats, get a line like "Best miner in the guild" or "6th of 6 in the guild · wooden spoon" that links to Records. The roster's Leaderboards card links there too. Nothing new is stored: it's all worked out in the browser, so the sync, database and rules are unchanged.

## Dungeons and Professions tidy-up (11 Nov)

- **Level ranges** now match the in-game Looking For Group tool (from Warcraft Tavern's WoW Forever dungeon guide), for example Dire Maul East 54–60, West and North 56–60, Upper Blackrock Spire 59–60. The switched-off Discord commands in `functions/index.js` still carry the old list; update it there too if Discord is turned back on.
- **Dungeons:** the dropdown is gone. **Dungeons by Level** splits them into four bands (13–24, 25–39, 40–51, 52–60, by each dungeon's starting level, plus All) and opens on the band for your level; the old "Suits my level" box is gone. Each band lists its dungeons in level order with how many current characters are the right level ("in range") and how many have been. Dungeons at your level are tagged. Click one to open it in place: who's in range by role, Suggest a group, Who's Been, and What Drops (now folded shut until you open it). Suits my level still filters the list.
- **Professions:** the secondary professions are cards like the primary ones (the long table is gone). Who Has What is one even 3-column grid (gathering first, then crafting, each card labelled), one line per character with the skill number on the right and the bar underneath, so long names no longer push things onto a second line. The rank (Expert and so on) is in the tooltip. Each card shows the top 5 with an "N more" button.

## This week, titles, rivals, milestones and sync status (12 Nov)

- **This Week** (top of Records): once a day the hourly sync saves everyone's level, honourable kills, loot points and profession skills to `guild/records` (the last 10 days, server-only in the rules). Records compares today with about a week ago and lists new number ones ("took the top spot in Alchemy from …"), climbs of two places or more into the top 5, and the week's biggest kill and level gains. Dungeons aren't in the snapshot. It starts filling in the day after this is deployed.
- **Titles:** whoever is alone at the top of a board (with at least two on it) holds its title, e.g. Most Wanted (kills), Dungeon Crawler, Best Dressed (loot points), Master Miner, Green Thumb (Herbalism), Head Chef, Field Medic, Master Angler. Shown under the name on the character page (three, then "+N more") and on each Records board. Worked out in the browser; nothing stored.
- **Rival:** on your own character's page, pick a guildie and get a head-to-head (level, kills, dungeons, loot points and every profession you share) with a running score. Saved on this device only.
- **Weekly recap archive:** the "Weekly recap" button (feed and History) opens a dialog: pick "This week so far" or any finished week, see the picture, then Copy picture or Download. When the week turns over (first sync after Monday midnight, Perth), the server saves that week's recap to `guild/recaps` (totals, top levellers, most kills, best loot, new Hall of Firsts; the last 52 weeks, server-only). The first week after deploying is marked "Part week" because it started mid-week.
- **Feed milestones:** the sync adds "Reached 500 honourable kills" (100, 250, 500, 1,000, 2,500, 5,000, 10,000, 25,000) and "Reached 225 Blacksmithing" (75, 150, 225, 300) to the journey, so they show in the feed. Not on a character's first sync, and not for a profession that's new to them.
- **Sync status:** each character page says when the armory was checked, how old the game's own data is (it updates when the character logs out), and what the last change was ("Last change 2 days ago: level 23 → 24, gear", saved as `armory.change`). The roster says how many characters the last check updated and, as a button, which ones the armory couldn't find (`guild/armory.missing`).
- **Dungeons** are grouped like the game's Spelunker achievements: **Novice** (Ragefire Chasm, Ruins of Lordaeron, Wailing Caverns, Deadmines, Shadowfang Keep, Excavation Site; plus Hall of Thanes and The Stockade, tagged "Alliance · no Legacy points" because they don't count toward the Horde achievement), **Experienced** (City of Dalaran, Blackfathom Deeps, Gnomeregan, The Drowned City, the four Scarlet Monastery wings, Razorfen Kraul, Krol'Dok Stronghold) and **Master** (the rest). Upper Blackrock Spire is 55–60, as the game shows it.
- **Phone pass:** every page checked at 390 and 320 px: Records rows keep the class dot, name and "You" on one line; What Drops' heading wraps properly; the bottom menu's five labels shrink a little under 360 px; a character tab with nothing in it (no gear yet) says so instead of showing a blank page.

## Text size

Text, spacing and sizes are in rem, so the whole site grows with the browser's text-size setting (someone who sets their browser to bigger text gets bigger text and roomier spacing to match). At the normal setting it looks exactly as it did in pixels. Borders, rounded corners, shadows and the screen-width breakpoints stay in px on purpose. If you add styles in px, run `python3 tools/scale/to_rem.py` to convert them. Checked at 125% on phone and desktop: nothing scrolls sideways or gets cut off; long names and labels wrap instead.

## Item links and tooltips

Every item the site knows the quality of (gear, best loot, the Journey and guild feed, the Hall of Firsts, passport loot stamps, dungeon drops and recipes) is shown like an in-game item: the name in square brackets in its quality colour. Hovering one shows Wowhead's WoW Forever tooltip, and clicking opens it on Wowhead.

- Items saved with an ID (anything from the armory) and items in the loot and recipe lists link straight to Wowhead. Those IDs come from the open-source wow-classic-items database (`tools/item-ids/`); WoW Forever keeps classic item IDs, so Wowhead's Forever tooltips work with them. 819 of the 970 dungeon drops and 1,121 of the 2,412 recipes have one.
- Items WoW Forever added itself (its new dungeons and recipes) aren't in that database. The page sends their names to the server function `itemLookup`, which looks each one up once on Wowhead's WoW Forever database and saves its ID and quality in `guild/itemIds` (only the server can write it). A result only counts when Wowhead's own tooltip data has exactly that name, so nothing gets the wrong link. The list updates live, so these items turn into proper coloured links with tooltips a few seconds after someone first views them, for everyone after that.
- Until then, or if Wowhead doesn't have an item, it shows as plain bold text rather than in a made-up colour. Names with no match are tried again after a week. Enchants are spells, not items, so they're never looked up and stay plain.
- The page asks about at most 25 names at a time, each name once per visit, and the server stops adding names once the list holds 6,000.
- Talents on character pages show a tooltip on hover too, in the same style, with the talent's rank and the game's own description from the armory (touch screens still tap to open it). They use the armory's text rather than Wowhead's, because the armory doesn't say which Wowhead spell each talent is.
- The weekly recap image draws items in their quality colours (it's a picture, so it can't link).
- To refresh the IDs after editing a loot or recipe list, see the top of `tools/item-ids/build.py`.

## Gear

Each character page has a gear panel like the in-game character window, filled from the armory (see below). Nothing in it is edited by hand. Hovering a slot shows the item's tooltip, and clicking it opens the item on Wowhead.

## Armory sync

Every hour (and whenever someone taps **Sync** on any character page, or **Sync everyone** on the roster) the site reads each character's WoW Forever armory page, `worldofwarcraft.blizzard.com/en-us/forever/us/armory/character/<first-last>`, and copies over:

- **Level**: only ever goes up. Level-ups go into the Journey, the Level Race and #guild-feed like any other.
- **Spec** (e.g. Combat), shown next to the class.
- **Professions**: primaries and secondaries replace what's on the site. Training a new rank (Journeyman, Expert, Artisan) goes into the Journey.
- **Gear**: the armory's equipped items replace the gear panel when they differ. Rare or better items go into the Journey.
- **Talents**: every tree with points in it, shown on the character page. Tap a talent to read what it does.
- **Stats**: health, power, attributes, melee, spell and defence stats, shown under the gear panel.
- **PvP**: honourable kills and rank. The Honour Board on the roster shows this week (since Monday, Perth time) and all time.
- **Last seen in game**: when the armory last heard from the game, which is usually the last logout. Shown on the roster and character pages.
- **Class and race**, only if they're blank on the site.
- **Character pictures**: the full in-game render fills the middle of the gear panel, the race background goes behind it and on the character card, and the armory portrait goes on the card. All load straight from Blizzard's image server.

The armory is only as fresh as the last time the game updated it, usually when someone logs out, and it can lag by hours. Gear and professions always come from the armory (the site can't edit them, and older hand edits are replaced at the next check). Levels never go down. Armory data can only be written by the sync, not from the site (see `firestore.rules`), so nobody can fake the Honour Board.

**Add my character** has a **Fill in from the armory** button: type the name, tap it, and race, class, level and role are filled in. Professions, gear, talents and pictures arrive a few seconds after saving. **Edit character** is short: first and last name, role, **Can also play** and when they joined the guild (optional), plus race, class and level until the armory finds the character. Renaming a character checks the armory again straight away.

**Who's in Range** on the Dungeons page lists everyone whose level fits each dungeon, split into tanks, healers and DPS, with **Suggest a group**. The roster's **Character of the day** spotlight picks a different character each day (the same one for everyone).

Characters only appear on the armory after logging out at level 10 or above.

**Guild roster.** Every hour the sync also reads the guild's member list from the armory (the same request the armory's guild page makes, to `worldofwarcraft.blizzard.com/en-us/graphql`). Guildies who aren't on the site yet are added automatically with their level, class and race, and show as **Unclaimed** until they tap **I'm already on here** and pick themselves. The first import is quiet; after that, new guildies get a "joined the guild" post in #guild-feed. Someone removed from the site is never added back. The roster also raises levels (it updates sooner than character pages), tags the **Guild Master**, and tags site characters that are **Not in the guild**. If Blizzard changes how their guild page asks for the roster, this part stops with a warning in the function logs (`guild roster`) and the rest keeps working; the request to copy lives in `ROSTER_QUERY` in `functions/index.js`.

## Trimmed down

To keep it to what fills itself in, the site no longer has a wishlist, I Can Make recipe lists, Showing Off, notes, a time zone, a goals card, trade orders, group posts, events, hand-edited gear or professions (or the item search that went with them), or achievements (the last two, First Blood and Artisan, went because the Hall of Firsts and the card's 1st and 300 stamps already show them). The menu is Roster, Dungeons, Cards and Professions. Old data for the cut features stays in the database but isn't shown. The Level Race's "This week" counts characters added this week from level 1.

## Discord is switched off for now

Discord posts, the daily digest and the slash commands are turned off, but all the code is still here. Only the **On Discord** box (who's online) is live, and it shows up once the server's widget is on (Server Settings > Widget > Enable Server Widget).

To turn the rest back on: set `DISCORD_ON = true` near the top of `functions/index.js` and in `public/index.html`, set the secrets below, then `FUNCTIONS_DISCOVERY_TIMEOUT=60 firebase deploy`. While it's off, the Discord functions aren't deployed and the Discord secrets aren't needed.

Before switching it back on: `/lfg`, `/link` and the #lfg and #events posts belong to the group posts and events the site no longer has, so they'd want taking out first.

## Discord posts (switched off)

Big moments post straight away: someone joining, level 60, being first in the guild to a level milestone, epic or better items, maxing a profession, PvP rank-ups, Looking for Group posts and events. Smaller news (other level milestones, blue items, new profession ranks, honourable kill milestones) is saved up and posted once a day at 9pm Perth time as **Today in Blood and Tears**.

`functions/index.js` posts to a Discord channel when someone joins the roster, posts a Looking for Group goal, hits a level milestone (every 10 levels and 60), equips a rare or better item, trains a new profession rank, reaches a new PvP rank or an honourable kill milestone, or plans an event. (Trade orders and the weekly roundup were removed; you can delete the #trade-orders channel and the DISCORD_WEBHOOK_TRADE secret.)

1. Upgrade the Firebase project to the Blaze plan and set a budget alert.
2. Check your Firestore location (Firestore Database page). If it isn't `australia-southeast1`, change `REGION` at the top of `functions/index.js` to match.
3. In Discord, make one webhook per channel (Edit Channel > Integrations > Webhooks > New Webhook) and copy each URL.
4. From this folder, set one secret per channel and paste its URL when asked:
   - `firebase functions:secrets:set DISCORD_WEBHOOK` for #guild-feed (new guildies, big moments and the daily digest)
   - `firebase functions:secrets:set DISCORD_WEBHOOK_LFG` for #lfg
   - `firebase functions:secrets:set DISCORD_WEBHOOK_EVENTS` for #events

   If #lfg or #events are forum channels, each group or event becomes its own post. Plain text channels get normal messages.
5. `cd functions && npm install && cd ..` then `firebase deploy`.

## Ideas for later

- Raid sign-ups and a raid calendar

## Discord slash commands (removed)

The old `/card`, `/who`, `/lfg` and `/link` commands were never switched on and were removed in Nov 2026, with the site's "Link Discord" and "Discord commands" buttons and the `dlinks` rule. Discord posting through webhooks (also switched off) is still in `functions/index.js`.

## Link previews and icon

Pasting the site's link in Discord (or anywhere that reads Open Graph tags) shows a Blood and Tears preview using `public/og.png`, with the red from `theme-color` down the side. Discord keeps old previews for a while, so the first new one can take a bit to show. The app icon is a blood drop (`public/icon.svg`, plus `icon-192.png` and `icon-512.png` for phones).

## Phone layout

On phones the roster shows each person in two or three lines with an arrow to open them, and the page runs: Since You Were Last Here (when there's news), totals, roster, In Game Today, Character of the Day, Guild Feed, Leaderboards, Guild Makeup, About. The menu has four tabs along the bottom (Roster, Dungeons, Cards, Professions), and the theme button is a sun or moon icon.
