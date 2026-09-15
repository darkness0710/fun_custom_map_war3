-- ============================================================
--  1_config.lua  --  Cau hinh map
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

CFG = {}

CFG.VERSION = "0.2.0"

-- Tieng hien cho nguoi choi: "en" hoac "vi".
-- build.py --lang en|vi ghi de len dong nay, nen mot bo nguon xuat ra
-- duoc hai ban map. Xem src/1_nen/6_lang.lua
CFG.LANG = "en"
CFG.DEBUG   = false     -- bat: in so do luoi, ping minimap, bao cao chi tiet

-- Lenh chat thu nghiem ("-sp"). Co RIENG mot co, khong di theo DEBUG --
-- de tat bao cao chi tiet ma van go lenh thu duoc. Tat truoc khi phat hanh.
CFG.DEV_COMMANDS = true

-- Ghi vet khoi dong ra file. Game sap thi moi dong chat deu mat, nen
-- day la cach duy nhat biet no chet o buoc nao. Tat di khi da on.
-- File nam o Documents\Warcraft III\<TRACE_FILE>
CFG.TRACE      = true
CFG.TRACE_FILE = "DarknessTrace.txt"

-- "-nat <chu>" liet ke toi da bao nhieu hang so ability moi lan.
-- Cao qua thi ngap chat va tran tran text tag.
CFG.NAT_FIELD_MAX = 20

-- ---------- Dong bo nhieu nguoi choi ----------
--
-- Bam nut frame chi no tren may nguoi bam. Doi trang thai game ngay o do
-- la lech tran. Xem docs/05-quyet-dinh/0012 va src/1_nen/3_sync.lua.
--
--   "auto"  -- uu tien blz, roi cache, roi local  (nen dung)
--   "blz"   -- BlzSendSyncData, can 1.31 tro len
--   "cache" -- game cache, co tu ban 1.00, chac chan chay
--   "local" -- khong dong bo, CHI CHOI MOT MINH
CFG.SYNC_MODE  = "auto"
CFG.SYNC_POLL  = 0.10    -- giay giua hai lan quet (chi duong cache)
CFG.SYNC_CACHE = "darknesssync.w3v"
CFG.SYNC_TEST_WAIT = 3.0 -- doi bao lau roi ket luan ping co ve khong

-- Ma lenh cua tung loai tin. 1..200, moi ma mot viec, khong trung nhau.
CFG.OP_PING   = 1   -- tu kiem duong dong bo
CFG.OP_HERO   = 2   -- arg = so thu tu trong CFG.HEROES
CFG.OP_SKILL  = 3   -- arg = slot * 100 + so thu tu trong choices
CFG.OP_LC_UP  = 4   -- arg = 0
CFG.OP_LC_SET = 5   -- arg = bac Linh Can muon nhay toi (dev)

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

-- Nha nhan sat thuong binh thuong. Chet la thua. (ADR 0011 bi lat)
CFG.HOUSE_INVULNERABLE = false

-- Nha chinh chet la ca ba nguoi choi thua.
CFG.HOUSE_DEATH_ENDS_GAME = true

-- true = chon duoc nha chinh de XEM chi so.
--
-- Truoc day dat false de chan Ctrl+A. Nhung thu chan that su la quyen
-- DIEU KHIEN, va cai do da duoc chan boi quyen so huu: nha thuoc slot
-- rieng, khong chia quyen dieu khien (04_player). Bo chon thu cong chi
-- lam khong xem duoc chi so -- hai nhieu hon loi.
--
-- Neu Ctrl+A van gom nha vao thi dat lai false va bao, luc do can cach
-- khac chu khong phai cach nay.
CFG.HOUSE_SELECTABLE = true

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
--         src/4_giao_dien/3_skillframe.lua -- hong thi xoa file do la xong.
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
  -- mota: BA gach dau dong, hien tren the chon hero.
  --
  -- PHAI NGAN. Frame chu cua Warcraft KHONG tu xuong dong va can giua
  -- the, nen mot dong dai se tran sang the ben canh va de len chu cua
  -- no. Toi da khoang 3-4 tu moi gach.
  --
  -- Gach thu ba luon la DIEM YEU -- the nao cung co cai manh, chi diem
  -- yeu moi lam nguoi choi phai nghi xem nen chon con nao.
  { id = id('H001'), name = "Hart", role = "Warrior - Tanker", abilities = {}, skills = nil,
    icon = [[ReplaceableTextures\CommandButtons\BTNHeroPaladin.blp]],
    mota    = { "Don quai dong", "Chiu don khoe", "Yeu truoc boss" },
    mota_en = { "Clears crowds", "Very tanky", "Weak vs bosses" } },
  { id = id('H002'), name = "Hvwd", role = "Shooter - Carry", abilities = {}, skills = nil,
    icon = [[ReplaceableTextures\CommandButtons\BTNHeroMoonPriestess.blp]],
    mota    = { "Sat thuong cao nhat", "Danh tu xa", "Rat mong" },
    mota_en = { "Top damage", "Long range", "Very fragile" } },
  { id = id('H003'), name = "Hkal", role = "Mage - Support", abilities = {}, skills = nil,
    icon = [[ReplaceableTextures\CommandButtons\BTNHeroBloodElfPrince.blp]],
    mota    = { "Hoi mau, tiep suc", "Lam cham quai", "Mot minh thi yeu" },
    mota_en = { "Heals and buffs", "Slows the wave", "Weak alone" } },
}

-- Ky nang gan cho MOI hero, khong rieng con nao.
CFG.HERO_COMMON_ABILITIES = {}

-- ---------- Nap truoc tai nguyen tu import ----------
--
-- Warcraft nap model cua nhung LOAI unit co mat tren map luc vao game.
-- Loai nao khong xuat hien o dau thi model nap theo yeu cau -- va model
-- tu import nap kieu do thi hong: unit hien ra den si, khong loi nao bao.
--
-- Do duoc: cung mot H001, con dat san trong World Editor thi co mau, con
-- tao bang CreateUnit luc chay thi den si.
--
-- Duong dan phai KHOP TUNG KY TU voi ten file trong map. Bo dong goi
-- (w3mpq.py) ghi ten theo duong dan tuong doi, dau gach nguoc.
CFG.PRELOAD = {
  [[war3mapImported\UtherV2.mdx]],
  [[units\HotS\Uther\Uther.blp]],
}

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

-- CFG.PICK_TITLE da chuyen sang 6_lang.lua, khoa "pick_title".

-- Kich thuoc the chon hero. Toa do man hinh: X 0.0..0.8, Y 0.0..0.6.
CFG.CARD_W    = 0.170   -- be ngang mot the; du cho ba gach dau dong
CFG.CARD_H    = 0.200
CFG.CARD_GAP  = 0.014   -- khoang cach giua hai the
CFG.CARD_ICON = 0.064   -- canh o icon trong the
CFG.CARD_TOP  = 0.014   -- tu dinh the toi icon
CFG.CARD_LINE = 0.016   -- khoang cach hai gach dau dong
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

-- ============================================================
--  DOT QUAI  --  220 stage
--  Luat: docs/02-he-thong/dot-quai.md
--  Duong cong: docs/03-du-lieu/duong-cong-suc-manh.md
-- ============================================================

-- 20 canh gioi. 'ten' phai KHONG DAU: font goc cua WC3 thieu glyph
-- Latin Extended nen chu co dau hien ra o vuong.
-- 'coi' 1..4 = Pham / Yeu / Tien / Than -- quyet dinh model va nhip wave.
CFG.REALMS = {
  { ten = "Pham Nhan", en = "Mortal", coi = 1 },
  { ten = "Luyen Khi", en = "Qi Refining", coi = 1 },
  { ten = "Truc Co", en = "Foundation", coi = 1 },
  { ten = "Kim Dan", en = "Golden Core", coi = 1 },
  { ten = "Nguyen Anh", en = "Nascent Soul", coi = 1 },
  { ten = "Hoa Than", en = "Spirit Severing", coi = 2 },
  { ten = "Luyen Hu", en = "Void Refining", coi = 2 },
  { ten = "Hop The", en = "Body Integration", coi = 2 },
  { ten = "Dai Thua", en = "Great Ascension", coi = 2 },
  { ten = "Do Kiep", en = "Tribulation", coi = 2 },
  { ten = "Chan Tien", en = "True Immortal", coi = 3 },
  { ten = "Thien Tien", en = "Heavenly Immortal", coi = 3 },
  { ten = "Kim Tien", en = "Golden Immortal", coi = 3 },
  { ten = "Thai At", en = "Taiyi", coi = 3 },
  { ten = "Dai La", en = "Great Luo", coi = 3 },
  { ten = "Tien De", en = "Immortal Emperor", coi = 4 },
  { ten = "Thanh Nhan", en = "Saint", coi = 4 },
  { ten = "Dao To", en = "Dao Ancestor", coi = 4 },
  { ten = "Hon Don Than", en = "Primordial God", coi = 4 },
  { ten = "Sang The Than", en = "World Creator", coi = 4 },
}

-- Doi so nay la doi tong so stage. Moi cong thuc suy ra tu no, khong
-- hard-code so 11 o dau ca.
CFG.TIERS_PER_REALM = 10
CFG.TIER_VIEN_MAN   = "vien man"   -- ten rieng cua tang cuoi

-- ---------- Thanh phan wave ----------
CFG.WAVE_MOB_COUNT   = 50    -- co dinh, khong doi theo so nguoi (ADR 0009)
CFG.WAVE_ELITE_COUNT = 1

-- Giay moi wave, theo coi. Day la nut chinh THOI LUONG VAN, va no cung
-- chinh DPS can -- hai thu dinh nhau.
CFG.WAVE_TIME = { 20.0, 28.0, 36.0, 45.0 }
CFG.WAVE_FIRST_DELAY = 15.0

-- Don sach wave thi vao wave sau NGAY, khong ngoi cho het dong ho.
--
-- Dong ho van chay song song: het gio la wave sau ra du con song hay
-- khong. Hai co che khong thay the nhau --
--   don sach som  -> vao som, khong co thoi gian chet
--   don khong kip -> quai don lai, dung nhu truoc
-- Nen ap luc giu nguyen, chi mat phan ngoi nhin dong ho.
-- Dot DAU TIEN doi goi bang "-next" thay vi tu ra sau WAVE_FIRST_DELAY.
-- De co thoi gian nhin map, xem bang, nang ky nang truoc khi vao tran.
-- Cac dot sau van chay binh thuong.
CFG.WAVE_WAIT_FIRST  = true

CFG.WAVE_AUTO_NEXT   = true
CFG.WAVE_CLEAR_DELAY = 1.5   -- giay, de kip doc chu truoc khi wave sau ra

-- Tran unit song. Qua nguong thi HOAN wave moi thay vi chong them.
CFG.WAVE_MAX_ALIVE = 300

-- Xe dich diem sinh de 50 con khong chong len nhau mot cho.
CFG.SPAWN_JITTER = 384.0

-- Giay giua hai lan ra lenh lai + kiem quai da cham nha chua.
CFG.WAVE_TICK = 2.0

-- ---------- Duong cong chi so ----------
-- EHP la dai luong that; mau dat len unit duoc suy nguoc ra tu giap.
-- Doi MOB_ARMOR_PER_REALM KHONG doi do kho. (ADR 0010)
CFG.MOB_EHP_BASE       = 20.0
CFG.MOB_EHP_GROWTH     = 1.018   -- moi stage. Rat nhay: mu 219
CFG.MOB_EHP_REALM_STEP = 1.22    -- moi canh gioi. Mu 19

CFG.MOB_DMG_BASE       = 6.0
CFG.MOB_DMG_GROWTH     = 1.016
CFG.MOB_DMG_REALM_STEP = 1.12

CFG.MOB_ARMOR_BASE      = 0.0
CFG.MOB_ARMOR_PER_REALM = 1.0
CFG.ARMOR_DR_PER_POINT  = 0.06   -- cong thuc giap cua Warcraft III

CFG.ELITE_EHP = 10.0
CFG.ELITE_DMG = 2.5
CFG.ELITE_SCALE = 3.2   -- gap doi 1.6 cu: tinh anh phai nhin ra ngay
CFG.BOSS_EHP  = 80.0
CFG.BOSS_DMG  = 3.0
CFG.BOSS_SCALE = 2.2

-- ---------- Theo so nguoi choi (ADR 0009) ----------
-- Phai < 1.0: bang 1.0 la phat nguoi choi vi ru duoc ban.
CFG.SCALE_EHP_PER_PLAYER      = 0.60
CFG.SCALE_DMG_PER_PLAYER      = 0.15   -- nho, vi sat thuong da tu loang
CFG.SCALE_BOSS_EHP_PER_PLAYER = 0.85   -- cao hon: boss mot than, don ha hieu qua hon
CFG.SCALE_RECOUNT_EACH_WAVE   = true

-- ---------- Mau linh theo coi ----------
-- PLACEHOLDER. Ban thiet ke can 4 coi x 6 mau = 24 unit type trong
-- Object Editor. Hien moi coi mot mau de he wave chay duoc truoc.
CFG.MOB_UNIT = {
  id('hfoo'),   -- Pham : Footman
  id('ugho'),   -- Yeu  : Ghoul
  id('uabo'),   -- Tien : Abomination
  id('ufro'),   -- Than : Frost Wyrm
}

-- ---------- Mau nha chinh ----------
-- Nha nhan sat thuong, chet la thua. Khong co dem mang, khong co lot.
--
-- Mau CO DINH khong dung duoc: sat thuong dich tang x279 qua 220 stage,
-- nen 1000 mau o stage 220 chet trong DUOI MOT GIAY. Thay vao do tinh
-- theo "chiu duoc bao nhieu don cua mot con linh", va tinh lai moi wave
-- -- ti le song sot giu nguyen suot van:
--
--   mau toi da = HOUSE_HP_HITS x sat thuong mot con linh o stage do
--
-- Voi 400: 3 con lot thi nha cam 133 giay, 50 con lot thi 8 giay.
-- Day la MOT con so duy nhat chinh do khoan dung cua ca map.
CFG.HOUSE_HP_HITS = 400

-- Hoi bao nhieu phan mau toi da moi wave. Khong co hoi mau thi sat
-- thuong tich luy va nha chet chac chan du choi gioi den may.
CFG.HOUSE_REGEN_PER_WAVE = 0.20

-- ---------- Kinh te ----------
-- Thu nhap bam x967 (hop dong suc manh), KHONG bam x2176 (duong cong
-- EHP dich). Bam nham la nua sau game qua de.
CFG.LINHKHI_BASE   = 60.0
CFG.LINHKHI_GROWTH = 1.0319    -- = 967^(1/219)
CFG.LINHKHI_MOB_SHARE = 0.60   -- 50 linh chia 60%, tinh anh 40%

-- Khong co cong tac "chia theo nguoi ket lieu". Da do: cach do lam ba
-- nguoi choi moi nguoi thieu 41% so tien can. Xem ADR 0013.

-- ---------- Gia nang cap ky nang ----------
-- Moi bac ky nang trai 2 canh gioi, nen buoc gia = buoc Linh Can binh
-- phuong (1.412^2). Nho vay "nang ca 7 skill mot bac" luon xap xi "mot
-- lan dot pha Linh Can" cung thoi diem -- ti le 0.99..1.01 suot 220 stage.
-- Do la mot lua chon doc duoc, khong phai hai duong cong khong lien quan.
CFG.SKILL_COST_BASE = 89.0     -- bac 1 -> 2
CFG.SKILL_COST_STEP = 1.99
CFG.SKILL_MAX_LEVEL = 10

-- ---------- Mo khoa ky nang ----------
--
-- Hero KHONG co san ca bay ky nang. Bat dau voi SKILL_START_COUNT cai
-- dau tien, nam cai con lai mua bang Linh Khi.
--
-- Hai ly do:
--  1. Ca bay ngay tu stage 1 thi khong con gi de mong. Bay o trong
--     command card day ngay giay dau la het chuyen.
--  2. Phep tinh he so 1.32 cho Dam Dat chi dem BA nguon: danh thuong,
--     chem lan, Dam Dat. Cho ca bay ngay tu dau la hero manh hon hop
--     dong stage 1 rat nhieu, dau van thanh de khong.
--
-- Gia suy tu duong cong thu nhap: mo duoc skill thu k vao khoang stage
-- MOC[k] = {3:15, 4:40, 5:75, 6:120, 7:170}, neu danh 22% thu nhap cong
-- don cho viec mo khoa. Xem docs/03-du-lieu/nang-cap-ky-nang.md
CFG.SKILL_START_COUNT = 2

-- Gia theo SO CAI DA MO, khong theo cai nao. Mo cai thu 3 la 250 du do
-- la ky nang nao -- nguoi choi thich mo cai nao truoc thi mo, khong bi
-- ep thu tu.
CFG.SKILL_UNLOCK = { 0, 0, 250, 790, 2910, 13560, 68210 }

-- ---------- Bay ky nang cua tung hero ----------
--
-- heSo : sat thuong/hoi mau = heSo x (LINHCAN_DMG_BASE + chi so CAO NHAT
--        cua hero). An theo chi so cao nhat nen skill khong bao gio phe,
--        va bam dung duong cong Linh Can.
-- pct  : ky nang bi dong tinh theo PHAN TRAM. Cong thang mot luong co
--        dinh thi cuoi game vo nghia -- Linh Can cong +1075 moi chi so.
-- cd   : hoi chieu bac 1, giay.
--
-- Moi so o day la bac 1. Bac 2..10 suy ra tu SKILL_*_STEP o tren.
-- Cach ra he so 1.32 cua A001: docs/03-du-lieu/nang-cap-ky-nang.md
CFG.SKILLS = {}

CFG.SKILLS[id('H001')] = {
  -- HAI CAI DAU la ky nang phat san (CFG.SKILL_START_COUNT). Xep dau
  -- bang la chu dich: Chem Lan don quai dong, Chuong don theo duong --
  -- du hai viec de song qua nhung canh gioi dau.
  { id = id('A005'), ten = "Chem Lan", en = "Cleaving Blow",   loai = "bidong",  pct = 0.20,
    mota = "Don danh van %s sat thuong sang muc tieu ben canh.",
    mota_en = "Attacks splash %s damage to nearby targets." },
  { id = id('A001'), ten = "Chuong", en = "Palm Strike",       loai = "chudong", heSo = 1.32, cd = 8.0, mana = 25,
    mota = "Gay %s sat thuong len mot duong thang.",
    mota_en = "Deals %s damage in a line." },

  -- Nam cai duoi mua bang Linh Khi, THU TU NAO CUNG DUOC. Gia phu thuoc
  -- da mo bao nhieu cai, khong phu thuoc mo cai nao.
  { id = id('A002'), ten = "Ho The", en = "Guarding Light",    loai = "chudong", heSo = 2.20, cd = 10.0, mana = 30,
    mota = "Hoi %s mau cho ban than hoac dong doi.",
    mota_en = "Heals %s to yourself or an ally." },
  { id = id('A003'), ten = "Hieu Lenh", en = "Rallying Order", loai = "aura",    pct = 0.15,
    mota = "Dong doi quanh ban duoc +%s giap ban than.",
    mota_en = "Allies near you gain +%s of their armor." },
  { id = id('A004'), ten = "Luyen The", en = "Body Forging",   loai = "bidong",  pct = 0.12,
    mota = "+%s ca ba chi so.",
    mota_en = "+%s to all three attributes." },
  { id = id('A006'), ten = "Da Sat", en = "Ironhide",          loai = "bidong",  pct = 0.05,
    mota = "Giam %s sat thuong nhan vao. Tran cung 10%%.",
    mota_en = "Reduces incoming damage by %s. Hard cap 10%%." },
  { id = id('A007'), ten = "Bat Hoai", en = "Indestructible",  loai = "chudong", heSo = 0.0, cd = 60.0, mana = 60,
    mota = "Tang manh giap va mau trong thoi gian ngan.",
    mota_en = "Greatly raises armor and health for a short time." },
}

CFG.OP_SKILL_UP = 6   -- arg = so thu tu ky nang trong CFG.SKILLS cua hero

-- Bat khi bo sinh da ghi so lieu vao war3map.w3a VA cac skill bi dong da
-- duoc viet bang Lua. Con false thi bang phim E noi ro con so dang hien
-- la thiet ke chu chua co hieu luc -- trong game van la so goc cua
-- Warcraft. Bang ma hien so dep nhung sai thi te hon la khong hien.
CFG.SKILL_DATA_LIVE = false

-- Suc manh moi bac. Ngan sach cho ca he nang cap la x2 (xem
-- docs/03-du-lieu/duong-cong-suc-manh.md). x2 la TICH cua moi nut chinh,
-- khong phai rieng sat thuong.
CFG.SKILL_DMG_STEP  = 1.0322   -- 1.33 sau 9 lan nang
CFG.SKILL_CD_STEP   = 0.9560   -- 0.667 sau 9 lan nang -> tan suat x1.5
CFG.SKILL_PASSIVE_STEP = 1.0801 -- 2.00 sau 9 lan nang (bi dong khong co cooldown)

-- Mana moi bac. Tang CHAM hon nhieu so voi bo mana (Linh Can cong ca ba
-- chi so nen Int, tuc bo mana, len rat nhanh). Y dinh: dau van mana la
-- mot rang buoc that, cuoi van thi khong con -- luc do van de la hoi
-- chieu chu khong phai mana.
--
-- Mana goc cua Shockwave la 100, ma Hart cap 1 co 75 mana -- khong cast
-- noi mot lan nao. Do la ly do phai dat lai tu Lua.
CFG.SKILL_MANA_STEP = 1.05   -- x1.55 sau 9 lan nang

CFG.TINHTHACH_BOSS_BASE = 10   -- boss canh gioi r roi BASE + STEP*(r-1)
CFG.TINHTHACH_BOSS_STEP = 5

-- ============================================================
--  LINH CAN  --  tu vi cua nguoi choi
--  docs/02-he-thong/kinh-te.md · bang-nhan-vat.md
--
--  Nguon suc manh LON NHAT cua nguoi choi: x20 trong hop dong x967.
--  Dung chung thang ten voi 20 canh gioi cua phe dich -- nguoi choi va
--  ke dich tu tien tren cung mot con duong.
-- ============================================================

-- 1.215, KHONG phai 1.17. Voi 1.17 thi 19 buoc chi cho x19.7, nhan voi
-- trang bi x12 va ky nang x2 la x474 -- trong khi hop dong can x967.
-- Tuc cuoi game nguoi choi chi manh bang 49% muc can, thua chac.
-- 1.215^19 = x40.5  ->  40.5 x 12 x 2 = x971 ~ x967. Xem
-- docs/03-du-lieu/duong-cong-suc-manh.md
CFG.LINHCAN_STEP = 1.215

-- Gia dot pha bac r = BASE x STEP^(r-1).
-- 1.412 = 1.0319^11 = thu nhap tron mot canh gioi, nen gia luon dang
-- dung 7,1 wave o MOI bac. Xem kinh-te.md.
CFG.LINHCAN_COST_BASE = 439.0
CFG.LINHCAN_COST_STEP = 1.412

-- Hai so de GIAI NGUOC ra chi so can dat.
--
-- Nhan thang chi so len x1.17 moi bac la SAI: sat thuong hero =
-- sat thuong nen + chi so chinh, phan nen lam loang nhan so. Do thang
-- chi so x19.7 chi cho x10.4 sat thuong -- thieu mot nua.
--
--   chiSo(r) = (DMG_BASE + STAT_BASE) x STEP^(r-1) - DMG_BASE
--
-- Doi hai so nay cho khop hero that trong Object Editor thi nhan so moi
-- dung. Bang "-lc" trong game in ra nhan so THUC DO duoc de doi chieu.
CFG.LINHCAN_DMG_BASE  = 17.0   -- sat thuong hero khi chi so = 0
CFG.LINHCAN_STAT_BASE = 10.0   -- chi so hero luc bac 1

-- Cong vao chi so nao:
--
-- "all"     ca ba Str/Agi/Int deu cong bang nhau.
--           Duoc : Str cho mau (phuc vu hop dong EHP x279), Int cho
--                  mana (Support can), Agi cho giap.
--           Mat  : Agi con cho TOC DANH -- do la DPS NGOAI ngan sach
--                  x967. O bac 20 la +749 Agi, khong phai it.
--
-- "primary" chi cong vao chi so dang cao nhat.
--           Duoc : sat thuong dung x19.7, khong thua khong thieu.
--           Mat  : hero khong tang mau/mana -- phai lay tu Trang Bi.
--
-- Chua do duoc cai nao dung hon: ti le Agi -> toc danh nam trong
-- Gameplay Constants cua map, va chua choi thu wave nao. Bat dau bang
-- "all" vi no phuc vu nhieu hop dong cung luc; doi sang "primary" neu
-- do thay hero manh vuot duong cong.
CFG.LINHCAN_STAT_MODE = "all"

-- ---------- Chu bay (floating combat text) ----------
-- Warcraft III chi cho ~100 text tag ton tai cung luc. Mot wave 50 con,
-- ve moi don danh mot chu la vai giay sau dat tran va TU DO khong con
-- chu nao hien nua. Nen sat thuong duoc cong don roi moi ve.
CFG.FCT_ENABLED   = true
CFG.FCT_SHOW_GOLD = true
CFG.FCT_FLUSH     = 0.40    -- giay gom sat thuong truoc khi ve
CFG.FCT_MAX_TAGS  = 12      -- toi da bao nhieu chu moi lan ve
CFG.FCT_MIN       = 1.0     -- duoi nguong nay khong ve
CFG.FCT_SIZE      = 0.022
CFG.FCT_HEIGHT    = 16.0
CFG.FCT_RISE      = 0.045
CFG.FCT_LIFE      = 1.4

-- Giao dien bang nhan vat (phim E). Bon he dung chung khung nay.
CFG.PANEL_X = 0.40
CFG.PANEL_Y = 0.36
CFG.PANEL_W = 0.46    -- rong ra: dong ky nang co ten + bac + so lieu + gia
-- Cao cua bang SUY RA tu so dong trong 4_giao_dien/1_panel.lua, khong
-- go tay o day -- de o day thi them mot dong la tran ra ngoai khung.

-- Ke vach xen ke cho de doc. Tat neu thay roi mat.
CFG.PANEL_GRID     = true
CFG.PANEL_GRID_TEX = [[ReplaceableTextures\TeamColor\TeamColor27]]
