# Blood and Tears guild site

The site for the Blood and Tears guild (Horde, WoW Forever), at https://bloodandtears.web.app. Almost everything fills itself in from the WoW Forever armory every hour. Nobody has to keep it up to date by hand.

This file describes the site as it is today. The older, dated notes on how each part was built are in `docs/HISTORY.md`. The look and feel is described in `DESIGN.md`.

## The pages

| Page | What's on it |
|---|---|
| **Roster** | Everyone in the guild. Search, Filters (with quick chips for Tanks, Healers, DPS, Level 60, Seen this week and Mine at the top, folded away until opened; whatever's on shows as removable chips), sort and three views (List, By class, Cards). Each row shows the portrait, the name with at most one mark (You, a gold crown for the Guild Master, or Officer), the top title and class, the level (with a status like On a tear under it), professions, best loot and last seen (blank when unknown); characters not in the guild sit in their own group at the bottom. The search, sort and column titles stay at the top while scrolling on desktop. On phones a row is just name, level and professions; open it for the rest; opening a row shows the details with their card beside them. The side column has Character of the Day, In Game Today, This Week (the top three moves; the level race, Firsts and honour are on Records) and Guild Makeup, with About the Guild at its foot. On phones the totals strip is one row you can swipe. Below the list is the Guild Feed. |
| **Character page** | Portrait, name and titles, a strip of headline numbers, then gear and stats, the Dungeon Passport, professions (with what they can make: tap a recipe for its reagents and where to get it; a dot shows whether it still gives them skill-ups), their trading card, talents and their Journey. |
| **Dungeons** | The dungeons grouped like the game's Spelunker achievements (Novice, Experienced, Master), with the two Alliance-side ones (Hall of Thanes, The Stockade) folded away at the bottom. For each: how many are the right level, how many have been, and how many still need it. "You need this" marks the ones your character is the right level for and hasn't done. Open one for the names, Suggest a group, and what drops. |
| **Raids** (`#raids`, from the switch on Dungeons) | Raid readiness for Barrow Deeps, Hyjal Summit and Onyxia's Lair, every level 60 with their role and gear, and who's between 50 and 59. |
| **Cards** | Everyone's trading card in sets (Gold foil, Silver, Bronze, Plain), with search and sort, and Card of the Week. "Open page" under a card shows on hover, keyboard focus, or once the card is flipped. |
| **Professions** | **Who Has What** (one table: a row per profession, everyone in skill order with medals for the top three and the wooden spoon for the lowest), and **Who Can Make It?**: search any crafted item to see who's skilled enough. **Reagents and recipe** on a result opens its reagents, where the recipe comes from and its skill-up colours (from `public/recipe-info.json`, loaded on first open). |
| **Records** | This Week (Moves, Level race or Gear race, the Hall of Firsts and Honour, on a switch), then **Leaderboards** (kills, level, dungeons and gear on one card with a switch, top five and the wooden spoon, the title holder above), the **Hall of Titles** as a grid of frame tiles (tap one for how it's won, the reign and who's next), When the Guild Plays, and a link to the profession leaderboards on Professions. |
| **Guild History** (`#history`) | The Last Seven Days (the recap's numbers, the top levellers and how much happened), then everything the feed has seen, one fold per day, with a character search and a Show menu (Levels, Loot, Titles and firsts, Joins and leaves, Professions, PvP, Dungeons). The weekly recap picture is there for any week. |

Other things worth knowing about:

- **Titles and stamps** are earned automatically. Whoever is alone at the top of a Records board holds its title (Most Wanted, Master Miner and so on), and cards earn stamps for things like level 60, an epic, a PvP rank or a full set of dungeons.
- **Card frames.** A title holder's card gets a frame for the kind of title: Warlord (most kills), Delver (dungeons), Royal (best dressed), Amethyst (epics), Lightning (levels this week), Oak (longest on the site), Wild (a gathering profession), Forge (a crafting profession), Hearth (Cooking, First Aid, Fishing) and Champion (top of a class, in the class colour). The colours are in `FRAMES` in `public/index.html`.
- **Reigns.** The server notes who holds Most Wanted, Best Dressed and each profession title, and since when (`guild/titles`, checked every hour). The site shows "3 weeks running" in the Hall of Titles, beside the title on the character page and on the card's label. The other titles (dungeons, epics, speed, longest on the site, top of a class) aren't tracked, so they show no reign.
- **Title news.** When one of those titles changes hands, the Guild Feed says so: "Mogra took Chief Engineer from Clark".
- **First edition.** Cards for characters who were on the site in launch week (5 to 11 November) carry "1st ed". It can't be earned later.
- **Status badges.** A roster row can show one small tag: Fresh blood (joined this week), On a tear (levels this week for where they started it: 6 under level 20, 4 from 20, 3 from 40, 2 from 50; only the top three get it, `TEAR_MAX` in `public/index.html`) or Missing in action (not seen for three weeks). Never more than one.
- **Streaks.** The server counts how many days in a row each character has been seen in game (`guild/streaks`, from the armory's last-logout time). From two days (`STREAK_MIN` in `public/index.html`), a flame and the number show beside "Last seen" on the roster, beside the name on their page, and as a stamp on their card. It goes when they miss a day. The first run looks back once and works out streaks so far from each character's dated history (levels, loot, skill-ups) and the daily snapshots; that can only undercount, since a day with nothing new to show isn't seen. One allowance for characters added in launch week: if their run is unbroken as far back as their history goes, and that history starts within a day of when they were added or has hit its 40-line limit, the streak counts from the day they were added.
- **Guild Master.** The character at the top rank on the guild's armory list gets a crown and "Guild Master" over a gold name on their card.
- **PvP rank stripes.** A card shows its PvP rank under the level badge: ranks 1 to 5 are bronze chevrons (one per rank), 6 to 10 are silver chevrons over a bar, and 11 to 14 are gold, two chevrons under one to four stars. It follows whatever rank the armory shows.
- **Choose your title.** With more than one title, the owner picks which one their card wears (its ribbon and frame) from the frame swatches under the card on their page.
- **Signature moves.** Every spec has one (Combat rogues have Blade Flurry), printed on the card for flavour. The list is `MOVES` in `public/index.html`.
- **Celebrations.** When your character levels up, your card flips over with the new level. Guild milestones (such as 1,000 honourable kills) get a small toast.
- **Since You Were Last Here** sums up what happened since this device last had the site open.
- **Search** (the header button, or press `/` anywhere) finds characters, recipes, dungeon drops, dungeons and pages, and goes straight there: a recipe opens Who Can Make It with it filled in, a drop opens its dungeon with What Drops open.
- **Smooth to use:** a spinning gingerbread loading screen until the roster arrives, pictures that fade in once, Back returning to the same spot on the page, and things sliding open when tapped (all motion is switched off for anyone who's asked their device for less).
- **Winter Veil.** A countdown strip runs from 1 December to Boxing Day.
- **Character of the Day** picks from characters at level 10 or more with a real armory picture, seen in game in the last three days (it widens if nobody fits). Recent level-ups and new gear make a pick likelier.
- **On Discord** names only who's in a voice channel (by channel) and who's playing World of Warcraft, then "+N others online". Officers can leave names off it (bots, say) under **Leave off the Discord box** in Guild Basics.
- **Short on healers:** Guild Makeup names the Shamans, Druids, Paladins and Priests who aren't set to Healer, as people who could heal as an off-spec.
- **Up for grabs:** while nobody has an epic or a level 60, those totals say so and open the Hall of Firsts.
- **Claim Your Character** goes for good on a device once it claims, or once "Not now" is pressed.
- **Endgame.** Once half the guild is level 60, the roster's "Level race" becomes a "Gear race".

## Where the data comes from

- **The armory sync** (`armorySyncAll`, every hour) reads the guild's member list and each character's armory page: level, class, race, spec, professions, gear, talents, stats, honourable kills, PvP rank, pictures and last seen. **Sync now** and **Sync everyone** do the same on demand.
- The armory only updates when a character logs out, and characters under level 10 aren't on it. The site shows this as "Up to date", "Data from …" or a dash, with the reason behind **Details**.
- **Only two things are entered by hand:** passport stamps (also added automatically from dungeon-only loot) and each card's flavour text. Officers also fill in About the Guild.
- **Worked out in the browser, never stored:** Records, titles, stamps and "who can make it".
- **Saved by the server:** a 10-day snapshot for This Week (`guild/records`), finished weekly recaps (`guild/recaps`), the Hall of Firsts and guild milestones (`guild/firsts`), who holds which title and since when (`guild/titles`), and each character's streak of days seen in game (`guild/streaks`).

## Who can do what

- **No sign-in screen.** Each browser gets an anonymous ID. Anyone with the link can read the site.
- **Claiming** links a character to a device, so that device can stamp its passport and write its flavour text. **Use on another device** gives a one-time code for a second device.
- **Officers** can edit or remove anything, free up wrong claims, merge duplicates, add characters by hand and set the guild basics. To make someone an officer, add their character name to `OFFICER_NAMES` in `functions/index.js` and deploy.
- **Only officers add characters by hand.** Everyone else arrives from the guild list within the hour.

## Privacy

- The site keeps armory data only: character names, never real names or emails.
- It asks search engines not to list it (`robots.txt`, a `noindex` tag and header).
- **Opting out:** More → Take off the site on a character page (the owner or an officer). The character is deleted and never added back. Officers can let them back in from the roster's "N opted out" button.
- **Privacy and opting out** in the footer explains all this to guildies. Officers also get **Check for old data** there, which finds and removes leftovers from features that were cut.
- **App Check** switches on when a reCAPTCHA Enterprise key is put in `APP_CHECK_SITE_KEY` in `public/firebase-config.js`. Turn on enforcement in the Firebase console only after the key is live.

## Files

| File | What it does |
|---|---|
| `public/index.html` | The whole site: layout, styles and code |
| `public/firebase-config.js` | The Firebase project's config and the App Check key |
| `public/recipes.json`, `public/recipe-info.json` | The recipe list for Who Can Make It?, and each recipe's reagents and source (built by `tools/recipes/build.py`) |
| `public/dungeon-loot.json` | Dungeon drops for What Drops, passport stamps from loot and item links (built by `tools/dungeon-loot/build.py`; the page loads it separately so it opens faster) |
| `manifest.webmanifest`, `icon*`, `logo.svg`, `og-gingerbread.png` | The home-screen icon and the link preview |
| `public/robots.txt` | Keeps the site out of search engines |
| `functions/index.js` | The server: armory sync, Hall of Firsts, snapshots, opt-out, item lookups, officers |
| `firestore.rules` | Who can read and change what |
| `firebase.json`, `.firebaserc` | What gets deployed and where, plus the security headers |
| `addon/BloodAndTearsScribe` | The guild scribe addon for WoW Forever |
| `tools/` | Scripts that rebuild the dungeon loot list, recipe list, item IDs and the icon |
| `DESIGN.md`, `PRODUCT.md` | The design system and what the site is for |
| `docs/HISTORY.md` | The build diary |

## Deploying

One-time setup: install the Firebase CLI (`npm install -g firebase-tools`, needs Node.js), run `firebase login`, and `cd functions && npm install`.

- **Only the page changed** (anything in `public/`): `firebase deploy --only hosting`
- **Server or rules changed too:** `FUNCTIONS_DISCOVERY_TIMEOUT=60 firebase deploy`. If it asks about deleting `itemSearch`, answer `y`; for `itemLookup`, answer `n`.

The Firebase project is `loot-goblins-roster`, the Hosting site is `bloodandtears`, and everything runs in `australia-southeast1`.

## Jobs in the Firebase and Google Cloud consoles

These aren't in the code:

- **Budget alert** (Google Cloud Billing → Budgets & alerts). It emails you; it doesn't stop charges.
- **Backups** (Firestore → Disaster recovery), if you want them.
- **App Check** registration and enforcement (see Privacy).
- **Anonymous sign-in** must stay on (Authentication → Sign-in method), and `bloodandtears.web.app` must be an authorised domain.

## Changing common things

- **A dungeon's loot:** edit its file in `tools/dungeon-loot/lists/`, then run `python3 tools/dungeon-loot/build.py` (it writes `public/dungeon-loot.json`). Wowhead IDs for WoW Forever's own drops are in `tools/item-ids/forever-loot.txt`. Recipe vendors are in `tools/recipes/vendors.json`.
- **A dungeon's level range:** `DUNGEONS` in `public/index.html`.
- **A recipe:** edit the profession's file in `tools/recipes/lists/`, then run `python3 tools/recipes/build.py`. Wowhead IDs come from `tools/item-ids/ids.json` (classic items) and `tools/item-ids/forever-crafted.txt` (WoW Forever's own new items, from Wowhead's Forever profession pages). Enchants link to Wowhead's spell pages, with spell IDs from `tools/item-ids/forever-enchants.txt`. Learn levels, reagents, skill-up colours and recipe sources come from `tools/recipes/wowhead-forever.json`, saved from Wowhead's WoW Forever profession and recipe pages; `build.py` writes them to `public/recipe-info.json`. A recipe with neither shows as plain text.
- **The icon or logo:** edit and run `python3 tools/icon/make_icon.py`.
- **The raids list:** `RAIDS` in `public/index.html`.
- **Guild milestones:** `MILESTONES` in `functions/index.js` and `MS_STEPS` in `public/index.html` must match.
- **New styles:** sizes are in rem. If you add any in px, run `python3 tools/scale/to_rem.py`.

## The guild scribe (in-game addon)

`addon/BloodAndTearsScribe` is a small WoW Forever addon (interface 16001). While whoever runs it plays, it reads the in-game guild list every five minutes and notes:

- when each guildie was last online (the guild list gives this for everyone, online or not), which days they were on, and the last zone they were seen in
- how many guildies are online each hour
- joins and leaves
- who was in the raid group inside a raid
- the recipes the uploader's own characters know (read when a profession window is opened)

It sends nothing anywhere, reads nothing in combat and draws nothing on screen. `/scribe` in game shows a summary.

**Install:** copy the `BloodAndTearsScribe` folder into the game's `Interface\AddOns` folder (or install it from CurseForge once it's published there), then tick it in the in-game AddOns list.

**Upload:** the game saves the notes when you log out or type `/reload`, to `WTF\Account\<ACCOUNT>\SavedVariables\BloodAndTearsScribe.lua` in the game folder. It has the same name as the addon's own file, so check it starts with `BloodAndTearsScribeDB = {`. On the site, open Roster, then Details next to "Up to date", and choose **Upload the scribe file** (officers only). The server (`scribeUpload`) reads the file as data, matches names to characters, skips anyone who opted out, and keeps what it uses in `guild/scribe`. Every few days is plenty: the guild list reports last-online times back from the moment of upload.

**Where it shows:** exact streaks and "last seen" (the later of the armory and the scribe), "Last seen … in <zone>" in an opened roster row, joins and leaves in the Guild Feed, **When the Guild Plays** on Records (after three days of notes), **Raid Nights** on Raids, and "knows it" in Who Can Make It? for recipes the scribe has seen.

## Switched off or removed

- **Discord posting** (webhooks and the daily digest) is switched off with `DISCORD_ON = false` in `functions/index.js`. The code is still there and does nothing. `docs/HISTORY.md` has the steps to turn it back on.
- **Removed:** the empty offline worker (`sw.js`; the page now lets go of old copies), group posts, events, trade orders, wishlists, notes, hand-edited gear and professions, achievements, the Discord slash commands, Rivals, and the card games (Card Duels, Draft Duel, Guess the Guildie; old links open Cards). Old data from these can be cleared with **Check for old data**.
