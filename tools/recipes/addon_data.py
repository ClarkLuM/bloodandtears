#!/usr/bin/env python3
"""Writes the Scribe addon's RecipeData.lua from public/recipes.json and public/recipe-info.json: what each recipe
makes (ids), each profession's recipes with skill, source and reagents (rec), the reagents' names (rn), and where to get
each recipe (where: "Sold by X (Zone)", "Drops in Zone", "A reward from Quest"...), worded like the site's recipe panel. The main
file reads them from the addon's shared table at load. Run after build.py when the recipe data changes."""
import json, os, re
ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
LUA = os.path.join(ROOT, "addon", "BloodAndTearsScribe", "RecipeData.lua")
recipes = json.load(open(os.path.join(ROOT, "public", "recipes.json")))["recipes"]
info = json.load(open(os.path.join(ROOT, "public", "recipe-info.json")))
def q(s): return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'
ZONES = info.get("zones", {})
def money(c):
    c = int(c or 0); g, s_, k = c // 10000, c // 100 % 100, c % 100
    return " ".join(x for x in [f"{g}g" if g else "", f"{s_}s" if s_ else "", f"{k}c" if k or not (g or s_) else ""] if x)
# Zones the site's list leaves out (the site only stores zone names it uses on its own pages)
ZONES.update({k: v for k, v in {"12": "Elwynn Forest", "38": "Loch Modan", "40": "Westfall", "44": "Redridge Mountains",
    "141": "Teldrassil", "148": "Darkshore", "1519": "Stormwind City", "1537": "Ironforge", "1657": "Darnassus",
    "36": "Alterac Mountains", "41": "Deadwind Pass", "2057": "Scholomance", "2017": "Stratholme"}.items() if k not in ZONES})
def where_text(prof, src, ri_full):
    """Where to get a recipe, as one short line. Each source says what it is: "sold by", "drops from", "quest:"."""
    if src == "A": return "Known automatically"
    tc = ri_full[3] if ri_full else 0
    if src == "T": return "From any " + prof + " trainer" + (" for " + money(tc) if tc else "")
    ri = ri_full[5] if ri_full else None
    sc = set((ri[2] if ri and ri[2] else (ri_full[4] if ri_full else [])) or [])
    vendor, drop = 5 in sc, bool(sc & {2, 16})
    parts = []
    for t, n, z in (ri[3] if ri else [])[:3]:
        zone = ZONES.get(str(z)) if z else None
        at = f" ({zone})" if zone else ""
        if t == 5 and n: parts.append(f"quest: {n}")
        elif t == 6 and n: parts.append(f"from {n}")
        elif n and vendor and not drop: parts.append(f"sold by {n}{at}")
        elif n and drop and not vendor: parts.append(f"drops from {n}{at}")
        elif n: parts.append(f"{n}{at}")  # both a vendor and a drop: the data doesn't say which NPC does which
        elif zone: parts.append(f"drops in {zone}")
    if parts:
        text = " or ".join(parts)
        return text[0].upper() + text[1:]
    if vendor: return "Sold by a vendor"
    if drop: return "Drops from monsters"
    if 4 in sc: return "A quest reward"
    return ""
ids, rec, used, where = {}, {}, set(), {}
for prof, rows in recipes.items():
    out = []
    for r in rows:
        name, skill, src = r[0], int(r[1] or 0), r[2] if r[2] in ("A", "T", "R") else ""
        assert "~" not in name and "\n" not in name and "]==]" not in name, name
        if len(r) > 4 and isinstance(r[4], int) and r[4] != 0 and name not in ids: ids[name] = r[4]
        ri = info["recipes"].get(prof + "|" + name)
        w = where_text(prof, src, ri)
        if w: where[prof + "|" + name] = w
        reag = [(int(a), int(b)) for a, b in (ri[2] if ri and isinstance(ri[2], list) else [])]
        used.update(a for a, _ in reag)
        out.append(f"{name}~{skill}~{src}~" + ",".join(f"{a}:{b}" for a, b in reag))
    rec[prof] = "\n".join(out)
def table(pairs, per):
    lines, cur = [], []
    for p in pairs:
        cur.append(p)
        if len(cur) == per: lines.append(" " + ",".join(cur) + ","); cur = []
    if cur: lines.append(" " + ",".join(cur) + ",")
    return "\n".join(lines)
names = {i: info["items"][str(i)][0] for i in sorted(used) if str(i) in info["items"]}
block = ("-- Blood and Tears Scribe: the site's recipe data. Written by tools/recipes/addon_data.py; don't edit it by hand.\n"
    "local _, ns = ...\n"
    "if not ns then return end\n"
    "-- What each recipe makes: an item id, or a negative spell id for enchants.\n"
    "ns.ids = {\n" + table(["[" + q(n) + "]=" + str(i) for n, i in sorted(ids.items())], 6) + "\n}\n"
    "-- Each profession's recipes, one per line: name~skill needed~source (T trainer, R recipe item, A automatic)~reagents.\n"
    "ns.rec = {\n" + "\n".join(" [" + q(p) + "]=[==[\n" + s + "]==]," for p, s in rec.items()) + "\n}\n"
    "-- Where to get each recipe, by \"Profession|Recipe\".\n"
    "ns.where = {\n" + "\n".join(" [" + q(k) + "]=" + q(v) + "," for k, v in sorted(where.items())) + "\n}\n"
    "-- Reagent names by item id.\n"
    "ns.rn = {\n" + table(["[" + str(i) + "]=" + q(n) for i, n in names.items()], 5) + "\n}\n")
open(LUA, "w", encoding="utf-8").write(block)
print(f"{len(ids)} item ids, {sum(len(v.splitlines()) for v in rec.values())} recipes, {len(names)} reagent names ({len(used) - len(names)} unnamed), {len(where)} with where to get them")
