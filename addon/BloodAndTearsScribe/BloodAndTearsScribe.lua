-- This addon is split over several files, loaded in the order the .toc lists them:
--   SiteData.lua         what the site last sent (written by the site's "Download for the addon" button)
--   RecipeData.lua       every recipe, what it makes and needs (written by tools/recipes/addon_data.py)
--   BloodAndTearsScribe.lua  this file: the notes, sharing, the window and its main tabs
--   Pages.lua            the Loot tab, the Alts page and the right-click menu, built from the parts this file lends out
-- Item lookups: newer clients moved these into C_Item, so never call a missing one.
local Item = {}
do
  local function call(fn, ...)
    if not fn then return end
    local ok, a, b, c = pcall(fn, ...)
    if ok then return a, b, c end
  end
  local info = function(x) return call(GetItemInfo or (C_Item and C_Item.GetItemInfo), x) end
  function Item.link(x) local _, l = info(x); return type(l) == "string" and l or nil end
  function Item.quality(x) local _, _, q = info(x); return q end
  function Item.icon(id)
    if id < 0 then return (call(GetSpellTexture or (C_Spell and C_Spell.GetSpellTexture), -id)) end
    local t = call(GetItemIcon or (C_Item and C_Item.GetItemIconByID), id)
    if t then return t end
    local fn = GetItemInfoInstant or (C_Item and C_Item.GetItemInfoInstant)
    if fn then local ok, _, _, _, _, ic = pcall(fn, id); if ok then return ic end end
  end
  -- The site's recipe data (the block at the end of this file), read once when first asked for.
  local byName, lists
  local function build()
    byName, lists = {}, {}
    for prof, str in pairs(Item.rec or {}) do
      local l = {}; lists[prof] = l
      for row in str:gmatch("[^\n]+") do
        local name, skill, src, reag = row:match("^(.-)~(%d+)~(%a?)~(.*)$")
        if name then
          local e = { name = name, prof = prof, skill = tonumber(skill) or 0, src = src, reag = {} }
          for id, q in reag:gmatch("(%d+):(%d+)") do e.reag[#e.reag + 1] = { tonumber(id), tonumber(q) } end
          l[#l + 1] = e
          if not byName[name] then byName[name] = e end
        end
      end
    end
  end
  -- The data itself comes from RecipeData.lua (loaded first).
  do local _, ns = ...; if ns then Item.ids, Item.rec, Item.rn = ns.ids or {}, ns.rec or {}, ns.rn or {} end end
  function Item.info(name) if not byName then build() end return name and byName[name] or nil end
  function Item.list(prof) if not byName then build() end return lists[prof] end
  function Item.reagName(id) return (Item.rn and Item.rn[id]) or ("item " .. id) end
  Item.SRC = { T = "from a trainer", R = "from a recipe (vendor, drop or quest)", A = "known automatically" }
  -- Adds what a recipe needs to the tooltip being shown.
  function Item.tipRecipe(name)
    local e = Item.info(name)
    if not e then return end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(e.prof .. " " .. e.skill .. (Item.SRC[e.src] and (", " .. Item.SRC[e.src]) or ""), 0.88, 0.66, 0.38)
    for _, r in ipairs(e.reag) do GameTooltip:AddLine(r[2] .. " x " .. Item.reagName(r[1]), 0.94, 0.90, 0.89) end
  end
end

-- Blood and Tears Scribe
-- While you play, this reads the in-game guild list every five minutes and notes, for each member: their level (and when
-- it went up), rank,
-- when they were last online, which days they were on, and the last zone they were seen in. It adds up how long
-- guildies spend in each zone (for the site's zone map). It also notes how many
-- guildies are online each hour, joins and leaves, who was in your group inside a dungeon or raid, every boss your
-- group kills there and the good loot it gets, and the
-- recipes your own characters know (when you open a profession window).
--
-- Everything is kept in BloodAndTearsScribeDB. The game saves it to
--   World of Warcraft\_forever_\WTF\Account\<ACCOUNT>\SavedVariables\BloodAndTearsScribe.lua
-- when you log out or type /reload. Upload THAT file on the site (Roster > Details > Upload the scribe file),
-- not this one: this is the addon itself. The notes file starts with "BloodAndTearsScribeDB = {".
-- From 0.10.0 copies of the addon in the guild share their notes with each other over the game's hidden addon channel
-- (never outside the game; the Scribe tab can turn it off): hours online, zone time, dungeon runs and boss kills,
-- last-seen times, and each player's own professions and recipes. So one upload carries what every scribe saw.
-- From 0.8.0 it keeps out of your chat: a small window (the gingerbread button
-- on the minimap, or /scribe) shows who's online and where, today's runs, drops and dings, the week's busiest zones
-- and hours, and what's in the notes file. When you log out it shows a summary of your session (/scribe summary any time).

local ADDON, NS = ...
NS = NS or {}
local VERSION = 7
local DAYS_KEPT = 60          -- days of "seen" days kept per member
local HOURS_KEPT = 42         -- days of hourly online counts kept
local EVENTS_KEPT = 200       -- joins and leaves
local RAIDS_KEPT = 60
local RUNS_KEPT = 120         -- dungeon runs (who was in your group inside a dungeon, per dungeon per day)
local KILLS_KEPT = 300        -- boss kills in dungeons and raids
local LOOT_KEPT = 300         -- uncommon-or-better loot your group received inside dungeons and raids
local ZONE_DAYS_KEPT = 42    -- days of minutes-per-zone kept
local PERTH = 8 * 3600        -- the guild's day runs on Perth time

local f = CreateFrame("Frame")
local db
local refresh = function() end   -- redraws the window; set further down, once the window exists
local shareRecipes = function() end   -- sends a freshly read recipe list to other scribes; set with the sharing below

local function now() return (GetServerTime and GetServerTime()) or time() end
local function dayOf(t) return date("!%Y-%m-%d", t + PERTH) end
local function hourOf(t) return date("!%Y-%m-%d %H", t + PERTH) end
local function short(n) return n and (Ambiguate and Ambiguate(n, "none") or n:gsub("%-.*$", "")) end

local function init()
  BloodAndTearsScribeDB = BloodAndTearsScribeDB or {}
  db = BloodAndTearsScribeDB
  db.v = VERSION
  db.members = db.members or {}
  db.events = db.events or {}
  db.raids = db.raids or {}
  db.hours = db.hours or {}
  db.recipes = db.recipes or {}
  db.runs = db.runs or {}
  db.kills = db.kills or {}
  db.loot = db.loot or {}
  db.lastHours = db.lastHours or {}
  db.zones = db.zones or {}
  db.zoneSeen = db.zoneSeen or {}
  db.ui = db.ui or {}
  db.joined = db.joined or {}   -- when the scribe saw each guildie join (for "a month in the guild")
  db.profs = db.profs or {}     -- professions and skill each scribe shares for its own character
  db.stamps = db.stamps or {}   -- dungeons a player marked as done on the Dungeons tab, per character
  db.mine = db.mine or {}       -- this account's characters that have logged in with the scribe (for alts and mains)
  db.itemIds = db.itemIds or {} -- what each recipe makes, by item id (for item tooltips in the recipe search)
  if db.ui.pip == nil then db.ui.pip = true end
  if db.ui.share == nil then db.ui.share = true end
  if db.ui.summary == nil then db.ui.summary = true end
  db.quiet = nil
end

-- Who's online right now, from the latest guild list read (not saved).
local onlineNow = {}
local notes = {}   -- guild list public notes, for "alt of X" (not saved)

local function note(who, what)
  local e = { t = now(), who = who, what = what }
  table.insert(db.events, e)
  while #db.events > EVENTS_KEPT do table.remove(db.events, 1) end
end

local function prune()
  local dayCut, hourCut = dayOf(now() - DAYS_KEPT * 86400), hourOf(now() - HOURS_KEPT * 86400)
  local upCut = now() - DAYS_KEPT * 86400
  for _, m in pairs(db.members) do
    if m.days then for d in pairs(m.days) do if d < dayCut then m.days[d] = nil end end end
    if m.ups then for l, t in pairs(m.ups) do if t < upCut then m.ups[l] = nil end end end
  end
  for h in pairs(db.hours) do if h < hourCut then db.hours[h] = nil end end
  for h in pairs(db.lastHours) do if h < hourCut then db.lastHours[h] = nil end end
  local zoneCut = dayOf(now() - ZONE_DAYS_KEPT * 86400)
  for d in pairs(db.zones) do if d < zoneCut then db.zones[d] = nil end end
  local keys = {}
  for k in pairs(db.raids) do keys[#keys + 1] = k end
  table.sort(keys)
  for i = 1, #keys - RAIDS_KEPT do db.raids[keys[i]] = nil end
  local rk = {}
  for k in pairs(db.runs) do rk[#rk + 1] = k end
  table.sort(rk)
  for i = 1, #rk - RUNS_KEPT do db.runs[rk[i]] = nil end
  while #db.kills > KILLS_KEPT do table.remove(db.kills, 1) end
  while #db.loot > LOOT_KEPT do table.remove(db.loot, 1) end
end

-- The game only lists offline guildies when "Show Offline Members" is ticked in the guild window. Without it the
-- list holds just the people online, so their levels were the only ones noted and everyone else looked "gone".
-- So the scribe ticks it while it reads, then puts your setting back straight after.
local showOffline = GetGuildRosterShowOffline or (C_GuildInfo and C_GuildInfo.GetShowOffline)
local setShowOffline = SetGuildRosterShowOffline or (C_GuildInfo and C_GuildInfo.SetShowOffline)
local putBack = false

local function askRoster()
  if not IsInGuild() then return end
  if showOffline and setShowOffline and not showOffline() then putBack = true; setShowOffline(true) end
  if C_GuildInfo and C_GuildInfo.GuildRoster then C_GuildInfo.GuildRoster() elseif GuildRoster then GuildRoster() end
end

local function readRoster()
  if not db or not IsInGuild() then return end
  local n = GetNumGuildMembers() or 0
  if n == 0 then return end
  -- A list without the offline guildies is only half the picture: note the people online, but don't mark anyone gone.
  local full_list = not showOffline or showOffline()
  local t = now()
  db.guild = GetGuildInfo("player")
  db.realm = GetRealmName()
  db.by = UnitName("player")
  db.at = t
  local today, present, online = dayOf(t), {}, 0
  wipe(onlineNow)
  for i = 1, n do
    local full, rankName, _, level, _, zone, pubNote, _, isOnline, _, classFile = GetGuildRosterInfo(i)
    if full then
      notes[short(full)] = pubNote
      local name = short(full)
      present[name] = true
      local m = db.members[name]
      if not m then
        m = { days = {} }
        db.members[name] = m
      end
      m.days = m.days or {}
      -- Level-ups: when the list first shows a higher level, note the time against each new level, so the site can
      -- date the ding (to within the five-minute read while you're online; otherwise the first read that sees it).
      if type(level) == "number" and type(m.level) == "number" and level > m.level then
        m.ups = m.ups or {}
        for l = m.level + 1, level do m.ups[l] = m.ups[l] or t end
      end
      m.level, m.class, m.rank = level, classFile, rankName
      m.gone = nil
      if isOnline then
        online = online + 1
        onlineNow[#onlineNow + 1] = { name = name, class = classFile, level = level, zone = zone }
        m.last = t
        m.zone = zone
        m.days[today] = true
        -- Time in each zone: the minutes since this guildie was last seen online, counted against the zone they're in now.
        -- The first sighting of a session counts as one five-minute read; a long gap (the scribe was offline) counts the same.
        if zone and zone ~= "" then
          local since = db.zoneSeen[name] and (t - db.zoneSeen[name]) or 300
          if since > 600 or since < 0 then since = 300 end
          local zd = db.zones[today] or {}
          db.zones[today] = zd
          zd[zone] = zd[zone] or {}
          zd[zone][name] = math.floor(((zd[zone][name] or 0) + since / 60) * 10 + 0.5) / 10
        end
        db.zoneSeen[name] = t
      else
        db.zoneSeen[name] = nil
      end
      if not isOnline and GetGuildRosterLastOnline then
        local y, mo, d, h = GetGuildRosterLastOnline(i)
        if y then
          local last = t - (((y or 0) * 365 + (mo or 0) * 30 + (d or 0)) * 86400 + (h or 0) * 3600)
          -- The game only gives whole hours, so keep whichever is more recent.
          if not m.last or last > m.last + 3600 then m.last = last end
          if (y or 0) == 0 and (mo or 0) == 0 and (d or 0) == 0 then m.days[dayOf(last)] = true end
          -- Backfill for "When the Guild Plays": the hour each offline guildie was last on counts as an hour someone
          -- played, even if nobody running the scribe was online then. Only each person's latest session is known.
          if (y or 0) == 0 and (mo or 0) == 0 and (d or 0) < HOURS_KEPT then
            local hk = hourOf(last)
            db.lastHours[hk] = db.lastHours[hk] or {}
            db.lastHours[hk][name] = true
          end
        end
      end
    end
  end
  -- Anyone no longer on the list is kept but marked as gone, so the site can tell leavers from quiet players.
  if full_list then for name, m in pairs(db.members) do if not present[name] then m.gone = true end end end
  if putBack and full_list and setShowOffline then putBack = false; C_Timer.After(0, function() setShowOffline(false) end) end
  local hk = hourOf(t)
  if (db.hours[hk] or 0) < online then db.hours[hk] = online end
  for h, names in pairs(db.lastHours) do
    local n = 0
    for _ in pairs(names) do n = n + 1 end
    if h ~= hk and (db.hours[h] or 0) < n then db.hours[h] = n end
  end
  prune()
  refresh()
end

-- Raid nights: who was in the raid group inside a raid, once per raid per day.
local function readRaid()
  if not db or not IsInRaid or not IsInRaid() then return end
  local _, instanceType = GetInstanceInfo()
  if instanceType ~= "raid" then return end
  local zone = GetRealZoneText() or "Raid"
  local key = dayOf(now()) .. " " .. zone
  local r = db.raids[key] or { zone = zone, day = dayOf(now()), who = {} }
  for i = 1, (GetNumGroupMembers and GetNumGroupMembers() or 0) do
    local name = GetRaidRosterInfo(i)
    if name then r.who[short(name)] = true end
  end
  db.raids[key] = r
end

-- Turns the game's own message (in whatever language it's running) into a pattern to read names and items from.
local function pattern(s)
  if type(s) ~= "string" then return nil end
  -- "%1$s" (numbered) becomes "%s"; every magic character, "%" included, is escaped; then "%s" and "%d" become captures.
  local p = s:gsub("%%%%", "\1"):gsub("%%%d+%$", "%%"):gsub("[%^%$%(%)%.%[%]%*%+%-%?%%]", "%%%0"):gsub("%%%%s", "(.+)"):gsub("%%%%d", "(%%d+)")
  p = "^" .. p:gsub("\1", "%%%%") .. "$"
  if not pcall(string.match, "", p) then return nil end
  return p
end

-- Dungeons: who was in your group inside a dungeon (once per dungeon per day), every boss your group kills, and the
-- uncommon-or-better loot your group gets there. The site turns these into Dungeon Passport stamps for everyone who
-- was there, a line in the Guild Feed for each kill, and loot lines. Only your own group is visible to the addon.
local function groupNames()
  local out, me = {}, UnitName("player")
  if me then out[short(me)] = true end
  if IsInRaid and IsInRaid() then
    for i = 1, (GetNumGroupMembers and GetNumGroupMembers() or 0) do local n = GetRaidRosterInfo(i); if n then out[short(n)] = true end end
  else
    for i = 1, 4 do local n = UnitName("party" .. i); if n then out[short(n)] = true end end
  end
  return out
end
local function inInstance()
  local name, instanceType = GetInstanceInfo()
  if instanceType == "party" or instanceType == "raid" then return name, instanceType end
end
local function readRun()
  if not db then return end
  local zone, kind = inInstance()
  if kind ~= "party" or not zone then return end
  local key = dayOf(now()) .. " " .. zone
  local r = db.runs[key] or { zone = zone, day = dayOf(now()), who = {} }
  for n in pairs(groupNames()) do r.who[n] = true end
  db.runs[key] = r
end
-- Nothing goes to chat any more: what the scribe notes shows in its window, and the minimap button counts it.
local TAG = "|cffe0a862Blood and Tears Scribe|r: "
-- A group member's guild list entry. In Forever a name can have two parts and the group shows only the first.
local function guildie(name)
  if not name or not db then return nil end
  if db.members[name] then return db.members[name], name end
  for full, m in pairs(db.members) do if full:sub(1, #name + 1) == name .. " " then return m, full end end
end
local function guildiesIn(who)
  local n = 0
  for name in pairs(who) do if guildie(name) then n = n + 1 end end
  return n
end
local function bossKilled(boss, success)
  if not db or success ~= 1 or not boss then return end
  local zone = inInstance() or GetRealZoneText()
  local who = groupNames()
  table.insert(db.kills, { t = now(), zone = zone, boss = boss, who = who })
  readRun()
  prune()
  refresh()
end
local QCOL = { ["9d9d9d"] = 0, ffffff = 1, ["1eff00"] = 2, ["0070dd"] = 3, a335ee = 4, ff8000 = 5, e6cc80 = 6 }
local LOOT_OTHER, LOOT_OTHER_N = pattern(LOOT_ITEM), pattern(LOOT_ITEM_MULTIPLE)
local LOOT_ME, LOOT_ME_N = pattern(LOOT_ITEM_SELF), pattern(LOOT_ITEM_SELF_MULTIPLE)
local function lootSeen(msg)
  if not db or not msg then return end
  local zone = inInstance()
  if not zone then return end
  local who, link
  if LOOT_ME_N then link = msg:match(LOOT_ME_N) end
  if not link and LOOT_ME then link = msg:match(LOOT_ME) end
  if link then who = UnitName("player")
  else
    if LOOT_OTHER_N then who, link = msg:match(LOOT_OTHER_N) end
    if not link and LOOT_OTHER then who, link = msg:match(LOOT_OTHER) end
  end
  if not who or not link then return end
  -- Only guildies' loot: pugs in the group are left out (here, in the window and on the site).
  if who ~= UnitName("player") and not guildie(short(who)) then return end
  local id = tonumber(link:match("item:(%d+)"))
  local name = link:match("%[(.-)%]")
  local col = link:match("|c%x%x(%x%x%x%x%x%x)")
  local q = col and QCOL[col:lower()]
  if not q then q = Item.quality(link) end
  if not id or not name or not q or q < 2 then return end
  table.insert(db.loot, { t = now(), who = short(who), id = id, q = q, name = name, zone = zone })
  prune()
  refresh()
end

-- "X has joined the guild." and friends, using the game's own wording so it works in any language.
local JOIN, LEAVE, REMOVED = pattern(ERR_GUILD_JOIN_S), pattern(ERR_GUILD_LEAVE_S), pattern(ERR_GUILD_REMOVE_SS)
local LEARNED = pattern(ERR_LEARN_RECIPE_S)
local function system(msg)
  if not db or not msg then return end
  -- "You have learned how to create a new item": the Recipes tab asks for the profession to be read again.
  if LEARNED and msg:match(LEARNED) then
    db.ui.learned = db.ui.learned or {}
    db.ui.learned[UnitName("player") or "?"] = now()
    refresh()
    return
  end
  local who, what
  if JOIN then who = msg:match(JOIN); what = "joined" end
  if not who and LEAVE then who = msg:match(LEAVE); what = "left" end
  if not who and REMOVED then who = msg:match(REMOVED); what = "removed" end
  if not who then return end
  note(short(who), what)
  if what == "joined" then db.joined[short(who)] = now() end
  refresh()
  askRoster()
end

-- Your own level-ups, timed exactly (the game says when you ding). In Forever the game's "who am I" gives only the
-- first part of a two-part name, so match it to the one guild list name that starts with it.
local function myEntry()
  local me = UnitName("player")
  if not me or not db then return nil end
  if db.members[me] then return db.members[me] end
  local found
  for name, m in pairs(db.members) do
    if name:sub(1, #me + 1) == me .. " " then if found then return nil end found = m end
  end
  return found
end
local function levelUp(newLevel)
  local m = myEntry()
  if not m or type(newLevel) ~= "number" then return end
  m.ups = m.ups or {}
  m.ups[newLevel] = now()
  m.level = newLevel
  refresh()
end

-- Your own characters' recipes, read when you open a profession window. Tries the newer and the older game functions.
-- The item a recipe makes, from its link, so the recipe search can show the item's tooltip.
local function noteItem(name, link)
  local id = link and tonumber(link:match("item:(%d+)"))
  if name and id then db.itemIds[name] = id end
end
local function readRecipes()
  if not db then return end
  local me, prof, names = UnitName("player"), nil, {}
  if C_TradeSkillUI and C_TradeSkillUI.GetAllRecipeIDs then
    if C_TradeSkillUI.IsTradeSkillLinked and C_TradeSkillUI.IsTradeSkillLinked() then return end
    if C_TradeSkillUI.IsTradeSkillGuild and C_TradeSkillUI.IsTradeSkillGuild() then return end
    local ok, info = pcall(C_TradeSkillUI.GetBaseProfessionInfo)
    prof = ok and info and info.professionName or nil
    if not prof and C_TradeSkillUI.GetTradeSkillLine then local ok2, _, name = pcall(C_TradeSkillUI.GetTradeSkillLine); prof = ok2 and name or nil end
    for _, id in ipairs(C_TradeSkillUI.GetAllRecipeIDs() or {}) do
      local r = C_TradeSkillUI.GetRecipeInfo(id)
      if r and r.learned and r.name then
        names[#names + 1] = r.name
        if C_TradeSkillUI.GetRecipeItemLink then local ok3, l = pcall(C_TradeSkillUI.GetRecipeItemLink, id); if ok3 then noteItem(r.name, l) end end
      end
    end
  elseif GetTradeSkillLine and GetNumTradeSkills then
    prof = GetTradeSkillLine()
    for i = 1, GetNumTradeSkills() do
      local name, kind = GetTradeSkillInfo(i)
      if name and kind ~= "header" then
        names[#names + 1] = name
        if GetTradeSkillItemLink then local ok3, l = pcall(GetTradeSkillItemLink, i); if ok3 then noteItem(name, l) end end
      end
    end
  end
  if not prof or prof == "" or prof == "UNKNOWN" or #names == 0 then return end
  table.sort(names)
  db.recipes[me] = db.recipes[me] or {}
  db.recipes[me][prof] = { at = now(), list = names }
  shareRecipes(me, prof)
  refresh()
end
-- Enchanting (and Beast Training) use the older Craft window, which the trade skill functions don't see.
local function readCraft()
  if not db or not GetNumCrafts then return end
  local me, names = UnitName("player"), {}
  local prof = (GetCraftDisplaySkillLine and GetCraftDisplaySkillLine()) or (GetCraftName and GetCraftName())
  if not prof or prof == "" or prof == "UNKNOWN" or prof == "Beast Training" then return end
  for i = 1, GetNumCrafts() do
    local name, _, kind = GetCraftInfo(i)
    if name and kind ~= "header" then
      names[#names + 1] = name
      if GetCraftItemLink then local ok3, l = pcall(GetCraftItemLink, i); if ok3 then noteItem(name, l) end end
    end
  end
  if #names == 0 then return end
  table.sort(names)
  db.recipes[me] = db.recipes[me] or {}
  db.recipes[me][prof] = { at = now(), list = names }
  shareRecipes(me, prof)
  refresh()
end

local ui = {}   -- the window, the minimap button and the session summary fill this in below
f:SetScript("OnEvent", function(_, event, ...)
  -- Never pop a Lua error at the player: anything that goes wrong is kept (the last 10) in the saved notes instead.
  local ok, err = pcall(function(a1, a2, a3, a4, a5)
  if event == "ADDON_LOADED" and a1 == ADDON then
    init()
  elseif event == "PLAYER_LOGIN" then
    askRoster()
    -- The guild list only refreshes when asked: ask every five minutes.
    C_Timer.NewTicker(300, askRoster)
    if ui.login then pcall(ui.login) end
  elseif event == "GUILD_ROSTER_UPDATE" then
    readRoster()
    -- Drop pugs' loot noted by older versions, once the guild list is known.
    if next(db.members) then
      local mine = short(UnitName("player"))
      for i = #db.loot, 1, -1 do local w = db.loot[i].who; if w ~= mine and not guildie(w) then table.remove(db.loot, i) end end
    end
  elseif event == "GROUP_ROSTER_UPDATE" or event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" then
    readRaid()
    pcall(readRun)
  elseif event == "ENCOUNTER_END" then
    pcall(bossKilled, a2, a5)
  elseif event == "CHAT_MSG_LOOT" then
    pcall(lootSeen, a1)
  elseif event == "CHAT_MSG_SYSTEM" then
    system(a1)
  elseif event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_LIST_UPDATE" or event == "TRADE_SKILL_UPDATE" then
    readRecipes()
  elseif event == "CRAFT_SHOW" or event == "CRAFT_UPDATE" then
    pcall(readCraft)
  elseif event == "SKILL_LINES_CHANGED" then
    if ui.skills then pcall(ui.skills) end
  elseif event == "TIME_PLAYED_MSG" then
    if ui.played then ui.played(a1) end
  elseif event == "PLAYER_MONEY" then
    if ui.noteMe then ui.noteMe() end
  elseif event == "PLAYER_REGEN_DISABLED" then
    if ui.combat then ui.combat() end
  elseif event == "PLAYER_REGEN_ENABLED" then
    askRoster()
    refresh()
  elseif event == "PLAYER_LEVEL_UP" then
    levelUp(a1)
  elseif event == "PLAYER_CAMPING" or event == "PLAYER_QUITING" then
    if ui.loggingOut then pcall(ui.loggingOut) end
  elseif event == "CHAT_MSG_ADDON" then
    if ui.addonMsg then pcall(ui.addonMsg, a1, a2, a3, a4) end
  elseif event == "LOGOUT_CANCEL" then
    if ui.logoutCancelled then pcall(ui.logoutCancelled) end
  end
  end, ...)
  if not ok and db then
    db.errs = db.errs or {}
    table.insert(db.errs, date("%Y-%m-%d %H:%M ") .. tostring(event) .. ": " .. tostring(err))
    while #db.errs > 10 do table.remove(db.errs, 1) end
  end
end)
for _, e in ipairs({ "ADDON_LOADED", "PLAYER_LOGIN", "GUILD_ROSTER_UPDATE", "GROUP_ROSTER_UPDATE", "ZONE_CHANGED_NEW_AREA",
  "CHAT_MSG_SYSTEM", "TRADE_SKILL_SHOW", "TRADE_SKILL_LIST_UPDATE", "TRADE_SKILL_UPDATE", "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED", "TIME_PLAYED_MSG", "PLAYER_MONEY", "PLAYER_LEVEL_UP", "PLAYER_ENTERING_WORLD", "ENCOUNTER_END", "CHAT_MSG_LOOT",
  "PLAYER_CAMPING", "PLAYER_QUITING", "LOGOUT_CANCEL", "CRAFT_SHOW", "CRAFT_UPDATE", "SKILL_LINES_CHANGED",
  "CHAT_MSG_ADDON" }) do
  pcall(f.RegisterEvent, f, e)
end


---------------------------------------------------------------------------------------------------------------------
-- The window: a minimap button opens it; three tabs (Today, This week, Scribe). Built in code with the game's own
-- fonts and plain coloured textures, so it needs no other files except the gingerbread logo (logo.tga).
---------------------------------------------------------------------------------------------------------------------
local LOGO = "Interface\\AddOns\\" .. (ADDON or "BloodAndTearsScribe") .. "\\logo"
local GOLD, DIM, INK = "|cffe0a862", "|cffa6948e", "|cffefe6e2"   -- the site's accent text, tertiary and primary ink
local QHEX = { [0] = "|cff9d9d9d", "|cffffffff", "|cff1eff00", "|cff0070dd", "|cffa335ee", "|cffff8000", "|cffe6cc80" }
local W = 430
-- Small pictures inside text (the game's fonts have no symbols): a sword for a run, a bag for a drop, light for a ding.
local IC_RUN, IC_LOOT, IC_DING = "|TInterface\\Icons\\INV_Sword_04:12:12|t", "|TInterface\\Icons\\INV_Misc_Bag_08:12:12|t", "|TInterface\\Icons\\Spell_Holy_InnerFire:12:12|t"
local IC_JOIN, IC_LEAVE, IC_ANNIV = "|TInterface\\Icons\\INV_Misc_Note_01:12:12|t", "|TInterface\\Icons\\Ability_Rogue_Sprint:12:12|t", "|TInterface\\Icons\\INV_Misc_Gift_01:12:12|t"
-- A class's icon (from the game's own sheet of class icons), or a dot in the class colour if the game has none.
local function dot(cls, size)
  local tc = cls and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[cls]
  if tc then
    size = size or 13
    return ("|TInterface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES:%d:%d:0:0:256:256:%d:%d:%d:%d|t"):format(size, size, tc[1] * 256 + 4, tc[2] * 256 - 4, tc[3] * 256 + 4, tc[4] * 256 - 4)
  end
  local c = cls and RAID_CLASS_COLORS and RAID_CLASS_COLORS[cls]
  local r, g, b = c and c.r or 0.9, c and c.g or 0.85, c and c.b or 0.8
  return ("|TInterface\\Buttons\\WHITE8X8:7:7:0:0:8:8:0:8:0:8:%d:%d:%d|t"):format(r * 255, g * 255, b * 255)
end

-- A profession's icon, for in front of its name.
ui.PROF_ICONS = { Alchemy = "Trade_Alchemy", Blacksmithing = "Trade_BlackSmithing", Cooking = "INV_Misc_Food_15", Enchanting = "Trade_Engraving",
  Engineering = "Trade_Engineering", ["First Aid"] = "Spell_Holy_SealOfSacrifice", Fishing = "Trade_Fishing", Herbalism = "Trade_Herbalism",
  Leatherworking = "Trade_LeatherWorking", Mining = "Trade_Mining", Smelting = "Trade_Mining", Skinning = "INV_Misc_Pelt_Wolf_01", Tailoring = "Trade_Tailoring" }
ui.profIcon = function(name, size)
  local i = name and ui.PROF_ICONS[name]
  if not i then return "" end
  size = size or 14
  return "|TInterface\\Icons\\" .. i .. ":" .. size .. ":" .. size .. ":0:0:64:64:5:59:5:59|t "
end
local function classHex(cls)
  local c = cls and RAID_CLASS_COLORS and RAID_CLASS_COLORS[cls]
  if c then return c.colorStr and ("|c" .. c.colorStr) or ("|cff%02x%02x%02x"):format(c.r * 255, c.g * 255, c.b * 255) end
  return INK
end
local function first(n) return (n or ""):match("^(%S+)") or n end
local function nameIn(name, cls) return classHex(cls) .. (name or "?") .. "|r" end
-- Names on screen are full: the game's "who am I" and group lists give only the first part of a two-part name, so
-- look the rest up in the guild list.
local function fullName(n) local _, full = guildie(n); return full or n end
local function memberName(n) local m, full = guildie(n); return nameIn(full or n, m and m.class) end
-- Whose alt a character is: one of your own characters (you pick your main on the Scribe tab), what another scribe
-- shared for theirs, or a guild note that says "alt" and names a guildie. Returns the main's full name, or nil.
-- The site's snapshot (SiteData.lua, from the site's "Download for the addon"): passports, professions, recipes, alts.
local function site() return type(BloodAndTearsSiteData) == "table" and type(BloodAndTearsSiteData.chars) == "table" and BloodAndTearsSiteData or nil end
local function siteChar(name)
  local sd = site(); if not sd or not name then return nil end
  if sd.chars[name] then return sd.chars[name], name end
  for full, c in pairs(sd.chars) do if full:sub(1, #name + 1) == name .. " " then return c, full end end
end
local function myMain()
  if db.ui.main and db.mine[db.ui.main] then return db.ui.main end
  local best
  for n, c in pairs(db.mine) do if not best or (c.lv or 0) > (db.mine[best].lv or 0) then best = n end end
  return best
end
local function mainOf(name)
  local short1 = first(name)
  if db.mine[short1] then local mn = myMain(); if mn and mn ~= short1 then return fullName(mn) end return nil end
  local sc = siteChar(name)
  if sc and sc.main and sc.main ~= "" then return sc.main end
  local p = db.profs[short1] or db.profs[name]
  if p and p.main and p.main ~= "" and p.main ~= short1 then return fullName(p.main) end
  local note = notes[name] or notes[short1]
  if note and note:lower():find("alt") then
    for full in pairs(db.members) do
      local f1 = first(full)
      if f1 ~= short1 and #f1 > 2 and note:lower():find(f1:lower(), 1, true) then return full end
    end
  end
  return nil
end
local function owns(n) return n:sub(-1) == "s" and (n .. "'") or (n .. "'s") end
local function altTag(name) local mn = mainOf(name); return mn and (DIM .. "  " .. owns(mn) .. " alt|r") or "" end
local function itemText(l)
  local n = "[" .. (l.name or "?") .. "]"
  return (QHEX[l.q or 2] or QHEX[2]) .. (l.id and ("|Hitem:" .. l.id .. "|h" .. n .. "|h") or n) .. "|r"
end
local function clock(t) local h, mi = tonumber(date("!%H", t + PERTH)), date("!%M", t + PERTH); return ((h % 12 == 0) and 12 or h % 12) .. ":" .. mi .. (h < 12 and "am" or "pm") end
local function hrs(min) if min < 60 then return math.floor(min + 0.5) .. "m" elseif min < 600 then return (math.floor(min / 6 + 0.5) / 10) .. "h" else return math.floor(min / 60 + 0.5) .. "h" end end
local function dur(sec) local m = math.floor(sec / 60); if m < 60 then return m .. "m" end return math.floor(m / 60) .. "h " .. (m % 60 < 10 and "0" or "") .. (m % 60) .. "m" end

-- Today's notes, newest first: dungeon runs (bosses grouped per dungeon), good drops, and guildies' level-ups.
local function todayFeed(since)
  local out, today = {}, dayOf(now())
  local runs = {}
  for _, k in ipairs(db.kills) do
    if dayOf(k.t) == today and (not since or k.t > since) then
      local r = runs[k.zone or "?"]
      if not r then r = { kind = "run", zone = k.zone or "?", t = k.t, n = 0, who = {} }; runs[r.zone] = r; out[#out + 1] = r end
      r.n = r.n + 1; if k.t > r.t then r.t = k.t end
      for n in pairs(k.who or {}) do r.who[n] = true end
    end
  end
  for _, l in ipairs(db.loot) do
    if dayOf(l.t) == today and (l.q or 0) >= 3 and (not since or l.t > since) and (l.who == short(UnitName("player")) or guildie(l.who)) then out[#out + 1] = { kind = "loot", t = l.t, l = l } end
  end
  for name, m in pairs(db.members) do
    for lv, t in pairs(m.ups or {}) do
      if dayOf(t) == today and (not since or t > since) and lv == m.level then out[#out + 1] = { kind = "ding", t = t, name = name, class = m.class, level = lv } end
    end
  end
  -- Joins and leaves from the guild's own messages, and month-in-the-guild milestones for anyone the scribe saw join.
  for _, e in ipairs(db.events) do
    if dayOf(e.t) == today and (not since or e.t > since) then out[#out + 1] = { kind = e.what == "joined" and "join" or "leave", t = e.t, name = e.who, what = e.what } end
  end
  local y, mo, d = today:match("^(%d+)-(%d+)-(%d+)$")
  for name, jt in pairs(db.joined) do
    local jy, jm, jd = dayOf(jt):match("^(%d+)-(%d+)-(%d+)$")
    local months = (tonumber(y) - tonumber(jy)) * 12 + (tonumber(mo) - tonumber(jm))
    if jd == d and months > 0 and (not since or since < now() - 86400 + 1) then
      local m = db.members[name]
      if m and not m.gone then out[#out + 1] = { kind = "anniv", t = now() - 1, name = name, class = m.class, months = months } end
    end
  end
  table.sort(out, function(a, b) return a.t > b.t end)
  return out
end

-- Minutes per zone over the last n days, biggest first.
local function zoneTotals(days)
  local cut, tot, list, ppl = dayOf(now() - (days - 1) * 86400), {}, {}, {}
  for d, zs in pairs(db.zones) do
    if d >= cut then for zone, who in pairs(zs) do for name, mins in pairs(who) do tot[zone] = (tot[zone] or 0) + mins; ppl[zone] = ppl[zone] or {}; ppl[zone][name] = true end end end
  end
  for zone, m in pairs(tot) do local n = 0; for _ in pairs(ppl[zone]) do n = n + 1 end; list[#list + 1] = { zone, m, n } end
  table.sort(list, function(a, b) return a[2] > b[2] end)
  return list
end

-- Average guildies online by weekday (Monday first) and hour, Perth time, from the hourly counts.
local function hourGrid()
  local sum, cnt = {}, {}
  for d = 0, 6 do sum[d], cnt[d] = {}, {} end
  for k, v in pairs(db.hours) do
    local y, mo, dd, h = k:match("^(%d+)-(%d+)-(%d+) (%d+)$")
    if y then
      local ok, ts = pcall(time, { year = tonumber(y), month = tonumber(mo), day = tonumber(dd), hour = 12 })
      if ok and ts then
        local wd = (tonumber(date("%w", ts)) + 6) % 7
        h = tonumber(h)
        sum[wd][h] = (sum[wd][h] or 0) + v; cnt[wd][h] = (cnt[wd][h] or 0) + 1
      end
    end
  end
  local avg, max, best = {}, 0, nil
  for d = 0, 6 do
    avg[d] = {}
    for h = 0, 23 do
      if cnt[d][h] then
        local a = sum[d][h] / cnt[d][h]; avg[d][h] = a
        if a > max then max = a; best = { d, h, a } end
      end
    end
  end
  return avg, max, best
end

-------------------------------------------------------------------- frame helpers
local function tex(parent, layer, r, g, b, a)
  local t = parent:CreateTexture(nil, layer or "ARTWORK")
  t:SetColorTexture(r, g, b, a or 1)
  return t
end
local function text(parent, font, justify)
  local fs = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlightSmall")
  fs:SetJustifyH(justify or "LEFT")
  if fs.SetWordWrap then fs:SetWordWrap(false) end
  -- Easier to read over a see-through panel: a soft shadow under every line, and the site's ink colours instead of the
  -- game's dim grey and bright white.
  fs:SetShadowColor(0, 0, 0, 0.9); fs:SetShadowOffset(1, -1)
  if font == "GameFontDisableSmall" then fs:SetTextColor(0.75, 0.68, 0.66)
  elseif font == nil or font == "GameFontHighlightSmall" or font == "GameFontHighlight" then fs:SetTextColor(0.937, 0.902, 0.886)
  elseif font == "GameFontNormalLarge" or font == "GameFontNormalHuge" then fs:SetTextColor(0.941, 0.773, 0.549) end
  return fs
end
local function panel(name, w, h)
  local fr = CreateFrame("Frame", name, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
  fr:SetSize(w, h)
  fr:SetFrameStrata("DIALOG")
  if fr.SetBackdrop then
    fr:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
    fr:SetBackdropColor(0.086, 0.063, 0.063, 0)
    fr:SetBackdropBorderColor(0.36, 0.27, 0.25, 1)
  end
  -- A solid panel underneath, so the world and other windows don't show through the lists.
  local bg = tex(fr, "BACKGROUND", 0.086, 0.063, 0.063, 0.9); bg:SetPoint("TOPLEFT", 4, -4); bg:SetPoint("BOTTOMRIGHT", -4, 4)
  -- The crimson header with the gingerbread and a gold title
  local hd = tex(fr, "BORDER", 0.122, 0.090, 0.086, 1)
  hd:SetPoint("TOPLEFT", 4, -4); hd:SetPoint("TOPRIGHT", -4, -4); hd:SetHeight(44)
  local line = tex(fr, "BORDER", 0.647, 0.051, 0.173, 1)
  line:SetPoint("TOPLEFT", hd, "BOTTOMLEFT"); line:SetPoint("TOPRIGHT", hd, "BOTTOMRIGHT"); line:SetHeight(2)
  local logo = fr:CreateTexture(nil, "ARTWORK"); logo:SetTexture(LOGO); logo:SetSize(32, 32); logo:SetPoint("TOPLEFT", 12, -10)
  fr.title = text(fr, "GameFontNormalLarge"); fr.title:SetPoint("TOPLEFT", logo, "TOPRIGHT", 8, -1)
  fr.sub = text(fr, "GameFontDisableSmall"); fr.sub:SetPoint("TOPLEFT", fr.title, "BOTTOMLEFT", 0, -2)
  local x = CreateFrame("Button", nil, fr, "UIPanelCloseButton"); x:SetSize(28, 28); x:SetPoint("TOPRIGHT", -8, -12)
  fr:EnableMouse(true); fr:SetMovable(true); fr:SetClampedToScreen(true)
  fr:RegisterForDrag("LeftButton")
  fr:SetScript("OnDragStart", function(self) if not (db and db.ui.lock) then self:StartMoving() end end)
  fr:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
  fr:Hide()
  if UISpecialFrames then table.insert(UISpecialFrames, name) end   -- Escape closes it
  return fr
end
-- A pool of one-line rows: a small mark on the left, the text, and a right-hand note (a time, a zone, a number).
local function rows(parent, n, top)
  local list = {}
  for i = 1, n do
    local r = CreateFrame("Frame", nil, parent)
    r:SetSize(W - 28, 20)
    r:SetPoint("TOPLEFT", 14, top - (i - 1) * 20)
    r.sep = tex(r, "BACKGROUND", 1, 1, 1, 0.045); r.sep:SetPoint("BOTTOMLEFT", 0, -1); r.sep:SetPoint("BOTTOMRIGHT", 0, -1); r.sep:SetHeight(1)
    r.mark = text(r, "GameFontNormalSmall"); r.mark:SetPoint("LEFT", 0, 0); r.mark:SetWidth(16)
    r.right = text(r, "GameFontDisableSmall", "RIGHT"); r.right:SetPoint("RIGHT", 0, 0)
    r.main = text(r, "GameFontHighlightSmall"); r.main:SetPoint("LEFT", 19, 0); r.main:SetPoint("RIGHT", r.right, "LEFT", -6, 0)
    r.bar = tex(r, "BACKGROUND", 0.10, 0.06, 0.05, 1); r.bar:SetPoint("BOTTOMLEFT", 16, -1); r.bar:SetPoint("BOTTOMRIGHT", 0, -1); r.bar:SetHeight(3)
    r.fill = tex(r, "ARTWORK", 0.839, 0.616, 0.337, 1); r.fill:SetPoint("TOPLEFT", r.bar); r.fill:SetPoint("BOTTOMLEFT", r.bar); r.fill:SetWidth(1)
    r.bar:Hide(); r.fill:Hide()
    -- A row can carry a few lines to show on hover (the grouped level-ups).
    r:EnableMouse(true)
    -- A loot row carries its item: hover for the item's own tooltip, shift-click to put its link in chat.
    r:SetScript("OnEnter", function(self)
      if self.item then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if not pcall(GameTooltip.SetHyperlink, GameTooltip, "item:" .. self.item) then GameTooltip:AddLine(self.itemName or "", 1, 1, 1) end
        GameTooltip:AddLine("Shift-click to link it in chat", 0.6, 0.6, 0.6)
        GameTooltip:Show()
        return
      end
      if not self.tip then return end
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      for _, l in ipairs(self.tip) do GameTooltip:AddLine(l, 1, 1, 1) end
      GameTooltip:Show()
    end)
    r:SetScript("OnLeave", function() GameTooltip:Hide() end)
    r:SetScript("OnMouseUp", function(self, button)
      if button == "RightButton" and self.who and ui.menu then ui.menu(self.who); return end
      if not (self.item and IsModifiedClick and IsModifiedClick("CHATLINK") and ChatEdit_InsertLink) then return end
      local l = Item.link(self.item)
      if l then ChatEdit_InsertLink(l) end
    end)
    list[i] = r
  end
  return list
end
local function setRow(r, mark, main, right, pct, tip)
  r.tip = tip; r.item = nil; r.itemName = nil; r.who = nil
  r.mark:SetText(mark or ""); r.main:SetText(main or ""); r.right:SetText(right or "")
  if pct then r.bar:Show(); r.fill:Show(); r.sep:Hide(); r.fill:SetWidth(math.max(1, (W - 44) * math.min(1, pct))) else r.bar:Hide(); r.fill:Hide(); r.sep:Show() end
  r:Show()
end

-- The game's own red buttons, made easier to read: a smaller label in light text (gold for the chosen one, which also
-- stays lit), with a shadow. Pass a frame made with UIPanelButtonTemplate.
local function wowButton(b, w, h, label)
  b:SetSize(w, h)
  b:SetText(label)
  local fs = b.GetFontString and b:GetFontString()
  if fs then
    fs:SetFontObject("GameFontHighlightSmall")
    fs:SetShadowColor(0, 0, 0, 1); fs:SetShadowOffset(1, -1)
    fs:SetTextColor(0.93, 0.89, 0.86)
  end
  b.setOn = function(self, on)
    if on then self:LockHighlight() else self:UnlockHighlight() end
    local f = self:GetFontString()
    if f then if on then f:SetTextColor(1, 0.82, 0.35) else f:SetTextColor(0.93, 0.89, 0.86) end end
  end
  return b
end

-------------------------------------------------------------------- the main window
-- A drop-down: a button showing the current choice, and a small list under it. opts is { { key, label }, ... };
-- pick(key) is called with the choice; button:set(key) shows a choice.
ui.dropdown = function(parent, w, prefix, opts, pick)
  local b = wowButton(CreateFrame("Button", nil, parent, "UIPanelButtonTemplate"), w, 22, "")
  local arrow = b:CreateTexture(nil, "OVERLAY"); arrow:SetSize(10, 10); arrow:SetPoint("RIGHT", -6, 0)
  arrow:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
  pcall(function() arrow:SetRotation(-math.pi / 2) end)
  local drop = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
  drop:SetSize(w, #opts * 20 + 10); drop:SetPoint("TOPRIGHT", b, "BOTTOMRIGHT", 0, -1)
  drop:SetFrameLevel((parent:GetFrameLevel() or 1) + 40); drop:EnableMouse(true); drop:Hide()
  if drop.SetBackdrop then
    drop:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true, tileSize = 16, edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
    drop:SetBackdropColor(0.086, 0.063, 0.063, 1); drop:SetBackdropBorderColor(0.36, 0.27, 0.25, 1)
  end
  for i, o in ipairs(opts) do
    local ob = CreateFrame("Button", nil, drop); ob:SetSize(w - 8, 20); ob:SetPoint("TOPLEFT", 4, -5 - (i - 1) * 20)
    local hl = tex(ob, "HIGHLIGHT", 1, 1, 1, 0.08); hl:SetAllPoints()
    local t = text(ob, "GameFontHighlightSmall"); t:SetPoint("LEFT", 8, 0); t:SetText(o[2])
    ob.pick = o[2]
    ob:SetScript("OnClick", function() drop:Hide(); pick(o[1]) end)
  end
  b:SetScript("OnClick", function() if drop:IsShown() then drop:Hide() else drop:Show() end end)
  parent:HookScript("OnHide", function() drop:Hide() end)
  b.set = function(self, key) for _, o in ipairs(opts) do if o[1] == key then self:SetText(prefix .. o[2]) end end end
  return b
end
-- A one-line foot note at the bottom of a tab; with lines, hovering it shows them (for help you only need once).
ui.foot = function(parent, lines)
  local fs = text(parent, "GameFontDisableSmall"); fs:SetPoint("BOTTOMLEFT", 14, 10); fs:SetWidth(W - 44); fs:SetHeight(14)
  if lines then
    local f = CreateFrame("Frame", nil, parent); f:SetPoint("BOTTOMLEFT", 14, 8); f:SetSize(W - 44, 18); f:EnableMouse(true)
    f:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
      for i, l in ipairs(lines) do if i == 1 then GameTooltip:AddLine(l, 0.88, 0.66, 0.38) else GameTooltip:AddLine(l, 0.94, 0.90, 0.89, true) end end
      GameTooltip:Show()
    end)
    f:SetScript("OnLeave", function() GameTooltip:Hide() end)
  end
  return fs
end
local win = panel("BloodAndTearsScribeWindow", W, 490)
win:SetPoint("CENTER", 0, 60)
win.title:SetText("Blood and Tears")
ui.ver = (GetAddOnMetadata or (C_AddOns and C_AddOns.GetAddOnMetadata) or function() return "" end)(ADDON, "Version") or ""
win.sub:SetText("Guild scribe " .. ui.ver)
local pages, tabs, current = {}, {}, "today"
local function page(key)
  local p = CreateFrame("Frame", nil, win); p:SetPoint("TOPLEFT", 4, -90); p:SetPoint("BOTTOMRIGHT", -4, 4); p:Hide()
  pages[key] = p; return p
end
local function label(p, s, y) local l = text(p, "GameFontNormalSmall"); l:SetPoint("TOPLEFT", 14, y); l:SetText(s); l:SetTextColor(0.651, 0.580, 0.557); return l end

-- Today
local pToday = page("today")
local onlineLabel = label(pToday, "Online now", -11)
local onlineRows = rows(pToday, 7, -36)
local todayLabel = label(pToday, "Today", -186)
local feedRows = rows(pToday, 8, -204)
local todayFoot = ui.foot(pToday)

-- This week
local pWeek = page("week")
label(pWeek, "Zones this week", -11)
-- Sort the zones (and scroll them with the mouse wheel).
ui.zoneDD = ui.dropdown(pWeek, 150, "Sort: ", { { "time", "Most time" }, { "people", "Most guildies" }, { "name", "A to Z" } }, function(k) db.ui.zoneSort = k; ui.zoneOff = 0; refresh() end)
ui.zoneDD:SetPoint("TOPRIGHT", -14, -6)
pWeek:EnableMouseWheel(true)
pWeek:SetScript("OnMouseWheel", function(_, d) ui.zoneOff = math.max(0, (ui.zoneOff or 0) - d); refresh() end)
local zoneRows = rows(pWeek, 5, -36)
for _, r in ipairs(zoneRows) do r:SetHeight(24) end
for i, r in ipairs(zoneRows) do r:ClearAllPoints(); r:SetPoint("TOPLEFT", 14, -36 - (i - 1) * 24) end
label(pWeek, "When the guild plays (Perth time)", -172)
local grid, CELL_W, CELL_H = {}, 13, 11
local dayNames = { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" }
for d = 0, 6 do
  local l = text(pWeek, "GameFontDisableSmall"); l:SetPoint("TOPLEFT", 14, -202 - d * (CELL_H + 2)); l:SetText(dayNames[d + 1])
  grid[d] = {}
  for h = 0, 23 do
    local c = tex(pWeek, "ARTWORK", 0.13, 0.08, 0.06, 1)
    c:SetSize(CELL_W, CELL_H); c:SetPoint("TOPLEFT", 50 + h * (CELL_W + 1), -202 - d * (CELL_H + 2))
    grid[d][h] = c
  end
end
for _, h in ipairs({ 0, 6, 12, 18 }) do
  local l = text(pWeek, "GameFontDisableSmall"); l:SetPoint("BOTTOMLEFT", grid[0][h], "TOPLEFT", 0, 2)
  l:SetText(h == 0 and "12am" or h == 12 and "12pm" or (h % 12) .. (h < 12 and "am" or "pm"))
end
local weekFoot = text(pWeek, "GameFontHighlightSmall"); weekFoot:SetPoint("TOPLEFT", 14, -302); weekFoot:SetWidth(W - 28)
local weekNote = ui.foot(pWeek)
weekNote:SetText("From this scribe's own notes. The site has the whole picture.")
local SHADES = { { 0.29, 0.10, 0.12 }, { 0.43, 0.10, 0.15 }, { 0.64, 0.09, 0.18 }, { 0.83, 0.16, 0.27 }, { 0.94, 0.34, 0.42 } }

-- Scribe
local pScribe = page("scribe")
label(pScribe, "In the notes file", -6)
local big = {}
for i = 1, 3 do
  local n = text(pScribe, "GameFontNormalHuge"); n:SetPoint("TOPLEFT", 14 + (i - 1) * 126, -26)
  local l = text(pScribe, "GameFontDisableSmall"); l:SetPoint("TOPLEFT", n, "BOTTOMLEFT", 0, -2)
  big[i] = { n = n, l = l }
end
local scribeInfo = text(pScribe, "GameFontHighlightSmall"); scribeInfo:SetPoint("TOPLEFT", 14, -84); scribeInfo:SetWidth(W - 28)
if scribeInfo.SetWordWrap then scribeInfo:SetWordWrap(true) end
scribeInfo:SetHeight(58); scribeInfo:SetJustifyV("TOP")
-- Settings have their own page (the Settings button in the header); the Scribe tab shows what's new instead.
page("settings")
label(pages.settings, "Settings", -6)
local checks = {}
local function check(key, s, y, after)
  local c = CreateFrame("CheckButton", nil, pages.settings, "UICheckButtonTemplate")
  c:SetSize(24, 24); c:SetPoint("TOPLEFT", 10, y + 140)
  local l = text(pages.settings, "GameFontHighlightSmall"); l:SetPoint("LEFT", c, "RIGHT", 2, 0); l:SetText(s)
  c:SetScript("OnClick", function(self) db.ui[key] = self:GetChecked() and true or false; if after then after() end end)
  checks[key] = c
end
local upload = ui.foot(pScribe, { "Getting the notes to the site", "1. Type /reload (or log out) to save the notes file.",
  "2. On the site: Roster, Details, then upload the file.",
  "The file is _forever_\\WTF\\Account\\(your account)\\SavedVariables\\BloodAndTearsScribe.lua" })
upload:SetText(GOLD .. "Getting the notes to the site|r  ·  hover for the steps")

-- Recipes: your professions, when each was last read, and a button that opens its window (the game only shares a
-- recipe list while that window is open, and only lets an addon open it from a click, through a secure button).
local pRecipes = page("recipes")
-- "Who can make it?": search every recipe list the scribe holds (yours, and any guildie whose scribe shared theirs).
local search = CreateFrame("EditBox", nil, pRecipes, "InputBoxTemplate")
search:SetSize(W - 40, 22); search:SetPoint("TOPLEFT", 20, -6); search:SetAutoFocus(false)
search:SetMaxLetters(60)
local searchHint = text(pRecipes, "GameFontDisableSmall"); searchHint:SetPoint("LEFT", search, "LEFT", 2, 0)
searchHint:SetText("Who can make it? Type a name, or alt-click any item")
search:SetScript("OnEscapePressed", function(self) self:SetText(""); self:ClearFocus() end)
search:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
-- A small cross at the right end of the box clears it (shown only while there's text).
do
  local x = CreateFrame("Button", nil, search)
  x:SetSize(16, 16); x:SetPoint("RIGHT", search, "RIGHT", -3, 0)
  local t = x:CreateTexture(nil, "ARTWORK"); t:SetAllPoints(); t:SetTexture("Interface\\FriendsFrame\\ClearBroadcastIcon"); t:SetAlpha(0.6)
  x:SetScript("OnEnter", function(self) t:SetAlpha(1); GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine("Clear the search", 1, 1, 1); GameTooltip:Show() end)
  x:SetScript("OnLeave", function() t:SetAlpha(0.6); GameTooltip:Hide() end)
  x:SetScript("OnClick", function() search:SetText(""); search:ClearFocus(); searchHint:Show() end)
  x:Hide()
  search.clear = x
  if search.SetTextInsets then search:SetTextInsets(0, 20, 0, 0) end
end
search:SetScript("OnTextChanged", function(self) if self.clear then self.clear:SetShown((self:GetText() or "") ~= "") end ui.hitOff = 0; ui.missing = nil; refresh() end)
search:SetScript("OnEditFocusGained", function() searchHint:Hide() end)
search:SetScript("OnEditFocusLost", function(self) if self:GetText() == "" then searchHint:Show() end end)
local recLabel = label(pRecipes, "Your professions", -37)
local CRAFTS = { Alchemy = "Alchemy", Blacksmithing = "Blacksmithing", Cooking = "Cooking", Enchanting = "Enchanting", Engineering = "Engineering",
  ["First Aid"] = "First Aid", Leatherworking = "Leatherworking", Tailoring = "Tailoring", Mining = "Smelting" }
local recRows = {}
-- The Read buttons cast a spell, which makes them (and anything they sit in) locked during combat: a window holding
-- them can't open, close or change tabs in a fight. So they live in a holder of their own that is laid over the
-- Recipes tab out of combat, and is unhooked and hidden the moment combat starts.
ui.readHold = CreateFrame("Frame", nil, UIParent)
ui.readHold:SetSize(W - 8, 250); ui.readHold:SetFrameStrata("DIALOG"); ui.readHold:SetFrameLevel(60); ui.readHold:Hide()
ui.readSync = function()
  if InCombatLockdown() then return end
  local h = ui.readHold
  h:ClearAllPoints()
  if win:IsShown() and current == "recipes" and not ui.readHide then
    h:SetScale(win:GetScale())
    h:SetPoint("TOPLEFT", pRecipes, "TOPLEFT"); h:SetPoint("TOPRIGHT", pRecipes, "TOPRIGHT")
    h:Show()
  else
    h:SetPoint("CENTER", UIParent, "CENTER"); h:Hide()
  end
end
ui.combat = function()
  local h = ui.readHold
  h:ClearAllPoints(); h:SetPoint("CENTER", UIParent, "CENTER"); h:Hide()
end
for i = 1, 5 do
  local r = CreateFrame("Frame", nil, pRecipes); r:SetSize(W - 28, 34); r:SetPoint("TOPLEFT", 14, -56 - (i - 1) * 36)
  r.name = text(r, "GameFontHighlight"); r.name:SetPoint("TOPLEFT", 0, -2)
  r.info = text(r, "GameFontDisableSmall"); r.info:SetPoint("TOPLEFT", r.name, "BOTTOMLEFT", 0, -3); r.info:SetWidth(W - 200)
  r.miss = wowButton(CreateFrame("Button", nil, r, "UIPanelButtonTemplate"), 68, 22, "Missing"); r.miss:SetPoint("RIGHT", -80, 0)
  r.miss:SetScript("OnClick", function() ui.missing = r.prof; ui.hitOff = 0; refresh() end)
  r.miss:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine("Recipes you don't know yet", 1, 1, 1); GameTooltip:Show() end)
  r.miss:SetScript("OnLeave", function() GameTooltip:Hide() end)
  local ok, b = pcall(CreateFrame, "Button", nil, ui.readHold, "SecureActionButtonTemplate,UIPanelButtonTemplate")
  if ok and b then
    wowButton(b, 76, 22, "Read"); b:SetPoint("TOPRIGHT", ui.readHold, "TOPRIGHT", -6, -62 - (i - 1) * 36)
    if b.RegisterForClicks then b:RegisterForClicks("AnyUp", "AnyDown") end
    b:SetAttribute("type", "spell")
    r.btn = b
  end
  r:Hide(); recRows[i] = r
end
local recEmpty = text(pRecipes, "GameFontDisableSmall"); recEmpty:SetPoint("TOPLEFT", 14, -56); recEmpty:SetWidth(W - 28)
local hitRows = {}
for i = 1, 8 do
  local r = CreateFrame("Frame", nil, pRecipes); r:SetSize(W - 28, 34); r:SetPoint("TOPLEFT", 14, -56 - (i - 1) * 36)
  r.name = text(r, "GameFontHighlight"); r.name:SetPoint("TOPLEFT", 0, -2); r.name:SetWidth(W - 28)
  r.info = text(r, "GameFontDisableSmall"); r.info:SetPoint("TOPLEFT", r.name, "BOTTOMLEFT", 0, -3); r.info:SetWidth(W - 28)
  -- Hover for the item's own tooltip; shift-click to put its link in chat.
  local function linkOf()
    local id = r.recipe and (db.itemIds[r.recipe] or Item.ids[r.recipe])
    if id and id < 0 then return "spell:" .. -id, id end
    if id then local l = Item.link(id); return l or ("item:" .. id), id end
    return r.recipe and Item.link(r.recipe), nil
  end
  local hl = tex(r, "HIGHLIGHT", 1, 1, 1, 0.05); hl:SetAllPoints()
  r:EnableMouse(true)
  r:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    local l = linkOf()
    if not (l and pcall(GameTooltip.SetHyperlink, GameTooltip, l:match("|H(item:[^|]+)|h") or l)) then GameTooltip:AddLine(self.recipe or "", 1, 1, 1) end
    pcall(Item.tipRecipe, self.recipe)
    GameTooltip:Show()
  end)
  r:SetScript("OnLeave", function() GameTooltip:Hide() end)
  r:SetScript("OnMouseUp", function()
    local l = linkOf()
    if l and IsModifiedClick and IsModifiedClick("CHATLINK") and ChatEdit_InsertLink and l:find("|H") then ChatEdit_InsertLink(l) end
  end)
  r:Hide(); hitRows[i] = r
end
local recFoot = ui.foot(pRecipes, { "How recipes get to the site", "1. Click Read: the profession's window opens and the scribe notes every recipe in it.",
  "2. Close the window. Do it once per profession, and again after learning new ones (this tab says when).",
  "3. Type /reload or log out to save, then upload the file on the site.",
  "The game only shares a recipe list while its window is open, so the scribe can't read them by itself." })
recFoot:SetText(GOLD .. "How recipes get to the site|r  ·  hover for the three steps")
local myProfs = {}
-- Your professions. Three places, because each can miss some: the skill list (it hides everything under a folded
-- header, like a collapsed "Professions" in the Skills tab), the spellbook (a profession's spell is only there if
-- you know it), and any profession the scribe has already read for this character. English clients.
local function knowsSpell(name)
  local ok, n = pcall(GetSpellInfo, name)
  if ok and n then return true end
  if C_Spell and C_Spell.GetSpellInfo then local ok2, i = pcall(C_Spell.GetSpellInfo, name); if ok2 and i then return true end end
  return false
end
local function readSkills()
  wipe(myProfs)
  local seen = {}
  local function add(name, rank, max) if CRAFTS[name] and not seen[name] then seen[name] = true; myProfs[#myProfs + 1] = { name = name, rank = rank, max = max } end end
  if GetNumSkillLines then
    for i = 1, GetNumSkillLines() do
      local name, header, _, rank, _, _, max = GetSkillLineInfo(i)
      if name and not header then add(name, rank, max) end
    end
  end
  for name, spell in pairs(CRAFTS) do if not seen[name] and knowsSpell(spell) then add(name) end end
  local me = UnitName("player")
  for name in pairs((db and me and db.recipes[me]) or {}) do add(name) end
  table.sort(myProfs, function(a, b) return a.name < b.name end)
  -- The buttons' spells can only be set out of combat.
  if not InCombatLockdown() then
    for i, r in ipairs(recRows) do local p = myProfs[i]; if r.btn then if p then r.btn:SetAttribute("spell", CRAFTS[p.name]); r.btn:Show() else r.btn:Hide() end end end
  end
end
ui.skills = function() readSkills(); refresh() end
-- Professions on this character that haven't been read, or have new recipes since they were.
local function needReading()
  local me = UnitName("player") or "?"
  local mine, learned, n = (db and db.recipes[me]) or {}, db and db.ui.learned and db.ui.learned[me], 0
  for _, p in ipairs(myProfs) do
    local got = mine[p.name] or mine[CRAFTS[p.name]]
    if not got or (learned and learned > got.at) then n = n + 1 end
  end
  return n
end
ui.needReading = needReading
local function ago(t)
  local d = now() - t
  if d < 3600 then return math.max(1, math.floor(d / 60)) .. "m ago" elseif d < 86400 then return math.floor(d / 3600) .. "h ago" end
  local n = math.floor(d / 86400); return n == 1 and "yesterday" or n .. " days ago"
end
local function fillSearch(q)
  q = q:lower()
  local found, order = {}, {}
  -- The notes' lists (yours and shared ones), then the site's for anyone the notes don't have.
  local lists, have = {}, {}
  for who, profs in pairs(db.recipes) do for prof, r in pairs(profs) do lists[#lists + 1] = { who, prof, r.list or {} }; have[first(who) .. "|" .. prof] = true end end
  local sd = site()
  if sd then for full, c in pairs(sd.chars) do
    if type(c.recipes) == "table" then for prof, l in pairs(c.recipes) do
      if not have[first(full) .. "|" .. prof] and type(l) == "table" then lists[#lists + 1] = { full, prof, l } end
    end end
  end end
  for _, L in ipairs(lists) do
    local who, prof = L[1], L[2]
    do
      for _, n in ipairs(L[3]) do
        if n:lower():find(q, 1, true) then
          if not found[n] then found[n] = {}; order[#order + 1] = n end
          found[n][#found[n] + 1] = { who = who, prof = prof }
        end
      end
    end
  end
  table.sort(order, function(a, b)
    local sa, sb = a:lower():sub(1, #q) == q, b:lower():sub(1, #q) == q
    if sa ~= sb then return sa end
    return a < b
  end)
  local off = math.max(0, math.min(ui.hitOff or 0, #order - #hitRows)); ui.hitOff = off; ui.hitN = #order
  recLabel:SetText(#order == 0 and "Nobody the scribe knows of can make that" or (#order .. (#order == 1 and " recipe" or " recipes") .. " match" .. (#order > #hitRows and ("  ·  " .. (off + 1) .. "–" .. math.min(#order, off + #hitRows) .. ", scroll for more") or "")))
  for i, r in ipairs(hitRows) do
    local n = order[i + off]
    if n then
      local bits = {}
      for _, c in ipairs(found[n]) do
        local m, full = guildie(c.who)
        local sc = not m and siteChar(c.who)
        -- Crafters who are online right now come first, with a green dot.
        local on = ui.isOn and ui.isOn(full or c.who)
        bits[#bits + 1] = (on and "0|TInterface\\FriendsFrame\\StatusIcon-Online:12:12|t" or "1") .. nameIn(full or c.who, m and m.class or sc and sc.cls) .. " " .. ui.profIcon(c.prof, 12)
      end
      table.sort(bits)
      for bi, b in ipairs(bits) do bits[bi] = b:sub(2) end
      local id = db.itemIds[n] or Item.ids[n]
      local icon = id and Item.icon(id)
      r.recipe = n
      r.name:SetText((icon and ("|T" .. icon .. ":16:16|t ") or "") .. n); r.info:SetText(table.concat(bits, ",  ")); r:Show()
    else r:Hide() end
  end
  for _, r in ipairs(recRows) do r:Hide() end
  recEmpty:SetText("")
end
ui.isOn = function(name)
  if not name then return false end
  local f = first(name)
  for _, o in ipairs(onlineNow) do if o.name == name or first(o.name) == f then return true end end
  return false
end
do
  local back = wowButton(CreateFrame("Button", nil, pRecipes, "UIPanelButtonTemplate"), 60, 22, "Back"); back:SetPoint("TOPRIGHT", -14, -31)
  back:SetScript("OnClick", function() ui.missing = nil; ui.hitOff = 0; refresh() end)
  back:Hide(); ui.backBtn = back
  pRecipes:EnableMouseWheel(true)
  pRecipes:SetScript("OnMouseWheel", function(_, d) ui.hitOff = math.max(0, (ui.hitOff or 0) - d); refresh() end)
  -- The recipes for one of your professions that you don't know yet: the ones you could learn now first.
  ui.fillMissing = function(mine)
    local prof = ui.missing
    local got = mine[prof] or mine[CRAFTS[prof] or ""]
    local all = Item.list(prof)
    if not got or not all then ui.missing = nil; return false end
    local have = {}
    for _, n in ipairs(got.list or {}) do have[n] = true end
    local rank = 0
    for _, p in ipairs(myProfs) do if p.name == prof then rank = tonumber(p.rank) or 0 end end
    local miss = {}
    for _, e in ipairs(all) do if not have[e.name] then miss[#miss + 1] = e end end
    table.sort(miss, function(a, b) if a.skill ~= b.skill then return a.skill < b.skill end return a.name < b.name end)
    local off = math.max(0, math.min(ui.hitOff or 0, #miss - #hitRows)); ui.hitOff = off
    recLabel:SetText(ui.profIcon(prof, 12) .. prof .. ": " .. #miss .. " you don't know yet" .. (#miss > #hitRows and ("  ·  " .. (off + 1) .. "–" .. math.min(#miss, off + #hitRows) .. ", scroll") or ""))
    for i, r in ipairs(hitRows) do
      local e = miss[i + off]
      if e then
        local id = db.itemIds[e.name] or Item.ids[e.name]
        local icon = id and Item.icon(id)
        r.recipe = e.name
        r.name:SetText((icon and ("|T" .. icon .. ":16:16|t ") or "") .. e.name)
        r.info:SetText((e.skill <= rank and (GOLD .. "You can learn this now|r") or (DIM .. "Needs " .. prof .. " " .. e.skill .. "|r")) .. DIM .. "  ·  " .. (Item.SRC[e.src] or "source unknown") .. "|r")
        r:Show()
      else r:Hide() end
    end
    for _, r in ipairs(recRows) do r:Hide() end
    recEmpty:SetText(#miss == 0 and ("You know every " .. prof .. " recipe the site lists.") or "")
    back:Show()
    return true
  end
end
local function fillRecipes()
  ui.backBtn:Hide()
  ui.readHide = true
  local me = UnitName("player") or "?"
  local q = search:GetText() or ""
  if q:gsub("%s", "") ~= "" and #q >= 2 then fillSearch(q:gsub("^%s+", ""):gsub("%s+$", "")); return end
  for _, r in ipairs(hitRows) do r:Hide() end
  recLabel:SetText("Professions for " .. fullName(me))
  readSkills()
  local mine, learned = db.recipes[me] or {}, db.ui.learned and db.ui.learned[me]
  if ui.missing and ui.fillMissing(mine) then return end
  ui.readHide = false
  -- Mining's window is Smelting, but the game files its recipes under Mining.
  for i, r in ipairs(recRows) do
    local p = myProfs[i]
    if p then
      local got = mine[p.name] or mine[CRAFTS[p.name]]
      r.name:SetText(ui.profIcon(p.name, 16) .. p.name .. "  " .. DIM .. (p.rank or "") .. (p.max and ("/" .. p.max) or "") .. "|r")
      if not got then r.info:SetText(GOLD .. "Not read yet|r")
      elseif learned and learned > got.at then r.info:SetText(GOLD .. "You've learned something new since. Read it again.|r")
      else r.info:SetText(#got.list .. " recipes, read " .. ago(got.at)) end
      r.prof = p.name
      r.miss:SetShown(got and Item.list(p.name) and true or false)
      r:Show()
    else r:Hide() end
  end
  recEmpty:SetText(#myProfs == 0 and "No crafting professions on this character." or (InCombatLockdown() and (DIM .. "The Read buttons come back when you leave combat.|r") or ""))
end

-- Dungeons: the ones for your level (the site's list and ranges), whether you've been (from the dungeon runs), and
-- which guildies online now are in range, plus how many more are offline.
local DUNGEONS = { { "Ragefire Chasm", 13, 18 }, { "Hall of Thanes", 13, 20 }, { "Ruins of Lordaeron", 15, 22 }, { "Wailing Caverns", 15, 24 },
  { "The Deadmines", 17, 26 }, { "Shadowfang Keep", 20, 30 }, { "Blackfathom Deeps", 24, 32 }, { "The Stockade", 25, 29 },
  { "Excavation Site: Wetlands", 26, 33 }, { "City of Dalaran", 28, 35 }, { "Razorfen Kraul", 29, 38 }, { "Gnomeregan", 29, 38 },
  { "Scarlet Monastery: Graveyard", 30, 38 }, { "Scarlet Monastery: Library", 33, 41 }, { "The Drowned City", 35, 42 },
  { "Scarlet Monastery: Armory", 36, 44 }, { "Razorfen Downs", 37, 46 }, { "Scarlet Monastery: Cathedral", 38, 46 },
  { "Krol'Dok Stronghold", 40, 47 }, { "Uldaman", 41, 51 }, { "Zul'Farrak", 44, 54 }, { "Maraudon", 46, 55 }, { "Alcaz Island Prison", 48, 55 },
  { "Sunken Temple", 50, 60 }, { "Blackrock Depths", 52, 60 }, { "Dire Maul: East", 54, 60 }, { "Lower Blackrock Spire", 55, 60 },
  { "Blackmaw Hold", 55, 60 }, { "Upper Blackrock Spire", 55, 60 }, { "Dire Maul: West", 56, 60 }, { "Dire Maul: North", 56, 60 },
  { "Shaper's Terrace", 58, 60 }, { "Stratholme: Living", 58, 60 }, { "Stratholme: Undead", 58, 60 }, { "Scholomance", 58, 60 } }
-- The site's achievement groups; everything not in the first two is Master.
local DG_GROUPS = {
  { "Novice", "Novice Spelunker", { "Ragefire Chasm", "Ruins of Lordaeron", "Wailing Caverns", "The Deadmines", "Shadowfang Keep", "Excavation Site: Wetlands" } },
  { "Experienced", "Experienced Spelunker", { "City of Dalaran", "Blackfathom Deeps", "Gnomeregan", "The Drowned City", "Scarlet Monastery: Graveyard", "Scarlet Monastery: Library",
    "Scarlet Monastery: Armory", "Scarlet Monastery: Cathedral", "Razorfen Kraul", "Krol'Dok Stronghold" } },
  { "Master", "Master Spelunker", nil } }
local function groupOf(name)
  for _, g in ipairs(DG_GROUPS) do if g[3] then for _, n in ipairs(g[3]) do if n == name then return g end end end end
  return DG_GROUPS[3]
end
local pDungeons = page("dungeons")
local dgBand, dgScroll = "mine", 0
local dgLabel = text(pDungeons, "GameFontNormalSmall"); dgLabel:SetPoint("TOPLEFT", 14, -37); dgLabel:SetWidth(W - 28)
-- Which dungeons to show: the ones for your level, or one of the site's achievement groups.
local dgBtns = {}
ui.dgShow = ui.dropdown(pDungeons, 150, "Show: ", { { "mine", "For your level" }, { "Novice", "Novice" }, { "Experienced", "Experienced" }, { "Master", "Master" }, { "all", "Every dungeon" } },
  function(k) dgBand, dgScroll = k, 0; refresh() end)
ui.dgShow:SetPoint("TOPLEFT", 14, -6)
ui.dgSortDD = ui.dropdown(pDungeons, 150, "Sort: ", { { "level", "By level" }, { "name", "A to Z" }, { "todo", "Not done first" }, { "online", "Guildies online" } },
  function(k) db.ui.dgSort = k; dgScroll = 0; refresh() end)
ui.dgSortDD:SetPoint("TOPRIGHT", -14, -6)
local ROWS_DG, ROW_H = 8, 36
local dgRows = {}
for i = 1, ROWS_DG do
  local r = CreateFrame("Frame", nil, pDungeons); r:SetSize(W - 28, ROW_H - 2); r:SetPoint("TOPLEFT", 14, -56 - (i - 1) * ROW_H)
  r.name = text(r, "GameFontHighlight"); r.name:SetPoint("TOPLEFT", 0, -1)
  r.flag = text(r, "GameFontNormalSmall", "RIGHT"); r.flag:SetPoint("TOPRIGHT", 0, -2)
  r.name:SetPoint("RIGHT", r.flag, "LEFT", -8, 0)
  r.range = text(r, "GameFontDisableSmall"); r.range:SetPoint("TOPLEFT", r.name, "BOTTOMLEFT", 0, -3); r.range:SetWidth(W - 28)
  -- Click a dungeon to mark it done (or not): the notes only know runs the scribe saw, so older ones need marking once.
  local hit = CreateFrame("Button", nil, r); hit:SetAllPoints()
  local hl = tex(hit, "HIGHLIGHT", 1, 1, 1, 0.05); hl:SetAllPoints()
  hit:SetScript("OnClick", function()
    local me, d = UnitName("player") or "?", r.dungeon
    if not d then return end
    db.stamps[me] = db.stamps[me] or {}
    db.stamps[me][d] = (not db.stamps[me][d]) and now() or nil
    refresh()
  end)
  hit:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(r.dungeon or "", 1, 1, 1)
    if r.whoText and r.whoText ~= "" then GameTooltip:AddLine("Online and in range: " .. r.whoText, 1, 1, 1, true) end
    GameTooltip:AddLine(r.marked and "Marked as done. Click to unmark." or r.fromSite and "Stamped in your passport on the site." or r.seen and "The scribe saw you here." or "Done it before? Click to mark it.", 0.75, 0.75, 0.75)
    GameTooltip:Show()
  end)
  hit:SetScript("OnLeave", function() GameTooltip:Hide() end)
  r:Hide(); dgRows[i] = r
end
pDungeons:EnableMouseWheel(true)
local dgMore = text(pDungeons, "GameFontDisableSmall", "RIGHT"); dgMore:SetPoint("BOTTOMRIGHT", -24, 10)
local dgFoot = ui.foot(pDungeons, { "Dungeons", "Click a dungeon you'd done before the scribe was running to mark it as done.", "Hover one for who's online and in range." })
dgFoot:SetText("Click a dungeon to mark it done  ·  hover for more")
-- Seen by the scribe: a dungeon run or a boss kill there with you in the group. The game names Scarlet Monastery and
-- Dire Maul without the wing, so those count for every wing.
local function sameDungeon(z, dname)
  if not z or z == "" then return false end
  local base = dname:match("^(.-):") or dname
  local zb = z:gsub("^The ", ""):lower()
  return z == dname or z == base or zb == base:gsub("^The ", ""):lower() or zb == dname:gsub("^The ", ""):lower()
end
local function seenIn(dname, me)
  for _, r in pairs(db.runs) do if sameDungeon(r.zone, dname) and r.who and r.who[me] then return true end end
  for _, k in ipairs(db.kills) do if sameDungeon(k.zone, dname) and k.who and k.who[me] then return true end end
  return false
end
local dgCount = 0
pDungeons:SetScript("OnMouseWheel", function(_, delta)
  dgScroll = math.max(0, math.min(math.max(0, dgCount - ROWS_DG), dgScroll - delta))
  refresh()
end)
local function fillDungeons()
  local me, lv = UnitName("player") or "?", UnitLevel("player") or 1
  ui.dgShow:set(dgBand); ui.dgSortDD:set(db.ui.dgSort or "level")
  local list = {}
  if dgBand == "all" then
    for _, d in ipairs(DUNGEONS) do list[#list + 1] = d end
  elseif dgBand == "mine" then
    for _, d in ipairs(DUNGEONS) do if lv >= d[2] and lv <= d[3] then list[#list + 1] = d end end
    if #list == 0 then for _, d in ipairs(DUNGEONS) do if d[2] > lv then list[#list + 1] = d; if #list >= 3 then break end end end end
  else
    for _, d in ipairs(DUNGEONS) do if groupOf(d[1])[1] == dgBand then list[#list + 1] = d end end
  end
  dgCount = #list
  local done = 0
  local scm = siteChar(me)
  local onSite = {}
  if scm and type(scm.dungeons) == "table" then for _, n in ipairs(scm.dungeons) do onSite[n] = true end end
  local isDone = {}
  for _, d in ipairs(list) do if seenIn(d[1], me) or onSite[d[1]] or (db.stamps[me] and db.stamps[me][d[1]]) then done = done + 1; isDone[d[1]] = true end end
  do
    local by = db.ui.dgSort or "level"
    local inRange = {}
    if by == "online" then
      for _, d in ipairs(list) do
        local n = 0
        for _, o in ipairs(onlineNow) do local l = tonumber(o.level) or 0; if l >= d[2] and l <= d[3] and first(o.name) ~= me then n = n + 1 end end
        inRange[d[1]] = n
      end
    end
    local pos = {}
    for i, d in ipairs(list) do pos[d[1]] = i end
    table.sort(list, function(x, y)
      if by == "name" then return x[1] < y[1] end
      if by == "todo" and (isDone[x[1]] or false) ~= (isDone[y[1]] or false) then return not isDone[x[1]] end
      if by == "online" and inRange[x[1]] ~= inRange[y[1]] then return inRange[x[1]] > inRange[y[1]] end
      return pos[x[1]] < pos[y[1]]
    end)
  end
  if dgBand == "all" then dgLabel:SetText(GOLD .. "Every dungeon|r" .. DIM .. "   " .. done .. " of " .. #list .. " done by " .. fullName(me) .. "|r")
  elseif dgBand == "mine" then dgLabel:SetText(GOLD .. "For " .. fullName(me) .. ", level " .. lv .. "|r" .. DIM .. "   " .. done .. " of " .. #list .. " done|r")
  else local g; for _, x in ipairs(DG_GROUPS) do if x[1] == dgBand then g = x end end
    dgLabel:SetText(GOLD .. g[2] .. "|r" .. DIM .. "   " .. done .. " of " .. #list .. " done by " .. fullName(me) .. "|r") end
  local on = {}
  for _, o in ipairs(onlineNow) do on[o.name] = o end
  local fresh = now() - 14 * 86400
  for i, r in ipairs(dgRows) do
    local d = list[i + dgScroll]
    if d then
      r.dungeon = d[1]
      r.marked = db.stamps[me] and db.stamps[me][d[1]] and true or false
      local sc = siteChar(me)
      r.seen = seenIn(d[1], me)
      if not r.seen and sc and type(sc.dungeons) == "table" then for _, n in ipairs(sc.dungeons) do if n == d[1] then r.seen = true; r.fromSite = true end end end
      r.name:SetText(d[1])
      r.flag:SetText((r.seen or r.marked) and (DIM .. "Been|r") or lv < d[2] and (DIM .. "From level " .. d[2] .. "|r") or (GOLD .. "Not yet|r"))
      local names, off = {}, 0
      for name, m in pairs(db.members) do
        local l = m.level or 0
        if not m.gone and l >= d[2] and l <= d[3] and first(name) ~= me then
          if on[name] then names[#names + 1] = nameIn(name, m.class) .. " " .. DIM .. l .. "|r"
          elseif (m.last or 0) >= fresh then off = off + 1 end
        end
      end
      table.sort(names)
      r.whoText = table.concat(names, ", ")
      r.range:SetText("Levels " .. d[2] .. "–" .. d[3] .. "  ·  " .. (#names > 0 and (#names .. " online in range: " .. r.whoText) or "nobody online in range") .. (off > 0 and (DIM .. "  +" .. off .. " offline|r") or ""))
      r:Show()
    else r:Hide() end
  end
  dgMore:SetText(#list > ROWS_DG and ((dgScroll + 1) .. "–" .. math.min(#list, dgScroll + ROWS_DG) .. " of " .. #list .. "  ·  scroll") or "")
end

-- Tabs along the top
local TABS = { { "today", "Today" }, { "week", "Week" }, { "dungeons", "Dungeons" }, { "recipes", "Recipes" }, { "loot", "Loot" }, { "scribe", "Scribe" } }
-- The Online list: sort it (the button cycles zone, level, name, class) and scroll it with the mouse wheel.
do
  local b = ui.dropdown(pToday, 150, "Sort: ", { { "zone", "Zone" }, { "level", "Level" }, { "name", "Name" }, { "class", "Class" } },
    function(k) db.ui.sort = k; ui.onOff = 0; refresh() end)
  b:SetPoint("TOPRIGHT", -14, -6)
  pToday:EnableMouseWheel(true)
  pToday:SetScript("OnMouseWheel", function(_, d) ui.onOff = math.max(0, (ui.onOff or 0) - d); refresh() end)
  ui.sortOnline = function()
    local by = db.ui.sort or "zone"
    b:set(by)
    table.sort(onlineNow, function(x, y)
      local kx, ky
      if by == "level" then kx, ky = -(tonumber(x.level) or 0), -(tonumber(y.level) or 0)
      elseif by == "class" then kx, ky = x.class or "", y.class or ""
      elseif by == "name" then kx, ky = x.name, y.name
      else kx, ky = x.zone or "", y.zone or "" end
      if kx ~= ky then return kx < ky end
      return x.name < y.name
    end)
    ui.onOff = math.max(0, math.min(ui.onOff or 0, #onlineNow - 7))
    return ui.onOff
  end
end
local function show(key)
  current = key
  if key ~= "settings" and key ~= "alts" then ui.back = key; if db then db.ui.tab = key end end
  for k, p in pairs(pages) do if k == key then p:Show() else p:Hide() end end
  local nr = ui.needReading and ui.needReading() or 0
  for _, t in ipairs(tabs) do
    -- A tab glows when it has something for you: professions to read, or what's new after an update.
    if t.setGlow then
      if t.key == "recipes" then t:setGlow(nr > 0 and key ~= "recipes") end
      if t.key == "scribe" then t:setGlow(ui.news and key ~= "scribe" and true or false) end
    end
    t:setOn(t.key == key)
  end
  if key == "scribe" and ui.news and db then ui.news = nil; db.ui.ver = ui.ver end
  refresh()
end
for i, t in ipairs(TABS) do
  local b = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
  local tw = (W - 28 - 4 * (#TABS - 1)) / #TABS
  wowButton(b, tw, 24, t[2]); b:SetPoint("TOPLEFT", 14 + (i - 1) * (tw + 4), -56)
  b.key = t[1]
  b:SetScript("OnClick", function() show(t[1]) end)
  local g = b:CreateTexture(nil, "OVERLAY"); g:SetPoint("TOPLEFT", 3, -3); g:SetPoint("BOTTOMRIGHT", -3, 3); g:SetColorTexture(1, 0.78, 0.25, 0.30)
  if g.SetBlendMode then g:SetBlendMode("ADD") end
  g:Hide()
  local ag
  pcall(function()
    ag = g:CreateAnimationGroup(); ag:SetLooping("BOUNCE")
    local a = ag:CreateAnimation("Alpha"); a:SetFromAlpha(0.25); a:SetToAlpha(1); a:SetDuration(0.9)
  end)
  b.setGlow = function(_, on)
    if on then g:Show() else g:Hide() end
    if ag and ag.Play then pcall(on and ag.Play or ag.Stop, ag) end
  end
  tabs[i] = b
end
do
  local b = wowButton(CreateFrame("Button", nil, win, "UIPanelButtonTemplate"), 68, 20, "Settings"); b:SetPoint("TOPRIGHT", -38, -16)
  b:SetScript("OnClick", function() show(current == "settings" and (ui.back or "today") or "settings") end)
  local a = wowButton(CreateFrame("Button", nil, win, "UIPanelButtonTemplate"), 48, 20, "Alts"); a:SetPoint("RIGHT", b, "LEFT", -4, 0)
  a:SetScript("OnClick", function() show(current == "alts" and (ui.back or "today") or "alts") end)
end


-------------------------------------------------------------------- filling the tabs
local pip   -- the minimap count, set below
local function fillToday()
  local off = ui.sortOnline()
  onlineLabel:SetText("Online now  ·  " .. #onlineNow)
  for i, r in ipairs(onlineRows) do
    local o = onlineNow[i + off]
    if i == #onlineRows and #onlineNow > off + #onlineRows then setRow(r, "", DIM .. "and " .. (#onlineNow - off - #onlineRows + 1) .. " more  ·  scroll|r", "")
    elseif o then setRow(r, dot(o.class), nameIn(o.name, o.class) .. "  " .. DIM .. (o.level or "") .. "|r" .. altTag(o.name), o.zone or ""); r.who = o.name
    else r:Hide() end
  end
  if #onlineNow == 0 then setRow(onlineRows[1], "", DIM .. "Nobody else is on right now.|r", "") end
  local feed = todayFeed()
  -- On busy days the level-ups would fill the list, so more than three become one line (hover it for everyone).
  local dings = {}
  for _, e in ipairs(feed) do if e.kind == "ding" then dings[#dings + 1] = e end end
  if #dings > 3 then
    local kept, put = {}, false
    for _, e in ipairs(feed) do
      if e.kind ~= "ding" then kept[#kept + 1] = e
      elseif not put then put = true; kept[#kept + 1] = { kind = "dings", t = e.t, list = dings } end
    end
    feed = kept
  end
  todayLabel:SetText("Today")
  for i, r in ipairs(feedRows) do
    local e = feed[i]
    if not e then r:Hide()
    elseif e.kind == "run" then
      local g = guildiesIn(e.who)
      setRow(r, IC_RUN, INK .. e.zone .. "|r" .. DIM .. "  ·  " .. e.n .. (e.n == 1 and " boss" or " bosses") .. (g > 1 and (", with " .. (g - 1) .. (g == 2 and " guildie" or " guildies")) or "") .. "|r", clock(e.t))
    elseif e.kind == "loot" then
      setRow(r, IC_LOOT, memberName(e.l.who) .. " looted " .. itemText(e.l), clock(e.t))
      r.item = e.l.id; r.itemName = e.l.name
    elseif e.kind == "ding" then
      setRow(r, IC_DING, nameIn(e.name, e.class) .. " reached level " .. e.level .. altTag(e.name), clock(e.t))
    elseif e.kind == "dings" then
      local tip, top = {}, {}
      for _, d in ipairs(e.list) do tip[#tip + 1] = nameIn(d.name, d.class) .. "  level " .. d.level .. "  " .. DIM .. clock(d.t) .. "|r"; if #top < 3 then top[#top + 1] = nameIn(first(d.name), d.class) end end
      setRow(r, IC_DING, #e.list .. " guildies levelled up today: " .. table.concat(top, ", ") .. DIM .. " and more|r", clock(e.t), nil, tip)
    elseif e.kind == "join" then
      setRow(r, IC_JOIN, INK .. e.name .. "|r joined the guild", clock(e.t))
    elseif e.kind == "leave" then
      setRow(r, IC_LEAVE, DIM .. e.name .. (e.what == "removed" and " was removed from the guild" or " left the guild") .. "|r", clock(e.t))
    else
      setRow(r, IC_ANNIV, nameIn(e.name, e.class) .. " has been in the guild " .. (e.months == 1 and "a month" or e.months % 12 == 0 and (e.months / 12 == 1 and "a year" or (e.months / 12) .. " years") or e.months .. " months"), "today")
    end
  end
  if #feed == 0 then setRow(feedRows[1], "", DIM .. "Nothing yet today. Runs, good drops and dings show here.|r", "") end
  local z = zoneTotals(1)[1]
  local nr = ui.needReading and ui.needReading() or 0
  todayFoot:SetText(nr > 0 and (GOLD .. nr .. (nr == 1 and " profession needs" or " professions need") .. " reading for the site: see the Recipes tab.|r")
    or (z and ("Busiest today: " .. z[1] .. ", " .. hrs(z[2]) .. " of guild time") or ""))
end
local function fillWeek()
  local list = zoneTotals(7)
  local top = list[1] and list[1][2] or 1
  local by = db.ui.zoneSort or "time"
  ui.zoneDD:set(by)
  if by == "people" then table.sort(list, function(a, b) if a[3] ~= b[3] then return a[3] > b[3] end return a[2] > b[2] end)
  elseif by == "name" then table.sort(list, function(a, b) return a[1] < b[1] end) end
  local off = math.max(0, math.min(ui.zoneOff or 0, #list - #zoneRows)); ui.zoneOff = off
  for i, r in ipairs(zoneRows) do
    local z = list[i + off]
    if z then setRow(r, GOLD .. (i + off) .. "|r", INK .. z[1] .. "|r" .. DIM .. "  " .. z[3] .. (z[3] == 1 and " guildie" or " guildies") .. "|r", hrs(z[2]), z[2] / top) else r:Hide() end
  end
  if not list[1] then setRow(zoneRows[1], "", DIM .. "No zone time noted this week yet.|r", "") end
  local avg, max, best = hourGrid()
  for d = 0, 6 do for h = 0, 23 do
    local a, c = avg[d][h], grid[d][h]
    if a and max > 0 then local s = SHADES[math.max(1, math.ceil(a / max * 5))]; c:SetColorTexture(s[1], s[2], s[3], 1)
    else c:SetColorTexture(0.13, 0.08, 0.06, 1) end
  end end
  local dn = { "Mondays", "Tuesdays", "Wednesdays", "Thursdays", "Fridays", "Saturdays", "Sundays" }
  weekFoot:SetText(best and ("Busiest: " .. GOLD .. dn[best[1] + 1] .. " around " .. ((best[2] % 12 == 0) and 12 or best[2] % 12) .. (best[2] < 12 and "am" or "pm") .. "|r, " .. (math.floor(best[3] * 10 + 0.5) / 10) .. " online") or "Busiest hours show after a few days of notes.")
end
local function fillScribe()
  local days, firstDay = {}, nil
  for k in pairs(db.hours) do local d = k:sub(1, 10); days[d] = true; if not firstDay or d < firstDay then firstDay = d end end
  local nd = 0; for _ in pairs(days) do nd = nd + 1 end
  local nr = 0; for _ in pairs(db.runs) do nr = nr + 1 end
  big[1].n:SetText(nd); big[1].l:SetText(nd == 1 and "day of hours" or "days of hours")
  big[2].n:SetText(nr); big[2].l:SetText(nr == 1 and "dungeon run" or "dungeon runs")
  local nl = 0; for _, l in ipairs(db.loot) do if l.who == short(UnitName("player")) or guildie(l.who) then nl = nl + 1 end end
  big[3].n:SetText(nl); big[3].l:SetText(nl == 1 and "good drop" or "good drops")
  local n = 0; for _, m in pairs(db.members) do if not m.gone then n = n + 1 end end
  local hs = ui.heard and ui.heard() or {}
  scribeInfo:SetText(n .. " guildies on the list, " .. #db.kills .. " boss kills noted" .. (firstDay and (", notes back to " .. firstDay) or "") .. ". "
    .. (not db.ui.share and "Sharing with other scribes is off." or #hs > 0 and ("Sharing with " .. table.concat(hs, ", ") .. ".") or "No other scribes heard from this session.")
    .. (site() and (" Site data from " .. tostring(site().at or "?"):sub(1, 10) .. ".") or " No site data yet: on the site, Roster, Details, Download for the addon."))
  for k, c in pairs(checks) do c:SetChecked(db.ui[k] and true or false) end
  if ui.mainBtn then ui.mainBtn() end
end
refresh = function()
  if not db then return end
  if pip then pip() end
  if not win:IsShown() then ui.readSync(); return end
  if current == "today" then fillToday() elseif current == "week" then fillWeek() elseif current == "dungeons" then fillDungeons() elseif current == "recipes" then fillRecipes() elseif current == "loot" then ui.fillLoot() elseif current == "settings" then ui.fillSettings() elseif current == "alts" then ui.fillAlts() else fillScribe() end
  if current == "today" then db.ui.seen = now(); if pip then pip() end end
  ui.readSync()
end
win:SetScript("OnShow", function() show(current) end)
win:HookScript("OnHide", function() ui.readSync() end)

-------------------------------------------------------------------- the minimap button
local mm = CreateFrame("Button", "BloodAndTearsScribeMinimapButton", Minimap)
mm:SetSize(31, 31); mm:SetFrameStrata("MEDIUM"); mm:SetFrameLevel(8)
mm:RegisterForClicks("LeftButtonUp", "RightButtonUp"); mm:RegisterForDrag("LeftButton")
if mm.SetHighlightTexture then mm:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight") end
local mmBg = mm:CreateTexture(nil, "BACKGROUND"); mmBg:SetTexture("Interface\\Minimap\\UI-Minimap-Background"); mmBg:SetSize(20, 20); mmBg:SetPoint("TOPLEFT", 7, -5)
local mmIcon = mm:CreateTexture(nil, "ARTWORK"); mmIcon:SetTexture(LOGO); mmIcon:SetSize(20, 20); mmIcon:SetPoint("TOPLEFT", 6, -5)
local mmBorder = mm:CreateTexture(nil, "OVERLAY"); mmBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder"); mmBorder:SetSize(53, 53); mmBorder:SetPoint("TOPLEFT")
local pipBg = mm:CreateTexture(nil, "OVERLAY", nil, 2); pipBg:SetColorTexture(0.78, 0.06, 0.18, 1); pipBg:SetSize(14, 12); pipBg:SetPoint("TOPRIGHT", 2, 2)
local pipText = mm:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"); pipText:SetPoint("CENTER", pipBg, "CENTER", 0, 0)
local function place()
  local a = math.rad((db and db.ui.angle) or 200)
  local r = (Minimap:GetWidth() / 2) + 10
  mm:ClearAllPoints(); mm:SetPoint("CENTER", Minimap, "CENTER", math.cos(a) * r, math.sin(a) * r)
end
pip = function()
  local n = 0
  if db and db.ui.pip then n = #todayFeed(db.ui.seen or 0) end
  if n > 0 then pipText:SetText(n > 9 and "9+" or n); pipBg:SetWidth(n > 9 and 18 or 14); pipBg:Show(); pipText:Show() else pipBg:Hide(); pipText:Hide() end
end
mm:SetScript("OnClick", function() if win:IsShown() then win:Hide() else win:Show() end end)
mm:SetScript("OnDragStart", function(self)
  self:SetScript("OnUpdate", function()
    local mx, my = Minimap:GetCenter()
    local px, py = GetCursorPosition()
    local sc = Minimap:GetEffectiveScale()
    db.ui.angle = math.deg(math.atan2(py / sc - my, px / sc - mx))
    place()
  end)
end)
mm:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
mm:SetScript("OnEnter", function(self)
  GameTooltip:SetOwner(self, "ANCHOR_LEFT")
  GameTooltip:AddLine("Blood and Tears Scribe", 0.94, 0.76, 0.35)
  GameTooltip:AddLine(#onlineNow .. " guildies online", 1, 1, 1)
  local n = db and #todayFeed(db.ui.seen or 0) or 0
  if n > 0 then GameTooltip:AddLine(n .. (n == 1 and " new note today" or " new notes today"), 1, 1, 1) end
  local nr = ui.needReading and ui.needReading() or 0
  if nr > 0 then GameTooltip:AddLine(nr .. (nr == 1 and " profession to read (Recipes tab)" or " professions to read (Recipes tab)"), 0.94, 0.76, 0.35) end
  GameTooltip:AddLine("Click to open. Drag to move.", 0.66, 0.58, 0.49)
  GameTooltip:Show()
end)
mm:SetScript("OnLeave", function() GameTooltip:Hide() end)

check("pip", "Count new notes on the minimap button", -164, pip)
check("summary", "Show my session summary when I log out", -188)
check("lock", "Lock the window in place", -212)
check("hideButton", "Hide the minimap button (/scribe still opens the window)", -236, function() if db.ui.hideButton then mm:Hide() else mm:Show() end end)
check("share", "Share notes with guildies who run the scribe too", -260)
-- Your main, for "alt of" on your other characters (here, and for other scribes over the sharing).
local mainLabel = text(pages.settings, "GameFontHighlightSmall"); mainLabel:SetPoint("TOPLEFT", 16, -156)
local mainBtn = wowButton(CreateFrame("Button", nil, pages.settings, "UIPanelButtonTemplate"), 160, 22, "")
mainBtn:SetPoint("LEFT", mainLabel, "RIGHT", 8, 0)
mainBtn:SetScript("OnClick", function()
  local names = {}
  for n in pairs(db.mine) do names[#names + 1] = n end
  table.sort(names)
  if #names == 0 then return end
  local cur = myMain()
  for i, n in ipairs(names) do if n == cur then db.ui.main = names[i % #names + 1]; break end end
  if not db.ui.main or not db.mine[db.ui.main] then db.ui.main = names[1] end
  refresh()
end)
ui.mainBtn = function() local mn = myMain(); mainLabel:SetText("Your main:"); mainBtn:SetText(mn and fullName(mn) or "log in on it once") end
-- Window size: drag the slider (or roll the mouse wheel over it); the window resizes when you let go.
do
  local p = pages.settings
  local l = text(p, "GameFontHighlightSmall"); l:SetPoint("TOPLEFT", 16, -194)
  local sl = CreateFrame("Slider", nil, p)
  sl:SetOrientation("HORIZONTAL"); sl:SetSize(220, 16); sl:SetPoint("TOPLEFT", 16, -214)
  sl:SetMinMaxValues(70, 150); sl:SetValueStep(5)
  if sl.SetObeyStepOnDrag then sl:SetObeyStepOnDrag(true) end
  local track = tex(sl, "BACKGROUND", 0.20, 0.13, 0.11, 1); track:SetPoint("LEFT", 0, 0); track:SetPoint("RIGHT", 0, 0); track:SetHeight(4)
  sl:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
  local hint = text(p, "GameFontDisableSmall"); hint:SetPoint("TOPLEFT", 16, -236); hint:SetText("70% to 150%. Good for smaller screens.")
  local function pct() return math.max(70, math.min(150, math.floor((sl:GetValue() or 100) / 5 + 0.5) * 5)) end
  local dirty = false
  local function apply()
    dirty = false
    db.ui.scale = pct() / 100
    win:SetScale(db.ui.scale)
    ui.readSync()
  end
  sl:SetScript("OnValueChanged", function() l:SetText("Window size: " .. pct() .. "%"); if db and pct() / 100 ~= (db.ui.scale or 1) then dirty = true end end)
  -- Resizing while the thumb is held would move the slider under the cursor, so wait for the button to come up.
  sl:SetScript("OnUpdate", function() if dirty and not (IsMouseButtonDown and IsMouseButtonDown("LeftButton")) then apply() end end)
  sl:EnableMouseWheel(true)
  sl:SetScript("OnMouseWheel", function(_, d) sl:SetValue(pct() + (d > 0 and 5 or -5)) end)
  local reset = wowButton(CreateFrame("Button", nil, p, "UIPanelButtonTemplate"), 60, 22, "Reset"); reset:SetPoint("LEFT", sl, "RIGHT", 12, 0)
  reset:SetScript("OnClick", function() sl:SetValue(100) end)
  ui.fillSettings = function()
    for k, c in pairs(checks) do c:SetChecked(db.ui[k] and true or false) end
    sl:SetValue(math.floor((db.ui.scale or 1) * 100 + 0.5)); l:SetText("Window size: " .. pct() .. "%")
    if ui.mainBtn then ui.mainBtn() end
  end
  -- The same from the window's bottom-right corner: drag the grip to resize (the top-left corner stays put).
  local grip = CreateFrame("Button", nil, win)
  grip:SetSize(16, 16); grip:SetPoint("BOTTOMRIGHT", -5, 5); grip:SetFrameLevel((win:GetFrameLevel() or 1) + 30)
  grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
  grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
  grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
  grip:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine("Drag to resize the window", 1, 1, 1); GameTooltip:Show() end)
  grip:SetScript("OnLeave", function() GameTooltip:Hide() end)
  grip:SetScript("OnMouseDown", function(self)
    local x0, y0 = GetCursorPosition()
    local s0 = win:GetScale() or 1
    local L, T = (win:GetLeft() or 0) * s0, (win:GetTop() or 0) * s0
    self:SetScript("OnUpdate", function()
      local x, y = GetCursorPosition()
      local d = ((x - x0) + (y0 - y)) / 2 / (UIParent:GetEffectiveScale() or 1)
      local sc = math.max(0.7, math.min(1.5, math.floor((s0 + d / W) * 20 + 0.5) / 20))
      if sc ~= win:GetScale() then
        win:SetScale(sc); win:ClearAllPoints(); win:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", L / sc, T / sc)
      end
    end)
  end)
  grip:SetScript("OnMouseUp", function(self)
    self:SetScript("OnUpdate", nil)
    db.ui.scale = win:GetScale() or 1
    sl:SetValue(math.floor(db.ui.scale * 100 + 0.5))
    ui.readSync()
  end)
  ui.applyScale = function() local sc = tonumber(db.ui.scale) or 1; if sc < 0.7 or sc > 1.5 then sc = 1 end; db.ui.scale = sc; win:SetScale(sc) end
end
-- What's new, on the Scribe tab. The tab says "(new)" after an update until it's been looked at.
do
  local head = label(pScribe, "What's new", -146)
  local t = text(pScribe, "GameFontHighlightSmall"); t:SetPoint("TOPLEFT", 14, -164); t:SetWidth(W - 28)
  if t.SetWordWrap then t:SetWordWrap(true) end
  t:SetJustifyV("TOP"); t:SetHeight(200)
  if t.SetSpacing then t:SetSpacing(3) end
  head:SetText("What's new in " .. ui.ver)
  t:SetText(GOLD .. "While you were away|r  After a while off, a panel at login shows who levelled, joined, and what dropped. Off in Settings.\n"
    .. GOLD .. "Tidier|r  Controls sit in the same place on every tab, with class and profession icons.\n"
    .. GOLD .. "Alts|r  A button at the top: your characters' levels, professions, gold and time played.\n"
    .. GOLD .. "Works in combat|r  The window opens and updates in a fight now (only the Read buttons wait).\n"
    .. GOLD .. "Loot tab|r  Every good drop guildies got, with the boss. Search it, filter by quality, hover for the tooltip, shift-click to link.\n"
    .. GOLD .. "Recipes|r  Tooltips list what a recipe needs. Crafters who are online come first, with a green dot. Missing shows what you can't make yet. Scroll long lists.\n"
    .. GOLD .. "Online list|r  Sort it by zone, level, name or class. Right-click a guildie to whisper or invite. Scroll if it's long.\n"
    .. GOLD .. "Settings|r  Their own page (button at the top). Resize the window there, or drag its bottom-right corner.\n"
    .. GOLD .. "Also|r  The window reopens on the tab you left, and alt-click any item to see who can make it.")
end

-------------------------------------------------------------------- the session summary
-- What you did since you logged in: levels, time played, zones (counted each minute), bosses, good drops, and the
-- guildies you were grouped with. Shown during the logout countdown, or any time with /scribe summary.
local sess
local function sessionTick()
  if not sess then return end
  if ui.noteMe then ui.noteMe() end
  local z = GetRealZoneText and GetRealZoneText() or nil
  if z and z ~= "" then sess.zones[z] = (sess.zones[z] or 0) + 1 end
  local me = UnitName("player")
  for n in pairs(groupNames()) do
    if n ~= short(me) then local m, full = guildie(n); if m then sess.with[full] = (sess.with[full] or 0) + 1 end end
  end
end
ui.login = function()
  local me = UnitName("player")
  if me then db.mine[me] = { lv = UnitLevel("player"), at = now(), class = select(2, UnitClass("player")) } end
  if ui.sharing then ui.sharing() end
  sess = { t = now(), level = UnitLevel("player"), zones = {}, with = {} }
  -- Back on the tab you left, at the size you chose; and note whether this is a new version.
  if db.ui.tab and pages[db.ui.tab] then current = db.ui.tab end
  ui.applyScale()
  ui.news = db.ui.ver ~= ui.ver
  if ui.awayStart then pcall(ui.awayStart) end   -- before noteMe, which marks you as on now
  if ui.noteMe then ui.noteMe() end
  if ui.askPlayed then C_Timer.After(6, function() pcall(ui.askPlayed) end) end
  C_Timer.NewTicker(60, sessionTick)
  if db.ui.hideButton then mm:Hide() end
  readSkills()
  place(); pip()
end

local sum = panel("BloodAndTearsScribeSummary", W + 40, 430)
sum:SetPoint("CENTER", 0, 80)
local sumStats = {}
for i = 1, 4 do
  local box = tex(sum, "BACKGROUND", 0.07, 0.04, 0.03, 1)
  local bw = (W + 40 - 24 - 18) / 4
  box:SetSize(bw, 46); box:SetPoint("TOPLEFT", 12 + (i - 1) * (bw + 6), -58)
  local n = text(sum, "GameFontNormalLarge", "CENTER"); n:SetPoint("TOP", box, "TOP", 0, -7); n:SetWidth(bw)
  local l = text(sum, "GameFontDisableSmall", "CENTER"); l:SetPoint("BOTTOM", box, "BOTTOM", 0, 6); l:SetWidth(bw)
  sumStats[i] = { n = n, l = l }
end
local sumLines = {}
for i = 1, 16 do
  local fs = text(sum, "GameFontHighlightSmall"); fs:SetPoint("TOPLEFT", 16, -114 - (i - 1) * 16); fs:SetWidth(W + 8)
  sumLines[i] = fs
end
-- Items named in the summary: hover for the tooltip, shift-click to link in chat.
pcall(function()
  sum:SetHyperlinksEnabled(true)
  sum:SetScript("OnHyperlinkEnter", function(self, link)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    if pcall(GameTooltip.SetHyperlink, GameTooltip, link) then GameTooltip:Show() end
  end)
  sum:SetScript("OnHyperlinkLeave", function() GameTooltip:Hide() end)
  sum:SetScript("OnHyperlinkClick", function(_, link)
    if not (IsModifiedClick and IsModifiedClick("CHATLINK") and ChatEdit_InsertLink) then return end
    local l = Item.link(link)
    if l then ChatEdit_InsertLink(l) end
  end)
end)
local close = wowButton(CreateFrame("Button", nil, sum, "UIPanelButtonTemplate"), 90, 24, "Close"); close:SetPoint("BOTTOMRIGHT", -14, 12)
close:SetScript("OnClick", function() sum:Hide() end)

local function fillSummary(leaving)
  if not sess then return end
  local me, t = UnitName("player"), now()
  local lv = UnitLevel("player")
  sum.title:SetText(fullName(me) .. "'s session")
  sum.sub:SetText("Level " .. (sess.level or lv) .. (lv ~= sess.level and (" to " .. lv) or "") .. "  ·  " .. clock(sess.t) .. " to " .. clock(t))
  local bosses, drops = {}, {}
  for _, k in ipairs(db.kills) do if k.t >= sess.t then bosses[#bosses + 1] = k end end
  for _, l in ipairs(db.loot) do if l.t >= sess.t and l.who == short(me) then drops[#drops + 1] = l end end
  local vals = { { (lv - (sess.level or lv) >= 0 and "+" or "") .. (lv - (sess.level or lv)), "Levels" }, { dur(t - sess.t), "Played" }, { #bosses, "Bosses" }, { #drops, "Drops" } }
  for i, v in ipairs(vals) do sumStats[i].n:SetText(v[1]); sumStats[i].l:SetText(v[2]) end
  local out = {}
  local zl = {}
  for z, m in pairs(sess.zones) do zl[#zl + 1] = { z, m } end
  table.sort(zl, function(a, b) return a[2] > b[2] end)
  if #zl > 0 then
    out[#out + 1] = GOLD .. "Where you went|r"
    local bits = {}
    for i = 1, math.min(4, #zl) do bits[#bits + 1] = INK .. zl[i][1] .. "|r " .. DIM .. hrs(zl[i][2]) .. "|r" end
    out[#out + 1] = table.concat(bits, "   ")
  end
  if #bosses > 0 then
    out[#out + 1] = GOLD .. "Dungeons|r"
    local by, order = {}, {}
    for _, k in ipairs(bosses) do local z = k.zone or "?"; if not by[z] then by[z] = {}; order[#order + 1] = z end; table.insert(by[z], k.boss) end
    for i = 1, math.min(3, #order) do local z = order[i]; out[#out + 1] = INK .. z .. "|r" .. DIM .. "  ·  " .. table.concat(by[z], ", ") .. "|r" end
  end
  if #drops > 0 then
    out[#out + 1] = GOLD .. "Drops|r"
    local bits = {}
    for i = 1, math.min(6, #drops) do bits[#bits + 1] = itemText(drops[i]) end
    out[#out + 1] = table.concat(bits, "  ")
    if #drops > 6 then out[#out + 1] = DIM .. "and " .. (#drops - 6) .. " more|r" end
  end
  local wl = {}
  for n, m in pairs(sess.with) do wl[#wl + 1] = { n, m } end
  table.sort(wl, function(a, b) return a[2] > b[2] end)
  if #wl > 0 then
    out[#out + 1] = GOLD .. "With guildies|r"
    local bits = {}
    for i = 1, math.min(5, #wl) do local m = db.members[wl[i][1]]; bits[#bits + 1] = nameIn(wl[i][1], m and m.class) .. DIM .. " " .. hrs(wl[i][2]) .. "|r" end
    out[#out + 1] = table.concat(bits, ",  ")
  end
  if #out == 0 then out[1] = DIM .. "A quiet one. Nothing noted this session yet.|r" end
  for i, fs in ipairs(sumLines) do fs:SetText(out[i] or "") end
  sum:SetHeight(math.max(200, 114 + #out * 16 + 50))
end
ui.loggingOut = function() if db and db.ui.summary and sess then sessionTick(); fillSummary(true); sum:Show() end end
ui.logoutCancelled = function() sum:Hide() end

-------------------------------------------------------------------- /scribe
SLASH_BTSCRIBE1 = "/scribe"
SlashCmdList.BTSCRIBE = function(arg)
  if not db then return end
  arg = (arg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  if arg == "summary" then fillSummary(false); sum:Show(); return end
  if arg == "button" then db.ui.hideButton = not db.ui.hideButton; if db.ui.hideButton then mm:Hide() else mm:Show(); place() end; return end
  if arg == "reset" then win:ClearAllPoints(); win:SetPoint("CENTER", 0, 60); db.ui.angle = 200; place(); win:Show(); return end
  if arg == "week" then show("week") elseif arg == "dungeons" then show("dungeons") elseif arg == "recipes" then show("recipes") elseif arg == "files" or arg == "file" then show("scribe") end
  if win:IsShown() and arg == "" then win:Hide() else win:Show() end
end

-- Alt-click any item (in your bags, a chat link, a vendor, the auction house) to look up who can make it: the
-- scribe's window opens on the recipe search with that item's name. Shift-click is left alone (it links to chat).
if hooksecurefunc and HandleModifiedItemClick then
  pcall(hooksecurefunc, "HandleModifiedItemClick", function(link)
    pcall(function()
      if not db or type(link) ~= "string" then return end
      if not (IsAltKeyDown and IsAltKeyDown()) or (IsShiftKeyDown and IsShiftKeyDown()) or (IsControlKeyDown and IsControlKeyDown()) then return end
      local name = link:match("%[(.-)%]")
      if not name or name == "" then return end
      show("recipes"); win:Show()
      searchHint:Hide()
      search:SetText(name:sub(1, 60))
    end)
  end)
end

---------------------------------------------------------------------------------------------------------------------
-- Sharing between scribes. Every copy in the guild talks over the game's hidden addon channel (prefix BTScribe1), so
-- whatever one scribe saw reaches the others, and any one upload carries it all. Nothing leaves the game.
--   D  digest: for each of the last 14 days, a single number summing what this copy holds for it. Sent at login,
--      every 15 minutes, and in reply to someone else's. A copy that holds more for a day sends that day.
--   H  hours online, Z zone minutes, K boss kills, U dungeon runs, S last-seen times (one day's worth each).
--   P  the sender's own level and professions; R its own recipe lists (in pieces).
-- Everything merges by keeping the larger number (or the newer list), so the same thing heard twice counts once.
---------------------------------------------------------------------------------------------------------------------
local PREFIX, SYNC_DAYS = "BTScribe1", 14
local reg = (C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix) or RegisterAddonMessagePrefix
local sendRaw = (C_ChatInfo and C_ChatInfo.SendAddonMessage) or SendAddonMessage
if reg then pcall(reg, PREFIX) end
local heard = {}          -- who we've heard from this session, and when (for the Scribe tab)
local queue, qset = {}, {}
local function send(msg)
  if not (db and db.ui.share and sendRaw and IsInGuild()) then return end
  if #queue > 600 then return end
  queue[#queue + 1] = msg:sub(1, 250)
end
-- Out a few at a time, so it never adds lag or trips the game's limits.
C_Timer.NewTicker(0.35, function()
  if #queue == 0 then return end
  local m = table.remove(queue, 1)
  pcall(sendRaw, PREFIX, m, "GUILD")
end)
local function num(x, lo, hi) x = tonumber(x); if not x or x ~= x then return nil end if x < lo then x = lo end if x > hi then x = hi end return x end
local function clean(x, n) x = tostring(x or ""):gsub("[~%^|\r\n]", ""):sub(1, n or 60); return x end
local function syncDays()
  local out = {}
  for i = 0, SYNC_DAYS - 1 do out[#out + 1] = dayOf(now() - i * 86400) end
  return out
end
-- One number for everything this copy holds about a day: if it's bigger than someone else's, we know more.
local function daySum(d)
  local n = 0
  for h = 0, 23 do n = n + (db.hours[("%s %02d"):format(d, h)] or 0) end
  for _, who in pairs(db.zones[d] or {}) do for _, m in pairs(who) do n = n + m end end
  for _, k in ipairs(db.kills) do if dayOf(k.t) == d then n = n + 7 end end
  for _, r in pairs(db.runs) do if r.day == d then for _ in pairs(r.who or {}) do n = n + 3 end end end
  for _, m in pairs(db.members) do if m.last and dayOf(m.last) == d then n = n + 1 end end
  return math.floor(n + 0.5)
end
local lastDigest = 0
local function sendDigest(force)
  if not db or (not force and now() - lastDigest < 120) then return end
  lastDigest = now()
  local bits = {}
  for _, d in ipairs(syncDays()) do local n = daySum(d); if n > 0 then bits[#bits + 1] = d:gsub("-", "") .. ":" .. n end end
  send("D~1~" .. table.concat(bits, ","))
end
-- A list of "key:value" pairs in as few messages as fit.
local function sendList(head, items)
  local cur = {}
  local len = #head
  for _, it in ipairs(items) do
    if len + #it + 1 > 240 and #cur > 0 then send(head .. table.concat(cur, ",")); cur, len = {}, #head end
    cur[#cur + 1] = it; len = len + #it + 1
  end
  if #cur > 0 then send(head .. table.concat(cur, ",")) end
end
local sentDay = {}
local function sendDay(d)
  if sentDay[d] and now() - sentDay[d] < 120 then return end
  sentDay[d] = now()
  local hrs = {}
  for h = 0, 23 do local v = db.hours[("%s %02d"):format(d, h)]; if v then hrs[#hrs + 1] = ("%02d:%d"):format(h, v) end end
  if #hrs > 0 then send("H~" .. d .. "~" .. table.concat(hrs, ",")) end
  for zone, who in pairs(db.zones[d] or {}) do
    local items = {}
    for name, m in pairs(who) do items[#items + 1] = clean(name, 40) .. ":" .. m end
    sendList("Z~" .. d .. "~" .. clean(zone, 50) .. "~", items)
  end
  for _, k in ipairs(db.kills) do
    if dayOf(k.t) == d then
      local w = {}; for n in pairs(k.who or {}) do w[#w + 1] = clean(n, 30) end
      send("K~" .. k.t .. "~" .. clean(k.zone, 50) .. "~" .. clean(k.boss, 50) .. "~" .. table.concat(w, ","))
    end
  end
  for _, r in pairs(db.runs) do
    if r.day == d then local w = {}; for n in pairs(r.who or {}) do w[#w + 1] = clean(n, 30) end
      send("U~" .. d .. "~" .. clean(r.zone, 50) .. "~" .. table.concat(w, ",")) end
  end
  local seen = {}
  for name, m in pairs(db.members) do if m.last and dayOf(m.last) == d then seen[#seen + 1] = clean(name, 40) .. ":" .. m.last end end
  sendList("S~", seen)
end
-- Your own character: level and professions (for other scribes' tooltips), and its recipe lists.
local function myProfLine()
  local me = UnitName("player")
  local ranks = {}
  if GetNumSkillLines then
    for i = 1, GetNumSkillLines() do
      local name, header, _, rank = GetSkillLineInfo(i)
      if name and not header and (CRAFTS[name] or name == "Herbalism" or name == "Skinning" or name == "Fishing") then ranks[#ranks + 1] = clean(name, 30) .. ":" .. (rank or 0) end
    end
  end
  local mn = myMain()
  return me and ("P~" .. clean(me, 40) .. "~" .. (UnitLevel("player") or 0) .. "~" .. table.concat(ranks, ",") .. "~" .. clean(mn and mn ~= me and mn or "", 40)) or nil
end
local function sendRecipes(me, prof)
  local r = db.recipes[me] and db.recipes[me][prof]
  if not r or not r.list then return end
  local parts, cur, len = {}, {}, 0
  for _, n in ipairs(r.list) do
    n = clean(n, 80)
    if len + #n + 1 > 190 and #cur > 0 then parts[#parts + 1] = table.concat(cur, "^"); cur, len = {}, 0 end
    cur[#cur + 1] = n; len = len + #n + 1
  end
  if #cur > 0 then parts[#parts + 1] = table.concat(cur, "^") end
  for i, part in ipairs(parts) do send("R~" .. clean(me, 40) .. "~" .. clean(prof, 30) .. "~" .. r.at .. "~" .. i .. "~" .. #parts .. "~" .. part) end
  local ids = {}
  for _, n in ipairs(r.list) do local id = db.itemIds[n]; if id then ids[#ids + 1] = id .. "=" .. clean(n, 80) end end
  local cur2, len2 = {}, 0
  for _, it in ipairs(ids) do
    if len2 + #it + 1 > 235 and #cur2 > 0 then send("I~" .. table.concat(cur2, "^")); cur2, len2 = {}, 0 end
    cur2[#cur2 + 1] = it; len2 = len2 + #it + 1
  end
  if #cur2 > 0 then send("I~" .. table.concat(cur2, "^")) end
end
local function sendMine()
  local me = UnitName("player")
  local line = myProfLine(); if line then send(line) end
  for prof in pairs((me and db.recipes[me]) or {}) do sendRecipes(me, prof) end
end
-- A recipe list is only sent again when it changed.
shareRecipes = function(me, prof)
  local r = db.recipes[me] and db.recipes[me][prof]
  if not r then return end
  local sig = #r.list .. ":" .. (r.list[1] or "") .. (r.list[#r.list] or "")
  db.ui.recSent = db.ui.recSent or {}
  if db.ui.recSent[me .. "|" .. prof] == sig then return end
  db.ui.recSent[me .. "|" .. prof] = sig
  sendRecipes(me, prof)
end

local pieces = {}
local function addKill(t, zone, boss, who)
  for _, k in ipairs(db.kills) do
    if k.boss == boss and math.abs((k.t or 0) - t) < 300 then for n in pairs(who) do k.who = k.who or {}; k.who[n] = true end return end
  end
  table.insert(db.kills, { t = t, zone = zone, boss = boss, who = who })
  table.sort(db.kills, function(a, b) return a.t < b.t end)
end
ui.addonMsg = function(prefix, msg, channel, sender)
  if prefix ~= PREFIX or channel ~= "GUILD" or not db or not db.ui.share or type(msg) ~= "string" then return end
  local from = short(sender)
  if not from or from == UnitName("player") then return end
  local firstTime = not heard[from] or now() - heard[from] > 1800
  heard[from] = now()
  local f = {}
  for part in (msg .. "~"):gmatch("(.-)~") do f[#f + 1] = part end
  local kind = f[1]
  if kind == "D" then
    local theirs = {}
    for ymd, n in (f[3] or ""):gmatch("(%d+):(%d+)") do
      if #ymd == 8 then theirs[ymd:sub(1, 4) .. "-" .. ymd:sub(5, 6) .. "-" .. ymd:sub(7, 8)] = tonumber(n) end
    end
    for _, d in ipairs(syncDays()) do if daySum(d) > (theirs[d] or 0) then sendDay(d) end end
    sendDigest()
    if firstTime then sendMine() end
  elseif kind == "H" and f[2] and f[2]:match("^%d%d%d%d%-%d%d%-%d%d$") then
    for h, n in (f[3] or ""):gmatch("(%d%d):(%d+)") do
      local key, v = f[2] .. " " .. h, num(n, 0, 1000)
      if v and v > (db.hours[key] or 0) then db.hours[key] = v end
    end
  elseif kind == "Z" and f[2] and f[2]:match("^%d%d%d%d%-%d%d%-%d%d$") and f[3] and f[3] ~= "" then
    local zd = db.zones[f[2]] or {}; db.zones[f[2]] = zd
    local zone = clean(f[3], 50); zd[zone] = zd[zone] or {}
    for name, m in (f[4] or ""):gmatch("([^:,]+):([%d%.]+)") do
      local v = num(m, 0, 1440)
      if v and v > (zd[zone][name] or 0) then zd[zone][name] = v end
    end
  elseif kind == "K" then
    local t = num(f[2], 1e9, 4e9)
    if t and f[3] ~= "" and f[4] ~= "" then
      local who = {}; for n in (f[5] or ""):gmatch("[^,]+") do who[clean(n, 30)] = true end
      addKill(t, clean(f[3], 50), clean(f[4], 50), who)
    end
  elseif kind == "U" and f[2] and f[2]:match("^%d%d%d%d%-%d%d%-%d%d$") and f[3] ~= "" then
    local zone = clean(f[3], 50)
    local key = f[2] .. " " .. zone
    local r = db.runs[key] or { zone = zone, day = f[2], who = {} }
    for n in (f[4] or ""):gmatch("[^,]+") do r.who[clean(n, 30)] = true end
    db.runs[key] = r
  elseif kind == "S" then
    for name, t in (f[2] or ""):gmatch("([^:,]+):(%d+)") do
      local m, v = db.members[name], num(t, 1e9, now() + 600)
      if m and v and v > (m.last or 0) then m.last = v; m.days = m.days or {}; m.days[dayOf(v)] = true end
    end
  elseif kind == "P" and f[2] and f[2] ~= "" then
    local p = { lv = num(f[3], 1, 60), at = now(), ranks = {} }
    for name, r in (f[4] or ""):gmatch("([^:,]+):(%d+)") do p.ranks[clean(name, 30)] = num(r, 0, 300) end
    p.main = f[5] and clean(f[5], 40) or nil
    db.profs[clean(f[2], 40)] = p
  elseif kind == "I" then
    for id, n in (f[2] or ""):gmatch("(%d+)=([^%^]+)") do
      local v = num(id, 1, 9999999); if v then db.itemIds[clean(n, 80)] = v end
    end
  elseif kind == "R" then
    local who, prof, at, i, total = clean(f[2], 40), clean(f[3], 30), num(f[4], 1e9, now() + 600), num(f[5], 1, 40), num(f[6], 1, 40)
    if who == "" or prof == "" or not at or not i or not total then return end
    local cur = db.recipes[who] and db.recipes[who][prof]
    if cur and (cur.at or 0) >= at then return end
    local key = who .. "|" .. prof .. "|" .. at
    local b = pieces[key] or { n = 0, parts = {} }; pieces[key] = b
    if not b.parts[i] then b.parts[i] = f[7] or ""; b.n = b.n + 1 end
    if b.n >= total then
      local list = {}
      for j = 1, total do for n in (b.parts[j] or ""):gmatch("[^%^]+") do if #list < 800 then list[#list + 1] = n end end end
      table.sort(list)
      db.recipes[who] = db.recipes[who] or {}
      db.recipes[who][prof] = { at = at, list = list, from = from }
      pieces[key] = nil
    end
  end
  refresh()
end
ui.sharing = function()
  C_Timer.After(20, function() sendDigest(true) end)
  C_Timer.After(35, sendMine)
  C_Timer.NewTicker(900, function() sendDigest(true) end)
end
ui.heard = function()
  local list = {}
  for n, t in pairs(heard) do if now() - t < 3600 then list[#list + 1] = n end end
  table.sort(list)
  return list
end

-- What the other files (Pages.lua) may use from this one. db, refresh and the current tab change as the game runs, so
-- they're lent as functions that look them up when called.
NS.k = {
  ui = ui, win = win, W = W, PERTH = PERTH, GOLD = GOLD, DIM = DIM, INK = INK, IC_LOOT = IC_LOOT, Item = Item,
  page = page, label = label, rows = rows, setRow = setRow, text = text, tex = tex, wowButton = wowButton,
  itemText = itemText, memberName = memberName, guildie = guildie, short = short, nameIn = nameIn, fullName = fullName,
  dot = dot, now = now, panel = panel, clock = clock, altTag = altTag, first = first, check = check,
  show = function(key) return show(key) end, IC_RUN = IC_RUN, IC_DING = IC_DING, IC_JOIN = IC_JOIN, IC_LEAVE = IC_LEAVE,
  db = function() return db end, refresh = function() return refresh() end,
}
