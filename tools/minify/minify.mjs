// Shrinks public/index.html for deploys: minifies the page's own script (terser) and its CSS and whitespace
// (html-minifier-terser). The readable file stays in the repo; only the deployed copy is minified.
import fs from "node:fs";import {minify as minHtml} from "html-minifier-terser";import {minify as minJs} from "terser";
const [,,src,dst]=process.argv;let s=fs.readFileSync(src,"utf8");
const re=/(<script type="module">)([\s\S]*?)(<\/script>)/g;const parts=[];let m;
while((m=re.exec(s)))parts.push(m);
for(const p of parts.reverse()){const r=await minJs(p[2],{module:true,compress:{passes:1},mangle:true,format:{comments:false}});
  s=s.slice(0,p.index)+p[1]+r.code+p[3]+s.slice(p.index+p[0].length)}
s=await minHtml(s,{collapseWhitespace:true,conservativeCollapse:true,removeComments:true,minifyCSS:true,minifyJS:false});
fs.writeFileSync(dst,s);console.log(src,"→",dst,fs.statSync(src).size,"→",s.length)
