// The safety check before a deploy: opens every page of the site with made-up test data (fake.js stands in for
// Firebase), on a computer and a phone, in dark and light, and fails if anything is broken:
//   - a script error on any page
//   - the page's styles have an unclosed block (what broke the news ticker on 26 Nov)
//   - a page scrolls sideways on a phone
//   - the news ticker isn't a single line on a computer
// Run: cd tools/check && npm ci && npx playwright install chromium && node check.mjs [../../public]
// The deploy workflows run it on the files they're about to publish; if it fails, nothing is deployed.
import { chromium } from "playwright";
import { createServer } from "node:http";
import { readFile, mkdir, cp, writeFile, rm } from "node:fs/promises";
import { join, extname, resolve } from "node:path";
import { tmpdir } from "node:os";

const SRC = resolve(process.argv[2] || "../../public");
const SITE = join(tmpdir(), "bt-check-site");
await rm(SITE, { recursive: true, force: true });
await mkdir(SITE, { recursive: true });
await cp(SRC, SITE, { recursive: true });
let html = await readFile(join(SITE, "index.html"), "utf8");
html = html.replace(/"https:\/\/www\.gstatic\.com\/firebasejs\/[\d.]+\/firebase-[a-z-]+\.js"/g, '"./fake.js"');
await writeFile(join(SITE, "index.html"), html);
await cp(new URL("./fake.js", import.meta.url), join(SITE, "fake.js"));

const problems = [];
// 1. Styles: every { has its }.
for (const m of html.matchAll(/<style[^>]*>([\s\S]*?)<\/style>/g)) {
  const css = m[1].replace(/\/\*[\s\S]*?\*\//g, "").replace(/"[^"\n]*"|'[^'\n]*'/g, '""');
  const depth = [...css].reduce((d, c) => d + (c === "{") - (c === "}"), 0);
  if (depth !== 0) problems.push(`Styles: ${depth > 0 ? depth + " block(s) never closed" : -depth + " extra closing brace(s)"}`);
}

const TYPES = { ".html": "text/html", ".js": "text/javascript", ".json": "application/json", ".css": "text/css", ".svg": "image/svg+xml", ".png": "image/png", ".webp": "image/webp", ".jpg": "image/jpeg", ".ico": "image/x-icon", ".webmanifest": "application/manifest+json" };
const server = createServer(async (req, res) => {
  let path = decodeURIComponent(new URL(req.url, "http://x").pathname);
  if (path.endsWith("/")) path += "index.html";
  try { const body = await readFile(join(SITE, path)); res.writeHead(200, { "content-type": TYPES[extname(path)] || "application/octet-stream" }); res.end(body); }
  catch { res.writeHead(404); res.end(); }
});
await new Promise(r => server.listen(0, "127.0.0.1", r));
const base = `http://127.0.0.1:${server.address().port}/`;

const PAGES = ["roster", "lfg", "raids", "professions", "records", "activity", "history", "char/members/uid-clark", "char/members/u2", "char/members/u4"];
const browser = await chromium.launch();
for (const theme of ["dark", "light"]) for (const width of [1280, 390]) {
  const page = await browser.newPage({ viewport: { width, height: 900 } });
  const errors = [];
  page.on("pageerror", e => errors.push(e.message));
  page.on("console", m => { if (m.type() === "error" && !/Failed to load resource|net::/.test(m.text())) errors.push(m.text()); });
  await page.route(/^https?:\/\/(?!127\.0\.0\.1)/, r => r.abort());   // nothing from the internet: Blizzard, Wowhead, fonts
  for (const p of PAGES) {
    await page.goto(base + "#" + p);
    await page.waitForTimeout(1200);
    await page.evaluate(t => { document.documentElement.dataset.theme = t }, theme);
    const r = await page.evaluate(() => {
      const news = document.querySelector(".news");
      return { sideways: document.documentElement.scrollWidth > document.documentElement.clientWidth + 1,
        empty: !document.querySelector("main") || document.querySelector("main").innerText.trim().length < 20,
        newsTall: news ? news.getBoundingClientRect().height > 80 : false };
    });
    const where = `${p} (${width}px, ${theme})`;
    if (r.empty) problems.push(`${where}: the page is empty`);
    if (r.sideways && width < 500) problems.push(`${where}: scrolls sideways`);
    if (r.newsTall && width > 900) problems.push(`${where}: the news ticker is more than one line`);
  }
  for (const e of new Set(errors)) problems.push(`Script error (${width}px, ${theme}): ${e.slice(0, 200)}`);
  await page.close();
}
await browser.close();
server.close();
await rm(SITE, { recursive: true, force: true });

if (problems.length) {
  console.error(`The safety check found ${problems.length} problem(s), so this won't be deployed:\n- ` + [...new Set(problems)].join("\n- "));
  process.exit(1);
}
console.log(`Safety check passed: ${PAGES.length} pages, computer and phone, dark and light.`);
