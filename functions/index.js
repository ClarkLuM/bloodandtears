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
// Discord posts, the daily digest and slash commands are switched off for now (the code is all kept).
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
  if (a.rank && prevA.rank !== undefined && a.rank > +prevA.rank) { journey.unshift({ t: "Reached PvP " + pvpRankName(a.rank), at: now }); changed = true; what.push("PvP rank"); }
  if (changed) { patch.updatedAt = now; patch.journey = journey.slice(0, 40); }
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
  const chars = [];
  for (const coll of ["members", "alts"]) for (const d of (await db().collection(coll).get()).docs) chars.push({ coll, id: d.id, data: d.data() });
  const byName = new Map(chars.map(c => [keyOf(c.data.first ? `${c.data.first} ${c.data.last || ""}` : c.data.char), c]));
  const now = new Date().toISOString(); let newOnes = 0, raised = 0;
  for (const g of roster) {
    const key = keyOf(`${g.first} ${g.last}`), have = byName.get(key);
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
  const members = roster.map(g => ({ name: `${g.first} ${g.last}`.trim(), level: g.level, cls: g.cls, rank: g.rank }));
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
async function syncAll() {
  let n = 0, changed = 0;
  await moveAlts().catch(err => logger.warn("moving alts", err.message));
  const roster = await syncRoster();
  await updateOfficers().catch(err => logger.warn("officers", err.message));
  for (const coll of ["members", "alts"]) {
    const snap = await db().collection(coll).get();
    for (const d of snap.docs) {
      try { const r = await syncChar(coll, d.id, d.data()); n++; if (r && (r.changed || []).length) changed++; }
      catch (e) { logger.warn("armory sync failed", d.id, e.message); }
      await new Promise(r => setTimeout(r, 400)); // be gentle with Blizzard's site
    }
  }
  await updateFirsts().catch(err => logger.warn("firsts", err.message));
  const now = new Date().toISOString(), prev = (await db().doc("guild/armory").get()).data() || {};
  // Remember when the guild list was last read, and say so if it couldn't be (Blizzard may have changed their site).
  await db().doc("guild/armory").set({ at: now, checked: n, changed, roster: roster ? { ...roster, at: now } : { ...(prev.roster || {}), error: now } });
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

// ---------- Discord slash commands ----------
// A Discord app (Developer Portal) points its Interactions Endpoint URL at discordInteractions. Discord sends each
// command here; nothing runs between commands, so there's no bot to keep online. Secrets: DISCORD_APP_ID,
// DISCORD_PUBLIC_KEY (both from the app's General Information page) and DISCORD_BOT_TOKEN (Bot page, used only to
// install the commands on a server).
const { onRequest } = require("firebase-functions/v2/https");
const DC_APP = dcSecret("DISCORD_APP_ID"), DC_KEY = dcSecret("DISCORD_PUBLIC_KEY"), DC_TOKEN = dcSecret("DISCORD_BOT_TOKEN");
const DUNGEONS = [["Ragefire Chasm","13–18"],["Hall of Thanes","13–18"],["Ruins of Lordaeron","15–20"],["The Deadmines","15–22"],["Wailing Caverns","17–24"],
  ["Shadowfang Keep","20–26"],["Blackfathom Deeps","22–28"],["Excavation Site: Wetlands","24–29"],["The Stockade","25–29"],["City of Dalaran","28–33"],
  ["Gnomeregan","29–38"],["Razorfen Kraul","29–38"],["Scarlet Monastery: Graveyard","30–38"],["Scarlet Monastery: Library","33–41"],["The Drowned City","35–40"],
  ["Scarlet Monastery: Armory","36–44"],["Uldaman","36–45"],["Razorfen Downs","37–46"],["Scarlet Monastery: Cathedral","38–46"],["Zul'Farrak","40–47"],
  ["Krol'Dok Stronghold","40–45"],["Maraudon","45–51"],["Alcaz Island Prison","48–53"],["Sunken Temple","50–55"],["Blackrock Depths","52–60"],
  ["Blackmaw Hold","55–60"],["Lower Blackrock Spire","57–60"],["Dire Maul: East","58–60"],["Shaper's Terrace","58–60"],["Stratholme: Living","58–60"],
  ["Stratholme: Undead","58–60"],["Scholomance","58–60"],["Upper Blackrock Spire","60"],["Dire Maul: West","60"],["Dire Maul: North","60"]];
const CLASS_HEX = { Warrior: 0xC69B6D, Paladin: 0xF48CBA, Hunter: 0xAAD372, Rogue: 0xFFF468, Priest: 0xFFFFFF, Shaman: 0x0070DD, Mage: 0x3FC7EB, Warlock: 0x8788EE, Druid: 0xFF7C0A };
const rangeOf = r => { const m = /^(\d+)(?:–(\d+))?$/.exec(r || ""); return m ? [+m[1], +(m[2] || m[1])] : null; };
const WHEN = [["now", "Now"], ["1h", "In an hour"], ["2h", "In two hours"], ["t19", "Today 7pm"], ["t20", "Today 8pm"], ["m19", "Tomorrow 7pm"], ["m20", "Tomorrow 8pm"]];
const COMMANDS = [
  { name: "card", description: "Show a guildie's character card", options: [{ type: 3, name: "name", description: "Character name", required: true, autocomplete: true }] },
  { name: "who", description: "Who's in range for a dungeon", options: [{ type: 3, name: "dungeon", description: "Dungeon", required: true, autocomplete: true }] },
  { name: "lfg", description: "Post a group on the guild site", options: [
    { type: 3, name: "dungeon", description: "Dungeon (or type anything)", required: true, autocomplete: true },
    { type: 3, name: "when", description: "When", required: false, choices: WHEN.map(([value, name]) => ({ name, value })) },
    { type: 3, name: "note", description: "A short note, like 'need a healer'", required: false, max_length: 140 },
    { type: 3, name: "character", description: "Which of your characters (if you have more than one)", required: false, autocomplete: true }] },
  { name: "link", description: "Link your Discord to your character on the guild site", options: [
    { type: 3, name: "code", description: "The code from 'Link Discord' on your character page", required: true, min_length: 6, max_length: 6 }] }];
const charName = c => c.first ? `${c.first} ${c.last || ""}`.trim() : String(c.char || "Someone");
const reply = (res, content, extra = {}) => res.json({ type: 4, data: { content, allowed_mentions: { parse: [] }, ...extra } });
const secret = (res, content) => reply(res, content, { flags: 64 }); // only the person who typed it sees it
function verifyDiscord(req) {
  try {
    const sig = req.get("x-signature-ed25519"), ts = req.get("x-signature-timestamp");
    if (!sig || !ts || !req.rawBody) return false;
    const crypto = require("crypto");
    const key = crypto.createPublicKey({ key: { kty: "OKP", crv: "Ed25519", x: Buffer.from(DC_KEY.value().trim(), "hex").toString("base64url") }, format: "jwk" });
    return crypto.verify(null, Buffer.concat([Buffer.from(ts), req.rawBody]), key, Buffer.from(sig, "hex"));
  } catch (e) { logger.warn("discord signature", e.message); return false; }
}
// Times for /lfg, in the character's own time zone (AWST, ACST or AEST, with daylight saving where they use it).
function whenIso(code, c) {
  const now = Date.now(); if (!code || code === "now") return new Date(now).toISOString();
  if (code === "1h" || code === "2h") return new Date(now + (code === "1h" ? 1 : 2) * 36e5).toISOString();
  const base = { AWST: 8, ACST: 9.5, AEST: 10 }[c.tz] || 8, off = base + (c.tz !== "AWST" && c.dst ? 1 : 0);
  const local = new Date(now + off * 36e5); if (code[0] === "m") local.setUTCDate(local.getUTCDate() + 1);
  local.setUTCHours(+code.slice(1), 0, 0, 0); return new Date(local.getTime() - off * 36e5).toISOString();
}
const statLine = a => { const s = (a && a.stats) || {}; return [s.health ? `${Math.round(s.health).toLocaleString("en-AU")} HP` : "", a && a.ilvl ? `item level ${a.ilvl}` : "", a && a.hk ? `${a.hk} kills` : ""].filter(Boolean).join(" · "); };
exports.discordInteractions = onRequest({ region: REGION, secrets: DISCORD_ON ? [DC_KEY] : [], maxInstances: 3, timeoutSeconds: 10 }, async (req, res) => {
  if (req.method !== "POST" || !verifyDiscord(req)) { res.status(401).send("bad signature"); return; }
  const i = req.body || {};
  if (i.type === 1) { res.json({ type: 1 }); return; } // Discord checking the URL works
  const cmd = i.data && i.data.name, opts = Object.fromEntries(((i.data && i.data.options) || []).map(o => [o.name, o.value]));
  const user = (i.member && i.member.user) || i.user || {};
  const members = () => db().collection("members").get().then(s => s.docs.map(d => ({ id: d.id, ...d.data() })));
  try {
    // Autocomplete: names and dungeons as you type.
    if (i.type === 4) {
      const focus = ((i.data.options || []).find(o => o.focused) || {}), q = String(focus.value || "").toLowerCase();
      let list = [];
      if (focus.name === "dungeon") list = DUNGEONS.filter(([n]) => n.toLowerCase().includes(q)).map(([n, r]) => ({ name: `${n} (${r})`, value: n }));
      else if (focus.name === "character") list = (await members()).filter(c => c.discordId === user.id).map(c => ({ name: charName(c), value: c.id }));
      else list = (await members()).filter(c => charName(c).toLowerCase().includes(q)).sort((a, b) => (+b.level || 0) - (+a.level || 0)).map(c => ({ name: `${charName(c)} · ${c.level || 1}`, value: charName(c) }));
      res.json({ type: 8, data: { choices: list.slice(0, 25) } }); return;
    }
    if (cmd === "card") {
      const q = String(opts.name || "").toLowerCase(), all = await members();
      const c = all.find(x => charName(x).toLowerCase() === q) || all.find(x => charName(x).toLowerCase().includes(q));
      if (!c) return secret(res, `Couldn't find "${clean(opts.name)}" on the guild site.`);
      const a = c.armory || {}, profs = Object.entries(c.profs || {}).sort((x, y) => y[1] - x[1]).slice(0, 2).map(([p, v]) => `${p} ${v}`).join(" · ");
      const pic = typeof a.avatar === "string" && /^https:\/\/render\.worldofwarcraft\.com\//.test(a.avatar) ? a.avatar : "";
      return reply(res, "", { embeds: [{ title: charName(c), url: `${SITE}/#char/members/${c.id}`, color: CLASS_HEX[c.cls] || GOLD,
        description: `Level ${c.level || 1} ${[c.race, c.spec || (a.spec || ""), c.cls].filter(Boolean).join(" ")} · ${c.role || "DPS"}${c.role2 ? " / " + c.role2 : ""}`,
        fields: [statLine(a) ? { name: "Stats", value: statLine(a), inline: true } : null, profs ? { name: "Professions", value: profs, inline: true } : null].filter(Boolean),
        ...(pic ? { thumbnail: { url: pic } } : {}), footer: { text: "Blood and Tears" } }] });
    }
    if (cmd === "who") {
      const d = DUNGEONS.find(([n]) => n.toLowerCase() === String(opts.dungeon || "").toLowerCase()) || DUNGEONS.find(([n]) => n.toLowerCase().includes(String(opts.dungeon || "").toLowerCase()));
      if (!d) return secret(res, "Pick a dungeon from the list.");
      const [lo, hi] = rangeOf(d[1]), ppl = (await members()).filter(c => +c.level >= lo && +c.level <= hi).sort((a, b) => (+b.level || 0) - (+a.level || 0));
      const roles = ["Tank", "Healer", "DPS"].map(r => { const n = ppl.filter(c => c.role === r || c.role2 === r).length; return `${n} ${r === "DPS" ? "DPS" : r.toLowerCase() + (n === 1 ? "" : "s")}`; }).join(" · ");
      return reply(res, "", { embeds: [{ title: `Who's in range for ${d[0]} (${d[1]})`, url: `${SITE}/#lfg`, color: GOLD,
        description: ppl.length ? `${roles}\n\n` + ppl.slice(0, 25).map(c => `**${clean(charName(c))}** · ${c.role || "DPS"}${c.role2 ? "/" + c.role2 : ""} ${c.level}`).join("\n") : "Nobody's at the right level yet." }] });
    }
    if (cmd === "link") {
      const code = String(opts.code || "").toUpperCase().replace(/[^A-Z0-9]/g, ""), ref = db().doc(`dlinks/${code}`), l = (await ref.get()).data();
      if (!l || !l.member) return secret(res, "That code didn't work. On the guild site, open your character and tap Link Discord for a new one.");
      await db().doc(`members/${l.member}`).update({ discordId: String(user.id) }); await ref.delete();
      const c = (await db().doc(`members/${l.member}`).get()).data() || {};
      return secret(res, `Linked! You're **${clean(charName(c))}**. Now try \`/lfg\`.`);
    }
    if (cmd === "lfg") {
      const mine = (await members()).filter(c => c.discordId === String(user.id)).sort((a, b) => (+b.level || 0) - (+a.level || 0));
      if (!mine.length) return secret(res, `Link your character first: on ${SITE}, open your character, tap **Link Discord**, then type \`/link\` with the code.`);
      const c = mine.find(x => x.id === opts.character) || mine[0];
      const d = DUNGEONS.find(([n]) => n.toLowerCase() === String(opts.dungeon || "").toLowerCase());
      const goal = { id: Math.random().toString(36).slice(2, 10), ...(d ? { kind: "dungeon", t: d[0], range: d[1] } : { kind: "other", t: String(opts.dungeon || "").slice(0, 80) }),
        lfg: true, done: false, at: new Date().toISOString(), when: whenIso(opts.when, c), ...(opts.note ? { note: String(opts.note).slice(0, 140) } : {}) };
      const goals = Array.isArray(c.goals) ? c.goals : [];
      if (goals.length >= 50) return secret(res, "That character has 50 goals. Clear some finished ones on the site first.");
      await db().doc(`members/${c.id}`).update({ goals: [...goals, goal], updatedAt: new Date().toISOString() });
      return secret(res, `Posted **${clean(goal.t)}** for ${clean(charName(c))}, <t:${Math.floor(Date.parse(goal.when) / 1000)}:R>. It's on the site's Groups page and in the LFG channel.`);
    }
    return secret(res, "I don't know that command yet.");
  } catch (e) { logger.error("discord command failed", cmd, e.message); return secret(res, "Something went wrong. Try again in a moment."); }
});
// Officers install (or update) the commands on a server from the site. The app must be added to that server first.
exports.discordRegister = onCall({ region: REGION, secrets: DISCORD_ON ? [DC_APP, DC_TOKEN] : [] }, async req => {
  if (!req.auth) throw new HttpsError("unauthenticated", "Open the site first.");
  const off = (await db().doc("guild/officers").get()).data() || {};
  if (!(off.uids || []).includes(req.auth.uid)) throw new HttpsError("permission-denied", "Only officers can do that.");
  const app = DC_APP.value().trim(), guild = String((req.data && req.data.guild) || "").replace(/\D/g, "");
  const invite = `https://discord.com/oauth2/authorize?client_id=${app}&scope=applications.commands`;
  if (!guild) return { ok: false, invite };
  const r = await fetch(`https://discord.com/api/v10/applications/${app}/guilds/${guild}/commands`, { method: "PUT",
    headers: { authorization: "Bot " + DC_TOKEN.value().trim(), "content-type": "application/json" }, body: JSON.stringify(COMMANDS) });
  if (!r.ok) { const t = await r.text(); logger.warn("discord register", r.status, t); return { ok: false, status: r.status, invite, error: r.status === 403 || r.status === 50001 ? "The app isn't on that server yet." : t.slice(0, 200) }; }
  return { ok: true, invite, count: COMMANDS.length };
});

// While Discord is off, these aren't deployed at all, so deploys don't need the Discord secrets.
if (!DISCORD_ON) for (const k of ["newMember", "memberChanged", "altChanged", "dailyDigest", "discordInteractions", "discordRegister"]) delete exports[k];
