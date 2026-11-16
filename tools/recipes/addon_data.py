#!/usr/bin/env python3
"""Writes the recipe data block at the end of the Scribe addon's Lua file, from public/recipes.json and
public/recipe-info.json: what each recipe makes (Item.ids), each profession's recipes with skill, source and
reagents (Item.rec), and the reagents' names (Item.rn). Run after build.py when the recipe data changes."""
import json, os, re
ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
LUA = os.path.join(ROOT, "addon", "BloodAndTearsScribe", "BloodAndTearsScribe.lua")
MARK = "-- What each recipe makes (from the site's recipes.json)"
recipes = json.load(open(os.path.join(ROOT, "public", "recipes.json")))["recipes"]
info = json.load(open(os.path.join(ROOT, "public", "recipe-info.json")))
def q(s): return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'
ids, rec, used = {}, {}, set()
for prof, rows in recipes.items():
    out = []
    for r in rows:
        name, skill, src = r[0], int(r[1] or 0), r[2] if r[2] in ("A", "T", "R") else ""
        assert "~" not in name and "\n" not in name and "]==]" not in name, name
        if len(r) > 4 and isinstance(r[4], int) and r[4] != 0 and name not in ids: ids[name] = r[4]
        ri = info["recipes"].get(prof + "|" + name)
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
block = (MARK + ": an item id, or a negative spell id for enchants.\n"
    "-- Used for the recipe search tooltips and icons when nobody has shared that recipe's item yet.\n"
    "-- This whole block is written by tools/recipes/addon_data.py; don't edit it by hand.\n"
    "Item.ids = {\n" + table(["[" + q(n) + "]=" + str(i) for n, i in sorted(ids.items())], 6) + "\n}\n"
    "-- Each profession's recipes, one per line: name~skill needed~source (T trainer, R recipe item, A automatic)~reagents.\n"
    "Item.rec = {\n" + "\n".join(" [" + q(p) + "]=[==[\n" + s + "]==]," for p, s in rec.items()) + "\n}\n"
    "-- Reagent names by item id.\n"
    "Item.rn = {\n" + table(["[" + str(i) + "]=" + q(n) for i, n in names.items()], 5) + "\n}\n")
s = open(LUA, encoding="utf-8").read()
i = s.index(MARK)
open(LUA, "w", encoding="utf-8").write(s[:i] + block)
print(f"{len(ids)} item ids, {sum(len(v.splitlines()) for v in rec.values())} recipes, {len(names)} reagent names ({len(used) - len(names)} unnamed)")
