-- Blood and Tears Scribe: the Loot tab, the Alts page and the right-click menu on guildies.
-- Built from the parts BloodAndTearsScribe.lua lends out (NS.k), so this file adds no names to that one.
local _, NS = ...
local k = NS and NS.k
if not k then return end
local ui, win, W, PERTH, GOLD, DIM, INK, IC_LOOT = k.ui, k.win, k.W, k.PERTH, k.GOLD, k.DIM, k.INK, k.IC_LOOT
local page, label, rows, setRow, text, tex, wowButton = k.page, k.label, k.rows, k.setRow, k.text, k.tex, k.wowButton
local itemText, memberName, guildie, short, nameIn, fullName, dot, now = k.itemText, k.memberName, k.guildie, k.short, k.nameIn, k.fullName, k.dot, k.now
local DB, refresh = k.db, k.refresh

-- Loot history: every good drop guildies got in dungeons (the notes keep the last 300), newest first, with the boss
-- it came from when a kill was noted just before it.
do
  local p = page("loot")
  local list = rows(p, 16, -36)
  -- Search by item or by who got it.
  local find = CreateFrame("EditBox", nil, p, "InputBoxTemplate")
  find:SetSize(W - 28 - 6 - 158, 22); find:SetPoint("TOPLEFT", 20, -6); find:SetAutoFocus(false); find:SetMaxLetters(40)
  local findHint = text(p, "GameFontDisableSmall"); findHint:SetPoint("LEFT", find, "LEFT", 2, 0); findHint:SetText("Search by item or guildie")
  find:SetScript("OnEscapePressed", function(self) self:SetText(""); self:ClearFocus() end)
  find:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
  find:SetScript("OnEditFocusGained", function() findHint:Hide() end)
  find:SetScript("OnEditFocusLost", function(self) if self:GetText() == "" then findHint:Show() end end)
  find:SetScript("OnTextChanged", function() ui.lootOff = 0; refresh() end)
  -- Filter by quality: a drop-down.
  local QUAL = { { 0, "All" }, { 2, "Uncommon" }, { 3, "Rare" }, { 4, "Epic" }, { 5, "Legendary" } }
  local qbtn = ui.dropdown(p, 150, "Quality: ", QUAL, function(k) DB().ui.lootQ = k; ui.lootOff = 0; refresh() end)
  qbtn:SetPoint("TOPRIGHT", -14, -6)
  local foot = ui.foot(p)
  p:EnableMouseWheel(true)
  p:SetScript("OnMouseWheel", function(_, d) ui.lootOff = math.max(0, (ui.lootOff or 0) - d * 3); refresh() end)
  ui.fillLoot = function()
    local me = short(UnitName("player"))
    local items, want = {}, tonumber(DB().ui.lootQ) or 0
    local q = (find:GetText() or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    qbtn:set(want)
    for i = #DB().loot, 1, -1 do
      local l = DB().loot[i]
      if (l.who == me or guildie(l.who)) and (want == 0 or (l.q or 2) == want) then
        local _, full = guildie(l.who)
        if q == "" or (l.name or ""):lower():find(q, 1, true) or (full or l.who or ""):lower():find(q, 1, true) then items[#items + 1] = l end
      end
    end
    local off = math.max(0, math.min(ui.lootOff or 0, #items - #list)); ui.lootOff = off
    for i, r in ipairs(list) do
      local l = items[i + off]
      if l then
        local boss
        for _, k in ipairs(DB().kills) do if k.zone == l.zone and l.t >= k.t and l.t - k.t <= 240 then boss = k.boss end end
        setRow(r, IC_LOOT, itemText(l) .. "  " .. memberName(l.who), DIM .. (boss or l.zone or "") .. "  ·  " .. date("!%d %b", l.t + PERTH) .. "|r")
        r.item = l.id; r.itemName = l.name
      else r:Hide() end
    end
    if #items == 0 then setRow(list[1], "", DIM .. ((want == 0 and q == "") and "No drops noted yet. Good loot guildies get in dungeons shows here." or "Nothing matches.") .. "|r", "") end
    foot:SetText(#items == 0 and "" or ((#items > #list and ((off + 1) .. "–" .. math.min(#items, off + #list) .. " of " .. #items .. "  ·  scroll") or (#items .. (#items == 1 and " drop" or " drops"))) .. "  ·  hover for the tooltip, shift-click to link"))
  end
end
-- Your characters (the Alts button in the header): level, professions, gold and time played for every character you
-- have logged in on with the scribe running. Kept in the notes file; the site doesn't read it and it isn't shared.
do
  local p = page("alts")
  local head = label(p, "Your characters", -11)
  local list = {}
  for i = 1, 9 do
    local r = CreateFrame("Frame", nil, p); r:SetSize(W - 28, 34); r:SetPoint("TOPLEFT", 14, -36 - (i - 1) * 36)
    r.sep = tex(r, "BACKGROUND", 1, 1, 1, 0.045); r.sep:SetPoint("BOTTOMLEFT", 0, -2); r.sep:SetPoint("BOTTOMRIGHT", 0, -2); r.sep:SetHeight(1)
    r.right = text(r, "GameFontHighlightSmall", "RIGHT"); r.right:SetPoint("TOPRIGHT", 0, -2)
    r.name = text(r, "GameFontHighlight"); r.name:SetPoint("TOPLEFT", 0, -2); r.name:SetPoint("RIGHT", r.right, "LEFT", -6, 0)
    r.right2 = text(r, "GameFontDisableSmall", "RIGHT"); r.right2:SetPoint("BOTTOMRIGHT", 0, 3)
    r.info = text(r, "GameFontDisableSmall"); r.info:SetPoint("BOTTOMLEFT", 0, 3); r.info:SetPoint("RIGHT", r.right2, "LEFT", -6, 0)
    r:Hide(); list[i] = r
  end
  local foot = ui.foot(p, { "Your characters", "A character shows here once you've logged in on it with the scribe running.", "Only you see this: the site doesn't read it and it isn't shared with other scribes." })
  local PROFS = { Alchemy = 1, Blacksmithing = 1, Cooking = 1, Enchanting = 1, Engineering = 1, ["First Aid"] = 1, Fishing = 1, Herbalism = 1,
    Leatherworking = 1, Mining = 1, Skinning = 1, Tailoring = 1 }
  local function coins(c)
    c = math.floor(tonumber(c) or 0)
    local g, sv = math.floor(c / 10000), math.floor(c / 100) % 100
    return GOLD .. g .. "g|r " .. INK .. sv .. "s|r"
  end
  local function played(sec)
    sec = tonumber(sec)
    if not sec then return "" end
    local d, h = math.floor(sec / 86400), math.floor(sec / 3600) % 24
    if d > 0 then return d .. "d " .. h .. "h played" end
    return h .. "h " .. (math.floor(sec / 60) % 60) .. "m played"
  end
  -- Note this character as it is now. Called at login, when your money changes, and each minute.
  ui.noteMe = function()
    local me = UnitName("player")
    if not DB() or not me then return end
    DB().alts = DB().alts or {}
    local a = DB().alts[me] or {}
    DB().alts[me] = a
    a.lv = UnitLevel("player"); a.class = select(2, UnitClass("player")); a.at = now()
    DB().ui.lastOn = now()
    if GetMoney then a.gold = GetMoney() end
    if GetRealZoneText then local z = GetRealZoneText(); if z and z ~= "" then a.zone = z end end
    if GetNumSkillLines then
      local profs, any = {}, false
      for i = 1, GetNumSkillLines() do
        local name, header, _, rank = GetSkillLineInfo(i)
        if name and not header and PROFS[name] then profs[name] = rank; any = true end
      end
      if any or not a.profs then a.profs = profs end
    end
  end
  -- Time played: asked once at login. The game answers in chat as well, so that line is held back just for this ask.
  ui.askPlayed = function()
    if not RequestTimePlayed then return end
    local orig = ChatFrame_DisplayTimePlayed
    if orig then
      ui.playedQuiet = true
      ChatFrame_DisplayTimePlayed = function(...) if ui.playedQuiet then ui.playedQuiet = nil; ChatFrame_DisplayTimePlayed = orig; return end return orig(...) end
      C_Timer.After(8, function() if ui.playedQuiet then ui.playedQuiet = nil; ChatFrame_DisplayTimePlayed = orig end end)
    end
    RequestTimePlayed()
  end
  ui.played = function(total)
    local me = UnitName("player")
    if not DB() or not me or not tonumber(total) then return end
    ui.noteMe()
    DB().alts[me].played = tonumber(total); DB().alts[me].playedAt = now()
    refresh()
  end
  ui.fillAlts = function()
    ui.noteMe()
    local me = UnitName("player")
    local names = {}
    for n in pairs(DB().alts or {}) do names[#names + 1] = n end
    table.sort(names, function(x, y)
      local ax, ay = DB().alts[x], DB().alts[y]
      if (ax.lv or 0) ~= (ay.lv or 0) then return (ax.lv or 0) > (ay.lv or 0) end
      return x < y
    end)
    local gold, secs = 0, 0
    for i, r in ipairs(list) do
      local n = names[i]
      local a = n and DB().alts[n]
      if a then
        local bits = {}
        local pn = {}
        for prof in pairs(a.profs or {}) do pn[#pn + 1] = prof end
        table.sort(pn)
        for _, prof in ipairs(pn) do bits[#bits + 1] = ui.profIcon(prof, 12) .. prof .. " " .. (a.profs[prof] or "") end
        -- This character's time keeps counting while you're on it.
        local sec = a.played and (a.played + (n == me and a.playedAt and (now() - a.playedAt) or 0)) or nil
        r.name:SetText(dot(a.class, 15) .. " " .. nameIn(fullName(n), a.class) .. "  " .. DIM .. (a.lv or "") .. "|r" .. (n == me and (DIM .. "  ·  playing now|r") or ""))
        r.right:SetText(a.gold and coins(a.gold) or "")
        r.info:SetText(#bits > 0 and table.concat(bits, "   ") or "No professions noted")
        r.right2:SetText(played(sec))
        r:Show()
      else r:Hide() end
    end
    for _, n in ipairs(names) do gold = gold + (DB().alts[n].gold or 0); secs = secs + (DB().alts[n].played or 0) end
    head:SetText("Your characters  ·  " .. #names)
    foot:SetText("All together: " .. coins(gold) .. DIM .. (secs > 0 and ("  ·  " .. played(secs)) or "") .. "|r" .. (#names > #list and ("  ·  showing the " .. #list .. " highest") or "") .. "  ·  only you see this")
  end
end
-- Right-click a guildie in the Online list: whisper or invite.
do
  local m = CreateFrame("Frame", "BloodAndTearsScribeMenu", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
  m:SetSize(124, 108); m:SetFrameStrata("TOOLTIP"); m:EnableMouse(true); m:SetClampedToScreen(true); m:Hide()
  if m.SetBackdrop then
    m:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
    m:SetBackdropColor(0.086, 0.063, 0.063, 0.96); m:SetBackdropBorderColor(0.36, 0.27, 0.25, 1)
  end
  local title = text(m, "GameFontNormalSmall", "CENTER"); title:SetPoint("TOP", 0, -9); title:SetWidth(108)
  local function item(s, y, fn)
    local b = wowButton(CreateFrame("Button", nil, m, "UIPanelButtonTemplate"), 104, 22, s); b:SetPoint("TOP", 0, y)
    b:SetScript("OnClick", function() m:Hide(); if fn and m.who then pcall(fn, m.who) end end)
  end
  item("Whisper", -26, function(n) if ChatFrame_SendTell then ChatFrame_SendTell(n) end end)
  item("Invite", -51, function(n) local f = (C_PartyInfo and C_PartyInfo.InviteUnit) or InviteUnit; if f then f(n) end end)
  item("Close", -76)
  if UISpecialFrames then table.insert(UISpecialFrames, "BloodAndTearsScribeMenu") end
  win:HookScript("OnHide", function() m:Hide() end)
  ui.menu = function(who)
    m.who = who; title:SetText(who)
    local x, y = GetCursorPosition()
    local sc = UIParent:GetEffectiveScale()
    m:ClearAllPoints(); m:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / sc + 4, y / sc + 4)
    m:Show()
  end
end

-- While you were away: a few seconds after you log in, if you'd been off for a while and anything happened, a small
-- panel lists it: guildies' level-ups (from the guild list), who joined or left, good drops and dungeon runs (those
-- only when a guildie with the scribe was there and shared them). Once per login; off with a tick box in Settings.
do
  local AWAY_MIN = 30 * 60        -- don't bother after a quick relog
  local p = k.panel("BloodAndTearsScribeAway", W, 300)
  p:SetPoint("CENTER", 0, 70)
  p.title:SetText("While you were away")
  local stats = {}
  for i = 1, 4 do
    local bw = (W - 24 - 18) / 4
    local box = tex(p, "BACKGROUND", 0.07, 0.04, 0.03, 1); box:SetSize(bw, 44); box:SetPoint("TOPLEFT", 12 + (i - 1) * (bw + 6), -58)
    local n = text(p, "GameFontNormalLarge", "CENTER"); n:SetPoint("TOP", box, "TOP", 0, -6); n:SetWidth(bw)
    local l = text(p, "GameFontDisableSmall", "CENTER"); l:SetPoint("BOTTOM", box, "BOTTOM", 0, 6); l:SetWidth(bw)
    stats[i] = { n = n, l = l }
  end
  local list = rows(p, 14, -112)
  local open = wowButton(CreateFrame("Button", nil, p, "UIPanelButtonTemplate"), 140, 22, "Open the Today tab"); open:SetPoint("BOTTOMRIGHT", -14, 12)
  open:SetScript("OnClick", function() p:Hide(); k.show("today"); win:Show() end)
  local foot = text(p, "GameFontDisableSmall"); foot:SetPoint("BOTTOMLEFT", 14, 16); foot:SetWidth(W - 180)
  foot:SetText("From the guild list and guildies' scribes.")
  local since, loginAt, before = nil, nil, nil

  local function plural(n, one, many) return n .. " " .. (n == 1 and one or many) end
  local function build()
    local db = DB()
    if not db or not since then return 0 end
    local mine = {}
    for n in pairs(db.mine or {}) do mine[n] = true end
    local lines, dings, joins, drops, runs = {}, {}, 0, 0, 0
    local function when(t) return (t and t < loginAt - 120) and k.clock(t) or "" end
    -- Level-ups: each guildie's highest new level. Ones the guild list only showed at login have no time.
    for name, m in pairs(db.members) do
      if not mine[k.first(name)] and not mine[name] then
        local top, tt
        for lv, t in pairs(m.ups or {}) do if t > since and (not top or lv > top) then top, tt = lv, t end end
        if top then dings[#dings + 1] = { t = tt, line = nameIn(name, m.class) .. DIM .. " reached |r" .. top .. k.altTag(name), right = when(tt) } end
      end
    end
    table.sort(dings, function(a, b) return a.t > b.t end)
    -- Joins and leaves: new names on the guild list since you were last on, and names that left it.
    local come, gone = {}, {}
    for name, m in pairs(db.members) do
      if before and not before.known[name] then come[#come + 1] = { name, m.class } end
      if before and m.gone and not before.gone[name] then gone[#gone + 1] = name end
    end
    for _, e in ipairs(db.events or {}) do if e.t > since and e.what == "joined" then local seen = false
      for _, c in ipairs(come) do if k.first(c[1]) == k.first(e.who) then seen = true end end
      if not seen then come[#come + 1] = { e.who } end end end
    joins = #come
    -- Good drops (rare and better) and runs, from shared notes.
    local loot = {}
    for i = #db.loot, 1, -1 do local l = db.loot[i]
      if l.t > since and (l.q or 0) >= 3 and (guildie(l.who)) and not mine[l.who] then loot[#loot + 1] = l end end
    drops = #loot
    local byZone, order = {}, {}
    for _, kl in ipairs(db.kills or {}) do if kl.t > since then
      local z = byZone[kl.zone or "?"]
      if not z then z = { zone = kl.zone or "?", n = 0, who = {}, t = kl.t }; byZone[z.zone] = z; order[#order + 1] = z end
      z.n = z.n + 1; if kl.t > z.t then z.t = kl.t end
      for n in pairs(kl.who or {}) do z.who[n] = true end
    end end
    runs = #order
    table.sort(order, function(a, b) return a.t > b.t end)
    if #dings + joins + #gone + drops + runs == 0 then return 0 end
    -- The lines, in groups, each short; the panel grows to fit (up to 14 lines).
    local function add(mark, main, right, item) lines[#lines + 1] = { mark, main, right or "", item } end
    for i = 1, math.min(5, #dings) do add(k.IC_DING, dings[i].line, dings[i].right) end
    if #dings > 5 then add("", DIM .. "and " .. (#dings - 5) .. " more level-ups|r") end
    for i = 1, math.min(3, drops) do local l = loot[i]; add(IC_LOOT, itemText(l) .. "  " .. memberName(l.who), l.zone or "", l) end
    if drops > 3 then add("", DIM .. "and " .. (drops - 3) .. " more on the Loot tab|r") end
    for i = 1, math.min(3, runs) do local z = order[i]; local g = 0; for n in pairs(z.who) do if guildie(n) then g = g + 1 end end
      add(k.IC_RUN, INK .. z.zone .. "|r" .. DIM .. "  ·  " .. plural(z.n, "boss", "bosses") .. (g > 1 and (", with " .. plural(g - 1, "guildie", "guildies")) or "") .. "|r", when(z.t)) end
    for _, c in ipairs(come) do add(k.IC_JOIN, INK .. c[1] .. "|r" .. DIM .. " joined the guild|r") end
    for _, n in ipairs(gone) do add(k.IC_LEAVE, DIM .. n .. " left the guild|r") end
    stats[1].n:SetText(#dings); stats[1].l:SetText(#dings == 1 and "level-up" or "level-ups")
    stats[2].n:SetText(joins); stats[2].l:SetText("joined")
    stats[3].n:SetText(drops); stats[3].l:SetText(drops == 1 and "good drop" or "good drops")
    stats[4].n:SetText(runs); stats[4].l:SetText(runs == 1 and "dungeon run" or "dungeon runs")
    for i, r in ipairs(list) do
      local L = lines[i]
      if L then setRow(r, L[1], L[2], L[3]); if L[4] then r.item = L[4].id; r.itemName = L[4].name end else r:Hide() end
    end
    p:SetHeight(112 + math.min(#lines, #list) * 20 + 48)
    local hrs = math.floor((now() - since) / 3600)
    p.sub:SetText("Since you were last on" .. (hrs >= 1 and ("  ·  " .. (hrs >= 48 and (math.floor(hrs / 24) .. " days") or plural(hrs, "hour", "hours"))) or ""))
    return #lines
  end
  -- At login: note when you were last on, and the guild list as it was then, then look a few seconds later (once the
  -- guild list has been read and other scribes have shared).
  ui.awayStart = function()
    local db = DB()
    if not db then return end
    if db.ui.away == nil then db.ui.away = true end
    local last = tonumber(db.ui.lastOn)
    loginAt = now()
    if not last or loginAt - last < AWAY_MIN then since = nil; return end
    since = last
    before = { known = {}, gone = {} }
    for name, m in pairs(db.members) do before.known[name] = true; if m.gone then before.gone[name] = true end end
    C_Timer.After(10, function()
      if not DB().ui.away then return end
      local ok, n = pcall(build)
      if ok and n and n > 0 then p:Show() end
    end)
  end
  ui.awayShow = function() if since and build() > 0 then p:Show() end end
  k.check("away", "Show what happened while I was away, when I log in", -410)
end
