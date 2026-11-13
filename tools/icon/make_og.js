// Run from the project folder (needs Playwright):  node tools/icon/make_og.js
// Link preview (public/og-gingerbread.png, 1200x630): a crimson tabard field with green trim, a faint pattern of gingerbread men,
// the round guild logo and the title in gingerbread.
const {chromium}=require('playwright');const fs=require('fs');
(async()=>{const b=await chromium.launch();const p=await b.newPage({viewport:{width:1200,height:630}});
const logo=fs.readFileSync('public/logo.svg','utf8').replace('<svg ','<svg width="380" height="380" ');
const man=/<path fill="#d69d56" d="([^"]+)"/.exec(logo)[1];
const pattern=`<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="630" style="position:absolute;inset:0"><defs><pattern id="gm" width="120" height="120" patternUnits="userSpaceOnUse" patternTransform="rotate(-12)"><g transform="translate(18 14) scale(.17)"><path d="${man}" fill="#d69d56" transform="translate(-60 -50)"/></g><g transform="translate(78 74) scale(.17)"><path d="${man}" fill="#d69d56" transform="translate(-60 -50)"/></g></pattern></defs><rect width="1200" height="630" fill="url(#gm)" opacity=".07"/></svg>`;
await p.setContent(`<html><head><style>body{margin:0;width:1200px;height:630px;overflow:hidden;position:relative;background:radial-gradient(ellipse at 28% 45%,#a8082c 0%,#7a0420 38%,#3a0208 100%);font-family:Georgia,serif}
.trim{position:absolute;left:0;right:0;height:22px;background:#23803a}.trim::after{content:"";position:absolute;left:0;right:0;top:9px;border-top:4px dashed #d69d56;opacity:.85}
.top{top:0}.bot{bottom:0}.row{position:absolute;inset:22px 0;display:flex;align-items:center;gap:56px;padding:0 84px}
h1{margin:0;font-size:96px;line-height:1;color:#f0c58c;text-shadow:0 3px 0 #5a1a08,0 8px 24px rgb(0 0 0/.35)}p{margin:22px 0 0;font:500 36px system-ui,sans-serif;color:#ffe9d6}
.tag{display:inline-block;margin-top:26px;padding:10px 20px;border-radius:999px;background:rgb(0 0 0/.28);border:2px solid #d69d56;color:#f0c58c;font:600 26px system-ui,sans-serif}
.logo{filter:drop-shadow(0 10px 24px rgb(0 0 0/.45));flex:none}</style></head><body>${pattern}<div class="trim top"></div><div class="trim bot"></div>
<div class="row"><div class="logo">${logo}</div><div><h1>Blood and Tears</h1><p>Horde guild · WoW Forever</p><span class="tag">Roster · Records · Dungeons · Professions</span></div></div></body></html>`);
await p.waitForTimeout(200);await p.screenshot({path:'public/og-gingerbread.png'});await b.close()})();
