-- ============================================================
--  01_config.lua  --  Cau hinh map
--
--  Buoc 1: kich thuoc, nguoi choi, luoi 25 o ngan cach boi song.
--  Moi con so chinh sua deu nam o day.
--
--  LUU Y: chu hien thi trong game de o dang khong dau -- font goc cua
--  WC3 thieu glyph Latin Extended (U+1EA0..U+1EF9).
--  LUU Y: moi duong dan phai viet bang [[...]], khong dung nhay kep.
-- ============================================================

-- FourCC cua Warcraft III tra ve HAI gia tri (id, va vi tri ke tiep --
-- no duoc cai dat bang string.unpack). Trong Lua, loi goi ham o VI TRI
-- CUOI cua mot table constructor se no ra thanh TAT CA gia tri tra ve.
-- Nen { FourCC('a'), FourCC('b') } cho ra bang 3 phan tu, phan tu cuoi
-- la mot so rac. Truyen so rac do cho GetUnitGoldCost lam game sap.
--
-- Cap ngoac don cat bot ve dung mot gia tri. Dung id() thay cho FourCC
-- o moi cho, nhat la trong bang.
local function id(fourcc)
  return (FourCC(fourcc))
end

local CFG = {}

CFG.VERSION = "0.2.0"
CFG.DEBUG   = false     -- bat: in so do luoi, ping minimap, bao cao chi tiet

-- Lenh chat thu nghiem ("-sp"). Co RIENG mot co, khong di theo DEBUG --
-- de tat bao cao chi tiet ma van go lenh thu duoc. Tat truoc khi phat hanh.
CFG.DEV_COMMANDS = true

-- Ghi vet khoi dong ra file. Game sap thi moi dong chat deu mat, nen
-- day la cach duy nhat biet no chet o buoc nao. Tat di khi da on.
-- File nam o Documents\Warcraft III\<TRACE_FILE>
CFG.TRACE      = true
CFG.TRACE_FILE = "DarknessTrace.txt"

-- ---------- Mau chu ----------
CFG.C_GOLD = "|cffffcc00"
CFG.C_JADE = "|cff66ffcc"
CFG.C_RED  = "|cffff6666"
CFG.C_GREY = "|cff999999"
CFG.C_END  = "|r"
CFG.MSG_TIME = 30.0

-- ---------- Nguoi choi ----------
-- Phai khop voi slot da bat trong World Editor.
CFG.PLAYER_SLOTS = { 0, 1, 2 }   -- ba nguoi choi, dong minh voi nhau
CFG.ENEMY_SLOT   = 11            -- phe dich, do may dieu khien

-- ---------- Luoi 25 o ----------
CFG.GRID_COLS = 5
CFG.GRID_ROWS = 5
CFG.TILE      = 128.0   -- mot o dia hinh WC3 = 128 don vi the gioi

-- Be rong dong song ngan cach hai block, tinh bang o dia hinh.
-- 8 o = 1024 don vi. Chon 8 vi no chia het vung choi duoc 212 o:
--   5 block x 36 o  +  4 song x 8 o  =  212 o, le bang 0.
-- Nho do moi mep block va mep song deu roi dung ranh gioi o, dem o
-- trong World Editor la ra. Doi so nay thi phai ve lai song.
CFG.RIVER_TILES = 8

-- Kich thuoc block duoc suy ra tu vung choi duoc luc chay, nen doi
-- map size trong World Editor khong phai sua gi o day.
-- Dat > 0 de ep kich thuoc block thay vi de code tu chia.
CFG.BLOCK_TILES_OVERRIDE = 0

-- ---------- Vung ve trong World Editor ----------
-- Nhan mot ten hoac mot danh sach ten -- thu lan luot tu tren xuong.
-- Danh sach de map chay duoc ca truoc va sau khi ban sua chinh ta ten
-- vung trong World Editor.
-- Khong tim thay thi vao map se co dong do liet ke moi vung WE that su
-- co (hien du CFG.DEBUG tat).
CFG.RGN_HOUSE  = { "MyHouseRegion" }
CFG.RGN_ENEMY  = { "MyEmenyRegion",  "MyEnemyRegion"  }

-- ---------- Nha chinh ----------
-- Mountain King. Day la HERO, khong phai cong trinh -- xem
-- docs/02-he-thong/nha-chinh.md ve nhung khac biet phai xu ly.
CFG.HOUSE_UNIT   = id('Hmkg')
CFG.HOUSE_NAME   = "Nha Chinh"
CFG.HOUSE_HP     = 1000
CFG.HOUSE_FACE   = 270.0
CFG.HOUSE_SCALE  = 1.0
CFG.HOUSE_SIGHT  = 1500.0

-- Slot so huu nha chinh. KHONG duoc trung PLAYER_SLOTS hay ENEMY_SLOT.
-- Slot rieng de nha khong thuoc ve rieng ai; no la dong minh cua ca ba
-- nguoi choi va chung tam nhin voi ho.
CFG.HOUSE_SLOT = 3

-- Nha chinh khong danh duoc ai.
CFG.HOUSE_CAN_ATTACK = false

-- Khoa kinh nghiem: hero len cap se tinh lai mau theo suc manh, pha mat
-- moc HOUSE_HP da dat.
CFG.HOUSE_SUSPEND_XP = true

-- Bat tu thi khong bao gio chet, ma nha chet la thua -- nen de false.
-- Bat tam thoi thanh true neu can test thu ma khong so thua.
CFG.HOUSE_INVULNERABLE = false

-- Nha chinh chet la ca ba nguoi choi thua.
CFG.HOUSE_DEATH_ENDS_GAME = true

-- false = nguoi choi khong chon duoc nha chinh. Nha la muc tieu phai
-- giu, khong phai quan de dieu khien -- lot vao Ctrl+A roi lo ra lenh
-- cho no la hong.
CFG.HOUSE_SELECTABLE = false

-- ---------- Khoa hero: kinh nghiem & ky nang ----------
-- Khong hero nao tren map duoc len cap: nha chinh, hero nguoi choi, va
-- ca hero cua phe dich sau nay.
CFG.LOCK_HERO_XP = true

-- ---------- Che do ky nang ----------
--
-- "none"  Khong hoc duoc ky nang nao. Ky nang CO DINH van gan duoc qua
--         CFG.HEROES[i].abilities.
--
-- "learn" KHUYEN DUNG. Dung menu hoc ky nang GOC cua Warcraft III:
--         luoi ICON, TOOLTIP day du, cham cap do. Khong phai viet UI.
--
--         Cach lam "chon M trong N": cho hero N ability hoc duoc, roi
--         chi phat M diem. Nguoi choi tu chon M cai. Moi ability dat
--         Stats - Levels = 1 de khong the do het diem vao mot cai.
--
-- "pick"  Popup chon theo slot (dialog cua ta). Kiem soat duoc cau truc
--         lua chon, nhung nut CHI CO CHU -- khong icon, khong tooltip.
--
-- "frame" THU NGHIEM. Giao dien tu ve bang BlzCreateFrame: co icon, tu
--         nhom theo slot, khong dung Object Editor. Xem file rieng
--         src/07b_skillframe.lua -- hong thi xoa file do la xong.
--
-- Ca "learn" va "pick" deu giu hero o cap 1: LOCK_HERO_XP khong doi,
-- diem ky nang do code phat chu khong do len cap.
--
-- Rieng "learn" doi Object Editor, thieu mot la khong hoc duoc:
--   1. Ability nam trong Techtree - Hero Abilities cua hero
--   2. Stats - Required Level          = 1
--   3. Levels - Level Skip Requirement = 0
--   4. Stats - Levels                  = 1   (de "chon M trong N")
CFG.SKILL_MODE = "frame"

-- So diem phat khi hero vua sinh ra. Chi co nghia o che do "learn".
CFG.SKILL_POINTS_START = 1

-- Suy ra tu SKILL_MODE -- dung sua tay. Chi che do "learn" moi can
-- diem ky nang; hai che do kia rut sach de nut + khong hien ra.
CFG.STRIP_SKILL_POINTS = (CFG.SKILL_MODE ~= "learn")

-- Go ability khoi hero luc chay.
--
-- DA THU VA KHONG AN cho ky nang goc. Vet ghi lai:
--   remove Priestess of the Moon: KHONG id nao trung (12 id da thu)
--   remove Nha Chinh:             KHONG id nao trung (12 id da thu)
--
-- Ly do: ky nang hero CHUA HOC khong phai ability gan tren unit -- chung
-- nam trong Techtree - Hero Abilities cua LOAI unit, va
-- UnitRemoveAbility khong voi toi duoc. Xoa ky nang goc phai lam trong
-- Object Editor. Xem docs/05-quyet-dinh/0008-ky-nang-hero-phai-sua-o-object-editor.md
--
-- Giu co che lai vi no van go duoc ability THAT SU dang co tren unit.
CFG.HERO_REMOVE_ABILITIES = {}

-- Giay giua hai lan quet toan map. 0 = chi khoa luc tao, khong quet.
-- Can quet vi hero co the sinh ra o cho code nay khong kiem soat:
-- unit dat san trong World Editor, hero trieu hoi, hero cua dot quai.
CFG.HERO_XP_SWEEP = 5.0

-- ---------- Chon hero bang popup ----------
-- Khong dung Tavern nua. CreateUnit bo qua toan bo techtree: khong
-- requirement, khong gia, khong luong thuc, khong quay hang, khong dong
-- ho hoi hang. Nam cho va tam truoc day deu khong can nua.

-- Ba hero tu tao trong Object Editor.
--
-- 'name'      chu hien tren nut popup, tu dat, khong can trung ten unit.
-- 'abilities' ky nang gan luc tao hero.
--
-- Dung ABILITY THUONG, khong phai hero ability: chung hien ra ngay,
-- khong ton diem ky nang -- hop voi map nay vi khong hero nao len cap.
--
-- VI TRI NUT khong do code quyet dinh. No nam o Art - Button Position
-- (X) va (Y) cua chinh ability trong Object Editor:
--   X = 0..3 (cot trai sang phai), Y = 0..2 (hang tren xuong duoi).
-- Hai ability trung vi tri thi de len nhau, mot cai bam khong duoc.
--
-- Command card 4x3 = 12 o. Lenh co ban da chiem 5 o:
--   (0,0) Move   (1,0) Stop   (2,0) Hold   (3,0) Attack   (0,1) Patrol
-- Con lai 7 o trong:
--   (1,1) (2,1) (3,1)   (0,2) (1,2) (2,2) (3,2)
-- 'skills' la CAY SKILL RIENG cua hero do, cung dang voi
-- CFG.SKILL_SLOTS. Hero nao khong khai bao thi dung SKILL_SLOTS chung.
-- 'icon' hien tren the chon hero (CFG.HERO_PICK_MODE = "frame").
-- Doi cho khop icon that cua hero trong Object Editor.
-- 'role' la dong chu nho duoi ten.
CFG.HEROES = {
  { id = id('H001'), name = "Hart", role = "Warrior", abilities = {}, skills = nil,
    icon = [[ReplaceableTextures\CommandButtons\BTNHeroPaladin.blp]] },
  { id = id('H002'), name = "Hvwd", role = "Shooter", abilities = {}, skills = nil,
    icon = [[ReplaceableTextures\CommandButtons\BTNHeroMoonPriestess.blp]] },
  { id = id('H003'), name = "Hkal", role = "Mage",    abilities = {}, skills = nil,
    icon = [[ReplaceableTextures\CommandButtons\BTNHeroBloodElfPrince.blp]] },
}

-- Ky nang gan cho MOI hero, khong rieng con nao.
CFG.HERO_COMMON_ABILITIES = {}

-- ---------- Chon ky nang theo slot ----------
--
-- Moi slot la mot O trong command card, va nguoi choi chon MOT trong so
-- cac ability ung vien cua slot do.
--
-- QUAN TRONG: vi tri o KHONG do code quyet dinh, no la
-- Art - Button Position cua chinh ability. Nen moi ability trong cung
-- mot slot phai duoc dat CUNG (X, Y) trong Object Editor -- co vay thi
-- chon con nao cung roi dung vao o do.
--
-- Bay o trong: (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2)
--
-- Vi du khi ban da co ability:
--   CFG.SKILL_SLOTS = {
--     { name = "O 1 - Tan cong", pos = "(1,1)", choices = {
--         { id = id('A000'), name = "Chem manh" },
--         { id = id('A001'), name = "Lao khien" },
--     }},
--     { name = "O 2 - Phong thu", pos = "(2,1)", choices = {
--         { id = id('A002'), name = "Giap da" },
--     }},
--   }
CFG.SKILL_SLOTS = {
  -- DU LIEU THU. Hai ky nang goc cua Paladin, de kiem tra luong chon
  -- truoc khi ban co ability tu tao. Xoa khi da co ability that.
  --
  -- Hai con nay se roi vao HAI O KHAC NHAU cua command card, vi
  -- Button Position cua chung do Blizzard dat san va khac nhau. Day
  -- dung la dieu can luu y: muon chung tranh CUNG mot o thi phai dat
  -- cung Art - Button Position trong Object Editor.
  { name = "Thu: chon 1 trong 2 skill Paladin", choices = {
      { id = id('AHhb'), name = "Holy Light",
        icon = [[ReplaceableTextures\CommandButtons\BTNHolyBolt.blp]] },
      { id = id('AHds'), name = "Divine Shield",
        icon = [[ReplaceableTextures\CommandButtons\BTNDivineIntervention.blp]] },
  }},
}

-- Chon xong mot slot thi tu mo slot ke tiep.
CFG.SKILL_PICK_CHAIN = true

-- ---------- Giao dien tu ve (SKILL_MODE = "frame") ----------
-- Toa do man hinh cua Warcraft III: X tu 0.0 den 0.8, Y tu 0.0 den 0.6.
CFG.FRAME_X       = 0.40    -- tam ngang
CFG.FRAME_Y       = 0.36    -- tam doc
CFG.FRAME_W       = 0.26
CFG.FRAME_H       = 0.10
CFG.FRAME_ICON    = 0.045   -- canh mot nut icon
CFG.FRAME_GAP     = 0.012   -- khoang cach giua hai nut
CFG.FRAME_BG      = [[ReplaceableTextures\TeamColor\TeamColor27]]

-- Template cho nut bam. Neu nut khong an, thu doi sang mot trong:
--   "ScoreScreenTabButtonTemplate"  "IconButtonTemplate"
--   "StandardLightButtonTemplate"   "DebugButton"
CFG.FRAME_BUTTON_TEMPLATE = "ScoreScreenTabButtonTemplate"

-- Mo toan bo suong mu. CHI DE PHAT TRIEN -- tat truoc khi phat hanh.
CFG.REVEAL_MAP = true

-- "frame"  the chon co icon, tu ve bang BlzCreateFrame
-- "dialog" popup chu cua Warcraft III -- xau hon nhung chac chan chay
CFG.HERO_PICK_MODE = "frame"

CFG.PICK_TITLE = "Chon hero cua ban"

-- Kich thuoc the chon hero. Toa do man hinh: X 0.0..0.8, Y 0.0..0.6.
CFG.CARD_W    = 0.115   -- be ngang mot the
CFG.CARD_H    = 0.150
CFG.CARD_GAP  = 0.014   -- khoang cach giua hai the
CFG.CARD_ICON = 0.064   -- canh o icon trong the
CFG.CARD_X    = 0.40    -- tam ngang cua ca hang the
CFG.CARD_Y    = 0.38    -- tam doc

-- Cho vai giay roi moi hien popup: hien ngay luc map vua nap thi no bi
-- man hinh chuyen canh nuot mat.
CFG.PICK_DELAY = 2.0

-- Moi nguoi toi da bao nhieu hero. 0 = khong gioi han.
CFG.HERO_MAX_PER_PLAYER = 1

-- true = mot hero chi mot nguoi lay duoc.
CFG.HERO_UNIQUE = true

-- Hero sinh ra cach nha chinh bao xa.
CFG.HERO_SPAWN_OFFSET = 500.0
