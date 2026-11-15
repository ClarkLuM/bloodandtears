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
-- The addon never sends anything anywhere and draws nothing on screen; it puts a short line in your chat when it notes a
-- boss kill or a rare-or-better drop (/scribe quiet turns those off). /scribe shows a summary.

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
end

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
  for i = 1, n do
    local full, rankName, _, level, _, zone, _, _, isOnline, _, classFile = GetGuildRosterInfo(i)
    if full then
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
  if not s then return nil end
  local p = s:gsub("([%.%(%)%-%+%*%?%[%]%^%$])", "%%%1"):gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)")
  return "^" .. p .. "$"
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
-- A line in your chat when the scribe notes something, so you know it's working. "/scribe quiet" turns them off.
local TAG = "|cffe0a862Blood and Tears Scribe|r: "
local function say(msg) if db and not db.quiet then print(TAG .. msg) end end
local function guildiesIn(who)
  local n = 0
  for name in pairs(who) do
    if db.members[name] then n = n + 1
    else for full in pairs(db.members) do if full:sub(1, #name + 1) == name .. " " then n = n + 1; break end end end
  end
  return n
end
local function bossKilled(boss, success)
  if not db or success ~= 1 or not boss then return end
  local zone = inInstance() or GetRealZoneText()
  local who = groupNames()
  table.insert(db.kills, { t = now(), zone = zone, boss = boss, who = who })
  readRun()
  prune()
  local today, n = dayOf(now()), 0
  for _, k in ipairs(db.kills) do if dayOf(k.t) == today and k.zone == zone then n = n + 1 end end
  local g = guildiesIn(who)
  say(("noted %s in %s (%d %s today), with %d %s in the group."):format(boss, zone or "?", n, n == 1 and "boss" or "bosses",
    g, g == 1 and "guildie" or "guildies"))
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
  local id = tonumber(link:match("item:(%d+)"))
  local name = link:match("%[(.-)%]")
  local col = link:match("|c%x%x(%x%x%x%x%x%x)")
  local q = col and QCOL[col:lower()]
  if not q and GetItemInfo then q = select(3, GetItemInfo(link)) end
  if not id or not name or not q or q < 2 then return end
  table.insert(db.loot, { t = now(), who = short(who), id = id, q = q, name = name, zone = zone })
  prune()
  if q >= 3 then say(("noted %s for %s."):format(link, short(who))) end
end

-- "X has joined the guild." and friends, using the game's own wording so it works in any language.
local JOIN, LEAVE, REMOVED = pattern(ERR_GUILD_JOIN_S), pattern(ERR_GUILD_LEAVE_S), pattern(ERR_GUILD_REMOVE_SS)
local function system(msg)
  if not db or not msg then return end
  local who, what
  if JOIN then who = msg:match(JOIN); what = "joined" end
  if not who and LEAVE then who = msg:match(LEAVE); what = "left" end
  if not who and REMOVED then who = msg:match(REMOVED); what = "removed" end
  if not who then return end
  note(short(who), what)
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
end

-- Your own characters' recipes, read when you open a profession window. Tries the newer and the older game functions.
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
      if r and r.learned and r.name then names[#names + 1] = r.name end
    end
  elseif GetTradeSkillLine and GetNumTradeSkills then
    prof = GetTradeSkillLine()
    for i = 1, GetNumTradeSkills() do
      local name, kind = GetTradeSkillInfo(i)
      if name and kind ~= "header" then names[#names + 1] = name end
    end
  end
  if not prof or prof == "" or prof == "UNKNOWN" or #names == 0 then return end
  table.sort(names)
  db.recipes[me] = db.recipes[me] or {}
  db.recipes[me][prof] = { at = now(), list = names }
end

f:SetScript("OnEvent", function(_, event, a1, a2, a3, a4, a5)
  if event == "ADDON_LOADED" and a1 == ADDON then
    init()
  elseif event == "PLAYER_LOGIN" then
    askRoster()
    -- The guild list only refreshes when asked: ask every five minutes.
    C_Timer.NewTicker(300, askRoster)
  elseif event == "GUILD_ROSTER_UPDATE" then
    readRoster()
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
  elseif event == "PLAYER_REGEN_ENABLED" then
    askRoster()
  elseif event == "PLAYER_LEVEL_UP" then
    levelUp(a1)
  end
end)
for _, e in ipairs({ "ADDON_LOADED", "PLAYER_LOGIN", "GUILD_ROSTER_UPDATE", "GROUP_ROSTER_UPDATE", "ZONE_CHANGED_NEW_AREA",
  "CHAT_MSG_SYSTEM", "TRADE_SKILL_SHOW", "TRADE_SKILL_LIST_UPDATE", "TRADE_SKILL_UPDATE", "PLAYER_REGEN_ENABLED", "PLAYER_LEVEL_UP", "PLAYER_ENTERING_WORLD", "ENCOUNTER_END", "CHAT_MSG_LOOT" }) do
  pcall(f.RegisterEvent, f, e)
end

SLASH_BTSCRIBE1 = "/scribe"
SlashCmdList.BTSCRIBE = function(arg)
  if not db then return end
  arg = (arg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  if arg == "quiet" or arg == "loud" then
    db.quiet = arg == "quiet"
    print(TAG .. (db.quiet and "won't mention what it notes. /scribe loud to turn the messages back on." or "will mention boss kills and good loot as it notes them."))
    return
  end
  local n, seen, today, profs = 0, 0, dayOf(now()), 0
  for _, m in pairs(db.members) do
    if not m.gone then n = n + 1 end
    if m.days and m.days[today] then seen = seen + 1 end
  end
  for _, p in pairs(db.recipes[UnitName("player")] or {}) do profs = profs + 1 end
  local kills, runs, loot, recent = 0, 0, 0, {}
  for _, k in ipairs(db.kills) do if dayOf(k.t) == today then kills = kills + 1; recent[#recent + 1] = k.boss end end
  for k in pairs(db.runs) do if k:sub(1, 10) == today then runs = runs + 1 end end
  for _, l in ipairs(db.loot) do if dayOf(l.t) == today then loot = loot + 1 end end
  print((TAG .. "%d guildies on the list, %d seen today, %d of your professions noted."):format(n, seen, profs))
  local zt, zn = {}, 0
  for zone, who in pairs(db.zones[today] or {}) do
    local s = 0
    for _, mins in pairs(who) do s = s + mins end
    zt[#zt + 1] = { zone, s }; zn = zn + 1
  end
  table.sort(zt, function(a, b) return a[2] > b[2] end)
  if zn > 0 then
    local top = {}
    for i = 1, math.min(3, #zt) do top[#top + 1] = ("%s %s"):format(zt[i][1], zt[i][2] >= 60 and (math.floor(zt[i][2] / 6 + 0.5) / 10 .. "h") or (math.floor(zt[i][2] + 0.5) .. "m")) end
    print("  Busiest zones today: " .. table.concat(top, ", ") .. ".")
  end
  print(("  Today: %d %s, %d %s, %d good %s."):format(runs, runs == 1 and "dungeon" or "dungeons", kills, kills == 1 and "boss" or "bosses", loot, loot == 1 and "drop" or "drops"))
  if #recent > 0 then
    local last = {}
    for i = math.max(1, #recent - 4), #recent do last[#last + 1] = recent[i] end
    print("  Latest bosses: " .. table.concat(last, ", ") .. ".")
  end
  print(("  %d %s and %d %s waiting in the file. /reload or log out, then upload it on the site. %s"):format(#db.kills, #db.kills == 1 and "boss" or "bosses",
    #db.loot, #db.loot == 1 and "drop" or "drops", db.quiet and "(/scribe loud for kill messages)" or "(/scribe quiet to hush the kill messages)"))
end
