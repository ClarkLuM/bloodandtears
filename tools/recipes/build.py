"""Builds public/recipes.json from lists/*.txt for the Professions page's "Who can make it?" search.

Each list is one profession, one recipe per line: "Recipe|learn skill|source"
  learn skill: the skill needed to learn it; a trailing * means the source site estimated it
  source: A = learned automatically with the profession, T = taught by the trainer,
          R = needs a recipe item (drop, vendor, quest or reputation)
Source: metabot.gg's WoW Forever profession pages (metabot.gg/en/wow-forever/professions), November 2026.
To fix a recipe, edit its list and run  python3 tools/recipes/build.py  from the project folder.
"""
import json, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "..", "..", "public", "recipes.json")
NAMES = {"alchemy": "Alchemy", "blacksmithing": "Blacksmithing", "cooking": "Cooking", "enchanting": "Enchanting",
         "engineering": "Engineering", "first-aid": "First Aid", "leatherworking": "Leatherworking", "mining": "Mining",
         "tailoring": "Tailoring"}
RANK = {"A": 0, "T": 1, "R": 2}
# Wowhead item IDs and qualities from tools/item-ids (built from the wow-classic-items database).
IDS_FILE = os.path.join(HERE, "..", "item-ids", "ids.json")
IDS = json.load(open(IDS_FILE, encoding="utf-8")) if os.path.exists(IDS_FILE) else {}
# WoW Forever's own new recipes make items the classic database doesn't have; their IDs are in forever-crafted.txt.
FOREVER_FILE = os.path.join(HERE, "..", "item-ids", "forever-crafted.txt")
if os.path.exists(FOREVER_FILE):
    for ln in open(FOREVER_FILE, encoding="utf-8"):
        if ln.startswith("#") or ln.count("|") != 2: continue
        i, q, n = ln.rstrip("\n").split("|")
        IDS.setdefault(n.strip().lower(), [int(i), int(q)])
# Enchants are spells, not items. They're stored as negative IDs, which the site turns into Wowhead spell links.
ENCH_FILE = os.path.join(HERE, "..", "item-ids", "forever-enchants.txt")
if os.path.exists(ENCH_FILE):
    for ln in open(ENCH_FILE, encoding="utf-8"):
        if ln.startswith("#") or ln.count("|") != 1: continue
        i, n = ln.rstrip("\n").split("|")
        IDS.setdefault("enchant " + n.strip().lower(), [-int(i), 1])
# Wowhead's WoW Forever profession pages (saved to wowhead-forever.json, 14 November 2026): the learn level, skill-up
# colours, reagents and where the recipe comes from. The site loads the details from public/recipe-info.json when a
# recipe's "Reagents and recipe" panel is opened.
WH_FILE = os.path.join(HERE, "wowhead-forever.json")
WH = json.load(open(WH_FILE, encoding="utf-8")) if os.path.exists(WH_FILE) else {"prof": {}, "items": {}, "zones": {}}
def wh_of(prof, name):
    rows = {k.lower(): v for k, v in WH["prof"].get(prof, {}).items()}
    o = rows.get(name.lower())
    if not o and prof == "Mining" and name.endswith(" Bar"): o = rows.get("smelt " + name[:-4].lower())
    return o
INFO_OUT = os.path.join(HERE, "..", "..", "public", "recipe-info.json")
info, used_items, used_zones = {}, set(), set()
out, total = {}, 0
for f in sorted(os.listdir(os.path.join(HERE, "lists"))):
    key = f[:-4]
    if key not in NAMES: sys.exit(f"Unknown list {f}: add it to NAMES")
    best = {}
    for n, ln in enumerate(open(os.path.join(HERE, "lists", f), encoding="utf-8"), 1):
        ln = ln.strip()
        if not ln: continue
        parts = [x.strip() for x in ln.split("|")]
        if len(parts) != 3 or parts[2] not in RANK: sys.exit(f"{f} line {n}: expected 'Recipe|skill|A/T/R', got {ln!r}")
        name, sk, src = parts
        est = sk.endswith("*"); sk = sk.rstrip("*")
        if not sk.isdigit(): continue
        wh = wh_of(NAMES[key], name)
        if wh and wh.get("l"): sk, est = str(wh["l"]), False  # Wowhead's learn level beats the estimate
        row = [name, int(sk), src, 1 if est else 0] + IDS.get(name.lower(), [])  # then Wowhead item ID and quality if known
        if wh:
            ri = wh.get("ri")
            info[NAMES[key] + "|" + name] = [wh["s"], wh.get("c") or [], wh.get("r") or [], wh.get("tc") or 0, wh.get("src") or [],
                                             ri[:3] + [[[t, n, z] for t, n, z in ri[3]]] if ri else None]
            used_items.update(str(r[0]) for r in wh.get("r") or [])
            if ri: used_zones.update(str(z) for _, _, z in ri[3] if z)
        k = name.lower(); old = best.get(k)
        # The same recipe listed twice (trainer and recipe item, say): keep the easiest way to get it.
        if not old or (RANK[src], row[1]) < (RANK[old[2]], old[1]): best[k] = row
    rows = sorted(best.values(), key=lambda r: (r[1], r[0]))
    out[NAMES[key]] = rows; total += len(rows)
json.dump({"source": "metabot.gg WoW Forever profession pages, Nov 2026", "recipes": out}, open(OUT, "w", encoding="utf-8"),
          ensure_ascii=False, separators=(",", ":"))
json.dump({"recipes": info, "items": {i: WH["items"][i] for i in sorted(used_items) if i in WH["items"]},
           "zones": {z: WH["zones"][z] for z in sorted(used_zones) if z in WH["zones"]}},
          open(INFO_OUT, "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))
print(f"{len(info)} recipes with reagents and sources -> public/recipe-info.json ({os.path.getsize(INFO_OUT)//1024} KB)")
print(f"{sum(len(r) > 4 for rows in out.values() for r in rows)} with Wowhead IDs")
print(f"{total} recipes across {len(out)} professions -> public/recipes.json ({os.path.getsize(OUT)//1024} KB)")
for p, rows in out.items(): print(f"  {p}: {len(rows)} ({sum(r[2]=='T' for r in rows)} trainer, {sum(r[2]=='A' for r in rows)} automatic)")
