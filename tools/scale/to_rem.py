"""Turns pixel spacing, sizes and text in public/index.html into rem, so the site grows with the browser's text size.

1rem = 16px at the browser's normal setting, so the site looks exactly the same there; someone who sets a bigger
default text size gets bigger text and roomier spacing to match. Run it after adding styles written in px:
    python3 tools/scale/to_rem.py
Left in px on purpose: borders and hairlines (1-2px), rounded corners, shadows, outlines, transforms and filters,
and the screen-width breakpoints in @media / @container (those should stay tied to the screen, not the text).
"""
import os, re, sys
PAGE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "public", "index.html")
SCALE = {"gap", "row-gap", "column-gap", "font-size", "line-height", "font", "flex", "flex-basis",
         "padding", "padding-top", "padding-right", "padding-bottom", "padding-left", "padding-block", "padding-inline",
         "margin", "margin-top", "margin-right", "margin-bottom", "margin-left", "margin-block", "margin-inline",
         "width", "min-width", "max-width", "height", "min-height", "max-height", "inset", "top", "right", "bottom", "left",
         "grid-template-columns", "grid-template-rows", "grid-auto-rows", "grid-auto-columns", "background-size", "scroll-margin-top"}
PX = re.compile(r"(?<![\w.$#-])(-?)(\d+(?:\.\d+)?)px\b")
def rem(m):
    sign, v = m.group(1), float(m.group(2))
    if v <= 2: return m.group(0)
    r = f"{v/16:.4f}".rstrip("0").rstrip(".")
    return f"{sign}{r.lstrip('0') if r.startswith('0.') else r}rem"
DECL = re.compile(r"(?P<prop>[a-z-]+)\s*:\s*(?P<val>[^;{}\"`]*)")
def convert_decls(text):
    def one(m):
        if m.group("prop") not in SCALE: return m.group(0)
        return m.group("prop") + ":" + PX.sub(rem, m.group("val")) if ":" in m.group(0) else m.group(0)
    return DECL.sub(lambda m: m.group("prop") + m.group(0)[len(m.group("prop")):m.group(0).index(":") + 1] + PX.sub(rem, m.group("val")) if m.group("prop") in SCALE else m.group(0), text)
s = open(PAGE, encoding="utf-8").read()
a, b = s.index("<style>"), s.index("</style>")
css = s[a:b]
# Keep @media / @container / @supports conditions as they are.
keep = []
css = re.sub(r"@(media|container|supports)[^{]*\{", lambda m: keep.append(m.group(0)) or f"\x00{len(keep)-1}\x00{{", css)
css = convert_decls(css)
css = re.sub(r"\x00(\d+)\x00\{", lambda m: keep[int(m.group(1))], css)
js = s[b:]
n_js = 0
def inline(m):
    global n_js
    out = convert_decls(m.group(2)); n_js += out != m.group(2)
    return m.group(1) + out + m.group(3)
js = re.sub(r'(style:")([^"]*)(")', inline, js)
js = re.sub(r"(style:`)([^`]*)(`)", inline, js)
s2 = s[:a] + css + js
open(PAGE, "w", encoding="utf-8").write(s2)
left = [m.group(0) for m in re.finditer(r"[a-z-]+:[^;{}]*?\b\d+px", s2[a:a + len(css)])]
print(f"stylesheet: px values left {len(re.findall(r'(?<![\\w.])[3-9]px|\\d\\d+px', css))} (borders, radii, shadows, breakpoints); inline styles changed: {n_js}")
