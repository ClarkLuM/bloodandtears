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
        row = [name, int(sk), src, 1 if est else 0] + IDS.get(name.lower(), [])  # then Wowhead item ID and quality if known
        k = name.lower(); old = best.get(k)
        # The same recipe listed twice (trainer and recipe item, say): keep the easiest way to get it.
        if not old or (RANK[src], row[1]) < (RANK[old[2]], old[1]): best[k] = row
    rows = sorted(best.values(), key=lambda r: (r[1], r[0]))
    out[NAMES[key]] = rows; total += len(rows)
json.dump({"source": "metabot.gg WoW Forever profession pages, Nov 2026", "recipes": out}, open(OUT, "w", encoding="utf-8"),
          ensure_ascii=False, separators=(",", ":"))
print(f"{sum(len(r) > 4 for rows in out.values() for r in rows)} with Wowhead IDs")
print(f"{total} recipes across {len(out)} professions -> public/recipes.json ({os.path.getsize(OUT)//1024} KB)")
for p, rows in out.items(): print(f"  {p}: {len(rows)} ({sum(r[2]=='T' for r in rows)} trainer, {sum(r[2]=='A' for r in rows)} automatic)")
