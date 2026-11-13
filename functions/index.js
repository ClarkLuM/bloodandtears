// Posts guild activity to Discord through a channel webhook.
// Each channel has its own webhook, stored as a Firebase secret (never in the site's files):
//   DISCORD_WEBHOOK         #guild-feed  (new guildies, big moments, and the daily "Today in Blood and Tears")
//   DISCORD_WEBHOOK_LFG     #lfg
//   DISCORD_WEBHOOK_EVENTS  #events
// Forum channels get one post per group or event; plain text channels get normal messages.
const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { defineSecret } = require("firebase-functions/params");
const { setGlobalOptions } = require("firebase-functions/v2");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const logger = require("firebase-functions/logger");

// Must match your Firestore database location (Firestore Database page in the Firebase console).
const REGION = "australia-southeast1";
const SITE = "https://bloodandtears.web.app";

setGlobalOptions({ region: REGION, maxInstances: 2 });
// Discord posts and the daily digest are switched off for now (the code is kept). The old slash commands were removed (Nov 2026).
// Set this to true, set the Discord secrets (see README), and deploy to turn them back on.
// The site's "On Discord" box doesn't use any of this, so it keeps working either way.
const DISCORD_ON = false;
// While it's off the Discord secrets aren't even declared, so deploys never ask for them.
const dcSecret = name => DISCORD_ON ? defineSecret(name) : { value: () => "" };
const WEBHOOK = dcSecret("DISCORD_WEBHOOK");
const HOOKS = { feed: WEBHOOK, lfg: dcSecret("DISCORD_WEBHOOK_LFG"), events: dcSecret("DISCORD_WEBHOOK_EVENTS") };
const ALL_SECRETS = DISCORD_ON ? Object.values(HOOKS) : [];
const GOLD = 0xb8282a; // guild red (name kept so the posts code doesn't change)

const KIND = { dungeon: "Dungeon", bg: "Battleground", prof: "Profession", level: "Level", item: "Item", other: "Goal" };
// Stop names and goals from turning into Discord formatting or pings.
const clean = s => String(s || "").replace(/([\\*_~`|>#\[\]()])/g, "\\$1").replace(/@/g, "@\u200b").slice(0, 200);
const nameOf = m => clean(m ? ((m.first ? `${m.first} ${m.last || ""}`.trim() : m.char) || "Someone") : "Someone");
const itemText = (name, url) => /^https:\/\/([a-z]+\.)?wowhead\.com\//i.test(url || "") ? `[${clean(name)}](${url})` : clean(name);

// Posts an embed to a channel. thread: a forum post title (new post), or {id} to reply inside an existing post.
// Returns the Discord message, so a forum post's id can be saved for later replies.
async function post(embed, channel = "feed", thread) {
  if (!DISCORD_ON) return null;
  let url = "";
  try { url = HOOKS[channel].value(); } catch (e) {}
  if (!url) { try { url = WEBHOOK.value(); } catch (e) {} }
  // Tidy up a pasted link: stray spaces, quotes or a line break would make it unusable.
  url = String(url || "").trim().replace(/^["'<]+|["'>]+$/g, "").trim();
  if (!url) { logger.warn(`No webhook set for ${channel}`); return null; }
  if (!/^https:\/\/(\w+\.)?discord(app)?\.com\/api\/webhooks\/\d+\/[\w-]+/.test(url)) {
    logger.error(`The ${channel} webhook isn't a Discord webhook link. It starts with "${url.slice(0, 24)}". Set it again with firebase functions:secrets:set.`);
    return null;
  }
  logger.info(`Posting to ${channel}`, { usingFallback: (() => { try { return !HOOKS[channel].value(); } catch (e) { return true; } })() });
  const send = async useThread => {
    const u = new URL(url); u.searchParams.set("wait", "true");
    if (useThread && thread && thread.id) u.searchParams.set("thread_id", thread.id);
    const body = { username: "Blood and Tears", allowed_mentions: { parse: [] }, embeds: [{ color: GOLD, ...embed }] };
    if (useThread && typeof thread === "string") body.thread_name = thread.slice(0, 100);
    return fetch(u, { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify(body) });
  };
  let res = await send(true);
  // A plain text channel rejects forum titles, and a deleted forum post rejects replies: send it as a normal message instead.
  if (!res.ok && thread && res.status === 400) res = await send(false);
  if (!res.ok) { logger.error(`Discord said ${res.status} for ${channel}`, await res.text()); return null; }
  const msg = await res.json().catch(() => null);
  // Logged so it's easy to check each webhook goes where you expect: firebase functions:log
  logger.info(`Posted to ${channel}`, { channel, discordChannel: msg && msg.channel_id, webhookName: msg && msg.author && msg.author.username });
  return msg;
}
const opts = path => ({ document: path, secrets: ALL_SECRETS });
// firebase-admin is only loaded when a function actually runs, so deploys start up quickly.
let _db;
const db = () => {
  if (!_db) {
    // Firebase's own library can register a helper app first, so check for the default app by name.
    const { initializeApp, getApps } = require("firebase-admin/app");
    if (!getApps().some(a => a.name === "[DEFAULT]")) initializeApp();
    _db = require("firebase-admin/firestore").getFirestore();
  }
  return _db;
};

// Someone adds a main character.
exports.newMember = onDocumentCreated(opts("members/{id}"), async e => {
  const m = e.data && e.data.data(); if (!m) return;
  if (m.quiet) return; // the first import of the whole guild roster
  await post({ title: m.fromGuild ? `${nameOf(m)} joined the guild` : `${nameOf(m)} joined the roster`, url: `${SITE}/#char/members/${e.params.id}`,
    description: [[m.race, m.cls].filter(Boolean).join(" "), m.role, `Level ${m.level || 1}`].filter(Boolean).map(clean).join(" · ") });
});

// New Looking for Group goals and level milestones, for mains and alts.
async function charChanged(e, coll) {
  const before = e.data.before.data() || {}, after = e.data.after.data() || {};
  // An officer linking a new device (or claiming their character) needs their officer powers on it too.
  if (coll === "members" && JSON.stringify(before.owners || []) !== JSON.stringify(after.owners || [])) await updateOfficers().catch(err => logger.warn("officers", err.message));
  const link = `${SITE}/#char/${coll}/${e.params.id}`;
  const who = nameOf(after);
  const was = new Set((before.goals || []).filter(g => g && g.lfg && !g.done).map(g => g.id || g.t));
  for (const g of (after.goals || [])) {
    if (!g || !g.lfg || g.done || was.has(g.id || g.t)) continue;
    const what = g.kind === "item" ? itemText(g.t, g.url) : clean(g.t);
    await post({ title: `${who} wants a group`, url: `${SITE}/#lfg`,
      description: `**${KIND[g.kind] || "Goal"}:** ${what}${g.range ? ` · levels ${clean(g.range)}` : ""}` +
        (Date.parse(g.when || "") ? `\n**When:** <t:${Math.floor(Date.parse(g.when) / 1000)}:F>` : "") + (g.note ? `\n> ${clean(g.note).slice(0, 140)}` : "") +
        `\nJoin on the site or whisper ${who} in game.` },
      "lfg", `${String(g.t || "Group").slice(0, 60)}${g.range ? " (" + g.range + ")" : ""} · ${nameOf(after).replace(/\\/g, "")}`);
  }
  const a = +before.level || 0, b = +after.level || 0;
  if (a && b > a && (b === 60 || Math.floor(b / 10) > Math.floor(a / 10))) {
    // First Blood: first main in the guild to reach this milestone.
    let first = "";
    if (coll === "members") {
      const m = Math.floor(b / 10) * 10;
      const others = await db().collection("members").where("level", ">=", m).get();
      if (others.docs.every(x => x.id === e.params.id)) first = m;
    }
    if (b === 60 || first) await post({ title: b === 60 ? `${who} hit level 60!` : `${who} reached level ${b}`, url: link,
      description: [b === 60 ? "Achievement: **Max Level**" : "", first ? `Achievement: **First Blood**, first in the guild to ${first}` : ""].filter(Boolean).join("\n") || undefined });
    else await toDigest(`**${who}** reached level ${b}`);
  }
  // Artisan: a profession reaching 300.
  const CLASS_ONLY = ["Lockpicking", "Comprehension"];
  for (const [p, v] of Object.entries(after.profs || {})) {
    if (CLASS_ONLY.includes(p) || +v < 300 || +((before.profs || {})[p] || 0) >= 300) continue;
    await post({ title: `${who} maxed ${clean(p)}`, description: `Achievement: **Artisan**, ${clean(p)} reached 300.`, url: link });
  }
  // The rest comes from the armory. A character's first sync is skipped, so it doesn't post everything they already had.
  const bA = before.armory || {}, aA = after.armory || {};
  const firstSync = !bA.at && !!aA.at;
  if (firstSync) return;
  // Rare, epic or legendary items that weren't equipped before (from the armory or picked on the site).
  const bG = before.gear || {}, seen = new Set(Object.values(bG).map(g => g && String(g.id)));
  const fresh = Object.values(after.gear || {}).filter(g => g && +g.q >= 3 && !seen.has(String(g.id)))
    .filter((g, i, l) => l.findIndex(x => String(x.id) === String(g.id)) === i).sort((x, y) => y.q - x.q);
  const blues = fresh.filter(g => +g.q === 3), big = fresh.filter(g => +g.q >= 4);
  for (const g of blues) await toDigest(`**${who}** equipped ${itemText(g.name, `https://www.wowhead.com/forever/item=${encodeURIComponent(g.id)}`)}`);
  if (big.length) {
    const fresh = big;
    await post({ title: `${who} equipped ${fresh.length === 1 ? (fresh[0].q >= 4 ? "something epic" : "something shiny") : fresh.length + " new items"}`, url: link,
      color: Q_COLOR[fresh[0].q] || GOLD,
      description: fresh.slice(0, 8).map(g => `**${Q_LABEL[g.q] || "Rare"}:** ${itemText(g.name, `https://www.wowhead.com/forever/item=${encodeURIComponent(g.id)}`)}`).join("\n") });
  }
  // Training a new profession rank (the armory's skill cap goes up).
  const bM = bA.profMax, aM = aA.profMax || {};
  if (bM) for (const [p, cap] of Object.entries(aM)) {
    if (!bM[p] || +cap <= +bM[p] || !RANK_BY_MAX[cap]) continue;
    await toDigest(`**${who}** trained ${RANK_BY_MAX[cap]} ${clean(p)}`);
  }
  // PvP: a new rank, or an honourable kill milestone.
  if (bA.rank !== undefined && +aA.rank > +bA.rank)
    await post({ title: `${who} reached PvP rank ${+aA.rank}${PVP_RANKS[+aA.rank] ? ": " + PVP_RANKS[+aA.rank] : ""}`, url: link, color: 0x8c1d1d,
      description: `${(+aA.hk || 0).toLocaleString("en-AU")} honourable kills so far.` });
  if (bA.hk !== undefined) {
    const hit = HK_MILESTONES.filter(n => +bA.hk < n && +aA.hk >= n).pop();
    if (hit) await toDigest(`**${who}** reached ${hit.toLocaleString("en-AU")} honourable kills`);
  }
}
const Q_LABEL = ["Poor", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Artifact", "Heirloom"];
const Q_COLOR = { 3: 0x0070dd, 4: 0xa335ee, 5: 0xff8000, 6: 0xe6cc80 };
const HK_MILESTONES = [100, 250, 500, 1000, 2500, 5000, 10000, 25000];
exports.memberChanged = onDocumentUpdated(opts("members/{id}"), e => charChanged(e, "members"));
exports.altChanged = onDocumentUpdated(opts("alts/{id}"), e => charChanged(e, "alts"));

// Smaller news (level milestones, blue items, profession ranks, kill milestones) is saved up and posted once a day,
// so #guild-feed isn't flooded. Big moments still post straight away.
async function toDigest(line) {
  if (!DISCORD_ON) return;
  const { FieldValue } = require("firebase-admin/firestore");
  await db().doc("guild/digest").set({ lines: FieldValue.arrayUnion(String(line).slice(0, 300)) }, { merge: true });
}
exports.dailyDigest = onSchedule({ schedule: "0 21 * * *", timeZone: "Australia/Perth", secrets: ALL_SECRETS }, async () => {
  const ref = db().doc("guild/digest"), lines = ((await ref.get()).data() || {}).lines || [];
  if (!lines.length) return;
  let text = "", shown = 0;
  for (const l of lines) { if ((text + l).length > 3800) break; text += "• " + l + "\n"; shown++; }
  if (lines.length > shown) text += `…and ${lines.length - shown} more on the site.`;
  await post({ title: "Today in Blood and Tears", url: SITE, description: text.trim() });
  await ref.set({ lines: [], at: new Date().toISOString() });
});
const { onCall, HttpsError } = require("firebase-functions/v2/https");

// ---------- Armory sync ----------
// The WoW Forever armory page for a character (worldofwarcraft.blizzard.com/en-us/forever/us/armory/character/<name>)
// includes a short summary like "Clark ❮Guild❯ - 10 Troll Rogue, 1 ilvl". We read the level from that.
// Levels only ever go up from here: if the armory is behind the site, nothing changes.
const ARMORY = "https://worldofwarcraft.blizzard.com/en-us/forever/us/armory/character/";
const decode = s => String(s).replace(/&#(\d+);/g, (m, n) => String.fromCodePoint(+n)).replace(/&#x([0-9a-f]+);/gi, (m, n) => String.fromCodePoint(parseInt(n, 16)))
  .replace(/&quot;/g, '"').replace(/&#39;|&apos;/g, "'").replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&amp;/g, "&");
// Each armory page carries the full character as JSON (characterProfileInitialState): level, spec, professions and gear.
// If that's ever missing, fall back to the short summary in the page's description.
const GEAR_SLOT = { HEAD: "Head", NECK: "Neck", SHOULDER: "Shoulder", BACK: "Back", CHEST: "Chest", SHIRT: "Shirt", TABARD: "Tabard", WRIST: "Wrist",
  HANDS: "Hands", WAIST: "Waist", LEGS: "Legs", FEET: "Feet", FINGER_1: "Finger 1", FINGER_2: "Finger 2", TRINKET_1: "Trinket 1", TRINKET_2: "Trinket 2",
  MAIN_HAND: "Main hand", OFF_HAND: "Off hand", RANGED: "Ranged" };
const INV_TEXT = { HEAD: "Head", NECK: "Neck", SHOULDER: "Shoulder", CLOAK: "Back", CHEST: "Chest", ROBE: "Chest", BODY: "Shirt", TABARD: "Tabard", WRIST: "Wrist",
  HAND: "Hands", WAIST: "Waist", LEGS: "Legs", FEET: "Feet", FINGER: "Finger", TRINKET: "Trinket", WEAPON: "One-Hand", TWOHWEAPON: "Two-Hand",
  WEAPONMAINHAND: "Main Hand", WEAPONOFFHAND: "Off Hand", SHIELD: "Off Hand", HOLDABLE: "Held In Off-hand", RANGED: "Ranged", RANGEDRIGHT: "Ranged", THROWN: "Thrown", RELIC: "Relic" };
const Q_NUM = { POOR: 0, COMMON: 1, UNCOMMON: 2, RARE: 3, EPIC: 4, LEGENDARY: 5, ARTIFACT: 6, HEIRLOOM: 7 };
// Only Blizzard's own image server is trusted for pictures and icons.
const pic = u => typeof u === "string" && /^https:\/\/render\.worldofwarcraft\.com\/[\w\/.-]+$/.test(u) ? u : "";
// Stats the armory lists that don't exist in this version of the game.
const SKIP_STATS = ["haste", "mastery", "leech", "versatility", "avoidance", "bonus-armor", "movement-speed", "item-level", "speed", "lifesteal"];
const r2 = v => Math.round((+v || 0) * 100) / 100;
async function armoryOf(fullName) {
  const slug = String(fullName || "").trim().toLowerCase().replace(/\s+/g, "-");
  if (!slug) return null;
  const res = await fetch(ARMORY + encodeURIComponent(slug), { headers: { "user-agent": "Mozilla/5.0 (compatible; BloodAndTearsGuildSite/1.0)", "accept-language": "en-US" } });
  if (!res.ok) { logger.info("armory: no page", { slug, status: res.status }); return null; }
  const html = await res.text();
  const out = { url: ARMORY + slug };
  const k = html.indexOf("var characterProfileInitialState = ");
  if (k >= 0) {
    try {
      const start = k + "var characterProfileInitialState = ".length, end = html.indexOf("</script>", start);
      const c = (JSON.parse(html.slice(start, end).trim().replace(/;\s*$/, "")) || {}).character || {};
      if (c.level) {
        out.full = true;
        out.level = +c.level; out.guild = (c.guild && c.guild.name) || ""; out.guildSlug = (c.guild && c.guild.slug) || ""; out.ilvl = +c.averageItemLevel || 0;
        out.first = String(c.name || "").slice(0, 20); out.last = String(c.surname || "").slice(0, 20);
        out.cls = c.class && c.class.name || ""; out.race = c.race && c.race.name || "";
        const sp = (c.specs || []).find(x => x.active) || null; out.spec = sp ? sp.name : "";
        // Pictures: the full transparent render, the square portrait and the race background the armory shows behind it.
        const md = c.media || {};
        out.render = pic(md["main-raw"] && md["main-raw"].url) || pic(md["main-sd-raw"] && md["main-sd-raw"].url);
        out.avatar = pic(c.avatar && c.avatar.url) || pic(md.avatar && md.avatar.url);
        out.bg = pic(c.render && c.render.background && c.render.background.url);
        // Blizzard's generic race and class pictures, used when the character's own picture is missing.
        out.fallbackFg = pic(c.render && c.render.foregroundFallback && c.render.foregroundFallback.url);
        out.fallbackBg = pic(c.render && c.render.staticFallback && c.render.staticFallback.url);
        out.gender = c.gender && c.gender.name || "";
        // When the armory last heard from the game, which is usually when they last logged out.
        out.updated = c.lastUpdatedTimestamp && c.lastUpdatedTimestamp.iso8601 || "";
        // Talents: every tree with points in it, and each talent's rank and description.
        out.talents = (c.specs || []).filter(t => t && +t.spentPoints > 0).slice(0, 3).map(t => ({
          name: String(t.name || "").slice(0, 40), points: +t.spentPoints || 0, active: !!t.active, icon: pic(t.icon && t.icon.url),
          talents: (t.talents || []).slice(0, 40).map(x => ({ id: +x.id || 0, name: String(x.name || "").slice(0, 60), rank: +x.rank || 1,
            icon: pic(x.icon && x.icon.url), desc: String(x.description || "").slice(0, 300) })) }));
        // Stats, as the character panel shows them. Damage is a [min, max] pair.
        const st = {};
        for (const g of ((c.stats || {}).groups || [])) for (const x of (g.stats || [])) {
          if (!x || !x.slug || x.slug in st || SKIP_STATS.includes(x.slug)) continue;
          const v = x.value || {};
          if (v.type === "RANGE") st[x.slug] = [r2(v.min && v.min.value), r2(v.max && v.max.value)];
          else if (typeof v.value === "number") st[x.slug] = r2(v.value);
        }
        out.stats = Object.keys(st).length ? st : null;
        // PvP: lifetime honourable kills and rank.
        if (c.pvp) { out.hk = +(c.pvp.honorableKills && c.pvp.honorableKills.value) || 0; out.rank = +(c.pvp.rank && c.pvp.rank.value) || 0; }
        const pr = {}, prMax = {}; let hasProfs = false;
        for (const grp of ["primaries", "secondaries"]) for (const x of ((c.professions || {})[grp] || [])) {
          hasProfs = true; if (!x.name) continue;
          pr[x.name] = Math.min(300, Math.max(0, ...(x.tiers || []).map(t => +t.skillPoints || 0)));
          // The skill cap shows which rank they've trained: 75 Apprentice, 150 Journeyman, 225 Expert, 300 Artisan.
          prMax[x.name] = Math.min(300, Math.max(0, ...(x.tiers || []).map(t => +t.maxSkillPoints || 0)));
        }
        out.profs = hasProfs ? pr : null; out.profMax = hasProfs ? prMax : null;
        const gear = {};
        for (const g of Object.values(c.gear || {})) {
          const slot = g && g.slot && GEAR_SLOT[g.slot.type]; if (!slot || !g.id) continue;
          const icon = ((g.media && g.media.content && g.media.content.assets) || []).find(a => a.key === "icon");
          gear[slot] = { id: String(g.id), name: String(g.name || "").slice(0, 120), q: Q_NUM[g.quality && g.quality.type] ?? 1, icon: "", iconUrl: pic(icon && icon.value),
            slot: INV_TEXT[g.inventory_type && g.inventory_type.type] || "" };
        }
        out.gear = Object.keys(gear).length ? gear : null;
        return out;
      }
    } catch (e) { logger.warn("armory: couldn't read the character data", { slug, err: e.message }); }
  }
  const m = /<meta[^>]+(?:property|name)=["'](?:og:)?description["'][^>]*content=["']([^"']*)["']/i.exec(html) || /<meta[^>]+content=["']([^"']*)["'][^>]*(?:property|name)=["'](?:og:)?description["']/i.exec(html);
  if (!m) { logger.warn("armory: no summary on page", { slug }); return null; }
  const text = decode(m[1]);
  const lv = /-\s*(\d{1,2})\s+([A-Za-z][A-Za-z']*)/.exec(text), guild = /❮([^❯]+)❯/.exec(text), ilvl = /(\d+)\s*ilvl/i.exec(text);
  if (!lv) { logger.warn("armory: couldn't read level", { slug, text }); return null; }
  return { ...out, level: +lv[1], race: lv[2], guild: guild ? guild[1].trim() : "", ilvl: ilvl ? +ilvl[1] : 0 };
}
const RANK_OF = sk => sk <= 75 ? "Apprentice" : sk <= 150 ? "Journeyman" : sk <= 225 ? "Expert" : "Artisan";
const RANK_BY_MAX = { 75: "Apprentice", 150: "Journeyman", 225: "Expert", 300: "Artisan" };
const PVP_RANKS = ["", "Scout", "Grunt", "Sergeant", "Senior Sergeant", "First Sergeant", "Stone Guard", "Blood Guard", "Legionnaire", "Centurion",
  "Champion", "Lieutenant General", "General", "Warlord", "High Warlord"];
const pvpRankName = n => PVP_RANKS[n] ? `Rank ${n}: ${PVP_RANKS[n]}` : `Rank ${n}`;
// Tank and healer specs. Anything else leaves the role alone (low-level talents often don't match how someone plays).
const roleFromSpec = (cls, spec) => spec === "Protection" && (cls === "Warrior" || cls === "Paladin") ? "Tank"
  : /^(Holy|Discipline|Restoration)$/.test(spec || "") ? "Healer" : "";
const roleFromRoster = r => { const t = String(r || "").toUpperCase(); return /TANK/.test(t) ? "Tank" : /HEAL/.test(t) ? "Healer" : /DAMAGE|DPS/.test(t) ? "DPS" : ""; };
const sameMap = (x, y) => { const k = o => JSON.stringify(Object.keys(o || {}).sort().map(n => [n, o[n]])); return k(x) === k(y); };
// Monday of this week in Perth, for "honourable kills this week".
const weekKey = () => { const d = new Date(Date.now() + 8 * 36e5); d.setUTCDate(d.getUTCDate() - (d.getUTCDay() + 6) % 7); return d.toISOString().slice(0, 10); };
async function syncChar(coll, id, data) {
  const a = await armoryOf(data.first ? `${data.first} ${data.last || ""}` : data.char);
  const now = new Date().toISOString();
  if (!a) return { found: false };
  const lv = Math.max(1, Math.min(60, a.level || 1));
  // Start from what was saved last time, so a page that only had the short summary doesn't wipe talents, stats and so on.
  const prevA = data.armory || {};
  const A = { ...prevA, at: now, url: a.url, level: lv };
  for (const key of ["guild", "guildSlug", "ilvl", "spec", "updated", "render", "avatar", "bg", "fallbackFg", "fallbackBg", "gender", "talents", "stats", "profMax"])
    if (a[key] !== undefined && a[key] !== null && (a[key] !== "" || a.full)) A[key] = a[key];
  if (a.hk !== undefined) {
    A.hk = a.hk; A.rank = a.rank;
    const wk = weekKey();
    A.hkWeek = prevA.hkWeek && prevA.hkWeek.wk === wk ? prevA.hkWeek : { wk, base: prevA.hk !== undefined ? Math.min(+prevA.hk, a.hk) : a.hk };
  }
  const patch = { armory: A };
  const journey = [...(Array.isArray(data.journey) ? data.journey : [])]; let changed = false; const what = [];
  const old = +data.level || 1;
  if (lv > old) { patch.level = lv; journey.unshift({ t: "Reached level " + lv, at: now, from: old }); changed = true; what.push(`level ${old} → ${lv}`); }
  if (a.cls && !data.cls) { patch.cls = a.cls; changed = true; what.push("class"); }
  if (a.race && !data.race) { patch.race = a.race; changed = true; what.push("race"); }
  if (a.spec && a.spec !== data.spec) { patch.spec = a.spec; changed = true; what.push("spec"); }
  // Role from a tank or healer spec, unless someone has picked their role by hand on the site.
  const specRole = roleFromSpec(a.cls || data.cls, a.spec);
  if (specRole && !data.roleEditedAt && specRole !== data.role && data.role2 !== specRole) { patch.role = specRole; changed = true; what.push("role"); }
  // Professions and gear always come from the armory (the site doesn't edit them by hand any more).
  if (a.profs) {
    const next = {};
    for (const [p, v] of Object.entries(a.profs)) {
      next[p] = v; const was = +((data.profs || {})[p] || 0);
      if (a.profMax) {
        // Training a new rank shows up as a higher skill cap. Only counted once we know the old cap.
        const capWas = prevA.profMax && prevA.profMax[p], cap = a.profMax[p];
        if (capWas && cap > capWas && RANK_BY_MAX[cap]) journey.unshift({ t: `Trained ${RANK_BY_MAX[cap]} ${p}`, at: now });
      } else if (was && v > was && RANK_OF(v) !== RANK_OF(was)) journey.unshift({ t: `${p} reached ${RANK_OF(v)}`, at: now });
      // Skill milestones for the feed ("Reached 225 Blacksmithing"). Not for a profession that's brand new to them.
      const hitSk = NOT_PROFS.includes(p) || !was ? 0 : SKILL_MILESTONES.filter(n => was < n && +v >= n).pop();
      if (hitSk) { journey.unshift({ t: `Reached ${hitSk} ${p}`, at: now }); changed = true; }
    }
    if (!sameMap(next, data.profs)) { patch.profs = next; changed = true; what.push("professions"); }
  }
  if (a.gear) {
    const strip = g => JSON.stringify(Object.keys(g || {}).sort().map(k => [k, String(g[k].id)]));
    if (strip(a.gear) !== strip(data.gear)) {
      const prev = data.gear || {};
      for (const [slot, g] of Object.entries(a.gear)) if (g.q >= 3 && !(prev[slot] && String(prev[slot].id) === g.id)) journey.unshift({ t: "Equipped " + g.name, at: now, item: { id: g.id, q: g.q } });
      patch.gear = a.gear; changed = true; what.push("gear");
    }
  }
  // Honourable kill milestones for the feed. Not on the first sync, so nobody gets news for kills they already had.
  if (a.hk !== undefined && prevA.at && prevA.hk !== undefined) {
    const hitHk = HK_MILESTONES.filter(n => +prevA.hk < n && +a.hk >= n).pop();
    if (hitHk) { journey.unshift({ t: `Reached ${hitHk} honourable kills`, at: now }); changed = true; what.push("honourable kills"); }
  }
  if (a.rank && prevA.rank !== undefined && a.rank > +prevA.rank) { journey.unshift({ t: "Reached PvP " + pvpRankName(a.rank), at: now }); changed = true; what.push("PvP rank"); }
  if (changed) { patch.updatedAt = now; patch.journey = journey.slice(0, 40); }
  // What the last sync that changed something changed, so the character page can say so.
  if (what.length) A.change = { at: now, what: what.slice(0, 8) };
  await db().doc(`${coll}/${id}`).update(patch);
  return { found: true, level: lv, from: old, raised: lv > old, changed: what, updated: a.updated || "" };
}
// Looks up a name for the Add Character form, without saving anything.
exports.armoryLookup = onCall({ region: REGION, maxInstances: 2 }, async req => {
  if (!req.auth) throw new HttpsError("unauthenticated", "Open the site first.");
  const name = String((req.data && req.data.name) || "").replace(/[^\p{L}' -]/gu, "").replace(/\s+/g, " ").trim().slice(0, 41);
  if (!name) return { found: false };
  const a = await armoryOf(name).catch(e => { logger.warn("armory lookup failed", e.message); return null; });
  if (!a) return { found: false };
  return { found: true, first: a.first || "", last: a.last || "", level: Math.max(1, Math.min(60, a.level || 1)), cls: a.cls || "", race: a.race || "",
    spec: a.spec || "", profs: a.profs || {}, guild: a.guild || "", avatar: a.avatar || "" };
});
// Check every character (mains and alts) against the armory, then note when it finished in guild/armory.
// Officers can fix anyone's character, remove leavers and edit the guild basics.
// Add officers by character name here. Each name is tied to the first character on the site with that name,
// so someone making a new character with the same name doesn't become an officer.
const OFFICER_NAMES = ["Clark Clark"];
async function updateOfficers() {
  const ref = db().doc("guild/officers"), prev = (await ref.get()).data() || {};
  const pinned = { ...(prev.pinned || {}) };
  const docs = (await db().collection("members").get()).docs.map(d => ({ id: d.id, ...d.data() }));
  for (const n of OFFICER_NAMES.map(keyOf)) {
    if (pinned[n] && docs.some(d => d.id === pinned[n])) continue;
    const match = docs.filter(d => keyOf(d.first ? `${d.first} ${d.last || ""}` : d.char) === n).sort((a, b) => String(a.createdAt || "").localeCompare(String(b.createdAt || "")))[0];
    if (match) pinned[n] = match.id; else delete pinned[n];
  }
  // Plus anyone an officer made an officer on the site (guild/officerPicks).
  const picks = (((await db().doc("guild/officerPicks").get()).data() || {}).ids || []).filter(id => docs.some(d => d.id === id));
  const ids = [...new Set([...Object.values(pinned), ...picks])], uids = [...new Set(docs.filter(d => ids.includes(d.id)).flatMap(d => d.owners || []))].sort();
  if (JSON.stringify([prev.members, prev.uids]) === JSON.stringify([ids.slice().sort(), uids])) return;
  await ref.set({ pinned, members: ids.slice().sort(), uids, at: new Date().toISOString() });
}
// "Make officer" / "Remove officer" on the site. Only officers can use it, and only on claimed characters,
// so nobody becomes an officer just by claiming an unclaimed one. Names in OFFICER_NAMES can't be removed here.
/* ---------- Item lookup: Wowhead IDs and qualities for WoW Forever's own items ---------- */
// The site shows items like in-game links. Classic items have their Wowhead IDs built into the page; items WoW Forever
// added don't, so the page sends their names here. Each one is looked up once on Wowhead's WoW Forever database and
// saved in guild/itemIds as items[name in lower case] = [id, quality] (or [0, 0, when] if Wowhead has no exact match,
// which is tried again after a week). A result only counts when Wowhead's own tooltip data has exactly that name, so an
// item can never pick up the wrong link. Only this function writes guild/itemIds (see firestore.rules).
const WH_SEARCH = "https://www.wowhead.com/forever/search?q=";
const WH_TIP = "https://nether.wowhead.com/forever/tooltip/item/";
const WH_HEADERS = { "user-agent": "Mozilla/5.0 (compatible; BloodAndTearsGuildSite/1.0)", "accept-language": "en-US" };
const itemKey = n => String(n || "").replace(/[\u0000-\u001f]/g, "").replace(/\s+/g, " ").trim().slice(0, 80);
async function whTooltip(id) {
  const r = await fetch(WH_TIP + id, { headers: WH_HEADERS });
  if (!r.ok) return null;
  const j = await r.json().catch(() => null);
  return j && typeof j.name === "string" ? j : null;
}
async function whFind(name) {
  // A search for an exact item name usually goes straight to the item's page; otherwise its results link to the items.
  const r = await fetch(WH_SEARCH + encodeURIComponent(name), { headers: WH_HEADERS, redirect: "follow" });
  const ids = [];
  const direct = /\/item=(\d+)/.exec(r.url || "");
  if (direct) ids.push(direct[1]);
  if (r.ok) { const html = await r.text(); for (const m of html.matchAll(/item=(\d+)/g)) if (!ids.includes(m[1])) ids.push(m[1]); }
  for (const id of ids.slice(0, 8)) {
    const t = await whTooltip(id).catch(() => null);
    if (t && t.name.trim().toLowerCase() === name.toLowerCase()) return [+id, Math.max(0, Math.min(6, +t.quality || 0))];
  }
  return null;
}
exports.itemLookup = onCall({ region: REGION, maxInstances: 2, timeoutSeconds: 120 }, async req => {
  if (!req.auth) throw new HttpsError("unauthenticated", "Open the site first.");
  // Enchants are spells, not items, so they're never looked up.
  const names = [...new Set((Array.isArray(req.data && req.data.names) ? req.data.names : []).map(itemKey)
    .filter(n => n.length > 1 && !/^enchant /i.test(n)))].slice(0, 25);
  if (!names.length) return { found: {} };
  const ref = db().doc("guild/itemIds"), snap = await ref.get(), have = (snap.exists && snap.data().items) || {};
  if (Object.keys(have).length > 6000) return { found: {} };  // a ceiling, so junk names can't grow the list forever
  const now = Date.now(), WEEK = 7 * 864e5;
  const todo = names.filter(n => { const v = have[n.toLowerCase()]; return !v || (!v[0] && now - (+v[2] || 0) > WEEK); });
  const found = {};
  for (let i = 0; i < todo.length; i += 4) await Promise.all(todo.slice(i, i + 4).map(async n => {
    try { const hit = await whFind(n); found[n.toLowerCase()] = hit || [0, 0, now]; }
    catch (e) { logger.warn("item lookup failed", n, e.message); }  // not saved, so it's tried again next time
  }));
  if (Object.keys(found).length) {
    const { FieldPath } = require("firebase-admin/firestore");
    if (!snap.exists) await ref.set({ items: {} });
    const args = [];
    for (const [k, v] of Object.entries(found)) args.push(new FieldPath("items", k), v);
    await ref.update(...args);
  }
  return { found };
});

// Opting out: a player (or an officer for them) takes a character off the site for good. Its page is deleted,
// it's added to guild/optout (officers only can read it) so the roster sync never adds it back, and its name and
// numbers come out of the Hall of Firsts, Records snapshots and saved weekly recaps. "Let back in" removes the name
// from the list; the next sync then adds the character back fresh. Cards already posted in Discord can't be recalled.
exports.optOut = onCall({ region: REGION, maxInstances: 2, timeoutSeconds: 60 }, async req => {
  if (!req.auth) throw new HttpsError("unauthenticated", "Open the site first.");
  const off = (await db().doc("guild/officers").get()).data() || {}, officer = (off.uids || []).includes(req.auth.uid);
  const ref = db().doc("guild/optout"), list = ((await ref.get()).data() || {}).names || {}, now = new Date().toISOString();
  if (req.data && req.data.undo) {
    if (!officer) throw new HttpsError("permission-denied", "Only officers can do that.");
    const key = keyOf(req.data.undo);
    if (!list[key]) throw new HttpsError("not-found", "That name isn't on the opt-out list.");
    delete list[key]; await ref.set({ names: list, at: now });
    // Let the roster sync add them again.
    const rref = db().doc("guild/roster"), r = (await rref.get()).data() || {};
    if (Array.isArray(r.added)) await rref.set({ ...r, added: r.added.filter(k => k !== key) });
    return { ok: true };
  }
  const id = String((req.data && req.data.id) || "").slice(0, 60), snap = await db().doc(`members/${id}`).get();
  if (!snap.exists) throw new HttpsError("not-found", "Character not found.");
  const c = snap.data(), owner = Array.isArray(c.owners) && c.owners.includes(req.auth.uid);
  if (!officer && !owner) throw new HttpsError("permission-denied", "Only officers, or the player who claimed this character, can do that.");
  const name = plainName(c), key = keyOf(name);
  list[key] = { at: now, name: name.slice(0, 41) };
  await ref.set({ names: list, at: now });
  await db().doc(`members/${id}`).delete();
  // Hall of Firsts: the moment stays, the name goes.
  const fref = db().doc("guild/firsts"), f = (await fref.get()).data() || {}, fl = { ...(f.list || {}) };
  for (const [k, v] of Object.entries(fl)) if (v && v.id === id) fl[k] = { at: v.at, name: "A former guildie", cls: "" };
  if (f.list) await fref.set({ ...f, list: fl });
  // Records snapshots and saved recaps.
  const rref = db().doc("guild/records"), rec = (await rref.get()).data();
  if (rec && rec.days) { for (const day of Object.values(rec.days)) if (day) delete day[id]; await rref.set(rec); }
  const cref = db().doc("guild/recaps"), cap = (await cref.get()).data();
  if (cap) {
    if (cap.open && cap.open.rows) delete cap.open.rows[id];
    for (const w of Object.values(cap.weeks || {})) for (const k of ["lev", "kw", "loot", "firsts"]) if (Array.isArray(w[k])) w[k] = w[k].filter(x => (k === "firsts" ? x[1] : x[0]) !== name);
    await cref.set(cap);
  }
  // Title reigns and the title news.
  const tref = db().doc("guild/titles"), tt = (await tref.get()).data();
  if (tt) {
    for (const [k, v] of Object.entries(tt.holders || {})) if (v && v.id === id) delete tt.holders[k];
    tt.log = (tt.log || []).filter(x => !(x.to && x.to.id === id) && !(x.from && x.from.name === name));
    await tref.set(tt);
  }
  // And their streak.
  const sref = db().doc("guild/streaks"), ss = (await sref.get()).data();
  if (ss && ss.rows && ss.rows[id]) { delete ss.rows[id]; await sref.set(ss); }
  // Off the saved guild list too.
  const gref = db().doc("guild/roster"), g = (await gref.get()).data();
  if (g && Array.isArray(g.members)) await gref.set({ ...g, members: g.members.filter(x => keyOf(x.name) !== key) });
  logger.info("opted out", { by: officer ? "officer" : "owner" });
  return { ok: true };
});
// Privacy clean-up (officers): finds, and on request removes, data the site no longer uses: old fields on characters
// from removed features (notes, availability, time zone, wishlist, Discord link and so on), records in collections the
// site no longer reads (old groups, trades, events), and device codes more than a day old. Check first, then run.
const OLD_FIELDS = ["notes", "tz", "avail", "wishlist", "crafts", "shots", "showoff", "pic", "discordId", "link"];
const KEEP_COLLECTIONS = ["members", "alts", "links", "guild"];
exports.privacyCleanup = onCall({ region: REGION, maxInstances: 1, timeoutSeconds: 300 }, async req => {
  if (!req.auth) throw new HttpsError("unauthenticated", "Open the site first.");
  const off = (await db().doc("guild/officers").get()).data() || {};
  if (!(off.uids || []).includes(req.auth.uid)) throw new HttpsError("permission-denied", "Only officers can do that.");
  const run = !!(req.data && req.data.run), { FieldValue } = require("firebase-admin/firestore");
  const fields = {}, collections = {}; let links = 0;
  for (const coll of ["members", "alts"]) for (const d of (await db().collection(coll).get()).docs) {
    const data = d.data() || {}, old = OLD_FIELDS.filter(k => k in data);
    for (const k of old) fields[k] = (fields[k] || 0) + 1;
    if (run && old.length) await db().doc(`${coll}/${d.id}`).update(Object.fromEntries(old.map(k => [k, FieldValue.delete()])));
  }
  for (const c of await db().listCollections()) {
    if (KEEP_COLLECTIONS.includes(c.id)) continue;
    const docs = (await c.get()).docs; if (!docs.length) continue;
    collections[c.id] = docs.length;
    if (run) for (const d of docs) await d.ref.delete();
  }
  const dayAgo = new Date(Date.now() - 864e5).toISOString();
  for (const d of (await db().collection("links").get()).docs) {
    const at = (d.data() || {}).at; if (at && String(at) < dayAgo) { links++; if (run) await d.ref.delete(); }
  }
  logger.info("privacy clean-up", { run, fields, collections, links });
  return { run, fields, collections, links };
});
exports.setOfficer = onCall({ region: REGION, maxInstances: 2 }, async req => {
  if (!req.auth) throw new HttpsError("unauthenticated", "Open the site first.");
  const off = (await db().doc("guild/officers").get()).data() || {};
  if (!(off.uids || []).includes(req.auth.uid)) throw new HttpsError("permission-denied", "Only officers can do that.");
  const id = String((req.data && req.data.id) || "").slice(0, 60), on = !!(req.data && req.data.on);
  const snap = await db().doc(`members/${id}`).get();
  if (!snap.exists) throw new HttpsError("not-found", "Character not found.");
  const c = snap.data();
  if (on && !(Array.isArray(c.owners) && c.owners.length)) throw new HttpsError("failed-precondition", "They need to claim their character first.");
  if (!on && Object.values(off.pinned || {}).includes(id)) throw new HttpsError("failed-precondition", "This officer is set in the site's code (OFFICER_NAMES), so they can't be removed here.");
  const ref = db().doc("guild/officerPicks"), cur = ((await ref.get()).data() || {}).ids || [];
  await ref.set({ ids: on ? [...new Set([...cur, id])] : cur.filter(x => x !== id), at: new Date().toISOString() });
  await updateOfficers();
  return { ok: true };
});
// The guild's member list, from the same request the armory's guild page makes.
// Blizzard can change this request when they update their site; if that happens it logs a warning and everything else carries on.
const GUILD_SLUG = "blood-and-tears";
const ROSTER_QUERY = { operationName: "GetGuildRoster", variables: { guild: { nameSlug: GUILD_SLUG, region: "us" }, showMessageOfTheDay: false, showRoles: false },
  extensions: { persistedQuery: { version: 1, sha256Hash: "5f32b85faa248d321a08645d470fb38b82be64b9abd8b5b5fd2816620546794b" } } };
const keyOf = s => String(s || "").trim().toLowerCase().replace(/\s+/g, " ");
async function guildRoster() {
  // Ask for roles too (the guild page's "Role Breakdown"); if Blizzard refuses that, ask the original way.
  return (await guildRosterOnce(true).catch(() => null)) || guildRosterOnce(false);
}
async function guildRosterOnce(showRoles) {
  const res = await fetch("https://worldofwarcraft.blizzard.com/en-us/graphql", { method: "POST",
    headers: { "content-type": "application/json", accept: "application/json", "user-agent": "Mozilla/5.0 (compatible; BloodAndTearsGuildSite/1.0)",
      origin: "https://worldofwarcraft.blizzard.com", referer: `https://worldofwarcraft.blizzard.com/en-us/forever/us/armory/guild/${GUILD_SLUG}` },
    body: JSON.stringify({ ...ROSTER_QUERY, variables: { ...ROSTER_QUERY.variables, showRoles } }) });
  const j = await res.json().catch(() => null);
  const list = j && j.data && j.data.Guild && j.data.Guild.roster;
  if (!res.ok || !Array.isArray(list)) { logger.warn("guild roster: no list", { status: res.status, errors: j && j.errors }); return null; }
  const roleOf = c => { const sp = c.spec || {}; return roleFromRoster(sp.role && (sp.role.enum || sp.role.type || sp.role.name) || sp.role || c.role) || roleFromSpec(c.class && c.class.name, sp.name); };
  return list.filter(x => x && x.character && x.character.name).map(x => ({ c: x.character, rank: x.rank })).map(({ c, rank }) => ({
    first: String(c.name).slice(0, 20), last: String(c.surname || "").slice(0, 20), level: Math.max(1, Math.min(60, +c.level || 1)),
    cls: c.class && c.class.name || "", race: c.race && c.race.name || "", gender: c.gender && c.gender.name || "", rank: +(rank && rank.rankId), role: roleOf(c), spec: c.spec && c.spec.name || "", onArmory: !!c.url }));
}
// Adds guildies who aren't on the site yet (anyone can then claim theirs with "I'm already on here"),
// and raises levels from the roster, which updates sooner than character pages.
async function syncRoster() {
  const roster = await guildRoster().catch(e => { logger.warn("guild roster failed", e.message); return null; });
  if (!roster) return null;
  const ref = db().doc("guild/roster"), prev = (await ref.get()).data() || {};
  const firstImport = !prev.at, added = new Set(prev.added || []);
  // Characters whose players opted out: never added, never updated, and left off the saved guild list.
  const out = new Set(Object.keys(((await db().doc("guild/optout").get()).data() || {}).names || {}));
  const chars = [];
  for (const coll of ["members", "alts"]) for (const d of (await db().collection(coll).get()).docs) chars.push({ coll, id: d.id, data: d.data() });
  const byName = new Map(chars.map(c => [keyOf(c.data.first ? `${c.data.first} ${c.data.last || ""}` : c.data.char), c]));
  const now = new Date().toISOString(); let newOnes = 0, raised = 0;
  for (const g of roster) {
    const key = keyOf(`${g.first} ${g.last}`), have = byName.get(key);
    if (out.has(key)) continue;
    if (have) {
      const d = have.data, old = +d.level || 1, patch = {};
      if (g.level > old) { patch.level = g.level; patch.journey = [{ t: "Reached level " + g.level, at: now, from: old }, ...(Array.isArray(d.journey) ? d.journey : [])].slice(0, 40); raised++; }
      if (g.cls && !d.cls) patch.cls = g.cls;
      if (g.role && !d.roleEditedAt && g.role !== d.role && g.role !== d.role2 && g.role !== "DPS") patch.role = g.role;
      if (g.race && !d.race) patch.race = g.race;
      if (Object.keys(patch).length) { patch.updatedAt = now; await db().doc(`${have.coll}/${have.id}`).update(patch); }
    } else if (!added.has(key)) {
      // Never re-added once removed from the site.
      added.add(key); newOnes++;
      await db().collection("members").add({ first: g.first, last: g.last, char: `${g.first} ${g.last}`.trim(), level: g.level, cls: g.cls, race: g.race, ...(g.gender ? { gender: g.gender } : {}),
        role: g.role || (g.cls === "Priest" ? "Healer" : "DPS"), profs: {}, journey: [], fromGuild: true, ...(firstImport ? { quiet: true } : {}), createdAt: now, updatedAt: now });
    }
  }
  const members = roster.filter(g => !out.has(keyOf(`${g.first} ${g.last}`))).map(g => ({ name: `${g.first} ${g.last}`.trim(), level: g.level, cls: g.cls, rank: g.rank }));
  await ref.set({ at: now, members, added: [...added].slice(-500) });
  return { members: roster.length, added: newOnes, raised };
}
// Alts were dropped: every character is now its own entry. This moves any old alts over, once,
// giving them the same devices as the main they were filed under (so the same person can still edit them).
async function moveAlts() {
  const snap = await db().collection("alts").get();
  for (const d of snap.docs) {
    const { owner, ...rest } = d.data(), main = owner ? (await db().doc(`members/${owner}`).get()).data() || {} : {};
    const owners = Array.isArray(main.owners) && main.owners.length ? { owners: main.owners } : {};
    await db().doc(`members/${d.id}`).set({ ...rest, ...owners, quiet: true, updatedAt: new Date().toISOString() });
    await db().doc(`alts/${d.id}`).delete();
  }
  return snap.docs.length;
}
// ---------- Hall of Firsts ----------
// The guild's firsts: first to each level milestone, first blue and purple item, first PvP rank, first 100 honourable
// kills and first 300 in a profession. They're kept in guild/firsts, so they stay put even after a character's journey
// (only its last 40 entries) has moved on, and each run only ever keeps the earliest.
// Levels use the "Reached level" history. Someone who was already past a milestone when the site first saw them counts
// from when they were added, marked "by" that date; if several were added together, whoever was furthest ahead wins.
// The rest is "first seen with it", so it's as exact as the hourly check.
const FIRST_LEVELS = [10, 20, 30, 40, 50, 60];
const SKILL_MILESTONES = [75, 150, 225, 300];
const NOT_PROFS = ["Lockpicking", "Comprehension"];
const lvOfText = t => +String(t || "").replace(/\D/g, "");
const plainName = d => (d.first ? `${d.first} ${d.last || ""}`.trim() : String(d.char || "")) || "Someone";
// Guild milestones: the whole guild's totals passing round numbers. They're the same totals as the tiles on the roster
// (levels gained, blue and epic items on right now, honourable kills, level 60s), so keep the two matching (guildNums
// in public/index.html). Kept in guild/firsts as `milestones` ({levels500: {at}}), with when each was first passed.
// The first time they're counted, any already passed are marked "by", so the site doesn't celebrate old news.
const MILESTONES = { levels: [100, 250, 500, 1000, 1500, 2000, 3000], blues: [10, 25, 50, 100, 200], epics: [1, 10, 25, 50],
  hk: [1000, 5000, 10000, 25000, 50000], sixty: [1, 5, 10, 20] };
async function updateFirsts() {
  const ref = db().doc("guild/firsts"), cur = (await ref.get()).data() || {};
  const firstRun = !cur.list, list = { ...(cur.list || {}) }, start = { ...(cur.start || {}) }, now = new Date().toISOString();
  const byAt = (a, b) => String(a.at).localeCompare(String(b.at));
  const cands = {}, add = (k, e, rank) => (cands[k] = cands[k] || []).push({ ...e, rank });
  const tot = { levels: 0, blues: 0, epics: 0, hk: 0, sixty: 0 };
  const snap = await db().collection("members").get();
  for (const doc of snap.docs) {
    const d = doc.data() || {}, id = doc.id, lv = +d.level || 1, j = Array.isArray(d.journey) ? d.journey : [];
    tot.levels += Math.max(0, lv - 1); if (lv >= 60) tot.sixty++;
    for (const g of Object.values(d.gear || {})) if (g && g.id) { if (+g.q === 3) tot.blues++; else if (+g.q >= 4) tot.epics++; }
    const base = { id, name: plainName(d).slice(0, 41), cls: String(d.cls || "").slice(0, 12) };
    const ups = j.filter(x => x && /^Reached level \d+/.test(x.t || "") && x.at)
      .map(x => ({ to: lvOfText(x.t), from: x.from != null ? +x.from : lvOfText(x.t) - 1, at: x.at })).sort(byAt);
    // The level the site first saw them at: worked out once, while their history is still complete, then kept.
    // A full history (40 entries) may have lost its oldest lines, so that counts from level 1 (no "by" claims).
    if (start[id] == null) start[id] = j.length >= 40 ? 1 : ups.length ? Math.max(1, ups[0].from) : lv;
    for (const n of FIRST_LEVELS) {
      const hit = ups.find(u => u.from < n && u.to >= n);
      if (hit) add("lv" + n, { ...base, at: hit.at, by: false }, hit.to);
      else if (start[id] >= n && d.createdAt) add("lv" + n, { ...base, at: d.createdAt, by: true }, start[id]);
    }
    // Blue (rare) and purple (epic) items: the "Equipped" history, or what they had on when the site first looked.
    const eq = j.filter(x => x && /^Equipped /.test(x.t || "") && x.item && x.at).sort(byAt);
    for (const [k, q] of [["blue", 3], ["epic", 4]]) {
      const e = eq.find(x => +x.item.q >= q);
      const worn = Object.values(d.gear || {}).filter(g => g && g.id && +g.q >= q).sort((a, b) => +b.q - +a.q)[0];
      if (e) add(k, { ...base, at: e.at, by: false, item: { id: String(e.item.id), q: +e.item.q, name: String(e.t).slice(9, 129) } }, +e.item.q);
      else if (worn) add(k, { ...base, at: now, by: true, item: { id: String(worn.id), q: +worn.q, name: String(worn.name || "").slice(0, 120) } }, +worn.q);
    }
    const a = d.armory || {}, rank = +a.rank || 0, hk = +a.hk || 0;
    tot.hk += hk;
    const pvp = j.filter(x => x && /^Reached PvP /.test(x.t || "") && x.at).sort(byAt)[0];
    if (pvp) add("pvp", { ...base, at: pvp.at, by: false, note: String(pvp.t).slice(11, 60) }, rank);
    else if (rank >= 1) add("pvp", { ...base, at: now, by: firstRun, note: pvpRankName(rank) }, rank);
    if (hk >= 100) add("hk100", { ...base, at: now, by: firstRun }, hk);
    const top = Object.entries(d.profs || {}).filter(([p]) => !NOT_PROFS.includes(p)).sort((x, y) => (+y[1] || 0) - (+x[1] || 0))[0];
    if (top && +top[1] >= 300) add("prof300", { ...base, at: now, by: firstRun, note: String(top[0]).slice(0, 30) }, +top[1]);
  }
  let changed = firstRun || Object.keys(start).length !== Object.keys(cur.start || {}).length;
  for (const [k, arr] of Object.entries(cands)) {
    arr.sort((x, y) => byAt(x, y) || y.rank - x.rank || x.name.localeCompare(y.name));
    const { rank, ...best } = arr[0], old = list[k];
    if (!old || String(best.at) < String(old.at)) { list[k] = best; changed = true; }
  }
  const ms = { ...(cur.milestones || {}) }, firstMs = !cur.milestones;
  if (firstMs) changed = true;
  for (const [k, steps] of Object.entries(MILESTONES)) for (const n of steps)
    if (tot[k] >= n && !ms[k + n]) { ms[k + n] = firstMs ? { at: now, by: true } : { at: now }; changed = true; }
  if (changed) await ref.set({ list, start, milestones: ms, at: now });
  return list;
}
// Records "This week": once a day, each character's level, honourable kills, loot points and profession skills,
// so the site can show who moved up. guild/records = { days: { "2026-11-12": { <id>: [level, hk, loot, {prof: skill}] } } },
// the last 10 days only (about 5 KB a day for 50 characters).
const perthDay = () => new Date(Date.now() + 8 * 36e5).toISOString().slice(0, 10);
async function saveRecordsDay() {
  const ref = db().doc("guild/records"), cur = (await ref.get()).data() || {}, key = perthDay();
  const days = { ...(cur.days || {}) };
  if (days[key]) return;
  const row = {};
  for (const doc of (await db().collection("members").get()).docs) {
    const d = doc.data() || {}, a = d.armory || {};
    const loot = Object.values(d.gear || {}).reduce((t, g) => t + (g && g.id ? Math.max(0, +g.q - 1) : 0), 0);
    const profs = {};
    for (const [p, v] of Object.entries(d.profs || {})) if (!NOT_PROFS.includes(p) && +v > 0) profs[p] = +v;
    row[doc.id] = [+d.level || 1, +a.hk || 0, loot, profs];
  }
  days[key] = row;
  for (const k of Object.keys(days).sort().slice(0, -10)) delete days[k];
  await ref.set({ days, at: new Date().toISOString() });
}
// Weekly recaps, kept so the site can make the recap picture for any past week. guild/recaps holds
// open: the snapshot taken at the start of this week { wk, at, rows: { <id>: [level, hk, name, cls] } }, and
// weeks: { "2026-11-09": recap } for finished weeks (the last 52). When the week turns over, the open week is
// compared with now and saved. A week that started before this existed is marked partial (it starts at open.at).
async function saveWeekRecap() {
  const ref = db().doc("guild/recaps"), cur = (await ref.get()).data() || {}, wk = weekKey(), now = new Date().toISOString();
  const docs = (await db().collection("members").get()).docs.map(x => ({ id: x.id, d: x.data() || {} }));
  const rowsNow = {};
  for (const { id, d } of docs) rowsNow[id] = [+d.level || 1, +((d.armory || {}).hk) || 0, plainName(d).slice(0, 41), String(d.cls || "").slice(0, 12)];
  const open = cur.open, weeks = { ...(cur.weeks || {}) };
  if (open && open.wk === wk) return;
  if (open && open.rows) {
    const from = open.at, inWeek = t => t && t >= from && t < now;
    const lev = [], kw = [];
    let levels = 0, hk = 0, blues = 0, epics = 0;
    for (const { id, d } of docs) {
      for (const g of Object.values(d.gear || {})) if (g && g.id) { if (+g.q === 3) blues++; else if (+g.q >= 4) epics++; }
      const a = open.rows[id]; if (!a) continue;
      const b = rowsNow[id], dl = Math.max(0, b[0] - a[0]), dk = Math.max(0, b[1] - a[1]);
      levels += dl; hk += dk;
      if (dl) lev.push([b[2], b[3], dl]); if (dk) kw.push([b[2], b[3], dk]);
    }
    const loot = docs.flatMap(({ d }) => (Array.isArray(d.journey) ? d.journey : [])
      .filter(j => j && /^Equipped /.test(j.t || "") && j.item && +j.item.q >= 3 && inWeek(j.at))
      .map(j => [plainName(d).slice(0, 41), String(d.cls || "").slice(0, 12), String(j.t).slice(9, 129), +j.item.q, String(j.item.id || ""), j.at]))
      .sort((x, y) => y[3] - x[3] || String(y[5]).localeCompare(String(x[5]))).slice(0, 5);
    const fl = ((await db().doc("guild/firsts").get()).data() || {}).list || {};
    const firsts = Object.entries(fl).filter(([, f]) => f && !f.by && inWeek(f.at)).map(([k, f]) => [k, f.name || "", f.cls || "", f.at, f.item || null]).slice(0, 6);
    const top = l => l.sort((x, y) => y[2] - x[2]).slice(0, 5);
    weeks[open.wk] = { from, to: now, partial: !open.full, totals: { levels, hk, blues, epics }, lev: top(lev), kw: top(kw), loot, firsts };
    for (const k of Object.keys(weeks).sort().slice(0, -52)) delete weeks[k];
  }
  // A week opened by the first run after the week turned over counts as the full week.
  await ref.set({ open: { wk, at: now, full: !!open, rows: rowsNow }, weeks, at: now });
}
// Title reigns: who is alone at the top of the boards the server can work out from what it already reads
// (honourable kills, loot points and each profession), and since when.
// guild/titles = { holders: { <key>: { id, name, cls, since } }, log: [ { at, k, to: { id, name, cls }, from: { name, cls } | null } ] }
// (the last 60 changes). Keys are "hk", "gear" and "p:<Profession>". The site shows "3 weeks running" from `since`
// and the changes in the Guild Feed. A tie means nobody holds the title, the same rule the site uses.
const TITLE_PROFS = ["Alchemy", "Blacksmithing", "Enchanting", "Engineering", "Herbalism", "Leatherworking", "Mining", "Skinning", "Tailoring", "Cooking", "First Aid", "Fishing"];
async function saveTitles() {
  const ref = db().doc("guild/titles"), cur = (await ref.get()).data() || {}, now = new Date().toISOString();
  const roster = ((await db().doc("guild/roster").get()).data() || {}).members;
  const inGuild = Array.isArray(roster) && roster.length ? new Set(roster.map(x => keyOf(x && x.name))) : null;
  const ms = [];
  for (const doc of (await db().collection("members").get()).docs) {
    const d = doc.data() || {}, name = plainName(d);
    if (inGuild && !inGuild.has(keyOf(name))) continue; // people who have left don't hold titles
    ms.push({ id: doc.id, name: name.slice(0, 41), cls: String(d.cls || "").slice(0, 12), hk: +((d.armory || {}).hk) || 0,
      gear: Object.values(d.gear || {}).reduce((t, g) => t + (g && g.id ? Math.max(0, +g.q - 1) : 0), 0), profs: d.profs || {} });
  }
  const boards = [["hk", m => m.hk], ["gear", m => m.gear], ...TITLE_PROFS.map(p => ["p:" + p, m => +m.profs[p] || 0])];
  const old = cur.holders || {}, holders = {}, log = Array.isArray(cur.log) ? cur.log.slice() : [], first = !cur.holders;
  for (const [k, get] of boards) {
    const rows = ms.map(m => [m, get(m)]).filter(x => x[1] > 0).sort((a, b) => b[1] - a[1]);
    const lead = rows.length > 1 && rows[0][1] > rows[1][1] ? rows[0][0] : null;
    if (!lead) continue;
    const was = old[k];
    if (was && was.id === lead.id) holders[k] = { ...was, name: lead.name, cls: lead.cls };
    else {
      holders[k] = { id: lead.id, name: lead.name, cls: lead.cls, since: now };
      // The very first run just notes who holds what; it isn't news.
      if (!first) log.push({ at: now, k, to: { id: lead.id, name: lead.name, cls: lead.cls }, from: was ? { name: was.name, cls: was.cls } : null });
    }
  }
  if (!first && JSON.stringify(holders) === JSON.stringify(old)) return;
  await ref.set({ holders, log: log.slice(-60), at: now });
}
// Streaks: how many days in a row each character has been seen in game. The armory says when a character last logged out;
// when that lands on a new day (Perth time), their streak grows by one if the last day counted was the day before, or
// starts again at 1. guild/streaks = { rows: { <id>: { n, last: "2026-11-13" } } }. The site shows it while `last` is today or yesterday.
async function saveStreaks() {
  const ref = db().doc("guild/streaks"), cur = (await ref.get()).data() || {}, rows = { ...(cur.rows || {}) };
  const dayOf = iso => { const t = Date.parse(iso || ""); return t ? new Date(t + 8 * 36e5).toISOString().slice(0, 10) : ""; };
  const next = d => new Date(Date.parse(d + "T00:00:00Z") + 864e5).toISOString().slice(0, 10);
  const prev = d => new Date(Date.parse(d + "T00:00:00Z") - 864e5).toISOString().slice(0, 10);
  const docs = (await db().collection("members").get()).docs;
  let changed = false; const ids = new Set();
  // The first time only: work out streaks so far from what the site already knows. A day counts when the armory showed
  // something new that day (a level, an item, a skill-up, a kill milestone) or the daily snapshot changed across it.
  // It can only undercount: a day spent playing with nothing new to show isn't seen.
  // One allowance, for characters added in launch week (5 to 11 November): if the run of days is unbroken as far back as
  // their history goes, and that history either starts within a day of when they were added or has been cut off at its
  // 40-line limit, the streak is counted from the day they were added. That's an inference, not a record.
  const LOOK_BACK = 2, LAUNCH_DAY = "2026-11-05", LAUNCH_END = "2026-11-12";
  if ((+cur.backfill || 0) < LOOK_BACK) {
    const days = ((await db().doc("guild/records").get()).data() || {}).days || {}, keys = Object.keys(days).sort();
    const game = /^(Reached |Equipped |Got |Trained )| reached (Apprentice|Journeyman|Expert|Artisan)$/;
    for (const doc of docs) {
      const d = doc.data() || {}, on = new Set();
      for (const j of Array.isArray(d.journey) ? d.journey : []) if (j && game.test(String(j.t || ""))) { const k = dayOf(j.at); if (k) on.add(k); }
      // Each snapshot is taken early in its day, so a change between two of them happened on the earlier day.
      for (let i = 0; i + 1 < keys.length; i++) {
        const a = days[keys[i]][doc.id], b = days[keys[i + 1]][doc.id];
        if (a && b && next(keys[i]) === keys[i + 1] && JSON.stringify(a) !== JSON.stringify(b)) on.add(keys[i]);
      }
      const seen = dayOf((d.armory || {}).updated); if (seen) on.add(seen);
      if (!on.size) continue;
      const sorted = [...on].sort(), last = sorted.pop(), first = sorted[0] || last; let n = 1, k = prev(last);
      while (on.has(k)) { n++; k = prev(k); }
      const start = next(k), made = dayOf(d.createdAt), from = made && made < LAUNCH_DAY ? LAUNCH_DAY : made;
      const full = (Array.isArray(d.journey) ? d.journey : []).length >= 40;
      if (from && from < LAUNCH_END && start === first && from < start && (full || next(from) === start))
        n += Math.round((Date.parse(start + "T00:00:00Z") - Date.parse(from + "T00:00:00Z")) / 864e5);
      const was = rows[doc.id];
      if (!was || was.last < last || (was.last === last && (+was.n || 0) < n)) { rows[doc.id] = { n, last }; changed = true; }
    }
    changed = true;
  }
  for (const doc of docs) {
    ids.add(doc.id);
    const day = dayOf(((doc.data() || {}).armory || {}).updated), was = rows[doc.id];
    if (!day || (was && was.last >= day)) continue;
    rows[doc.id] = { n: was && next(was.last) === day ? (+was.n || 0) + 1 : 1, last: day }; changed = true;
  }
  for (const id of Object.keys(rows)) if (!ids.has(id)) { delete rows[id]; changed = true; }
  if (changed) await ref.set({ rows, backfilled: true, backfill: LOOK_BACK, at: new Date().toISOString() });
}
async function syncAll() {
  let n = 0, changed = 0; const missing = [];
  await moveAlts().catch(err => logger.warn("moving alts", err.message));
  const roster = await syncRoster();
  await updateOfficers().catch(err => logger.warn("officers", err.message));
  for (const coll of ["members", "alts"]) {
    const snap = await db().collection(coll).get();
    for (const d of snap.docs) {
      try { const r = await syncChar(coll, d.id, d.data()); n++; if (r && (r.changed || []).length) changed++; if (r && !r.found) missing.push(plainName(d.data()).slice(0, 41)); }
      catch (e) { logger.warn("armory sync failed", d.id, e.message); }
      await new Promise(r => setTimeout(r, 400)); // be gentle with Blizzard's site
    }
  }
  await updateFirsts().catch(err => logger.warn("firsts", err.message));
  await saveRecordsDay().catch(err => logger.warn("records", err.message));
  await saveWeekRecap().catch(err => logger.warn("recaps", err.message));
  await saveTitles().catch(err => logger.warn("titles", err.message));
  await saveStreaks().catch(err => logger.warn("streaks", err.message));
  const now = new Date().toISOString(), prev = (await db().doc("guild/armory").get()).data() || {};
  // Remember when the guild list was last read, and say so if it couldn't be (Blizzard may have changed their site).
  // missing: characters the armory had no page for this time (new, under level 10, or renamed), so the roster can say so.
  await db().doc("guild/armory").set({ at: now, checked: n, changed, missing: missing.slice(0, 20), missingN: missing.length, roster: roster ? { ...roster, at: now } : { ...(prev.roster || {}), error: now } });
  return { checked: n, changed, roster };
}
// Every hour, check everyone.
exports.armorySyncAll = onSchedule({ schedule: "every 1 hours", timeZone: "Australia/Perth", region: REGION, timeoutSeconds: 540 }, syncAll);
// "Sync" buttons: one character ({coll, id}) or everyone ({all: true}). Anyone on the site can use them,
// with a short cooldown so the button can't hammer Blizzard's site.
exports.armorySync = onCall({ region: REGION, maxInstances: 2, timeoutSeconds: 300 }, async req => {
  if (!req.auth) throw new HttpsError("unauthenticated", "Open the site first.");
  const now = Date.now();
  if (req.data && req.data.all) {
    // Moving old alts over is quick, so it happens even when the armory check is on cooldown.
    const moved = await moveAlts().catch(err => { logger.warn("moving alts", err.message); return 0; });
    const last = (await db().doc("guild/armory").get()).data();
    if (last && last.at && now - Date.parse(last.at) < 10 * 60 * 1000) return { all: true, skipped: true, at: last.at, moved };
    await db().doc("guild/armory").set({ at: new Date().toISOString(), running: true }, { merge: true });
    return { all: true, ...(await syncAll()) };
  }
  const coll = req.data && req.data.coll === "alts" ? "alts" : "members", id = String((req.data && req.data.id) || "").slice(0, 60);
  const snap = await db().doc(`${coll}/${id}`).get();
  if (!snap.exists) throw new HttpsError("not-found", "Character not found.");
  const d = snap.data();
  if (d.armory && d.armory.at && now - Date.parse(d.armory.at) < 60 * 1000) return { found: true, level: d.level, changed: [], recent: true };
  const r = await syncChar(coll, id, d);
  await updateFirsts().catch(err => logger.warn("firsts", err.message));
  return r;
});

// While Discord is off, these aren't deployed at all, so deploys don't need the Discord secrets.
if (!DISCORD_ON) for (const k of ["newMember", "memberChanged", "altChanged", "dailyDigest"]) delete exports[k];
