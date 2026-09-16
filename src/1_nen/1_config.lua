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

-- ---------- Nghi giua hai canh gioi ----------
--
-- Dong ho chay suot 10 tang, roi DUNG HAN o hai moc:
--
--   tang 1..10        dong ho chay        <- ap luc, dot chong duoc
--   tang 10 don sach  DUNG dong ho        <- nghi
--     -next           BOSS
--   boss chet         DUNG dong ho        <- nghi, tieu Tinh Thach
--     -next           canh gioi sau
--
-- Vi sao khong bo han dong ho cho ca 11 stage: WAVE_TIME dang la MO NEO
-- cua hop dong DPS x967 -- "wave phai ha kip gio". Bo ap luc thoi gian
-- trong canh gioi thi hop dong mat neo va phai neo lai vao mau nha.
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

-- ---------- Gia nang cap ky nang: tra bang NGO TINH ----------
--
-- Ky nang KHONG mua bang Linh Khi nua. Ly do o docs/02-he-thong/kinh-te.md:
-- bon he ma ba he cung rut mot cai vi thi khong he nao co ban sac rieng,
-- va nguoi choi chi phai tra loi dung mot cau hoi ("gom du tien chua").
--
-- Ngo Tinh la DIEM, khong phai tien: khong co duong cong mu, khong bam
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
--   7 x (1 mo khoa + 9 lan nang) = 70 diem, tren 300 diem ca van.
CFG.SKILL_NGO_UNLOCK = 1    -- mo khoa mot ky nang
CFG.SKILL_NGO_UP     = 1    -- nang mot bac
CFG.SKILL_MAX_LEVEL  = 10

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
-- Bao nhieu ky nang duoc PHAT SAN. Dat 0: khong cai nao mien phi.
--
-- Hero vao map voi command card TRONG (chi Move/Stop/Hold/Attack/Patrol).
-- Con tinh anh dau tien chet cho 1 diem, du mo mot ky nang -- va do la
-- quyet dinh dau tien cua van: mo cai nao truoc.
--
-- Doi lai: dot 1 danh bang don thuong. Voi WAVE_WAIT_FIRST bat thi
-- nguoi choi co thoi gian nhin bang truoc khi go -next, nen khong ai bi
-- nem vao tran ma khong biet minh co gi.
CFG.SKILL_START_COUNT = 0

-- Bay ky nang deu mo khoa duoc NGAY TU DAU, gia nhu nhau. Khong con
-- bang gia theo so cai da mo -- xem CFG.SKILL_NGO_UNLOCK o tren.

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
  -- HAI CAI DAU la ky nang phat san (CFG.SKILL_START_COUNT). Xep dau
  -- bang la chu dich: Chem Lan don quai dong, Chuong don theo duong --
  -- du hai viec de song qua nhung canh gioi dau.
  { id = id('A005'), ten = "Chem Lan", en = "Cleaving Blow",   loai = "bidong",  pct = 0.20, fx = "cleave",
    mota = "Don danh van %s sat thuong sang muc tieu ben canh.",
    mota_en = "Attacks splash %s damage to nearby targets." },
  { id = id('A001'), ten = "Chuong", en = "Palm Strike",       loai = "chudong", heSo = 1.32, cd = 8.0, mana = 25, fx = "line",
    mota = "Gay %s sat thuong len mot duong thang.",
    mota_en = "Deals %s damage in a line." },

  -- Nam cai duoi mua bang Ngo Tinh, THU TU NAO CUNG DUOC. Gia phu thuoc
  -- da mo bao nhieu cai, khong phu thuoc mo cai nao.
  { id = id('A002'), ten = "Ho The", en = "Guarding Light",    loai = "chudong", heSo = 2.20, cd = 10.0, mana = 30, fx = "heal",
    mota = "Hoi %s mau cho ban than hoac dong doi.",
    mota_en = "Heals %s to yourself or an ally." },
  -- 'giap' chu khong phai 'pct': Warcraft dung GIAP PHANG, khong phai
  -- phan tram. Giam sat thuong = giap x 0.06 / (1 + giap x 0.06), chinh
  -- la CFG.ARMOR_DR_PER_POINT ma he dot quai dang dung.
  --
  -- Ban cu la "+15% giap": tren mot hero co 3 giap thi do la +0.45 giap,
  -- tuc +2.6% mau hieu dung -- gan nhu bang khong. Gio +3 giap phang
  -- (bac 10: +6), tuong duong +18% -> +36% mau hieu dung.
  { id = id('A003'), ten = "Hieu Lenh", en = "Rallying Order", loai = "aura",    giap = 3.0, fx = "aura",
    mota = "Ca doi duoc %s giap.",
    mota_en = "The whole party gains %s armor." },
  { id = id('A004'), ten = "Luyen The", en = "Body Forging",   loai = "bidong",  pct = 0.12, fx = "stat",
    mota = "+%s ca ba chi so.",
    mota_en = "+%s to all three attributes." },
  { id = id('A006'), ten = "Da Sat", en = "Ironhide",          loai = "bidong",  pct = 0.05, fx = "reduce",
    mota = "Giam %s sat thuong nhan vao. Tran cung 10%%.",
    mota_en = "Reduces incoming damage by %s. Hard cap 10%%." },
  { id = id('A007'), ten = "Bat Hoai", en = "Indestructible",  loai = "chudong", heSo = 0.0, cd = 60.0, mana = 60, fx = "buff",
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

CFG.TINHTHACH_BOSS_BASE = 10   -- boss canh gioi r roi BASE + STEP*(r-1)
CFG.TINHTHACH_BOSS_STEP = 5

-- ---------- Ngo Tinh ----------
--
-- Dong tien thu BA. Nguon: TINH ANH, moi wave mot con -- khong phai
-- linh thuong, khong phai boss.
--
-- Vi sao them mot dong tien nua thay vi dung Linh Khi cho tat ca: ba
-- nguon quai co ba NHIP khac han nhau, va do la thu san co de gan cho
-- ba he khac nhau ma khong phai bia ra co che gi moi.
--
--   linh thuong  11,000 con ca van  -> nhip giay   -> Linh Khi
--   tinh anh        200 con         -> nhip wave   -> Ngo Tinh
--   boss             20 con         -> nhip canh gioi -> Tinh Thach
--
-- Ngo Tinh KHONG hien tren thanh tai nguyen (Warcraft chi co vang va
-- go, ca hai da dung roi). No hien trong bang phim E.
--
-- Tong ca van: 200 x1 + 20 x5 = 300 diem.
CFG.NGOTINH_ELITE = 1
CFG.NGOTINH_BOSS  = 5

-- ============================================================
--  LINH CAN  --  tu vi cua nguoi choi
--  docs/02-he-thong/kinh-te.md · bang-nhan-vat.md
--
--  Nguon suc manh LON NHAT cua nguoi choi: x20 trong hop dong x967.
--  Dung chung thang ten voi 20 canh gioi cua phe dich -- nguoi choi va
--  ke dich tu tien tren cung mot con duong.
-- ============================================================

-- 1.17, KHONG phai 1.215.
--
-- Con so nay da doi mot lan, va ly do doi dang ghi lai o day vi no de
-- bi lat nguoc lai:
--
--   Ban cu (BA nguon): Linh Can x40.5 x Trang Bi x12 x Ky Nang x2 = x971.
--   Voi 1.17 thi chi x474 -- thieu mot nua, nen 1.215 la dung LUC DO.
--
--   Ban nay (BON nguon): Phap Khi da thanh he that, nen ngan sach chia
--   lai: x19.7 x 8 x 2.4 x 2.5 = x948 ~ x967. Voi 1.215 thi thanh
--   x1,942 -- gap DOI muc hop dong, va nua sau van thanh di dao.
--
-- Tuc hai con so deu tung dung, chi la voi hai ban ngan sach khac nhau.
-- KHONG duoc tron: doi mot cai o day thi phai kiem lai TICH cua ca bon.
-- Xem ADR 0015 va docs/02-he-thong/kinh-te.md.
CFG.LINHCAN_STEP = 1.17

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


-- ============================================================
--  TRANG BI  --  6 o, moi o 10 cap
--  docs/02-he-thong/kinh-te.md
--
--  Mua bang LINH KHI, cung vi voi Linh Can -- co y. Do la lua chon
--  chinh cua moi wave: dot pha hay nang do. Hai he kia (Ky Nang, Phap
--  Khi) khong tranh vi nay, chung bi chan boi NOI DUNG chu khong boi
--  tien -- xem CFG.NGOTINH_ELITE va CFG.TINHTHACH_BOSS_BASE.
-- ============================================================

-- Sau o. Ten la huong vi; TAC DUNG cua ca sau giong nhau: +4% sat
-- thuong moi cap.
--
-- Vi sao khong cho moi o mot tac dung khac nhau cho da dang: ngan sach
-- Trang Bi la x8 SAT THUONG, ma x8 do chinh la (1.04^9)^6. Chia ba o
-- sang mau/giap thi sat thuong chi con (1.04^9)^3 = x2.9, va tich bon
-- he tut tu x948 xuong x344. Muon o thu/cong khac nhau thi phai suy
-- lai ca ngan sach truoc -- dung sua mot minh cho nay.
CFG.TRANGBI = {
  { ten = "Vu Khi",       en = "Weapon",   icon = [[ReplaceableTextures\CommandButtons\BTNSteelMelee.blp]] },
  { ten = "Ho Giap",      en = "Armor",    icon = [[ReplaceableTextures\CommandButtons\BTNSteelArmor.blp]] },
  { ten = "Chien Ngoa",   en = "Boots",    icon = [[ReplaceableTextures\CommandButtons\BTNBootsOfSpeed.blp]] },
  { ten = "Ngoc Boi",     en = "Pendant",  icon = [[ReplaceableTextures\CommandButtons\BTNPendantOfEnergy.blp]] },
  { ten = "Ho Than Phu",  en = "Talisman", icon = [[ReplaceableTextures\CommandButtons\BTNTalisman.blp]] },
  { ten = "Tru Vat Gioi", en = "Ring",     icon = [[ReplaceableTextures\CommandButtons\BTNRingViolet.blp]] },
}

CFG.TRANGBI_MAX_LEVEL = 10
CFG.TRANGBI_PCT       = 0.04    -- moi cap +4% sat thuong

-- Gia theo TONG SO LAN da nang cua ca sau o, khong theo cap cua rieng
-- mot o. Cung nguyen tac voi ky nang truoc day: don het vao mot o khong
-- re hon rai deu, nen nguoi choi chon theo loi choi chu khong theo phep
-- tinh.
--
-- 1.134 = 1.0319^4.07 = thu nhap cua 4,07 stage. 54 lan nang trai deu
-- 220 stage thi moi lan cach nhau dung 4,07 stage -- nen "mot lan nang
-- do dang may wave" la hang so suot van, giong het cach Linh Can bam
-- theo 7,1 wave.
--
-- BASE 147 (khong phai 86): Ky Nang da chuyen sang Ngo Tinh nen phan
-- 22% Linh Khi cua no doi sang day. Trang Bi gio an 52% ngan sach.
CFG.TRANGBI_COST_BASE = 147.0
CFG.TRANGBI_COST_STEP = 1.134

-- ============================================================
--  PHAP KHI  --  5 mon, mua MOT lan, khong co cap
--  docs/02-he-thong/kinh-te.md
--
--  Nguon tien duy nhat la TINH THACH, ma Tinh Thach chi roi tu boss.
--  Nen day la he duy nhat khong cay duoc: thua mot boss la mat han mot
--  mon, khong co cach bu.
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
-- Thoi Dien Chau) da xoa. Chung mua bang Tinh Thach; he nay gio tra
-- bang NGO TINH, va noi dung se thiet ke lai.
--
-- NGAN SACH DANH SAN: ca van kiem 300 Ngo Tinh, ky nang tieu 70, nen
-- con 230 diem cho day. Con so do la rang buoc khi thiet ke lai.
--
-- Code van chay voi bang rong: the hien mot dong "chua co gi", khong
-- mua duoc gi, va moi hieu ung tra ve false. Them mon moi la them dong
-- vao bang nay VA viet cho doc 'ma' cua no -- khong co bang dieu phoi
-- tu dong nao ca.
CFG.PHAPKHI = {}

-- Tong gia 1,050 tren 1,150 Tinh Thach cua ca van -- mua du ca nam neu
-- ha het 20 boss, va CHI neu ha het.
--
-- Hai mon dau cong vao chinh nen kinh te, nen mua som lai hon mua muon.
-- Do la lua chon that: bo 60 Tinh Thach vao "Tu Linh Tran" ngay canh
-- gioi 1 nghia la chap nhan cham co mon thu nam.

-- Ngan sach suc manh cua Phap Khi (x2.5) la cho VAY.
--
-- Nam mon o tren khong mon nao nhan thang sat thuong; chung cong vao
-- kinh te va vao kha nang song sot cua nha. Tuc x2.5 dang duoc tra bang
-- duong vong -- nhieu Linh Khi hon thi nhieu Trang Bi hon.
--
-- Chua do duoc duong vong do co bang x2.5 that khong. Day la cho dau
-- tien phai kiem khi choi thu, chu khong phai cho de sua so.
CFG.PHAPKHI_LIVE = true


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
             mau = {255, 140, 255}, tien = "Tinh Thach",
             coop = "Boss chia ba than o ba goc. Than nao chet le thi hai" ..
                    " than kia hoi sinh no. Phai ha ca ba trong mot cua so" ..
                    " thoi gian -- ba nguoi, ba cho, mot nhip." },

  linhmach = { ten = "Linh Mach", en = "Qi Vein",
               mau = {255, 200, 120}, tien = "Linh Khi",
               coop = "Ba tru dan khi. Mach chi chay khi CA BA tru deu co" ..
                      " nguoi dung. Quai lien tuc ra de day nguoi khoi tru." },

  tamdao = { ten = "Tam Dao Mon", en = "Three Paths",
             mau = {120, 255, 160}, tien = "Ngo Tinh",
             coop = "Ba cua, moi cua chi mot VAI qua duoc: Kim can nguoi" ..
                    " chiu don, Moc can nguoi giai, Hoa can nguoi pha nhanh." ..
                    " Dung ba hero cua CFG.HEROES." },

  tranma = { ten = "Tran Ma Thap", en = "Warding Pagoda",
             mau = {120, 200, 255}, tien = "Tinh Thach",
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

-- Giao dien bang nhan vat (phim E). Bon he dung chung khung nay.
CFG.PANEL_X = 0.40
CFG.PANEL_Y = 0.30
CFG.PANEL_W = 0.56    -- do duoc: 5 cot cua bang cu chi con 81px cho cot "Bac"

-- Hinh hoc mot DONG kieu "list" (Ky Nang, Trang Bi, Phap Khi).
--
-- So cu: dong 0.024, icon 0.018, nut 0.028 -- o 1080p la 43px / 32px /
-- 50px. Mot khung 828px chua nut bam 50px thi khong phai bang be, ma la
-- MAT DO SAI: khung thua cho ma noi dung thi nho.
CFG.PANEL_ROW   = 0.048   -- cao mot dong  (86px o 1080p)
CFG.PANEL_ICON  = 0.036   -- canh icon     (65px)
CFG.PANEL_BTN_W = 0.105   -- be ngang nut  (189px, du cho "NANG  178")
CFG.PANEL_BTN_H = 0.026
CFG.PANEL_PAD   = 0.012

-- Co chu ba cap. Bang cu khong goi BlzFrameSetScale lan nao nen moi
-- dong mot co -- nhin vao chi thay mot khoi chu deu deu.
CFG.PANEL_SCALE_HEAD = 1.20
CFG.PANEL_SCALE_NAME = 1.05
CFG.PANEL_SCALE_SUB  = 0.85

-- Nen bang. Cung danh sach voi bang chon hero: template FDF co vien
-- that, het thi lui ve CFG.FRAME_BG (o mau dac, khong vien).
CFG.PANEL_BACKDROP = { "EscMenuBackdrop", "QuestButtonBaseTemplate" }

-- Thanh tien do cua the kieu "focus". Hai o mau DAC -- va o day thi mot
-- o mau dac dung la thu can, khac han truong hop dung no lam nen bang.
CFG.PANEL_BAR_BG   = [[ReplaceableTextures\TeamColor\TeamColor27]]
CFG.PANEL_BAR_FILL = [[ReplaceableTextures\TeamColor\TeamColor04]]
-- Cao cua bang SUY RA tu so dong trong 4_giao_dien/1_panel.lua, khong
-- go tay o day -- de o day thi them mot dong la tran ra ngoai khung.

-- Ke vach xen ke cho de doc. Tat neu thay roi mat.
CFG.PANEL_GRID     = true
CFG.PANEL_GRID_TEX = [[ReplaceableTextures\TeamColor\TeamColor27]]
