"""Builds the "From loot" passport list from lists/*.txt and writes it into public/index.html.

Each list is one dungeon's boss drops, one line per item: "Boss | Item name"
(source: wowtbc.gg/warcraftforever/loot-tables/dungeons/, November 2026).
To fix an item: edit its list, then run  python3 tools/dungeon-loot/build.py  from the project folder.

Left out on purpose, because owning them doesn't prove you were in that dungeon:
  - items more than one boss drops (random world drops sit in several bosses' tables),
  - items listed for more than one dungeon,
  - the well-known world drops in WORLD below.
"""
import json, os, re, sys
HERE = os.path.dirname(os.path.abspath(__file__))
PAGE = os.path.join(HERE, "..", "..", "public", "index.html")
# File name -> the dungeon's name on the site (DUNGEONS in index.html).
NAMES = {
 "ragefire-chasm": "Ragefire Chasm", "hall-of-thanes": "Hall of Thanes", "ruins-of-lordaeron": "Ruins of Lordaeron",
 "the-deadmines": "The Deadmines", "wailing-caverns": "Wailing Caverns", "shadowfang-keep": "Shadowfang Keep",
 "blackfathom-deeps": "Blackfathom Deeps", "excavation-site-wetlands": "Excavation Site: Wetlands", "the-stockade": "The Stockade",
 "city-of-dalaran": "City of Dalaran", "gnomeregan": "Gnomeregan", "razorfen-kraul": "Razorfen Kraul",
 "scarlet-monastery-graveyard": "Scarlet Monastery: Graveyard", "scarlet-monastery-library": "Scarlet Monastery: Library",
 "the-drowned-city": "The Drowned City", "scarlet-monastery-armory": "Scarlet Monastery: Armory", "uldaman": "Uldaman",
 "razorfen-downs": "Razorfen Downs", "scarlet-monastery-cathedral": "Scarlet Monastery: Cathedral", "zul-farrak": "Zul'Farrak",
 "krol-dok-stronghold": "Krol'Dok Stronghold", "maraudon": "Maraudon", "alcaz-island-prison": "Alcaz Island Prison",
 "sunken-temple": "Sunken Temple", "blackrock-depths": "Blackrock Depths", "blackmaw-hold": "Blackmaw Hold",
 "lower-blackrock-spire": "Lower Blackrock Spire", "dire-maul-east": "Dire Maul: East", "stratholme-living": "Stratholme: Living",
 "stratholme-undead": "Stratholme: Undead", "scholomance": "Scholomance", "upper-blackrock-spire": "Upper Blackrock Spire",
 "dire-maul-west": "Dire Maul: West", "dire-maul-north": "Dire Maul: North"}
WORLD = """Rugged Spaulders|Sorcerer Collar|Inscribed Leather Breastplate|Bright Pants|Shimmering Armor|Emblazoned Buckler|Superior Buckler
|Scaled Leather Bracers|Superior Tunic|Lambent Scale Girdle|Glimmering Shield|Glimmering Mail Pauldrons|Glimmering Mail Greaves|Durable Tunic
|Emblazoned Chestpiece|Banded Helm|Band of Thorns|Mail Combat Belt|Nightsky Wristbands|Tundra Necklace|Embossed Plate Boots|Twilight Orb
|Imperial Leather Pants|Chromite Pauldrons|Imposing Gloves|Brutish Helmet|Ironhide Greaves|Keeper's Gloves|High Chief's Belt|Protector Ankleguards
|Bloodforged Chestpiece|Formidable Legguards|Lofty Sabatons|Brutish Breastplate|Branded Leather Bracers|Dusty Mail Boots|Captain's Buckler
|Jouster's Chestplate|Templar Boots|Crusader's Armor|Modest Armguards|Gallant's Wristguards|Grimy Metal Boots|Mud Stained Boots|Hyena Hide Belt
|Hyena Hide Jerkin|Tarnished Elven Ring|Elemental Plate Girdle|Scarab Plate Helm|Barrier Shield|Helm of the New Moon|Blade of the New Moon
|Tunic of the Crescent Moon|Boots of the Full Moon|Gauntlets of Deftness|Helm of the Executioner""".replace("\n", "")
WORLD = {w.strip().lower() for w in WORLD.split("|") if w.strip()}
# Wowhead item IDs and qualities from tools/item-ids (built from the wow-classic-items database).
IDS_FILE = os.path.join(HERE, "..", "item-ids", "ids.json")
IDS = json.load(open(IDS_FILE, encoding="utf-8")) if os.path.exists(IDS_FILE) else {}
rows, order = {}, 0
for f in sorted(os.listdir(os.path.join(HERE, "lists"))):
    key = f[:-4]
    if key not in NAMES: sys.exit(f"Unknown list {f}: add it to NAMES")
    for ln in open(os.path.join(HERE, "lists", f), encoding="utf-8"):
        if "|" not in ln: continue
        boss, item = [x.strip() for x in ln.split("|", 1)]
        order += 1
        rows.setdefault(item.lower(), []).append((NAMES[key], boss, item, order))
out, skipped = {}, {"several bosses": 0, "several dungeons": 0, "world drop": 0}
for k, src in rows.items():
    if k in WORLD: skipped["world drop"] += 1; continue
    if len({x[0] for x in src}) > 1: skipped["several dungeons"] += 1; continue
    if len({x[1] for x in src}) > 1: skipped["several bosses"] += 1; continue
    d, b, name, o = src[0]; out[k] = [d, b, name, o] + IDS.get(k, [])  # order keeps bosses in list order; then Wowhead ID and quality if known
js = "const DUNGEON_LOOT=" + json.dumps(dict(sorted(out.items())), ensure_ascii=False, separators=(",", ":")) + ";"
s = open(PAGE, encoding="utf-8").read()
a, b = "/* DUNGEON_LOOT:start (built by tools/dungeon-loot/build.py; edit the lists, not this line) */", "/* DUNGEON_LOOT:end */"
if a not in s: sys.exit("Markers not found in index.html")
s = s[:s.index(a) + len(a)] + "\n" + js + "\n" + s[s.index(b):]
open(PAGE, "w", encoding="utf-8").write(s)
per = {}
for v in out.values(): per[v[0]] = per.get(v[0], 0) + 1
print(f"{len(out)} items across {len(per)} dungeons ({sum(len(v) > 4 for v in out.values())} with Wowhead IDs); left out: {skipped}")
