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
-- duoc hai ban map. Xem src/1_core/6_i18n.lua
CFG.LANG = "en"
CFG.DEBUG   = true     -- bat: in so do luoi, ping minimap, bao cao chi tiet

-- Lenh "-debug" day ca bon dong tien len con so nay. Chi co khi
-- CFG.DEBUG bat. De thu mot he o bac cao ma khong phai cay ca van.
-- ---------- Canh gan vao hero ----------
--
-- THUAN TRANG TRI (2026-09-19). Chua gan vao he nao -- chua thuong,
-- chua moc canh gioi, chua ban. Co lenh "-wing" de nhin thu.
--
-- Nguon: "Cosmic Elven Wings" cua Vinz, hiveworkshop 315167.
-- Xem models/wings/note.txt.
--
-- KHONG PHAI IMPORT TEXTURE NAO: da doc chunk texture ca 10 file, moi
-- duong dan deu la texture CO SAN cua Warcraft. Chi .mdx phai import.
--
-- 'b' = ban Borderless (khong vien): 61 KB thay vi 113 KB, cung bo
-- animation, khac o hinh hoc.
-- Goi "Ethereal Wings" cua Xecutor_ShamanX, hiveworkshop 373249.
-- Xem models/wings/note.txt.
--
-- 14-16 KB moi bo. Animation: Birth, Death, Stand.
--
-- Tien to "eth_" trong duong dan la di san cua thoi con goi thu hai
-- (CosmicElven, da bo): hai goi deu co mot bo ten "Divine" nen phai
-- tach. Giu nguyen vi doi ten duong dan trong map la sua ba cho
-- (CFG, war3map.imp, file tren dia) doi lay khong gi ca.
CFG.WINGS = {
  -- XEP THEO DO CHOI TANG DAN, va 'rank' la canh gioi mo khoa.
  --
  -- Hinh dang: HAI cai nhanh trong coi Pham, roi MOI COI mot cai, roi
  -- dinh. Khoang cach 10 -> 10 -> 25 -> 25 -> 20 stage: dau van don
  -- dap, cuoi van thua.
  --
  --   canh gioi 2   stage 6    ngay sau boss dau tien
  --   canh gioi 4   stage 16   van trong coi Pham
  --   canh gioi 6   stage 26   vao coi YEU   -- quai doi mau
  --   canh gioi 11  stage 51   vao coi TIEN
  --   canh gioi 16  stage 76   vao coi THAN
  --   canh gioi 20  stage 96   dinh
  --
  -- Ba moc giua trung ranh gioi bon coi la CO Y: do la luc MOB_UNIT
  -- doi, quai nhin khac han. Chuong moi cua map da co dau hieu thi
  -- giac san, gan canh vao do lam no nang them.
  --
  -- U MINH dung thu hai du nhin hoanh trang nhat (sai rong nhat). Ly
  -- do: nen map toi, canh den doc rat yeu o tam zoom 2000. No an tuong
  -- luc dung ngam, nhung giua tran thi nhat hon Thanh Quang va Thai
  -- Duong nhieu. Cam giac "canh minh xin dan" phai thang su hop chu de.
  -- 'path' la MODEL (wings\, so nhieu), 'icon' la ANH (wing\, so it).
  -- Hai thu muc khac nhau va do khong phai loi chinh ta: model di vao
  -- wings\ tu dot import dau, icon la dot sau. Doi ten mot trong hai la
  -- sua ba cho (CFG, war3map.imp, file tren dia) doi lay khong gi.
  --
  -- Anh sinh tu docs/01-tmp/wing/<code>-avatar.png bang:
  --   python w3blp.py encode <png> models/icons/wing/<code>.blp --size 256
  --   python w3import.py add  models/icons/wing/<code>.blp wing/<code>.blp
  { code = "eth_storm",    rank =  2, vi = "Loi Dinh",    en = "Storm",
    path = [[wings\eth_storm.mdx]],    icon = [[wing\eth_storm.blp]],    attach = "origin" },
  { code = "eth_darkness", rank =  4, vi = "U Minh",      en = "Darkness",
    path = [[wings\eth_darkness.mdx]], icon = [[wing\eth_darkness.blp]], attach = "origin" },
  { code = "eth_divine",   rank =  6, vi = "Thien Dao",   en = "Divine",
    path = [[wings\eth_divine.mdx]],   icon = [[wing\eth_divine.blp]],   attach = "origin" },
  { code = "eth_blizzard", rank = 11, vi = "Bang Nguyet", en = "Blizzard",
    path = [[wings\eth_blizzard.mdx]], icon = [[wing\eth_blizzard.blp]], attach = "origin" },
  { code = "eth_holy",     rank = 16, vi = "Thanh Quang", en = "Holy",
    path = [[wings\eth_holy.mdx]],     icon = [[wing\eth_holy.blp]],     attach = "origin" },
  { code = "eth_sun",      rank = 20, vi = "Thai Duong",  en = "Sun",
    path = [[wings\eth_sun.mdx]],      icon = [[wing\eth_sun.blp]],      attach = "origin" },
}


-- GOI "Cosmic Elven Wings" (Vinz, hiveworkshop 315167) DA BO HAN
-- 2026-09-19, ca 6 bo lan file nguon.
--
-- Ly do khong phai chat luong: ba bo Chaos/Cosmic/Divine chay tot. Ly
-- do la GOC MODEL. Goi do gan "chest" moi dung lung; goi Ethereal gan
-- "chest" thi vot len tren dau, phai gan "origin". Giu ca hai la giu
-- hai quy uoc gan khac nhau trong mot bang -- va hai bo con lai cua
-- goi do (Nature, Void) thi khong bao gio hien duoc.
--
-- Mot goi, mot diem gan, khong ngoai le. Lich su do do giu o
-- models/wings/note.txt.

-- Diem gan mac dinh -- DA DO, khong phai doan.
--
-- "origin" chu khong "chest": goc cua model Ethereal lech len, nen gan
-- vao "chest" thi canh vot len tren dau. Thu bang mat qua "-wing N
-- <diem>", vi khong co ham nao tra loi "diem nay co ton tai khong" --
-- gan sai thi Warcraft im lang.
--
-- Ca sau bo o tren KHAI THANG attach = "origin" chu khong dua vao
-- mac dinh nay. Nhin thi thua, nhung no lam moi dong TU NOI diem gan
-- cua no -- va do dung la bai hoc: diem gan la thuoc tinh cua MODEL,
-- khong phai cua map. Them mot goi khac vao bang la thay ngay no gan
-- kieu khac.
--
-- Mac dinh nay chi con la duong lui cho dong nao quen khai.
CFG.WING_ATTACH = "origin"

-- Cac diem gan de thu, theo thu tu THAP DAN tren than nguoi.
--
-- Canh nam qua CAO thi doi xuong diem thap hon, va nguoc lai -- goc
-- cua model quyet dinh, khong phai ten diem.
CFG.WING_POINTS = { "origin", "foot left", "chest", "overhead", "head" }

-- Ti le. nil = de nguyen co model.
CFG.WING_SCALE = nil

CFG.DEBUG_MONEY = 999999

-- ---------- Canh cheat co san cua Warcraft ----------
--
-- KHONG CHAN DUOC, CHI PHAT HIEN DUOC: greedisgood/whosyourdaddy do
-- chinh engine xu ly, khong di qua trigger nao cua map va khong co
-- native nao tat. He nay do HAU QUA, khong bat cu bam phim.
--
-- Xem 2_player/13_cheatguard.lua.
CFG.CHEAT_WATCH = true

-- Giay giua hai lan doi chieu.
--
-- 0.5 chu khong 2.0: tu khi CHEAT_ACTION = "revert" thi nhip nay chinh
-- la BE RONG CUA SO nguoi choi con giu duoc tien an cap. 2 giay du de
-- bam mua mot mon; nua giay thi khong.
CFG.CHEAT_TICK = 0.5

-- Sai so cho phep truoc khi coi la lech. Giu NHO: moi duong cap tien
-- cua map deu di qua addGold/addLumber nen so cai phai khop tuyet doi;
-- de rong la tu mo mot khe cho cheat nho lot qua.
CFG.CHEAT_SLACK = 1

-- Lam gi khi bat duoc:
--   "off"       do nhung im lang (chi ghi file vet)
--   "announce"  bao cho ca ban do, KHONG dung toi tien
--   "revert"    bao + THU HOI ve dung con so so cai  <- mac dinh
--
-- VI SAO "revert" moi la cau tra loi that. Chan dau vao thi khong the
-- -- cheat do engine xu ly. Nhung HAU QUA thi thu hoi duoc: so cai giu
-- con so DUNG, nen dat lai thanh tai nguyen ve con so do la xoa sach
-- phan an cap. greedisgood van "chay", chi la vo dung sau nua giay.
--
-- An toan vi CHI TRU PHAN THUA: neu thanh tai nguyen dang THAP hon so
-- cai thi khong dong vao -- to oan vi thieu tien la kieu sai te nhat.
--
-- KHONG co lua chon "ket thuc van". Mot phep do co the sai, va huy van
-- cua ba nguoi vi mot lan do sai la cai gia qua dat.
CFG.CHEAT_ACTION = "revert"

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
-- la lech tran. Xem docs/05-quyet-dinh/0012 va src/1_core/3_sync.lua.
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
CFG.OP_CULT_UP  = 4   -- arg = 0
CFG.OP_CULT_SET = 5   -- arg = bac Linh Can muon nhay toi (dev)
-- OP_SKILL_UP = 6, khai bao canh bang CFG.SKILLS ben duoi.
CFG.OP_GEAR_UP  = 7   -- arg = so thu tu o trang bi trong CFG.GEAR
CFG.OP_RELIC_BUY = 8   -- arg = so thu tu phap khi trong CFG.RELIC
CFG.OP_SHOP   = 9   -- arg = so thu tu mon trong CFG.SHOP
CFG.OP_ITEM   = 10  -- arg = o tui 0..5, dung do bang phim so
CFG.OP_FORTUNE   = 11  -- arg = so thu tu the 1..3 trong luot quay
CFG.OP_GEAR_DISMANTLE = 12 -- arg = so thu tu mon trong CFG.GEAR (Tien Giai)
CFG.OP_WAVE_CALL = 13  -- arg = 0. Nut goi dot tren bang tran dau
CFG.OP_GEAR_UP_ONE = 14 -- arg = so thu tu mon. Luyen DUNG MOT lan
CFG.OP_SIDEQUEST = 15  -- arg = so thu tu trong CFG.SIDE_QUESTS
CFG.OP_GO_HOME   = 16  -- arg = 0. Nut Ve Nha tren bang tran dau
CFG.OP_HOUSE_UP  = 17  -- arg = so thu tu duong nang cap trong CFG.HOUSE_UP
CFG.OP_WING      = 18  -- arg = 0. Nut doi canh o the Trang Bi
CFG.OP_PET       = 19  -- arg = 0. Nut doi Thanh Thu di theo
-- Opcode KHONG bi chan o mot chu so: unpackMsg dung math.floor(v/10^7)
-- nen op 10, 11... van giai duoc. Thu bi chan la arg (< 10^5) va seq
-- (< 100). Xem src/1_core/3_sync.lua.

-- ---------- Mau chu ----------
CFG.C_GOLD = "|cffffcc00"
CFG.C_JADE = "|cff66ffcc"
CFG.C_RED  = "|cffff6666"
CFG.C_GREY = "|cff999999"
-- Nhan "[He Thong]" o dau moi dong cua he thong. Xanh nhat chu
-- khong vang: vang la mau TEN NGUOI CHOI o nhan cua API.say, hai
-- loai dong phai phan biet duoc ngay tu ky tu dau.
CFG.C_SYS  = "|cff7fb2ff"
CFG.C_END  = "|r"
-- ---------- Camera: lenh "-zoom" ----------
--
-- Tam nhin AP CHO MOI NGUOI luc vao map, va cung la cho "-zoom" khong
-- tham so tra ve.
--
-- 2000 chu khong 1650 (mac dinh cua Warcraft): map nay la thu tran, 50
-- con lot mot luc thi o tam 1650 khong thay duoc dau dan quai voi nha
-- chinh cung luc. Rong hon mot chut la doc duoc ca tran.
--
-- Ap luc vao map chu khong bat nguoi choi tu go: mot cai phai go moi
-- van thi 9/10 van se khong ai go.
CFG.ZOOM_DEFAULT = 2000.0

-- Chan tren chan duoi. Khong chan thi "-zoom 999999" day camera ra
-- ngoai vu tru va nguoi choi khong co duong ve tru khoi dong lai game.
CFG.ZOOM_MIN = 900.0
CFG.ZOOM_MAX = 4500.0

-- Giay de camera truot toi tam nhin moi. 0 la nhay ngay.
--
-- 0.35 chu khong 0: nhay ngay thi mat khong kip bam vao dau la tam
-- nhin, va mot cu doi dot ngot doc ra nhu loi ve.
CFG.ZOOM_TIME = 0.35

-- NOI FARZ khi zoom ra. Warcraft cat canh o mot khoang nhat dinh; keo
-- TARGET_DISTANCE ra 4500 ma de nguyen farz thi dia hinh phia xa BIEN
-- MAT thay vi hien ra -- trieu chung nhin ra "map bi thung".
CFG.ZOOM_FARZ = 10000.0

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

-- Hero hien ra o day luc pick, khong phai quanh nha chinh nua.
CFG.RGN_HERO_START = { "HeroStartRegion" }

-- Buoc vao vung nay la dich chuyen ve CFG.RGN_HOUSE. Mot chieu: vung
-- dich la nha chinh chu khong phai vung nay, nen khong co vong lap.
CFG.RGN_HERO_MOVE  = { "HeroMoveRegion" }

-- Luot quay thuong tang khi lan DAU di qua cong ve nha.
--
-- MOT LAN MOI NGUOI, khong phai moi lan qua cong. Cong nay nam ngay
-- duoi cho hero hien ra nen di ra di vao mat ba giay -- thuong moi lan
-- la mot cai may in luot quay vo han.
--
-- 0 de tat.
--
-- DA TAT -- 2026-09-19. Luot quay dau van gio den tu Co Duyen va Thanh
-- Thu, khong phat kem qua khoi dau nua: mot luot quay mien phi ngay
-- giay dau day nguoi choi rang quay la thu tu den, trong khi ca he do
-- duoc dung de THUONG cho viec di danh.
CFG.GATE_ROLL = 0

-- ---------- NHIEM VU PHU: Tu Thanh Thu ----------
--
-- The II cua bang tran dau (phim R). Bon con, mo khoa o BON MOC cach
-- nhau dung 5 canh gioi -- DAU moi khoi 5 con, khong phai cuoi:
--
--    canh gioi  1  Pham Nhan   <- mo ngay tu dau van
--    canh gioi  6  Hoa Than
--    canh gioi 11  Chan Tien
--    canh gioi 16  Tien De
--
-- Nghia la Chu Tuoc KHONG bi khoa: no mo tu giay dau tien. Dung vay --
-- no la pho ban day bai, va chi so no bang dung mot hero canh gioi 1,
-- nen giay dau tien thi thua, vai dot sau thi thang. Cai chan no khong
-- phai cai nut, ma la suc manh.
--
-- unit KHOP VOI THU TU GAP, khong phai thu tu Tu Tuong:
--   B001 Hac -> B002 Trau -> B003 Ho -> B004 Rong
--
-- block: SO THU TU O TRONG LUOI 25, khong phai mot cai ten tu dat.
--
-- ADR 0017 da chot: ten vung ma hoa VI TRI (Blk01..Blk25), vai tro song
-- trong CFG. Vi tri gan nhu khong bao gio doi, vai tro thi doi nhieu
-- lan -- buoc chung vao mot cai ten nghia la moi lan doi y phai sua file
-- nhi phan, mo lai World Editor, roi sua moi tham chieu gg_rct_<Ten>.
--
-- Doi phong ban cua mot nhiem vu = sua MOT so o day.
--
-- Chon hang 5 de cang xa nha chinh cang manh: dia ly noi len tien trinh.
-- Cot 1 la truc chinh cua van (block 1 hero start, 16 quai ra, 21 nha
-- chinh) nen tranh ra; ca bon hang 1-4 cot 2-5 van con trong cho ADR
-- 0014 -- 16 block cho noi dung sau.
--
--        cot1   cot2   cot3   cot4   cot5
--  dong5  NHA    Q1 22  Q2 23  Q3 24  Q4 25
--
-- Vung chua sinh thi nut khoa va ghi "thieu vung" mau DO -- do la loi
-- cua nguoi lam map, khong phai cua nguoi choi. Sinh bang:
--     python w3region.py gen
-- mech: DUNG BANG TU VUNG CUA CFG.BOSS_MECH, khong che co che moi. Tam
-- con boss thuong da chay bang tam co che do; them co che thu chin chi
-- de phuc vu bon con nay la them mot duong chua ai di.
--
-- Thang do: 1 -> 2 -> 2 -> 4 co che. Con dau day MOT bai, con cuoi gom
-- moi thu. Va moi con mot CAU HOI khac nhau, khong phai "nhieu mau hon":
--   Chu Tuoc  lao + phat cuong   -> phai ne, va phai ket lieu nhanh
--   Huyen Vu  khien + phan don   -> danh manh hon la tu giet minh
--   Bach Ho   lao + xe giap      -> cang keo dai cang vo, phai burst
--   Thanh Long gom bon           -> phai lam duoc ca ba bai tren
--
-- arrive = Gate (cua vao, hero hien ra), lair = Lair (hang, boss dung).
--
-- Do tu war3map.w3r: trong moi cap thi Gate nam CAO hon Lair ~2.200 don
-- vi, tuc o phia GAN nha chinh. Doc nguoc lai thi doi hai ten cho nhau,
-- khong phai sua code.
--
-- Ten cu la "Region 004" / "Region 004 Copy" -- khong noi len vi tri,
-- khong noi len vai tro. Da doi bang:
--     python w3region.py rename --doi "Region 004=Quest1Lair" ...
-- ADR 0028: doi ten cang muon cang dat, vi ten la thu DUY NHAT noi Lua
-- voi World Editor (bien toan cuc gg_rct_<Ten>).
--
-- KHONG co vung cua ra. Duong thoat duy nhat la nut VE NHA tren bang R,
-- ma mo bang thi khong dung game -- dung yen doc bang trong luc boss
-- quat CHINH LA cai gia phai tra. Do la thu thach co chu y, khong phai
-- thieu sot. arrive la cho hero hien
-- ra, lair la cho boss dung san tu luc vao map. exit la cua ra de bo
-- chay giua chung. Chua ve thi nut khoa va noi ro thieu vung nao.
-- 'icon' la CHAN DUNG, dung o o Thanh Thu cua the Trang Bi.
--
-- Truoc day o do treo CFG.GEAR_PET_ICON -- MOT duong dan co dinh -- nen
-- doi pet xong o van hien Chu Tuoc. Nguoi choi bam DOI, chu doi, con
-- thu ngoai san doi, ma cai o thi khong: trong nhu nut bam hong.
--
-- Cung bon file ma CFG.RELIC dang dung (avatar\B001..B004.blp), va cung
-- thu tu -- Phap Khi thu i mo boi Thanh Thu thu i.
CFG.SIDE_QUESTS = {
  { unit = id('B001'), vi = "Chu Tuoc",   en = "Vermilion Bird", rank =  1, seconds =  45.0, hits = 16.0, rolls =  3,
    icon = [[avatar\B001.blp]],
    mech = { "charge", "enrage" },
    arrive = { "Quest1Gate" }, lair = { "Quest1Lair" } },

  { unit = id('B002'), vi = "Huyen Vu",   en = "Black Tortoise", rank =  6, seconds =  85.0, hits = 12.0, rolls =  5,
    icon = [[avatar\B002.blp]],
    mech = { "shield", "reflect" },
    arrive = { "Quest2Gate" }, lair = { "Quest2Lair" } },

  { unit = id('B003'), vi = "Bach Ho",    en = "White Tiger",    rank = 11, seconds = 150.0, hits =  9.0, rolls =  8,
    icon = [[avatar\B003.blp]],
    mech = { "charge", "shred" },
    arrive = { "Quest3Gate" }, lair = { "Quest3Lair" } },

  { unit = id('B004'), vi = "Thanh Long", en = "Azure Dragon",   rank = 16, seconds = 240.0, hits =  7.0, rolls = 12,
    icon = [[avatar\B004.blp]],
    mech = { "slam", "summon", "lifesteal", "enrage" },
    arrive = { "Quest4Gate" }, lair = { "Quest4Lair" } },
}

-- CHI SO THANH THU: DO DOI, y het boss thuong -- nhung do LUC NGUOI
-- CHOI BUOC VAO, khong phai luc sinh ra.
--
-- LOI DA SHIP: ban dau toi suy chi so tu CANH GIOI cua, nghi rang duong
-- cong Tu Vi se tu lo phan thu tu. Sai hoan toan. Do tu file vet, canh
-- gioi 16, mot hero:
--
--     chi so THAT cua hero      30.105
--     phan den tu canh gioi 16     511   <- 1,7%
--     phan tu trang bi + ky nang 29.594  <- 98,3%, gap 59 LAN
--
-- Canh gioi gan nhu KHONG phai suc manh cua nguoi choi; trang bi va ky
-- nang moi la. Nen con dau (canh gioi 1, chua trang bi) thi qua dai, ba
-- con sau (da full trang bi) thi vo trong mot nhip.
--
-- Gio: mau = dps_ca_doi x seconds, do NGAY LUC BUOC VAO. Thu tu van bi
-- chan boi nut khoa theo canh gioi; do kho tang dan bang 'seconds' va
-- 'hits' rieng tung con chu khong bang mot duong cong khong lien quan.
-- Tam san: du de danh ai buoc vao hang, khong du de duoi ra ngoai.
CFG.SIDE_QUEST_AGGRO   = 800.0
-- Day xich: di qua bay nhieu don vi khoi hang thi bi keo ve. Phai LON
-- hon AGGRO, neu khong no vua duoi mot buoc la bi giat lai -- nhin ra
-- con boss bi dong kinh.
CFG.SIDE_QUEST_LEASH   = 1400.0
CFG.SIDE_QUEST_TICK    = 1.0    -- giay giua hai lan kiem day xich
-- Bo hoang bay nhieu giay thi con thu TRA VE NGUYEN TRANG: hoi day mau,
-- bo ghim chi so, do lai theo suc cua doi o thoi diem moi.
--
-- LO HONG DA CO, day la mieng va: armPin() ghim chi so VINH VIEN. Ghim
-- la dung -- xem chu thich o armPin -- nhung khong bo ghim thi sinh ra
-- duong di nay: mo khoa Huyen Vu o canh gioi 6, cham vao no mot cai de
-- ghim, bo di, quay lai o canh gioi 20. No van la con thu do cho mot
-- doi canh gioi 6. Ca bon con deu mo khoa SOM hon luc du suc danh, nen
-- day khong phai truong hop hiem -- do la duong tu nhien.
--
-- 20 giay: du dai de mot pha chet-hoi-sinh-chay-vao khong bi tinh la bo
-- cuoc, du ngan de khong ai phai dung cho.
CFG.SIDE_QUEST_RESET   = 20.0
CFG.SIDE_QUEST_SCALE   = 1.6    -- Thanh Thu to hon hero, nho hon boss (2.2)
-- Mac dinh khi mot con khong tu khai 'seconds' / 'hits'.
--   seconds: bao nhieu giay hoa luc CA DOI de ha. Boss thuong la 40s.
--   hits   : bao nhieu don de ha MOT hero dung yen. Cang it cang dau.
CFG.SIDE_QUEST_SECONDS = 60.0
CFG.SIDE_QUEST_HITS    = 14.0

-- ---------- Nha chinh ----------
-- Mountain King. Day la HERO, khong phai cong trinh -- xem
-- docs/02-he-thong/nha-chinh.md ve nhung khac biet phai xu ly.
CFG.HOUSE_UNIT   = id('Hmkg')

-- Nha chinh la HERO, ma hero Warcraft co san SAU O TUI. Nguoi choi keo
-- mot binh mau tha vao nha chinh la binh do nam trong tui nha chinh --
-- khong ai lay ra duoc, va khong loi nao bao.
--
-- HAI LOP, vi khong lop nao mot minh du chac:
--
--   1. Go luon ability tui do. 'AInv' la Inventory (Hero) cua Warcraft,
--      nhung day la mot ma DOAN chu chua do -- neu ma sai thi
--      UnitRemoveAbility tra false va file vet ghi ro.
--   2. Bat su kien nhat do: nha chinh vua nhan mon nao thi TRA NGAY ra
--      dat. Lop nay khong phu thuoc ma nao ca, nen no la lop chac.
CFG.HOUSE_REMOVE_ABILITIES = { id('AInv') }
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
--         src/4_ui/3_skillframe.lua -- hong thi xoa file do la xong.
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
  { id = id('H001'), title = "Thiet Son", name = "Hart", role = "Warrior - Tanker", abilities = {}, skills = nil,
    -- Icon TU VE. Nguon: docs/01-tmp/hero/<ma unit>.png
    -- Sinh bang: python w3gear_icons.py
    icon = [[hero\H001.blp]],
    desc_vi    = { "Don quai dong", "Chiu don khoe", "Yeu truoc boss" },
    desc_en = { "Clears crowds", "Very tanky", "Weak vs bosses" } },
  -- DA MO KHOA -- 2026-09-19. Cay ky nang xong: xem CFG.SKILLS[H002].
  { id = id('H002'), title = "Lac Vu", name = "Hvwd", role = "Shooter - Carry", abilities = {}, skills = nil,
    -- Icon TU VE. Nguon: docs/01-tmp/hero/<ma unit>.png
    -- Sinh bang: python w3gear_icons.py
    icon = [[hero\H002.blp]],
    desc_vi    = { "Sat thuong cao nhat", "Danh tu xa", "Rat mong" },
    desc_en = { "Top damage", "Long range", "Very fragile" } },
  -- DA MO KHOA -- 2026-09-19. Cay ky nang xong: xem CFG.SKILLS[H003].
  -- Ca ba hero deu mo, nen HERO_UNIQUE gio co nghia that.
  { id = id('H003'), title = "Han Nguyet", name = "Hkal", role = "Mage - Support", abilities = {}, skills = nil,
    -- Icon TU VE. Nguon: docs/01-tmp/hero/<ma unit>.png
    -- Sinh bang: python w3gear_icons.py
    icon = [[hero\H003.blp]],
    desc_vi    = { "Hoi mau, tiep suc", "Lam cham quai", "Mot minh thi yeu" },
    desc_en = { "Heals and buffs", "Slows the wave", "Weak alone" } },
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
-- Duong dan phai KHOP TUNG KY TU voi war3map.imp, va voi chunk texture
-- ben trong chinh file .mdx. Doc duong dan that bang:
--   python w3import.py list
--   python -c "import re,io; print(re.findall(rb'[ -~]{3,120}?\.blp', io.open(F,'rb').read()))"
-- Dat texture sai cho la model ra o XANH LA va khong co loi nao bao.
CFG.PRELOAD = {
  [[war3mapImported\UtherV2.mdx]],            -- H001 Hart
  [[units\HotS\Uther\Uther.blp]],
  [[war3mapImported\SylvanasHighElf.mdx]],    -- H002 Hvwd (Agi)
  [[units\HotS\Sylvanas\SylvanasHighElf.blp]],
  [[units\HotS\Sylvanas\BlackArrow1.blp]],
  [[war3mapImported\Orphea_web.mdx]],         -- H003 Hkal (Int)
  [[Orphea.blp]],
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

-- CFG.PICK_TITLE da chuyen sang 6_i18n.lua, khoa "pick_title".

-- ---------- Bang chon hero ----------
-- Toa do man hinh: X 0.0..0.8, Y 0.0..0.6.
--
-- BA COT DOC, moi hero mot cot, va MOT nut SELECT chung o duoi -- cung
-- khuon voi khung Co Duyen.
--
-- CHON ROI MOI XAC NHAN. Chon hero la viec khong lam lai duoc
-- (CFG.HERO_UNIQUE), nen mot cu keo chuot nham khong duoc phep tra gia
-- bang ca van. Bam mot cot la CHON, doi y thoai mai; bam SELECT moi
-- that.
--
-- Ban truoc la mot cot doc, moi hero mot dong rong bang ca bang. Doi
-- vi trong nhu mot cai menu chu khong nhu mot man chon tuong. Cai gia
-- phai tra la be ngang mot muc tut tu 0.360 xuong 0.160, nen ba gach mo
-- ta khong noi lien mot dong duoc nua ma phai MOI GACH MOT DONG -- text
-- frame cua Warcraft khong tu xuong dong, chu thua la de len cot ben.
--
-- Gio 'desc_vi' lai phai ngan 3-4 tu that. Do la rang buoc CO Y doi
-- lay: bo cuc ba cot doc ke nhau cho so sanh ba hero bang mot cai liec
-- mat, con mot cot doc thi phai doc tu tren xuong.
CFG.CARD_W     = 0.540   -- be ngang CA KHUNG (ba cot chia nhau)
CFG.CARD_GAP   = 0.010   -- khoang cach hai cot
CFG.CARD_ICON  = 0.056   -- canh o icon, to hon ban mot cot vi co cho
CFG.CARD_PAD   = 0.010   -- le trong
-- Vien trang tri cua backdrop an mat mep trong. EscMenuBackdrop co
-- vien day, va CARD_PAD mot minh khong du -- tieu de leo len dung
-- duong vien vang. Do bang mat tren anh chup 1080p.
CFG.CARD_BORDER = 0.010
CFG.CARD_LINE  = 0.014   -- khoang cach hai dong chu ben trong mot dong
CFG.CARD_X     = 0.40    -- tam ngang cua bang
CFG.CARD_Y     = 0.38    -- tam doc

-- CFG.CARD_H va CFG.CARD_TOP da bo. Cao mot cot SUY RA tu co icon va so
-- dong chu (xem colH trong 2_heroframe.lua) -- de o day thi doi co chu
-- mot cai la chu tro ra ngoai vien, dung loi ma bang phim E da dinh mot
-- lan roi.

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

-- Template nut cho MOT COT hero.
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
-- "Moi nguoi mot con, khong ai lay trung."
--
-- CHI co nghia khi con NHIEU HON MOT hero mo khoa. Tu 2026-09-19 da co
-- HAI con mo (Hart va Hvwd), nen luat nay bat that: nguoi thu ba van
-- chua co gi de lay cho toi khi Hkal xong.
--
-- 2_heropick.lua tu tat luat nay khi so hero mo khoa <= 1, nen khoa hay
-- mo deu khong phai sua dong nay.
CFG.HERO_UNIQUE = true

-- Hero sinh ra cach nha chinh bao xa.
-- Bang hero: dong 1 la TEN NHAN VAT, dong 2 la "Level <bac> <canh gioi>".
--
-- Truoc day ca hai dong deu ghi ten unit cua Object Editor, nen dong
-- hai la "Level 1 Mage" VINH VIEN -- hero trong map nay khong bao gio
-- len cap. Dong quan trong thu hai cua bang noi dung mot thu: mot he
-- thong khong ton tai.
--
-- false de tra lai nhu cu. Xem 15_heroname.lua.
CFG.HERO_NAME_SHOW_RANK = true

CFG.HERO_SPAWN_OFFSET = 500.0

-- Hero chet bao lau thi song lai. 0 = tat han, hero chet nam luon.
--
-- TRUOC 2026-09-19 KHONG CO HE NAY. onAnyDeath() chi xu ly nha chinh
-- va quai; duong song lai duy nhat la Ankh 500 vang hoac bi dong Hoi
-- Sinh cua A006. Chet o wave 30 ma khong co Ankh thi ngoi xem 70 wave
-- con lai -- trong map co-op ba nguoi do la cho mot nguoi nghi choi
-- giua chung ma van phai ngoi do.
--
-- Te hon: measureParty() bo qua hero chet nen boss NHO LAI theo. Doi
-- hai nguoi thang de hon doi ba nguoi co mot xac -- nghich ly, va no
-- am tham.
--
-- 30 giay: du dai de chet la mat mat that (mot wave thuong keo 40-60
-- giay, nen mat gan tron mot wave), du ngan de khong ai bo game. Song
-- lai o NHA CHINH chu khong o cho vua chet -- cho vua chet la cho vua
-- thua, va doan duong quay lai chinh la phan gia phai tra.
CFG.HERO_REVIVE_SECONDS = 30.0

-- Bang tong ket dung tren man hinh bao lau truoc khi hop thoai ket qua
-- cua Warcraft che mat. Truoc day la 3 giay cho MOT dong chu; gio la
-- mot bang nhieu dong nen phai lau hon.
CFG.END_SUMMARY_SECONDS = 10.0

-- ============================================================
--  DOT QUAI  --  100 stage
--  Luat: docs/02-he-thong/dot-quai.md
--  Duong cong: docs/03-du-lieu/duong-cong-suc-manh.md
-- ============================================================

-- 20 canh gioi. 'ten' phai KHONG DAU: font goc cua WC3 thieu glyph
-- Latin Extended nen chu co dau hien ra o vuong.
-- 'coi' 1..4 = Pham / Yeu / Tien / Than -- quyet dinh model va nhip wave.
CFG.REALMS = {
  { vi = "Pham Nhan", en = "Mortal", world = 1 },
  { vi = "Luyen Khi", en = "Qi Refining", world = 1 },
  { vi = "Truc Co", en = "Foundation", world = 1 },
  { vi = "Kim Dan", en = "Golden Core", world = 1 },
  { vi = "Nguyen Anh", en = "Nascent Soul", world = 1 },
  { vi = "Hoa Than", en = "Spirit Severing", world = 2 },
  { vi = "Luyen Hu", en = "Void Refining", world = 2 },
  { vi = "Hop The", en = "Body Integration", world = 2 },
  { vi = "Dai Thua", en = "Great Ascension", world = 2 },
  { vi = "Do Kiep", en = "Tribulation", world = 2 },
  { vi = "Chan Tien", en = "True Immortal", world = 3 },
  { vi = "Thien Tien", en = "Heavenly Immortal", world = 3 },
  { vi = "Kim Tien", en = "Golden Immortal", world = 3 },
  { vi = "Thai At", en = "Taiyi", world = 3 },
  { vi = "Dai La", en = "Great Luo", world = 3 },
  { vi = "Tien De", en = "Immortal Emperor", world = 4 },
  { vi = "Thanh Nhan", en = "Saint", world = 4 },
  { vi = "Dao To", en = "Dao Ancestor", world = 4 },
  { vi = "Hon Don Than", en = "Primordial God", world = 4 },
  { vi = "Sang The Than", en = "World Creator", world = 4 },
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
  { vi = "So Ki",    en = "Early" },
  { vi = "Trung Ki", en = "Middle" },
  { vi = "Hau Ki",   en = "Late" },
  { vi = "Vien Man", en = "Perfection" },
}

-- CFG.TIER_PERFECTION da chuyen sang 6_i18n.lua, khoa "tier_perfection". Ten
-- tang cuoi la CHU HIEN THI chu khong phai tham so, ma chu hien thi
-- phai co ca hai thu tieng. Cung ly do voi CFG.PICK_TITLE truoc day.

-- ---------- Thanh phan wave ----------
CFG.WAVE_MOB_COUNT   = 50    -- co dinh, khong doi theo so nguoi (ADR 0009)
CFG.WAVE_ELITE_COUNT = 1

-- ---------- DOT MOI CHI RA KHI NGUOI CHOI GOI ----------
--
-- Khong con dong ho nao keo dot sau vao. Nhip cua ca van do nut "GOI DOT"
-- tren bang tran dau (phim R) quyet dinh, va CHI no.
--
-- DA BO, va vi sao:
--
--   WAVE_TIME         Giay moi wave theo coi. No khong con cam lai tu khi
--                     WAVE_ONLY_WHEN_CLEAR bat: don sach som thi
--                     onMobDeath keo dot sau vao truoc, don cham thi dong
--                     ho tu hoan. Con so chay tren man hinh khong quyet
--                     dinh gi -- chi tao ap luc gia.
--                     Bo no cung bo luon rang buoc kho chiu nhat cua
--                     ADR 0018:
--                       WAVE_TIME[coi] > quang duong/toc do + thoi gian giet
--                     Rang buoc do da lam sai WAVE_TIME hai lan, va khoa
--                     cung moi lan doi CFG.MOB_UNIT.
--
--   WAVE_FIRST_DELAY  15 giay truoc dot 1. Da chet san vi WAVE_WAIT_FIRST.
--
--   WAVE_AUTO_NEXT    Don sach xong 1.5 giay la dot moi ra. DAY moi la thu
--   WAVE_CLEAR_DELAY  khong cho nguoi choi tho: chua kip mo bang mua da da
--                     co dot moi tren dau.
--
--   WAVE_WAIT_FIRST   Gio MOI dot deu cho goi, khong rieng dot 1.
--
--   S.waveDlg         Cua so dem nguoc cua Warcraft. Xoa theo WAVE_TIME.

-- Con quai song thi khong goi duoc dot moi.
--
-- Goi som la bo qua phan kho de an tien dot sau; va hai dot chong len nhau
-- thi dot sau lai keo dai dot dang do, mot day chuyen nguoi choi khong
-- ngan duoc.
--
-- Dat false thi nut goi duoc bat moi luc -- nhung luc do ADR 0009 (50 linh
-- co dinh) mat nghia, vi nguoi choi tu chon so quai tren map.
CFG.WAVE_ONLY_WHEN_CLEAR = true

-- ---------- TU CHINH: cai lam 80 stage thuong khac nhau ----------
--
-- Moi stage thuong boc MOT tu chinh. Khong co no thi bon tang cua mot
-- canh gioi chi cach nhau x1.054 chi so -- nguoi choi bam dung ngan ay
-- nut, bon lan, hai muoi canh gioi.
--
-- LUAT CUA BANG NAY: mot con quai DAY GAP RUOI thi nguoi choi van bam
-- dung ngan ay nut. Mot con quai TU HOI MAU thi buoc phai doi thu tu
-- bam. Chi cai sau moi la loi choi -- nen moi tu chinh phai doi CACH
-- danh, khong phai doi con so.
--
-- BOC NGAU NHIEN (chot 2026-09-19), nhung KHONG trung cai vua roi:
-- hai stage lien tiep giong nhau la nguoi choi tuong he hong.
--
-- GetRandomInt PHAI goi tren MOI MAY cung thu tu. spawnStage() chay tu
-- duong dong bo nen an toan -- dung boc o bat cu callback cua frame nao.
--
-- THOI TIET: moi tu chinh mot kieu troi. Do la lop bao thu BA, canh
-- dong chu (troi di) va mau quai (phai nhin vao quai). Troi thi thay
-- ma khong can nhin dau ca.
--
-- 'weather' la DANH SACH UNG VIEN, khong phai mot ma.
--
-- LOI DA SHIP: ban dau tin rang "AddWeatherEffect tra ve handle" nghia
-- la ma dung. KHONG PHAI. No tra handle cho ca ma rac -- hai ma
-- 'WNcw' (bao cat) va 'WOlw' (gio Outland) deu "dung duoc" theo phep
-- do do, va tren man hinh thi khong hien gi ca.
--
-- Phep do THAT la con mat: lenh dev "-sky" bat tung ma mot de nhin.
-- Chi ma nao NHIN THAY moi duoc vao bang nay. Xem CFG.SKY_PROBE.
--
-- DO XONG 2026-09-19 tren 1.31.1, tileset L: trong 22 ma thu, CHI BON
-- ma hien ra man hinh --
--
--   RLhr  Lordaeron mua rao + set
--   SNbs  Northrend bao tuyet
--   SNhs  Northrend tuyet nang
--   MEds  Dalaran Shield (mai vom tim)
--
-- Toan bo 8 kieu SUONG MU, moi kieu mua/tuyet NHE, va ca 6 ung vien
-- gio/bao cat deu khong hien gi. Danh sach ung vien vi the rut con
-- DUNG MOT ma moi tu chinh -- de nhieu la moi cai giu mot handle chet.
--
-- Bon ma cho nam tu chinh, nen mot cai phai di tay khong: Trung Linh.
--
-- KHONG can region: dung bj_mapInitialPlayableArea, thu da dung o ba
-- cho khac trong map nay. Nhieu hieu ung deu gan duoc vao CUNG mot
-- rect roi bat/tat tung cai -- khong phai moi loai mot vung.
--
-- 'kind' quyet dinh cho cai dat, khong phai cho trang tri:
--   ability -> gan ability goc cua Warcraft vao tung con
--   damage  -> he so nhan o SU KIEN SAT THUONG
--   death   -> su kien chet
--   bounty  -> nhan thuong trong rewardAll()
--
-- VI SAO hai cai giam sat thuong KHONG dung giap: ADR 0010 -- duong
-- cong sinh ra EHP, mau that suy nguoc ra TU GIAP. So vao giap la lang
-- le doi ca duong cong do kho. Phai nhan o su kien sat thuong.
-- Ma da DO XONG 2026-09-19, danh sach giu nguyen mot cai.
--
-- Ca nam deu dung duoc ung vien DAU TIEN (file vet: "modifier: thoi
-- tiet lifesteal = 'RLhr'" ...). Giu them hai ung vien du phong khong
-- ton gi, va no la tu lieu cho ban Warcraft khac.
-- Danh sach ma thoi tiet de DO BANG MAT, qua lenh dev "-sky N".
--
-- Khong co cach nao kiem bang code: AddWeatherEffect nhan ca ma rac.
-- Nen cong cu duy nhat la bat tung cai roi nhin. Cai nao hien ro thi
-- moi cho vao CFG.MODIFIERS.
-- DA DO 2026-09-19 tren 1.31.1: chi bon ma dau hien ra man hinh, 18
-- ma con lai khong hien gi. Giu ca danh sach lam TU LIEU -- ban
-- Warcraft khac co the khac, va lenh "-sky" van dung de do lai.
CFG.SKY_PROBE = {
  { 'RLhr', "Lordaeron mua rao + set     -- HIEN" },
  { 'RLlr', "Lordaeron mua (nhe)" },
  { 'RAhr', "Ashenvale mua (nang)" },
  { 'RAlr', "Ashenvale mua (nhe)" },
  { 'SNbs', "Northrend bao tuyet         -- HIEN" },
  { 'SNhs', "Northrend tuyet nang        -- HIEN" },
  { 'SNls', "Northrend tuyet (nhe)" },
  { 'FDbh', "Suong mu XANH (nang)" },
  { 'FDbl', "Suong mu XANH (nhe)" },
  { 'FDgh', "Suong mu LUC (nang)" },
  { 'FDgl', "Suong mu LUC (nhe)" },
  { 'FDrh', "Suong mu DO (nang)" },
  { 'FDrl', "Suong mu DO (nhe)" },
  { 'FDwh', "Suong mu TRANG (nang)" },
  { 'FDwl', "Suong mu TRANG (nhe)" },
  { 'MEds', "Dalaran Shield, mai vom tim -- HIEN" },
  { 'WOcw', "Outland gio (ung vien A)" },
  { 'WOlw', "Outland gio (ung vien B)" },
  { 'WNcw', "Bao cat (ung vien A)" },
  { 'WHwd', "Bao cat (ung vien B)" },
  { 'WOsd', "Bao cat (ung vien C)" },
  { 'LRaa', "Ung vien la" },

  -- Them 2026-09-19 tu mot bang nguoi khac dua. Bang do co 8 dong la
  -- ma MINH DA DO VA TRUOT (FDgh FDgl FDwh FDwl FDrh FDrl SNls RLlr) --
  -- nen bang do khong dang tin nguyen khoi. Bon ma duoi la phan THAT
  -- SU MOI, chua ai do: cu do, khong cai vao bang tu chinh truoc.
  --
  -- Bang do con khuyen "dung FourCC se mo khoa 22 hieu ung an". Sai:
  -- makeWeather() va devSky() DEU da goi FourCC tu dau.
  { 'RPlr', "Rays of Light -- tia nang" },
  { 'RPmo', "Rays of Moonlight -- tia trang" },
  { 'OAsf', "Outland bao cat (ung vien D)" },
  { 'WTlg', "Gio manh (ung vien E)" },
}

CFG.MODIFIERS = {
  -- Hut mau: dung ABILITY goc chu khong tu cong mau.
  --
  -- Ability co hieu ung xanh la moi don -- nhin la biet, khong phai doc
  -- chat. Va engine lo phan tinh toan, ta khong phai bat su kien.
  --
  -- Ma ability thi DO chu khong go: xem probeAbility() o 5_modifier.lua.
  -- Gan sai ma thi UnitAddAbility tra false va ham im lang khong lam gi.
  { code = "lifesteal", kind = "ability",
    vi = "Hut Mau", en = "Vampiric",
    abils = { 'AUav', 'ANvc', 'Avam' },
    color = { 255, 60, 60 },
    weather = { 'RLhr' },
    sky_vi = "giong bao co set", sky_en = "thunderstorm",
    desc_vi = "Quai tu lanh khi danh trung. Don tung con, dung rai.",
    desc_en = "They heal as they hit. Focus one, do not spread." },

  { code = "resist_magic", kind = "damage", spell = true, cut = 0.50,
    vi = "Chan Phep", en = "Spell Ward",
    -- Mai vom Dalaran: mot cai KHIEN PHEP phu ca vung. Trong bon ma
    -- con dung duoc thi day la cai hop chu de nhat, va cung la cai
    -- KHAC HAN ba cai kia -- khong the nham voi mua hay tuyet.
    color = { 180, 110, 255 },
    weather = { 'MEds' },
    sky_vi = "mai vom phep", sky_en = "arcane dome",
    desc_vi = "Ky nang chi con nua sat thuong. Danh tay.",
    desc_en = "Skills deal half. Use auto-attacks." },

  { code = "resist_phys", kind = "damage", spell = false, cut = 0.50,
    vi = "Day Da", en = "Thick Hide",
    -- Mau XANH THEP chu khong nau: hai tu chinh dung tuyet (Day Da va
    -- No Tan) la cap de nham nhat, nen mau quai phai keo chung ra xa
    -- nhau het co. Nau voi cam thi van gan nhau.
    color = { 150, 190, 215 },
    weather = { 'SNhs' },
    sky_vi = "tuyet nang", sky_en = "heavy snow",
    desc_vi = "Don danh thuong chi con nua sat thuong. Xa chieu.",
    desc_en = "Auto-attacks deal half. Use skills." },

  -- Ban kinh va he so tinh theo SAT THUONG CUA CHINH CON DO, nen no tu
  -- bam theo duong cong quai -- khong phai mot con so phang thanh vo
  -- nghia o canh gioi 15.
  { code = "explode", kind = "death", radius = 300.0, factor = 4.0,
    vi = "No Tan", en = "Volatile",
    color = { 255, 150, 60 },
    weather = { 'SNbs' },
    sky_vi = "bao tuyet", sky_en = "blizzard",
    desc_vi = "Chet thi no. Dung dung chum mot cho.",
    desc_en = "They burst on death. Do not bunch up." },

  -- Khong hieu ung gi, doi lai x2 MOI phan thuong cua stage nay.
  --
  -- Nhan ca Go va luot Co Duyen (chot 2026-09-19): Go se co them cho
  -- tieu, nen hao phong duoc. Tinh ra ky vong ca van: +16 stage nhan
  -- doi -> Go 260 -> ~292, luot quay 169 -> ~185.
  { code = "bounty", kind = "bounty", mult = 2.0,
    vi = "Trung Linh", en = "Bountiful",
    -- KHONG co thoi tiet, va do la chu dich.
    --
    -- Chi bon ma con dung duoc cho nam tu chinh, nen mot cai phai di
    -- tay khong. Cho no vao dung cai nay: dot nghi va hai tien thi
    -- TROI QUANG la dau hieu dung nhat -- vang mat cung la mot tin.
    color = { 255, 230, 120 },
    weather = nil,
    sky_vi = "troi quang", sky_en = "clear skies",
    desc_vi = "Quai khong co gi dac biet -- doi lai thuong GAP DOI.",
    desc_en = "Nothing special about them -- but rewards are DOUBLED." },
}

-- ---------- Do lai so quai song ----------
--
-- LOI THAT DA XAY RA (ADR 0018): S.alive ket tren 0 thi MOI loi thoat
-- cung chet -- ca duong "don sach" lan lenh goi tay, vi ca hai deu hoi
-- cung mot con so. Ket thi ket vinh vien, khong loi nao bao.
--
-- Nen cu mot luc phai DO LAI thay vi tin con so dang giu.
--
-- DEM QUA S.mobs, KHONG quet map theo chu so huu. S.mobs chi duoc ghi o
-- duong sinh quai cua he wave (2 cho, ca hai trong spawnStage), nen quai
-- DAT SAN o cac vung dat sau nay khong bao gio lot vao. Dem theo
-- GetOwningPlayer == S.enemy thi vo luon chung, va S.alive khong bao gio
-- ve 0 -- dung cai bay ma phep do nay dinh chua.
CFG.WAVE_RECOUNT = 10.0


-- ---------- Hai moc nghi cua moi canh gioi ----------
--
-- Nut goi dot doi NHAN o hai moc nay, chu khong chi doi so:
--
--   tang 1..4         GOI DOT (n)
--   tang 4 don sach   TRIEU BOSS          <- moc 1
--   boss chet         SANG CANH GIOI SAU  <- moc 2
--
-- Tu 2026-09-18 ca 5 stage deu cho goi, nen hai moc nay khong con la
-- "dung dong ho" nua -- chung la hai NHAN khac cua cung mot nut.
--
-- Nhung van giu bien rieng (S.waitNext) chu khong gop lam mot, vi ba
-- trang thai lam ba viec khac nhau: goi dot thuong, trieu boss, va sang
-- canh gioi. Moc 2 la cho Loi Kiep se gan vao.
--
-- Dat false thi hai moc bien mat: boss ra ngay sau tang 4, va canh gioi
-- sau ra ngay sau boss -- khong con cho tieu tien.
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
-- Voi MOB_EHP_FOLLOW_CULT: mu la (TANG - 1), tuc 0..3 trong mot canh
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
CFG.MOB_EHP_FOLLOW_CULT = true

-- Chi con dung khi MOB_EHP_FOLLOW_CULT = false.
CFG.MOB_EHP_REALM_STEP = 1.22    -- moi canh gioi. Mu 19

-- Mu cua he so Linh Can dung cho SAT THUONG quai (< 1 = quai doc cham
-- hon hero khoe len). Chi dung khi MOB_EHP_FOLLOW_CULT bat.
CFG.MOB_DMG_FOLLOW_POW    = 0.85

CFG.MOB_DMG_BASE       = 6.0
CFG.MOB_DMG_GROWTH     = 1.016
CFG.MOB_DMG_REALM_STEP = 1.12

CFG.MOB_ARMOR_BASE      = 0.0
CFG.MOB_ARMOR_PER_REALM = 1.0
CFG.ARMOR_DR_PER_POINT  = 0.06   -- cong thuc giap cua Warcraft III

CFG.ELITE_EHP = 10.0
CFG.ELITE_DMG = 2.5
CFG.ELITE_SCALE = 3.2   -- gap doi 1.6 cu: tinh anh phai nhin ra ngay
CFG.BOSS_SCALE = 2.2

-- ============================================================
--  BOSS  --  do theo SUC MANH THAT cua doi, khong theo duong cong
-- ============================================================
--
-- CFG.BOSS_EHP / BOSS_DMG cu (x80 / x3 tren duong cong quai thuong) da
-- bo. Ly do: duong cong quai thuong khong biet doi hero manh den dau.
--
-- LOI DO DUOC, va no khong rieng gi boss: Tu Vi cong deu ca ba chi so,
-- ma 1 Agi = 1/3 giap. Cuoi van hero co 8,070 giap -> giam 99.79% sat
-- thuong. Boss danh 2,036 chi con 4 mau. Moi con quai trong map deu vay.
--
--   bac  5: giap   106 -> giam 86.5%
--   bac 10: giap   537 -> giam 97.0%
--   bac 20: giap 8,070 -> giam 99.79%
--
-- Nen boss KHONG dat sat thuong theo mot con so tuyet doi nua. No do
-- MAU HIEU DUNG cua tung hero (mau / (1 - giam)) roi chia ra, nen don
-- danh luon an dung mot phan mau that du giap bao nhieu.

-- Boss song duoc bao nhieu giay duoi hoa luc CA DOI.
CFG.BOSS_SECONDS = 40.0

-- Uoc luong sat thuong moi giay cua mot hero = he so x (DMG_BASE + chi
-- so cao nhat).
--
-- 1.0 vi do duoc: 1 Str = 1 sat thuong don danh, va don thuong ~1.6
-- giay mot nhat -- cong voi ky nang thi tong xap xi dung bang chi so.
CFG.BOSS_DPS_FACTOR = 1.0

-- ---------- Tu MOT DON sang MOI GIAY ----------
--
-- LOI DA SHIP: measureParty() tinh (CULT_DMG_BASE + chi so cao nhat) --
-- do la sat thuong MOT DON, cung cong thuc ma skill dung. Roi mau boss
-- lay so do nhan BOSS_SECONDS, tuc coi mot don bang mot giay.
--
-- Do duoc tu file vet, canh gioi 16, mot hero:
--     dps 30122 -> mau 1204880
-- Hero danh hon mot don moi giay va con ky nang, nen boss chet nhanh
-- gap may lan 40 giay thiet ke. Nguoi choi bao "oanh ti chet".
--
-- Gio chia cho HOI CHIEU DON DANH THAT doc bang native. Native vang mat
-- thi lui ve so nay va API.trace -- khong nuot.
CFG.BOSS_ATTACKS_FALLBACK = 1.0    -- don/giay khi khong doc duoc hoi chieu

-- Ky nang gop them bao nhieu vao sat thuong moi giay, tinh theo lan don
-- thuong. 1.0 = ky nang gop bang dung don thuong -> tong gap doi.
--
-- DAY LA UOC LUONG, chua do duoc: no phu thuoc nguoi choi bam bao nhieu
-- va hoi chieu tung skill. Dong trace luc boss CHET in ra thoi gian
-- thuc so voi BOSS_SECONDS -- chinh so nay theo do chu dung doan.
CFG.BOSS_SKILL_SHARE = 1.0

-- Bi dong nao cong % vao moi don danh DON MUC TIEU.
--
-- Tach khoi BOSS_SKILL_SHARE vi day khong phai uoc luong -- day la con
-- so DOC DUOC tu bac ky nang cua tung hero. Gop vao mot hang so chung
-- thi Hart va Hvwd phai dung chung mot con so ma san luong that cua
-- chung khac nhau.
--
-- KHONG co "cleave": Chem Lan van sang con BEN CANH, ma boss dung mot
-- minh nen no cong 0. Gom vao la boss thanh qua day mau cho Hart.
CFG.BOSS_DPS_PASSIVE_FX = { "burn" }

-- Boss ha mot hero dung yen trong bao nhieu don.
CFG.BOSS_HITS_TO_KILL = 12.0

-- ---------- Ky nang boss: XEM CFG.BOSS_MECH ----------
--
-- SAU khoa o day da XOA ngay 2026-09-19 vi KHONG FILE NAO DOC:
--
--   BOSS_ENRAGE_AT / BOSS_ENRAGE_DMG     -> BOSS_MECH.enrage { at, dmg }
--   BOSS_SKILL_CD / _RADIUS / _FACTOR    -> BOSS_MECH.slam { cd, radius, factor }
--   BOSS_LIFESTEAL                       -> BOSS_MECH.lifesteal { ratio }
--
-- Chung song sot qua dot chuyen sang BOSS_MECH va nam do mot minh. Cai
-- gia phai tra khong phai la vai dong thua: docs doc chung roi ta CO
-- CHE SAI theo -- boss.md viet "cu BOSS_ENRAGE_STEP giay boss cong sat
-- thuong", trong khi code kich theo NGUONG MAU (BOSS_MECH.enrage.at).
--
-- Mot khoa khong ai doc la mot lo'i cho chinh minh doc sai. Quet dinh
-- ky bang scratchpad/docsync.py.

-- ---------- HAI MUOI BOSS, moi canh gioi mot con ----------
--
-- Boss phai la HERO va KHONG BAY.
--
-- Quai thuong dung CFG.MOB_UNIT, ma coi 4 la Frost Wyrm -- BIET BAY,
-- va khong phai hero. Boss dung bang rieng nay.
--
-- Ma nao sai, biet bay, hoac khong phai hero thi startBoss() BAO RO
-- luc VAO MAP -- khong doi den canh gioi 16 moi phat hien.
--
-- 'mech' = danh sach co che. Moi co che mot ham trong 3_boss.lua; con so
-- di kem nam ngay trong bang nay de doc mot cho la thay het.
--
--   slam       don AoE quanh boss
--   lifesteal  hut lai % sat thuong gay ra
--   enrage     duoi nguong mau -> sat thuong x he so
--   shred      moi don danh TRU GIAP vinh vien cua muc tieu
--   summon     goi thuoc ha
--   charge     lao toi hero XA NHAT
--   shield     dinh ky tao khien hap thu
--   reflect    phan lai % sat thuong nhan vao
--
-- shred la co che tra loi cho mot loi do duoc: cuoi van hero co 8,070
-- giap, giam 99.79% sat thuong. Boss xe giap thi tran cang keo dai hero
-- cang de vo -- nguoc han nhip thong thuong.
--
-- Moi con mot file mo ta rieng: docs/02-he-thong/boss/NN-<slug>.md
-- 'aura': MOI con mot hao quang, tra bang CFG.BOSS_AURA.
--
-- HAI RANG BUOC CUA WARCRAFT, khong phai cua map:
--   Vampiric chi an voi don CAN CHIEN
--   Trueshot chi an voi don TAM XA
-- Gan nham thi aura IM LANG KHONG LAM GI -- khong loi, khong bao, va
-- boss chi yeu di mot cach kho hieu. spawn() do lai bang
-- IsUnitType(UNIT_TYPE_RANGED_ATTACKER) va GHI VET neu lech, nen bang
-- nay sai o dau se tu noi ra chu khong phai doi ai phat hien.
--
-- Vi the: 'vampiric' chi cho con danh gan (Hmkg Obla Otch Npbm),
-- 'trueshot' chi cho con danh xa (Hamg Emoo Hblm Nfir). Ba cai con lai
-- an voi ca hai nen rai tu do.
--
-- KHONG cho 'vampiric' len con da co co che lifesteal (r5 r11 r15 r17)
-- -- hai lop hut mau chong nhau thi lop thu hai khong doc ra duoc.
--
-- Bon con mot aura, chia deu 5 x 4 = 20.
CFG.BOSSES = {
  { r = 1,  vi = "Thi Giai Lao To",    en = "Corpse-Shed Elder",   unit = id('Hmkg'), aura = "vampiric",  mech = { "slam" } },
  { r = 2,  vi = "Dan Khi Chan Nhan",  en = "Qi-Gathering Adept",  unit = id('Hpal'), aura = "command",   mech = { "slam", "shield" } },
  { r = 3,  vi = "Truc Co Thach Linh", en = "Foundation Stonesoul",unit = id('Ucrl'), aura = "endurance", mech = { "slam", "reflect" } },
  { r = 4,  vi = "Kim Dan Ma Quan",    en = "Golden Core Warlord", unit = id('Obla'), aura = "vampiric",  mech = { "charge", "enrage" } },
  { r = 5,  vi = "Nguyen Anh Quy Mau", en = "Nascent Soul Matron", unit = id('Udre'), aura = "unholy",    mech = { "lifesteal", "summon" } },

  { r = 6,  vi = "Hoa Than Vo Tuong",  en = "Spirit-Sever Formless",unit = id('Ewar'), aura = "command",   mech = { "charge", "shred" } },
  { r = 7,  vi = "Luyen Hu Dao Nhan",  en = "Void-Refiner",        unit = id('Hamg'), aura = "trueshot",  mech = { "shield", "summon" } },
  { r = 8,  vi = "Hop The Cuong Ma",   en = "Body-Integration Fiend",unit = id('Otch'), aura = "vampiric",  mech = { "slam", "enrage" } },
  { r = 9,  vi = "Dai Thua Ton Gia",   en = "Great Ascension Arhat",unit = id('Ekee'), aura = "endurance", mech = { "summon", "reflect" } },
  { r = 10, vi = "Do Kiep Loi Chu",    en = "Tribulation Thunderlord",unit = id('Ofar'), aura = "unholy",    mech = { "slam", "charge", "enrage" } },

  { r = 11, vi = "Chan Tien Kiem Khach",en = "True Immortal Swordsman",unit = id('Edem'), aura = "unholy",    mech = { "charge", "lifesteal" } },
  { r = 12, vi = "Thien Tien Tinh Quan",en = "Heavenly Star Marshal",unit = id('Emoo'), aura = "trueshot",  mech = { "shield", "shred" } },
  { r = 13, vi = "Kim Tien Bat Hoai",  en = "Golden Immortal Adamant",unit = id('Hpal'), aura = "command",   mech = { "reflect", "shield" } },
  { r = 14, vi = "Thai At Cuu Chuyen", en = "Taiyi Ninefold",      unit = id('Ulic'), aura = "endurance", mech = { "summon", "slam" } },
  { r = 15, vi = "Dai La Thien Ma",    en = "Great Luo Demon",     unit = id('Udea'), aura = "unholy",    mech = { "lifesteal", "enrage", "shred" } },

  { r = 16, vi = "Tien De Kim Than",   en = "Immortal Emperor",    unit = id('Hblm'), aura = "trueshot",  mech = { "slam", "shield", "enrage" } },
  { r = 17, vi = "Thanh Nhan Vo Nga",  en = "Selfless Saint",      unit = id('Oshd'), aura = "endurance", mech = { "reflect", "lifesteal" } },
  { r = 18, vi = "Dao To Huyen Vi",    en = "Dao Ancestor",        unit = id('Nbrn'), aura = "command",   mech = { "shred", "summon", "charge" } },
  { r = 19, vi = "Hon Don Than Ma",    en = "Primordial God-Fiend", unit = id('Nfir'), aura = "trueshot",  mech = { "slam", "reflect", "enrage" } },
  { r = 20, vi = "Sang The Than",      en = "World Creator",       unit = id('Npbm'), aura = "vampiric",  mech = { "slam", "charge", "shred", "enrage" } },
}

-- Con so dung chung cho tung co che.
CFG.BOSS_MECH = {
  -- slam: cast giay -> vong tron hien ra, roi moi no. Xem chu thich dai
  -- o groundSlam() trong 3_boss.lua.
  --
  -- CAST VA RADIUS PHAI DI VOI NHAU. Chay thoat duoc hay khong la
  -- toc_do_hero x cast so voi radius. Hero dung ngay tam no thi phai
  -- vuot dung RADIUS trong CAST giay. Dong trace luc boss xuat hien in
  -- ra so DO DUOC, doi chieu o do chu dung tin con so o day.
  slam      = { cd =  9.0, cast = 2.0, radius = 600.0, factor = 10.0, marks = 16 },
  charge    = { cd = 11.0, factor = 3.0 },
  summon    = { cd = 20.0, count = 4 },
  shield    = { cd = 15.0, ratio = 0.12 },   -- khien = 12% mau toi da
  lifesteal = { ratio = 0.25 },
  reflect   = { ratio = 0.15 },
  shred     = { perHit = 0.02 },             -- tru 2% giap HIEN CO moi don
  enrage    = { at = 0.30, dmg = 1.60 },
}

-- ---------- Hao quang cua boss ----------
--
-- NAM ABILITY CO SAN CUA WARCRAFT, khong nhan ban. Ly do: ca nam deu
-- la PHAN TRAM, nen chung tu bam theo suc cua boss va khong bao gio
-- teo (ADR 0024). Do la truong hop hiem ma "de Warcraft giu so" la
-- dung -- xem CFG.SKILLS[H002] de doi chieu.
--
-- 'abils': DANH SACH UNG CU VIEN, do chu khong go.
--   UnitAddAbility tra FALSE khi ma sai, nen probeAura() thu lan luot
--   roi ghi vet cai nao trung. Chi 'AUav' 'AOae' 'AEar' la DA DUOC
--   DUNG THAT trong map nay (hut mau cua tu chinh, A003, A009); hai ma
--   con lai chua, nen chung co ban du phong.
--
-- 'need': loai don danh BAT BUOC de aura co tac dung.
--   Warcraft quy dinh, khong phai map: Vampiric chi an don can chien,
--   Trueshot chi an don tam xa. Gan nham thi aura im lang khong lam gi.
--   spawn() doi chieu voi IsUnitType(UNIT_TYPE_RANGED_ATTACKER) va ghi
--   vet neu lech.
--
-- 'desc': cau hien cho NGUOI CHOI luc boss xuat hien. Bo di thi hao
-- quang thanh mot con so vo hinh -- nguoi choi thua ma khong biet vi
-- sao, y het chuyen tu chinh truoc day.
CFG.BOSS_AURA = {
  endurance = { vi = "Kien Nhan", en = "Endurance Aura",
    abils = { 'AOae', 'Aaen' }, need = nil,
    desc_vi = "Boss danh va chay NHANH hon.",
    desc_en = "The boss attacks and moves faster." },

  vampiric  = { vi = "Hut Mau", en = "Vampiric Aura",
    abils = { 'AUav', 'ANvc', 'Avam' }, need = "melee",
    desc_vi = "Boss tu lanh khi danh trung -- phai ep ha nhanh.",
    desc_en = "The boss heals as it hits -- burn it down fast." },

  command   = { vi = "Thong Linh", en = "Command Aura",
    abils = { 'AOac', 'Acom', 'Acoa' }, need = nil,
    desc_vi = "Boss gay THEM sat thuong.",
    desc_en = "The boss deals extra damage." },

  unholy    = { vi = "Bat Tinh", en = "Unholy Aura",
    abils = { 'AUau', 'Auau', 'Aunh' }, need = nil,
    desc_vi = "Boss chay nhanh va tu hoi mau -- kho keo, kho bo chay.",
    desc_en = "The boss moves fast and regenerates -- hard to kite." },

  trueshot  = { vi = "Than Xa", en = "Trueshot Aura",
    abils = { 'AEar', 'Atru' }, need = "ranged",
    desc_vi = "Don tam xa cua boss manh hon.",
    desc_en = "The boss deals more ranged damage." },
}

-- Bac hao quang theo canh gioi. Aura goc cua Warcraft co 3 bac, va
-- chung la PHAN TRAM nen len bac la len ti le -- khong can ta tinh gi.
--
-- 20 canh gioi chia 3 khoang: 1-7 bac 1, 8-14 bac 2, 15-20 bac 3.
CFG.BOSS_AURA_MAX_LEVEL = 3

-- Bang cu, giu lai cho 3_boss.lua lui ve khi CFG.BOSSES thieu mot bac.
CFG.BOSS_UNIT = {
  id('Hmkg'), id('Obla'), id('Udre'), id('Ucrl'),
}

-- ---------- Theo so nguoi choi (ADR 0009) ----------
-- Phai < 1.0: bang 1.0 la phat nguoi choi vi ru duoc ban.
CFG.SCALE_EHP_PER_PLAYER      = 0.60
CFG.SCALE_DMG_PER_PLAYER      = 0.15   -- nho, vi sat thuong da tu loang
-- KHONG con dung: boss do suc manh that cua doi, ma phep do do da cong
-- dps cua TUNG hero roi. Nhan them theo so nguoi la dem hai lan.
-- (CFG.SCALE_BOSS_EHP_PER_PLAYER da bo.)
CFG.SCALE_RECOUNT_EACH_WAVE   = true

-- ---------- Mau linh: MOT MAU MOI CANH GIOI ----------
--
-- Tra theo CANH GIOI (1..20), khong phai theo coi. Ban truoc tra theo
-- coi nen suot 25 stage quai khong doi hinh mot lan nao -- doc khoang
-- trong nhin thay duoc lon nhat con lai cua he dot quai. Gio doi moi
-- 5 stage.
--
-- Bon coi, bon chung toc, do dan len:
--   1-5    Pham  Nguoi     linh thuong -> ky binh
--   6-10   Yeu   Orc       tho phi, to va on ao
--   11-15  Tien  Night Elf thanh thoat, danh xa
--   16-20  Than  Undead    va mot con Infernal khep lai
--
-- KHONG CON QUAI BAY. Ban truoc coi Than dung 'ufro' (Frost Wyrm) --
-- no BAY, va quai bay thi hero danh gan khong cham toi, duong di khong
-- theo dia hinh, va Chan Dia cua boss thanh vo nghia.
--
-- MA UNIT THI DO, KHONG TIN TRI NHO. probeMobUnits() luc vao map tao
-- thu tung con, kiem CreateUnit co tra ve nil khong VA kiem
-- IsUnitType(UNIT_TYPE_FLYING) -- roi xoa di. Go sai mot ma bon ky tu
-- la wave do khong sinh duoc con nao, va no im lang.
CFG.MOB_UNIT = {
  id('hfoo'),   -- 1  Pham Nhan      Footman
  id('hrif'),   -- 2  Luyen Khi      Rifleman
  id('hmpr'),   -- 3  Truc Co        Priest
  id('hsor'),   -- 4  Kim Dan        Sorceress
  id('hkni'),   -- 5  Nguyen Anh     Knight

  id('ogru'),   -- 6  Hoa Than       Grunt
  id('ohun'),   -- 7  Luyen Hu       Troll Headhunter
  id('orai'),   -- 8  Hop The        Raider
  id('okod'),   -- 9  Dai Thua       Kodo Beast
  id('ocat'),   -- 10 Do Kiep        Catapult

  id('earc'),   -- 11 Chan Tien      Archer
  id('esen'),   -- 12 Thien Tien     Huntress
  id('edry'),   -- 13 Kim Tien       Dryad
  id('edoc'),   -- 14 Thai At        Druid of the Claw
  id('emtg'),   -- 15 Dai La         Mountain Giant

  id('ugho'),   -- 16 Tien De        Ghoul
  id('ucry'),   -- 17 Thanh Nhan     Crypt Fiend
  id('unec'),   -- 18 Dao To         Necromancer
  id('uabo'),   -- 19 Hon Don        Abomination
  id('ninf'),   -- 20 Sang The       Infernal
}

-- Lui ve day khi CFG.MOB_UNIT thieu bac, hoac ma sai.
--
-- 'hfoo' vi no la ma DA CHAY THAT hang tram wave trong du an nay --
-- khong phai vi no hop chu de. Duong lui phai la thu chac chan chay,
-- khong phai thu dep.
CFG.MOB_UNIT_FALLBACK = id('hfoo')

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

-- ---------- NANG CAP NHA CHINH (the VI, tra bang VANG) ----------
--
-- VI SAO CO HE NAY. Hai ly do do duoc, khong phai cam tinh:
--
--   1. VANG gan nhu la dong tien chet. No chi mua duoc lo thuoc (10) va
--      Ankh (500). Trong khi Co Duyen mot minh da cho 185 vang o canh
--      gioi 1 va 27.016 o canh gioi 20. Tien don dong ma khong co cho
--      tieu la mot he thong khong lam gi ca.
--   2. Do ben cua nha chinh la MOT hang so duy nhat (HOUSE_HP_HITS) cho
--      ca van. Nguoi choi khong co mot cach nao can thiep.
--
-- MOT DUONG DUY NHAT, va no cong SUC MANH chu khong cong % mau.
--
-- Ban dau co ba duong (% mau / hoi moi wave / phan sat) -- da bo hai
-- duong sau va doi duong dau:
--
--   - "+12% mau toi da" moi cap nghe to ma cam giac khong thay gi: o
--     canh gioi 1 no la 288 mau tren 2.400, tuc 48 don linh. Suc Manh
--     thi ra mot con so NHIN THAY DUOC tren bang chi so cua nha.
--   - "Hoi Phuc" trung viec voi HOUSE_REGEN_PER_WAVE da co san.
--   - "Phan Sat" them mot trigger sat thuong toan cuc cho mot hieu ung
--     nho -- khong dang.
--
-- SO DIEM PHAI LEO THEO CANH GIOI. Day la ADR 0024: cong thi leo, nhan
-- thi phang. Mot con so diem PHANG se vo nghia o canh gioi 10 vi mau
-- nha luc do bam theo duong cong quai. Nhan voi CULT_STAT_STEP^(bac-1)
-- y het cach Trang Bi cong diem.
CFG.HOUSE_UP_MAX = 10

-- Gia cap n = PRICE0 x STEP^(n-1). Voi 80 va 1.25: cap 1 la 80, cap 10
-- la 596, tron duong la 2.660 vang.
--
-- HA GIA 2026-09-19, tu 300 x 1.45^n (tron duong 26.723). Ly do la mot
-- phep do, khong phai cam tinh:
--
--   Vang ca van MOT nguoi kiem duoc:  4.000 - 14.140
--     quai thuong  80 stage x 50 con x 1 vang   = 4.000
--     Co Duyen     169 luot x the vang 30-90    = 0 - 10.140
--     (tinh anh va boss KHONG cho vang)
--
-- Tuc gia cu doi gan 2 LAN tong thu nhap toi da: ke ca khi luot quay
-- nao cung chon vang va khong mua mot vien da nao thi van khong toi
-- noi cap 9 (cong don 18.223).
--
-- NANG HON: vang KHONG phai dong tien thua. No mua Da Huyen Thiet (10
-- vang/vien) o shop, ma tron bo Trang Bi an 4.000 vien = 40.000 vang --
-- gap 3 lan tong thu nhap. Vang la dong tien CHAT NHAT trong van.
--
-- Nen the VI phai la mot mon BAO HIEM nho, khong phai mot nhanh tien
-- trinh thu hai. 2.660 vang = 29% thu nhap thuc te, va bang 266 vien da
-- tuc 6,7% bo trang bi. Do la mot lua chon that ma khong cuop he chinh.
--
-- Cap 1 co y de RE (80 vang): phai mua duoc ngay canh gioi dau, luc nha
-- yeu nhat va nguoi choi chua co gi khac de tieu.
CFG.HOUSE_UP_PRICE0 = 80
CFG.HOUSE_UP_STEP   = 1.25

-- Bao nhieu mau mot diem Suc Manh. DO LUC VAO MAP tren chinh con nha
-- chinh (xem probeHpPerStr o 12_houseup.lua); con so nay chi la duong
-- lui khi do khong duoc, va luc do file vet se noi ro.
CFG.HOUSE_UP_STR_HP = 25.0

CFG.HOUSE_UP = {
  -- 'str' la diem Suc Manh moi cap, do o CANH GIOI 1. Cap 10 o canh
  -- gioi 1 = 400 diem = 10.000 mau, tren nen 2.400 -- tuc x5.
  { code = "fortify", vi = "Kien Co", en = "Fortify", str = 40,
    icon = [[ReplaceableTextures\CommandButtons\BTNHumanWatchTower.tga]],
    desc_vi = "Nha chinh +%s Suc Manh.",
    desc_en = "Main hall +%s Strength." },
}


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
-- nao bam theo thu nhap duoc nua. Do la ly do CULT_COST_STEP tut tu
-- 1.412 xuong 1.08.
CFG.REWARD_MOB_QI = 1
CFG.REWARD_MOB_GOLD    = 1
CFG.REWARD_ELITE_QI = 50
CFG.REWARD_BOSS_QI  = 100
-- 1, HA TU 2 -- 2026-09-20, di kem viec them the Go vao Co Duyen.
--
-- Do duoc: mot van co 168 luot quay. Them the Go 1 diem ma nguoi choi
-- luon chon thi nguon Go 261 -> 429, trong khi cho tieu chi 320 --
-- thua 109, va ca quyet dinh "mua 3 Phap Khi bo 1" bien mat.
--
-- Ha nguon tu dong xuong con mot nua thi Go THOI LA THU NHAP TU DONG,
-- thanh thu phai DANH DOI bang suc manh:
--   khong lay the Go lan nao   181  -- thieu 139, bo 2 Phap Khi
--   lay mot nua so luot        265  -- thieu 55, van bo 1
--   lay moi luot               349  -- du het, tra bang 168 the khac
CFG.REWARD_ELITE_LUMBER    = 1
CFG.REWARD_BOSS_LUMBER     = 5

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
CFG.SKILL_LUMBER_UNLOCK = 1    -- mo khoa mot ky nang
CFG.SKILL_LUMBER_UP     = 1    -- nang mot bac
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
--  CFG.SKILL_CARRY_BASE -- ghi so vao truong goc thay vi tat.)
--
-- CHUA tat duoc, van con cong chong:
--   A005 Chem Lan   -- "-nat spell" chua ra ten hang: ma goc ACce khop
--                      nham vao ABILITY_BLF_ACCEPTS_* ("ACCEPTS" chua
--                      "CCE"). Do lai bang "-nat cleav".
--   A006 Da Sat     -- ban sao cua Attribute Bonus va KHONG duoc zero
--                      trong war3map.w3a (A004 thi co, A006 thi khong).
--   A007 mau toi da -- khong thay hang so HAV2 trong ban nay.
CFG.SKILL_ZERO_BASE = {
  [id('A001')] = { "ABILITY_RLF_DAMAGE_OSH1", "ABILITY_RLF_MAXIMUM_DAMAGE_OSH2" },
  [id('A002')] = { "ABILITY_RLF_AMOUNT_HEALED_DAMAGED_HHB1" },
  [id('A007')] = { "ABILITY_RLF_DAMAGE_BONUS_HAV3",
                   "ABILITY_RLF_MAGIC_DAMAGE_REDUCTION_HAV4" },

  -- Hvwd -- DO BANG "-nat spell", 2026-09-19. File vet:
  --
  --   spell AOcl: ABILITY_RLF_DAMAGE_PER_TARGET_OCL1
  --   spell AHfa: ABILITY_RLF_DAMAGE_BONUS_HFA1
  --   spell ACr2: (chi ra ..._OCR2 -- KHOP GIA, xem duoi)
  --   spell AEar: (chi ra ..._RESEARCH_* -- KHOP GIA)
  --   spell Amgl: (khong co gi)
  --
  -- Truoc do toi SUY ten tu quy luat AOsh -> Osh1 -> ABILITY_RLF_<TEN>_OSH1
  -- va sai het: ghi "ABILITY_RLF_DAMAGE_OCL1" trong khi that la
  -- "..._DAMAGE_PER_TARGET_OCL1", va bia han "..._HIT_POINTS_GAINED_CR21".
  --
  -- HAI KHOP GIA suyt lua tiep. spells() trong 5_natives.lua bo chu cai
  -- dau roi tim CHUOI CON, nen:
  --   ACr2 -> "CR2" -> trung ..._OCR2, ma OCR2 la hau to cua AOcr
  --                    (Critical Strike), khong lien quan gi
  --   AEar -> "EAR" -> trung ..._RESEARCH_*, vi RESEARCH chua "EAR"
  -- Da sua spells() de tach khop MANH (ten ket thuc bang <hau to><so>)
  -- khoi khop YEU, nen lan sau no tu noi ra.
  --
  -- A011 TRUOC DAY KHONG CO DONG NAO O DAY -- do la thieu sot that, va
  -- la cai dat nhat trong ca dot: ABILITY_RLF_DAMAGE_BONUS_HFA1 chinh
  -- la con so PHANG cong vao moi mui ten, tuc dung thu ma ca thiet ke
  -- 'burn' dung ra de thay the.
  [id('A008')] = { "ABILITY_RLF_DAMAGE_PER_TARGET_OCL1" },
  [id('A011')] = { "ABILITY_RLF_DAMAGE_BONUS_HFA1" },
  -- A010 (ACr2) KHONG co hang so nao -- da do, khong phai chua tim.
  -- Nen lop hoi mau goc 6 giay van chay chong len fxHot(). No la so
  -- PHANG nen teo dan (ADR 0024): ro o wave dau, vo nghia tu canh gioi
  -- 5. Muon tat han thi phai lay MA TRUONG 4 ky tu cua truong "Data -
  -- Hit Points Gained" roi di qua ConvertAbilityRealLevelField -- cach
  -- lay: dat truong do mot gia tri bat ky trong World Editor, luu, roi
  -- "python w3obj.py dump" se in ra ma truong.
}

-- ---------- Truong goc dung lam VAT MANG ----------
--
-- Nguoc voi SKILL_ZERO_BASE: thay vi tat hieu ung goc roi tu cong bang
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
--   source = "armor"     -> armorAt(sk, lv), duong cong giap cua bang
--   source = "buffarmor" -> CFG.FX_BUFF_ARMOR theo bac
CFG.SKILL_CARRY_BASE = {
  -- A003 DA RA KHOI BANG NAY. No tung la Devotion Aura (AHad) va ta ghi
  -- so giap vao truong ARMOR_BONUS_HAD1. Gio no la Endurance Aura
  -- (AOae) -- truong do KHONG TON TAI tren ability nay, nen giu lai chi
  -- de BlzSetAbilityRealLevelField ghi vao hu vo, im lang.
  --
  -- Va do la y muon: bang so cua A003 gio do World Editor quyet dinh
  -- hoan toan. war3map.w3a la nguon su that duy nhat, khong con hai noi
  -- cung khai mot con so.
  [id('A007')] = { field = "ABILITY_RLF_DEFENSE_BONUS_HAV1", source = "buffarmor" },
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
CFG.SKILL_ZERO_BASE_INT = {
  [id('A004')] = { "ABILITY_ILF_STRENGTH_BONUS_ISTR",
                   "ABILITY_ILF_AGILITY_BONUS",
                   "ABILITY_ILF_INTELLIGENCE_BONUS" },
  -- A006 DA RA KHOI BANG NAY. No tung la Aamk (cong chi so) nen phai
  -- zero ba truong do di. Gio no la AOre -- Hoi Sinh -- khong co truong
  -- chi so nao de zero, va goi zeroField len chung chi ton mot vong lap
  -- ghi vao hu vo.
}

-- ---------- Mo khoa ky nang ----------
--
-- Hero vao map TAY KHONG -- command card chi co Move/Stop/Hold/Attack/
-- Patrol -- nhung cam san mot it Go (CFG.LUMBER_START).
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
--
-- 1 go -- 2026-09-19, ha tu 2. Hai go mo duoc HAI ky nang ngay giay
-- dau, ma the la mat mat quyet dinh dau tien cua van: "mo cai nao
-- truoc". Mot go thi phai chon THAT, va con lai phai di danh moi co.
CFG.LUMBER_START = 1

-- Vang cam san luc buoc qua cong ve nha.
--
-- Dat THANH 50 chu khong CONG 50: Warcraft phat vang khoi dau theo
-- war3map.w3i truoc khi mot dong Lua nao chay, va con so do khong doc
-- duoc tu day. Cong them thi tong se la "50 + mot con so khong ai
-- biet"; dat thanh thi dung 50 du w3i co dat gi.
--
-- 50 vang = 5 lo thuoc, hoac 5 hon Da Huyen Thiet, hoac 5 thap. Du de
-- mua MOT thu, khong du de mua ca ba -- lai la mot quyet dinh that.
CFG.GOLD_START = 50

-- ---------- Bay ky nang cua tung hero ----------
--
-- factor : sat thuong/hoi mau = factor x (CULT_DMG_BASE + chi so CAO NHAT
--        cua hero). An theo chi so cao nhat nen skill khong bao gio phe,
--        va bam dung duong cong Linh Can.
-- pct  : ky nang bi dong tinh theo PHAN TRAM. Cong thang mot luong co
--        dinh thi cuoi game vo nghia -- Linh Can cong +1075 moi chi so.
-- cd   : hoi chieu bac 1, giay.
--
-- Moi so o day la bac 1. Bac 2..10 suy ra tu SKILL_*_STEP o tren.
-- Cach ra he so 1.32 cua A001: docs/03-du-lieu/nang-cap-ky-nang.md
CFG.SKILLS = {}

-- 'fx' la LOAI HIEU UNG, do src/2_player/7_effect.lua doc.
--
-- Vi sao co o nay thay vi viet rieng cho tung ability: bay loai hieu ung
-- duoi day dung lai duoc cho Hvwd va Hkal. Them hero moi la khai bao
-- them dong, khong phai viet them code.
--
--   "line"   gay sat thuong tren mot duong thang truoc mat
--   "chain"  nay tu muc tieu sang muc tieu gan, moi lan yeu di
--   "heal"   hoi mau mot muc tieu
--   "buff"   tu tang giap + mau trong CFG.FX_BUFF_TIME giay
--   "cleave" bi dong: don danh van % sat thuong sang ben
--   "burn"   bi dong: don danh de lai mot lop dot keo dai
--   "reduce" bi dong: giam % sat thuong nhan vao (co tran cung)
--   "stat"   bi dong: +% ca ba chi so
--   "aura"   NHAN thuan tuy -- khong con ma Lua nao doc. Con so nam
--            trong chinh ability (A003 Hieu Lenh, A009 Than Xa), va
--            Warcraft tu cong. Giu lai vi bang phim R loc theo no.
CFG.SKILLS[id('H001')] = {
  -- Khong cai nao phat san (CFG.SKILL_START_COUNT = 0). Thu tu trong
  -- bang la thu tu hien o bang phim R, nen xep hai cai co ban len dau --
  -- Chem Lan don quai dong, Chuong don theo duong -- de diem Go
  -- dau tien roi vao tam mat truoc.
  -- 'goc' = ma ability GOC ma cai nay nhan ban tu do. Doc duoc tu
  -- war3map.w3a, nhung code luc chay khong thay -- ma no la thu can de
  -- tra ten hang so ABILITY_*LF_* cua tung skill ("-nat spell").
  { id = id('A005'), baseAbil = "ACce", vi = "Chem Lan", en = "Cleaving Blow",   kind = "passive",  pct = 0.20, fx = "cleave",
    desc_vi = "Don danh van %s sat thuong sang muc tieu ben canh.",
    desc_en = "Attacks splash %s damage to nearby targets." },
  -- 50 mana, khong phai 25: hero bac 1 co 75 mana nen 50 = mot phat roi
  -- phai cho hoi. (Con so 100 nhin thay trong game khong den tu day --
  -- do la mana goc cua Shockwave, lo ra vi nhanh MO KHOA quen goi
  -- applyLevel; da sua.)
  { id = id('A001'), baseAbil = "AOsh", vi = "Chuong", en = "Palm Strike",       kind = "active" , factor = 1.32, cd = 8.0, mana = 50, fx = "line", hotkey = "Q",
    desc_vi = "Gay %s sat thuong len mot duong thang.",
    desc_en = "Deals %s damage in a line." },

  -- Nam cai duoi mo sau, THU TU NAO CUNG DUOC: gia mo khoa phang nen
  -- nguoi choi chi phai chon thu tu, khong phai tinh toan.
  { id = id('A002'), baseAbil = "AHhb", vi = "Ho The", en = "Guarding Light",    kind = "active" , factor = 2.20, cd = 10.0, mana = 30, fx = "heal", hotkey = "W",
    desc_vi = "Hoi %s mau cho ban than hoac dong doi.",
    desc_en = "Heals %s to yourself or an ally." },
  -- 'giap' chu khong phai 'pct': Warcraft dung GIAP PHANG, khong phai
  -- phan tram. Giam sat thuong = giap x 0.06 / (1 + giap x 0.06), chinh
  -- la CFG.ARMOR_DR_PER_POINT ma he dot quai dang dung.
  --
  -- Ban cu la "+15% giap": tren mot hero co 3 giap thi do la +0.45 giap,
  -- tuc +2.6% mau hieu dung -- gan nhu bang khong. Gio +3 giap phang
  -- (bac 10: +6), tuong duong +18% -> +36% mau hieu dung.
  -- A003: doi tu Devotion Aura sang Endurance Aura (2026-09-19).
  --
  -- KHONG co 'armor' va KHONG co 'pct': moi con so cua no nam trong
  -- war3map.w3a, do World Editor dat. fromAbil noi cho fmt() biet phai
  -- DOC tu ability chu dung tu tinh -- xem 4_skill.lua.
  --
  -- Bang so hien tai co lo hong da biet va nguoi lam map chap nhan:
  -- toc danh thieu bac 6, toc chay thieu bac 1-3 va bac 8 (0.50) manh
  -- hon bac 9 (0.45). Bac de trong lay gia tri cua ability GOC, ma AOae
  -- goc chi co 3 bac -- nen bac 6 la vung khong xac dinh.
  { id = id('A003'), baseAbil = "AOae", vi = "Hieu Lenh", en = "Rallying Order", kind = "aura",
    fromAbil = "ABILITY_RLF_ATTACK_SPEED_INCREASE_OAE1",
    -- Ma truong de dung khi hang so tren vang mat (1.31.1 thieu that).
    --
    -- 'Oae2' chu KHONG phai 'Oae1': doi chieu Object Editor voi dump
    -- war3map.w3a, bac 8 toc danh = 0.50 va bac 8 toc chay = 0.40; file
    -- ghi Oae2=0.5, Oae1=0.4. Tooltip goc cung noi the -- DataA la toc
    -- chay, DataB la toc danh. Ten hang so cua Blizzard ("..._OAE1")
    -- dat nguoc, dung theo no la doc nham sang toc chay.
    fromField = "Oae2", fromPct = true, fx = "aura",
    desc_vi = "Ca doi duoc %s toc danh va toc chay.",
    desc_en = "The whole party gains %s attack and movement speed." },
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
  -- Gio: chiso x SKILL_PASSIVE_STEP^(bac skill-1) x CULT_STAT_STEP^(bac Tu Vi-1)
  -- Hai truc deu co nghia: bac skill doi x2 (tra Go thi thay duoc), bac
  -- Tu Vi giu no khong bi bo lai. Ti le so voi mot lan dot pha dung yen
  -- o 16% moi bac.
  --
  -- Dung CHINH CULT_STAT_STEP nhu he quay, nen doi duong cong Tu Vi
  -- thi ca ba he tu co theo.
  { id = id('A004'), baseAbil = "Aamk", vi = "Luyen The", en = "Body Forging",   kind = "passive",  statVal = 4.0, fx = "stat",
    desc_vi = "%s ca ba chi so, nhan them theo bac Tu Vi.",
    desc_en = "%s to all three attributes, scaled by Cultivation rank." },
  -- A006: doi tu Aamk (cong chi so) sang AOre -- Hoi Sinh (2026-09-19).
  --
  -- Bi dong thuan: Warcraft lo het, ta khong ghi mot truong nao. Con so
  -- duy nhat dang hien la HOI CHIEU, doc thang tu ability.
  --
  -- Bang so thieu bac 2 (270 -- ? -- 210 180 ...); nguoi lam map chap
  -- nhan, xem chu thich A003.
  { id = id('A006'), baseAbil = "AOre", vi = "Da Sat", en = "Ironhide",          kind = "passive",
    fromCooldown = true, fx = "reduce",
    desc_vi = "Chet thi tu song lai. Hoi chieu %s.",
    desc_en = "Revives you on death. Cooldown %s." },
  { id = id('A007'), baseAbil = "AHav", vi = "Bat Hoai", en = "Indestructible",  kind = "active" , factor = 0.0, cd = 60.0, mana = 60, fx = "buff", hotkey = "E",
    desc_vi = "Tang manh giap trong thoi gian ngan.",
    desc_en = "Greatly raises armor for a short time." },
}

-- ---------- Hvwd: xa thu ----------
--
-- BAY KY NANG, CHIA BA NHOM THEO "AI GIU CON SO" -- va do la phan quan
-- trong nhat cua bang nay, khong phai ban thanaso.
--
--   Lua giu so   A008 A010 A011   -> factor/pct, tu bam chi so hero
--   WE giu so    A006 A009        -> doc ra bang fromAbil/fromCooldown
--   Lua giu so   A012             -> xem chu thich ngay tren dong A012
--   ca hai       A004             -> statVal x bac skill x bac Tu Vi
--
-- Vi sao phai chia: mot con so PHANG dat trong Object Editor se teo
-- thanh khong ([ADR 0024] cong thi leo, nhan thi phang). Do duoc o canh
-- gioi 16: chi so that cua hero la 30.105. Mot cu "+40 sat thuong moi
-- mui ten" luc do la lam tron so. Nen chi nhung gi von la PHAN TRAM
-- (Trueshot, Moon Glaive) moi duoc phep de WE giu.
--
-- A004 va A006 DUNG CHUNG ID voi Hart, va hai dong do phai GIONG HET
-- ben H001: w3skill.py ghi ten/tooltip theo MA ABILITY chu khong theo
-- hero, nen hai ban khai khac nhau cho cung mot ma se de len nhau -- ai
-- chay sau thang, va khong ai thay gi sai luc build.
CFG.SKILLS[id('H002')] = {
  -- Hai cai dau la hai cai NEN, giong cach Hart xep Chem Lan + Chuong
  -- len dau: diem Go dau tien nen roi vao tam mat truoc.
  --
  -- 'kind = "passive"' nhung VAN co hotkey: ban goc AHfa la autocast,
  -- nen no co nut bat/tat that su tren command card. 'kind' o day chi
  -- la goi y cho fmt() biet hien pct hay factor -- xem 4_skill.lua.
  -- 'pos' ghi de cho tu dong chia o. Thu tu tu dong tra ra o (3,2) cho
  -- Thieu Thien va (2,2) cho Nguyet Nhan -- dung o nhung nguoc CHO.
  -- Bo cuc nut la chuyen cam giac, khong suy ra duoc tu bang, nen khai
  -- thang chu khong sap xep lai bang cho ra dung thu tu.
  { id = id('A011'), baseAbil = "AHfa", vi = "Thieu Thien", en = "Searing Arrows", kind = "passive", pct = 0.30, fx = "burn", hotkey = "E", pos = "2,2",
    desc_vi = "Mui ten thieu dot: them %s sat thuong cua don danh, rai deu trong 3 giay.",
    desc_en = "Arrows sear: %s of the hit as extra damage spread over 3 seconds." },
  -- He so 1.10 chu khong 1.32 nhu Chuong: cai nay cham toi BON muc
  -- tieu. Nhan ra la 4 x 1.10 = 4.40 so voi mot duong thang cua Chuong.
  { id = id('A008'), baseAbil = "AOcl", vi = "Loi Van", en = "Chain Lightning", kind = "active", factor = 1.10, cd = 9.0, mana = 45, fx = "chain", hotkey = "Q",
    desc_vi = "Tia set nay qua cac muc tieu gan, moi lan nhay yeu di. %s sat thuong.",
    desc_en = "Lightning arcs between nearby targets, weaker each hop. %s damage." },

  -- Nam cai duoi mo sau, THU TU NAO CUNG DUOC -- gia mo khoa phang.
  --
  -- 2.00 chu khong 2.20 nhu Ho The cua Hart: xa thu khong phai nguoi di
  -- hoi mau, va Hkal moi la ho tro that su.
  -- 'hot' chu KHONG 'heal'. Hai cai khac nhau that:
  --   heal  hoi MOT CUC ngay       (Ho The cua Hart)
  --   hot   rai deu trong 'adur'   (Hoi Xuan)
  --
  -- LOI DA SHIP: ban dau dung 'heal' cho tien, vi fxHeal() co san.
  -- Nguoi lam map dat 6 giay trong World Editor ma trong game no hoi
  -- tuc thi -- nhin ra nhu loi, va con so 6 giay thanh vo nghia.
  --
  -- 'durField' noi cho fxHot() biet DOC thoi luong o dau, chu khong
  -- khai thoi luong. Khai tuong minh du "adur" da la mac dinh: doc mot
  -- dong nay la biet ngay 6 giay den tu World Editor, khong phai di
  -- tim trong code.
  { id = id('A010'), baseAbil = "ACr2", vi = "Hoi Xuan", en = "Rejuvenation", kind = "active", factor = 2.00, cd = 12.0, mana = 40, fx = "hot", hotkey = "W", durField = "adur",
    desc_vi = "Hoi %s mau, rai deu trong thoi gian hieu luc.",
    desc_en = "Restores %s health, spread over the duration." },
  -- Trueshot Aura: WE giu so, va o day do la DUNG -- no von la PHAN
  -- TRAM sat thuong tam xa, nen tu bam theo hero, khong teo.
  --
  -- Y HET cach A003 lam. 'Ear1' suy tu quy luat cua A003 (ability AOae
  -- -> truong Oae1/Oae2), CHUA DO. Doc khong ra thi fromAbility() ghi
  -- vet va tooltip lui ve "bac N" -- khong bia so. Do lai bang
  -- "-nat spell" roi sua o day neu sai.
  { id = id('A009'), baseAbil = "AEar", vi = "Than Xa", en = "Trueshot Aura", kind = "aura",
    fromAbil = "ABILITY_RLF_DAMAGE_INCREASE_EAR1",
    fromField = "Ear1", fromPct = true, fx = "aura",
    desc_vi = "Ca doi duoc %s sat thuong danh xa.",
    desc_en = "The whole party gains %s ranged attack damage." },
  -- LOI DA SHIP, va no im lang tron ven: A012 tung KHONG co 'fx' va
  -- khong co con so nao, vi ta tin rang "Moon Glaive la co che cua
  -- engine, khong can mot dong Lua nao".
  --
  -- NO KHONG NAY. Do lai thi hai cho deu thieu:
  --   war3map.w3a  A012 khong co MOT truong du lieu nao -- so muc tieu
  --                va do hao thua ke tu Amgl goc (3 bac), trong khi ta
  --                da dat alev = 10
  --   war3map.w3u  H002 khong khai 'ua1w' -- kieu vu khi thua ke tu
  --                unit goc, ma Moon Glaive chi nay duoc khi vu khi la
  --                Missile (Bounce)
  --
  -- Bai hoc: "de engine lo" chi dung khi ability GOC da chay san tren
  -- unit do. Nhan ban no sang mot hero khac la mang theo ca mot chum
  -- dieu kien khong ai liet ke ra.
  --
  -- Gio tinh bang Lua, % cua DON DANH THAT -- y het cleave. Dat
  -- 'ua1w = mbounce' trong WE de lay lai hoat anh thi PHAI bo 'fx'
  -- o day, khong thi sat thuong nhan doi.
  { id = id('A012'), baseAbil = "Amgl", vi = "Nguyet Nhan", en = "Moon Glaive", kind = "passive", pct = 0.25, fx = "bounce", pos = "3,2",
    desc_vi = "Don danh nay sang 3 muc tieu ben canh, cu nay dau %s sat thuong roi yeu dan.",
    desc_en = "Attacks bounce to 3 nearby targets; the first bounce deals %s damage, then falls off." },
  { id = id('A004'), baseAbil = "Aamk", vi = "Luyen The", en = "Body Forging",   kind = "passive",  statVal = 4.0, fx = "stat",
    desc_vi = "%s ca ba chi so, nhan them theo bac Tu Vi.",
    desc_en = "%s to all three attributes, scaled by Cultivation rank." },
  { id = id('A006'), baseAbil = "AOre", vi = "Da Sat", en = "Ironhide",          kind = "passive",
    fromCooldown = true, fx = "reduce",
    desc_vi = "Chet thi tu song lai. Hoi chieu %s.",
    desc_en = "Revives you on death. Cooldown %s." },
}

-- ---------- Hkal: phap su / ho tro ----------
--
-- CHIA NHOM THEO "AI GIU CON SO", y het Hvwd:
--
--   Lua giu so   A013 A014        -> factor, tu bam chi so hero
--   WE giu so    A006 A015 A016   -> bang so trong war3map.w3a
--   ca hai       A004             -> statVal x bac skill x bac Tu Vi
--   Lua giu so   A012             -> 'bounce', % cua don danh that
--
-- A015 Hu Khong Khien de WE giu la DUNG: Mana Shield doi sat thuong
-- lay mana theo mot TI LE, va bo mana thi leo theo Tri Tue -- tuc suc
-- chiu cua khien tu leo. Ti le thi khong teo (ADR 0024).
--
-- A016 Linh Tuyen thi CHUA CHAC. Neu truong cua Brilliance Aura la
-- phan tram toc hoi mana thi no tu scale; neu la mot so mana/giay
-- PHANG thi no teo dan. Chua do duoc -- "-nat spell" se noi. Du sao
-- no cung la ky nang DAU VAN theo thiet ke: SKILL_MANA_STEP (x1.55
-- sau 10 bac) co y tang cham hon bo mana, nen cuoi van mana khong con
-- la rang buoc.
--
-- A012 Nguyet Nhan tren mot phap su la CHUA HOP LY -- chu du an biet
-- va chap nhan tam. Giu o day de bo bay cai du cho, doi mot ky nang
-- thu the thi thay mot dong.
--
-- A004 / A006 / A012 dung chung ability voi hero khac, nen ba dong do
-- phai GIONG HET ban goc: w3skill.py ghi ten/tooltip theo MA ABILITY
-- chu khong theo hero.
CFG.SKILLS[id('H003')] = {
  { id = id('A013'), baseAbil = "AUfn", vi = "Han Bang", en = "Frost Nova", kind = "active", factor = 1.20, cd = 8.0, mana = 55, fx = "nova", hotkey = "Q",
    desc_vi = "No mot vong bang quanh muc tieu, %s sat thuong len moi con trong vong.",
    desc_en = "Bursts a ring of frost around the target for %s damage to everything inside." },
  -- 1.80 chu khong 2.20 nhu Ho The: cai nay cham toi BA nguoi. Nhan ra
  -- la 1.80 x (1 + 0.75 + 0.5625) = 4.16 so voi mot muc tieu cua Hart.
  { id = id('A014'), baseAbil = "AOhw", vi = "Cam Lo", en = "Healing Wave", kind = "active", factor = 1.80, cd = 10.0, mana = 45, fx = "wave", hotkey = "W",
    desc_vi = "Hoi %s mau, nay qua dong doi va yeu dan. Uu tien nguoi thieu mau nhat.",
    desc_en = "Restores %s health, bouncing to allies and weakening. Picks the most wounded first." },

  -- KHONG khai 'mana' lan 'cd': ca hai do World Editor dat, va
  -- applyLevel() chi ghi de khi bang nay co khai. Mana Shield tinh
  -- mana theo TUNG DON an vao, khong phai mot lan bam.
  { id = id('A015'), baseAbil = "ACmf", vi = "Linh Khien", en = "Mana Shield", kind = "active", noNumber = true, hotkey = "E",
    desc_vi = "Bat len thi sat thuong tru vao mana thay vi mau.",
    desc_en = "While active, damage drains mana instead of health." },
  -- Y HET cach A003 va A009 lam. 'Hab1' suy tu quy luat, CHUA DO. Doc
  -- khong ra thi fromAbility() ghi vet va tooltip lui ve "bac N".
  { id = id('A016'), baseAbil = "AHab", vi = "Linh Tuyen", en = "Brilliance Aura", kind = "aura",
    fromAbil = "ABILITY_RLF_MANA_REGENERATION_INCREASE_HAB1",
    fromField = "Hab1", fromPct = true, fx = "aura",
    desc_vi = "Ca doi hoi mana nhanh hon %s.",
    desc_en = "The whole party regenerates mana %s faster." },
  { id = id('A012'), baseAbil = "Amgl", vi = "Nguyet Nhan", en = "Moon Glaive", kind = "passive", pct = 0.25, fx = "bounce", pos = "3,2",
    desc_vi = "Don danh nay sang 3 muc tieu ben canh, cu nay dau %s sat thuong roi yeu dan.",
    desc_en = "Attacks bounce to 3 nearby targets; the first bounce deals %s damage, then falls off." },
  { id = id('A004'), baseAbil = "Aamk", vi = "Luyen The", en = "Body Forging",   kind = "passive",  statVal = 4.0, fx = "stat",
    desc_vi = "%s ca ba chi so, nhan them theo bac Tu Vi.",
    desc_en = "%s to all three attributes, scaled by Cultivation rank." },
  { id = id('A006'), baseAbil = "AOre", vi = "Da Sat", en = "Ironhide",          kind = "passive",
    fromCooldown = true, fx = "reduce",
    desc_vi = "Chet thi tu song lai. Hoi chieu %s.",
    desc_en = "Revives you on death. Cooldown %s." },
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
-- Nen 7_effect.lua bat su kien cast va TU gay sat thuong bang
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

-- ---------- "chain": set dien lan (A008, Hvwd) ----------
--
-- Warcraft CO san co che nay trong Chain Lightning, nhung con so cua no
-- la sat thuong PHANG tu Object Editor -- tuc teo dan theo ADR 0024.
-- Nen ta muon cai VO (icon, hoi chieu, mana, tam) va tu tinh sat thuong
-- bang skillDamage() nhu moi ky nang khac.
CFG.FX_CHAIN_MAX     = 4       -- so muc tieu, ke ca muc tieu dau
CFG.FX_CHAIN_HOP     = 400.0   -- tam nhay toi da giua hai muc tieu
CFG.FX_CHAIN_FALLOFF = 0.80    -- moi lan nhay con bay nhieu phan

-- ---------- "bounce": don danh nay sang ben (A012) ----------
--
-- LAM BANG LUA chu khong de engine lo. A012 tung la ban sao Moon
-- Glaive khong co dong Lua nao, va NO KHONG NAY. Do lai thay hai cho
-- deu thieu: war3map.w3a khong co truong du lieu nao cho A012, va
-- war3map.w3u khong khai 'ua1w' cho H002 -- ma Moon Glaive chi nay
-- duoc khi vu khi cua unit la Missile (Bounce).
--
-- Neu mai nay dat 'ua1w = mbounce' trong World Editor de lay lai hoat
-- anh glaive bay vong, PHAI bo 'fx = "bounce"' khoi A012 -- de ca hai
-- la sat thuong nhan doi.
CFG.FX_BOUNCE_MAX     = 3       -- so lan nay, KHONG ke muc tieu dau
CFG.FX_BOUNCE_HOP     = 350.0   -- tam nhay giua hai muc tieu
CFG.FX_BOUNCE_FALLOFF = 0.70    -- moi lan nay con bay nhieu phan

-- HA TU 0.45 XUONG 0.25 -- 2026-09-20, sau khi DO trong tran that.
--
-- File vet: "bounce: pid 0 co Nguyet Nhan bac 10, 90% moi cu nay".
-- Bac 10 nhan SKILL_PASSIVE_STEP^9 = x2, nen 0.45 thanh 0.90. Ba cu
-- nay voi FALLOFF 0.70 la 90 + 63 + 44 = +197% sat thuong -- gan gap
-- BA don danh.
--
-- Doi chieu: Chem Lan cua Hart o bac 10 la 40%. Nguyet Nhan vang vao
-- dung 3 con con Chem Lan vang ca dam, nen manh hon moi muc tieu la
-- hop ly -- gap ba thi khong.
--
-- 0.25 -> bac 10 la 50%, ba cu = 50 + 35 + 24 = +109%. Van la ky nang
-- manh nhat cua xa thu, nhung khong con nuot ca bang so.

-- ---------- "nova": no mot vong quanh muc tieu (A013, Hkal) ----------
CFG.FX_NOVA_AOE = 300.0

-- ---------- "wave": hoi mau nay qua dong doi (A014, Hkal) ----------
--
-- CHON NGUOI THIEU MAU NHAT chu khong phai gan nhat -- xem fxWave().
-- Hoi mau nay sang mot nguoi day mau la vut di mot nhip, ma so nhip
-- thi co han. Sat thuong thi nguoc lai: muc tieu nao cung an du.
CFG.FX_WAVE_MAX      = 3       -- so nguoi duoc hoi, ke ca nguoi dau
CFG.FX_WAVE_HOP      = 500.0   -- tam nhay toi da giua hai nguoi
CFG.FX_WAVE_FALLOFF  = 0.75    -- moi lan nhay con bay nhieu phan

-- ---------- "burn": thieu dot (A011, Hvwd) ----------
--
-- Vi sao KHONG dung "% mau toi da cua muc tieu" nhu ban thao dau: mau
-- moi thu trong map nay DINH NGHIA theo DPS nguoi choi (ADR 0020, va
-- armStats() trong 4_sidequest.lua dat mau Thanh Thu = dps x seconds).
-- Nen "% mau dich" that ra la "% TRAN DAU": 1% se thanh dung 100 mui
-- ten giet moi thu, va con so 'seconds' 45/85/150/240 -- ca cai num
-- chinh do kho cua Thanh Thu -- bien mat khoi phuong trinh.
--
-- Do lai con te hon: cung 100 mui do voi Chu Tuoc (thiet ke 45 giay) la
-- CHAM hon danh thuong, con voi Thanh Long (240 giay) la nhanh gap 3,6
-- lan. Cang ve cuoi map cang vo.
--
-- Nen burn tinh theo % DON DANH THAT, y het "cleave": no tu bam theo
-- moi thu hero co, va khong bao gio cham vao num do kho cua boss.
CFG.FX_BURN_TIME = 3.0     -- giay chay mot lan dot
CFG.FX_BURN_TICK = 0.5     -- giay giua hai nhip dot
-- Danh lai TRONG luc dang chay thi LAM MOI, khong cong don. Cong don
-- thi toc danh tu nhan voi chinh no -- hero cuoi van danh rat nhanh se
-- co hang chuc lop dot chong len nhau.
CFG.FX_BURN_STACK = false

-- ---------- "hot": hoi mau keo dai (A010, Hvwd) ----------
--
-- DUONG LUI, khong phai nguon su that. Thoi luong that lay tu CHINH
-- ability -- truong 'adur' trong war3map.w3a, hien la 6.0 va do World
-- Editor dat. Khai mot con so co dinh o day roi dung no la hai noi
-- cung khai mot thu, va mot ngay se chi sua mot noi.
--
-- Chi dung khi doc khong ra, va luc do fxHot() ghi vet mot lan.
CFG.FX_HOT_TIME = 6.0

-- ---------- Nut bat/tat cua Thieu Thien (A011) ----------
--
-- { ma lenh BAT, ma lenh TAT }. nil = tu do theo ten lenh.
--
-- VI SAO CO KHOA NAY: do theo TEN khong dang tin. OrderId() tra khac 0
-- chi chung minh "ten nay la mot lenh co that", KHONG chung minh "no la
-- lenh cua ability nay". Ban dau danh sach do co "blackarrow" va no
-- trung -- file vet ghi 852577/852579 -- nhung do la lenh cua Black
-- Arrow, mot ability khac han. Nut E khong bao gio phat lenh do.
--
-- Cung lop loi voi AddWeatherEffect nhan ma rac.
--
-- CACH LAY SO THAT: vao game, bam E mot cai, doc dong
--   order: pid 0 phat lenh 852xxx
-- trong DarknessTrace.txt (bam hai lan duoc ca so bat lan so tat), roi
-- ghi thang vao day. Do, khong doan.
CFG.BURN_ORDER = nil

-- HAI DUONG DAN NAY LA DUONG DA CHUNG MINH, khong phai duong dep nhat.
--
-- Ca hai dang muon lai model cua "line"/"cleave". Trong khong dung lam:
-- mot cu set dien ma no ra song xung kich. Nhung mot duong dan SAI thi
-- khong ve ra gi VA VAN "thanh cong" -- AddSpecialEffect tra ve handle
-- nhu thuong, y het AddWeatherEffect voi ma rac. Khong co cach nao kiem
-- tu ngoai; chi vao game NHIN moi biet.
--
-- Muon doi sang model dung nghia thi thu trong game roi hay ghi vao
-- day. Vai ung cu vien (CHUA DO):
--   Abilities\Spells\Orc\LightningBolt\LightningBoltMissile.mdl
--   Abilities\Spells\Other\Incinerate\FireLordDeathExplode.mdl
--
-- Rieng A008 con co art RIENG cua Chain Lightning goc chay len -- ban
-- sao AOcl van ve tia set cua no du ta da zero sat thuong. Nen
-- FX_HIT_CHAIN chi la DAU CHAM tren tung muc tieu Lua that su danh,
-- huu ich de thay Lua va Warcraft co chon cung bay con hay khong.
CFG.FX_HIT_BURN  = [[Abilities\Weapons\WitchDoctorMissile\WitchDoctorMissile.mdl]]
CFG.FX_HIT_CHAIN = [[Abilities\Spells\Orc\Shockwave\ShockwaveMissile.mdl]]
CFG.FX_HIT_NOVA  = [[Abilities\Spells\Orc\Shockwave\ShockwaveMissile.mdl]]
CFG.FX_HIT_BOUNCE = [[Abilities\Weapons\WitchDoctorMissile\WitchDoctorMissile.mdl]]
-- (CFG.FX_BUFF_TIME da xoa 2026-09-19: khong file nao doc. Thoi
--  luong buff lay tu truong 'adur'/'ahdu' cua chinh ability --
--  xem chu thich o 7_effect.lua.)
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

-- Vong tron bao truoc cua Chan Dia, va cai no ra o tam.
--
-- Hai duong dan nay la duong DA CHUNG MINH la ve ra hinh (dang dung o
-- ngay tren). Duong dan model KHONG liet ke duoc tu ngoai -- game dong
-- goi bang CASC -- va go sai thi WC3 im lang khong ve gi, khong bao
-- loi. Nen tha xau ma chac con hon dep ma trang.
-- ---------- Luyen Trang Bi: nhay ngay tren O ----------
--
-- KHONG ve hieu ung o con hero. Luc bam FORGE mat nguoi choi dang o
-- BANG, ma con hero thi dang bi chinh cai bang che khuat -- ve o do la
-- ve vao cho khong ai nhin.
--
-- Nen phan hoi nam tren dung cai o vua bam: mot lop mau phu len icon,
-- nhay may nhip roi tat.
--
-- BA muc, vi ba ket qua khac nhau ve GIA TRI chu khong chi ve mau:
--   OK    len mot cap -- chuyen thuong, ~15 lan moi canh gioi
--   BIG   cham cap cuoi, mo duong Tien Hoa len canh gioi sau -- dang khoe
--   FAIL  dot da ma khong duoc gi
--
-- MAU: cung thu muc, cung cach danh so voi TeamColor04 va TeamColor27 --
-- hai duong DA CHUNG MINH ve ra hinh trong du an nay. Bang TeamColor
-- danh so lien tuc 00..27 nen 00 (do) va 06 (xanh la) gan nhu chac
-- chan co that. Neu vao game thay KHONG nhay mau gi: doi ca hai ve
-- CFG.PANEL_BTN_EDGE, luc do mat mau nhung van con nhip nhay.
CFG.PANEL_FLASH_OK   = [[ReplaceableTextures\TeamColor\TeamColor06]]
CFG.PANEL_FLASH_FAIL = [[ReplaceableTextures\TeamColor\TeamColor00]]

-- Nhay may nhip, moi nhip bao lau. Mot nhip thi chop mot cai la xong,
-- khong phan biet duoc -- cung bai hoc voi vong tron bao truoc cua
-- Chan Dia. FAIL nhay nhieu nhip hon OK: truot thi phai thay ro.
CFG.PANEL_FLASH_OK_PULSES   = 1
CFG.PANEL_FLASH_BIG_PULSES  = 3
CFG.PANEL_FLASH_FAIL_PULSES = 2
CFG.PANEL_FLASH_STEP        = 0.16   -- giay moi nhip (hien roi tat)

CFG.FX_SLAM_MARK  = [[Abilities\Spells\Human\Avatar\AvatarCaster.mdl]]
CFG.FX_SLAM_HIT   = [[Abilities\Spells\Orc\Shockwave\ShockwaveMissile.mdl]]

CFG.OP_SKILL_UP = 6   -- arg = so thu tu ky nang trong CFG.SKILLS cua hero

-- Bat khi cac hieu ung da duoc viet that. Con false thi bang phim E noi
-- ro con so dang hien la thiet ke chu chua co hieu luc -- bang ma hien
-- so dep nhung sai thi te hon la khong hien.
--
-- Bat tu 2026-09-16: src/2_player/7_effect.lua tu gay sat thuong
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
--  docs/02-he-thong/kinh-te.md | bang-nhan-vat.md
--
--  Nguon suc manh CHINH: EHP quai dinh nghia bang chinh he so cua no
--  (CFG.MOB_EHP_FOLLOW_CULT), nen mot minh no du bam quai.
--  Dung chung thang ten voi 20 canh gioi cua phe dich -- nguoi choi va
--  ke dich tu tien tren cung mot con duong.
-- ============================================================

-- KHOA CFG.CULT_STEP DA BO (2026-09-17), cung voi ca cach nghi
-- "ngan sach x967". Ghi lai vi day la thay doi de bi lat nguoc:
--
--   Ban cu: bon he nhan nhau phai ra x967, va x967 do la duong cong
--   EHP cua quai -- hai ve dung rieng nen phai deo nhau bang tay.
--
--   Ban nay: CFG.MOB_EHP_FOLLOW_CULT = true. EHP quai DINH NGHIA
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
CFG.CULT_STAT_GAIN = 50.0   -- cong them o lan dot pha DAU TIEN
CFG.CULT_STAT_STEP = 1.30   -- moi lan sau x1.30 lan truoc

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
CFG.CULT_COST_BASE = 500.0
CFG.CULT_COST_STEP = 1.0

-- Hai so de GIAI NGUOC ra chi so can dat.
--
-- Nhan thang chi so len x1.17 moi bac la SAI: sat thuong hero =
-- sat thuong nen + chi so chinh, phan nen lam loang nhan so. Do thang
-- chi so x19.7 chi cho x10.4 sat thuong -- thieu mot nua.
--
--   stat(r) = (DMG_BASE + STAT_BASE) x STEP^(r-1) - DMG_BASE
--
-- Doi hai so nay cho khop hero that trong Object Editor thi nhan so moi
-- dung. Bang "-lc" trong game in ra nhan so THUC DO duoc de doi chieu.
CFG.CULT_DMG_BASE  = 17.0   -- sat thuong hero khi chi so = 0
CFG.CULT_STAT_BASE = 10.0   -- chi so hero luc bac 1

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
CFG.CULT_STAT_MODE = "all"


-- ============================================================
--  TRANG BI  --  6 mon, moi mon tien hoa 100 bac
--  docs/02-he-thong/trang-bi-kiem.md  |  ADR 0021
--
--  Moi mon di 20 canh gioi x 5 cap. TRAN la TU VI cua nguoi choi:
--  mon do khong bao gio vuot qua canh gioi ma nguoi choi dang o.
--
--  VI SAO CO TRAN. Sau ADR 0020, EHP quai dinh nghia bang he so Tu Vi
--  nen Tu Vi triet tieu voi quai, va MOI nguon khac la phan VUOT LEN
--  khong co can tren. He 6 o cu cong x8.3 sat thuong ma khong gi chan
--  -- do la ly do no phai khoa. Khoa theo canh gioi cho phan vuot len
--  mot can tren, va can do bam DUNG bien ma quai cung bam.
--
--  CHI SO CON RONG -- 2026-09-17. Khung tien hoa chay day du (ten, cap,
--  xac suat, Tien Giai, tran Tu Vi) nhung chua mon nao cong gi ca. Do
--  la CO Y: chu du an mo cau truc truoc, chot chi so sau.
-- ============================================================

-- Sau mon. Ten va icon la thu duy nhat phan biet chung luc nay.
--
-- ICON: chi dung sau duong dan DA CHUNG MINH ve ra hinh -- doan mot
-- duong dan sai thi ra o XANH LA (loi ma BTNRingViolet da dinh), ma
-- game dong goi bang CASC nen khong liet ke duoc tu ngoai.
--
-- KHIEN dang muon tam icon Talisman vi trong sau duong dan da chung
-- minh khong co cai nao la khien. Sua trong World Editor -> Object
-- Editor -> mot item bat ky -> Art - Icon, chep duong dan that vao day.
-- MOI MON MOT VAI. 'role' la thu code doc de biet cong gi:
--
--   "str" "agi" "int"  cong diem chi so, qua heroRecompute. LEO theo
--                      CULT_STAT_STEP -- xem CFG.GEAR_STAT_BASE.
--   "all"              chia deu ca ba, tong bang mot mon don chi so.
--   "dmgpct"           % sat thuong GAY RA -- don thuong, phep, va hoi mau.
--   "mitig_phys"       % sat thuong DON DANH nhan vao duoc giam.
--   "mitig_magic"      % sat thuong PHEP nhan vao duoc giam.
--
-- BA VAI CUOI KHONG LEO, va do khong phai thieu sot -- xem chu thich
-- CFG.GEAR_STAT_BASE ("cong thi leo, nhan thi phang").
--
-- ICON: chi dung duong dan DA CHUNG MINH ve ra hinh. Mu dang muon icon
-- BTNStaffOfSanctuary vi trong so duong da chung minh khong co cai nao
-- la mu; Khien muon Talisman, cung ly do. Doi sang icon dung nghia thi
-- phai lay duong dan THAT tu Object Editor truoc -- doan la ra o xanh la.
--
-- Thu tu bang nay la thu tu hien tren the. Doi thu tu khong sao (hai ben
-- kenh dong bo doc chung mot bang), nhung doi thi doi mot lan.
-- 'icon' la duong LUI, 'probe' la cach lay duong THAT.
--
-- Duong dan texture khong liet ke duoc tu ngoai (game dong goi bang
-- CASC), nen go tay la doan -- va du an nay doan sai ba lan lien
-- (BTNRingViolet, BTNStrength, BTNGoldmine), lan nao cung ra o xanh la.
--
-- Item cua game thi DOC duoc: CreateItem roi BlzGetItemIconPath tra ve
-- duong dan that. probe = danh sach ma item de thu, thu lan luot, cai
-- dau tien ra icon thi lay.
--
-- MA TRONG 'probe' CHUA DUOC XAC MINH -- chung la phong doan co hoc.
-- File vet ghi ro cai nao trung cai nao truot:
--     gear: Mu <- ciri (icon ...)      = trung
--     gear: Mu GIU DUONG LUI           = truot het, van dung 'icon'
-- Truot thi dung lenh "-icon <ma>" trong game de tim ma khac roi bo
-- vao day. Truot cung khong hong gi: duong lui deu la duong DA CHUNG
-- MINH ve ra hinh.
CFG.GEAR = {
  { key = "helm", vi = "Mu",         en = "Helm",     role = "int",
    probe = { "ciri", "hval", "hlst", "hbth" },
    icon = [[ReplaceableTextures\CommandButtons\BTNStaffOfSanctuary.blp]] },
  { key = "necklace", vi = "Day Chuyen", en = "Necklace", role = "all",
    probe = { "nspi", "pnec" },
    icon = [[ReplaceableTextures\CommandButtons\BTNPendantOfEnergy.blp]] },
  { key = "armor", vi = "Ao Giap",    en = "Armor",    role = "str",
    probe = { "brac", "bgst" },
    icon = [[ReplaceableTextures\CommandButtons\BTNSteelArmor.blp]] },
  { key = "sword", vi = "Kiem",       en = "Sword",    role = "dmgpct",
    probe = { "cnob", "rat9" },
    icon = [[ReplaceableTextures\CommandButtons\BTNSteelMelee.blp]] },
  { key = "shield", vi = "Khien",      en = "Shield",   role = "mitig_phys",
    probe = { "shar", "shtm" },
    icon = [[ReplaceableTextures\CommandButtons\BTNTalisman.blp]] },
  { key = "cloak", vi = "Ao Choang",  en = "Cloak",    role = "mitig_magic",
    probe = { "rde1", "rde2", "ring" },
    icon = [[ReplaceableTextures\CommandButtons\BTNRingSkull.blp]] },
  { key = "boots", vi = "Giay",       en = "Boots",    role = "agi",
    probe = { "bspd", "bgst" },
    icon = [[ReplaceableTextures\CommandButtons\BTNBootsOfSpeed.blp]] },
  { key = "ring", vi = "Nhan",       en = "Ring",     role = "lifesteal",
    probe = { "rde1", "rde2", "ciri" },
    icon = [[ReplaceableTextures\CommandButtons\BTNRingSkull.blp]] },
}

-- Nam cap trong MOT canh gioi. So phan tu PHAI bang #CFG.GEAR_ODDS.
-- Cung hinh dang voi CFG.TIER_NAMES cua he dot quai.
CFG.GEAR_CAP = {
  { vi = "So Cap",     en = "Basic" },
  { vi = "Trung Cap",  en = "Fine" },
  { vi = "Cao Cap",    en = "Superior" },
  { vi = "Thuong Cap", en = "Exalted" },
  { vi = "Hoan Hao",   en = "Perfect" },
}

-- Xac suat LEN cap thu i. XS[1] la lan dau (mo khoa mon do), luon 100%.
--
-- Ky vong so lan thu de di tron mot canh gioi:
--   1 + 1/0.75 + 1/0.50 + 1/0.25 + 1/0.15 = 15.0 lan
--
-- That bai KHONG mat gi ngoai vien da -- khong tut cap, khong vo mon.
CFG.GEAR_ODDS = { 1.00, 0.75, 0.50, 0.25, 0.15 }

-- Da moi lan thu nang cap. Phang, moi bac nhu nhau.
CFG.GEAR_PRICE = 1

-- ---------- Tien Giai ----------
--
-- Den "Hoan Hao" roi thi khong nang cap duoc nua; phai TIEN GIAI de
-- sang canh gioi sau. Ton 10 da, va CHAC CHAN 100% -- no la mot CUA,
-- khong phai mot canh bac chong len canh bac.
--
-- Tien Giai dua thang toi "So Cap" cua canh gioi moi: goi luon lan len
-- So Cap (von 100%) vao day, de khong co mot cu bam chac chan thua.
--
-- DIEU KIEN: Tu Vi cua nguoi choi phai DA toi canh gioi dich. Day la
-- cho cai tran that su co hieu luc.
CFG.GEAR_DISMANTLE = 10

-- Trang Bi khong con khoa. (CFG.GEAR_LOCKED, _MAX_LEVEL, _PCT,
-- _COST_BASE, _COST_STEP cua he 6 o x 10 cap da bo cung he do.)

-- ---------- Bo cuc o trang bi (kieu hinh nhan) ----------
--
-- { cot, dong } cho tung mon, THEO DUNG THU TU CFG.GEAR o tren.
-- Cot 1 va 3 la hai ben nguoi; cot 2 de trong cho hinh bong o giua.
--
--        cot1        cot2         cot3
--   d1   Mu        (hinh bong)   Day Chuyen
--   d2   Ao          "           Khien
--   d3   Kiem        "           Ao Choang
--   d4              Giay
--
-- Doi cho hai mon thi doi o day, khong phai sua 1_panel.lua -- bang chi
-- doc bang nay va dem ra so cot/dong lon nhat de biet phai chua bao lon.
-- Vi tri { cot, dong } cua tung o. THU TU PHAI KHOP CFG.GEAR o tren --
-- bang o va bang mon ghep voi nhau bang so thu tu, khong bang ten.
--
-- BO CUC PAPER-DOLL: ba cot, cot giua la NGUOI, tam mon vay hai ben.
--
--        c1          c2             c3
--   h1  Mu      +-----------+  DayChuyen      dau       | co
--   h2  AoGiap  |  ly lich  |  AoChoang       than truoc| than sau
--   h3  Kiem    |   hero    |  Khien          tay phai  | tay trai
--   h4  Nhan    |  <Pet>    |  Giay           ngon tay  | ban | chan
--
-- MOI HANG MOT CAP CO NGHIA, doi xung qua than nguoi. Hang 3 dat nhat:
-- Kiem voi Khien nam dung hai tay, khong phai xep cho du cho.
--
-- VI SAO BA COT chu khong phai nen luoi cho day: cot giua CO LY DO ton
-- tai (ly lich nhan vat), nen no khong phai lo hong. Bo cot giua di thi
-- tam mon con lai chi la mot danh sach hai cot -- doc ra thu tu, khong
-- doc ra co the.
CFG.GEAR_SLOTS = {
  { 1, 1 },   -- Mu
  { 3, 1 },   -- Day Chuyen
  { 1, 2 },   -- Ao Giap
  { 1, 3 },   -- Kiem
  { 3, 3 },   -- Khien
  { 3, 2 },   -- Ao Choang
  { 3, 4 },   -- Giay
  { 1, 4 },   -- Nhan

  -- HANG 5: hai o KHONG phai trang bi.
  --
  -- Di qua dung may moc o luoi san co (icon + nhan + nut) thay vi ve
  -- khung rieng -- them mot loai o moi la them mot cho co the lech
  -- hang voi tam o kia.
  --
  -- Chi so 9 va 10 KHONG tra vao CFG.GEAR. tabItems() cua 5_gear.lua
  -- noi them hai muc o cuoi, va tabItemAction() dinh tuyen chung sang
  -- op khac. Xem chu thich o do.
  { 1, 5 },   -- CANH      (doi bo dang deo)
  { 3, 5 },   -- THANH THU (doi con di theo)
}

-- O Pet: CHO DANH SAN, chua co he nao dung toi.
--
-- nil = khong ve o nay. Dat { cot, dong } thi luoi chua mot o vien co
-- chu mo, khong nut -- de nguoi choi biet cho do se co thu gi, chu
-- khong phai mot lo hong giua bang.
-- O TICK "luyen gop / luyen le" ngoi o khe NUT cua o Pet -- Pet la o
-- duy nhat khong co nut nen cho do dang trong. Dat o COT GIUA vi no chi
-- phoi ca tam nut hai ben: mot cai dieu khien tat ca thi phai ngoi giua
-- chung, khong phai nep ra ria.
-- ---------- PET ----------
--
-- BAN DAU: thuan trang tri, di theo hero. Khong danh, khong an don,
-- khong cong chi so. O Pet trong the Trang Bi da de san tu truoc.
--
-- unit = Hmkg (Mountain King). Chon no vi day la id DA CHUNG MINH ve ra
-- hinh: probe() cua 3_boss.lua tao thu ca 20 unit boss moi lan vao map,
-- va Hmkg la boss canh gioi 1. Khong phai doan.
--
-- Hmkg la unit HERO, nen phai SuspendHeroXP -- xem chu thich 11_pet.lua.
CFG.PET = {
  -- KHONG co pet mac dinh. nil = chua thu phuc con nao thi khong co pet.
  --
  -- Truoc day o day la Hmkg (Mountain King) de thu co che, va no DANH
  -- NGUOI CHOI. Nguyen nhan: chu so huu bj_PLAYER_NEUTRAL_EXTRA la mot
  -- phe TRUNG LAP THU DICH. Toi muon no tu bang chon tuong -- nhung o do
  -- unit tao ra roi XOA NGAY trong cung mot khung hinh, nen thu dich hay
  -- khong chua bao gio quan trong. Chep mot mau dung cho vat the vut di
  -- sang vat the SONG LAU la sai.
  --
  -- Gio pet chi den tu viec thu phuc Thanh Thu (d.petUnit), va
  -- startPet() dat lien minh ro rang -- xem 11_pet.lua.
  unit   = nil,
  -- 'Aloc' = Locust. Khong chon duoc, khong bi nham muc tieu, khong va
  -- cham. Day la ma goc cua Warcraft, khong phai ability tu tao.
  locust = id('Aloc'),
  scale  = 0.55,          -- 'mini' -- hero thuong la 1.0
  near   = 220.0,         -- xa hon bay nhieu thi moi doi cho
  tick   = 0.25,          -- giay giua hai lan kiem khoang cach
  spawnOffset = 120.0,    -- hien ra cach hero bao xa

  -- CHU SO HUU. true = player trung lap, khong phai nguoi choi.
  --
  -- Hmkg la unit kieu HERO, ma MOI hero thuoc ve mot nguoi choi deu hien
  -- o thanh hero goc tren trai. Locust khong go duoc cho do: no lo phan
  -- chon/nham muc tieu/va cham, khong lo phan giao dien.
  --
  -- Doi chu sang player trung lap la xong -- trung lap khong co giao
  -- dien nen khong co thanh hero. Pet van nhan lenh tu trigger nhu cu,
  -- vi lenh di qua IssuePointOrder chu khong qua chuot nguoi choi.
  --
  -- Doi lai: mat mau co cua nguoi choi, nen phai SetUnitColor tra lai.
  neutral = true,
}

CFG.GEAR_TOGGLE_SLOT = { 2, 4 }

-- O Pet TRANG TRI cu da bo: gio Canh va Thanh Thu la hai O THAT o
-- hang 5, di qua may moc o luoi nhu tam mon trang bi. Khong con o nao
-- "ve cho dep ma khong bam duoc".
CFG.GEAR_PET_SLOT = nil

-- Icon hai o hang 5, DUONG LUI cho luc chua mo bo/con nao.
--
-- Deo roi thi o lay anh cua chinh bo dang deo -- API.wingIcon /
-- API.petIcon, xem tabItems() trong 5_gear.lua.
--
-- Ca hai duong lui deu la anh DA IMPORT that (w3import.py list thay
-- wing\eth_*.blp va avatar\B00N.blp), khong phai duong dan BTN* go tu
-- tri nho.
--
-- Canh truoc day lui ve BTNMonsoon -- mot icon phep thuat khong lien
-- quan gi toi canh. Nguoi chua toi canh gioi 2 nhin vao o do khong
-- doan ra no la o gi. Lui ve chinh bo DAU TIEN thi o luon la mot doi
-- canh, chi khac la chua mo.
CFG.GEAR_WING_ICON = [[wing\eth_storm.blp]]
CFG.GEAR_PET_ICON  = [[avatar\B001.blp]]

-- Cot giua cua luoi = ly lich hero (icon + ten + canh gioi). nil = bo.
--
-- Icon lay tu CFG.HEROES cua chinh nguoi choi do -- khong phai mot bong
-- nguoi chung chung, va khong ton them anh nao.
--
-- GEAR_DOLL_ICON: canh o icon. 0.090 = 162px o 1080p, tuc phong 2.5 lan
-- tu 64px. Lap day cot (0.1375) se la 3.9 lan va nhin ra be.
-- ---------- Icon Trang Bi TU VE ----------
--
-- Duong dan DUNG SAN theo cong thuc, khong go tung cai:
--
--     gear\<key>\<canh gioi 2 chu so>.blp
--
-- <key> la truong 'key' cua tung mon o tren -- TIENG ANH, vi no thanh
-- duong dan that trong map.
--
-- THEM CANH GIOI KHONG PHAI SUA CODE: tha anh vao
-- docs/01-tmp/<thu muc>/NN-*.png roi chay
--
--     python w3gear_icons.py
--
-- No sinh BLP, chep vao map va dang ky vao war3map.imp. Bang duoi tu
-- tim thay.
--
-- THIEU FILE THI LUI VE icon do tu item (truong 'icon'), khong ra o
-- xanh la -- xem iconFor() trong 5_gear.lua.
-- ---------- Anh canh gioi ----------
--
-- Cung quy uoc voi CFG.GEAR_ICON_PATH: %02d la so CANH GIOI 1..20, khop
-- CFG.REALMS theo thu tu. Sinh bang `python w3gear_icons.py` tu
-- docs/01-tmp/realm/NN-ten.png -- them canh gioi thi tha anh vao do va
-- nang REALM_ICON_MAX, khong sua mot dong Lua nao.
--
-- 256px chu khong 128 nhu icon: no hien o kho ~340 px o 1080p.
CFG.REALM_ICON_PATH = [[realm\%02d.blp]]
CFG.REALM_ICON_MAX  = 20

CFG.GEAR_ICON_PATH = [[gear\%s\%02d.blp]]

-- Canh gioi cao nhat DA CO anh. Tren muc nay thi dung anh cua muc nay --
-- mon o canh gioi 7 ma moi ve toi 5 thi van hien anh 5, khong bi trong.
--
-- Ve them canh gioi: tha anh vao docs/01-tmp/<thu muc>/NN-*.png, chay
-- python w3gear_icons.py, roi nang so nay. Ba buoc, khong sua code.
--
-- BUOC BA LA BUOC DE QUEN. So nay tung ket o 5 trong khi trong map da co
-- 15 muc -- tuc muoi canh gioi deu hien anh cua canh gioi 5, va khong co
-- gi bao ca: thieu anh thi lui ve anh thap hon chu khong no.
CFG.GEAR_ICON_MAX = 20

CFG.GEAR_DOLL_COL  = 2
-- Do duoc tren anh chup: icon 0.090 trong hop 0.1537 x 0.214 chi lap
-- 25% dien tich -- ba phan tu cai hop la MOT MANG DEN DAC, va no la
-- vung den to nhat ca bang. 0.130 dua len 51%, chu van con cho cho ten
-- va canh gioi ben duoi.
CFG.GEAR_DOLL_ICON = 0.130

-- Hinh bong nguoi o cot giua. nil = de trong (mot o vien rong).
--
-- (CFG.GEAR_SILHOUETTE da xoa 2026-09-19: khong file nao doc. Cot giua
--  bang Trang Bi gio la ly lich hero -- icon + ten + canh gioi -- chu
--  khong phai bong nguoi. Xem 1_panel.lua.)

-- ---------- Chi so: CONG THI LEO, NHAN THI PHANG ----------
--
-- Sau mon chia lam HAI loai, va chung phai duoc doi xu khac nhau.
--
-- BON MON CONG DIEM (Ao/Giay/Mu/Nhan) khong tu leo. Mot diem Str o canh
-- gioi 20 dang gia dung bang mot diem Str o canh gioi 1, ma quai thi da
-- leo x146. Nen chung phai nhan CULT_STAT_STEP^(canh gioi-1) bang tay,
-- neu khong den nua sau van chung thanh hat bui.
--
-- HAI MON NHAN (Kiem %sat thuong, Khien %chong chiu) TU LEO SAN: gia tri
-- cua chung ti le voi toan bo suc manh con lai, ma phan do da leo x146
-- roi. Cho chung leo them mot lan nua la x146 BINH PHUONG.
--
-- Day dung la cai bay ADR 0010 da phai viet ra cho quai -- giap phang
-- nhung nhan voi mau dang leo -- lap lai o tang nguoi choi.
--
-- Nen: bon mon cong thi LEO theo Tu Vi, hai mon nhan thi PHANG (tuyen
-- tinh theo so bac da di).

-- Diem chi so cho MOT bac o canh gioi 1. Cac canh gioi sau nhan theo
-- CHINH CULT_STAT_STEP -- dung go 1.30 o day, de doi duong cong Tu Vi
-- thi trang bi tu di theo.
--
--   value(T,L) = BASE x [ 5 x (STEP^(T-1) - 1)/(STEP-1) + L x STEP^(T-1) ]
--
-- 1.5 chon de mot mon di TRON 100 bac dang ~4,726 diem = 20% Tu Vi ca
-- van (24,198). Ba mon tron -- dung bang so tien ca van mua duoc -- la
-- 60%. Do la phan VUOT LEN, khong phai phan bam theo quai (ADR 0020).
CFG.GEAR_STAT_BASE = 1.5

-- Kiem: % sat thuong GAY RA o bac 100. Tuyen tinh theo so bac.
--
-- An vao CA BA duong: don thuong (onDamaged), sat thuong phep va hoi mau
-- (skillDamage). Doi lai no khong cho mau nhu Ao.
--
-- 0.20 de nguoi choi tron Kiem ngang mot mon cong diem tron: +4,726 diem
-- tren nen 24,198 cua Tu Vi la +19.5% sat thuong. Lam tron len 20%.
CFG.GEAR_DMG_MAX = 0.20

-- Khien va Ao Choang: % sat thuong NHAN VAO duoc giam, o bac 100.
-- Tuyen tinh. Khien cham DON DANH, Ao Choang cham PHEP -- moi mon mot
-- nua chien truong.
--
-- KHONG cong diem giap. Da tinh: de ngang mot mon khac thi chi duoc cong
-- 2.8 DIEM giap ca van -- tuc 0.03 moi bac, mot con so khong hien thi
-- noi. Vi EHP = mau x (1 + 0.06 x giap) nen giap manh den muc khong chia
-- duoc thanh 100 bac. Doi sang % chong chiu thi cung ngan sach do tra ve
-- mot con so nguoi choi doc duoc.
--
-- 0.25 chu khong phai 0.15 vi moi mon chi an MOT PHAN luong sat thuong
-- vao. Neu quai danh 60% vat ly / 40% phep thi Khien tron dang
-- 0.25 x 0.60 = 15% tong, xap xi +20% cua cac mon kia.
--
-- TI LE 60/40 LA GIA DINH, CHUA DO. Do la hai con so dau tien phai xem
-- lai sau tran choi thu dau -- bat CFG.TRACE, cong don sat thuong theo
-- BlzGetEventDamageType roi chia.
CFG.GEAR_MITIG_MAX = 0.25

-- Nhan: % sat thuong GAY RA hoi thanh mau, o bac 100. Tuyen tinh.
--
-- Bang 0.20 cua Kiem, co y. Hai mon deu an theo sat thuong gay ra nen
-- chung mot thang do; de Nhan cao hon thi no vua manh hon Kiem vua lam
-- duoc them viec song sot.
--
-- Nhan NHAN VOI Kiem chu khong cong: Kiem cong 20% sat thuong, roi Nhan
-- hut 20% cua con so DA cong. Do la cho hai mon nay di voi nhau, khong
-- phai trung nhau.
--
-- Hut mau KHONG cuu duoc mot don chet ngay -- Chan Dia cua boss an 83%
-- mau mot phat. No manh o tran keo dai, yeu o don sam set. Bu qua bu
-- lai voi Khien/Ao Choang, khong dam len nhau.
CFG.GEAR_LIFESTEAL_MAX = 0.20

-- Tran CUNG cho tong phan giam sat thuong (Khien + bi dong "reduce").
-- Hai nguon nhan voi nhau chu khong cong, nen khong bao gio toi 100% --
-- nhung van chan mot lan nua o day de mot lan chinh so tay khong bien
-- hero thanh bat tu.
CFG.GEAR_MITIG_CAP = 0.40

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
-- MO KHOA 2026-09-19. Bang co noi dung roi.
CFG.RELIC_LOCKED = false

-- Bon Phap Khi. MUA MOT LAN, KHONG CO CAP.
--
-- Y TUONG COT LOI: moi mon la CAU TRA LOI cho mot ap luc cu the, khong
-- phai mot nac thang nua. Trang Bi da la cai thang -- ai cung leo cung
-- mot thang, chi khac leo cao bao nhieu. Neu Phap Khi cung la "+8% sat
-- thuong, +8% nua" thi no chi la Trang Bi thu hai doi ten.
--
-- KHONG DU TIEN MUA HET, va do la diem. Ca van kiem ~292 Go, ky nang
-- tieu 70, con ~222. Tong gia bon mon la 250 -- mua duoc DUNG BA, phai
-- bo mot. Do la cho duy nhat trong map nguoi choi phai CHON.
--
-- Hai mon "cong vao nha chinh" (nhahp/nharegen) DA BO khoi thiet ke:
-- the VI da lam dung viec do roi, va hai he cung sua mot con so la hai
-- noi cung khai mot thu -- som muon lech. Hai ma do van con trong
-- rescaleHouse() va luon tra false; giu lai vo hai.
--
-- HIEU UNG TO CO CHU DICH (+25% chu khong +8%): mot mon mua-mot-lan-
-- khong-co-cap phai cam thay duoc NHU MOT SU KIEN. Mua xong ma khong
-- thay gi doi thi 70 Go do la tien vut di.
--
-- ICON dung CHAN DUNG BON THANH THU, khong go duong dan BTN* theo tri
-- nho. Hai ly do: duong dan sai thi ra O XANH LA chu khong bao loi --
-- im lang, dung kieu bay cua map nay; va bon anh do DA IMPORT that
-- (w3import.py list thay avatar\B001..B004.blp), nen chac chan co.
--
-- Tien the no noi dung y do: mon nay mo khoa bang con thu nao.
--
-- Doc-luc-dung: khong mon nao dang ky trigger rieng. Cho nao can thi
-- hoi API.relicHas. Them mon moi la them dong o day VA viet cho doc ma
-- cua no -- khong co bang dieu phoi tu dong nao ca.
CFG.RELIC = {
  -- 'unlock' = so thu tu trong CFG.SIDE_QUESTS. Bang nay xep DUNG THU
  -- TU HA THU (Chu Tuoc -> Huyen Vu -> Bach Ho -> Thanh Long), nen
  -- unlock[i] == i. Xep the de the IV doc nhu mot thanh tien do: cot
  -- tren mo truoc, cot duoi mo sau.
  { code = "hoavu", price = 70, unlock = 1,
    vi = "Hoa Vu Linh Chau", en = "Vermilion Pearl",
    icon = [[avatar\B001.blp]],   -- chan dung Chu Tuoc
    dmgUp = 0.25,
    desc    = "Sat thuong gay ra +25%.",
    desc_en = "Deal 25% more damage." },

  { code = "huyenquy", price = 70, unlock = 2,
    vi = "Huyen Quy Giap", en = "Black Tortoise Mail",
    icon = [[avatar\B002.blp]],   -- chan dung Huyen Vu
    mitig = 0.20,
    desc    = "Sat thuong nhan -20%, ca don danh lan phep.",
    desc_en = "Take 20% less damage, both physical and spell." },

  { code = "batdong", price = 55, unlock = 3,
    vi = "Bat Dong Minh Vuong", en = "Immovable King",
    icon = [[avatar\B003.blp]],   -- chan dung Bach Ho
    halve = 0.50,
    desc    = "No Tan va Xe Giap cua boss deu chi con mot nua.",
    desc_en = "Volatile bursts and boss Sunder are both halved." },

  { code = "luongnghi", price = 55, unlock = 4,
    vi = "Luong Nghi Chau", en = "Duality Orb",
    icon = [[avatar\B004.blp]],   -- chan dung Thanh Long
    modCut = 0.50,
    desc    = "Tu chinh Chan Phep / Day Da chi con cat MOT NUA.",
    desc_en = "Spell Ward / Thick Hide traits cut only HALF as much." },
}


-- (CFG.RELIC_LIVE da bo: khong file nao doc no.)


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
CFG.FORTUNE_X = 0.40
CFG.FORTUNE_Y = 0.36

-- Cach nhau bao lau giua hai cot khi chia the. 0 = tat hieu ung.
--
-- DA TAT -- 2026-09-19. Ly le cu: 0.10 giay du de mat thay 'vua sang
-- luot moi'. Do la ly le cua nguoi NHIN MOT LUOT. Nguoi choi that thi
-- quay 12 luot lien tiep sau Thanh Long, va luc do moi lan cho la mot
-- lan tay phai dung lai -- 2,4 giay cong don cho ca chuoi, tra gia
-- bang nhip bam.
--
-- Mot hieu ung trang tri thua o lan thu muoi hai thi no khong con la
-- trang tri, no la do tre.
CFG.FORTUNE_DEAL_STEP = 0.0

CFG.FORTUNE_ELITE = 1
CFG.FORTUNE_BOSS  = 3

-- Gia tri MOT the o bac 1. Cac bac sau nhan theo CHINH
-- CFG.CULT_STAT_STEP, nen quay tu bam theo Tu Vi: doi duong cong Tu
-- Vi thi quay tu co theo, khong phai chinh lai o day.
--
-- 2.2 chon de 7 luot mot canh gioi dang gia ~31% mot lan dot pha, va ca
-- van (140 luot) cong ~9,700 chi so = 40% cua Tu Vi.
-- 7.0, NANG TU 2.2 -- 2026-09-20, sau khi quy hai the ve CUNG MOT
-- DON VI (diem chi so):
--
--   the Vang 60 vang -> 6 da -> 6 buoc Luyen
--   moi buoc Luyen cong GEAR_STAT_BASE x CULT_STAT_STEP^(bac-1) = 1.5x
--   tuc the Vang = 9.0 x he so, the Chi So = 2.2 x he so
--
-- Ti le 4.09 lan, va no DUNG IM suot 20 bac vi ca hai cung nhan
-- CULT_STAT_STEP. Nghia la khong bao gio co diem giao: nguoi choi nao
-- nhan ra se bam Vang 168 lan lien tiep ma khong can nhin.
--
-- 7.0 chu khong 9.0: the Chi So an NGAY va khong qua xac suat, con the
-- Vang phai di qua shop, qua he Luyen 100/75/50/25/15, va qua tran Tu
-- Vi. Chenh 22% la phan tra cho su chac chan do.
CFG.FORTUNE_VALUE = 7.0

-- Dai ngau nhien quanh gia tri do: 0.7 .. 1.3 lan.
CFG.FORTUNE_RANGE_MIN = 0.70
CFG.FORTUNE_RANGE_MAX = 1.30

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
CFG.FORTUNE_GOLD_MIN = 30
CFG.FORTUNE_GOLD_MAX = 90

-- HAI THE, khong con ba. The "da Huyen Thiet" da BO -- 2026-09-18.
--
-- Ly do khong phai no yeu, ma no TRUNG: vang mua duoc da o shop, lai mua
-- duoc ca lo va Ankh. The da la tap con cua the vang, kem dung mot thu
-- la linh hoat. Hai the trung nhau thi khong con la lua chon.
--
-- Bo no con duoc mot thu quan trong hon: ca van chi con MOT duong ra da
-- (vang -> shop), nen gia da trong shop tro thanh NUM DUY NHAT dieu nhip
-- Trang Bi. Truoc do hai nguon da danh nhau, chinh cai nay hong cai kia.
--
-- Hai the con lai so duoc voi nhau, va do la diem chinh:
--
--   the vang   60 vang tb -> 6 da (gia 10) -> 1.875 x 1.30^(r-1) diem
--   the chi so                                 2.2 x 1.30^(r-1) diem
--
-- CUNG THUA SO 1.30^(r-1) nen hai duong SONG SONG vinh vien, khong bao
-- gio cat nhau -- cung thu thuat ADR 0020 dung cho quai. The chi so hon
-- 17%, dung the: no tra ngay va khong qua xac suat, con the vang phai
-- doi qua shop, qua he 100/75/50/25/15, va qua tran Tu Vi.
--
-- Thu tu trong bang NAY LA thu tu cot trai sang phai, va cung la thu tu
-- goi GetRandomInt trong drawCards -- doi thu tu la doi chuoi ngau nhien.
CFG.FORTUNE_KINDS = { "gold", "stat", "lumber" }

-- BA LOAI, RUT HAI. Moi luot la mot cau hoi KHAC NHAU:
--
--   Go   <-> Chi So    mo mot nut bam moi   vs  manh hon ngay
--   Go   <-> Vang      ky nang              vs  trang bi
--   Chi So <-> Vang    an ngay              vs  phai qua Luyen
--
-- Ba cau hoi thay vi mot. Mo ca ba the thi no thanh "chon cai to nhat"
-- -- va cai to nhat thi tinh ra duoc, tuc khong con la lua chon.
CFG.FORTUNE_DRAW = 2

-- The Go: MOT diem, CO DINH, khong nhan theo bac.
--
-- VI SAO KHONG NGAU NHIEN. Go la dong tien NGUYEN va gia phang: 1 Go =
-- dung mot bac ky nang. Doc phat hieu ngay. Ngau nhien 1-3 thi bat
-- nguoi choi lam tinh moi lan rut, VA no tu lat quyet dinh: 3 Go thi
-- hien nhien hon the Chi So, 1 Go thi hien nhien thua. Do la NHIEU,
-- khong phai lua chon.
--
-- The Vang DUOC PHEP ngau nhien vi 30 hay 90 khong doi viec ta co muon
-- vang hay khong -- no la so lon, lien tuc.
--
-- VI SAO KHONG NHAN THEO BAC: cho tieu cua Go deu PHANG (1 Go mot bac
-- ky nang, Phap Khi gia co dinh). Nhan theo bac thi cuoi van mot the
-- cho 100 Go trong khi chi con 5 cho tieu.
CFG.FORTUNE_LUMBER = 1

-- The 2 cong vao MOT chi so ngau nhien trong ba.
--
-- Biet truoc: sat thuong ky nang an theo chi so CAO NHAT, ma Hart co Str
-- cao nhat va Tu Vi cong deu ca ba -- nen Str luon dan dau. Trung Agi
-- hay Int thi KHONG tang sat thuong ky nang, chi duoc giap/toc danh hoac
-- mana.
--
-- Giu nguyen, khong bu he so: canh bac co chu dich -- chu du an chot.
CFG.FORTUNE_STATS = { "str", "agi", "int" }

-- ---------- Shop: the V ----------
--
-- He DUY NHAT tieu VANG, va la he duy nhat ban do TIEU HAO. Ba he kia
-- deu la tich luy vinh vien; shop la cho doi tien lay mot lan dung.
--
-- Ngan sach: 10,000 vang ca van, 50 moi wave thuong (mot nguoi choi).
--
-- Gia 5 cho ca hai lo: nam lo moi wave neu tieu het. Ban truoc dat
-- 40/30 (mot lo mot wave), roi 10; chu du an chot lai 5.
--
-- Cung gia voi Thap Canh la CO Y: ca ba deu la do tieu hao mua theo
-- nhip wave, nen dat chung mot bac de nguoi choi khong phai tinh -- chi
-- phai chon lan nay can MAU, MANA hay mot cai THAP chiu don.
--
-- 'item' la ma item CO SAN cua Warcraft, khong phai item tu tao:
--   phea  Potion of Healing  -- hoi mau
--   pman  Potion of Mana     -- hoi mana
-- Neu ma sai thi UnitAddItemById tra ve nil, va 6_shop.lua BAO RO chu
-- khong nuot im -- xem ADR 0012.
CFG.SHOP = {
  { code = "hp", vi = "Lo Hoi Mau",  en = "Healing Potion",
    item = id('phea'), price = 5,
    icon = [[ReplaceableTextures\CommandButtons\BTNPotionGreenSmall.blp]],
    desc_vi    = "Hoi mau ngay. Dung duoc mot lan.",
    desc_en = "Restores health instantly. One use." },

  { code = "mp", vi = "Lo Hoi Mana", en = "Mana Potion",
    item = id('pman'), price = 5,
    icon = [[ReplaceableTextures\CommandButtons\BTNPotionBlueSmall.blp]],
    desc_vi    = "Hoi mana ngay. Dung duoc mot lan.",
    desc_en = "Restores mana instantly. One use." },

  -- Da Huyen Thiet: mon DUY NHAT trong shop khong phai item.
  --
  -- 'da' thay cho 'item': buy() cong thang vao S.p[pid].da chu khong bo
  -- gi vao tui. Nen no khong ton o tui, khong can hasRoom(), va khong bi
  -- probeItems() do (khong co ma item de do).
  --
  -- VAI DA DOI -- 2026-09-18. Truoc day day la cho "go khi den" ben canh
  -- the da cua Co Duyen. The da da bo, nen day gio la DUONG RA DA DUY
  -- NHAT cua ca van: vang -> da -> Trang Bi.
  --
  -- GIA 10 LA NUM DIEU NHIP TRANG BI. Suy ra chu khong chon bua:
  --   thu nhap vang ca van   4,000 (quai) + 8,400 (the vang) = 12,400
  --   mot mon di tron        471 da
  --   12,400 / 10            1,240 da  ->  ~2.6 mon
  -- Tuc tien chi du cho 2-3 trong 6 mon: the Trang Bi la mot LUA CHON,
  -- khong phai mot thanh tien do ai cung keo het.
  --
  -- Ha gia xuong la da thua, ma da thua thi bam mai cung trung -- he xac
  -- suat 100/75/50/25/15 khong con nghia gi.
  { code = "iron", vi = "Da Huyen Thiet", en = "Black Iron",
    iron = 1, price = 10,
    icon = [[ReplaceableTextures\CommandButtons\BTNStaffOfSanctuary.blp]],
    desc_vi    = "Mot vien da, dung de nang cap trang bi.",
    desc_en = "One stone, used to upgrade equipment." },

  -- 500 vang = 10 wave thu nhap cua mot nguoi (50 vang/wave). Dat cao
  -- hon hai lo kia hai bac do vi no mua thu khac han: khong phai mot
  -- lan hoi mau, ma mot lan KHONG CHET.
  --
  -- Ma 'ankh' la phong doan nhu 'phea'/'pman'. Khong sao: startShop()
  -- tao thu moi item luc vao map, ma sai thi CreateItem tra ve nil va
  -- no bao do ngay -- khong doi toi luc ai do bo ra 500 vang moi biet.

  { code = "ankh", vi = "Ankh Hoi Sinh", en = "Ankh of Reincarnation",
    item = id('ankh'), price = 500,
    icon = [[ReplaceableTextures\CommandButtons\BTNAnkh.blp]],
    desc_vi    = "Tu hoi sinh tai cho khi chet.",
    desc_en = "Revives you on the spot when you die." },

  -- ---------- Thap canh (phat cung VA ban) ----------
  --
  -- 'tsct' la item GOC cua Warcraft: Ivory Tower. Ability cua no la
  -- Albt "Build Tiny Scout Tower" -- viec DUY NHAT cua no la dung thap,
  -- khong co tac dung thua nao kem theo. Do la ly do chon no thay vi
  -- muon mot binh thuoc lam the: binh thuoc dung se VUA hoi mau VUA
  -- dung thap, ma ability goc thi khong go duoc luc chay (ADR 0008).
  --
  -- DA MO BAN -- 2026-09-19. Truoc day 'forSale = false' nen no chi den
  -- tu CFG.START_ITEMS: het ba cai phat dau van la het han ca van.
  --
  -- Gia 10 dat NGANG mot hon Da Huyen Thiet, va gap doi mot lo thuoc.
  -- Do la ti gia can noi ra: mot cai thap = mot buoc tien Trang Bi bi
  -- hoan lai. Nguoi choi mua thap la dang tra bang TOC DO LEN DO, chu
  -- khong phai bang mot khoan vang le khong dung vao dau.
  --
  -- Khong dat re hon: thap chiu don thay hero, ma re qua thi dap thap
  -- lien tuc se re hon ca mua thuoc -- va ca he Trang Bi thanh khong
  -- can thiet o nhung wave dau.
  --
  -- give() van tim duoc no nhu truoc: give() tra ca bang CFG.SHOP,
  -- khong loc theo 'forSale'.
  --
  -- probeItems() tao thu moi ma luc vao map va bao do neu sai -- nen
  -- 'tsct' go nham thi biet ngay, khong im lang mat thap.
  { code = "tower", vi = "Thap Canh", en = "Watch Tower",
    item = id('tsct'), price = 10,
    icon = [[ReplaceableTextures\CommandButtons\BTNHumanWatchTower.blp]],
    desc_vi = "Dung mot thap canh. Thap chiu don thay hero.",
    desc_en = "Raises a watch tower. It soaks damage for you." },
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
-- So thap phat cung luc pick hero. PHAI khai TRUOC CFG.START_ITEMS --
-- khai sau thi "CFG.TOWER_START or 2" o duoi doc ra nil va lang le lay
-- 2, tuc cai num nay khong dieu khien gi ca.
--
-- Thap chi de thu luc dau van, nen so nho va KHONG mua them duoc: het
-- ba cai la phai dua vao hero.
CFG.TOWER_START = 3

-- Da ren phat cung luc voi thap, o cong HeroMoveRegion. 0 de tat.
--
-- DA TAT -- 2026-09-19. Ly le cu: hai vien = hai cu Luyen, de nguoi
-- choi BAM THU cai nut do mot lan trong phut dau roi moi biet minh
-- dang di gom cai gi.
--
-- Bo vi gio da co 50 vang, va Da Huyen Thiet gia 10 -- muon bam thu
-- cai nut do thi mua lay, khong ai phat. Hai vien cho khong lam nhat
-- mat buoc dau cua chuoi "vang -> da -> Trang Bi": chuoi do chi co
-- nghia khi nguoi choi tu di qua no mot lan.
CFG.IRON_START = 0

CFG.START_ITEMS = {
  { code = "hp", count = 10 },
  { code = "mp", count = 10 },
  -- Hai thap thu ban dau. Phat cung luc pick hero, khong mua duoc.
  { code = "tower", count = CFG.TOWER_START or 2 },
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
  [21] = { role = "sect" },
  [16] = { role = "gate" },

  [17] = { role = "qivein" },
  [13] = { role = "threebody" },
  [3]  = { role = "threepaths" },
  [5]  = { role = "pagoda" },
}

-- Block khong co trong bang tren = "hoang" (chua giao viec). De trong
-- CO Y, khong phai quen -- ADR 0014 va ADR 0018.
--
-- 'coop' la CO CHE buoc ba nguoi phai phoi hop. No la ly do ton tai cua
-- vung; vung nao khong dien duoc o nay thi chua nen co.
-- 'tien' la dong tien vung do sinh ra.
-- 'mau'  dung cho ping minimap cua lenh "-vung".
CFG.BLOCK_ROLE = {
  sect  = { vi = "Tong Mon", en = "Sect",       color = {255, 220,  80} },
  gate  = { vi = "Ma Mon",   en = "Demon Gate", color = {255,  80,  80} },

  threebody = { vi = "Tam The Tran", en = "Three-Body Array",
             color = {255, 140, 255}, currency = "Go",
             coop = "Boss chia ba than o ba goc. Than nao chet le thi hai" ..
                    " than kia hoi sinh no. Phai ha ca ba trong mot cua so" ..
                    " thoi gian -- ba nguoi, ba cho, mot nhip." },

  qivein = { vi = "Linh Mach", en = "Qi Vein",
               color = {255, 200, 120}, currency = "Linh Khi",
               coop = "Ba tru dan khi. Mach chi chay khi CA BA tru deu co" ..
                      " nguoi dung. Quai lien tuc ra de day nguoi khoi tru." },

  threepaths = { vi = "Tam Dao Mon", en = "Three Paths",
             color = {120, 255, 160}, currency = "Go",
             coop = "Ba cua, moi cua chi mot VAI qua duoc: Kim can nguoi" ..
                    " chiu don, Moc can nguoi giai, Hoa can nguoi pha nhanh." ..
                    " Dung ba hero cua CFG.HEROES." },

  pagoda = { vi = "Tran Ma Thap", en = "Warding Pagoda",
             color = {120, 200, 255}, currency = "Go",
             coop = "Mot nguoi phai dung yen dan phap, khong danh khong" ..
                    " chay duoc. Hai nguoi con lai gong ca tran. Doi phien" ..
                    " nhau khi nguoi dang dan sap guc." },

  wilds = { vi = "Hoang Dia", en = "Wilds", color = {130, 130, 130},
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
CFG.PANEL_ESC_LOCK = 0.25

-- ---------- Bang tran dau (phim R) ----------
--
-- Bang THU HAI, tach khoi bang nhan vat co y:
--   ESC  "nhan vat toi the nao"   -- mo giua tran, voi
--   R    "tran dau dang the nao"  -- mo giua hai dot, thong tha
--
-- Hai cau hoi khac nhau, hai nhip khac nhau. Gop lam mot bang 7 the la
-- bat nguoi choi cuon qua Trang Bi de tim nut goi dot.
--
-- HAI BANG LOAI TRU NHAU, khong chong len nhau: mo cai nay la dong cai
-- kia. Chong len nhau thi ESC phai doan dong cai nao, ma cau hoi do
-- khong co dap an dung.
CFG.GAME_KEY = "R"
CFG.GAME_X   = 0.40
CFG.GAME_Y   = 0.42

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

-- Bang thong ke ben phai luoi Trang Bi: co chu RIENG, nho hon.
--
-- Do duoc tu anh chup: chu o co 0.85 ton ~9,1 px moi ky tu. Cho co
-- 352 px, ma ten dai nhat ("Day Chuyen - Thuong Cap") + gia tri dai
-- nhat ("+1,575 moi chi so") = 365 px -- KHONG vua du chia cot the nao.
--
-- Bang thong ke la chu doc day, nho hon la binh thuong. 0.72 dua tong
-- ve ~310 px, vua ca hai cot.
CFG.PANEL_SCALE_STAT = 0.72

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
-- Chi dung hai o mau DA THAY VE RA MAU tren anh chup, khong doan them
-- so hieu TeamColor nao: 04 la vang (thanh tien do dang dung), 27 la den
-- (vach ke dong va nen thanh tien do dang dung). Doan sai mot so hieu
-- thi ra o XANH LA, dung loi ma BTNRingViolet da dinh.
CFG.PANEL_BTN_EDGE   = [[ReplaceableTextures\TeamColor\TeamColor04]]
CFG.PANEL_BTN_FILL   = [[ReplaceableTextures\TeamColor\TeamColor27]]
CFG.PANEL_BTN_BORDER = 0.0016

-- BE DAY VIEN theo trang thai nut -- nhan so cua PANEL_BTN_BORDER.
--
-- Day la tin hieu CHINH cho "bam duoc hay khong". Mau chu mot minh thi
-- qua yeu: xam di vai phan tram do sang, tren nen den, o co chu 0.85 --
-- phai doc tung nut moi biet. Cau nguoi choi hoi khi liec bang la "cai
-- nao bam duoc BAY GIO", tuc quet 7 o mot luot, nen tin hieu phai doc
-- duoc bang mat ngoai vi: hinh khoi, khong phai chu.
--
-- Doi BE DAY chu khong doi MAU: doi mau la phai them duong dan texture,
-- ma doan duong dan texture trong du an nay lan nao cung sai.
-- MAU RUOT theo trang thai. Tu sinh bang w3blp.py, nguon o
-- docs/01-tmp/ui/ -- khong doan duong dan texture nao ca.
--
-- Vi sao can mau CHU KHONG chi be day vien: be day la tin hieu TUONG
-- DOI, phai co ca hai trang thai canh nhau moi doc duoc. Luc het tien
-- thi ca tam nut deu thieu, khong con gi de so. Mau nen doc duoc mot
-- minh.
CFG.PANEL_BTN_FILL_POOR   = [[ui\btn_poor.blp]]
CFG.PANEL_BTN_FILL_LOCKED = [[ui\btn_locked.blp]]

-- Nut cao BTN_H = 0.026, tuc 47 px o 1080p. Vien 3.0 x 0.0016 = 8,6 px
-- MOI BEN, an mat 37% chieu cao -- nhin ra mot khung vang to hon chinh
-- cai nut. Da thu, phai bo.
--
-- Gio MAU RUOT ganh phan bao trang thai, nen vien khong can het loi:
--   on/poor  vien mong nhu nhau, khac nhau o mau ruot
--   locked   khong vien -- phang han, doc ra "chua toi luot"
CFG.PANEL_BTN_W_ON     = 1.0   -- bam duoc: vien mong, ruot den
CFG.PANEL_BTN_W_POOR   = 1.0   -- thieu tien: vien mong, ruot do sam
CFG.PANEL_BTN_W_LOCKED = 0.0   -- chua toi luot: khong vien, ruot xam

-- Thanh tien do cua the kieu "focus". Hai o mau DAC -- va o day thi mot
-- o mau dac dung la thu can, khac han truong hop dung no lam nen bang.
CFG.PANEL_BAR_BG   = [[ReplaceableTextures\TeamColor\TeamColor27]]
CFG.PANEL_BAR_FILL = [[ReplaceableTextures\TeamColor\TeamColor04]]
-- Cao cua bang SUY RA tu so dong trong 4_ui/1_panel.lua, khong
-- go tay o day -- de o day thi them mot dong la tran ra ngoai khung.

-- Ke vach xen ke cho de doc. Tat neu thay roi mat.
CFG.PANEL_GRID     = true
-- Nen o ke: KHONG den dac nua.
--
-- TeamColor27 la den tuyet doi. Dung cho vach ke mot dong thi ra VACH
-- DEN tren nen panel mau lam sam; dung cho hop hinh nguoi (0.1537 x
-- 0.214) thi ra mot mang den to nhat ca bang. Do duoc tren anh chup:
-- ba phan tu cai hop la den dac.
--
-- (22,42,48) la lam sam, cung ho voi nen panel nen doc ra "o" chu khong
-- ra "lo thung". O mau tu ve bang w3blp.py -- xem ui_icons().
CFG.PANEL_GRID_TEX = [[ui\panel_row.blp]]
