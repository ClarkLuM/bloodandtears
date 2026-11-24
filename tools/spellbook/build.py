"""Builds public/spellbook.json, the class abilities the character page's Spellbook shows.

Source: tools/spellbook/class-abilities.json, saved from Wowhead's WoW Forever talent calculator data (talents-classic:
abilities, abilitySkills, abilitySkillNames) plus each spell's Wowhead tooltip (name, icon, text). To refresh it, save
that data again in the same shape and re-run this script.
Each class gets its schools (Arms, Fury...) and its spells as [name, level, school index, icon, rank, of ranks,
cost line, description, spell id, from a talent (1/0: rank 1 is the talent itself)], sorted by level.
"""
import json, os, re
HERE = os.path.dirname(os.path.abspath(__file__))
CLASSES = {"1": "Warrior", "2": "Paladin", "3": "Hunter", "4": "Rogue", "5": "Priest", "7": "Shaman", "8": "Mage", "9": "Warlock", "11": "Druid"}
src = json.load(open(os.path.join(HERE, "class-abilities.json")))
tal = json.load(open(os.path.join(HERE, "..", "..", "public", "talent-trees.json")))
spells = src["spells"]
# Abilities that start as a talent (Mortal Strike, Pyroblast): Wowhead lists their later ranks, rank 1 is the talent.
talent_names = {cls: {x[0] for t in trees for x in t["talents"]} for cls, trees in tal["classes"].items()}
def calc(m):
  e = m.group(1)
  if not re.fullmatch(r"[\d\s+\-*/().]+", e): return m.group(0)
  try: v = eval(e, {"__builtins__": {}}); return str(round(v)) if abs(v - round(v)) < 1e-9 else str(round(v, 1))
  except Exception: return m.group(0)
REQ = re.compile(r"^Requires ((?:[\w' ]*?(?:Stance|Form|Weapon|Stealth|Shields?|Aura|Totem)(?:, | or )?)+)\s*")
def parse(text, name):
  t = re.sub(r"\[([^\[\]]*)\]", calc, text)
  m = list(re.finditer(r"Requires level \d+ ?", t))
  head, rest = (t[:m[-1].start()], t[m[-1].end():]) if m else (t, "")
  head = re.sub(r"\s+", " ", head).strip()
  if head.startswith(name): head = head[len(name):].strip()
  head = re.sub(r"Requires \w+( \w+)?$", "", head).strip()
  head = re.sub(r"^(Rank \d+ )?(Level \d+ )?", "", head).strip()
  needs, out = [], []
  for line in rest.split("\n"):
    line = re.sub(r"\s+", " ", line).strip()
    while True:
      r = REQ.match(line)
      if not r: break
      needs.append(r.group(1).strip().rstrip(",")); line = line[r.end():]
    if line: out.append(line)
  needs = [n for n in needs if n not in ("Melee Weapon", "Ranged Weapon")] or []
  meta = head + (" · Needs " + ", ".join(needs) if needs else "")
  return meta[:90], " ".join(out)[:420]
out = {"source": src.get("source", ""), "fetched": src.get("fetched", ""), "classes": {}}
names = src["abilitySkillNames"]
for cid, cls in CLASSES.items():
  schools = src["abilitySkills"].get(cid, [])
  rows, seen = [], set()
  for a in src["abilities"].get(cid, []):
    sp = spells.get(str(a["id"]))
    if not sp or a["id"] in seen or (sp[0], a["level"]) in seen: continue
    seen.add(a["id"]); seen.add((sp[0], a["level"]))
    meta, desc = parse(sp[2], sp[0])
    if sp[0] in talent_names.get(cls, set()) and not meta: continue  # a passive talent, not something you cast
    si = schools.index(a["skill"]) if a["skill"] in schools else -1
    rows.append([sp[0], int(a["level"]), si, sp[1] or "", 0, 0, meta, desc, a["id"], 1 if sp[0] in talent_names.get(cls, set()) else 0])
  rows.sort(key=lambda r: (r[1], r[0]))
  by = {}
  for r in rows: by.setdefault(r[0], []).append(r)
  for lst in by.values():
    for i, r in enumerate(lst): r[4], r[5] = i + 1 + r[9], len(lst) + r[9]
  out["classes"][cls] = {"schools": [names.get(str(s), str(s)) for s in schools], "spells": rows}
json.dump(out, open(os.path.join(HERE, "..", "..", "public", "spellbook.json"), "w"), separators=(",", ":"), ensure_ascii=False)
print("spellbook.json:", {c: len(v["spells"]) for c, v in out["classes"].items()})
