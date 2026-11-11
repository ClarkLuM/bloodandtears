"""Draws the site icon (public/icon.svg) and the round header logo (public/logo.svg) from the in-game guild logo
screenshot (tools/icon/ingame-logo.png): the gingerbread man's outline is traced from its pixels, smoothed and made
symmetric; the face, bow tie, buttons and marks are drawn as clean lines in the same places.
Run from the project folder:  python3 tools/icon/make_icon.py
Then remake the PNGs (icon-192.png, icon-512.png) from icon.svg, and the link preview with  node tools/icon/make_og.js
Needs numpy, scipy, scikit-image and Pillow."""
import os
HERE=os.path.dirname(os.path.abspath(__file__));ROOT=os.path.dirname(os.path.dirname(HERE))
import numpy as np,sys
from PIL import Image
from scipy import ndimage
from skimage import measure
im=np.asarray(Image.open(os.path.join(HERE,'ingame-logo.png')).convert('RGB')).astype(float)
r,g,b=im[...,0],im[...,1],im[...,2]
ging=(r>150)&(g>100)&(b<120)&(r-b>70)
lab,n=ndimage.label(ging);sizes=ndimage.sum(ging,lab,range(1,n+1));body=lab==1+int(np.argmax(sizes))
filled=ndimage.binary_fill_holes(body)
ys,xs=np.nonzero(filled);cx=(xs.min()+xs.max()+1)/2;cy=(ys.min()+ys.max()+1)/2;h=ys.max()-ys.min()+1
S=345/h;Z=8;OY=258
f=filled.astype(float);mid=cx-0.5;mir=np.clip(np.round(2*mid-np.arange(f.shape[1])).astype(int),0,f.shape[1]-1)
up=ndimage.gaussian_filter(ndimage.zoom((f+f[:,mir])/2,Z,order=1),16)
c=max(measure.find_contours(up,0.5),key=len);c=measure.approximate_polygon(c,tolerance=5)
P=[((p[1]/Z-cx)*S+256,(p[0]/Z-cy)*S+OY) for p in c]
X=lambda x:(x-cx)*S+256;Y=lambda y:(y-cy)*S+OY
def path(pts):
  P=pts[:-1] if pts[0]==pts[-1] else pts;n=len(P);d=f"M{P[0][0]:.1f} {P[0][1]:.1f}"
  for i in range(n):
    p0,p1,p2,p3=P[i-1],P[i],P[(i+1)%n],P[(i+2)%n]
    c1=(p1[0]+(p2[0]-p0[0])/6,p1[1]+(p2[1]-p0[1])/6);c2=(p2[0]-(p3[0]-p1[0])/6,p2[1]-(p3[1]-p1[1])/6)
    d+=f"C{c1[0]:.1f} {c1[1]:.1f} {c2[0]:.1f} {c2[1]:.1f} {p2[0]:.1f} {p2[1]:.1f}"
  return d+"Z"
def pt(x,y):return f"{X(x):.1f} {Y(y):.1f}"
C='#9a0628';w=S*2.2
# Angry eyes: a round eye with its top cut off at a slant (low on the inside), under a thick slanted brow.
def eye(ex,ey,side):
  rx=S*2.25;x0,y0=X(ex),Y(ey)
  # clip: keep the part below a line from (outer, high) to (inner, low)
  inner=1 if side=="L" else -1
  return (f'<clipPath id="e{side}"><path d="M{x0-rx*1.6:.1f} {y0-rx*(0.55 if side=="L" else -0.25)*1:.1f}'
          f'L{x0+rx*1.6:.1f} {y0-rx*(-0.25 if side=="L" else 0.55):.1f}L{x0+rx*1.6:.1f} {y0+rx*2:.1f}L{x0-rx*1.6:.1f} {y0+rx*2:.1f}Z"/></clipPath>'
          f'<ellipse cx="{x0:.1f}" cy="{y0:.1f}" rx="{rx:.1f}" ry="{rx*1.05:.1f}" clip-path="url(#e{side})"/>')
eyes=f'<g fill="{C}">{eye(49.5,34.2,"L")}{eye(55.7,34.2,"R")}</g>'
brows=f'<path d="M{pt(46.6,29.6)}L{pt(51.6,32.4)}M{pt(58.6,29.6)}L{pt(53.6,32.4)}"/>'
feat=f'''<g fill="none" stroke="{C}" stroke-width="{w:.1f}" stroke-linecap="round" stroke-linejoin="round">
{brows}
<path d="M{pt(48.4,41.6)}Q{pt(52.6,37.4)} {pt(56.8,41.6)}"/>
<path d="M{pt(37.4,46.6)}Q{pt(33.8,51.2)} {pt(35.2,57.6)}M{pt(67.8,46.6)}Q{pt(71.4,51.2)} {pt(70.0,57.6)}"/>
<path d="M{pt(35.4,84.0)}L{pt(42.8,93.4)}M{pt(69.8,84.0)}L{pt(62.4,93.4)}"/></g>
{eyes}
<g fill="{C}" stroke="{C}" stroke-linejoin="round"><path d="M{pt(47.4,48.0)}L{pt(52.6,51.0)}L{pt(57.8,48.0)}L{pt(57.8,54.0)}L{pt(52.6,51.0)}L{pt(47.4,54.0)}Z" stroke-width="{S*1.1:.1f}"/>
<circle cx="{X(52.6):.1f}" cy="{Y(63.6):.1f}" r="{S*2.8:.1f}" stroke="none"/><circle cx="{X(52.6):.1f}" cy="{Y(75.6):.1f}" r="{S*2.6:.1f}" stroke="none"/></g>'''
svg=f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><rect width="512" height="512" rx="96" fill="#1a0b08"/><circle cx="256" cy="256" r="226" fill="#896038"/><circle cx="256" cy="256" r="210" fill="#3a1608"/><circle cx="256" cy="256" r="204" fill="#9a0628"/><path fill="#d69d56" d="{path(P)}"/>{feat}</svg>'''
open(os.path.join(ROOT,'public','icon.svg'),'w').write(svg)
# The round logo on its own (no square behind it), for the site header.
logo=svg.replace('viewBox="0 0 512 512"','viewBox="30 30 452 452"').replace('<rect width="512" height="512" rx="96" fill="#1a0b08"/>','')
open(os.path.join(ROOT,'public','logo.svg'),'w').write(logo)
