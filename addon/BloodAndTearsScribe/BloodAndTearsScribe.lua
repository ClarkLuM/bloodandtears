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

local ADDON = ...
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
  if not db or not IsInGuild() or InCombatLockdown() then return end
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
  elseif event == "PLAYER_REGEN_ENABLED" then
    askRoster()
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
  "CHAT_MSG_SYSTEM", "TRADE_SKILL_SHOW", "TRADE_SKILL_LIST_UPDATE", "TRADE_SKILL_UPDATE", "PLAYER_REGEN_ENABLED", "PLAYER_LEVEL_UP", "PLAYER_ENTERING_WORLD", "ENCOUNTER_END", "CHAT_MSG_LOOT",
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
local function dot(cls)
  local c = cls and RAID_CLASS_COLORS and RAID_CLASS_COLORS[cls]
  local r, g, b = c and c.r or 0.9, c and c.g or 0.85, c and c.b or 0.8
  return ("|TInterface\\Buttons\\WHITE8X8:7:7:0:0:8:8:0:8:0:8:%d:%d:%d|t"):format(r * 255, g * 255, b * 255)
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
  local cut, tot, list = dayOf(now() - (days - 1) * 86400), {}, {}
  for d, zs in pairs(db.zones) do
    if d >= cut then for zone, who in pairs(zs) do for _, mins in pairs(who) do tot[zone] = (tot[zone] or 0) + mins end end end
  end
  for zone, m in pairs(tot) do list[#list + 1] = { zone, m } end
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
    r.mark = text(r, "GameFontNormalSmall"); r.mark:SetPoint("LEFT", 0, 0); r.mark:SetWidth(14)
    r.right = text(r, "GameFontDisableSmall", "RIGHT"); r.right:SetPoint("RIGHT", 0, 0)
    r.main = text(r, "GameFontHighlightSmall"); r.main:SetPoint("LEFT", 16, 0); r.main:SetPoint("RIGHT", r.right, "LEFT", -6, 0)
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
    r:SetScript("OnMouseUp", function(self)
      if not (self.item and IsModifiedClick and IsModifiedClick("CHATLINK") and ChatEdit_InsertLink) then return end
      local l = Item.link(self.item)
      if l then ChatEdit_InsertLink(l) end
    end)
    list[i] = r
  end
  return list
end
local function setRow(r, mark, main, right, pct, tip)
  r.tip = tip; r.item = nil; r.itemName = nil
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
local win = panel("BloodAndTearsScribeWindow", W, 490)
win:SetPoint("CENTER", 0, 60)
win.title:SetText("Blood and Tears")
win.sub:SetText("Guild scribe " .. ((GetAddOnMetadata or (C_AddOns and C_AddOns.GetAddOnMetadata) or function() return "" end)(ADDON, "Version") or ""))
local pages, tabs, current = {}, {}, "today"
local function page(key)
  local p = CreateFrame("Frame", nil, win); p:SetPoint("TOPLEFT", 4, -90); p:SetPoint("BOTTOMRIGHT", -4, 4); p:Hide()
  pages[key] = p; return p
end
local function label(p, s, y) local l = text(p, "GameFontNormalSmall"); l:SetPoint("TOPLEFT", 14, y); l:SetText(s); l:SetTextColor(0.651, 0.580, 0.557); return l end

-- Today
local pToday = page("today")
local onlineLabel = label(pToday, "Online now", -6)
local onlineRows = rows(pToday, 7, -26)
local todayLabel = label(pToday, "Today", -178)
local feedRows = rows(pToday, 8, -196)
local todayFoot = text(pToday, "GameFontDisableSmall"); todayFoot:SetPoint("BOTTOMLEFT", 14, 12); todayFoot:SetWidth(W - 28)
if todayFoot.SetWordWrap then todayFoot:SetWordWrap(true) end
todayFoot:SetJustifyV("BOTTOM"); todayFoot:SetHeight(30)

-- This week
local pWeek = page("week")
label(pWeek, "Busiest zones this week", -6)
local zoneRows = rows(pWeek, 5, -24)
for _, r in ipairs(zoneRows) do r:SetHeight(24) end
for i, r in ipairs(zoneRows) do r:ClearAllPoints(); r:SetPoint("TOPLEFT", 14, -24 - (i - 1) * 24) end
label(pWeek, "When the guild plays (Perth time)", -162)
local grid, CELL_W, CELL_H = {}, 13, 11
local dayNames = { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" }
for d = 0, 6 do
  local l = text(pWeek, "GameFontDisableSmall"); l:SetPoint("TOPLEFT", 14, -192 - d * (CELL_H + 2)); l:SetText(dayNames[d + 1])
  grid[d] = {}
  for h = 0, 23 do
    local c = tex(pWeek, "ARTWORK", 0.13, 0.08, 0.06, 1)
    c:SetSize(CELL_W, CELL_H); c:SetPoint("TOPLEFT", 50 + h * (CELL_W + 1), -192 - d * (CELL_H + 2))
    grid[d][h] = c
  end
end
for _, h in ipairs({ 0, 6, 12, 18 }) do
  local l = text(pWeek, "GameFontDisableSmall"); l:SetPoint("BOTTOMLEFT", grid[0][h], "TOPLEFT", 0, 2)
  l:SetText(h == 0 and "12am" or h == 12 and "12pm" or (h % 12) .. (h < 12 and "am" or "pm"))
end
local weekFoot = text(pWeek, "GameFontHighlightSmall"); weekFoot:SetPoint("TOPLEFT", 14, -292); weekFoot:SetWidth(W - 28)
local weekNote = text(pWeek, "GameFontDisableSmall"); weekNote:SetPoint("TOPLEFT", 14, -310); weekNote:SetWidth(W - 28)
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
label(pScribe, "Settings", -146)
local checks = {}
local function check(key, s, y, after)
  local c = CreateFrame("CheckButton", nil, pScribe, "UICheckButtonTemplate")
  c:SetSize(24, 24); c:SetPoint("TOPLEFT", 10, y)
  local l = text(pScribe, "GameFontHighlightSmall"); l:SetPoint("LEFT", c, "RIGHT", 2, 0); l:SetText(s)
  c:SetScript("OnClick", function(self) db.ui[key] = self:GetChecked() and true or false; if after then after() end end)
  checks[key] = c
end
local upload = text(pScribe, "GameFontDisableSmall"); upload:SetPoint("BOTTOMLEFT", 14, 12); upload:SetWidth(W - 28)
if upload.SetWordWrap then upload:SetWordWrap(true) end
upload:SetJustifyV("BOTTOM"); upload:SetHeight(44)
upload:SetText("The notes file is _forever_\\WTF\\Account\\(your account)\\SavedVariables\\BloodAndTearsScribe.lua. Type /reload to save it, then upload it on the site: Roster, Details.")

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
search:SetScript("OnTextChanged", function(self) if self.clear then self.clear:SetShown((self:GetText() or "") ~= "") end refresh() end)
search:SetScript("OnEditFocusGained", function() searchHint:Hide() end)
search:SetScript("OnEditFocusLost", function(self) if self:GetText() == "" then searchHint:Show() end end)
local recLabel = label(pRecipes, "Your professions", -38)
local CRAFTS = { Alchemy = "Alchemy", Blacksmithing = "Blacksmithing", Cooking = "Cooking", Enchanting = "Enchanting", Engineering = "Engineering",
  ["First Aid"] = "First Aid", Leatherworking = "Leatherworking", Tailoring = "Tailoring", Mining = "Smelting" }
local recRows = {}
for i = 1, 5 do
  local r = CreateFrame("Frame", nil, pRecipes); r:SetSize(W - 28, 34); r:SetPoint("TOPLEFT", 14, -58 - (i - 1) * 38)
  r.name = text(r, "GameFontHighlight"); r.name:SetPoint("TOPLEFT", 0, -2)
  r.info = text(r, "GameFontDisableSmall"); r.info:SetPoint("TOPLEFT", r.name, "BOTTOMLEFT", 0, -3); r.info:SetWidth(W - 130)
  local ok, b = pcall(CreateFrame, "Button", nil, r, "SecureActionButtonTemplate,UIPanelButtonTemplate")
  if ok and b then
    wowButton(b, 76, 22, "Read"); b:SetPoint("RIGHT", 0, 0)
    if b.RegisterForClicks then b:RegisterForClicks("AnyUp", "AnyDown") end
    b:SetAttribute("type", "spell")
    r.btn = b
  end
  r:Hide(); recRows[i] = r
end
local recEmpty = text(pRecipes, "GameFontDisableSmall"); recEmpty:SetPoint("TOPLEFT", 14, -58); recEmpty:SetWidth(W - 28)
local hitRows = {}
for i = 1, 6 do
  local r = CreateFrame("Frame", nil, pRecipes); r:SetSize(W - 28, 34); r:SetPoint("TOPLEFT", 14, -58 - (i - 1) * 38)
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
    if l then GameTooltip:SetHyperlink(l:match("|H(item:[^|]+)|h") or l)
    else GameTooltip:AddLine(self.recipe or "", 1, 1, 1); GameTooltip:AddLine("No item details yet. They show once someone who knows it has opened that profession with the scribe running.", 0.75, 0.75, 0.75, true) end
    GameTooltip:Show()
  end)
  r:SetScript("OnLeave", function() GameTooltip:Hide() end)
  r:SetScript("OnMouseUp", function()
    local l = linkOf()
    if l and IsModifiedClick and IsModifiedClick("CHATLINK") and ChatEdit_InsertLink and l:find("|H") then ChatEdit_InsertLink(l) end
  end)
  r:Hide(); hitRows[i] = r
end
local recFoot = text(pRecipes, "GameFontDisableSmall"); recFoot:SetPoint("BOTTOMLEFT", 14, 12); recFoot:SetWidth(W - 28)
if recFoot.SetWordWrap then recFoot:SetWordWrap(true) end
recFoot:SetJustifyV("BOTTOM"); recFoot:SetHeight(92)
recFoot:SetText(GOLD .. "How recipes get to the site|r\n"
  .. INK .. "1.|r Click Read: the profession's window opens and the scribe notes every recipe in it.\n"
  .. INK .. "2.|r Close the window. Do it once per profession, and again after learning new ones (this tab says when).\n"
  .. INK .. "3.|r Type /reload or log out to save, then upload the file on the site.\n"
  .. "The game only shares a recipe list while its window is open, so the scribe can't read them by itself.")
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
    for i, r in ipairs(recRows) do local p = myProfs[i]; if r.btn and p then r.btn:SetAttribute("spell", CRAFTS[p.name]) end end
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
  recLabel:SetText(#order == 0 and "Nobody the scribe knows of can make that" or (#order .. (#order == 1 and " recipe" or " recipes") .. " match" .. (#order > #hitRows and (", showing " .. #hitRows) or "")))
  for i, r in ipairs(hitRows) do
    local n = order[i]
    if n then
      local bits = {}
      for _, c in ipairs(found[n]) do
        local m, full = guildie(c.who)
        local sc = not m and siteChar(c.who)
        bits[#bits + 1] = nameIn(full or c.who, m and m.class or sc and sc.cls) .. DIM .. " (" .. c.prof .. ")|r"
      end
      table.sort(bits)
      local id = db.itemIds[n] or Item.ids[n]
      local icon = id and Item.icon(id)
      r.recipe = n
      r.name:SetText((icon and ("|T" .. icon .. ":16:16|t ") or "") .. n); r.info:SetText(table.concat(bits, ",  ")); r:Show()
    else r:Hide() end
  end
  for _, r in ipairs(recRows) do r:Hide() end
  recEmpty:SetText("")
end
local function fillRecipes()
  local me = UnitName("player") or "?"
  local q = search:GetText() or ""
  if q:gsub("%s", "") ~= "" and #q >= 2 then fillSearch(q:gsub("^%s+", ""):gsub("%s+$", "")); return end
  for _, r in ipairs(hitRows) do r:Hide() end
  recLabel:SetText("Professions for " .. fullName(me))
  readSkills()
  local mine, learned = db.recipes[me] or {}, db.ui.learned and db.ui.learned[me]
  -- Mining's window is Smelting, but the game files its recipes under Mining.
  for i, r in ipairs(recRows) do
    local p = myProfs[i]
    if p then
      local got = mine[p.name] or mine[CRAFTS[p.name]]
      r.name:SetText(p.name .. "  " .. DIM .. (p.rank or "") .. (p.max and ("/" .. p.max) or "") .. "|r")
      if not got then r.info:SetText(GOLD .. "Not read yet|r")
      elseif learned and learned > got.at then r.info:SetText(GOLD .. "You've learned something new since. Read it again.|r")
      else r.info:SetText(#got.list .. " recipes, read " .. ago(got.at)) end
      r:Show()
    else r:Hide() end
  end
  recEmpty:SetText(#myProfs == 0 and "No crafting professions on this character." or "")
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
local dgLabel = text(pDungeons, "GameFontNormalSmall"); dgLabel:SetPoint("TOPLEFT", 14, -36); dgLabel:SetWidth(W - 28)
-- Which dungeons to show: the ones for your level, or one of the site's achievement groups.
local dgBtns = {}
local BANDS = { { "mine", "Your level" }, { "Novice", "Novice" }, { "Experienced", "Experienced" }, { "Master", "Master" } }
for i, bd in ipairs(BANDS) do
  local b = CreateFrame("Button", nil, pDungeons, "UIPanelButtonTemplate")
  local bw = (W - 28 - 3 * 4) / 4
  wowButton(b, bw, 20, bd[2]); b:SetPoint("TOPLEFT", 14 + (i - 1) * (bw + 4), -8)
  b.band = bd[1]
  b:SetScript("OnClick", function() dgBand, dgScroll = bd[1], 0; refresh() end)
  dgBtns[i] = b
end
local ROWS_DG, ROW_H = 8, 34
local dgRows = {}
for i = 1, ROWS_DG do
  local r = CreateFrame("Frame", nil, pDungeons); r:SetSize(W - 28, ROW_H - 2); r:SetPoint("TOPLEFT", 14, -54 - (i - 1) * ROW_H)
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
local dgMore = text(pDungeons, "GameFontDisableSmall", "CENTER"); dgMore:SetPoint("TOP", 0, -54 - ROWS_DG * ROW_H - 2)
local dgFoot = text(pDungeons, "GameFontDisableSmall"); dgFoot:SetPoint("BOTTOMLEFT", 14, 12); dgFoot:SetWidth(W - 28)
if dgFoot.SetWordWrap then dgFoot:SetWordWrap(true) end
dgFoot:SetJustifyV("BOTTOM"); dgFoot:SetHeight(32)
dgFoot:SetText("Click a dungeon you'd done before the scribe was running to mark it. Hover one for who's online and in range.")
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
  for _, b in ipairs(dgBtns) do b:setOn(b.band == dgBand) end
  local list = {}
  if dgBand == "mine" then
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
  for _, d in ipairs(list) do if seenIn(d[1], me) or onSite[d[1]] or (db.stamps[me] and db.stamps[me][d[1]]) then done = done + 1 end end
  if dgBand == "mine" then dgLabel:SetText(GOLD .. "For " .. fullName(me) .. ", level " .. lv .. "|r" .. DIM .. "   " .. done .. " of " .. #list .. " done|r")
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
  dgMore:SetText(#list > ROWS_DG and ((dgScroll + 1) .. "–" .. math.min(#list, dgScroll + ROWS_DG) .. " of " .. #list .. " · scroll for more") or "")
end

-- Tabs along the top
local TABS = { { "today", "Today" }, { "week", "Week" }, { "dungeons", "Dungeons" }, { "recipes", "Recipes" }, { "scribe", "Scribe" } }
local function show(key)
  current = key
  for k, p in pairs(pages) do if k == key then p:Show() else p:Hide() end end
  local nr = ui.needReading and ui.needReading() or 0
  for _, t in ipairs(tabs) do
    if t.key == "recipes" then t:SetText(nr > 0 and ("Recipes (" .. nr .. ")") or "Recipes") end
    t:setOn(t.key == key)
  end
  refresh()
end
for i, t in ipairs(TABS) do
  local b = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
  local tw = (W - 28 - 4 * 4) / 5
  wowButton(b, tw, 24, t[2]); b:SetPoint("TOPLEFT", 14 + (i - 1) * (tw + 4), -56)
  b.key = t[1]
  b:SetScript("OnClick", function() show(t[1]) end)
  tabs[i] = b
end


-------------------------------------------------------------------- filling the tabs
local pip   -- the minimap count, set below
local function fillToday()
  table.sort(onlineNow, function(a, b) return (a.zone or "") < (b.zone or "") or ((a.zone or "") == (b.zone or "") and a.name < b.name) end)
  onlineLabel:SetText("Online now  ·  " .. #onlineNow)
  for i, r in ipairs(onlineRows) do
    local o = onlineNow[i]
    if i == #onlineRows and #onlineNow > #onlineRows then setRow(r, "", DIM .. "and " .. (#onlineNow - #onlineRows + 1) .. " more|r", "")
    elseif o then setRow(r, dot(o.class), nameIn(o.name, o.class) .. "  " .. DIM .. (o.level or "") .. "|r" .. altTag(o.name), o.zone or "")
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
  todayFoot:SetText((nr > 0 and (GOLD .. nr .. (nr == 1 and " profession needs" or " professions need") .. " reading for the site: see the Recipes tab.|r\n") or "")
    .. (z and ("Busiest today: " .. z[1] .. ", " .. hrs(z[2]) .. " of guild time") or ""))
end
local function fillWeek()
  local list = zoneTotals(7)
  local top = list[1] and list[1][2] or 1
  for i, r in ipairs(zoneRows) do
    local z = list[i]
    if z then setRow(r, GOLD .. i .. "|r", INK .. z[1] .. "|r", hrs(z[2]), z[2] / top) else r:Hide() end
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
  if not win:IsShown() then return end
  if current == "today" then fillToday() elseif current == "week" then fillWeek() elseif current == "dungeons" then fillDungeons() elseif current == "recipes" then fillRecipes() else fillScribe() end
  if current == "today" then db.ui.seen = now(); if pip then pip() end end
end
win:SetScript("OnShow", function() show(current) end)

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
local mainLabel = text(pScribe, "GameFontHighlightSmall"); mainLabel:SetPoint("TOPLEFT", 16, -294)
local mainBtn = wowButton(CreateFrame("Button", nil, pScribe, "UIPanelButtonTemplate"), 160, 20, "")
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

-------------------------------------------------------------------- the session summary
-- What you did since you logged in: levels, time played, zones (counted each minute), bosses, good drops, and the
-- guildies you were grouped with. Shown during the logout countdown, or any time with /scribe summary.
local sess
local function sessionTick()
  if not sess then return end
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
local keep = wowButton(CreateFrame("Button", nil, sum, "UIPanelButtonTemplate"), 120, 24, "Keep playing"); keep:SetPoint("BOTTOMRIGHT", -14, 12)
local close = wowButton(CreateFrame("Button", nil, sum, "UIPanelButtonTemplate"), 90, 24, "Close"); close:SetPoint("RIGHT", keep, "LEFT", -6, 0)
keep:SetScript("OnClick", function() if CancelLogout then pcall(CancelLogout) end sum:Hide() end)
close:SetScript("OnClick", function() sum:Hide() end)

local function fillSummary(leaving)
  if not sess then return end
  local me, t = UnitName("player"), now()
  local lv = UnitLevel("player")
  sum.title:SetText(fullName(me) .. "'s session")
  sum.sub:SetText("Level " .. (sess.level or lv) .. (lv ~= sess.level and (" to " .. lv) or "") .. "  ·  " .. clock(sess.t) .. " to " .. clock(t))
  keep:SetShown(leaving and true or false)
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

-- What each recipe makes (from the site's recipes.json): an item id, or a negative spell id for enchants.
-- Used for the recipe search tooltips and icons when nobody has shared that recipe's item yet.
Item.ids = {
 ["9-60 Battery Pack"]=274048,["Accurate Scope"]=4407,["Acolyte's Boots"]=250506,["Acolyte's Chain Belt"]=250516,["Acolyte's Chain Helm"]=250501,["Acolyte's Chain Leggings"]=250496,
 ["Acolyte's Chain Shirt"]=250491,["Acolyte's Gloves"]=250511,["Acolyte's Silvered Chain Helm"]=250531,["Acolyte's Silvered Chain Leggings"]=250526,["Acolyte's Silvered Chain Shirt"]=250521,["Admiral's Hat"]=10030,
 ["Advanced Target Dummy"]=4392,["Alchemist's Stone"]=13503,["Alchemy Laboratory"]=279990,["Anarchist's Workbench"]=279989,["Annihilator"]=12798,["Anti-Venom"]=6452,
 ["Anvil"]=279988,["Aquadynamic Fish Attractor"]=6533,["Arcane Bomb"]=16040,["Arcane Elixir"]=9155,["Arcane Forge"]=279987,["Arcane Salvager"]=279985,
 ["Arcanite Bar"]=12360,["Arcanite Blacksmith Hammer"]=285281,["Arcanite Champion"]=12790,["Arcanite Dragonling"]=16022,["Arcanite Reaper"]=12784,["Arcanite Rod"]=16206,
 ["Arcanite Skeleton Key"]=15872,["Arclight Spanner"]=6219,["Argent Boots"]=19056,["Argent Shoulders"]=19059,["Azerothium Bar"]=249726,["Azerothium Legplates"]=279265,
 ["Azure Gustwoven Belt"]=277025,["Azure Gustwoven Boots"]=277027,["Azure Gustwoven Bracers"]=277023,["Azure Gustwoven Gloves"]=277024,["Azure Gustwoven Harness"]=277022,["Azure Gustwoven Hood"]=277050,
 ["Azure Gustwoven Spaulders"]=277051,["Azure Gustwoven Trousers"]=277026,["Azure Shoulders"]=7060,["Azure Silk Belt"]=7052,["Azure Silk Cloak"]=7053,["Azure Silk Gloves"]=4319,
 ["Azure Silk Hood"]=7048,["Azure Silk Pants"]=7046,["Azure Silk Vest"]=4324,["Azure Skyforged Chain"]=277019,["Azure Skyforged Chainmail"]=277016,["Azure Skyforged Gauntlets"]=277018,
 ["Azure Skyforged Greaves"]=277021,["Azure Skyforged Helm"]=277048,["Azure Skyforged Legguards"]=277020,["Azure Skyforged Pauldrons"]=277049,["Azure Skyforged Wristguards"]=277017,["Azure Stormsewn Cord"]=277037,
 ["Azure Stormsewn Cowl"]=277054,["Azure Stormsewn Cuffs"]=277035,["Azure Stormsewn Epaulets"]=277055,["Azure Stormsewn Handwraps"]=277036,["Azure Stormsewn Leggings"]=277038,["Azure Stormsewn Shoes"]=277039,
 ["Azure Stormsewn Vest"]=277034,["Azure Windraveled Armguards"]=277029,["Azure Windraveled Cover"]=277052,["Azure Windraveled Drapes"]=277053,["Azure Windraveled Footwraps"]=277033,["Azure Windraveled Jerkin"]=277028,
 ["Azure Windraveled Mitts"]=277030,["Azure Windraveled Pants"]=277032,["Azure Windraveled Strap"]=277031,["Bagh Nakh"]=250618,["Baked Salmon"]=13935,["Barbaric Belt"]=4264,
 ["Barbaric Bracers"]=18948,["Barbaric Gloves"]=4254,["Barbaric Harness"]=5739,["Barbaric Iron Boots"]=7916,["Barbaric Iron Breastplate"]=7914,["Barbaric Iron Gloves"]=7917,
 ["Barbaric Iron Helm"]=7915,["Barbaric Iron Shoulders"]=7913,["Barbaric Leggings"]=5963,["Barbaric Linen Vest"]=2578,["Barbaric Shoulders"]=5964,["Barbecued Buzzard Wing"]=4457,
 ["Basic Campfire"]=279981,["Basic Campfire Kit"]=279981,["Bat Hachee"]=250067,["Bear Brisket"]=250074,["Bear Bruscitti"]=250070,["Beer Basted Boar Ribs"]=2888,
 ["Belt of the Archmage"]=18405,["Bent Goggles"]=280311,["Big Bag of Enchantment"]=22249,["Big Bear Steak"]=3726,["Big Black Mace"]=7945,["Big Bronze Bomb"]=4380,
 ["Big Bronze Knife"]=3848,["Big Iron Bomb"]=4394,["Big Voodoo Cloak"]=8216,["Big Voodoo Mask"]=8201,["Big Voodoo Pants"]=8202,["Big Voodoo Robe"]=8200,
 ["Bileblister Boots"]=275612,["Bileblister Claws"]=275610,["Bileblister Girdle"]=275611,["Biznicks 247x128 Accurascope"]=18283,["Black Amnesty"]=19166,["Black Cord"]=254043,
 ["Black Dragonscale Boots"]=16984,["Black Dragonscale Breastplate"]=15050,["Black Dragonscale Helm"]=252605,["Black Dragonscale Leggings"]=15052,["Black Dragonscale Shoulders"]=15051,["Black Gloves"]=254101,
 ["Black Grasp of the Destroyer"]=22194,["Black Handwraps"]=254027,["Black Mageweave Boots"]=10026,["Black Mageweave Gloves"]=10003,["Black Mageweave Headband"]=10024,["Black Mageweave Leggings"]=9999,
 ["Black Mageweave Robe"]=10001,["Black Mageweave Shoulders"]=10027,["Black Mageweave Vest"]=9998,["Black Sandals"]=254113,["Black Silk Pack"]=5765,["Black Slippers"]=254007,
 ["Black Swashbuckler's Shirt"]=4336,["Black Waistcord"]=254087,["Black Whelp Cloak"]=7283,["Black Whelp Slippers"]=252424,["Black Whelp Tunic"]=20575,["Blackfury"]=19167,
 ["Blackguard"]=19168,["Blackmouth Oil"]=6370,["Blazing Rapier"]=12777,["Bleakwood Hew"]=12769,["Blessed Plate Belt"]=250592,["Blessed Plate Boots"]=250587,
 ["Blessed Plate Bracers"]=250590,["Blessed Plate Chest"]=250594,["Blessed Plate Gauntlet"]=250588,["Blessed Plate Helm"]=250593,["Blessed Plate Leggings"]=250591,["Blessed Plate Pauldrons"]=250586,
 ["Blight"]=7959,["Blood Sausage"]=3220,["Blood Talon"]=12795,["Blood Tiger Breastplate"]=19688,["Blood Tiger Shoulders"]=19689,["Bloodsoul Breastplate"]=19690,
 ["Bloodsoul Gauntlets"]=19692,["Bloodsoul Shoulders"]=19691,["Bloodvine Boots"]=19684,["Bloodvine Goggles"]=19999,["Bloodvine Leggings"]=19683,["Bloodvine Lens"]=19998,
 ["Bloodvine Vest"]=19682,["Blue Dragonscale Breastplate"]=15048,["Blue Dragonscale Helm"]=252604,["Blue Dragonscale Leggings"]=20295,["Blue Dragonscale Shoulders"]=15049,["Blue Firework"]=9312,
 ["Blue Glittering Axe"]=7942,["Blue Linen Robe"]=6242,["Blue Linen Shirt"]=2577,["Blue Linen Vest"]=6240,["Blue Overalls"]=6263,["Blue Rocket Cluster"]=21571,
 ["Blue Suede Armor"]=252480,["Blue Suede Belt"]=252481,["Blue Suede Bracers"]=252559,["Blue Suede Gloves"]=252546,["Blue Suede Hat"]=252482,["Blue Suede Pants"]=252478,
 ["Blue Suede Shoes"]=30894,["Blue Suede Shoulders"]=252554,["Boiled Clams"]=5525,["Bold Dirk"]=250616,["Bolt of Linen Cloth"]=2996,["Bolt of Mageweave"]=4339,
 ["Bolt of Runecloth"]=14048,["Bolt of Silk Cloth"]=4305,["Bolt of Woolen Cloth"]=2997,["Boots of Conviction"]=273927,["Boots of Darkness"]=7027,["Boots of the Enchanter"]=4325,
 ["Bottomless Bag"]=14156,["Bottomless Reagent Bag"]=254139,["Bramblewood Belt"]=22761,["Bramblewood Boots"]=22760,["Bramblewood Helm"]=22759,["Brass Knuckles"]=250602,
 ["Brawler's Leather Armor"]=252490,["Brawler's Leather Belt"]=252428,["Brawler's Leather Boots"]=252439,["Brawler's Leather Gloves"]=252494,["Brawler's Leather Helm"]=252512,["Brawler's Leather Hood"]=252504,
 ["Brawler's Leather Legguards"]=252516,["Brawler's Leather Pants"]=252500,["Brawler's Leather Tunic"]=252508,["Breakfast Omelette"]=250080,["Breastplate of Salvation"]=250601,["Bright Yellow Shirt"]=4332,
 ["Bright-Eye Goggles"]=10499,["Brightcloth Cloak"]=14103,["Brightcloth Gloves"]=14101,["Brightcloth Pants"]=14104,["Brightcloth Robe"]=14100,["Brilliant Mana Oil"]=20748,
 ["Brilliant Smallfish"]=6290,["Brilliant Wand"]=249385,["Brilliant Wizard Oil"]=20749,["Briny Seafood Stew"]=274971,["Bristle Whisker Catfish"]=4593,["Bronze Axe"]=2849,
 ["Bronze Bar"]=2841,["Bronze Battle Axe"]=7958,["Bronze Dory"]=250603,["Bronze Framework"]=4382,["Bronze Greatsword"]=7957,["Bronze Mace"]=2848,
 ["Bronze Shortsword"]=2850,["Bronze Tube"]=4371,["Bronze Warhammer"]=7956,["Broodwatcher's Belt"]=275620,["Broodwatcher's Clenchers"]=275619,["Broodwatcher's Treaders"]=275621,
 ["Brown Linen Pants"]=4343,["Brown Linen Robe"]=6238,["Brown Linen Shirt"]=4344,["Brown Linen Vest"]=2568,["Calcified Smoothie"]=249874,["Camp Tent"]=279978,
 ["Carrion Surprise"]=12213,["Catseye Draught"]=10592,["Catseye Ultra Goggles"]=10501,["Caustic Smog Potion"]=250951,["Cenarion Herb Bag"]=22251,["Centaur Banner Deployment Device"]=269900,
 ["Cerulean Dye"]=249409,["Champion's Legplates"]=250598,["Charged Mithril Battleaxe"]=250612,["Charged Scorpid Belt"]=252575,["Charged Scorpid Boots"]=252602,["Charged Scorpid Bracers"]=252593,
 ["Charged Scorpid Gauntlets"]=252596,["Charged Scorpid Helm"]=252581,["Charged Scorpid Leggings"]=252600,["Charged Scorpid Shoulders"]=252583,["Charged Scorpid Vest"]=252598,["Charred Wolf Meat"]=2679,
 ["Chimeric Boots"]=15073,["Chimeric Gloves"]=15074,["Chimeric Leggings"]=15072,["Chimeric Vest"]=15075,["Chromatic Cloak"]=18509,["Chromatic Gauntlets"]=19157,
 ["Cindercloth Boots"]=10044,["Cindercloth Cloak"]=14044,["Cindercloth Gloves"]=14043,["Cindercloth Pants"]=14045,["Cindercloth Robe"]=10042,["Cindercloth Vest"]=14042,
 ["Clam Chowder"]=5526,["Clam Linguine"]=250081,["Clanking Cord"]=280308,["Cleric's Elixir"]=250332,["Clever Poultice"]=255717,["Cloak of Earth and Sky"]=279270,
 ["Cloak of Fire"]=14134,["Cloak of Warding"]=18413,["Cloudy Gustwoven Belt"]=277001,["Cloudy Gustwoven Boots"]=277003,["Cloudy Gustwoven Bracers"]=276999,["Cloudy Gustwoven Gloves"]=277000,
 ["Cloudy Gustwoven Harness"]=276998,["Cloudy Gustwoven Hood"]=277042,["Cloudy Gustwoven Spaulders"]=277043,["Cloudy Gustwoven Trousers"]=277002,["Cloudy Skyforged Chain"]=276995,["Cloudy Skyforged Chainmail"]=276992,
 ["Cloudy Skyforged Gauntlets"]=276994,["Cloudy Skyforged Greaves"]=276997,["Cloudy Skyforged Helm"]=277040,["Cloudy Skyforged Legguards"]=276996,["Cloudy Skyforged Pauldrons"]=277041,["Cloudy Skyforged Wristguards"]=276993,
 ["Cloudy Stormsewn Cord"]=277013,["Cloudy Stormsewn Cowl"]=277046,["Cloudy Stormsewn Cuffs"]=277011,["Cloudy Stormsewn Epaulets"]=277047,["Cloudy Stormsewn Handwraps"]=277012,["Cloudy Stormsewn Leggings"]=277014,
 ["Cloudy Stormsewn Shoes"]=277015,["Cloudy Stormsewn Vest"]=277010,["Cloudy Windraveled Armguards"]=277005,["Cloudy Windraveled Cover"]=277044,["Cloudy Windraveled Drapes"]=277045,["Cloudy Windraveled Footwraps"]=277009,
 ["Cloudy Windraveled Jerkin"]=277004,["Cloudy Windraveled Mitts"]=277006,["Cloudy Windraveled Pants"]=277008,["Cloudy Windraveled Strap"]=277007,["Cluster Launcher"]=21570,["Clutchlord's Grips"]=275625,
 ["Clutchlord's Stompers"]=275627,["Clutchlord's Support"]=275626,["Coarse Blasting Powder"]=4364,["Coarse Dynamite"]=4365,["Coarse Grinding Stone"]=3478,["Coarse Sharpening Stone"]=2863,
 ["Coarse Weightstone"]=3240,["Colorful Kilt"]=10048,["Comfortable Leather Hat"]=8174,["Compact Critter Carrier"]=260807,["Compact Harvest Reaper Kit"]=4391,["Cooked Crab Claw"]=2682,
 ["Cooked Glossy Mightfish"]=13927,["Cookie's Feast"]=279957,["Copper Axe"]=2845,["Copper Bar"]=2840,["Copper Battle Axe"]=3488,["Copper Bracers"]=2853,
 ["Copper Chain Belt"]=2851,["Copper Chain Boots"]=3469,["Copper Chain Pants"]=2852,["Copper Chain Vest"]=3471,["Copper Claymore"]=7955,["Copper Dagger"]=7166,
 ["Copper Mace"]=2844,["Copper Modulator"]=4363,["Copper Rod"]=6217,["Copper Shortsword"]=2847,["Copper Tube"]=4361,["Core Armor Kit"]=18251,
 ["Core Felcloth Bag"]=21342,["Core Marksman Rifle"]=18282,["Corehound Belt"]=19162,["Corehound Boots"]=16982,["Corruption"]=12782,["Coyote Steak"]=2684,
 ["Crab Cake"]=2683,["Cracked Blacksmith Hammer"]=285279,["Crafted Heavy Shot"]=8068,["Crafted Light Shot"]=8067,["Crafted Solid Shot"]=8069,["Craftsman's Monocle"]=4393,
 ["Crimson Dawnwoven Bag"]=239148,["Crimson Silk Belt"]=7055,["Crimson Silk Cloak"]=7056,["Crimson Silk Gloves"]=7064,["Crimson Silk Pantaloons"]=7062,["Crimson Silk Robe"]=7063,
 ["Crimson Silk Shoulders"]=7059,["Crimson Silk Vest"]=7058,["Crispy Bat Wing"]=12224,["Crispy Lizard Tail"]=5479,["Crocolisk Gumbo"]=3664,["Crocolisk Steak"]=3662,
 ["Crude Scope"]=4405,["Crusader's Boots"]=10192,["Crusader's Chain Belt"]=250517,["Crusader's Chain Helm"]=250502,["Crusader's Chain Leggings"]=250497,["Crusader's Chain Shirt"]=250492,
 ["Crusader's Gloves"]=250512,["Crusader's Knapsack"]=239147,["Crusader's Silvered Chain Helm"]=250532,["Crusader's Silvered Chain Leggings"]=250527,["Crusader's Silvered Chain Shirt"]=250522,["Crystal Infused Bandage"]=23684,
 ["Cured Heavy Hide"]=4236,["Cured Light Hide"]=4231,["Cured Medium Hide"]=4233,["Cured Rugged Hide"]=15407,["Cured Thick Hide"]=8172,["Curiously Tasty Omelet"]=3665,
 ["Dark Iron Bar"]=11371,["Dark Iron Bomb"]=16005,["Dark Iron Boots"]=20039,["Dark Iron Bracers"]=17014,["Dark Iron Destroyer"]=17016,["Dark Iron Gauntlets"]=19164,
 ["Dark Iron Helm"]=19148,["Dark Iron Leggings"]=17013,["Dark Iron Mail"]=11606,["Dark Iron Plate"]=11604,["Dark Iron Pulverizer"]=11608,["Dark Iron Reaver"]=17015,
 ["Dark Iron Rifle"]=16004,["Dark Iron Shoulders"]=11605,["Dark Iron Sunderer"]=11607,["Dark Leather Belt"]=4249,["Dark Leather Boots"]=2315,["Dark Leather Cloak"]=2316,
 ["Dark Leather Gloves"]=4248,["Dark Leather Pants"]=5961,["Dark Leather Shoulders"]=4252,["Dark Leather Tunic"]=2317,["Dark Silk Shirt"]=4333,["Darkrune Breastplate"]=20550,
 ["Darkrune Gauntlets"]=20549,["Darkrune Helm"]=20551,["Darksoul Breastplate"]=19693,["Darksoul Leggings"]=19694,["Darksoul Shoulders"]=19695,["Darkspear"]=12802,
 ["Dawn Armor"]=252483,["Dawn Treaders"]=19052,["Dawn's Edge"]=12774,["Dawnbringer Shoulders"]=12625,["Dazzling Mithril Rapier"]=7944,["Deadly Blunderbuss"]=4369,
 ["Deadly Bronze Poniard"]=3490,["Deadly Scope"]=10546,["Deepdive Helmet"]=10506,["Defender's Leather Armor"]=252434,["Defender's Leather Belt"]=252430,["Defender's Leather Boots"]=252441,
 ["Defender's Leather Gloves"]=252496,["Defender's Leather Helm"]=252455,["Defender's Leather Hood"]=252447,["Defender's Leather Kilt"]=252457,["Defender's Leather Pants"]=252445,["Defender's Leather Tunic"]=252450,
 ["Delicate Arcanite Converter"]=16006,["Demon Forged Breastplate"]=12628,["Demonheart Boots"]=273943,["Demonheart Gloves"]=273941,["Demonheart Leggings"]=273940,["Demonheart Spaulders"]=273942,
 ["Dense Blasting Powder"]=15992,["Dense Dynamite"]=18641,["Dense Grinding Stone"]=12644,["Dense Sharpening Stone"]=12404,["Dense Weightstone"]=12643,["Dented Goggles"]=280313,
 ["Depleted Thorium Sabatons"]=279263,["Deviate Scale Belt"]=6468,["Deviate Scale Cloak"]=6466,["Deviate Scale Gloves"]=6467,["Devilsaur Gauntlets"]=15063,["Devilsaur Leggings"]=15062,
 ["Dig Rat Stew"]=5478,["Dimensional Ripper - Everlook"]=18984,["Dimensional Transporter - Mt. Hyjal"]=260823,["Dirge's Kickin' Chimaerok Chops"]=21023,["Discolored Healing Potion"]=4596,["Discombobulator Ray"]=4388,
 ["Distilled Firewater"]=246948,["Dormant Heart of the Mountain"]=249473,["Double-Stitched Woolen Shoulders"]=4314,["Dragonbreath Chili"]=12217,["Dragonfire Potion"]=250953,["Dragonscale Breastplate"]=8367,
 ["Dragonscale Gauntlets"]=8347,["Draught of Detect Demon"]=9233,["Draught of Detect Lesser Invisibility"]=3828,["Draught of Detect Undead"]=9154,["Draught of Dream Vision"]=9197,["Draught of Greater Water Breathing"]=18294,
 ["Draught of Water Breathing"]=5996,["Draught of Water Walking"]=8827,["Dreambough Wand"]=249234,["Dreamless Sleep Potion"]=12190,["Dreamscale Breastplate"]=20380,["Dreamstaff"]=249454,
 ["Dreamweave Circlet"]=10041,["Dreamweave Gloves"]=10019,["Dreamweave Vest"]=10021,["Dry Pork Ribs"]=2687,["Dusky Belt"]=7387,["Dusky Boots"]=7390,
 ["Dusky Bracers"]=7378,["Dusky Leather Armor"]=7374,["Dusky Leather Leggings"]=7373,["EZ and SAF Field Transporter: Mt. Hyjal"]=260821,["EZ-Thro Bronze Mortar"]=260802,["EZ-Thro Copper Bomb XL"]=260795,
 ["EZ-Thro Dark Bomb"]=260817,["EZ-Thro Dynamite"]=6714,["EZ-Thro Dynamite II"]=18588,["EZ-Thro Field Transporter: Gadgetzan"]=260819,["EZ-Thro Fireproof Fuse"]=260801,["EZ-Thro Grenade"]=260803,
 ["EZ-Thro Magnetic Displacer"]=260829,["EZ-Thro Mana Bomb"]=260818,["EZ-Thro Radiation Bomb"]=215168,["EZ-Thro Shell"]=260815,["EZ-Thro Thorium Grenade"]=260816,["EZ-Thro Tru-Trigger"]=260808,
 ["EZ-Thro Wrap"]=260794,["Earthen Leather Shoulders"]=7352,["Earthen Leggings"]=253999,["Earthen Silk Belt"]=7061,["Earthen Silk Cuffs"]=254019,["Earthen Silk Gloves"]=254017,
 ["Earthen Silk Hood"]=254015,["Earthen Silk Shoulders"]=254033,["Earthen Silk Slippers"]=254013,["Earthen Vest"]=7051,["Earthenweave Boots"]=254093,["Earthenweave Cord"]=254077,
 ["Earthenweave Crown"]=254137,["Earthenweave Cuffs"]=254131,["Earthenweave Gloves"]=254075,["Earthenweave Leggings"]=254125,["Earthenweave Mantle"]=254119,["Earthenweave Vest"]=254121,
 ["Ebon Hand"]=19170,["Ebon Shiv"]=7947,["Edge of Winter"]=17704,["Egg Nog"]=17198,["Elderwild Pants"]=279254,["Elderwild Waistcord"]=279252,
 ["Elemental Fire"]=7068,["Elemental Sharpening Stone"]=18262,["Elementium Bar"]=17771,["Elixir of Agility"]=8949,["Elixir of Brute Force"]=13453,["Elixir of Cunning"]=250328,
 ["Elixir of Defense"]=3389,["Elixir of Ferocity"]=250350,["Elixir of Fire Power"]=6373,["Elixir of Fortitude"]=3825,["Elixir of Frost Power"]=17708,["Elixir of Giant Growth"]=6662,
 ["Elixir of Greater Agility"]=9187,["Elixir of Greater Defense"]=8951,["Elixir of Greater Fortitude"]=250335,["Elixir of Greater Intellect"]=9179,["Elixir of Greater Spirit"]=250347,["Elixir of Greater Strength"]=9206,
 ["Elixir of Holy Power"]=21546,["Elixir of Intellect"]=250354,["Elixir of Lesser Agility"]=3390,["Elixir of Lesser Defense"]=3389,["Elixir of Lesser Fortitude"]=3825,["Elixir of Lesser Intellect"]=250353,
 ["Elixir of Lesser Spirit"]=250345,["Elixir of Minor Agility"]=2457,["Elixir of Minor Defense"]=5997,["Elixir of Minor Force"]=247755,["Elixir of Minor Fortitude"]=2458,["Elixir of Minor Spirit"]=250344,
 ["Elixir of Minor Strength"]=2454,["Elixir of Nature Power"]=250343,["Elixir of Ogre Strength"]=3391,["Elixir of Sages"]=250338,["Elixir of Shadow Power"]=9264,["Elixir of Spirit"]=40072,
 ["Elixir of Strength"]=250349,["Elixir of Wicked Regeneration"]=250336,["Elixir of Wisdom"]=3383,["Elixir of the Grizzly"]=250351,["Elixir of the Mongoose"]=13452,["Elixir of the Owl"]=250337,
 ["Elixir of the Phalanx"]=250329,["Elixir of the Sages"]=13447,["Elixir of the Whale"]=250348,["Embossed Leather Boots"]=2309,["Embossed Leather Cloak"]=2310,["Embossed Leather Gloves"]=4239,
 ["Embossed Leather Pants"]=4242,["Embossed Leather Vest"]=2300,["Emergency Field Cloak"]=260806,["Enchant 2H Weapon - Agility"]=-27837,["Enchant 2H Weapon - Greater Impact"]=-13937,["Enchant 2H Weapon - Impact"]=-13695,
 ["Enchant 2H Weapon - Lesser Agility"]=-1248510,["Enchant 2H Weapon - Lesser Impact"]=-13529,["Enchant 2H Weapon - Lesser Intellect"]=-7793,["Enchant 2H Weapon - Lesser Spirit"]=-13380,["Enchant 2H Weapon - Lesser Strength"]=-1248511,["Enchant 2H Weapon - Major Intellect"]=-20036,
 ["Enchant 2H Weapon - Major Spirit"]=-20035,["Enchant 2H Weapon - Mighty Healing Power"]=-1248636,["Enchant 2H Weapon - Mighty Spell Power"]=-1248607,["Enchant 2H Weapon - Minor Impact"]=-7745,["Enchant 2H Weapon - Spellblasting"]=-1219580,["Enchant 2H Weapon - Strength"]=-1248668,
 ["Enchant 2H Weapon - Superior Impact"]=-20030,["Enchant Boots - Agility"]=-13935,["Enchant Boots - Greater Agility"]=-20023,["Enchant Boots - Greater Stamina"]=-20020,["Enchant Boots - Lesser Agility"]=-13637,["Enchant Boots - Lesser Spirit"]=-13687,
 ["Enchant Boots - Lesser Stamina"]=-13644,["Enchant Boots - Minor Agility"]=-7867,["Enchant Boots - Minor Speed"]=-13890,["Enchant Boots - Minor Stamina"]=-7863,["Enchant Boots - Speed"]=-1328948,["Enchant Boots - Spirit"]=-20024,
 ["Enchant Boots - Stamina"]=-13836,["Enchant Bracer - Agility"]=-1248497,["Enchant Bracer - Deflection"]=-13931,["Enchant Bracer - Greater Agility"]=-1248500,["Enchant Bracer - Greater Intellect"]=-20008,["Enchant Bracer - Greater Spellpower"]=-1220624,
 ["Enchant Bracer - Greater Spirit"]=-13846,["Enchant Bracer - Greater Stamina"]=-13945,["Enchant Bracer - Greater Strength"]=-13939,["Enchant Bracer - Healing Power"]=-23802,["Enchant Bracer - Inferior Stamina"]=-7418,["Enchant Bracer - Intellect"]=-13822,
 ["Enchant Bracer - Lesser Agility"]=-1248460,["Enchant Bracer - Lesser Deflection"]=-13646,["Enchant Bracer - Lesser Healing Power"]=-1248498,["Enchant Bracer - Lesser Intellect"]=-13622,["Enchant Bracer - Lesser Spirit"]=-7859,["Enchant Bracer - Lesser Stamina"]=-13501,
 ["Enchant Bracer - Lesser Strength"]=-13536,["Enchant Bracer - Mana Regeneration"]=-23801,["Enchant Bracer - Minor Agility"]=-7779,["Enchant Bracer - Minor Deflect"]=-7428,["Enchant Bracer - Minor Healing Power"]=-1248459,["Enchant Bracer - Minor Intellect"]=-1248458,
 ["Enchant Bracer - Minor Spirit"]=-7766,["Enchant Bracer - Minor Stamina"]=-7457,["Enchant Bracer - Minor Strength"]=-7782,["Enchant Bracer - Spell Power"]=-1217189,["Enchant Bracer - Spirit"]=-13642,["Enchant Bracer - Stamina"]=-13648,
 ["Enchant Bracer - Strength"]=-13661,["Enchant Bracer - Superior Agility"]=-1248599,["Enchant Bracer - Superior Deflection"]=-1248665,["Enchant Bracer - Superior Intellect"]=-1248661,["Enchant Bracer - Superior Spirit"]=-20009,["Enchant Bracer - Superior Stamina"]=-20011,
 ["Enchant Bracer - Superior Strength"]=-20010,["Enchant Chest - Absorption"]=-1249071,["Enchant Chest - Greater Intellect"]=-13663,["Enchant Chest - Greater Stamina"]=-13640,["Enchant Chest - Greater Stats"]=-20025,["Enchant Chest - Inferior Stamina"]=-7420,
 ["Enchant Chest - Intellect"]=-13607,["Enchant Chest - Lesser Absorption"]=-13538,["Enchant Chest - Lesser Intellect"]=-7776,["Enchant Chest - Lesser Stamina"]=-7748,["Enchant Chest - Lesser Stats"]=-13700,["Enchant Chest - Major Intellect"]=-20028,
 ["Enchant Chest - Major Stamina"]=-20026,["Enchant Chest - Minor Absorption"]=-7426,["Enchant Chest - Minor Intellect"]=-7443,["Enchant Chest - Minor Stats"]=-13626,["Enchant Chest - Stamina"]=-7857,["Enchant Chest - Stats"]=-13941,
 ["Enchant Chest - Superior Intellect"]=-13917,["Enchant Chest - Superior Stamina"]=-13858,["Enchant Cloak - Agility"]=-1219587,["Enchant Cloak - Defense"]=-13635,["Enchant Cloak - Dodge"]=-25086,["Enchant Cloak - Fire Resistance"]=-13657,
 ["Enchant Cloak - Greater Defense"]=-13746,["Enchant Cloak - Greater Fire Resistance"]=-25081,["Enchant Cloak - Greater Nature Resistance"]=-25082,["Enchant Cloak - Greater Resistance"]=-20014,["Enchant Cloak - Lesser Agility"]=-13882,["Enchant Cloak - Lesser Fire Resistance"]=-7861,
 ["Enchant Cloak - Lesser Protection"]=-13421,["Enchant Cloak - Lesser Shadow Resistance"]=-13522,["Enchant Cloak - Minor Agility"]=-13419,["Enchant Cloak - Minor Protection"]=-7771,["Enchant Cloak - Minor Resistance"]=-7454,["Enchant Cloak - Resistance"]=-13794,
 ["Enchant Cloak - Stealth"]=-25083,["Enchant Cloak - Subtlety"]=-25084,["Enchant Cloak - Superior Defense"]=-20015,["Enchant Gloves - Advanced Herbalism"]=-13868,["Enchant Gloves - Advanced Mining"]=-13841,["Enchant Gloves - Advanced Skinning"]=-1248528,
 ["Enchant Gloves - Agility"]=-13815,["Enchant Gloves - Arcane Power"]=-1213626,["Enchant Gloves - Fire Power"]=-25078,["Enchant Gloves - Fishing"]=-13620,["Enchant Gloves - Frost Power"]=-25074,["Enchant Gloves - Greater Agility"]=-20012,
 ["Enchant Gloves - Greater Strength"]=-20013,["Enchant Gloves - Healing Power"]=-25079,["Enchant Gloves - Herbalism"]=-13617,["Enchant Gloves - Holy Power"]=-1213622,["Enchant Gloves - Lotus Claw"]=-1294054,["Enchant Gloves - Mining"]=-13612,
 ["Enchant Gloves - Minor Haste"]=-13948,["Enchant Gloves - Natural Power"]=-1248645,["Enchant Gloves - Riding Skill"]=-13947,["Enchant Gloves - Shadow Power"]=-25073,["Enchant Gloves - Skinning"]=-13698,["Enchant Gloves - Strength"]=-13887,
 ["Enchant Gloves - Superior Agility"]=-25080,["Enchant Gloves - Superior Strength"]=-1248640,["Enchant Gloves - Threat"]=-25072,["Enchant Necklace - Agility"]=-1249059,["Enchant Necklace - Deflection"]=-1249060,["Enchant Necklace - Healing Power"]=-1249058,
 ["Enchant Necklace - Spell Power"]=-1249057,["Enchant Necklace - Strength"]=-1249019,["Enchant Off-Hand - Excellent Spirit"]=-1219578,["Enchant Off-Hand - Superior Intellect"]=-1219577,["Enchant Off-Hand - Wisdom"]=-1219579,["Enchant Shield - Critical Strike"]=-1220623,
 ["Enchant Shield - Excellent Stamina"]=-1219581,["Enchant Shield - Frost Resistance"]=-13933,["Enchant Shield - Greater Spirit"]=-13905,["Enchant Shield - Greater Stamina"]=-20017,["Enchant Shield - Lesser Block"]=-13689,["Enchant Shield - Lesser Protection"]=-13464,
 ["Enchant Shield - Lesser Spirit"]=-13485,["Enchant Shield - Lesser Stamina"]=-13631,["Enchant Shield - Minor Stamina"]=-13378,["Enchant Shield - Spirit"]=-13659,["Enchant Shield - Stamina"]=-13817,["Enchant Shield - Superior Spirit"]=-20016,
 ["Enchant Weapon - Agility"]=-23800,["Enchant Weapon - Crusader"]=-20034,["Enchant Weapon - Demonslaying"]=-13915,["Enchant Weapon - Fiery Weapon"]=-13898,["Enchant Weapon - Grand Sorcerer"]=-1231164,["Enchant Weapon - Greater Striking"]=-13943,
 ["Enchant Weapon - Healing Power"]=-22750,["Enchant Weapon - Icy Chill"]=-20029,["Enchant Weapon - Insight"]=-1248757,["Enchant Weapon - Lesser Beastslayer"]=-13653,["Enchant Weapon - Lesser Elemental Slayer"]=-13655,["Enchant Weapon - Lesser Striking"]=-13503,
 ["Enchant Weapon - Lifestealing"]=-20032,["Enchant Weapon - Mighty Intellect"]=-23804,["Enchant Weapon - Mighty Spirit"]=-23803,["Enchant Weapon - Minor Beastslayer"]=-7786,["Enchant Weapon - Minor Striking"]=-7788,["Enchant Weapon - Recovery"]=-1248760,
 ["Enchant Weapon - Revelation"]=-1248805,["Enchant Weapon - Spell Power"]=-22749,["Enchant Weapon - Strength"]=-23799,["Enchant Weapon - Striking"]=-13693,["Enchant Weapon - Superior Striking"]=-20031,["Enchant Weapon - Unholy Weapon"]=-20033,
 ["Enchant Weapon - Winter's Might"]=-21931,["Enchanted Battlehammer"]=12776,["Enchanted Leather"]=12810,["Enchanted Lute"]=279976,["Enchanted Mageweave Pouch"]=22246,["Enchanted Runecloth Bag"]=22248,
 ["Enchanted Thorium Bar"]=12655,["Enchanted Thorium Breastplate"]=12618,["Enchanted Thorium Helm"]=12620,["Enchanted Thorium Leggings"]=12619,["Enchanter's Cowl"]=4322,["Enriched Thorium Breastplate"]=250595,
 ["Enriched Thorium Helm"]=250597,["Enriched Thorium Leggings"]=250596,["Essence of Air"]=7082,["Essence of Earth"]=7076,["Essence of Fire"]=7078,["Essence of Undeath"]=12808,
 ["Essence of Water"]=7080,["Eternity Pauldrons"]=279255,["Evergreen Shield"]=279262,["Expert Campfire Kit"]=279974,["Explosive Arrow"]=10579,["Explosive Sheep"]=4384,
 ["Faction Banner"]=279972,["Feathered Breastplate"]=8349,["Fel Cape"]=279269,["Felblood Soul Bag"]=279271,["Felcloth Bag"]=21341,["Felcloth Boots"]=14108,
 ["Felcloth Gloves"]=18407,["Felcloth Hood"]=14111,["Felcloth Pants"]=14107,["Felcloth Robe"]=14106,["Felcloth Shoulders"]=14112,["Fermenter"]=279970,
 ["Festival Dress"]=21154,["Festival Suit"]=21542,["Field Repair Bot 74A"]=18232,["Fiery Chain Girdle"]=16989,["Fiery Chain Shoulders"]=16988,["Fiery Cord"]=254041,
 ["Fiery Gloves"]=254099,["Fiery Handwraps"]=254025,["Fiery Plate Gauntlets"]=12631,["Fiery Sandals"]=254111,["Fiery Slippers"]=254005,["Fiery Waistcord"]=254085,
 ["Filet o' Flank"]=238638,["Filet of Redgill"]=13930,["Filigreed Flame Circlet"]=253979,["Filigreed Flame Gown"]=253905,["Filigreed Flame Leggings"]=253941,["Filigreed Pearly Circlet"]=253983,
 ["Filigreed Pearly Gown"]=253909,["Filigreed Pearly Leggings"]=253945,["Filigreed Pristine Circlet"]=253975,["Filigreed Pristine Gown"]=253901,["Filigreed Pristine Leggings"]=253937,["Filigreed Shadow Circlet"]=253981,
 ["Filigreed Shadow Gown"]=253907,["Filigreed Shadow Leggings"]=253943,["Filigreed Shining Circlet"]=253985,["Filigreed Shining Gown"]=253911,["Filigreed Shining Leggings"]=253947,["Filigreed Silky Circlet"]=253977,
 ["Filigreed Silky Gown"]=253903,["Filigreed Silky Leggings"]=253939,["Fillet of Frenzy"]=5476,["Fine Leather Belt"]=4246,["Fine Leather Boots"]=2307,["Fine Leather Cloak"]=2308,
 ["Fine Leather Gloves"]=2312,["Fine Leather Pants"]=5958,["Fine Leather Tunic"]=4243,["Fire Goggles"]=10500,["Fire Oil"]=6371,["Fire Protection Potion"]=6049,
 ["Firework Launcher"]=21569,["First Aid Kit"]=279968,["Flame Boots"]=253893,["Flame Circlet"]=253953,["Flame Deflector"]=4376,["Flame Gloves"]=253917,
 ["Flame Gown"]=253965,["Flame Leggings"]=253991,["Flame Sash"]=253929,["Flank au Poivre"]=250069,["Flarecore Gloves"]=16979,["Flarecore Leggings"]=19165,
 ["Flarecore Mantle"]=16980,["Flarecore Robe"]=19156,["Flarecore Wraps"]=18263,["Flash Bomb"]=4852,["Flask of Chromatic Resistance"]=13513,["Flask of Distilled Wisdom"]=13511,
 ["Flask of Natural Accuracy"]=274273,["Flask of Natural Aggression"]=274274,["Flask of Natural Precision"]=274275,["Flask of Natural Swiftness"]=274276,["Flask of Petrification"]=13506,["Flask of Supreme Power"]=13512,
 ["Flask of the Titans"]=13510,["Flawless Arcanite Rifle"]=16007,["Fletcher's Gloves"]=7348,["Floppy Goggles"]=280310,["Flying Tiger Goggles"]=4368,["Force Reactive Disk"]=18168,
 ["Forceful Heavy Armor Kit"]=252453,["Forceful Medium Armor Kit"]=252437,["Forceful Rugged Armor Kit"]=252488,["Forceful Thick Armor Kit"]=252463,["Forest Defender's Axe"]=279260,["Formal White Shirt"]=4334,
 ["Free Action Potion"]=5634,["Frenzy Potion"]=250940,["Frost Leather Cloak"]=7377,["Frost Oil"]=3829,["Frost Protection Potion"]=6050,["Frost Tiger Blade"]=3854,
 ["Frostguard"]=12797,["Frostsaber Boots"]=15071,["Frostsaber Gloves"]=15070,["Frostsaber Leggings"]=15069,["Frostsaber Tunic"]=15068,["Frostweave Gloves"]=13870,
 ["Frostweave Pants"]=13871,["Frostweave Robe"]=13868,["Frostweave Tunic"]=13869,["Frothing Cord"]=254039,["Frothing Gloves"]=254097,["Frothing Handwraps"]=254023,
 ["Frothing Sandals"]=254109,["Frothing Slippers"]=254003,["Frothing Waistcord"]=254083,["Frozen Heart of the Mountain"]=249469,["Gaea's Embrace"]=22660,["Gauntlets of Glory"]=273945,
 ["Gauntlets of the Sea"]=8346,["Gem-studded Leather Belt"]=4262,["Gemmed Copper Boots"]=250620,["Gemmed Copper Gauntlets"]=3474,["Ghost Dye"]=9210,["Ghostweave Belt"]=14143,
 ["Ghostweave Boots"]=254129,["Ghostweave Cord"]=254073,["Ghostweave Gloves"]=14142,["Ghostweave Hood"]=254135,["Ghostweave Mantle"]=254127,["Ghostweave Pants"]=14144,
 ["Ghostweave Vest"]=14141,["Giant Clam Scorcho"]=6038,["Giant Scrambled Eggs"]=250078,["Gift of Arthas"]=9088,["Gilded Cord"]=254037,["Gilded Gloves"]=254095,
 ["Gilded Handwraps"]=254021,["Gilded Sandals"]=254107,["Gilded Slippers"]=254001,["Gilded Waistcord"]=254081,["Gingerbread Cookie"]=17197,["Girdle of Insight"]=18504,
 ["Girdle of the Dawn"]=19051,["Gizmo Girdle"]=280307,["Glacial Cloak"]=22658,["Glacial Gloves"]=22654,["Glacial Vest"]=22652,["Glacial Wrists"]=22655,
 ["Glimmering Staff"]=249392,["Glinting Steel Dagger"]=12259,["Gloves of Conviction"]=273921,["Gloves of Meditation"]=4318,["Gloves of Spell Mastery"]=14146,["Gloves of the Dawn"]=19057,
 ["Gloves of the Greatfather"]=17721,["Glowing Copper Boots"]=250482,["Gnomish Alarm-O-Bot"]=18645,["Gnomish Army Knife"]=40772,["Gnomish Battle Chicken"]=10725,["Gnomish Cloaking Device"]=4397,
 ["Gnomish Death Ray"]=10645,["Gnomish Goggles"]=10545,["Gnomish Ham Radio"]=10723,["Gnomish Harm Prevention Belt"]=10721,["Gnomish Mind Control Cap"]=10726,["Gnomish Net-o-Matic Projector"]=10720,
 ["Gnomish Poultryizer"]=23835,["Gnomish Rocket Boots"]=10724,["Gnomish Shrink Ray"]=10716,["Gnomish Universal Remote"]=7506,["Gnomish Weather Machine"]=260826,["Goblin \"Boom\" Box"]=10580,
 ["Goblin Bomb Dispenser"]=10587,["Goblin Construction Helmet"]=10543,["Goblin Deviled Clams"]=5527,["Goblin Dragon Gun"]=10727,["Goblin Jumper Cables"]=7148,["Goblin Jumper Cables XL"]=18587,
 ["Goblin Land Mine"]=4395,["Goblin Mining Helmet"]=10542,["Goblin Mortar"]=10577,["Goblin Radio"]=10585,["Goblin Rocket Boots"]=7189,["Goblin Rocket Fuel"]=9061,
 ["Goblin Rocket Helmet"]=10588,["Goblin Sapper Charge"]=10646,["Gold Bar"]=3577,["Gold Power Core"]=10558,["Golden Cord"]=254045,["Golden Gloves"]=254103,
 ["Golden Handwraps"]=254029,["Golden Iron Destroyer"]=3852,["Golden Mantle of the Dawn"]=19058,["Golden Rod"]=11128,["Golden Sandals"]=254115,["Golden Scale Boots"]=3847,
 ["Golden Scale Bracers"]=6040,["Golden Scale Coif"]=3837,["Golden Scale Cuirass"]=3845,["Golden Scale Gauntlets"]=9366,["Golden Scale Leggings"]=3843,["Golden Scale Shoulders"]=3841,
 ["Golden Skeleton Key"]=15870,["Golden Slippers"]=254009,["Golden Waistcord"]=254089,["Goldthorn Tea"]=10841,["Gooey Spider Cake"]=3666,["Gordok Ogre Suit"]=18258,
 ["Goregasher Grips"]=275622,["Goregasher Stompers"]=275624,["Goregasher Support"]=275623,["Goretusk Liver Pie"]=724,["Grand Lobster Banquet"]=238642,["Gray Leather Boots"]=2315,
 ["Gray Woolen Robe"]=2585,["Gray Woolen Shirt"]=2587,["Great Rage Potion"]=5633,["Greater Adept's Robe"]=6264,["Greater Arcane Elixir"]=13454,["Greater Arcane Protection Potion"]=13461,
 ["Greater Cleric's Elixir"]=250333,["Greater Discolored Healing Potion"]=247241,["Greater Dreamless Sleep Potion"]=20002,["Greater Eternal Wand"]=249237,["Greater Fire Protection Potion"]=13457,["Greater Frenzy Potion"]=250941,
 ["Greater Frost Protection Potion"]=13456,["Greater Healing Potion"]=1710,["Greater Holy Protection Potion"]=13460,["Greater Mageblood Elixir"]=250341,["Greater Magic Wand"]=11288,["Greater Mana Potion"]=6149,
 ["Greater Mender's Potion"]=250947,["Greater Mystic Wand"]=11290,["Greater Nature Protection Potion"]=13458,["Greater Shadow Protection Potion"]=13459,["Greater Spellblasting Potion"]=250935,["Greater Stoneshield Potion"]=13455,
 ["Greaves of Glory"]=273947,["Green Dragonscale Breastplate"]=15045,["Green Dragonscale Gauntlets"]=20296,["Green Dragonscale Leggings"]=15046,["Green Firework"]=9313,["Green Holiday Shirt"]=17723,
 ["Green Iron Boots"]=3484,["Green Iron Bracers"]=3835,["Green Iron Gauntlets"]=3485,["Green Iron Hauberk"]=3844,["Green Iron Helm"]=3836,["Green Iron Leggings"]=3842,
 ["Green Iron Shoulders"]=3840,["Green Leather Armor"]=4255,["Green Leather Belt"]=4257,["Green Leather Bracers"]=4259,["Green Lens"]=10504,["Green Linen Bracers"]=4308,
 ["Green Linen Shirt"]=2579,["Green Rocket Cluster"]=21574,["Green Silk Armor"]=7065,["Green Silk Pack"]=5764,["Green Silken Shoulders"]=7057,["Green Tinted Goggles"]=4385,
 ["Green Whelp Armor"]=7375,["Green Whelp Bracers"]=7386,["Green Winter Clothes"]=34087,["Green Woolen Bag"]=4241,["Green Woolen Robe"]=6243,["Green Woolen Vest"]=2582,
 ["Greenhammer"]=279261,["Grilled Squid"]=13928,["Grimstitch Boots"]=273931,["Grimstitch Gloves"]=273929,["Grimstitch Pants"]=273928,["Grimstitch Spaulders"]=273930,
 ["Grovekeeper Boots"]=273895,["Grovekeeper Gauntlets"]=273897,["Grovekeeper Grips"]=273885,["Grovekeeper Handguards"]=273893,["Grovekeeper Kilt"]=273888,["Grovekeeper Leggings"]=273896,
 ["Grovekeeper Legguards"]=273892,["Grovekeeper Mantle"]=273890,["Grovekeeper Mitts"]=273889,["Grovekeeper Pauldrons"]=273894,["Grovekeeper Sandals"]=273891,["Grovekeeper Shoulderpads"]=273886,
 ["Grovekeeper Spaulders"]=273898,["Grovekeeper Stompers"]=273887,["Grovekeeper Treads"]=273899,["Grovekeeper Trousers"]=273884,["Guard's Boots"]=250504,["Guard's Chain Belt"]=250514,
 ["Guard's Chain Helm"]=250499,["Guard's Chain Leggings"]=250494,["Guard's Chain Shirt"]=250489,["Guard's Gloves"]=250509,["Guard's Silvered Chain Helm"]=250529,["Guard's Silvered Chain Leggings"]=250524,
 ["Guard's Silvered Chain Shirt"]=250519,["Guardian Armor"]=4256,["Guardian Belt"]=4258,["Guardian Cloak"]=5965,["Guardian Gloves"]=5966,["Guardian Leather Bracers"]=4260,
 ["Guardian Pants"]=5962,["Gurubashi Mojo Madness"]=19931,["Gyrochronatom"]=4389,["Gyrofreeze Ice Reflector"]=18634,["Gyromatic Micro-Adjustor"]=10498,["Hammer of the Titans"]=12796,
 ["Handful of Copper Bolts"]=4359,["Handguards of Conviction"]=273925,["Handguards of Glory"]=273949,["Hands of Darkness"]=7047,["Handstitched Leather Belt"]=4237,["Handstitched Leather Boots"]=2302,
 ["Handstitched Leather Bracers"]=7277,["Handstitched Leather Cloak"]=7276,["Handstitched Leather Pants"]=2303,["Handstitched Leather Vest"]=5957,["Handstitched Linen Britches"]=4309,["Hard Gold Boots"]=250534,
 ["Hard Gold Bracers"]=250535,["Hard Gold Coif"]=250537,["Hard Gold Cuirass"]=250533,["Hard Gold Gauntlet"]=250538,["Hard Gold Leggings"]=250536,["Hard Gold Pauldrons"]=250539,
 ["Hardened Iron Shortsword"]=3849,["Harvester Override Signalcaster"]=277132,["Healing Potion"]=929,["Heartseeker"]=12783,["Heavy Armor Kit"]=4265,["Heavy Blasting Powder"]=4377,
 ["Heavy Bronze Mace"]=3491,["Heavy Copper Broadsword"]=3487,["Heavy Copper Maul"]=6214,["Heavy Crocolisk Stew"]=20074,["Heavy Dynamite"]=4378,["Heavy Earthen Gloves"]=7359,
 ["Heavy Grinding Stone"]=3486,["Heavy Kodo Stew"]=12215,["Heavy Leather"]=4234,["Heavy Leather Ammo Pouch"]=7372,["Heavy Leather Ball"]=18662,["Heavy Linen Bandage"]=2581,
 ["Heavy Linen Gloves"]=4307,["Heavy Mageweave Bandage"]=8545,["Heavy Mithril Axe"]=7941,["Heavy Mithril Boots"]=7933,["Heavy Mithril Breastplate"]=7930,["Heavy Mithril Gauntlet"]=7919,
 ["Heavy Mithril Helm"]=7934,["Heavy Mithril Pants"]=7921,["Heavy Mithril Shoulder"]=7918,["Heavy Obsidian Belt"]=22197,["Heavy Quiver"]=7371,["Heavy Runecloth Bandage"]=14530,
 ["Heavy Scorpid Belt"]=15082,["Heavy Scorpid Boots"]=252594,["Heavy Scorpid Bracers"]=15077,["Heavy Scorpid Gauntlet"]=15078,["Heavy Scorpid Helm"]=15080,["Heavy Scorpid Leggings"]=15079,
 ["Heavy Scorpid Shoulders"]=15081,["Heavy Scorpid Vest"]=15076,["Heavy Sharpening Stone"]=2871,["Heavy Silk Bandage"]=6451,["Heavy Thorium Bar"]=251291,["Heavy Thorium Gauntlets"]=279264,
 ["Heavy Timbermaw Belt"]=19043,["Heavy Timbermaw Boots"]=19048,["Heavy Weightstone"]=3241,["Heavy Wool Bandage"]=3531,["Heavy Woolen Cloak"]=4311,["Heavy Woolen Gloves"]=4310,
 ["Heavy Woolen Pants"]=4316,["Helm of Fire"]=8348,["Helm of the Great Chief"]=12636,["Herb Baked Egg"]=6888,["Herbalist's Gloves"]=7349,["Hi-Explosive Bomb"]=10562,
 ["Hi-Impact Mithril Slugs"]=10512,["Hide of the Wild"]=18510,["High-Yield Radiation Bomb"]=215127,["Hillman's Belt"]=4250,["Hillman's Cloak"]=3719,["Hillman's Leather Boots"]=252449,
 ["Hillman's Leather Gloves"]=4247,["Hillman's Leather Vest"]=4244,["Hillman's Shoulders"]=4251,["Hivethrasher's Boots"]=275615,["Hivethrasher's Claws"]=275613,["Hivethrasher's Girdle"]=275614,
 ["Holy Protection Potion"]=6051,["Hoof-Shaped Foot Pedal"]=269902,["Hot Lion Chops"]=3727,["Hot Smoked Bass"]=13929,["Hot Wolf Ribs"]=13851,["Huge Thorium Battleaxe"]=12775,
 ["Hyper Deluxe Sniper Rifle Mk XVII"]=279273,["Hyper-Radiant Flame Reflector"]=18638,["Hyperconductive Arcano-Filament"]=213379,["Ice Deflector"]=4386,["Icebane Bracers"]=22671,["Icebane Breastplate"]=22669,
 ["Icebane Gauntlets"]=22670,["Icy Cloak"]=4327,["Icy Scale Bracers"]=22665,["Icy Scale Breastplate"]=22664,["Icy Scale Gauntlets"]=22666,["Idol of Swiftness"]=279250,
 ["Idol of the Dream"]=220606,["Idol of the Ursine Twins"]=279251,["Imperial Plate Belt"]=12424,["Imperial Plate Boots"]=12426,["Imperial Plate Bracers"]=12425,["Imperial Plate Chest"]=12422,
 ["Imperial Plate Gauntlets"]=250589,["Imperial Plate Helm"]=12427,["Imperial Plate Leggings"]=12429,["Imperial Plate Shoulders"]=12428,["Inferno Gloves"]=18408,["Inlaid Mithril Cylinder"]=9060,
 ["Inlaid Thorium Hammer"]=12772,["Invisibility Potion"]=9172,["Invulnerable Mail"]=12641,["Iridescent Hammer"]=5541,["Iron Bar"]=3575,["Iron Buckle"]=7071,
 ["Iron Counterweight"]=6043,["Iron Fists"]=250604,["Iron Grenade"]=4390,["Iron Morningstar"]=250606,["Iron Oven"]=279982,["Iron Shield Spike"]=6042,
 ["Iron Strut"]=4387,["Ironfeather Breastplate"]=15066,["Ironfeather Leggings"]=252486,["Ironfeather Shoulders"]=15067,["Ironforge Breastplate"]=6731,["Ironforge Chain"]=6730,
 ["Ironforge Gauntlets"]=6733,["Ironvine Belt"]=22764,["Ironvine Breastplate"]=22762,["Ironvine Gloves"]=22763,["Ironwood Blade"]=279259,["Jade Serpentblade"]=3850,
 ["Jagged Obsidian Shield"]=22198,["Journeyman Campfire Kit"]=279961,["Jungle Stew"]=12212,["Justicar's Belt"]=250560,["Justicar's Boots"]=250550,["Justicar's Gauntlet"]=250570,
 ["Justicar's Gloves"]=250555,["Justicar's Pauldrons"]=250580,["Justicar's Sabatons"]=250565,["Justicar's Waistguard"]=250575,["Justicar's Wristguards"]=250585,["Justice Epaulets"]=273914,
 ["Justice Gauntlets"]=273909,["Justice Gloves"]=273913,["Justice Greaves"]=273911,["Justice Handguards"]=273917,["Justice Leggings"]=273908,["Justice Legguards"]=273916,
 ["Justice Legplates"]=273912,["Justice Pauldrons"]=273918,["Justice Sabatons"]=273919,["Justice Spaulders"]=273910,["Justice Treads"]=273915,["Kaldorei Spider Kabob"]=5472,
 ["Kodo Hide Bag"]=5081,["Large Blue Rocket"]=21589,["Large Blue Rocket Cluster"]=21714,["Large Copper Bomb"]=4370,["Large Green Rocket"]=21590,["Large Green Rocket Cluster"]=21716,
 ["Large Purple Rocket"]=21591,["Large Purple Rocket Cluster"]=21717,["Large Red Rocket"]=21592,["Large Red Rocket Cluster"]=21718,["Large Seaforium Charge"]=4398,["Large White Rocket"]=21593,
 ["Large White Rocket Cluster"]=21719,["Large Yellow Rocket"]=21595,["Large Yellow Rocket Cluster"]=21720,["Lava Belt"]=19149,["Lavender Mageweave Shirt"]=10054,["Lean Venison"]=5480,
 ["Lean Wolf Steak"]=12209,["Leather Tourniquet"]=255721,["Leggings of Conviction"]=273924,["Legguards of Glory"]=273948,["Legionite Bar"]=251290,["Legionite Glaive"]=250619,
 ["Legplates of Glory"]=273944,["Lesser Arcane Elixir"]=250342,["Lesser Cleric's Elixir"]=250331,["Lesser Discolored Healing Potion"]=247239,["Lesser Eternal Wand"]=249232,["Lesser Frenzy Potion"]=250939,
 ["Lesser Healing Potion"]=858,["Lesser Invisibility Potion"]=3823,["Lesser Mageblood Elixir"]=250340,["Lesser Magic Wand"]=11287,["Lesser Mana Oil"]=20747,["Lesser Mana Potion"]=3385,
 ["Lesser Mender's Potion"]=250945,["Lesser Mystic Wand"]=11289,["Lesser Spellblasting Potion"]=250933,["Lesser Stoneshield Potion"]=4623,["Lesser Troll's Blood Elixir"]=3388,["Lesser Wizard Oil"]=20746,
 ["Lesser Wizard's Robe"]=5766,["Libram of Holy Alacrity"]=228175,["Libram of Infusion"]=279248,["Libram of Invocation"]=249442,["Lifelike Mechanical Toad"]=15996,["Light Armor Kit"]=2304,
 ["Light Leather"]=2318,["Light Leather Bracers"]=7281,["Light Leather Pants"]=7282,["Light Leather Quiver"]=7278,["Light Leather Reagent Bag"]=277715,["Light Obsidian Belt"]=22195,
 ["Lil' Smoky"]=11826,["Limited Invulnerability Potion"]=3387,["Linen Bag"]=4238,["Linen Bandage"]=1251,["Linen Belt"]=7026,["Linen Boots"]=2569,
 ["Linen Cloak"]=2570,["Linen Reagent Bag"]=253664,["Lionheart Helm"]=12640,["Living Action Potion"]=20008,["Living Breastplate"]=15059,["Living Crown"]=252561,
 ["Living Essence"]=12803,["Living Leggings"]=15060,["Living Shoulders"]=15061,["Lobster Stew"]=13933,["Loch Frenzy Delight"]=6316,["Lodestone"]=279960,
 ["Long Silken Cloak"]=4326,["Longjaw Mud Snapper"]=4592,["Loom"]=279959,["Loot-A-Rang"]=260812,["Lovingly Crafted Boomstick"]=4372,["Low-Background Truesilver Plates"]=213376,
 ["Mageblood Elixir"]=20007,["Magenta Dye"]=249430,["Mageweave Bag"]=10050,["Mageweave Bandage"]=8544,["Mageweave Reagent Bag"]=254035,["Magic Resistance Potion"]=9036,
 ["Major Discolored Healing Potion"]=241650,["Major Frenzy Potion"]=250943,["Major Healing Potion"]=13446,["Major Mana Potion"]=13444,["Major Mender's Potion"]=250949,["Major Recombobulator"]=18637,
 ["Major Rejuvenation Potion"]=18253,["Major Spellblasting Potion"]=250937,["Major Troll's Blood Elixir"]=3826,["Mana Potion"]=3827,["Mana Well"]=279956,["Mana-infused Cord"]=279267,
 ["Manaflare Boots"]=273907,["Manaflare Gloves"]=273905,["Manaflare Mantle"]=273906,["Manaflare Pants"]=273904,["Mantle of Conviction"]=273922,["Mantle of the Timbermaw"]=19050,
 ["Martyr's Legplates"]=250600,["Massive Iron Axe"]=3855,["Master Engineer's Goggles"]=16008,["Master Forge"]=279955,["Masterwork Stormhammer"]=12794,["Masterwork Target Dummy"]=16023,
 ["Mechanical Dragonling"]=4396,["Mechanical Repair Kit"]=11590,["Mechanical Squirrel Box"]=4401,["Medium Armor Kit"]=2313,["Medium Leather"]=2319,["Mender's Leather Belt"]=252523,
 ["Mender's Leather Boots"]=252472,["Mender's Leather Bracers"]=252543,["Mender's Leather Gauntlets"]=252551,["Mender's Leather Gloves"]=252530,["Mender's Leather Shoes"]=252533,["Mender's Leather Shoulders"]=252538,
 ["Mender's Leather Waistguard"]=252477,["Mender's Mail Belt"]=252591,["Mender's Mail Boots"]=252565,["Mender's Mail Bracers"]=252573,["Mender's Mail Gauntlets"]=252587,["Mender's Mail Sabatons"]=252579,
 ["Mender's Mail Shoulders"]=252569,["Mender's Potion"]=250946,["Might of the Timbermaw"]=19044,["Mightfish Steak"]=13934,["Mighty Iron Hammer"]=3492,["Mighty Rage Potion"]=13442,
 ["Minor Arcane Elixir"]=247754,["Minor Cleric's Elixir"]=250330,["Minor Discolored Healing Potion"]=4596,["Minor Frenzy Potion"]=250938,["Minor Healing Potion"]=118,["Minor Mageblood Elixir"]=250339,
 ["Minor Magic Resistance Potion"]=3384,["Minor Mana Oil"]=20745,["Minor Mana Potion"]=2455,["Minor Mender's Potion"]=250944,["Minor Recombobulator"]=4381,["Minor Rejuvenation Potion"]=2456,
 ["Minor Spellblasting Potion"]=250932,["Minor Troll's Blood Elixir"]=3382,["Minor Wizard Oil"]=20744,["Mithril Bar"]=3860,["Mithril Blacksmith Hammer"]=285280,["Mithril Blunderbuss"]=10508,
 ["Mithril Casing"]=10561,["Mithril Claws"]=250609,["Mithril Claymore"]=250610,["Mithril Coif"]=7931,["Mithril Frag Bomb"]=10514,["Mithril Gyro-Shot"]=10513,
 ["Mithril Head Trout"]=8364,["Mithril Heavy-bore Rifle"]=10510,["Mithril Mechanical Dragonling"]=10576,["Mithril Plate Bracers"]=7924,["Mithril Plate Gloves"]=7925,["Mithril Plate Pants"]=7920,
 ["Mithril Plate Shoulders"]=7932,["Mithril Shield Spike"]=7967,["Mithril Shortsword"]=250607,["Mithril Spurs"]=7969,["Mithril Stiletto"]=250611,["Mithril Tube"]=10559,
 ["Mithril Warhammer"]=250608,["Mobile Alarm"]=10719,["Molten Belt"]=19163,["Molten Foundry"]=279952,["Molten Heart of the Mountain"]=249470,["Molten Helm"]=16983,
 ["Mongoose Boots"]=18506,["Monster Omelet"]=12218,["Mooncloth"]=14342,["Mooncloth Bag"]=14155,["Mooncloth Boots"]=15802,["Mooncloth Circlet"]=14140,
 ["Mooncloth Gloves"]=18409,["Mooncloth Leggings"]=14137,["Mooncloth Reagent Bag"]=254133,["Mooncloth Robe"]=18486,["Mooncloth Shoulders"]=14139,["Mooncloth Vest"]=14138,
 ["Moonglow Boots"]=252427,["Moonglow Vest"]=6709,["Moonsight Rifle"]=4383,["Moonsteel Broadsword"]=3853,["Mote of Magic"]=247786,["Mourning Handguards"]=279257,
 ["Mrrggl Smrrthle"]=249873,["Murloc Fin Soup"]=3663,["Murloc Scale Belt"]=5780,["Murloc Scale Bracers"]=5783,["Murloc Scale Breastplate"]=5781,["Murloc Scale Shoes"]=252426,
 ["Mystery Stew"]=12214,["Mystic Heavy Armor Kit"]=252452,["Mystic Medium Armor Kit"]=252436,["Mystic Mushroom"]=249396,["Mystic Rugged Armor Kit"]=252487,["Mystic Thick Armor Kit"]=252462,
 ["Nature Protection Potion"]=6052,["Netherflame Cuffs"]=254065,["Netherflame Shoulders"]=254053,["Netherfroth Cuffs"]=254063,["Netherfroth Shoulders"]=254051,["Nethergeld Cuffs"]=254061,
 ["Nethergeld Shoulders"]=254049,["Netherlight Cuffs"]=254071,["Netherlight Shoulders"]=254059,["Netherpearl Cuffs"]=254067,["Netherpearl Shoulders"]=254055,["Nethershine Cuffs"]=254069,
 ["Nethershine Shoulders"]=254057,["Nightfall"]=19169,["Nightfin Soup"]=13931,["Nightscape Boots"]=8197,["Nightscape Cloak"]=8195,["Nightscape Headband"]=8176,
 ["Nightscape Pants"]=8193,["Nightscape Shoulders"]=8192,["Nightscape Tunic"]=8175,["Nimble Leather Gloves"]=7285,["No Slip SAF-T Padding"]=260796,["Novice Arcanist's Sash"]=253885,
 ["Novice Ardent's Sash"]=253887,["Novice's Practice Wand"]=247789,["Obsidian Mail Tunic"]=22191,["Officer's Belt"]=250556,["Officer's Boots"]=250546,["Officer's Gauntlet"]=250566,
 ["Officer's Gloves"]=250551,["Officer's Pauldrons"]=250576,["Officer's Sabatons"]=250561,["Officer's Waistguard"]=250571,["Officer's Wristguards"]=250581,["Oil of Immolation"]=8956,
 ["Onyxia Scale Cloak"]=15138,["Orange Mageweave Shirt"]=10056,["Orange Martial Shirt"]=10052,["Orb of Mystic Insight"]=249394,["Orb of Souls"]=249395,["Orcish War Leggings"]=7929,
 ["Ornate Mithril Boots"]=7936,["Ornate Mithril Breastplate"]=7935,["Ornate Mithril Gloves"]=7927,["Ornate Mithril Helm"]=7937,["Ornate Mithril Pants"]=7926,["Ornate Mithril Shoulders"]=7928,
 ["Ornate Spyglass"]=5507,["Ornate Thorium Handaxe"]=12773,["Outlaw's Collar"]=279253,["Pants of Conviction"]=273920,["Parachute Cloak"]=10518,["Patterned Bronze Bracers"]=2868,
 ["Pauldrons of Conviction"]=273926,["Pauldrons of Glory"]=273950,["Peace Tea"]=249865,["Pearl-clasped Cloak"]=5542,["Pearl-handled Dagger"]=5540,["Pearly Boots"]=253897,
 ["Pearly Circlet"]=253957,["Pearly Gloves"]=253921,["Pearly Gown"]=253969,["Pearly Leggings"]=253995,["Pearly Sash"]=253933,["Persuader"]=22384,
 ["Pet Bombling"]=11825,["Phantom Blade"]=7961,["Philosopher's Stone"]=9149,["Phoenix Gloves"]=4331,["Phoenix Pants"]=4317,["Pilferer's Gloves"]=7358,
 ["Pincer Bites"]=263512,["Pink Mageweave Shirt"]=10055,["Plague Doctor's Laboratory"]=279951,["Plain Ol' Paletusk"]=274976,["Plated Armorfish"]=13890,["Poached Sunscale Salmon"]=13932,
 ["Polar Bracers"]=22663,["Polar Gloves"]=22662,["Polar Tunic"]=22661,["Polished Driftwood Icon"]=249398,["Polished Steel Boots"]=3846,["Polished Truesilver Gears"]=213383,
 ["Pop-Up Shrub"]=237023,["Portable Bronze Mortar"]=4403,["Potent Anti-Venom"]=255715,["Potion of Beast Slaying"]=250955,["Potion of Demon Slaying"]=9224,["Potion of Elemental Purging"]=250954,
 ["Potion of Poison Cleansing"]=3386,["Potion of Predatory Senses"]=250327,["Potion of Venomous Blood"]=250950,["Powerful Anti-Venom"]=19440,["Powerful Poultice"]=255719,["Powerful Seaforium Charge"]=18594,
 ["Practice Lock"]=6712,["Prefect's Belt"]=250559,["Prefect's Boots"]=250549,["Prefect's Gauntlet"]=250569,["Prefect's Gloves"]=250554,["Prefect's Pauldrons"]=250579,
 ["Prefect's Sabatons"]=250564,["Prefect's Waistguard"]=250574,["Prefect's Wristguards"]=250584,["Prehistoric Pulled Raptor"]=250075,["Primal Batskin Bracers"]=19687,["Primal Batskin Gloves"]=19686,
 ["Primal Batskin Jerkin"]=19685,["Pristine Boots"]=253889,["Pristine Circlet"]=253949,["Pristine Gloves"]=253913,["Pristine Gown"]=253961,["Pristine Leggings"]=253987,
 ["Pristine Sash"]=253925,["Pristine Scorpid Leggings"]=252606,["Protector's Boots"]=31420,["Protector's Chain Belt"]=250515,["Protector's Chain Helm"]=250500,["Protector's Chain Leggings"]=250495,
 ["Protector's Chain Shirt"]=250490,["Protector's Gloves"]=250510,["Protector's Silvered Chain Helm"]=250530,["Protector's Silvered Chain Leggings"]=250525,["Protector's Silvered Chain Shirt"]=250520,["Prowler Steak"]=238637,
 ["Prowler's Leather Belt"]=252459,["Prowler's Leather Boots"]=252468,["Prowler's Leather Bracers"]=252539,["Prowler's Leather Gauntlets"]=252547,["Prowler's Leather Gloves"]=252524,["Prowler's Leather Shoes"]=252465,
 ["Prowler's Leather Shoulders"]=252534,["Prowler's Leather Waistguard"]=252473,["Purification Potion"]=13462,["Purple Rocket Cluster"]=21575,["Quickdraw Quiver"]=8217,["Radiant Belt"]=12416,
 ["Radiant Boots"]=12419,["Radiant Breastplate"]=12415,["Radiant Circlet"]=12417,["Radiant Cord"]=254047,["Radiant Gloves"]=12418,["Radiant Handwraps"]=254031,
 ["Radiant Leggings"]=12420,["Radiant Sandals"]=254117,["Radiant Slippers"]=254011,["Radiant Staff"]=249453,["Radiant Waistcord"]=254091,["Rage Potion"]=5631,
 ["Raging Raptor Ribs"]=250073,["Rainbow Fin Albacore"]=5095,["Raptor Hide Belt"]=4456,["Raptor Hide Harness"]=4455,["Raptor Rouladen"]=250076,["Reagent Bot"]=279950,
 ["Red Dragonscale Breastplate"]=15047,["Red Dragonscale Leggings"]=252603,["Red Firework"]=9318,["Red Linen Bag"]=5762,["Red Linen Robe"]=2572,["Red Linen Shirt"]=2575,
 ["Red Linen Vest"]=6239,["Red Mageweave Bag"]=10051,["Red Mageweave Gloves"]=10018,["Red Mageweave Headband"]=10033,["Red Mageweave Pants"]=10009,["Red Mageweave Shoulders"]=10029,
 ["Red Mageweave Vest"]=10007,["Red Rocket Cluster"]=21576,["Red Swashbuckler's Shirt"]=6796,["Red Whelp Gloves"]=7284,["Red Winter Clothes"]=34085,["Red Woolen Bag"]=5763,
 ["Red Woolen Boots"]=4313,["Redridge Goulash"]=1082,["Refined Scale of Onyxia"]=17967,["Reinforced Linen Cape"]=2580,["Reinforced Woolen Shoulders"]=4315,["Repair Bot"]=279949,
 ["Restorative Potion"]=9030,["Rich Purple Silk Shirt"]=4335,["Rime-encrusted Boots"]=279268,["Roast Raptor"]=12210,["Roasted Boar Meat"]=2681,["Roasted Kodo Meat"]=5474,
 ["Robe of Power"]=7054,["Robe of Winter Night"]=14136,["Robe of the Archmage"]=14152,["Robe of the Void"]=14153,["Robes of Arcana"]=5770,["Robes of Fiery Devastation"]=279266,
 ["Rock Garden"]=279948,["Rockscale Cod"]=4594,["Root Tea"]=249867,["Rose Colored Goggles"]=10503,["Rough Blasting Powder"]=4357,["Rough Boomstick"]=4362,
 ["Rough Bronze Boots"]=6350,["Rough Bronze Bracers"]=2867,["Rough Bronze Cuirass"]=2866,["Rough Bronze Leggings"]=2865,["Rough Bronze Shoulders"]=3480,["Rough Copper Bomb"]=4360,
 ["Rough Copper Chain Boots"]=277672,["Rough Copper Vest"]=10421,["Rough Dynamite"]=4358,["Rough Grinding Stone"]=3470,["Rough Sharpening Stone"]=2862,["Rough Weightstone"]=3239,
 ["Royal Tea"]=249866,["Rugged Armor Kit"]=15564,["Rugged Leather"]=8170,["Rugged Leather Pants"]=7280,["Rune Edge"]=12779,["Runecloth Bag"]=14046,
 ["Runecloth Bandage"]=14529,["Runecloth Belt"]=13856,["Runecloth Boots"]=13864,["Runecloth Cloak"]=13860,["Runecloth Cuffs"]=254123,["Runecloth Gloves"]=13863,
 ["Runecloth Headband"]=13866,["Runecloth Pants"]=13865,["Runecloth Reagent Bag"]=254079,["Runecloth Robe"]=13858,["Runecloth Shoulders"]=13867,["Runecloth Tunic"]=13857,
 ["Runed Arcanite Rod"]=16207,["Runed Copper Belt"]=2857,["Runed Copper Bracers"]=2854,["Runed Copper Breastplate"]=2864,["Runed Copper Gauntlets"]=3472,["Runed Copper Pants"]=3473,
 ["Runed Copper Rod"]=6218,["Runed Golden Rod"]=11130,["Runed Mithril Hammer"]=7946,["Runed Silver Rod"]=6339,["Runed Stygian Belt"]=20539,["Runed Stygian Boots"]=20537,
 ["Runed Stygian Leggings"]=20538,["Runed Truesilver Rod"]=11145,["Runic Breastplate"]=12613,["Runic Leather Armor"]=15090,["Runic Leather Belt"]=15093,["Runic Leather Bracers"]=15092,
 ["Runic Leather Gauntlets"]=15091,["Runic Leather Headband"]=15094,["Runic Leather Pants"]=15095,["Runic Leather Shoulders"]=15096,["Runic Plate Boots"]=12611,["Runic Plate Helm"]=12612,
 ["Runic Plate Leggings"]=12614,["Runic Plate Shoulders"]=12610,["Runn Tum Tuber Surprise"]=18254,["SAF-T Bell"]=260799,["SAF-T Bomb"]=260805,["SAF-T Bronze Bomb"]=260797,
 ["SAF-T Casing"]=260804,["SAF-T Clever Dynamite"]=260814,["SAF-T Copper Bomb"]=260793,["SAF-T Disposable Parachute"]=260810,["SAF-T Dynamite"]=260792,["SAF-T Emergency Ripper: Everlook"]=260820,
 ["SAF-T Jumbo Dynamite"]=260798,["SAF-T Nitro Boosts"]=260828,["SAF-T Tabs"]=260784,["SAF-T Teleport"]=260830,["SAF-T Tube"]=260813,["SAF-T Ultra Precision Scope"]=279272,
 ["Sabatons of Glory"]=273951,["Sage's Tea"]=249870,["Sageblade"]=22383,["Sagefish Delight"]=21217,["Salt Shaker"]=15846,["Sandpaper"]=249432,
 ["Sandstalker Bracers"]=20476,["Sandstalker Breastplate"]=20478,["Sandstalker Gauntlets"]=20477,["Satchel of Bronze Bombs"]=285276,["Satchel of Cenarius"]=22252,["Satchel of Copper Bombs"]=285275,
 ["Satchel of Dark Iron Bombs"]=285278,["Satchel of Iron Bombs"]=285277,["Savory Deviate Delight"]=6657,["Savory Stag Sliders"]=250065,["Savory Turtle Stew"]=250068,["Savory Whimsyfin Delight"]=251525,
 ["Scalegut Belt"]=275617,["Scalegut Clenchers"]=275616,["Scalegut Treaders"]=275618,["Scorpid Surprise"]=5473,["Scroll of Spatial Mending"]=220792,["Searing Golden Blade"]=12260,
 ["Seasoned Wolf Kabob"]=1017,["Sentinel's Belt"]=250557,["Sentinel's Boots"]=250547,["Sentinel's Gauntlet"]=250567,["Sentinel's Gloves"]=250552,["Sentinel's Pauldrons"]=250577,
 ["Sentinel's Sabatons"]=250562,["Sentinel's Waistguard"]=250572,["Sentinel's Wristguards"]=250582,["Serenity"]=12781,["Sewing Machine"]=279945,["Shadow Boots"]=253895,
 ["Shadow Circlet"]=253955,["Shadow Crescent Axe"]=3856,["Shadow Gloves"]=253919,["Shadow Goggles"]=4373,["Shadow Gown"]=253967,["Shadow Hood"]=4323,
 ["Shadow Leggings"]=253993,["Shadow Oil"]=3824,["Shadow Protection Potion"]=6048,["Shadow Sash"]=253931,["Shadoweave Boots"]=10031,["Shadoweave Gloves"]=10023,
 ["Shadoweave Mask"]=10025,["Shadoweave Pants"]=10002,["Shadoweave Robe"]=10004,["Shadoweave Shoulders"]=10028,["Shadowskin Gloves"]=18238,["Shafety Sheep"]=260800,
 ["Sharpening Wheel"]=279944,["Shifting Cloak"]=18511,["Shining Boots"]=253899,["Shining Circlet"]=253959,["Shining Gloves"]=253923,["Shining Gown"]=253971,
 ["Shining Leggings"]=253997,["Shining Mithril Boots"]=250542,["Shining Mithril Breastplate"]=250540,["Shining Mithril Gauntlet"]=250545,["Shining Mithril Helm"]=250543,["Shining Mithril Pants"]=250544,
 ["Shining Mithril Pauldrons"]=250541,["Shining Sash"]=253935,["Shining Silver Breastplate"]=2870,["Shoulders of Glory"]=273946,["Shredder Autosalvage Unit"]=210147,["Silk Bandage"]=6450,
 ["Silk Headband"]=7050,["Silk Reagent Bag"]=253973,["Silky Boots"]=253891,["Silky Circlet"]=253951,["Silky Gloves"]=253915,["Silky Gown"]=253963,
 ["Silky Leggings"]=253989,["Silky Sash"]=253927,["Silver Bar"]=2842,["Silver Contact"]=4404,["Silver Rod"]=6338,["Silver Skeleton Key"]=15869,
 ["Silver-plated Shotgun"]=4379,["Silvered Bronze Boots"]=3482,["Silvered Bronze Breastplate"]=2869,["Silvered Bronze Gauntlets"]=3483,["Silvered Bronze Leggings"]=10423,["Silvered Bronze Shoulders"]=3481,
 ["Simple Black Dress"]=10053,["Simple Dress"]=6786,["Simple Kilt"]=10047,["Simple Linen Boots"]=10046,["Simple Linen Pants"]=10045,["Simple Poultice"]=255716,
 ["Skirmisher's Leather Belt"]=252461,["Skirmisher's Leather Gloves"]=252528,["Skirmisher's Mail Belt"]=252590,["Skirmisher's Mail Boots"]=252564,["Skirmisher's Mail Bracers"]=252572,["Skirmisher's Mail Gauntlets"]=252586,
 ["Skirmisher's Mail Sabatons"]=252578,["Skirmisher's Mail Shoulders"]=252568,["Skulker's Leather Belt"]=252520,["Skulker's Leather Boots"]=252469,["Skulker's Leather Bracers"]=252540,["Skulker's Leather Gauntlets"]=252548,
 ["Skulker's Leather Gloves"]=252525,["Skulker's Leather Shoes"]=252531,["Skulker's Leather Shoulder"]=252535,["Skulker's Leather Waistguard"]=252474,["Skycaller's Leather Belt"]=252522,["Skycaller's Leather Boots"]=252471,
 ["Skycaller's Leather Bracers"]=252542,["Skycaller's Leather Gauntlets"]=252550,["Skycaller's Leather Gloves"]=252529,["Skycaller's Leather Shoes"]=252532,["Skycaller's Leather Shoulders"]=252537,["Skycaller's Leather Waistguard"]=252476,
 ["Skycaller's Mail Belt"]=252589,["Skycaller's Mail Boots"]=252563,["Skycaller's Mail Bracers"]=252571,["Skycaller's Mail Gauntlets"]=252585,["Skycaller's Mail Sabatons"]=252577,["Skycaller's Mail Shoulders"]=252567,
 ["Skywall Souffle"]=263509,["Slimy Smoothie"]=249872,["Slitherskin Mackerel"]=787,["Small Blue Rocket"]=21558,["Small Bronze Bomb"]=4374,["Small Green Rocket"]=21559,
 ["Small Leather Ammo Pouch"]=7279,["Small Purple Rocket"]=21560,["Small Red Rocket"]=21557,["Small Seaforium Charge"]=4367,["Small Silk Pack"]=4245,["Small White Rocket"]=21561,
 ["Small Yellow Rocket"]=21562,["Smoked Bear Meat"]=6890,["Smoked Desert Dumplings"]=20452,["Smoked Sagefish"]=21072,["Smoking Heart of the Mountain"]=11811,["Snake Burst Firework"]=19026,
 ["Sniper Scope"]=10548,["Snowmaster 9000"]=17716,["Soaring Pamplona"]=250066,["Soft-soled Linen Boots"]=4312,["Solid Blasting Powder"]=10505,["Solid Dynamite"]=10507,
 ["Solid Grinding Stone"]=7966,["Solid Iron Maul"]=3851,["Solid Sharpening Stone"]=7964,["Solid Weightstone"]=7965,["Soothing Turtle Bisque"]=3729,["Soul Pouch"]=21340,
 ["Soulstaff"]=249393,["Specklefin Feast"]=238641,["Spellblasting Potion"]=250934,["Spellpower Goggles Xtreme"]=10502,["Spellpower Goggles Xtreme Plus"]=15999,["Spiced Chili Crab"]=12216,
 ["Spiced Wolf Meat"]=2680,["Spicy Smoothie"]=249875,["Spider Belt"]=4328,["Spider Sausage"]=17222,["Spider Silk Slippers"]=4321,["Spidersilk Boots"]=4320,
 ["Spinefin Halibut"]=8957,["Spinning Wheel"]=279943,["Spiritcaller Boots"]=276541,["Spiritcaller Epaulets"]=273938,["Spiritcaller Gauntlets"]=273937,["Spiritcaller Gloves"]=276539,
 ["Spiritcaller Greaves"]=273939,["Spiritcaller Grips"]=273933,["Spiritcaller Kilt"]=276538,["Spiritcaller Leggings"]=273932,["Spiritcaller Mantle"]=276540,["Spiritcaller Pants"]=273936,
 ["Spiritcaller Spaulders"]=273934,["Spiritcaller Treads"]=273935,["Spitfire Bracers"]=20481,["Spitfire Breastplate"]=20479,["Spitfire Gauntlets"]=20480,["Spotted Yellowtail"]=6887,
 ["Stalker's Leather Belt"]=252521,["Stalker's Leather Gloves"]=252526,["Stalker's Mail Belt"]=252588,["Stalker's Mail Boots"]=252562,["Stalker's Mail Bracers"]=252570,["Stalker's Mail Gauntlets"]=252584,
 ["Stalker's Mail Sabatons"]=252576,["Stalker's Mail Shoulders"]=252566,["Stalwart Helm"]=250599,["Standard Scope"]=4406,["Star Belt"]=4329,["Steadfast Libram"]=279247,
 ["Stealthman 52"]=260827,["Steam Tonk Controller"]=22728,["Steaming Stag Steak"]=250071,["Steel Bar"]=3859,["Steel Breastplate"]=7963,["Steel Plate Helm"]=7922,
 ["Steel Spear"]=250605,["Steel Weapon Chain"]=6041,["Sterling Silver Boots"]=250483,["Sterling Silver Breastplate"]=250487,["Sterling Silver Gauntlet"]=250485,["Sterling Silver Leggings"]=250484,
 ["Sterling Silver Shoulders"]=250486,["Stonescale Oil"]=13423,["Storm Gauntlets"]=12632,["Stormcarver"]=250617,["Stormcloth Boots"]=10039,["Stormcloth Gloves"]=10011,
 ["Stormcloth Headband"]=10032,["Stormcloth Pants"]=10010,["Stormcloth Shoulders"]=10038,["Stormcloth Vest"]=10020,["Stormrider's Leather Armor"]=252492,["Stormrider's Leather Belt"]=252432,
 ["Stormrider's Leather Boots"]=252443,["Stormrider's Leather Gloves"]=252498,["Stormrider's Leather Helm"]=252514,["Stormrider's Leather Hood"]=252506,["Stormrider's Leather Kilt"]=252518,["Stormrider's Leather Pants"]=252502,
 ["Stormrider's Leather Tunic"]=252510,["Stormshroud Armor"]=15056,["Stormshroud Gloves"]=21278,["Stormshroud Pants"]=15057,["Stormshroud Shoulders"]=15058,["Strange Copper Boots"]=250621,
 ["Strider Stew"]=5477,["Strong Anti-Venom"]=6453,["Stronghold Gauntlets"]=12639,["Stuckbutton Goggles"]=280312,["Stylish Blue Shirt"]=6384,["Stylish Green Shirt"]=6385,
 ["Stylish Red Shirt"]=4330,["Succulent Pork Ribs"]=2685,["Sulfuric Acid"]=249410,["Sulfuron Hammer"]=17193,["Sunny Tea"]=249869,["Sunrise Omelette"]=238639,
 ["Superior Discolored Healing Potion"]=247242,["Superior Frenzy Potion"]=250942,["Superior Healing Potion"]=3928,["Superior Mana Potion"]=13443,["Superior Mender's Potion"]=250948,["Superior Poultice"]=255718,
 ["Superior Spellblasting Potion"]=250936,["Supple Scorpid Belt"]=252595,["Supple Scorpid Boots"]=252574,["Supple Scorpid Bracers"]=252582,["Supple Scorpid Helm"]=252597,["Supple Scorpid Leggings"]=252580,
 ["Supple Scorpid Sabatons"]=252601,["Supple Scorpid Shoulders"]=252592,["Supple Scorpid Vest"]=252599,["Surgical Tourniquet"]=255722,["Swarmtender's Cord"]=275608,["Swarmtender's Footpads"]=275609,
 ["Swarmtender's Gloves"]=275607,["Sweetpaw Jam"]=267341,["Swift Boots"]=7391,["Swift Flight Bracers"]=18508,["Swiftfeather Arrow"]=274387,["Swiftness Potion"]=2459,
 ["Swiftstrike Shot"]=274388,["Swiftstrike Steak"]=250072,["Swim Speed Potion"]=6372,["Sylvan Crown"]=22757,["Sylvan Shoulders"]=22758,["Sylvan Vest"]=22756,
 ["Talons of Wrath"]=249441,["Tanning Rack"]=279941,["Target Dummy"]=4366,["Tasty Lion Steak"]=3728,["Tasty Raptor Bites"]=250079,["Tender Wolf Steak"]=18045,
 ["Tenets of the Silver Hand"]=249397,["The Big One"]=10586,["The Shatterer"]=7954,["Thick Armor Kit"]=8173,["Thick Leather"]=4304,["Thick Leather Ammo Pouch"]=8218,
 ["Thick Murloc Armor"]=5782,["Thick Obsidian Breastplate"]=22196,["Thick War Axe"]=3489,["Thistle Tea"]=7676,["Thorium Armor"]=12405,["Thorium Bar"]=12359,
 ["Thorium Belt"]=12406,["Thorium Boots"]=12409,["Thorium Bracers"]=12408,["Thorium Cestus"]=250614,["Thorium Greatmace"]=250613,["Thorium Greatsword"]=12764,
 ["Thorium Grenade"]=15993,["Thorium Helm"]=12410,["Thorium Leggings"]=12414,["Thorium Poleaxe"]=250615,["Thorium Rifle"]=15995,["Thorium Shells"]=15997,
 ["Thorium Shield Spike"]=12645,["Thorium Tube"]=16000,["Thorium Widget"]=15994,["Timbermaw Brawlers"]=19049,["Timbermaw Tunic"]=252484,["Tin Bar"]=3576,
 ["Tinkerbox"]=238737,["Tinkerbox: Magnetic Displacement"]=238736,["Tinkerbox: Nitro Boosts"]=238735,["Tinkerbox: Teleport"]=238734,["Titanic Leggings"]=22385,["Tooled Leather Armor"]=252552,
 ["Tooled Leather Belt"]=252544,["Tooled Leather Boots"]=252545,["Tooled Leather Bracers"]=252557,["Tooled Leather Crown"]=252555,["Tooled Leather Epaulets"]=252558,["Tooled Leather Gauntlets"]=252553,
 ["Tooled Leather Pants"]=252560,["Torch of Light"]=279246,["Totem of Ancestral Protection"]=249443,["Totem of Thunder"]=228176,["Totem of Urgency"]=279249,["Totemic Leather Armor"]=252435,
 ["Totemic Leather Belt"]=252431,["Totemic Leather Boots"]=252442,["Totemic Leather Gloves"]=252497,["Totemic Leather Helm"]=252456,["Totemic Leather Hood"]=252448,["Totemic Leather Leggings"]=252458,
 ["Totemic Leather Pants"]=252446,["Totemic Leather Tunic"]=252451,["Tough Scorpid Boots"]=8209,["Tough Scorpid Bracers"]=8205,["Tough Scorpid Breastplate"]=8203,["Tough Scorpid Gloves"]=8204,
 ["Tough Scorpid Helm"]=8208,["Tough Scorpid Leggings"]=8206,["Tough Scorpid Shoulders"]=8207,["Toughened Leather Armor"]=2314,["Toughened Leather Gloves"]=4253,["Toxin Study"]=279940,
 ["Tranquil Mechanical Yeti"]=21277,["Tranquil Wristguards"]=279256,["Trapper's Leather Armor"]=252491,["Trapper's Leather Belt"]=252429,["Trapper's Leather Boots"]=252440,["Trapper's Leather Gloves"]=252495,
 ["Trapper's Leather Helm"]=252513,["Trapper's Leather Hood"]=252505,["Trapper's Leather Legguards"]=252517,["Trapper's Leather Pants"]=252501,["Trapper's Leather Tunic"]=252509,["Treads of Conviction"]=273923,
 ["Triage Tea"]=249868,["Troll's Blood Elixir"]=3826,["Tru-Trigger Frag Bomb"]=260809,["Truefaith Gloves"]=7049,["Truefaith Vestments"]=14154,["Truesilver Bar"]=6037,
 ["Truesilver Breastplate"]=7939,["Truesilver Champion"]=7960,["Truesilver Conduit"]=249455,["Truesilver Gauntlets"]=7938,["Truesilver Rod"]=11144,["Truesilver Skeleton Key"]=15871,
 ["Truesilver Transformer"]=18631,["Turtle Scale Bracers"]=8198,["Turtle Scale Breastplate"]=8189,["Turtle Scale Gloves"]=8187,["Turtle Scale Helm"]=8191,["Turtle Scale Leggings"]=8185,
 ["Tuxedo Jacket"]=10036,["Tuxedo Pants"]=10035,["Tuxedo Shirt"]=10034,["Twice-Spiced Raptor Slice"]=250077,["Twisted Nether Wand"]=249144,["Twisting Essence Jar"]=249456,
 ["Ultra-Flash Shadow Reflector"]=18639,["Ultralight Goblin Glider"]=260825,["Ultrasafe Rechargeable Battery"]=260822,["Ultrasafe Transporter: Gadgetzan"]=18986,["Undermine Clam Chowder"]=16766,["Unsanctified Grenade"]=284869,
 ["Unstable Trigger"]=10560,["Venomous Smoothie"]=249871,["Venomspew Cord"]=275605,["Venomspew Footpads"]=275606,["Venomspew Gloves"]=275604,["Veteran's Boots"]=250503,
 ["Veteran's Chain Belt"]=250513,["Veteran's Chain Helm"]=250498,["Veteran's Chain Leggings"]=250493,["Veteran's Chain Shirt"]=250488,["Veteran's Gloves"]=250508,["Veteran's Silvered Chain Helm"]=250528,
 ["Veteran's Silvered Chain Leggings"]=250523,["Veteran's Silvered Chain Shirt"]=250518,["Viridian Dye"]=249431,["Voice Amplification Modulator"]=16009,["Volcanic Breastplate"]=15053,["Volcanic Hammer"]=12792,
 ["Volcanic Leggings"]=15054,["Volcanic Shoulders"]=15055,["Warbear Harness"]=15064,["Warbear Helm"]=252485,["Warbear Woolies"]=15065,["Warden's Leather Belt"]=252460,
 ["Warden's Leather Boots"]=252470,["Warden's Leather Bracers"]=252541,["Warden's Leather Gauntlets"]=252549,["Warden's Leather Gloves"]=252527,["Warden's Leather Shoes"]=252466,["Warden's Leather Shoulders"]=252536,
 ["Warden's Leather Waistguard"]=252475,["Warder's Belt"]=250558,["Warder's Boots"]=20900,["Warder's Gauntlet"]=250568,["Warder's Gloves"]=250553,["Warder's Pauldrons"]=250578,
 ["Warder's Sabatons"]=250563,["Warder's Waistguard"]=250573,["Warder's Wristguards"]=250583,["Westfall Stew"]=733,["Whimsical Waistwrap"]=280306,["Whirring Bronze Gizmo"]=4375,
 ["White Bandit Mask"]=10008,["White Leather Jerkin"]=2311,["White Linen Robe"]=6241,["White Linen Shirt"]=2576,["White Rocket Cluster"]=21577,["White Swashbuckler's Shirt"]=6795,
 ["White Wedding Dress"]=10040,["White Woolen Dress"]=6787,["Whitesoul Helm"]=12633,["Wicked Leather Armor"]=15085,["Wicked Leather Belt"]=15088,["Wicked Leather Boots"]=252479,
 ["Wicked Leather Bracers"]=15084,["Wicked Leather Gauntlets"]=15083,["Wicked Leather Headband"]=15086,["Wicked Leather Pants"]=15087,["Wicked Leather Shoulders"]=252556,["Wicked Mithril Blade"]=7943,
 ["Wicked Smoothie"]=249876,["Wild Leather Armor Kit"]=279258,["Wild Leather Boots"]=8213,["Wild Leather Cloak"]=8215,["Wild Leather Helmet"]=8214,["Wild Leather Leggings"]=8212,
 ["Wild Leather Shoulders"]=8210,["Wild Leather Vest"]=8211,["Wildstalker's Gauntlets"]=273901,["Wildstalker's Greaves"]=273903,["Wildstalker's Legguards"]=273900,["Wildstalker's Spaulders"]=273902,
 ["Wildthorn Mail"]=12624,["Wildvine Potion"]=9144,["Winter Boots"]=34086,["Wisdom of the Timbermaw"]=19047,["Wisdom's Leather Armor"]=252493,["Wisdom's Leather Belt"]=252433,
 ["Wisdom's Leather Boots"]=252444,["Wisdom's Leather Gloves"]=252499,["Wisdom's Leather Helm"]=252515,["Wisdom's Leather Hood"]=252507,["Wisdom's Leather Leggings"]=252519,["Wisdom's Leather Pants"]=252503,
 ["Wisdom's Leather Tunic"]=252511,["Wizard Oil"]=20750,["Wizardweave Leggings"]=14132,["Wizardweave Robe"]=14128,["Wizardweave Turban"]=14130,["Wolfshead Helm"]=8345,
 ["Wool Bandage"]=3530,["Woolen Bag"]=4240,["Woolen Boots"]=2583,["Woolen Cape"]=2584,["Woolen Reagent Bag"]=253667,["Woolen Tourniquet"]=255720,
 ["World Enlarger"]=18660,["Yellow Rocket Cluster"]=21578,
}
