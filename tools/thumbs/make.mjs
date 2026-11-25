// Small copies of every character's armory picture, for phones on mobile data.
// Blizzard only serves WoW Forever renders at full size (1600x1200 PNG, about 470 KB). This makes an 800-wide WebP of
// each (about 10 times smaller) into public/thumbs/, plus public/thumbs/index.json saying which armory picture and
// armory update each copy was made from. The site only uses a copy while it still matches the character's armory;
// if they've changed gear since, it shows the full picture until the next deploy.
// Run by "Deploy the site" and "Preview the site" with the deploy key in GOOGLE_APPLICATION_CREDENTIALS
// (needs the Cloud Datastore Viewer role to read the character list). If anything fails, the site deploys without it.
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import sharp from "sharp";
import { mkdir, writeFile } from "node:fs/promises";

const OUT = process.argv[2] || "../../public/thumbs";
const pic = u => typeof u === "string" && /^https:\/\/render\.worldofwarcraft\.com\/[\w\/.-]+$/.test(u) && !/\/shadow\//.test(u) ? u : "";
initializeApp({ projectId: "loot-goblins-roster" });
const db = getFirestore();
await mkdir(OUT, { recursive: true });
const jobs = [];
for (const coll of ["members", "alts"]) {
  const snap = await db.collection(coll).get();
  for (const d of snap.docs) { const a = d.data().armory || {}, r = pic(a.render); if (r && a.updated) jobs.push({ coll, id: d.id, r, u: a.updated }); }
}
const index = {};
let ok = 0, bytesIn = 0, bytesOut = 0;
async function one(j) {
  try {
    const res = await fetch(j.r, { headers: { "user-agent": "Mozilla/5.0 (compatible; BloodAndTearsGuildSite/1.0)" } });
    if (!res.ok) return;
    const buf = Buffer.from(await res.arrayBuffer());
    const small = await sharp(buf).resize({ width: 800 }).webp({ quality: 78, alphaQuality: 90 }).toBuffer();
    const f = `${j.coll}-${j.id}.webp`;
    await writeFile(`${OUT}/${f}`, small);
    index[`${j.coll}/${j.id}`] = { f, r: j.r, u: j.u };
    ok++; bytesIn += buf.length; bytesOut += small.length;
  } catch (e) { console.warn("skipped", j.coll, j.id, e.message); }
}
const queue = [...jobs];
await Promise.all(Array.from({ length: 4 }, async () => { while (queue.length) await one(queue.shift()); }));
await writeFile(`${OUT}/index.json`, JSON.stringify(index));
console.log(`Thumbnails: ${ok} of ${jobs.length}, ${(bytesIn / 1e6).toFixed(1)} MB down to ${(bytesOut / 1e6).toFixed(1)} MB`);
