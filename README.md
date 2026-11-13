# Blood and Tears guild site

The site for the Blood and Tears guild (Horde, WoW Forever), at https://bloodandtears.web.app. Almost everything fills itself in from the WoW Forever armory every hour. Nobody has to keep it up to date by hand.

This file describes the site as it is today. The older, dated notes on how each part was built are in `docs/HISTORY.md`. The look and feel is described in `DESIGN.md`.

## The pages

| Page | What's on it |
|---|---|
| **Roster** | Everyone in the guild. Search, Filters, sort, quick chips (Tanks, Healers, DPS, Level 60, Seen this week, Mine) and three views (List, By class, Cards). Each row shows the portrait, name and top title, level, professions, best loot and last seen; opening a row shows the details with their card beside them. The side column has Character of the Day, In Game Today, This Week on Records, Guild Makeup and About the Guild. Below the list is the Guild Feed. |
| **Character page** | Portrait, name and titles, a strip of headline numbers, then gear and stats, the Dungeon Passport, professions (with what they can make), their trading card, talents and their Journey. |
| **Dungeons** | The dungeons grouped like the game's Spelunker achievements (Novice, Experienced, Master). For each: how many are the right level, how many have been, and how many still need it. Open one for the names, Suggest a group, and what drops. |
| **Raids** (`#raids`, from the switch on Dungeons) | Raid readiness for Barrow Deeps, Hyjal Summit and Onyxia's Lair, every level 60 with their role and gear, and who's between 50 and 59. |
| **Cards** | Everyone's trading card in sets (Gold foil, Silver, Bronze, Plain), with search and sort, and Card of the Week. |
| **Professions** | Who has what, and **Who Can Make It?**: search any crafted item to see who's skilled enough. |
| **Records** | Leaderboards for kills, level, dungeons, gear and every profession, with titles for whoever is top, the wooden spoon for last, This Week, the Hall of Titles and the Hall of Firsts. |
| **Guild History** (`#history`) | Everything the feed has seen, one fold per day, plus the weekly recap picture for any week. |

Other things worth knowing about:

- **Titles and stamps** are earned automatically. Whoever is alone at the top of a Records board holds its title (Most Wanted, Master Miner and so on), and cards earn stamps for things like level 60, an epic, a PvP rank or a full set of dungeons.
- **Card frames.** A title holder's card gets a frame for the kind of title: Warlord (most kills), Delver (dungeons), Royal (best dressed), Amethyst (epics), Lightning (levels this week), Oak (longest on the site), Wild (a gathering profession), Forge (a crafting profession), Hearth (Cooking, First Aid, Fishing) and Champion (top of a class, in the class colour). The colours are in `FRAMES` in `public/index.html`.
- **Reigns.** The server notes who holds Most Wanted, Best Dressed and each profession title, and since when (`guild/titles`, checked every hour). The site shows "3 weeks running" in the Hall of Titles, beside the title on the character page and on the card's label. The other titles (dungeons, epics, speed, longest on the site, top of a class) aren't tracked, so they show no reign.
- **Title news.** When one of those titles changes hands, the Guild Feed says so: "Mogra took Chief Engineer from Clark".
- **First edition.** Cards for characters who were on the site in launch week (5 to 11 November) carry "1st ed". It can't be earned later.
- **Status badges.** A roster row can show one small tag: Fresh blood (joined this week), On a tear (four or more levels this week) or Missing in action (not seen for three weeks). Never more than one.
- **Streaks.** The server counts how many days in a row each character has been seen in game (`guild/streaks`, from the armory's last-logout time). From two days (`STREAK_MIN` in `public/index.html`), a flame and the number show beside "Last seen" on the roster, beside the name on their page, and as a stamp on their card. It goes when they miss a day. The first run looks back once and works out streaks so far from each character's dated history (levels, loot, skill-ups) and the daily snapshots; that can only undercount, since a day with nothing new to show isn't seen. One allowance for characters added in launch week: if their run is unbroken as far back as their history goes, and that history starts within a day of when they were added or has hit its 40-line limit, the streak counts from the day they were added.
- **Guild Master.** The character at the top rank on the guild's armory list gets a crown and "Guild Master" over a gold name on their card.
- **PvP rank stripes.** A card shows its PvP rank under the level badge: ranks 1 to 5 are bronze chevrons (one per rank), 6 to 10 are silver chevrons over a bar, and 11 to 14 are gold, two chevrons under one to four stars. It follows whatever rank the armory shows.
- **Choose your title.** With more than one title, the owner picks which one their card wears (its ribbon and frame) from the frame swatches under the card on their page.
- **Signature moves.** Every spec has one (Combat rogues have Blade Flurry), printed on the card for flavour. The list is `MOVES` in `public/index.html`.
- **Celebrations.** When your character levels up, your card flips over with the new level. Guild milestones (such as 1,000 honourable kills) get a small toast.
- **Since You Were Last Here** sums up what happened since this device last had the site open.
- **Winter Veil.** A countdown strip runs from 1 November to Boxing Day.
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
| `public/recipes.json` | The recipe list for Who Can Make It? (built by `tools/recipes/build.py`) |
| `public/sw.js`, `manifest.webmanifest`, `icon*`, `logo.svg`, `og-gingerbread.png` | Offline support, the home-screen icon and the link preview |
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

- **A dungeon's loot:** edit its file in `tools/dungeon-loot/lists/`, then run `python3 tools/dungeon-loot/build.py`.
- **A dungeon's level range:** `DUNGEONS` in `public/index.html`.
- **A recipe:** edit the profession's file in `tools/recipes/lists/`, then run `python3 tools/recipes/build.py`.
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

**Upload:** the game saves the notes when you log out or type `/reload`, to `WTF\Account\<ACCOUNT>\SavedVariables\BloodAndTearsScribe.lua` in the game folder. On the site, open Roster, then Details next to "Up to date", and choose **Upload the scribe file** (officers only). The server (`scribeUpload`) reads the file as data, matches names to characters, skips anyone who opted out, and keeps what it uses in `guild/scribe`. Every few days is plenty: the guild list reports last-online times back from the moment of upload.

**Where it shows:** exact streaks and "last seen" (the later of the armory and the scribe), "Last seen … in <zone>" in an opened roster row, joins and leaves in the Guild Feed, **When the Guild Plays** on Records (after three days of notes), **Raid Nights** on Raids, and "knows it" in Who Can Make It? for recipes the scribe has seen.

## Switched off or removed

- **Discord posting** (webhooks and the daily digest) is switched off with `DISCORD_ON = false` in `functions/index.js`. The code is still there and does nothing. `docs/HISTORY.md` has the steps to turn it back on.
- **Removed:** group posts, events, trade orders, wishlists, notes, hand-edited gear and professions, achievements, the Discord slash commands, Rivals, and the card games (Card Duels, Draft Duel, Guess the Guildie; old links open Cards). Old data from these can be cleared with **Check for old data**.
