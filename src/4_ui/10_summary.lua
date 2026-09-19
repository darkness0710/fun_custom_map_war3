-- ============================================================
--  10_summary.lua  --  Bang tong ket luc het van
--
--  VI SAO CO. Ha boss stage 100 xong truoc day chi co MOT dong chu roi
--  CustomVictoryBJ. Mot tram wave doi lay mot hop thoai.
--
--  Va ban THUA con can hon ban thang: nguoi choi muon biet minh di
--  duoc toi dau, chu khong chi biet la thua.
--
--  CHI DOC, KHONG DEM THEM. Moi con so o day suy tu trang thai da co
--  san (S.stage, bac Tu Vi, so Thanh Thu, so Phap Khi...) tru DUNG HAI
--  cai phai dem: thoi gian va so quai. Them mot bo dem la them mot cho
--  co the lech voi su that.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local function clock()
  if S.t0 == nil or TimerGetElapsed == nil then return nil end
  return TimerGetElapsed(S.t0)
end

-- "1g 23p" / "23p 45g". Bo giay khi da qua mot gio: o do giay la nhieu
-- chu so ma khong ai doc.
local function hms(sec)
  if sec == nil then return "--" end
  local h = math.floor(sec / 3600.0)
  local m = math.floor((sec - h * 3600.0) / 60.0)
  local s = math.floor(sec - h * 3600.0 - m * 60.0)
  if h > 0 then return h .. "g " .. m .. "p" end
  return m .. "p " .. s .. "g"
end

-- Tong bac trang bi cua mot nguoi. Doc qua API.gearLevel chu khong mo
-- bang: 5_gear.lua so huu cach tinh do.
local function gearTotal(pid)
  if API.gearLevel == nil or CFG.GEAR == nil then return 0 end
  local n = 0
  for i = 1, #CFG.GEAR do n = n + (API.gearLevel(pid, i) or 0) end
  return n
end

local function relicCount(pid)
  if API.relicHas == nil or CFG.RELIC == nil then return 0 end
  local n = 0
  for i = 1, #CFG.RELIC do
    if API.relicHas(pid, CFG.RELIC[i].code) then n = n + 1 end
  end
  return n
end

local function skillTotal(pid)
  if API.skillList == nil then return 0 end
  local list, n = API.skillList(pid), 0
  for i = 1, #list do
    n = n + (API.skillLevel(pid, list[i].id, i) or 0)
  end
  return n
end

-- ---------- Ve bang ----------
--
-- Di qua API.info: day la BAN BAO CAO, khong mau, nhieu dong. Rieng
-- hai dong dau (THANG/THUA va ly do) la chu cua NGUOI CHOI nen chung
-- di qua API.msg va qua i18n.
local function show(win, reason)
  API.msg(nil, " ")
  local head = win and API.t("end_win") or API.t("end_lose")
  API.msg(nil, (win and CFG.C_GOLD or CFG.C_RED) .. head .. CFG.C_END ..
               "  " .. reason)

  local stage = S.stage or 0
  local total = (API.totalStages ~= nil) and API.totalStages() or 0
  API.info(nil, API.t("end_stage", stage, total) ..
                "   " .. API.t("end_time", hms(clock())) ..
                "   " .. API.t("end_kills", API.num(S.killCount or 0)))

  for i = 1, #S.pids do
    local pid = S.pids[i]
    local d = S.p[pid]
    if d ~= nil and d.hero ~= nil then
      local rank = (API.cultRank ~= nil) and API.cultRank(pid) or 1
      local realm = (API.realmName ~= nil) and API.realmName(rank) or rank
      API.info(nil, "  " .. GetPlayerName(Player(pid)) .. "  --  " ..
        realm ..
        "  |  " .. API.t("end_skill", skillTotal(pid)) ..
        "  |  " .. API.t("end_gear",  gearTotal(pid)) ..
        "  |  " .. API.t("end_relic", relicCount(pid)) ..
        "  |  " .. API.t("end_beast",
                         (API.petOwned ~= nil) and API.petOwned(pid) or 0) ..
        "  |  " .. API.t("end_wing",
                         (API.wingOwned ~= nil) and API.wingOwned(pid) or 0))
    end
  end

  API.trace("summary: stage " .. stage .. "/" .. total ..
            ", " .. math.floor(clock() or 0) .. "s, " ..
            (S.killCount or 0) .. " quai")
end

local function startSummary()
  -- Mot dong ho chay suot van, chi de DOC. TimerGetElapsed tren mot
  -- timer chu khong cong don bang tay: cong don bang tay thi moi cho
  -- quen goi la mot cho lech.
  S.t0 = CreateTimer()
  TimerStart(S.t0, 999999.0, false, nil)
  S.killCount = 0
  API.trace("summary: san sang")
end

API.summaryShow  = show
API.startSummary = startSummary
