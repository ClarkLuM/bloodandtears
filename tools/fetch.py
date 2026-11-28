import json, os, re, sys, time, urllib.parse, urllib.request
UA = {"User-Agent": "BloodAndTearsGuildSite/1.0 (art lookup for a guild fan site)"}
D = ["Ragefire Chasm","Wailing Caverns","Deadmines","Shadowfang Keep","Blackfathom Deeps","Stormwind Stockade","Razorfen Kraul","Gnomeregan",
     "Scarlet Monastery","Razorfen Downs","Uldaman","Zul'Farrak","Maraudon","Temple of Atal'Hakkar","Sunken Temple","Blackrock Depths","Dire Maul",
     "Blackrock Spire","Stratholme","Scholomance","Onyxia's Lair","Hyjal Summit","Hall of Thanes","Ruins of Lordaeron","Drowned City","Alcaz","Blackmaw Hold","Shaper's Terrace","Krol'dok","Dalaran","Excavation Site","Barrow Deeps"]
def get(u):
    r = urllib.request.urlopen(urllib.request.Request(u, headers=UA), timeout=40); return r.read()
API = "https://warcraft.wiki.gg/api.php?"
os.makedirs("out", exist_ok=True); found = {}
for d in D:
    hits = []
    for q in [f'"{d}" loading screen', f'{d} loadscreen', f'{d} loading']:
        try:
            j = json.loads(get(API + urllib.parse.urlencode({"action":"query","list":"search","srnamespace":6,"srsearch":q,"srlimit":12,"format":"json"})))
            hits += [x["title"] for x in j.get("query",{}).get("search",[])]
        except Exception as e: print("search fail", d, e)
        time.sleep(0.5)
    hits = [h for i,h in enumerate(hits) if h not in hits[:i] and re.search(r"load", h, re.I)][:8]
    found[d] = []
    for t in hits:
        try:
            j = json.loads(get(API + urllib.parse.urlencode({"action":"query","titles":t,"prop":"imageinfo","iiprop":"url|size","iiurlwidth":1600,"format":"json"})))
            info = next(iter(j["query"]["pages"].values()))["imageinfo"][0]
            u = info.get("thumburl") or info["url"]
            name = re.sub(r"[^A-Za-z0-9]+","_",t[5:])[:80]
            ext = os.path.splitext(urllib.parse.urlparse(u).path)[1] or ".jpg"
            open(f"out/{name}{ext}","wb").write(get(u))
            found[d].append({"title":t,"file":name+ext,"w":info.get("width"),"h":info.get("height"),"src":info.get("descriptionurl")})
        except Exception as e: print("file fail", t, e)
        time.sleep(0.3)
    print(d, [x["file"] for x in found[d]])
F = {"Hall of Thanes":"forever-custom/wow-forever-hall-of-thanes","Ruins of Lordaeron":"forever-custom/wow-forever-ruins-of-lordaeron","Excavation Site: Wetlands":"forever-custom/wow-forever-excavation-site",
 "City of Dalaran":"forever-custom/wow-forever-city-of-dalaran","The Drowned City":"articles/auto/wow-forever-drowned-city","Krol'Dok Stronghold":"articles/auto/wow-forever-kroldok-stronghold",
 "Alcaz Island Prison":"articles/auto/wow-forever-alcaz-prison","Blackmaw Hold":"articles/auto/wow-forever-blackmaw-hold","Shaper's Terrace":"articles/auto/wow-forever-shapers-terrace"}
for d,k in F.items():
    u = f"https://conquestcapped.com/guides/image/catalog/{k}-loading-screen.png"
    try:
        b = get(u); n = "cc_"+re.sub(r"[^A-Za-z0-9]+","_",d)+".png"; open("out/"+n,"wb").write(b); found.setdefault("cc:"+d,[]).append({"file":n,"src":u}); print("cc ok", d, len(b))
    except Exception as e: print("cc fail", d, e)
json.dump(found, open("out/found.json","w"), indent=1)
