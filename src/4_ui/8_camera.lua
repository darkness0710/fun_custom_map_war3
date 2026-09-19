-- ============================================================
--  8_camera.lua  --  Tam nhin camera, lenh "-zoom"
--
--  BA DIEU PHAI NHO:
--
--  1. CAMERA LA CUC BO, va do la LY DO no an toan. SetCameraField chi
--     doi camera cua may dang chay -- khong mot chut trang thai game
--     nao doi theo, nen khong co cua desync. Nguoc lai cung dung: goi
--     thang ma khong loc nguoi choi thi CA DOI bi zoom theo.
--
--     Dung SetCameraFieldForPlayer neu ban nay co; khong thi loc bang
--     GetLocalPlayer(). Ca hai duong deu an toan vi cung khong doi
--     trang thai.
--
--  2. ZOOM RA XA THI PHAI NOI FARZ. Warcraft cat canh o mot khoang
--     nhat dinh (far-Z); keo TARGET_DISTANCE ra 4000 ma de nguyen farz
--     thi dia hinh phia xa BIEN MAT thay vi hien ra. Trieu chung nhin
--     ra "map bi thung", de tuong la loi terrain.
--
--  3. CHAN TREN CHAN DUOI. Go "-zoom 999999" thi camera bay ra ngoai
--     vu tru va nguoi choi khong co duong ve tru khoi dong lai game.
--     Clamp, va bao ro da clamp.
--
--  Nho: goi ham cua file khac phai qua API.
-- ============================================================

local function clampDist(v)
  local lo = CFG.ZOOM_MIN or 900.0
  local hi = CFG.ZOOM_MAX or 4500.0
  if v < lo then return lo end
  if v > hi then return hi end
  return v
end

-- Dat tam nhin cho MOT nguoi choi.
local function setZoom(pid, dist, secs)
  if SetCameraField == nil and SetCameraFieldForPlayer == nil then
    API.trace("camera: khong co SetCameraField -- lenh -zoom vo hieu")
    return nil
  end
  local d = clampDist(dist)
  local t = secs or CFG.ZOOM_TIME or 0.0

  local forPlayer = _G["SetCameraFieldForPlayer"]
  if forPlayer ~= nil then
    forPlayer(Player(pid), CAMERA_FIELD_TARGET_DISTANCE, d, t)
    if CFG.ZOOM_FARZ ~= nil and CAMERA_FIELD_FARZ ~= nil then
      forPlayer(Player(pid), CAMERA_FIELD_FARZ, CFG.ZOOM_FARZ, t)
    end
  elseif GetLocalPlayer() == Player(pid) then
    -- Nhanh nay chi chay tren may cua chinh nguoi do. KHONG doi trang
    -- thai game nao nen khong lech ban.
    SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, d, t)
    if CFG.ZOOM_FARZ ~= nil and CAMERA_FIELD_FARZ ~= nil then
      SetCameraField(CAMERA_FIELD_FARZ, CFG.ZOOM_FARZ, t)
    end
  end

  if S.p[pid] ~= nil then S.p[pid].zoom = d end
  return d
end

-- "-zoom"      -> ve mac dinh
-- "-zoom 3000" -> dat 3000
--
-- Khong tham so KHONG phai la "khong lam gi": nguoi choi go "-zoom" khi
-- da zoom lung tung va muon ve cho cu. Do la cong dung chinh cua no.
local function onZoom(pid, text)
  local arg = (text or ""):match("%-zoom%s+([%d%.]+)")
  local want = tonumber(arg) or CFG.ZOOM_DEFAULT or 1650.0

  local got = setZoom(pid, want)
  if got == nil then return end

  API.msg(pid, CFG.C_JADE .. API.t("zoom_set", API.num(math.floor(got + 0.5)))
               .. CFG.C_END)
  -- Bao RO khi da bi chan, neu khong nguoi choi go 9000 thay 4500 roi
  -- tuong lenh hong.
  if math.abs(got - want) > 0.5 then
    API.msg(pid, CFG.C_GREY .. API.t("zoom_clamp",
      API.num(math.floor((CFG.ZOOM_MIN or 900.0) + 0.5)),
      API.num(math.floor((CFG.ZOOM_MAX or 4500.0) + 0.5))) .. CFG.C_END)
  end
end

local function startCamera()
  local t = CreateTrigger()
  for i = 1, #S.pids do
    -- false = khop TIEN TO, de "-zoom 3000" cung no. Voi true thi chi
    -- dung chuoi "-zoom" moi khop va lenh co tham so chet lang.
    TriggerRegisterPlayerChatEvent(t, Player(S.pids[i]), "-zoom", false)
  end
  TriggerAddAction(t, function()
    onZoom(GetPlayerId(GetTriggerPlayer()), GetEventPlayerChatString())
  end)
  S.zoomTrig = t

  -- AP NGAY cho moi nguoi, khong doi ai go lenh.
  --
  -- secs = 0: luc vao map ma cho camera TRUOT toi tam nhin moi thi
  -- nguoi choi thay man hinh tu dong lui ra, doc nhu loi. Nhay thang
  -- la dung -- chua ai kip nhin thi chua co gi de truot.
  local d = CFG.ZOOM_DEFAULT or 1650.0
  for i = 1, #S.pids do setZoom(S.pids[i], d, 0.0) end

  API.trace("camera: lenh -zoom san sang (mac dinh " ..
            (CFG.ZOOM_DEFAULT or 1650.0) .. ", chan " ..
            (CFG.ZOOM_MIN or 900.0) .. ".." .. (CFG.ZOOM_MAX or 4500.0) ..
            "), da ap cho " .. #S.pids .. " nguoi")
end

API.cameraZoom  = setZoom
API.startCamera = startCamera
