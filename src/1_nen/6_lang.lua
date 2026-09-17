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
  panel_close     = "ESC / %s to close",
  panel_close_esc = "ESC to close",
  panel_skill     = "Skills",
  panel_gear      = "Gear",
  panel_root      = "Cultivation",
  panel_treasure  = "Treasures",
  panel_linhkhi   = "Spirit Qi",
  panel_level     = "lv",
  panel_max       = "max",
  panel_cd        = "cd",
  panel_mana      = "mana",
  col_rank        = "Rank",
  col_realm       = "Realm",
  col_power       = "Power",
  col_cost        = "Cost",
  col_skill       = "Skill",
  col_level       = "Lv",
  col_effect      = "Effect",
  col_use         = "Cd / Mana",
  stat_str        = "Str",
  stat_agi        = "Agi",
  stat_int        = "Int",
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
  pick_title      = "Choose your hero",
  pick_done       = "%s chose %s.",
  wave_next       = "Next wave",
  wave_cleared    = "Wave cleared.",
  wave_waiting    = "Type -next when you are ready. Waves will not start on their own.",
  wave_vienman    = "%s is complete. The clock has stopped -- type -next to call the boss.",
  wave_realmdone  = "Clock stopped. Spend what you earned, then type -next to enter %s.",
  wave_resting    = "Clock is stopped. Type -next when the party is ready.",
  wave_notclear   = "Still %d enemies alive. Clear the wave first.",
  mob_suffix      = "Cultivator",
  elite_suffix    = "Elite",
  boss_suffix     = "Lord",
  panel_vang      = "Gold",
  panel_go        = "Lumber",
  panel_shop      = "Shop",
  no_go           = "Not enough Lumber.",
  no_vang         = "Not enough Gold.",
  shop_full       = "Inventory full.",
  shop_empty      = "Nothing for sale.",
  shop_bought     = "Bought %s for %s gold.",
  shop_stack      = "%s x%d -- %s gold.",
  tb_locked       = "Locked for now.",
  pk_locked       = "Locked for now -- this system is being redesigned.",
  btn_up          = "UPGRADE",
  btn_buy         = "BUY",
  btn_unlock      = "UNLOCK",
  -- Ten tien NGAN, chi dung tren nut. Nut cu chi in con so: "UPGRADE 1"
  -- doc ra la "nang len bac 1", khong ai doan duoc 1 do la 1 Ngo Tinh.
  cur_lk          = "Qi",
  cur_go          = "Lumber",
  cur_vang        = "Gold",
  st_max          = "MAX",
  st_locked       = "locked",
  st_owned        = "owned",
  lc_rank         = "Rank %d / %d",
  lc_have         = "You hold %s Spirit Qi.",
  lc_next         = "BREAK THROUGH  ->  %s",
  tb_effect       = "+%s attack damage",
  tb_bought       = "%s raised %s to level %d.",
  pk_bought       = "%s obtained %s.",
  pk_note         = "Spirit Stone only drops from bosses -- 20 times a run.",
  pk_empty        = "No treasures yet -- leftover Insight will be spent here.",
  ngo_note        = "Insight comes from elites -- one per wave.",
  tier_word       = "Tier",
  tier_full       = "Perfection",
  stage_boss      = "BOSS",
  wave_comp       = "%d x %s   +   %d x %s",
  wave_hold       = "%d enemies still alive -- next wave postponed until the map is clear.",
  boss_coming     = "=== %s TRIBULATION -- BOSS ===",
  win_final       = "%s has been stopped.",
}

T.vi = {
  panel_close     = "ESC / %s de dong",
  panel_close_esc = "ESC de dong",
  panel_skill     = "Ky Nang",
  panel_gear      = "Trang Bi",
  panel_root      = "Tu Vi",
  panel_treasure  = "Phap Bao",
  panel_linhkhi   = "Linh Khi",
  panel_level     = "bac",
  panel_max       = "toi da",
  panel_cd        = "hoi",
  panel_mana      = "mana",
  col_rank        = "Bac",
  col_realm       = "Canh gioi",
  col_power       = "Suc manh",
  col_cost        = "Gia",
  col_skill       = "Ky nang",
  col_level       = "Bac",
  col_effect      = "Hieu luc",
  col_use         = "Hoi / Mana",
  stat_str        = "Suc manh",
  stat_agi        = "Nhanh nhen",
  stat_int        = "Tri tue",
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

  pick_title      = "Chon hero cua ban",
  pick_done       = "%s da chon %s.",
  wave_next       = "Dot ke tiep",
  wave_cleared    = "Da don sach dot nay.",
  wave_waiting    = "Go -next khi san sang. Quai se khong tu ra.",
  wave_vienman    = "%s vien man. Dong ho da dung -- go -next de goi boss do kiep.",
  wave_realmdone  = "Dong ho da dung. Tieu cho xong roi go -next de vao %s.",
  wave_resting    = "Dong ho dang dung. Go -next khi ca doi san sang.",
  wave_notclear   = "Con %d con tren map. Don sach roi hay goi dot sau.",
  mob_suffix      = "Tan Tu",
  elite_suffix    = "Tinh Anh",
  boss_suffix     = "Ma Ton",
  panel_vang      = "Vang",
  panel_go        = "Go",
  panel_shop      = "Cua Hang",
  no_go           = "Khong du Go.",
  no_vang         = "Khong du Vang.",
  shop_full       = "Tui do da day.",
  shop_empty      = "Chua ban gi ca.",
  shop_bought     = "Da mua %s voi %s vang.",
  shop_stack      = "%s x%d -- %s vang.",
  tb_locked       = "Tam khoa.",
  pk_locked       = "Tam khoa -- he nay dang thiet ke lai.",
  btn_up          = "NANG",
  btn_buy         = "MUA",
  btn_unlock      = "MO KHOA",
  cur_lk          = "Linh Khi",
  cur_go          = "Go",
  cur_vang        = "Vang",
  st_max          = "TOI DA",
  st_locked       = "chua mo",
  st_owned        = "da co",
  lc_rank         = "Bac %d / %d",
  lc_have         = "Dang co %s Linh Khi.",
  lc_next         = "DOT PHA  ->  %s",
  tb_effect       = "+%s sat thuong don danh",
  tb_bought       = "%s nang %s len cap %d.",
  pk_bought       = "%s da co %s.",
  pk_note         = "Tinh Thach chi roi tu boss -- 20 lan ca van.",
  pk_empty        = "Chua co phap khi nao -- Ngo Tinh du se tieu o day.",
  ngo_note        = "Ngo Tinh den tu tinh anh -- moi wave mot con.",
  tier_word       = "Tang",
  tier_full       = "Vien Man",
  stage_boss      = "BOSS",
  wave_comp       = "%d x %s   +   %d x %s",
  wave_hold       = "Con %d con tren map -- hoan dot sau den khi don sach.",
  boss_coming     = "=== %s DO KIEP -- BOSS ===",
  win_final       = "Da chan duoc %s.",
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
