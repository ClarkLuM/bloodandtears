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
-- The addon never sends anything anywhere. From 0.8.0 it keeps out of your chat: a small window (the gingerbread button
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
  if db.ui.pip == nil then db.ui.pip = true end
  if db.ui.summary == nil then db.ui.summary = true end
  db.quiet = nil
end

-- Who's online right now, from the latest guild list read (not saved).
local onlineNow = {}

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
  local id = tonumber(link:match("item:(%d+)"))
  local name = link:match("%[(.-)%]")
  local col = link:match("|c%x%x(%x%x%x%x%x%x)")
  local q = col and QCOL[col:lower()]
  if not q and GetItemInfo then q = select(3, GetItemInfo(link)) end
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
    if name and kind ~= "header" then names[#names + 1] = name end
  end
  if #names == 0 then return end
  table.sort(names)
  db.recipes[me] = db.recipes[me] or {}
  db.recipes[me][prof] = { at = now(), list = names }
  refresh()
end

local ui = {}   -- the window, the minimap button and the session summary fill this in below
f:SetScript("OnEvent", function(_, event, a1, a2, a3, a4, a5)
  if event == "ADDON_LOADED" and a1 == ADDON then
    init()
  elseif event == "PLAYER_LOGIN" then
    askRoster()
    -- The guild list only refreshes when asked: ask every five minutes.
    C_Timer.NewTicker(300, askRoster)
    if ui.login then pcall(ui.login) end
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
  elseif event == "LOGOUT_CANCEL" then
    if ui.logoutCancelled then pcall(ui.logoutCancelled) end
  end
end)
for _, e in ipairs({ "ADDON_LOADED", "PLAYER_LOGIN", "GUILD_ROSTER_UPDATE", "GROUP_ROSTER_UPDATE", "ZONE_CHANGED_NEW_AREA",
  "CHAT_MSG_SYSTEM", "TRADE_SKILL_SHOW", "TRADE_SKILL_LIST_UPDATE", "TRADE_SKILL_UPDATE", "PLAYER_REGEN_ENABLED", "PLAYER_LEVEL_UP", "PLAYER_ENTERING_WORLD", "ENCOUNTER_END", "CHAT_MSG_LOOT",
  "PLAYER_CAMPING", "PLAYER_QUITING", "LOGOUT_CANCEL", "CRAFT_SHOW", "CRAFT_UPDATE", "SKILL_LINES_CHANGED" }) do
  pcall(f.RegisterEvent, f, e)
end


---------------------------------------------------------------------------------------------------------------------
-- The window: a minimap button opens it; three tabs (Today, This week, Scribe). Built in code with the game's own
-- fonts and plain coloured textures, so it needs no other files except the gingerbread logo (logo.tga).
---------------------------------------------------------------------------------------------------------------------
local LOGO = "Interface\\AddOns\\" .. (ADDON or "BloodAndTearsScribe") .. "\\logo"
local GOLD, DIM, INK = "|cfff0c35a", "|cffa8957d", "|cffe9dcc8"
local QHEX = { [0] = "|cff9d9d9d", "|cffffffff", "|cff1eff00", "|cff0070dd", "|cffa335ee", "|cffff8000", "|cffe6cc80" }
local W = 400
-- Small pictures inside text (the game's fonts have no symbols): a sword for a run, a bag for a drop, light for a ding.
local IC_RUN, IC_LOOT, IC_DING = "|TInterface\\Icons\\INV_Sword_04:12:12|t", "|TInterface\\Icons\\INV_Misc_Bag_08:12:12|t", "|TInterface\\Icons\\Spell_Holy_InnerFire:12:12|t"
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
local function memberName(n) local m = guildie(n); return nameIn(first(n), m and m.class) end
local function itemText(l) return (QHEX[l.q or 2] or QHEX[2]) .. "[" .. (l.name or "?") .. "]|r" end
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
    if dayOf(l.t) == today and (l.q or 0) >= 3 and (not since or l.t > since) then out[#out + 1] = { kind = "loot", t = l.t, l = l } end
  end
  for name, m in pairs(db.members) do
    for lv, t in pairs(m.ups or {}) do
      if dayOf(t) == today and (not since or t > since) and lv == m.level then out[#out + 1] = { kind = "ding", t = t, name = name, class = m.class, level = lv } end
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
  return fs
end
local function panel(name, w, h)
  local fr = CreateFrame("Frame", name, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
  fr:SetSize(w, h)
  fr:SetFrameStrata("DIALOG")
  if fr.SetBackdrop then
    fr:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
    fr:SetBackdropColor(0.10, 0.06, 0.05, 0.96)
    fr:SetBackdropBorderColor(0.55, 0.38, 0.17, 1)
  else
    local bg = tex(fr, "BACKGROUND", 0.10, 0.06, 0.05, 0.96); bg:SetAllPoints()
  end
  -- The crimson header with the gingerbread and a gold title
  local hd = tex(fr, "BORDER", 0.33, 0.06, 0.11, 1)
  hd:SetPoint("TOPLEFT", 4, -4); hd:SetPoint("TOPRIGHT", -4, -4); hd:SetHeight(44)
  local line = tex(fr, "BORDER", 0.55, 0.38, 0.17, 1)
  line:SetPoint("TOPLEFT", hd, "BOTTOMLEFT"); line:SetPoint("TOPRIGHT", hd, "BOTTOMRIGHT"); line:SetHeight(1)
  local logo = fr:CreateTexture(nil, "ARTWORK"); logo:SetTexture(LOGO); logo:SetSize(32, 32); logo:SetPoint("TOPLEFT", 12, -10)
  fr.title = text(fr, "GameFontNormalLarge"); fr.title:SetPoint("TOPLEFT", logo, "TOPRIGHT", 8, -1)
  fr.sub = text(fr, "GameFontDisableSmall"); fr.sub:SetPoint("TOPLEFT", fr.title, "BOTTOMLEFT", 0, -2)
  local x = CreateFrame("Button", nil, fr, "UIPanelCloseButton"); x:SetPoint("TOPRIGHT", 0, 0)
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
    r:SetSize(W - 28, 18)
    r:SetPoint("TOPLEFT", 14, top - (i - 1) * 18)
    r.mark = text(r, "GameFontNormalSmall"); r.mark:SetPoint("LEFT", 0, 0); r.mark:SetWidth(14)
    r.right = text(r, "GameFontDisableSmall", "RIGHT"); r.right:SetPoint("RIGHT", 0, 0)
    r.main = text(r, "GameFontHighlightSmall"); r.main:SetPoint("LEFT", 16, 0); r.main:SetPoint("RIGHT", r.right, "LEFT", -6, 0)
    r.bar = tex(r, "BACKGROUND", 0.10, 0.06, 0.05, 1); r.bar:SetPoint("BOTTOMLEFT", 16, -1); r.bar:SetPoint("BOTTOMRIGHT", 0, -1); r.bar:SetHeight(3)
    r.fill = tex(r, "ARTWORK", 0.94, 0.76, 0.35, 1); r.fill:SetPoint("TOPLEFT", r.bar); r.fill:SetPoint("BOTTOMLEFT", r.bar); r.fill:SetWidth(1)
    r.bar:Hide(); r.fill:Hide()
    list[i] = r
  end
  return list
end
local function setRow(r, mark, main, right, pct)
  r.mark:SetText(mark or ""); r.main:SetText(main or ""); r.right:SetText(right or "")
  if pct then r.bar:Show(); r.fill:Show(); r.fill:SetWidth(math.max(1, (W - 44) * math.min(1, pct))) else r.bar:Hide(); r.fill:Hide() end
  r:Show()
end

-------------------------------------------------------------------- the main window
local win = panel("BloodAndTearsScribeWindow", W, 470)
win:SetPoint("CENTER", 0, 60)
win.title:SetText("Blood and Tears")
win.sub:SetText("Guild scribe " .. ((GetAddOnMetadata or (C_AddOns and C_AddOns.GetAddOnMetadata) or function() return "" end)(ADDON, "Version") or ""))
local pages, tabs, current = {}, {}, "today"
local function page(key)
  local p = CreateFrame("Frame", nil, win); p:SetPoint("TOPLEFT", 4, -84); p:SetPoint("BOTTOMRIGHT", -4, 4); p:Hide()
  pages[key] = p; return p
end
local function label(p, s, y) local l = text(p, "GameFontNormalSmall"); l:SetPoint("TOPLEFT", 14, y); l:SetText(s); return l end

-- Today
local pToday = page("today")
local onlineLabel = label(pToday, "ONLINE NOW", -6)
local onlineRows = rows(pToday, 7, -22)
local todayLabel = label(pToday, "TODAY", -156)
local feedRows = rows(pToday, 9, -172)
local todayFoot = text(pToday, "GameFontDisableSmall"); todayFoot:SetPoint("BOTTOMLEFT", 14, 12); todayFoot:SetWidth(W - 28)
if todayFoot.SetWordWrap then todayFoot:SetWordWrap(true) end
todayFoot:SetJustifyV("BOTTOM"); todayFoot:SetHeight(30)

-- This week
local pWeek = page("week")
label(pWeek, "BUSIEST ZONES  ·  THIS WEEK", -6)
local zoneRows = rows(pWeek, 5, -24)
for _, r in ipairs(zoneRows) do r:SetHeight(24) end
for i, r in ipairs(zoneRows) do r:ClearAllPoints(); r:SetPoint("TOPLEFT", 14, -24 - (i - 1) * 24) end
label(pWeek, "WHEN THE GUILD PLAYS  ·  PERTH TIME", -152)
local grid, CELL_W, CELL_H = {}, 13, 11
local dayNames = { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" }
for d = 0, 6 do
  local l = text(pWeek, "GameFontDisableSmall"); l:SetPoint("TOPLEFT", 14, -172 - d * (CELL_H + 2)); l:SetText(dayNames[d + 1])
  grid[d] = {}
  for h = 0, 23 do
    local c = tex(pWeek, "ARTWORK", 0.13, 0.08, 0.06, 1)
    c:SetSize(CELL_W, CELL_H); c:SetPoint("TOPLEFT", 50 + h * (CELL_W + 1), -172 - d * (CELL_H + 2))
    grid[d][h] = c
  end
end
for _, h in ipairs({ 0, 6, 12, 18 }) do
  local l = text(pWeek, "GameFontDisableSmall"); l:SetPoint("BOTTOMLEFT", grid[0][h], "TOPLEFT", 0, 2)
  l:SetText(h == 0 and "12am" or h == 12 and "12pm" or (h % 12) .. (h < 12 and "am" or "pm"))
end
local weekFoot = text(pWeek, "GameFontHighlightSmall"); weekFoot:SetPoint("TOPLEFT", 14, -272); weekFoot:SetWidth(W - 28)
local weekNote = text(pWeek, "GameFontDisableSmall"); weekNote:SetPoint("TOPLEFT", 14, -290); weekNote:SetWidth(W - 28)
weekNote:SetText("From this scribe's own notes. The site has the whole picture.")
local SHADES = { { 0.29, 0.10, 0.12 }, { 0.43, 0.10, 0.15 }, { 0.64, 0.09, 0.18 }, { 0.83, 0.16, 0.27 }, { 0.94, 0.34, 0.42 } }

-- Scribe
local pScribe = page("scribe")
label(pScribe, "IN THE NOTES FILE", -6)
local big = {}
for i = 1, 3 do
  local n = text(pScribe, "GameFontNormalHuge"); n:SetPoint("TOPLEFT", 14 + (i - 1) * 126, -26)
  local l = text(pScribe, "GameFontDisableSmall"); l:SetPoint("TOPLEFT", n, "BOTTOMLEFT", 0, -2)
  big[i] = { n = n, l = l }
end
local scribeInfo = text(pScribe, "GameFontHighlightSmall"); scribeInfo:SetPoint("TOPLEFT", 14, -84); scribeInfo:SetWidth(W - 28)
if scribeInfo.SetWordWrap then scribeInfo:SetWordWrap(true) end
scribeInfo:SetHeight(48); scribeInfo:SetJustifyV("TOP")
label(pScribe, "SETTINGS", -146)
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
upload:SetJustifyV("BOTTOM"); upload:SetHeight(78)
upload:SetText("Your notes file is World of Warcraft\\_forever_\\WTF\\Account\\(your account)\\SavedVariables\\BloodAndTearsScribe.lua. "
  .. "Type /reload (or log out) to save it, then on the site open Roster, Details, Upload the scribe file. In Chrome or Edge the site remembers the file after the first time.")

-- Recipes: your professions, when each was last read, and a button that opens its window (the game only shares a
-- recipe list while that window is open, and only lets an addon open it from a click, through a secure button).
local pRecipes = page("recipes")
local recLabel = label(pRecipes, "YOUR PROFESSIONS", -6)
local CRAFTS = { Alchemy = "Alchemy", Blacksmithing = "Blacksmithing", Cooking = "Cooking", Enchanting = "Enchanting", Engineering = "Engineering",
  ["First Aid"] = "First Aid", Leatherworking = "Leatherworking", Tailoring = "Tailoring", Mining = "Smelting" }
local recRows = {}
for i = 1, 5 do
  local r = CreateFrame("Frame", nil, pRecipes); r:SetSize(W - 28, 34); r:SetPoint("TOPLEFT", 14, -26 - (i - 1) * 38)
  r.name = text(r, "GameFontHighlight"); r.name:SetPoint("TOPLEFT", 0, -2)
  r.info = text(r, "GameFontDisableSmall"); r.info:SetPoint("TOPLEFT", r.name, "BOTTOMLEFT", 0, -3); r.info:SetWidth(W - 130)
  local ok, b = pcall(CreateFrame, "Button", nil, r, "SecureActionButtonTemplate,UIPanelButtonTemplate")
  if ok and b then
    b:SetSize(76, 22); b:SetPoint("RIGHT", 0, 0); b:SetText("Read")
    if b.RegisterForClicks then b:RegisterForClicks("AnyUp", "AnyDown") end
    b:SetAttribute("type", "spell")
    r.btn = b
  end
  r:Hide(); recRows[i] = r
end
local recEmpty = text(pRecipes, "GameFontDisableSmall"); recEmpty:SetPoint("TOPLEFT", 14, -26); recEmpty:SetWidth(W - 28)
local recFoot = text(pRecipes, "GameFontDisableSmall"); recFoot:SetPoint("BOTTOMLEFT", 14, 12); recFoot:SetWidth(W - 28)
if recFoot.SetWordWrap then recFoot:SetWordWrap(true) end
recFoot:SetJustifyV("BOTTOM"); recFoot:SetHeight(92)
recFoot:SetText(GOLD .. "How recipes get to the site|r\n"
  .. INK .. "1.|r Click Read: the profession's window opens and the scribe notes every recipe in it.\n"
  .. INK .. "2.|r Close the window. Do it once per profession, and again after learning new ones (this tab says when).\n"
  .. INK .. "3.|r Type /reload or log out to save, then upload the file on the site.\n"
  .. "The game only shares a recipe list while its window is open, so the scribe can't read them by itself.")
local myProfs = {}
-- Your professions from the skill list (the game's own names; English clients).
local function readSkills()
  wipe(myProfs)
  if not GetNumSkillLines then return end
  for i = 1, GetNumSkillLines() do
    local name, header, _, rank, _, _, max = GetSkillLineInfo(i)
    if name and not header and CRAFTS[name] then myProfs[#myProfs + 1] = { name = name, rank = rank, max = max } end
  end
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
local function fillRecipes()
  local me = UnitName("player") or "?"
  recLabel:SetText("YOUR PROFESSIONS  ·  " .. me:upper())
  if #myProfs == 0 then readSkills() end
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

-- Tabs along the top
local TABS = { { "today", "Today" }, { "week", "This week" }, { "recipes", "Recipes" }, { "scribe", "Scribe" } }
local function show(key)
  current = key
  for k, p in pairs(pages) do if k == key then p:Show() else p:Hide() end end
  local nr = ui.needReading and ui.needReading() or 0
  for _, t in ipairs(tabs) do
    if t.key == "recipes" then t:SetText(nr > 0 and ("Recipes (" .. nr .. ")") or "Recipes") end
    if t.key == key then t:LockHighlight(); t:GetFontString():SetTextColor(1, 0.82, 0.35) else t:UnlockHighlight(); t:GetFontString():SetTextColor(0.75, 0.68, 0.6) end
  end
  refresh()
end
for i, t in ipairs(TABS) do
  local b = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
  local tw = (W - 24 - 3 * 4) / 4
  b:SetSize(tw, 24); b:SetPoint("TOPLEFT", 12 + (i - 1) * (tw + 4), -54)
  b:SetText(t[2]); b.key = t[1]
  b:SetScript("OnClick", function() show(t[1]) end)
  tabs[i] = b
end

-------------------------------------------------------------------- filling the tabs
local pip   -- the minimap count, set below
local function fillToday()
  table.sort(onlineNow, function(a, b) return (a.zone or "") < (b.zone or "") or ((a.zone or "") == (b.zone or "") and a.name < b.name) end)
  onlineLabel:SetText("ONLINE NOW  ·  " .. #onlineNow)
  for i, r in ipairs(onlineRows) do
    local o = onlineNow[i]
    if i == #onlineRows and #onlineNow > #onlineRows then setRow(r, "", DIM .. "and " .. (#onlineNow - #onlineRows + 1) .. " more|r", "")
    elseif o then setRow(r, dot(o.class), nameIn(o.name, o.class) .. "  " .. DIM .. (o.level or "") .. "|r", o.zone or "")
    else r:Hide() end
  end
  if #onlineNow == 0 then setRow(onlineRows[1], "", DIM .. "Nobody else is on right now.|r", "") end
  local feed = todayFeed()
  todayLabel:SetText("TODAY")
  for i, r in ipairs(feedRows) do
    local e = feed[i]
    if not e then r:Hide()
    elseif e.kind == "run" then
      local g = guildiesIn(e.who)
      setRow(r, IC_RUN, INK .. e.zone .. "|r" .. DIM .. "  ·  " .. e.n .. (e.n == 1 and " boss" or " bosses") .. (g > 1 and (", with " .. (g - 1) .. (g == 2 and " guildie" or " guildies")) or "") .. "|r", clock(e.t))
    elseif e.kind == "loot" then
      setRow(r, IC_LOOT, memberName(e.l.who) .. " looted " .. itemText(e.l), clock(e.t))
    else
      setRow(r, IC_DING, nameIn(first(e.name), e.class) .. " reached level " .. e.level, clock(e.t))
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
  big[3].n:SetText(#db.loot); big[3].l:SetText(#db.loot == 1 and "good drop" or "good drops")
  local n = 0; for _, m in pairs(db.members) do if not m.gone then n = n + 1 end end
  scribeInfo:SetText(n .. " guildies on the list, " .. #db.kills .. " boss kills noted" .. (firstDay and (", notes back to " .. firstDay) or "") .. ". The file keeps a rolling few weeks, so uploading every few days loses nothing.")
  for k, c in pairs(checks) do c:SetChecked(db.ui[k] and true or false) end
end
refresh = function()
  if not db then return end
  if pip then pip() end
  if not win:IsShown() then return end
  if current == "today" then fillToday() elseif current == "week" then fillWeek() elseif current == "recipes" then fillRecipes() else fillScribe() end
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
local keep = CreateFrame("Button", nil, sum, "UIPanelButtonTemplate"); keep:SetSize(120, 24); keep:SetPoint("BOTTOMRIGHT", -14, 12); keep:SetText("Keep playing")
local close = CreateFrame("Button", nil, sum, "UIPanelButtonTemplate"); close:SetSize(90, 24); close:SetPoint("RIGHT", keep, "LEFT", -6, 0); close:SetText("Close")
keep:SetScript("OnClick", function() if CancelLogout then pcall(CancelLogout) end sum:Hide() end)
close:SetScript("OnClick", function() sum:Hide() end)

local function fillSummary(leaving)
  if not sess then return end
  local me, t = UnitName("player"), now()
  local lv = UnitLevel("player")
  sum.title:SetText(me .. "'s session")
  sum.sub:SetText("Level " .. (sess.level or lv) .. (lv ~= sess.level and (" to " .. lv) or "") .. "  ·  " .. clock(sess.t) .. " to " .. clock(t))
  keep:SetShown(leaving and true or false)
  local bosses, drops = {}, {}
  for _, k in ipairs(db.kills) do if k.t >= sess.t then bosses[#bosses + 1] = k end end
  for _, l in ipairs(db.loot) do if l.t >= sess.t and l.who == short(me) then drops[#drops + 1] = l end end
  local vals = { { (lv - (sess.level or lv) >= 0 and "+" or "") .. (lv - (sess.level or lv)), "LEVELS" }, { dur(t - sess.t), "PLAYED" }, { #bosses, "BOSSES" }, { #drops, "DROPS" } }
  for i, v in ipairs(vals) do sumStats[i].n:SetText(v[1]); sumStats[i].l:SetText(v[2]) end
  local out = {}
  local zl = {}
  for z, m in pairs(sess.zones) do zl[#zl + 1] = { z, m } end
  table.sort(zl, function(a, b) return a[2] > b[2] end)
  if #zl > 0 then
    out[#out + 1] = GOLD .. "WHERE YOU WENT|r"
    local bits = {}
    for i = 1, math.min(4, #zl) do bits[#bits + 1] = INK .. zl[i][1] .. "|r " .. DIM .. hrs(zl[i][2]) .. "|r" end
    out[#out + 1] = table.concat(bits, "   ")
  end
  if #bosses > 0 then
    out[#out + 1] = GOLD .. "DUNGEONS|r"
    local by, order = {}, {}
    for _, k in ipairs(bosses) do local z = k.zone or "?"; if not by[z] then by[z] = {}; order[#order + 1] = z end; table.insert(by[z], k.boss) end
    for i = 1, math.min(3, #order) do local z = order[i]; out[#out + 1] = INK .. z .. "|r" .. DIM .. "  ·  " .. table.concat(by[z], ", ") .. "|r" end
  end
  if #drops > 0 then
    out[#out + 1] = GOLD .. "DROPS|r"
    local bits = {}
    for i = 1, math.min(6, #drops) do bits[#bits + 1] = itemText(drops[i]) end
    out[#out + 1] = table.concat(bits, "  ")
    if #drops > 6 then out[#out + 1] = DIM .. "and " .. (#drops - 6) .. " more|r" end
  end
  local wl = {}
  for n, m in pairs(sess.with) do wl[#wl + 1] = { n, m } end
  table.sort(wl, function(a, b) return a[2] > b[2] end)
  if #wl > 0 then
    out[#out + 1] = GOLD .. "WITH GUILDIES|r"
    local bits = {}
    for i = 1, math.min(5, #wl) do local m = db.members[wl[i][1]]; bits[#bits + 1] = nameIn(first(wl[i][1]), m and m.class) .. DIM .. " " .. hrs(wl[i][2]) .. "|r" end
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
  if arg == "week" then show("week") elseif arg == "recipes" then show("recipes") elseif arg == "files" or arg == "file" then show("scribe") end
  if win:IsShown() and arg == "" then win:Hide() else win:Show() end
end
