"""Builds public/talent-trees.json, the WoW Forever talent tree layouts the character page draws.

Source: tools/talents/wowhead-forever-talents.json, saved from Wowhead's WoW Forever talent calculator data
(talents-classic). To refresh it, save that data again in the same shape and re-run this script.
Each talent becomes [name, row, col, max rank, icon, required talent index (or -1), rank 1 text, max rank text,
rank 1 spell id, max rank spell id]. Trees are listed per class in the game's order.
"""
import json, os, re
HERE = os.path.dirname(os.path.abspath(__file__))
ORDER = {
  "Warrior": [("WarriorArms", "Arms"), ("WarriorFury", "Fury"), ("WarriorProtection", "Protection")],
  "Paladin": [("PaladinHoly", "Holy"), ("PaladinProtection", "Protection"), ("PaladinCombat", "Retribution")],
  "Hunter": [("HunterBeastMastery", "Beast Mastery"), ("HunterMarksmanship", "Marksmanship"), ("HunterSurvival", "Survival")],
  "Rogue": [("RogueAssassination", "Assassination"), ("RogueCombat", "Combat"), ("RogueSubtlety", "Subtlety")],
  "Priest": [("PriestDiscipline", "Discipline"), ("PriestHoly", "Holy"), ("PriestShadow", "Shadow")],
  "Shaman": [("ShamanElementalCombat", "Elemental"), ("ShamanEnhancement", "Enhancement"), ("ShamanRestoration", "Restoration")],
  "Mage": [("MageArcane", "Arcane"), ("MageFire", "Fire"), ("MageFrost", "Frost")],
  "Warlock": [("WarlockCurses", "Affliction"), ("WarlockSummoning", "Demonology"), ("WarlockDestruction", "Destruction")],
  "Druid": [("DruidBalance", "Balance"), ("DruidFeralCombat", "Feral Combat"), ("DruidRestoration", "Restoration")],
}
src = json.load(open(os.path.join(HERE, "wowhead-forever-talents.json")))
trees = src["trees"]
# Wowhead's text has markup for plurals ("<!--singular:Point:Points-->Point<!--singular-->") and the odd tag: keep the words.
def text(v): return re.sub(r"\s+", " ", re.sub(r"<[^>]*>", "", re.sub(r"<!--.*?-->", "", v))).strip() if isinstance(v, str) else v
def clean(t): return [text(v) if i in (6, 7) else v for i, v in enumerate(t)]
out = {"source": src.get("source", ""), "fetched": src.get("fetched", ""), "classes": {}}
for cls, list_ in ORDER.items():
  out["classes"][cls] = [{"name": nm, "talents": [clean(t[:10]) for t in trees[key]]} for key, nm in list_]
json.dump(out, open(os.path.join(HERE, "..", "..", "public", "talent-trees.json"), "w"), separators=(",", ":"), ensure_ascii=False)
print("talent-trees.json:", sum(len(t["talents"]) for c in out["classes"].values() for t in c), "talents")
