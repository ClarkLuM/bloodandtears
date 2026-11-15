# Builds public/azeroth.json from geo.py: python tools/maps/build.py
import json,math,hashlib,sys,os
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from geo import KAL,EK,ZEP,WORLD,SHORT
def rnd(*k):return int.from_bytes(hashlib.md5(repr(k).encode()).digest()[:4],"big")/2**32-.5
def frac(p,q,amp,depth,key):
    if depth==0:return []
    mx,my=(p[0]+q[0])/2,(p[1]+q[1])/2;dx,dy=q[0]-p[0],q[1]-p[1];ln=math.hypot(dx,dy)
    if ln<1.2:return []
    o=rnd(key,depth,round(mx,1),round(my,1))*ln*amp;m=(mx-dy/ln*o,my+dx/ln*o)
    return frac(p,m,amp,depth-1,key)+[m]+frac(m,q,amp,depth-1,key)
def edge(p,q,amp,depth):
    a,b=(p,q) if p<q else (q,p)
    pts=frac(a,b,amp,depth,(a,b));return pts if (a,b)==(p,q) else pts[::-1]
SEA=lambda p:p in SEAPTS
SEAPTS=set()
def ring(L,amp,depth):
    L=[tuple(p) for p in L];out=[]
    for i in range(len(L)):
        p,q=L[i],L[(i+1)%len(L)]
        out+=[p]+([] if SEA(p) or SEA(q) else edge(p,q,amp,depth))
    return "M"+"L".join(f"{x:.0f},{y:.0f}" if False else f"{round(x,1):g},{round(y,1):g}" for x,y in out)+"Z"
def T(c,p):return (round(p[0]*c["scale"]+c["ox"],1),round(p[1]*c["scale"]+c["oy"],1))
def cont(c):
    tr=lambda L:[T(c,p) for p in L]
    land=ring(tr(c["coast"]),.22,3)+(ring(tr(c["coast2"]),.22,3) if "coast2" in c else "")+"".join(ring(tr(I),.18,3) for I in c["isles"])
    lakes="".join(ring(tr(L),.15,2) for L in c["lakes"] if L[0]!=L[1])
    zones={}
    for L in c["z"].values():
        for p in L:
            if p[0] in(-50,500) or p[1] in(-50,900,40,60): SEAPTS.add(T(c,p))
    for k,L in c["z"].items():
        lab=c["lab"][k];x,y=T(c,lab[:2])
        o=lab[2] if len(lab)>2 and isinstance(lab[2],dict) else {}
        zones[k]={"d":ring(tr(L),.2,3),"x":x,"y":y,"s":SHORT.get(k,k)}
        if o.get("lines"):zones[k]["l"]=o["lines"]
        if o.get("fs"):zones[k]["f"]=o["fs"]
        if k in c["closed"]:zones[k]["closed"]=1
    return {"land":land,"lakes":lakes,"zones":zones,"dg":{k:T(c,v) for k,v in c.get("dg",{}).items()},"cities":{k:list(T(c,v[:2]))+([v[2]] if len(v)>2 else []) for k,v in c["cities"].items()}}
out={"w":400,"h":650,"kalimdor":cont(KAL),"ek":cont(EK),"zephras":cont(ZEP),"world":WORLD}
import os
json.dump(out,open(os.path.join(os.path.dirname(os.path.abspath(__file__)),"..","..","public","azeroth.json"),"w"),separators=(",",":"))
print(len(json.dumps(out,separators=(",",":"))))
