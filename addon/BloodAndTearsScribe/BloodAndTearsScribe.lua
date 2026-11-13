-- Blood and Tears Scribe
-- While you play, this reads the in-game guild list every five minutes and notes, for each member: their level, rank,
-- when they were last online, which days they were on, and the last zone they were seen in. It also notes how many
-- guildies are online each hour, joins and leaves, who was in your raid group inside a raid, and the
-- recipes your own characters know (when you open a profession window).
--
-- Everything is kept in BloodAndTearsScribeDB. The game saves it to
--   World of Warcraft\_forever_\WTF\Account\<ACCOUNT>\SavedVariables\BloodAndTearsScribe.lua
-- when you log out or type /reload. Upload THAT file on the site (Roster > Details > Upload the scribe file),
-- not this one: this is the addon itself. The notes file starts with "BloodAndTearsScribeDB = {".
-- The addon never sends anything anywhere, reads nothing during combat and draws nothing on screen. /scribe shows a summary.

local ADDON = ...
local VERSION = 1
local DAYS_KEPT = 60          -- days of "seen" days kept per member
local HOURS_KEPT = 42         -- days of hourly online counts kept
local EVENTS_KEPT = 200       -- joins and leaves
local RAIDS_KEPT = 60
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
end

local function note(who, what)
  local e = { t = now(), who = who, what = what }
  table.insert(db.events, e)
  while #db.events > EVENTS_KEPT do table.remove(db.events, 1) end
end

local function prune()
  local dayCut, hourCut = dayOf(now() - DAYS_KEPT * 86400), hourOf(now() - HOURS_KEPT * 86400)
  for _, m in pairs(db.members) do
    if m.days then for d in pairs(m.days) do if d < dayCut then m.days[d] = nil end end end
  end
  for h in pairs(db.hours) do if h < hourCut then db.hours[h] = nil end end
  local keys = {}
  for k in pairs(db.raids) do keys[#keys + 1] = k end
  table.sort(keys)
  for i = 1, #keys - RAIDS_KEPT do db.raids[keys[i]] = nil end
end

local function askRoster()
  if not IsInGuild() then return end
  if C_GuildInfo and C_GuildInfo.GuildRoster then C_GuildInfo.GuildRoster() elseif GuildRoster then GuildRoster() end
end

local function readRoster()
  if not db or not IsInGuild() or InCombatLockdown() then return end
  local n = GetNumGuildMembers() or 0
  if n == 0 then return end
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
      m.level, m.class, m.rank = level, classFile, rankName
      m.gone = nil
      if isOnline then
        online = online + 1
        m.last = t
        m.zone = zone
        m.days[today] = true
      elseif GetGuildRosterLastOnline then
        local y, mo, d, h = GetGuildRosterLastOnline(i)
        if y then
          local last = t - (((y or 0) * 365 + (mo or 0) * 30 + (d or 0)) * 86400 + (h or 0) * 3600)
          -- The game only gives whole hours, so keep whichever is more recent.
          if not m.last or last > m.last + 3600 then m.last = last end
          if (y or 0) == 0 and (mo or 0) == 0 and (d or 0) == 0 then m.days[dayOf(last)] = true end
        end
      end
    end
  end
  -- Anyone no longer on the list is kept but marked as gone, so the site can tell leavers from quiet players.
  for name, m in pairs(db.members) do if not present[name] then m.gone = true end end
  local hk = hourOf(t)
  if (db.hours[hk] or 0) < online then db.hours[hk] = online end
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

-- "X has joined the guild." and friends, using the game's own wording so it works in any language.
local function pattern(s)
  if not s then return nil end
  local p = s:gsub("([%.%(%)%-%+%*%?%[%]%^%$])", "%%%1"):gsub("%%s", "(.+)")
  return "^" .. p .. "$"
end
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

f:SetScript("OnEvent", function(_, event, a1)
  if event == "ADDON_LOADED" and a1 == ADDON then
    init()
  elseif event == "PLAYER_LOGIN" then
    askRoster()
    -- The guild list only refreshes when asked: ask every five minutes.
    C_Timer.NewTicker(300, askRoster)
  elseif event == "GUILD_ROSTER_UPDATE" then
    readRoster()
  elseif event == "GROUP_ROSTER_UPDATE" or event == "ZONE_CHANGED_NEW_AREA" then
    readRaid()
  elseif event == "CHAT_MSG_SYSTEM" then
    system(a1)
  elseif event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_LIST_UPDATE" or event == "TRADE_SKILL_UPDATE" then
    readRecipes()
  elseif event == "PLAYER_REGEN_ENABLED" then
    askRoster()
  end
end)
for _, e in ipairs({ "ADDON_LOADED", "PLAYER_LOGIN", "GUILD_ROSTER_UPDATE", "GROUP_ROSTER_UPDATE", "ZONE_CHANGED_NEW_AREA",
  "CHAT_MSG_SYSTEM", "TRADE_SKILL_SHOW", "TRADE_SKILL_LIST_UPDATE", "TRADE_SKILL_UPDATE", "PLAYER_REGEN_ENABLED" }) do
  pcall(f.RegisterEvent, f, e)
end

SLASH_BTSCRIBE1 = "/scribe"
SlashCmdList.BTSCRIBE = function()
  if not db then return end
  local n, seen, today, profs = 0, 0, dayOf(now()), 0
  for _, m in pairs(db.members) do
    if not m.gone then n = n + 1 end
    if m.days and m.days[today] then seen = seen + 1 end
  end
  for _, p in pairs(db.recipes[UnitName("player")] or {}) do profs = profs + 1 end
  print(("|cffe0a862Blood and Tears Scribe|r: %d guildies on the list, %d seen today, %d of your professions noted. /reload or log out, then upload the file on the site."):format(n, seen, profs))
end
