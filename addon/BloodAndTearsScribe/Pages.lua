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
