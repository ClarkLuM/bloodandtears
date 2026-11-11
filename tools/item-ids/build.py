"""Finds Wowhead item IDs for every item in the dungeon loot and recipe lists, so the site can link them with tooltips.

The IDs come from the open-source wow-classic-items database (npm package "wow-classic-items", data/json/data.json),
which has every classic item with its ID and quality. WoW Forever keeps classic IDs, so Wowhead's Forever tooltips
work with them. Items WoW Forever added itself aren't in it; the site links those to a Wowhead search instead.

Run from the project folder after changing a list:
  npm pack wow-classic-items && mkdir -p /tmp/wci && tar -xzf wow-classic-items-*.tgz -C /tmp/wci
  python3 tools/item-ids/build.py /tmp/wci/package/data/json/data.json
then rebuild:  python3 tools/dungeon-loot/build.py  and  python3 tools/recipes/build.py
"""
import json, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
TOOLS = os.path.dirname(HERE)
if len(sys.argv) < 2: sys.exit(__doc__)
Q = {"Poor": 0, "Common": 1, "Uncommon": 2, "Rare": 3, "Epic": 4, "Legendary": 5, "Artifact": 6}
db = {}
for i in json.load(open(sys.argv[1], encoding="utf-8")):
    k = str(i.get("name", "")).strip().lower()
    # The database also has later expansions; when a name repeats, the original (lowest ID) is the one WoW Forever uses.
    if k and (k not in db or i["itemId"] < db[k]["itemId"]): db[k] = i
want = set()
for folder, col in (("dungeon-loot", 1), ("recipes", 0)):
    for f in os.listdir(os.path.join(TOOLS, folder, "lists")):
        for ln in open(os.path.join(TOOLS, folder, "lists", f), encoding="utf-8"):
            parts = [x.strip() for x in ln.replace("|", "\x00").split("\x00")]
            if len(parts) >= 2: want.add(parts[col].lower())
out = {k: [db[k]["itemId"], Q.get(db[k].get("quality"), 1)] for k in sorted(want) if k in db}
json.dump(out, open(os.path.join(HERE, "ids.json"), "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))
print(f"{len(out)} of {len(want)} item names have IDs -> tools/item-ids/ids.json")
