-- ============================================================
--  6_lang.lua  --  Chu hien cho nguoi choi, hai thu tieng
--
--  CFG.LANG chon tieng. build.py --lang en|vi ghi de len no, nen mot
--  bo nguon xuat ra duoc hai ban map.
--
--  HAI CACH, dung cho hai thu khac nhau:
--
--  1. API.t("key")  -- chu co dinh cua giao dien. Nam trong bang T ben
--     duoi, mot cho duy nhat, de doi chieu xem thieu cau nao.
--
--  2. API.pick(tbl) -- ten nam trong bang du lieu (canh gioi, ky nang,
--     hero). Khong tach ra khoi bang du lieu vi ten di lien voi so lieu
--     cua no; tach ra la hai bang phai giu dong bo bang tay.
--
--  THIEU CAU THI TRA VE CHINH CAI KEY, khong tra ve nil va khong sap.
--  Chu la mot khoa lo ra tren man hinh, de thay, sua sau cung duoc --
--  khac han voi nil lam no giua tran.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local T = {}

T.en = {
  -- Bang nhan vat
  panel_close     = "Close",
  panel_skill     = "Skills",
  panel_gear      = "Gear",
  panel_root      = "Spirit Root",
  panel_treasure  = "Treasures",
  panel_linhkhi   = "Spirit Qi",
  panel_tinhthach = "Spirit Stone",
  panel_level     = "lv",
  panel_max       = "max",
  panel_cd        = "cd",
  panel_empty     = "Nothing here yet.",

  -- The Ky Nang
  skill_none      = "No hero yet, or this hero has no skills defined.",
  skill_notlive   = "Numbers above are DESIGN, not yet in effect.",
  skill_notlive2  = " In game these are still Warcraft defaults.",
  skill_oemissing = "%s only has %d levels in Object Editor",
  skill_oefix     = " (design needs %d). Set Stats - Levels = %d for %s.",
  skill_atmax     = "%s is already at max level.",
  skill_up        = "%s reached level %d/%d.",
  skill_warn      = "Warning: %s is only at level %d on the unit, not %d",
  skill_oeshort   = "OE short",
  skill_locked    = "locked",
  skill_buy       = "buy",
  skill_unlocked  = "%s unlocked %s.",

  -- Linh Can
  lc_power        = "Power",
  lc_stat         = "stats",
  lc_here         = "you are here",
  lc_passed       = "done",
  lc_break        = "Break through",
  lc_peak         = "You have reached the peak of cultivation.",
  lc_broke        = "%s broke through to %s",

  -- Chung
  no_qi           = "Not enough Spirit Qi.",
  need_have       = " Need %s, have %s.",
  boss_down       = "Boss %s defeated. Everyone gains %d Spirit Stone.",

  -- Quai
  wave_next       = "Next wave",
  wave_cleared    = "Wave cleared.",
  wave_notclear   = "Still %d enemies alive. Clear the wave first.",
  mob_suffix      = "Cultivator",
  elite_suffix    = "Elite",
  boss_suffix     = "Lord",
}

T.vi = {
  panel_close     = "Dong",
  panel_skill     = "Ky Nang",
  panel_gear      = "Trang Bi",
  panel_root      = "Linh Can",
  panel_treasure  = "Phap Bao",
  panel_linhkhi   = "Linh Khi",
  panel_tinhthach = "Tinh Thach",
  panel_level     = "bac",
  panel_max       = "toi da",
  panel_cd        = "hoi",
  panel_empty     = "He nay chua cai.",

  skill_none      = "Chua co hero, hoac hero nay chua khai bao ky nang.",
  skill_notlive   = "So lieu tren la THIET KE, chua co hieu luc.",
  skill_notlive2  = " Trong game van la so goc cua Warcraft.",
  skill_oemissing = "%s chi co %d bac trong Object Editor",
  skill_oefix     = " (thiet ke can %d). Dat Stats - Levels = %d cho %s.",
  skill_atmax     = "%s da o bac cao nhat.",
  skill_up        = "%s len bac %d/%d.",
  skill_warn      = "Canh bao: %s tren unit moi o bac %d, khong phai %d",
  skill_oeshort   = "OE thieu bac",
  skill_locked    = "chua mo",
  skill_buy       = "mua",
  skill_unlocked  = "%s da mo khoa %s.",

  lc_power        = "Suc manh",
  lc_stat         = "chi so",
  lc_here         = "dang o day",
  lc_passed       = "da qua",
  lc_break        = "Dot pha",
  lc_peak         = "Da toi dinh cua thang tu vi.",
  lc_broke        = "%s dot pha len %s",

  no_qi           = "Khong du linh khi.",
  need_have       = " Can %s, dang co %s.",
  boss_down       = "Ha duoc boss %s. Moi nguoi nhan %d Tinh Thach.",

  wave_next       = "Dot ke tiep",
  wave_cleared    = "Da don sach dot nay.",
  wave_notclear   = "Con %d con tren map. Don sach roi hay goi dot sau.",
  mob_suffix      = "Tan Tu",
  elite_suffix    = "Tinh Anh",
  boss_suffix     = "Ma Ton",
}

local function lang()
  return T[CFG.LANG] and CFG.LANG or "en"
end

-- Thieu cau thi tra ve chinh cai key. Mot chuoi la tren man hinh de
-- thay ngay va sua sau duoc; nil thi no giua tran.
local function t(key, ...)
  local s = T[lang()][key]
  if s == nil then
    API.trace("lang: THIEU cau [" .. tostring(key) .. "] tieng " .. lang())
    return tostring(key)
  end
  if select("#", ...) == 0 then return s end
  return string.format(s, ...)
end

-- Ten nam trong bang du lieu: { ten = "Pham Nhan", en = "Mortal" }
-- Tieng Viet giu o khoa "ten" vi bang du lieu viet bang tieng Viet truoc.
local function pick(tbl)
  if tbl == nil then return "?" end
  if lang() == "en" then return tbl.en or tbl.ten or "?" end
  return tbl.ten or tbl.en or "?"
end

-- Doi chieu hai bang: thieu cau nao thi bao ngay luc vao map, dung de
-- tinh co mo dung the do moi phat hien.
local function checkAll()
  local thieu = {}
  for k, _ in pairs(T.en) do
    if T.vi[k] == nil then thieu[#thieu + 1] = "vi:" .. k end
  end
  for k, _ in pairs(T.vi) do
    if T.en[k] == nil then thieu[#thieu + 1] = "en:" .. k end
  end
  if #thieu > 0 then
    API.trace("lang: LECH BANG -- " .. table.concat(thieu, " "))
  else
    API.trace("lang: " .. lang() .. ", hai bang khop nhau")
  end
end

API.t         = t
API.pick      = pick
API.lang      = lang
API.langCheck = checkAll
