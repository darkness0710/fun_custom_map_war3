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
-- OP_SKILL_UP = 6, khai bao canh bang CFG.SKILLS ben duoi.
CFG.OP_TB_UP  = 7   -- arg = so thu tu o trang bi trong CFG.TRANGBI
CFG.OP_PK_BUY = 8   -- arg = so thu tu phap khi trong CFG.PHAPKHI
CFG.OP_SHOP   = 9   -- arg = so thu tu mon trong CFG.SHOP
CFG.OP_ITEM   = 10  -- arg = o tui 0..5, dung do bang phim so
CFG.OP_QUAY   = 11  -- arg = so thu tu the 1..3 trong luot quay
-- Opcode KHONG bi chan o mot chu so: unpackMsg dung math.floor(v/10^7)
-- nen op 10, 11... van giai duoc. Thu bi chan la arg (< 10^5) va seq
-- (< 100). Xem src/1_nen/3_sync.lua.

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

-- Nha chinh phai DUNG YEN.
--
-- CFG.HOUSE_UNIT dang la Hmkg -- Mountain King -- mot unit HERO co chan,
-- va no thuoc mot slot may (CFG.HOUSE_SLOT). Unit co chan cua slot may
-- thi tu di loanh quanh: do la AI mac dinh cua Warcraft, khong phai loi
-- code nao cua du an.
--
-- Nha chinh la MUC TIEU, khong phai dien vien. No khong can di dau ca.
CFG.HOUSE_FROZEN = true

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

-- Mo toan bo suong mu. Day la LUAT CUA MAP, khong phai cong tac dev.
--
-- Map nay la thu tran: quai di theo duong co san toi nha chinh, khong co
-- gi de trinh sat va khong ai giau quan duoc. Suong mu o day khong tao
-- ra quyet dinh nao, no chi lam nguoi choi khong thay dot quai dang toi.
CFG.REVEAL_MAP = true

-- "frame"  the chon co icon, tu ve bang BlzCreateFrame
-- "dialog" popup chu cua Warcraft III -- xau hon nhung chac chan chay
CFG.HERO_PICK_MODE = "frame"

-- CFG.PICK_TITLE da chuyen sang 6_lang.lua, khoa "pick_title".

-- ---------- Bang chon hero ----------
-- Toa do man hinh: X 0.0..0.8, Y 0.0..0.6.
--
-- BO CUC MOT COT DOC: moi hero mot dong, rong bang ca bang.
--
-- Truoc day la ba the ngang moi the rong 0.17. Bo vi frame chu cua
-- Warcraft KHONG tu xuong dong, va text frame khong dat kich thuoc thi
-- bi can giua quanh diem neo -- mot dong mo ta dai hon 0.17 la tran ra
-- hai ben va de len chu cua the ben canh. Chu cang dai vung de cang
-- rong, nen loi luc co luc khong.
--
-- No con ep 'mota' phai ngan 3-4 tu: mot rang buoc sinh ra tu han che
-- ky thuat chu khong tu thiet ke. Dong rong bang ca bang thi chu luon
-- co cho, va rang buoc do bien mat.
CFG.CARD_W     = 0.360   -- be ngang vung noi dung = be ngang mot dong
CFG.CARD_GAP   = 0.005   -- khoang cach hai dong
CFG.CARD_ICON  = 0.040   -- canh o icon
CFG.CARD_PAD   = 0.010   -- le trong
-- Vien trang tri cua backdrop an mat mep trong. EscMenuBackdrop co
-- vien day, va CARD_PAD mot minh khong du -- tieu de leo len dung
-- duong vien vang. Do bang mat tren anh chup 1080p.
CFG.CARD_BORDER = 0.010
CFG.CARD_LINE  = 0.014   -- khoang cach hai dong chu ben trong mot dong
CFG.CARD_X     = 0.40    -- tam ngang cua bang
CFG.CARD_Y     = 0.38    -- tam doc

-- CFG.CARD_H va CFG.CARD_TOP da bo. Cao mot dong SUY RA tu co icon va
-- so dong chu (xem rowH trong 2_heroframe.lua) -- de o day thi doi co
-- chu mot cai la chu tro ra ngoai vien, dung loi ma bang phim E da dinh
-- mot lan roi.

-- Co chu. 1.0 la co mac dinh cua Warcraft.
--
-- Ba muc khac nhau de co PHAN CAP: khong co no thi ten hero, vai va mo
-- ta cung mot co, nhin vao chi thay mot khoi chu deu deu.
CFG.CARD_SCALE_TITLE = 1.25
CFG.CARD_SCALE_NAME  = 1.10
CFG.CARD_SCALE_DESC  = 0.90

-- Template FDF lam nen bang, thu lan luot tu tren xuong.
--
-- Het thi lui ve CFG.FRAME_BG -- va day la ly do phai co danh sach nay:
-- FRAME_BG la TeamColor27, mot bang mau DAC 1x1 pixel von dung de to
-- mau phe. Keo no lam nen thi duoc dung mot hinh chu nhat xam phang,
-- khong vien khong bo goc. Template co san cua game co vien that.
--
-- Da dung duong nao thi doc o file vet, dong "herocard: nen =".
CFG.CARD_BACKDROP = { "EscMenuBackdrop", "QuestButtonBaseTemplate" }

-- Template nut cho MOT DONG hero.
--
-- Dong la hinh rong-va-thap, dung ti le von co cua mot nut tab -- nen
-- ScoreScreenTabButtonTemplate hop o day. Chinh no keo thanh the vuong
-- 0.17 x 0.20 thi phan trang tri hai dau gian ra meo mo, va do la mot
-- phan ly do bo cuc cu nhin xau.
--
-- Nut khong an hoac nhin sai thi thu:
--   "ScriptDialogButton"  "IconButtonTemplate"
--   "StandardLightButtonTemplate"  "DebugButton"
CFG.CARD_BUTTON_TEMPLATE = "ScoreScreenTabButtonTemplate"

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
--  DOT QUAI  --  100 stage
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
-- hard-code so 5 o dau ca.
--
-- 10 -> 4 (2026-09-17). Mot canh gioi gio la 4 wave + 1 boss = 5 stage,
-- ca van 20 x 5 = 100 stage thay vi 220.
--
-- Bon tang co TEN rieng chu khong danh so, xem CFG.TIER_NAMES: "Truc Co
-- So Ki" doc ra nghia ngay, con "Truc Co Tang 3" thi phai nho tang 3
-- tren tong bao nhieu.
CFG.TIERS_PER_REALM = 4

-- Ten bon tang trong mot canh gioi. So phan tu PHAI bang
-- TIERS_PER_REALM -- wave.lua lui ve danh so neu thieu.
CFG.TIER_NAMES = {
  { ten = "So Ki",    en = "Early" },
  { ten = "Trung Ki", en = "Middle" },
  { ten = "Hau Ki",   en = "Late" },
  { ten = "Vien Man", en = "Perfection" },
}

-- CFG.TIER_VIEN_MAN da chuyen sang 6_lang.lua, khoa "tier_full". Ten
-- tang cuoi la CHU HIEN THI chu khong phai tham so, ma chu hien thi
-- phai co ca hai thu tieng. Cung ly do voi CFG.PICK_TITLE truoc day.

-- ---------- Thanh phan wave ----------
CFG.WAVE_MOB_COUNT   = 50    -- co dinh, khong doi theo so nguoi (ADR 0009)
CFG.WAVE_ELITE_COUNT = 1

-- Giay moi wave, theo coi. Day la nut chinh THOI LUONG VAN, va no cung
-- chinh DPS can -- hai thu dinh nhau.
-- RANG BUOC, khong phai so chinh tu do:
--
--   WAVE_TIME[coi]  >  quang duong/toc do  +  thoi gian giet het mot dot
--
-- Thieu ve phai thi nhanh "don sach -> vao dot sau" KHONG BAO GIO chay
-- duoc: map khong bao gio sach, nen S.alive khong bao gio ve 0, nen ca
-- WAVE_AUTO_NEXT lan lenh -next deu chet.
--
-- Do duoc (cua quai cach nha 5,361 don vi):
--   coi 1  Footman     270  di 19.9s  -> can >= 30s, truoc day dat 20  SAI
--   coi 2  Ghoul       350  di 15.3s  -> can >= 25s, dat 28            ok
--   coi 3  Abomination 190  di 28.2s  -> can >= 38s, truoc day dat 36  SAI
--   coi 4  Frost Wyrm  200  di 26.8s  -> can >= 37s, dat 45            ok
--
-- Vi sao coi 1 (32s) lai DAI HON coi 2 (28s) du de hon: WAVE_TIME khong
-- phai thuan do kho -- no bi chan duoi boi TOC DO MAU LINH. Footman cua
-- coi 1 cham hon Ghoul cua coi 2, nen no can nhieu giay hon du wave de
-- hon. Doi CFG.MOB_UNIT la phai tinh lai bang nay.
CFG.WAVE_TIME = { 32.0, 28.0, 40.0, 45.0 }
CFG.WAVE_FIRST_DELAY = 15.0

-- ---------- Dot moi chi ra khi dot cu da don sach ----------
--
-- Ban truoc: dong ho chay song song, het WAVE_TIME giay la dot sau ra
-- DU CON SONG HAY KHONG. Y do la "ap luc chinh".
--
-- No sai, va sai theo kieu khong go lai duoc. Mot con tinh anh mau day
-- song qua het WAVE_TIME thi dot sau chong len dot truoc; dot sau nua
-- lai chong tiep; moi dot them lai keo dai dot dang do. Nguoi choi
-- khong co hanh dong nao ngan duoc day chuyen do -- danh nhanh hon
-- chinh la thu ho dang khong lam duoc.
--
-- Va no mau thuan voi luat da co o "-next": lenh do TU CHOI khi con
-- quai song, vi goi som la bo qua phan kho de an tien dot sau. Dong ho
-- lam dung viec ma -next bi cam lam.
--
-- Dat false thi ap luc dong ho quay lai y nhu cu.
CFG.WAVE_ONLY_WHEN_CLEAR = true

-- Don sach wave thi vao wave sau NGAY, khong ngoi cho het dong ho.
--
-- Voi WAVE_ONLY_WHEN_CLEAR bat thi day la duong VAO DOT SAU CHINH, con
-- dong ho chi la luoi do: no chi ban khi S.alive = 0, ma luc do nhanh
-- nay da chay roi. Giu dong ho lai de phong truong hop quai bien mat ma
-- khong sinh su kien chet -- luc do S.alive ve 0 nhung onMobDeath khong
-- he chay.
-- Dot DAU TIEN doi goi bang "-next" thay vi tu ra sau WAVE_FIRST_DELAY.
-- De co thoi gian nhin map, xem bang, nang ky nang truoc khi vao tran.
-- Cac dot sau van chay binh thuong.
CFG.WAVE_WAIT_FIRST  = true

CFG.WAVE_AUTO_NEXT   = true
CFG.WAVE_CLEAR_DELAY = 1.5   -- giay, de kip doc chu truoc khi wave sau ra

-- ---------- Nghi giua hai canh gioi ----------
--
-- Dong ho chay suot 10 tang, roi DUNG HAN o hai moc:
--
--   tang 1..10        dong ho chay        <- ap luc, dot chong duoc
--   tang 10 don sach  DUNG dong ho        <- nghi
--     -next           BOSS
--   boss chet         DUNG dong ho        <- nghi, tieu Go
--     -next           canh gioi sau
--
-- Vi sao khong bo han dong ho cho ca 5 stage: WAVE_TIME la thu DUY NHAT
-- con ep "wave phai ha kip gio". Quai bam theo duong cong Tu Vi nen do
-- kho tu can bang, nhung no khong noi gi ve TOC DO -- khong co dong ho
-- thi mot doi danh cham van thang, chi lau hon.
-- Giu dong ho trong 10 tang thi ap luc con nguyen, ma van co nhip.
--
-- Va no sua mot loi that: mo bang phim E khong dung game (frame khong
-- dung game duoc), nen truoc day mua sam nghia la dung chiu don. Gio
-- viec do co cho cua no.
CFG.WAVE_REST = true

-- Tran unit song. Qua nguong thi HOAN wave moi thay vi chong them.
CFG.WAVE_MAX_ALIVE = 300

-- Xe dich diem sinh de 50 con khong chong len nhau mot cho.
CFG.SPAWN_JITTER = 384.0

-- Giay giua hai lan ra lenh lai + kiem quai da cham nha chua.
CFG.WAVE_TICK = 2.0

-- ---------- Duong cong chi so ----------
-- EHP la dai luong that; mau dat len unit duoc suy nguoc ra tu giap.
-- Doi MOB_ARMOR_PER_REALM KHONG doi do kho. (ADR 0010)
-- 120 chu khong phai 20: do tu yeu cau "Chuong phat dau mat 1/3 mau o
-- wave 1". Chuong bac 1 = 1.32 x (17 + 13) = 39.6 sat thuong, nen mau
-- quai wave 1 phai la 3 x 39.6 = 119 -> lam tron 120.
--
-- Voi 20 mau nhu truoc thi Chuong mot phat giet ba con -- khong con
-- cam giac danh nhau nao o nhung wave dau.
CFG.MOB_EHP_BASE       = 120.0
-- Voi MOB_EHP_THEO_LINHCAN: mu la (TANG - 1), tuc 0..3 trong mot canh
-- gioi -- mot doc nho de tang 4 khac tang 1. Khong con mu theo stage
-- toan cuc, vi phan do da nam trong he so Linh Can roi.
CFG.MOB_EHP_GROWTH     = 1.018
-- QUAI BAM THEO DUONG CONG LINH CAN, khong co duong cong rieng nua.
--
-- Ban truoc quai nhan deu MOB_EHP_REALM_STEP moi canh gioi, con hero
-- thi khong nhay deu: lan dot pha dau x2.85 (vi +50 tren nen 10), roi
-- tut dan ve x1.30. Mot ben deu, mot ben khong -- nen hero vuot len o
-- dau van (bac 4-5 giet quai MOT PHAT) roi tut lai o cuoi.
--
-- Chon mot hang so nao cung khong sua duoc, vi hai duong cong khac HINH
-- chu khong chi khac do doc.
--
-- Gio EHP quai = MOB_EHP_BASE x (he so Linh Can cua canh gioi do)
--                             x MOB_EHP_GROWTH^(tang - 1)
--
-- Ti le "may phat Chuong mot con" phang theo DINH NGHIA: ca hai ve deu
-- co cung thua so he so Linh Can, no triet tieu.
--
-- Hop dong ngam: nguoi choi len dung MOT bac moi canh gioi -- va do
-- chinh la giao keo 500 Linh Khi/canh gioi = 500 mot lan dot pha.
CFG.MOB_EHP_THEO_LINHCAN = true

-- Chi con dung khi MOB_EHP_THEO_LINHCAN = false.
CFG.MOB_EHP_REALM_STEP = 1.22    -- moi canh gioi. Mu 19

-- Mu cua he so Linh Can dung cho SAT THUONG quai (< 1 = quai doc cham
-- hon hero khoe len). Chi dung khi MOB_EHP_THEO_LINHCAN bat.
CFG.MOB_DMG_THEO_MU    = 0.85

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
-- Mau CO DINH khong dung duoc: sat thuong dich tang x339 qua 100 stage
-- (do lai 2026-09-17 sau khi quai bam theo duong cong Linh Can), nen
-- 1000 mau o stage 100 chet trong DUOI MOT GIAY. Thay vao do tinh
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
-- Thu nhap khong bam theo duong cong nao nua: no PHANG, va moi canh
-- gioi kiem dung mot lan dot pha. Do la ca hop dong.
-- ---------- THU NHAP: PHANG, mot con mot dong ----------
--
-- Ban truoc thu nhap la duong cong mu: 60 x 1.0319^(stage-1), ca van
-- 1,880,187 Linh Khi. Bo han. Gio moi con tra dung mot so co dinh, va
-- so do khong doi theo stage:
--
--   quai thuong    1 Linh Khi + 1 Vang
--   tinh anh      50 Linh Khi + 2 Go
--   boss         100 Linh Khi + 5 Go
--
-- So Linh Khi chon de MOT CANH GIOI kiem dung MOT lan dot pha:
--   1 wave      = 50 quai x1 + 1 tinh anh x50 = 100
--   1 canh gioi = 4 wave (400) + boss (100)   = 500
--   1 dot pha                                 = 500  <- phang
--
-- Ca van: Linh Khi 10,000 | Vang 4,000 | Go 260
--
-- Doi lai: gia cua moi he cung phai phang theo, khong con duong cong mu
-- nao bam theo thu nhap duoc nua. Do la ly do LINHCAN_COST_STEP tut tu
-- 1.412 xuong 1.08.
CFG.THUONG_MOB_LINHKHI = 1
CFG.THUONG_MOB_VANG    = 1
CFG.THUONG_ELITE_LINHKHI = 50
CFG.THUONG_BOSS_LINHKHI  = 100
CFG.THUONG_ELITE_GO    = 2
CFG.THUONG_BOSS_GO     = 5

-- Khong co cong tac "chia theo nguoi ket lieu". Da do: cach do lam ba
-- nguoi choi moi nguoi thieu 41% so tien can. Xem ADR 0013.

-- ---------- Gia nang cap ky nang: tra bang NGO TINH ----------
--
-- Ky nang KHONG mua bang Linh Khi nua. Ly do o docs/02-he-thong/kinh-te.md:
-- bon he ma ba he cung rut mot cai vi thi khong he nao co ban sac rieng,
-- va nguoi choi chi phai tra loi dung mot cau hoi ("gom du tien chua").
--
-- Go la DIEM, khong phai tien: khong co duong cong mu, khong bam
-- theo thu nhap. Nho vay bo duoc han mot duong cong phai can bang, va
-- "nang ky nang" tro thanh cau hoi khac han "mua gi" -- no hoi "da giet
-- du tinh anh chua".
--
-- MOT diem cho moi lan, ke ca lan mo khoa. Khong co bang, khong co
-- duong cong.
--
-- Truoc day gia tang dan { 1,2,2,3,3,4,4,5,5 } va mo khoa tang theo so
-- cai da mo. Bo het: voi gia phang thi nguoi choi khong phai tinh toan
-- gi ca, chi phai chon THU TU -- mo cai nao truoc, don bac cai nao.
--
-- Tong chi de mo va max tron bay ky nang:
--   7 x (1 mo khoa + 9 lan nang) = 70 go, tren 260 go ca van.
-- Ky nang tra bang GO. Go chi roi tu tinh anh (2) va boss (5), ca van
-- duoc 260 -- nen no bi chan boi "da giet du tinh anh chua", khong phai
-- "da gom du tien chua".
--
-- MOT go mot lan. Day la con so chu du an chot, khong phai con so suy
-- ra tu ngan sach -- toi da tu doi no thanh 3 va bi tra lai.
--
-- He qua da biet va da chap nhan: tron bay ky nang chi ton 70/260 go,
-- va voi 13 go moi canh gioi thi MAX HET O STAGE 27 -- roi 73 stage
-- cuoi go chi tang chu khong tieu duoc. Phan du (190) de danh cho Phap
-- Khi khi he do mo lai; tu gio den luc do no la con so chet.
CFG.SKILL_GO_UNLOCK = 1    -- mo khoa mot ky nang
CFG.SKILL_GO_UP     = 1    -- nang mot bac
CFG.SKILL_MAX_LEVEL  = 10

-- ---------- TAT hieu ung goc cua ability ban sao ----------
--
-- Mot ability nhan ban van GIU NGUYEN hieu ung cua ability goc. Chuong
-- la ban sao cua Shockwave nen NO tu gay 110 sat thuong, roi fxLine
-- cong them 39.6 nua o tren -- bang ghi 39.6 ma man hinh hien 111.
--
-- Va so goc do la HANG SO: no dung yen o 110 suot van trong khi duong
-- cong cua du an len x26. Dau van skill manh gap ba lan bang ghi, cuoi
-- van phan goc thanh vun. Khong tat thi CFG.SKILL_DATA_LIVE noi doi.
--
-- TEN HANG SO DO DUOC bang "-nat spell" (2026-09-17), khong phai doan:
-- ban 1.31.1 co du cac ham Blz*AbilityRealLevelField nhung THIEU
-- ABILITY_RLF_DAMAGE_HCA1, nen ten hang moi ban moi khac.
--
-- CHI tat cai ma Lua da tu lam thay:
--   A001 sat thuong  -> fxLine
--   A002 hoi mau     -> fxHeal
-- (A003 va A007 KHONG con o day: giap cua chung chuyen sang
--  CFG.SKILL_CHO_GOC -- ghi so vao truong goc thay vi tat.)
--
-- CHUA tat duoc, van con cong chong:
--   A005 Chem Lan   -- "-nat spell" chua ra ten hang: ma goc ACce khop
--                      nham vao ABILITY_BLF_ACCEPTS_* ("ACCEPTS" chua
--                      "CCE"). Do lai bang "-nat cleav".
--   A006 Da Sat     -- ban sao cua Attribute Bonus va KHONG duoc zero
--                      trong war3map.w3a (A004 thi co, A006 thi khong).
--   A007 mau toi da -- khong thay hang so HAV2 trong ban nay.
CFG.SKILL_TAT_GOC = {
  [id('A001')] = { "ABILITY_RLF_DAMAGE_OSH1", "ABILITY_RLF_MAXIMUM_DAMAGE_OSH2" },
  [id('A002')] = { "ABILITY_RLF_AMOUNT_HEALED_DAMAGED_HHB1" },
  [id('A007')] = { "ABILITY_RLF_DAMAGE_BONUS_HAV3",
                   "ABILITY_RLF_MAGIC_DAMAGE_REDUCTION_HAV4" },
}

-- ---------- Truong goc dung lam VAT MANG ----------
--
-- Nguoc voi SKILL_TAT_GOC: thay vi tat hieu ung goc roi tu cong bang
-- Lua, GHI THANG so can bang cua ta vao truong cua ability, roi de
-- Warcraft cong.
--
-- VI SAO PHAI DOI. Warcraft khong co native "cong them giap" --
-- BlzSetUnitArmor dat GIAP TONG. Nen de Hieu Lenh cong +3 giap, code
-- buoc phai so huu ca cong thuc giap:
--
--   BlzSetUnitArmor(h, n.giap + auraGiap() + buffGiap(pid))
--
-- ma n.giap la BlzGetUnitArmor() CHUP LUC TAO HERO -- tuc giap tong hoi
-- Agi con bang 5. Tu do tro di, phan Agi dong gop bi dong bang trong con
-- so do: Agi len 511 ma giap van bang 2.
--
-- Hai ky nang can cong giap CHINH LA hai ability von cong giap
-- (Devotion Aura, Avatar). Ghi so vao truong cua chung thi Warcraft tu
-- cong, va ta xoa duoc han dong BlzSetUnitArmor -- chi so chay lai binh
-- thuong nhu moi map Warcraft khac.
--
-- Khong phai ta can tinh THEM, ma la ta can THOI SO HUU.
--
--   nguon = "giap"     -> giapAt(sk, lv), duong cong giap cua bang
--   nguon = "buffgiap" -> CFG.FX_BUFF_ARMOR theo bac
CFG.SKILL_CHO_GOC = {
  [id('A003')] = { truong = "ABILITY_RLF_ARMOR_BONUS_HAD1",   nguon = "giap" },
  [id('A007')] = { truong = "ABILITY_RLF_DEFENSE_BONUS_HAV1", nguon = "buffgiap" },
}

-- Cung viec, nhung truong SO NGUYEN -- phai goi
-- BlzSetAbilityIntegerLevelField chu khong phai ban Real.
--
-- DO DUOC bang "-nat ilf" (2026-09-17). Luu y ten khong deu: Strength
-- co hau to ISTR, hai cai kia thi khong.
--
-- A004 da duoc zero san trong war3map.w3a (Iagi/Istr/Iint = 0 moi bac),
-- A006 thi KHONG. Ghi ca hai o day cho deu: neu mai nay sinh lai file
-- w3a thi khong phu thuoc vao viec ai da zero cai nao.
CFG.SKILL_TAT_GOC_INT = {
  [id('A004')] = { "ABILITY_ILF_STRENGTH_BONUS_ISTR",
                   "ABILITY_ILF_AGILITY_BONUS",
                   "ABILITY_ILF_INTELLIGENCE_BONUS" },
  [id('A006')] = { "ABILITY_ILF_STRENGTH_BONUS_ISTR",
                   "ABILITY_ILF_AGILITY_BONUS",
                   "ABILITY_ILF_INTELLIGENCE_BONUS" },
}

-- ---------- Mo khoa ky nang ----------
--
-- Hero vao map TAY KHONG -- command card chi co Move/Stop/Hold/Attack/
-- Patrol -- nhung cam san mot it Go (CFG.GO_START).
--
-- Mot diem do la quyet dinh dau tien cua van, va no la quyet dinh that:
-- mo cai nao truoc? Khac han "vao map da co du bay cai", luc do giay dau
-- khong con gi de chon.
--
-- Va khac ca ban de 0 diem: luc do giay dau khong chon gi duoc ca, phai
-- danh don thuong cho toi con tinh anh dau tien moi co cai de bam.
--
-- Gia phang: mo cai thu nhat hay thu bay deu 1 diem, don mot bac cung 1
-- diem. Tron bay ky nang = 7 x (1 mo + 9 don) = 70 diem.
CFG.SKILL_START_COUNT = 0

-- Go cam san luc vao map. Du dung MOT ky nang.
-- 2 go: du mo MOT ky nang sat thuong VA Luyen The ngay giay dau.
CFG.GO_START = 2

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

-- 'fx' la LOAI HIEU UNG, do src/2_nguoi_choi/7_hieuung.lua doc.
--
-- Vi sao co o nay thay vi viet rieng cho tung ability: bay loai hieu ung
-- duoi day dung lai duoc cho Hvwd va Hkal. Them hero moi la khai bao
-- them dong, khong phai viet them code.
--
--   "line"   gay sat thuong tren mot duong thang truoc mat
--   "heal"   hoi mau mot muc tieu
--   "buff"   tu tang giap + mau trong CFG.FX_BUFF_TIME giay
--   "cleave" bi dong: don danh van % sat thuong sang ben
--   "reduce" bi dong: giam % sat thuong nhan vao (co tran cung)
--   "stat"   bi dong: +% ca ba chi so
--   "aura"   +% giap cho ca doi
CFG.SKILLS[id('H001')] = {
  -- Khong cai nao phat san (CFG.SKILL_START_COUNT = 0). Thu tu trong
  -- bang la thu tu hien o bang phim R, nen xep hai cai co ban len dau --
  -- Chem Lan don quai dong, Chuong don theo duong -- de diem Go
  -- dau tien roi vao tam mat truoc.
  -- 'goc' = ma ability GOC ma cai nay nhan ban tu do. Doc duoc tu
  -- war3map.w3a, nhung code luc chay khong thay -- ma no la thu can de
  -- tra ten hang so ABILITY_*LF_* cua tung skill ("-nat spell").
  { id = id('A005'), goc = "ACce", ten = "Chem Lan", en = "Cleaving Blow",   loai = "bidong",  pct = 0.20, fx = "cleave",
    mota = "Don danh van %s sat thuong sang muc tieu ben canh.",
    mota_en = "Attacks splash %s damage to nearby targets." },
  -- 50 mana, khong phai 25: hero bac 1 co 75 mana nen 50 = mot phat roi
  -- phai cho hoi. (Con so 100 nhin thay trong game khong den tu day --
  -- do la mana goc cua Shockwave, lo ra vi nhanh MO KHOA quen goi
  -- applyLevel; da sua.)
  { id = id('A001'), goc = "AOsh", ten = "Chuong", en = "Palm Strike",       loai = "chudong", heSo = 1.32, cd = 8.0, mana = 50, fx = "line", phim = "Q",
    mota = "Gay %s sat thuong len mot duong thang.",
    mota_en = "Deals %s damage in a line." },

  -- Nam cai duoi mo sau, THU TU NAO CUNG DUOC: gia mo khoa phang nen
  -- nguoi choi chi phai chon thu tu, khong phai tinh toan.
  { id = id('A002'), goc = "AHhb", ten = "Ho The", en = "Guarding Light",    loai = "chudong", heSo = 2.20, cd = 10.0, mana = 30, fx = "heal", phim = "W",
    mota = "Hoi %s mau cho ban than hoac dong doi.",
    mota_en = "Heals %s to yourself or an ally." },
  -- 'giap' chu khong phai 'pct': Warcraft dung GIAP PHANG, khong phai
  -- phan tram. Giam sat thuong = giap x 0.06 / (1 + giap x 0.06), chinh
  -- la CFG.ARMOR_DR_PER_POINT ma he dot quai dang dung.
  --
  -- Ban cu la "+15% giap": tren mot hero co 3 giap thi do la +0.45 giap,
  -- tuc +2.6% mau hieu dung -- gan nhu bang khong. Gio +3 giap phang
  -- (bac 10: +6), tuong duong +18% -> +36% mau hieu dung.
  { id = id('A003'), goc = "AHad", ten = "Hieu Lenh", en = "Rallying Order", loai = "aura",    giap = 3.0, fx = "aura",
    mota = "Ca doi duoc %s giap.",
    mota_en = "The whole party gains %s armor." },
  -- 'chiso' chu khong phai 'pct': cong PHANG, khong phai phan tram.
  --
  -- Ban cu la "+12% ca ba chi so". Do duoc: bac Tu Vi 1 no cong +2, bac
  -- 20 cong +5,810. Khong phai yeu, ma LECH THOI DIEM -- vo hinh dung
  -- luc phai bo Go ra mua, roi manh len mien phi khi da khong can.
  --
  -- Nguyen nhan: 12% la phan tram cua mot dai luong doi x2,421 suot van.
  -- Nang skill tu bac 1 len 10 chi dua 12% -> 24%, tuc x2 -- nen suc
  -- manh cua skill do TU VI quyet dinh, khong phai do bac skill. Nguoi
  -- choi bo 10 Go ra ma gan nhu khong thay gi.
  --
  -- Gio: chiso x SKILL_PASSIVE_STEP^(bac skill-1) x LINHCAN_STAT_STEP^(bac Tu Vi-1)
  -- Hai truc deu co nghia: bac skill doi x2 (tra Go thi thay duoc), bac
  -- Tu Vi giu no khong bi bo lai. Ti le so voi mot lan dot pha dung yen
  -- o 16% moi bac.
  --
  -- Dung CHINH LINHCAN_STAT_STEP nhu he quay, nen doi duong cong Tu Vi
  -- thi ca ba he tu co theo.
  { id = id('A004'), goc = "Aamk", ten = "Luyen The", en = "Body Forging",   loai = "bidong",  chiso = 4.0, fx = "stat",
    mota = "%s ca ba chi so, nhan them theo bac Tu Vi.",
    mota_en = "%s to all three attributes, scaled by Cultivation rank." },
  { id = id('A006'), goc = "Aamk", ten = "Da Sat", en = "Ironhide",          loai = "bidong",  pct = 0.05, fx = "reduce",
    mota = "Giam %s sat thuong nhan vao. Tran cung 10%%.",
    mota_en = "Reduces incoming damage by %s. Hard cap 10%%." },
  { id = id('A007'), goc = "AHav", ten = "Bat Hoai", en = "Indestructible",  loai = "chudong", heSo = 0.0, cd = 60.0, mana = 60, fx = "buff", phim = "E",
    mota = "Tang manh giap trong thoi gian ngan.",
    mota_en = "Greatly raises armor for a short time." },
}

-- ---------- Hang so hieu ung ky nang ----------
--
-- SAT THUONG CONG THEM, khong sua truong cua ability.
--
-- Muon Chuong gay dung x1.32 chi so thi cach "chinh thong" la ghi so vao
-- truong Data cua Shockwave trong war3map.w3a. Khong lam duoc: ma truong
-- cua AOsh / AHhb / AHad CHUA AI DO
-- (docs/06-object-editor/sua-va-clone-ability.md), ma du an nay co luat
-- khong doan -- doan sai mot ma truong la file hong am tham.
--
-- Nen 7_hieuung.lua bat su kien cast va TU gay sat thuong bang
-- UnitDamageTarget. Sat thuong goc cua Warcraft van con, nhung o bac 10
-- voi Linh Can bac 20 thi no la sai so lam tron.
--
-- Doi lai: hieu ung NHIN THAY (song xung kich cua Shockwave) van la cua
-- Warcraft, nen tam ban va tam nhin co the lech nhau chut. Chinh
-- FX_LINE_LEN cho khop mat nhin.
CFG.FX_LINE_LEN    = 700.0   -- do dai duong danh cua "line"
CFG.FX_LINE_WIDTH  = 125.0   -- nua be ngang duong danh
CFG.FX_CLEAVE_AOE  = 200.0   -- ban kinh van cua "cleave"
CFG.FX_REDUCE_CAP  = 0.10    -- tran cung cua "reduce" -- xem mota A006
CFG.FX_BUFF_TIME   = 12.0    -- giay cua "buff"
CFG.FX_BUFF_ARMOR  = 30.0    -- giap cong them khi buff

-- CFG.FX_BUFF_HP da bo. Bat Hoai truoc day cong ca mau toi da, nhung
-- mau toi da cua hero SUY RA tu Suc manh -- ma Linh Can va Luyen The
-- doi Suc manh luc nao cung duoc. Cong roi tru lai mot con so tuyet doi
-- tren mot dai luong tu no thay doi la sai chac chan.
--
-- Bo phan mau, bu bang giap (20 -> 30). Giap moi la thu "bat hoai" that:
-- no giam sat thuong, va no suy ra duoc tu nen nen khong bao gio lech.

-- Hieu ung nhin thay. Duong dan phai viet bang [[...]] (ADR 0003).
CFG.FX_HIT_LINE   = [[Abilities\Spells\Orc\Shockwave\ShockwaveMissile.mdl]]
CFG.FX_HIT_CLEAVE = [[Abilities\Weapons\WitchDoctorMissile\WitchDoctorMissile.mdl]]
CFG.FX_HIT_HEAL   = [[Abilities\Spells\Human\Heal\HealTarget.mdl]]
CFG.FX_HIT_BUFF   = [[Abilities\Spells\Human\Avatar\AvatarCaster.mdl]]

CFG.OP_SKILL_UP = 6   -- arg = so thu tu ky nang trong CFG.SKILLS cua hero

-- Bat khi cac hieu ung da duoc viet that. Con false thi bang phim E noi
-- ro con so dang hien la thiet ke chu chua co hieu luc -- bang ma hien
-- so dep nhung sai thi te hon la khong hien.
--
-- Bat tu 2026-09-16: src/2_nguoi_choi/7_hieuung.lua tu gay sat thuong
-- theo dung CFG.SKILLS, va w3obj.py da dat alev = 10 cho ca bay ability.
CFG.SKILL_DATA_LIVE = true

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

-- ---------- Ba dong tien: nguon nao, he nao ----------
--
-- Ba nguon quai co ba NHIP khac han nhau, va do la thu san co de gan
-- cho ba he khac nhau ma khong phai bia ra co che gi moi:
--
--   linh thuong   4,000 con ca van -> nhip giay      -> Linh Khi + Vang
--   tinh anh         80 con        -> nhip wave      -> Go (2 moi con)
--   boss             20 con        -> nhip canh gioi -> Go (5 moi con)
--
-- Moi he bi chan boi mot loai NOI DUNG, khong phai boi mot cai vi:
--   Linh Khi -> Linh Can   Vang -> Shop   Go -> Ky Nang
--
-- Tong ca van: Linh Khi 10,000 | Vang 4,000 | Go 260.
-- So thuong nam o CFG.THUONG_* phia tren. (Vang con duoc cong tu the 3
-- cua Co Duyen, nhung so do tuy nguoi choi chon nen khong chot duoc.)
--
-- Hai dong tien cu da bo:
--   Ngo Tinh   -> doi ten thanh Go va chuyen len thanh tai nguyen
--   Tinh Thach -> xoa han. Sau khi Phap Khi bi khoa thi khong he nao
--                 tieu no nua, ma mot con so chi tang chu khong bao gio
--                 dung duoc thi te hon la khong co.

-- ============================================================
--  LINH CAN  --  tu vi cua nguoi choi
--  docs/02-he-thong/kinh-te.md · bang-nhan-vat.md
--
--  Nguon suc manh CHINH: EHP quai dinh nghia bang chinh he so cua no
--  (CFG.MOB_EHP_THEO_LINHCAN), nen mot minh no du bam quai.
--  Dung chung thang ten voi 20 canh gioi cua phe dich -- nguoi choi va
--  ke dich tu tien tren cung mot con duong.
-- ============================================================

-- KHOA CFG.LINHCAN_STEP DA BO (2026-09-17), cung voi ca cach nghi
-- "ngan sach x967". Ghi lai vi day la thay doi de bi lat nguoc:
--
--   Ban cu: bon he nhan nhau phai ra x967, va x967 do la duong cong
--   EHP cua quai -- hai ve dung rieng nen phai deo nhau bang tay.
--
--   Ban nay: CFG.MOB_EHP_THEO_LINHCAN = true. EHP quai DINH NGHIA
--   bang chinh he so Linh Can, nen hai ve co cung thua so va no triet
--   tieu. Khong con ngan sach nao phai khop ca.
--
-- HE QUA phai nho: Tu Vi mot minh da du bam quai. MOI nguon khac --
-- Co Duyen (+40% chi so ca van), bac ky nang, va Trang Bi neu mo lai
-- -- deu la phan VUOT LEN thuan, khong phai phan bu cho du.
-- Xem ADR 0015 va docs/02-he-thong/kinh-te.md.
-- ---------- Chi so moi lan dot pha ----------
--
-- Moi lan dot pha cong THEM, va so cong them GAP DOI moi bac:
--   Pham Nhan -> Luyen Khi   +50
--   Luyen Khi -> Truc Co     +65
--   Truc Co   -> Kim Dan     +84
--   ...
--   bac 19 -> 20             +5,623
--
-- Cong don het 19 bac: 50 x (1.30^19 - 1)/0.30 = 24,199 chi so.
--
-- VI SAO 1.30 CHU KHONG PHAI 2.0. Gap doi dung 19 lan thi ra 26 TRIEU
-- chi so va 138 trieu mau quai -- so to den muc vo map.
--
-- Va gap doi KHONG lam cho cam giac manh hon: thu nguoi choi cam nhan
-- la TI LE nhay len cua tong chi so, ma ti le do bang dung STEP o moi
-- buoc du STEP la bao nhieu. Chon 2.0 hay 1.30 thi moi lan dot pha deu
-- "manh len mot muc nhu nhau"; chi khac con so cuoi van.
--
-- Nen chon STEP theo rang buoc DUY NHAT con lai: so phai doc duoc.
--   1.30 -> 24,199 chi so, quai 113,589 mau   (dang dung)
--   1.25 -> 13,688 chi so, quai  64,259 mau
--   1.45 -> 129,234 chi so, quai 606,000 mau
CFG.LINHCAN_STAT_GAIN = 50.0   -- cong them o lan dot pha DAU TIEN
CFG.LINHCAN_STAT_STEP = 1.30   -- moi lan sau x1.30 lan truoc

-- Gia dot pha bac r = BASE x STEP^(r-1).
-- 1.412 = 1.0319^11 = thu nhap tron mot canh gioi, nen gia luon dang
-- dung 7,1 wave o MOI bac. Xem kinh-te.md.
-- PHANG: 500 moi lan, moi bac nhu nhau (STEP = 1.0).
--
-- Con so nay khong suy ra tu duong cong nao -- no la mot GIAO KEO don:
-- mot canh gioi kiem dung 500 Linh Khi, va mot lan dot pha ton dung
-- 500. Don sach mot canh gioi = len duoc mot bac, khong hon khong kem.
--
-- Nguoi choi khong phai tinh gi ca: het canh gioi thi bam dot pha.
-- 19 lan x 500 = 9,500 tren 10,000 kiem duoc -- 500 du ra la dem cho
-- nguoi bo lo vai con.
CFG.LINHCAN_COST_BASE = 500.0
CFG.LINHCAN_COST_STEP = 1.0

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
--           Mat  : Agi con cho TOC DANH -- mot nguon DPS nua ma duong
--                  cong quai khong he biet. O bac 20 la +749 Agi.
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


-- ============================================================
--  TRANG BI  --  6 o, moi o 10 cap
--  docs/02-he-thong/kinh-te.md
--
--  Mua bang LINH KHI, cung vi voi Linh Can -- co y. Do la lua chon
--  chinh cua moi wave: dot pha hay nang do. Hai he kia (Ky Nang, Phap
--  Khi) khong tranh vi nay, chung bi chan boi NOI DUNG chu khong boi
--  tien -- xem CFG.THUONG_ELITE_GO va CFG.THUONG_BOSS_GO.
-- ============================================================

-- Sau o. Ten la huong vi; TAC DUNG cua ca sau giong nhau: +4% sat
-- thuong moi cap.
--
-- Vi sao ca sau o cung mot tac dung: ngan sach Trang Bi tung la x8 SAT
-- THUONG, ma x8 do chinh la (1.04^9)^6 -- chia ba o sang mau/giap thi
-- chi con x2.9.
--
-- LAP LUAN DO DA MAT NEN tu khi MOB_EHP_THEO_LINHCAN bat: khong con
-- tich bon he nao phai dat x948 ca. Gio Trang Bi la phan VUOT LEN
-- thuan, nen cau hoi khong con la "co du x8 khong" ma la "cho vuot
-- len bao nhieu la vua". Giu nguyen sau o giong nhau cho toi khi tra
-- loi duoc cau do -- dung sua mot minh cho nay.
CFG.TRANGBI = {
  { ten = "Vu Khi",       en = "Weapon",   icon = [[ReplaceableTextures\CommandButtons\BTNSteelMelee.blp]] },
  { ten = "Ho Giap",      en = "Armor",    icon = [[ReplaceableTextures\CommandButtons\BTNSteelArmor.blp]] },
  { ten = "Chien Ngoa",   en = "Boots",    icon = [[ReplaceableTextures\CommandButtons\BTNBootsOfSpeed.blp]] },
  { ten = "Ngoc Boi",     en = "Pendant",  icon = [[ReplaceableTextures\CommandButtons\BTNPendantOfEnergy.blp]] },
  { ten = "Ho Than Phu",  en = "Talisman", icon = [[ReplaceableTextures\CommandButtons\BTNTalisman.blp]] },
  -- BTNRingViolet.blp KHONG co trong ban 1.31.1 -- do duoc: o icon ra
  -- mot o XANH LA, do la mau Warcraft ve khi thieu texture. Doi sang
  -- BTNRingSkull (icon cua Ring of Protection). Neu van xanh la thi van
  -- la duong dan sai: mo World Editor -> Object Editor -> mot item bat
  -- ky -> Art - Icon, chep duong dan that vao day. Khong doan them lan
  -- nua -- game dong goi bang CASC nen khong liet ke duoc tu ngoai.
  { ten = "Tru Vat Gioi", en = "Ring",     icon = [[ReplaceableTextures\CommandButtons\BTNRingSkull.blp]] },
}

-- KHOA TAM THOI. The van hien du sau o, moi o ghi 0/0 va khong co nut
-- -- de nguoi choi thay he nay ton tai va dang dong, khac han mot the
-- trong khien ho tuong giao dien hong.
--
-- Mo lai = dat false VA chon lai dong tien cho no: truoc day no tieu
-- Linh Khi, ma Linh Khi gio chi con 10,000 ca van va Linh Can da an
-- 91%. Xem docs/02-he-thong/kinh-te.md
CFG.TRANGBI_LOCKED = true

CFG.TRANGBI_MAX_LEVEL = 10
CFG.TRANGBI_PCT       = 0.04    -- moi cap +4% sat thuong

-- Gia theo TONG SO LAN da nang cua ca sau o, khong theo cap cua rieng
-- mot o. Cung nguyen tac voi ky nang truoc day: don het vao mot o khong
-- re hon rai deu, nen nguoi choi chon theo loi choi chu khong theo phep
-- tinh.
--
-- CA HAI SO DUOI DAY DA CHET, va phai tinh lai truoc khi bo
-- CFG.TRANGBI_LOCKED. Chung duoc suy ra tu thu nhap MU cu
-- (60 x 1.0319^stage, tong 1,880,187 Linh Khi ca van):
--
--   1.134 = 1.0319^4.07 -- thu nhap cua 4,07 stage thoi do.
--   BASE 147            -- 52% cua ngan sach thoi do.
--
-- Thu nhap gio PHANG va ca van chi co 10,000 Linh Khi, ma:
--   tron 60 lan nang  = 974,606 Linh Khi   (gap 97 lan so kiem duoc)
--   lan nang thu 54   = 115,295 Linh Khi   (mot lan)
--   10,000 mua duoc   = 18/60 lan
--   500 du sau Tu Vi  =  2/60 lan
--
-- Tuc mo khoa ngay bay gio thi he nay gan nhu khong dung duoc. Chon
-- lai dong tien VA duong cong cung luc -- xem docs/02-he-thong/kinh-te.md.
CFG.TRANGBI_COST_BASE = 147.0
CFG.TRANGBI_COST_STEP = 1.134

-- ============================================================
--  PHAP KHI  --  5 mon, mua MOT lan, khong co cap
--  docs/02-he-thong/kinh-te.md
--
--  Tra bang GO (tinh anh 2, boss 5) -- Tinh Thach da xoa han
--  2026-09-17. Ngan sach la phan Go ky nang khong dung toi.
-- ============================================================

-- Moi mon DOI MOT LUAT, khong cong chi so -- ba he kia da lo chi so roi.
--
-- 'ma' la thu code doc de biet ap hieu ung nao. Them mon moi thi them
-- ma moi VA sua cho doc ma do; khong co bang dieu phoi tu dong nao ca.
--
-- CA NAM deu doc-luc-dung, khong mon nao can trigger rieng. Do la tieu
-- chi chon: mot mon can bo bat su kien rieng la mot mon co the hong am
-- tham, ma Phap Khi thi ca van chi mua duoc 5 lan.
-- RONG CO Y -- 2026-09-16.
--
-- Nam mon cu (Tu Linh Tran, Ngo Dao Bi, Hon Thien Kinh, Kim Cang Phu,
-- Thoi Dien Chau) da xoa. Chung mua bang Tinh Thach, dong tien do gio
-- khong con; noi dung se thiet ke lai.
--
-- NGAN SACH DANH SAN: ca van kiem 260 Go, ky nang tieu 70, nen con
-- 190 diem cho day. Con so do la rang buoc khi thiet ke lai.
--
-- Code van chay voi bang rong: the hien mot dong "chua co gi", khong
-- mua duoc gi, va moi hieu ung tra ve false. Them mon moi la them dong
-- vao bang nay VA viet cho doc 'ma' cua no -- khong co bang dieu phoi
-- tu dong nao ca.
-- KHOA TAM THOI, cung ly do voi CFG.TRANGBI_LOCKED.
CFG.PHAPKHI_LOCKED = true

CFG.PHAPKHI = {}


-- (CFG.PHAPKHI_LIVE da bo: khong file nao doc no.)


-- ---------- Quay thuong: the VI ----------
--
-- Giet tinh anh duoc 1 luot, boss 3 luot -- 7 luot mot canh gioi, 140
-- ca van. Moi luot mo ba the, chon MOT.
--
-- VI SAO 1/3 CHU KHONG PHAI 5/10. Voi 5/10 thi ca van 600 luot: 30 phut
-- ngoi chon menu, va moi luot chi dang +-1 chi so o canh gioi dau, +-7
-- o canh gioi 10 -- khong ai cam thay gi. It ma dam hon nhieu ma nhat.
-- Vi tri khung Co Duyen (tam khung). Dat cao hon tam man hinh mot chut
-- de khong de len thanh giao dien duoi.
CFG.QUAY_X = 0.40
CFG.QUAY_Y = 0.36

CFG.QUAY_ELITE = 1
CFG.QUAY_BOSS  = 3

-- Gia tri MOT the o bac 1. Cac bac sau nhan theo CHINH
-- CFG.LINHCAN_STAT_STEP, nen quay tu bam theo Tu Vi: doi duong cong Tu
-- Vi thi quay tu co theo, khong phai chinh lai o day.
--
-- 2.2 chon de 7 luot mot canh gioi dang gia ~31% mot lan dot pha, va ca
-- van (140 luot) cong ~9,700 chi so = 40% cua Tu Vi.
CFG.QUAY_GIA_TRI = 2.2

-- Dai ngau nhien quanh gia tri do: 0.7 .. 1.3 lan.
CFG.QUAY_DAI_MIN = 0.70
CFG.QUAY_DAI_MAX = 1.30

-- The 3: VANG, khong phai mau/mana.
--
-- Ban dau the 3 dinh cong mau/mana toi da. Bo vi mot ly do ky thuat
-- CHAC CHAN chu khong phai so thich: ban 1.31.1 KHONG phoi ra truong
-- nao cong them mau toi da (do bang "-nat ilf": co
-- ABILITY_ILF_STRENGTH_BONUS_ISTR va DEFENSE_BONUS_IDEF, nhung khong co
-- cai nao cho MAX LIFE). Chi con BlzSetUnitMaxHP, ma ham do GHI DE --
-- dung cai da dong bang giap suot may ngay.
--
-- Vang thi la bo dem cong thuan, khong ai so huu, va no chay thang vao
-- shop -- them mon moi vao shop la the 3 tu co gia tri.
--
-- PHANG, va NGAU NHIEN TRONG DAI -- 2026-09-17.
--
-- Ban cu: 12 x gia tri the, tuc nhan theo bac. Do duoc hau qua: canh
-- gioi 20 mot the cho 3,859 vang = 154 da (gia da 25), trong khi the 1
-- cho 3 da. Tu khoang canh gioi 10 tro di, chon the 3 roi mua da LUON
-- LUON loi hon chon the 1 -- the 1 thanh the chet.
--
-- Nguyen nhan: the 3 leo x180 ca van con the 1 phang. Mot ben leo, mot
-- ben dung yen thi som muon cung cat nhau.
--
-- Luat rut ra:  TIEN THI PHANG, SUC MANH THI LEO.
--   the 1 (da)     -> tien   -> phang
--   the 3 (vang)   -> tien   -> phang
--   the 2 (chi so) -> suc manh -> van leo x1.30
-- Dung huong ca nen kinh te da di: thu nhap phang, Tu Vi phang 500, ky
-- nang phang 1 go. The 3 la thu cuoi cung con sot lai cua thoi thu
-- nhap mu.
--
-- VI SAO 30-90 CHU KHONG PHAI MOT SO CO DINH. So co dinh thi phep so
-- sanh ba the giai DUNG MOT LAN roi lap lai 140 lan -- nguoi choi bam
-- theo quan tinh. Co dai thi thinh thoang no dao nguoc, nen moi luot
-- phai nhin that.
--
-- Dat dai theo the 1 quy ra vang (gia da 25):
--   the 1 = 3 da = 75 vang, nhung KHOA -- chi mua duoc trang bi
--   the 3 = 30..90, tb 60  -- thap hon mot chut vi vang LINH HOAT hon
--                             (doi nguoc lai da luc nao cung duoc)
-- Dinh dai 90 PHAI vuot 75, neu khong the 3 thua moi luot va lai chet.
--
-- Doi chieu voi tien quai: quai cho 200 vang mot canh gioi, 7 luot the
-- 3 cho ~420 -- gap doi, du de no la lua chon that.
CFG.QUAY_VANG_MIN = 30
CFG.QUAY_VANG_MAX = 90

-- The 1: da Huyen Thiet, PHANG, khong nhan theo bac.
--
-- Phang vi gia nang trang bi co dinh theo luong da -- chu du an chot.
--
-- CON SO NAY BAM THEO SO MON TRANG BI, quy tac:
--
--     QUAY_DA ~= 2.5 x so mon
--
-- Cach ra: mot mon di tron thang 100 bac ton ~300 da (ky vong 15 lan
-- thu moi canh gioi x 20). Ca van co 140 luot quay, nen:
--     1 mon  ->  300 da can  ->  QUAY_DA = 3   (140x3 = 420)
--     4 mon  -> 1,200 da can ->  QUAY_DA = 10  (140x10 = 1,400)
--
-- Hien moi co MOT mon (Kiem) nen de 3. THEM MON LA PHAI SUA SO NAY --
-- de nguyen 10 thi da thua 4.7 lan, ma da thua thi bam mai cung trung,
-- tuc he xac suat 100/75/50/25/15 khong con nghia gi.
--
-- Va no phai HOI THIEU mot chut so voi nhu cau: co thieu thi vang moi
-- co viec (shop ban da), va shop moi dung vai "go khi den" thay vi
-- thanh duong leo chinh.
CFG.QUAY_DA = 3

-- The 2 cong vao MOT chi so ngau nhien trong ba.
--
-- Biet truoc: sat thuong ky nang an theo chi so CAO NHAT, ma Hart co Str
-- cao nhat va Tu Vi cong deu ca ba -- nen Str luon dan dau. Trung Agi
-- hay Int thi KHONG tang sat thuong ky nang, chi duoc giap/toc danh hoac
-- mana.
--
-- Giu nguyen, khong bu he so: canh bac co chu dich -- chu du an chot.
CFG.QUAY_CHISO = { "str", "agi", "int" }

-- ---------- Shop: the V ----------
--
-- He DUY NHAT tieu VANG, va la he duy nhat ban do TIEU HAO. Ba he kia
-- deu la tich luy vinh vien; shop la cho doi tien lay mot lan dung.
--
-- Ngan sach: 10,000 vang ca van, 50 moi wave thuong (mot nguoi choi).
--
-- Gia 10 cho ca hai lo: nam lo moi wave neu tieu het. Ban truoc dat
-- 40/30 (mot lo mot wave); chu du an chot lai 10.
--
-- 'item' la ma item CO SAN cua Warcraft, khong phai item tu tao:
--   phea  Potion of Healing  -- hoi mau
--   pman  Potion of Mana     -- hoi mana
-- Neu ma sai thi UnitAddItemById tra ve nil, va 6_shop.lua BAO RO chu
-- khong nuot im -- xem ADR 0012.
CFG.SHOP = {
  { ma = "hp", ten = "Lo Hoi Mau",  en = "Healing Potion",
    item = id('phea'), gia = 10,
    icon = [[ReplaceableTextures\CommandButtons\BTNPotionGreenSmall.blp]],
    mota    = "Hoi mau ngay. Dung duoc mot lan.",
    mota_en = "Restores health instantly. One use." },

  { ma = "mp", ten = "Lo Hoi Mana", en = "Mana Potion",
    item = id('pman'), gia = 10,
    icon = [[ReplaceableTextures\CommandButtons\BTNPotionBlueSmall.blp]],
    mota    = "Hoi mana ngay. Dung duoc mot lan.",
    mota_en = "Restores mana instantly. One use." },

  -- Da Huyen Thiet: mon DUY NHAT trong shop khong phai item.
  --
  -- 'da' thay cho 'item': buy() cong thang vao S.p[pid].da chu khong bo
  -- gi vao tui. Nen no khong ton o tui, khong can conCho(), va khong bi
  -- probeItems() do (khong co ma item de do).
  --
  -- VAI CUA MON NAY LA GO KHI DEN, khong phai duong leo chinh. The 1 cua
  -- Co Duyen cho 3 da mien phi; day la cho bo tien ra khi xui nhieu lan
  -- lien tiep o cap 15%. Gia 25 dat co y: 3 da cua the 1 = 75 vang, ma
  -- mot luot the 3 chi cho 30-90 -- nen mua da bang vang luon LO hon
  -- nhat the 1, chi duoc cai la chu dong duoc.
  { ma = "da", ten = "Da Huyen Thiet", en = "Black Iron",
    da = 1, gia = 25,
    icon = [[ReplaceableTextures\CommandButtons\BTNStaffOfSanctuary.blp]],
    mota    = "Mot vien da, dung de nang cap trang bi.",
    mota_en = "One stone, used to upgrade equipment." },

  -- 500 vang = 10 wave thu nhap cua mot nguoi (50 vang/wave). Dat cao
  -- hon hai lo kia hai bac do vi no mua thu khac han: khong phai mot
  -- lan hoi mau, ma mot lan KHONG CHET.
  --
  -- Ma 'ankh' la phong doan nhu 'phea'/'pman'. Khong sao: startShop()
  -- tao thu moi item luc vao map, ma sai thi CreateItem tra ve nil va
  -- no bao do ngay -- khong doi toi luc ai do bo ra 500 vang moi biet.
  { ma = "ankh", ten = "Ankh Hoi Sinh", en = "Ankh of Reincarnation",
    item = id('ankh'), gia = 500,
    icon = [[ReplaceableTextures\CommandButtons\BTNAnkh.blp]],
    mota    = "Tu hoi sinh tai cho khi chet.",
    mota_en = "Revives you on the spot when you die." },
}

-- Tui do cua hero co 6 o. Mua khi day tui thi item roi xuong dat ngay
-- duoi chan -- nen phai chan truoc va hoan tien, chu khong de nguoi choi
-- mat vang vi mot cai o.
CFG.SHOP_CHECK_BAG = true

-- ---------- Gop lo cung loai vao mot o ----------
--
-- Mua lan thu hai thi CONG THEM MOT LUOT VAO O CU, khong chiem o moi.
-- Khong co no thi sau sau lan mua la day tui, va ca he shop chi dung
-- duoc sau lan mot van.
--
-- Gop bang tay chu khong trong cho Warcraft tu gop: tu gop hay khong la
-- thuoc tinh cua tung item trong Object Editor, ma ta dang dung item co
-- san cua game nen khong nam quyen. Tu dem luot thi ket qua giong nhau
-- o moi ban, khong phu thuoc du lieu goc.
--
-- CHUA DO: mot item co san nhu 'phea' khi dung co tru MOT luot roi giu
-- lai phan con lai khong, hay bien mat ca o. Do la thuoc tinh du lieu
-- cua item, khong phai cua doan code nay. startShop() in so luot goc ra
-- file vet luc vao map de doi chieu.
CFG.SHOP_STACK_MAX = 10

-- ---------- Qua khoi dau ----------
--
-- Phat SAU KHI pick xong hero, khong phai luc vao map: qua la cua hero,
-- ma luc vao map hero chua ton tai nen khong co tui nao de bo vao.
--
-- 'ma' khop voi CFG.SHOP o tren. Dung chung mot bang voi shop chu khong
-- go rieng ma item o day -- neu khong thi doi item ben shop la quen ben
-- qua, va hai cho cung tao mot thu thi som muon cung lech.
--
-- 10 lo moi loai = dung bang CFG.SHOP_STACK_MAX, nen goi gon trong MOT o
-- moi loai, het hai o tren sau.
CFG.START_ITEMS = {
  { ma = "hp", so = 10 },
  { ma = "mp", so = 10 },
}

-- ---------- Phan vung 25 block ----------
--
-- Luoi 25 block truoc day chi la TOA DO tinh luc chay. Gio moi block co
-- mot vai tro ghi o day, va mot vung THAT trong World Editor ten
-- Blk01..Blk25 (sinh bang w3region.py).
--
-- TEN VUNG LA VI TRI, VAI TRO NAM O DAY. Blk13 doi doi la Blk13; doi y
-- ve vai tro thi sua bang nay, khong dong toi file nhi phan nao va
-- khong gay tham chieu gg_rct_ nao.
--
-- CHUA CAI LOI CHOI NAO. Bang nay moi la ban do -- no cho biet dinh lam
-- gi o dau, de khi bat tay vao thi khong phai quyet lai tu dau. Xem
-- docs/02-he-thong/phan-vung.md va ADR 0014.
--
--        c1          c2          c3          c4          c5
--  r5   21 NHA       22  .       23  .       24  .       25  .
--  r4   16 CUA       17 MACH     18  .       19  .       20  .
--  r3   11  .        12  .       13 TAM THE  14  .       15  .
--  r2    6  .         7  .        8  .        9  .       10  .
--  r1    1  .         2  .        3 TAM DAO   4  .        5 TRAN MA
--
-- BON VUNG, BON CO CHE KHAC NHAU. Khong co vung nao lap lai vung nao.
--
-- Ban truoc co 4 pho ban + 4 thi luyen + 4 linh mach = mot y tuong chep
-- bon lan, khong phai bon vung. Chep lai thi nguoi choi lam cai dau
-- xong la biet het ba cai sau, va 12 block do chi khac nhau o quang
-- duong phai chay.
--
-- LUAT MOI: moi vung phai BUOC ca ba nguoi cung lam, va moi vung buoc
-- theo mot kieu KHAC NHAU. Khong nghi ra co che moi thi DE RONG -- mot
-- block hoang khong ton gi, mot block chep lai thi ton dung cai cam
-- giac moi me cua nguoi choi.
--
-- Bon dong tu, bon vung:
--   chia ra roi dong bo   Tam The Tran (13)
--   ba cho, giu lien tuc  Linh Mach    (17)
--   moi nguoi mot vai     Tam Dao Mon  (3)
--   mot nguoi bi khoa     Tran Ma Thap (5)
--
-- Xa nha dan = kho dan. Nha o block 21 (1,5):
--   17 cach 1 song ngang + 1 doc   -- vung lam thuong xuyen nhat
--   13 cach 2 + 2                  -- su kien, tam ban do
--    3 cach 2 + 4
--    5 cach 4 + 4                  -- xa nhat, kho nhat
CFG.BLOCKS = {
  [21] = { vai = "nha" },
  [16] = { vai = "cua" },

  [17] = { vai = "linhmach" },
  [13] = { vai = "tamthe" },
  [3]  = { vai = "tamdao" },
  [5]  = { vai = "tranma" },
}

-- Block khong co trong bang tren = "hoang" (chua giao viec). De trong
-- CO Y, khong phai quen -- ADR 0014 va ADR 0018.
--
-- 'coop' la CO CHE buoc ba nguoi phai phoi hop. No la ly do ton tai cua
-- vung; vung nao khong dien duoc o nay thi chua nen co.
-- 'tien' la dong tien vung do sinh ra.
-- 'mau'  dung cho ping minimap cua lenh "-vung".
CFG.BLOCK_ROLE = {
  nha  = { ten = "Tong Mon", en = "Sect",       mau = {255, 220,  80} },
  cua  = { ten = "Ma Mon",   en = "Demon Gate", mau = {255,  80,  80} },

  tamthe = { ten = "Tam The Tran", en = "Three-Body Array",
             mau = {255, 140, 255}, tien = "Go",
             coop = "Boss chia ba than o ba goc. Than nao chet le thi hai" ..
                    " than kia hoi sinh no. Phai ha ca ba trong mot cua so" ..
                    " thoi gian -- ba nguoi, ba cho, mot nhip." },

  linhmach = { ten = "Linh Mach", en = "Qi Vein",
               mau = {255, 200, 120}, tien = "Linh Khi",
               coop = "Ba tru dan khi. Mach chi chay khi CA BA tru deu co" ..
                      " nguoi dung. Quai lien tuc ra de day nguoi khoi tru." },

  tamdao = { ten = "Tam Dao Mon", en = "Three Paths",
             mau = {120, 255, 160}, tien = "Go",
             coop = "Ba cua, moi cua chi mot VAI qua duoc: Kim can nguoi" ..
                    " chiu don, Moc can nguoi giai, Hoa can nguoi pha nhanh." ..
                    " Dung ba hero cua CFG.HEROES." },

  tranma = { ten = "Tran Ma Thap", en = "Warding Pagoda",
             mau = {120, 200, 255}, tien = "Go",
             coop = "Mot nguoi phai dung yen dan phap, khong danh khong" ..
                    " chay duoc. Hai nguoi con lai gong ca tran. Doi phien" ..
                    " nhau khi nguoi dang dan sap guc." },

  hoang = { ten = "Hoang Dia", en = "Wilds", mau = {130, 130, 130},
            coop = "Chua co y tuong. De rong cho toi khi co -- xem ADR 0018." },
}

-- Ten vung trong World Editor, de code tim duoc gg_rct_Blk07.
-- w3region.py sinh dung tien to nay.
CFG.BLOCK_RGN_PREFIX = "Blk"

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

-- Giao dien bang nhan vat. Bon he dung chung khung nay.

-- Phim CHU mo bang. nil = khong gan phim chu nao, chi dung ESC.
--
-- E -> R -> nil. E thanh phim tat cua Bat Hoai; roi R cung bo not vi ESC
-- da du.
--
-- Doi lai: ESC gio BAT/TAT chu khong chi tat. Nghia la moi lan bam ESC
-- de huy chon quan hay dong menu deu mo bang len -- neu thay phien thi
-- dat lai mot chu cai o day, luc do ESC tu quay ve chi-tat.
--
-- Ghi bang CHU CAI chu khong bang hang so OSKEY_*: hang so tra ra luc
-- gan phim (_G["OSKEY_" .. chu]) nen khong phu thuoc thu tu nap chunk.
CFG.PANEL_KEY = nil

-- Giay chan trung cho ESC. Hai duong dang ky nam chung mot trigger nen
-- mot lan bam no hai lan; xem chu thich trong bindEsc().
CFG.PANEL_ESC_KHOA = 0.25

-- ---------- Dung do bang hang so tren (canh Esc) ----------
--
-- Warcraft chi gan san tui do vao numpad (7/8/4/5/1/2). May khong co
-- numpad, va tay phai roi chuot de voi sang numpad, nen gan THEM hang
-- so tren. Numpad van chay nhu cu -- day la them, khong phai thay.
--
-- Thu tu trong bang = thu tu o tui: phan tu 1 -> o 1, ... -> o 6.
--
-- DANH DOI, biet truoc chu khong phai bug: hang so tren cung la phim
-- goi NHOM QUAN cua Warcraft. Bam 1 se vua goi nhom 1 vua dung do o 1.
-- Map nay moi nguoi mot hero nen nhom quan gan nhu khong dung toi, nhung
-- neu thay phien thi dat nil de tat, hoac doi sang phim khac.
CFG.ITEM_KEYS = { "1", "2", "3", "4", "5", "6" }
CFG.PANEL_X = 0.40
-- 0.33 chu khong phai 0.30. Khung cao 0.474 dat tam o 0.30 thi day
-- khung tut xuong y = 0.063, ma thanh giao dien duoi cua Warcraft (chan
-- dung, chan dung hero, command card) phu khoang 0.12 duoi cung VA an
-- tren frame cua ta -- no nuot cu bam.
--
-- Do la ly do nut Close bam khong an: no VE ra nhung nam duoi thanh do.
-- Nut da doi len dinh khung, va tam khung nang len de hang muc cuoi
-- cung cung thoat khoi dai do.
CFG.PANEL_Y = 0.33
-- 0.56 -> 0.68 -> 0.74, moi lan them mot the.
--
-- Nhan the la TEXT khong dat kich thuoc nen no TRAN sang nut ben canh
-- chu khong bi cat: the qua hep thi "IV. Treasures" de len "V. Shop".
--
-- Be ngang mot the = (W - 2xPAD - (n-1)xGAP) / n:
--   4 the o 0.56 -> 0.1235   (goc)
--   5 the o 0.74 -> 0.1353   (hien tai)
--   6 the o 0.68 -> 0.1003   (hep hon goc 19%)
--
-- Tung len 0.74 luc co sau the. Co Duyen sau do tach ra thanh khung
-- rieng nen chi con nam, va 0.74 gio rong rai -- giu nguyen de con cho
-- cho he sau.
--
-- Khung 0.74 giua man hinh 0.8 thi con tran 0.03 moi ben -- gan het co,
-- nen the THU BAY se phai rut ngan nhan chu khong noi khung duoc nua.
CFG.PANEL_W = 0.74

-- Hinh hoc mot DONG kieu "list" (Ky Nang, Trang Bi, Phap Khi).
--
-- So cu: dong 0.024, icon 0.018, nut 0.028 -- o 1080p la 43px / 32px /
-- 50px. Mot khung 828px chua nut bam 50px thi khong phai bang be, ma la
-- MAT DO SAI: khung thua cho ma noi dung thi nho.
CFG.PANEL_ROW   = 0.048   -- cao mot dong  (86px o 1080p)
CFG.PANEL_ICON  = 0.036   -- canh icon     (65px)
CFG.PANEL_BTN_W = 0.150   -- be ngang nut, du cho "UPGRADE  147 Qi"
CFG.PANEL_BTN_H = 0.026
CFG.PANEL_PAD   = 0.012
-- Vien trang tri cua EscMenuBackdrop an mat mep trong. PANEL_PAD mot
-- minh khong du: dong nen va cum focus tran ra ngoai duong vien vang.
-- Cung bai hoc voi CFG.CARD_BORDER cua bang chon hero.
CFG.PANEL_BORDER = 0.012

-- Co chu ba cap. Bang cu khong goi BlzFrameSetScale lan nao nen moi
-- dong mot co -- nhin vao chi thay mot khoi chu deu deu.
CFG.PANEL_SCALE_HEAD = 1.20
CFG.PANEL_SCALE_NAME = 1.05
CFG.PANEL_SCALE_SUB  = 0.85

-- Nen bang. Cung danh sach voi bang chon hero: template FDF co vien
-- that, het thi lui ve CFG.FRAME_BG (o mau dac, khong vien).
CFG.PANEL_BACKDROP = { "EscMenuBackdrop", "QuestButtonBaseTemplate" }

-- ---------- Vien nut, TU VE ----------
--
-- Hai lan hong truoc khi ra cach nay:
--   1. Template ScoreScreenTabButtonTemplate khong ve gi ca -- nut chi
--      la chu troi giua nen, khong ai biet bam vao dau.
--   2. Doi sang EscMenuBackdrop (template dang ve khung bang). Do la
--      backdrop 9 o: bon goc va bon canh cua no la ANH CO KICH THUOC
--      RIENG, khong co lai theo frame. Dap len mot nut cao 0.026 thi
--      moi nut mo ra mot cai khung go to bang nua man hinh -- anh chup
--      cho thay ca bang bien thanh cai cui go.
--
-- Bai hoc: mot backdrop dung cho KHUNG khong dung lai duoc cho NUT.
-- Nen tu ve: hai o mau dac long nhau, o ngoai la vien, o trong la ruot.
-- O mau dac co lai duoc moi kich thuoc, nen khong the hong kieu (2).
-- Chi dung hai o mau DA THAY VE RA MAU tren anh chup, khong doan thêm
-- so hieu TeamColor nao: 04 la vang (thanh tien do dang dung), 27 la den
-- (vach ke dong va nen thanh tien do dang dung). Doan sai mot so hieu
-- thi ra o XANH LA, dung loi ma BTNRingViolet da dinh.
CFG.PANEL_BTN_EDGE   = [[ReplaceableTextures\TeamColor\TeamColor04]]
CFG.PANEL_BTN_FILL   = [[ReplaceableTextures\TeamColor\TeamColor27]]
CFG.PANEL_BTN_BORDER = 0.0016

-- Thanh tien do cua the kieu "focus". Hai o mau DAC -- va o day thi mot
-- o mau dac dung la thu can, khac han truong hop dung no lam nen bang.
CFG.PANEL_BAR_BG   = [[ReplaceableTextures\TeamColor\TeamColor27]]
CFG.PANEL_BAR_FILL = [[ReplaceableTextures\TeamColor\TeamColor04]]
-- Cao cua bang SUY RA tu so dong trong 4_giao_dien/1_panel.lua, khong
-- go tay o day -- de o day thi them mot dong la tran ra ngoai khung.

-- Ke vach xen ke cho de doc. Tat neu thay roi mat.
CFG.PANEL_GRID     = true
CFG.PANEL_GRID_TEX = [[ReplaceableTextures\TeamColor\TeamColor27]]
