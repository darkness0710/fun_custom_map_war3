gg_rct_MyHouseRegion = nil
gg_rct_MyEmenyRegion = nil
gg_rct_HeroStartRegion = nil
gg_rct_HeroMoveRegion = nil
gg_rct_Quest1Lair = nil
gg_rct_Quest2Lair = nil
gg_rct_Quest3Lair = nil
gg_rct_Quest4Lair = nil
gg_rct_Quest1Gate = nil
gg_rct_Quest2Gate = nil
gg_rct_Quest3Gate = nil
gg_rct_Quest4Gate = nil
function InitGlobals()
end

function CreateRegions()
    local we
    gg_rct_MyHouseRegion = Rect(-11776.0, 12288.0, -11456.0, 12480.0)
    gg_rct_MyEmenyRegion = Rect(-11712.0, 5792.0, -11392.0, 6016.0)
    gg_rct_HeroStartRegion = Rect(-12544.0, -12416.0, -12320.0, -12192.0)
    gg_rct_HeroMoveRegion = Rect(-12576.0, -13248.0, -12256.0, -12960.0)
    gg_rct_Quest1Lair = Rect(-7744.0, 10208.0, -7264.0, 10496.0)
    gg_rct_Quest2Lair = Rect(-4160.0, 10208.0, -3616.0, 10496.0)
    gg_rct_Quest3Lair = Rect(-7744.0, 5568.0, -7200.0, 5856.0)
    gg_rct_Quest4Lair = Rect(-4064.0, 5600.0, -3584.0, 5856.0)
    gg_rct_Quest1Gate = Rect(-7744.0, 12352.0, -7264.0, 12640.0)
    gg_rct_Quest2Gate = Rect(-4160.0, 12320.0, -3616.0, 12608.0)
    gg_rct_Quest3Gate = Rect(-7840.0, 7776.0, -7296.0, 8064.0)
    gg_rct_Quest4Gate = Rect(-4192.0, 8000.0, -3712.0, 8256.0)
end

function InitCustomPlayerSlots()
    SetPlayerStartLocation(Player(0), 0)
    SetPlayerColor(Player(0), ConvertPlayerColor(0))
    SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
    SetPlayerRaceSelectable(Player(0), true)
    SetPlayerController(Player(0), MAP_CONTROL_USER)
    SetPlayerStartLocation(Player(1), 1)
    SetPlayerColor(Player(1), ConvertPlayerColor(1))
    SetPlayerRacePreference(Player(1), RACE_PREF_ORC)
    SetPlayerRaceSelectable(Player(1), true)
    SetPlayerController(Player(1), MAP_CONTROL_USER)
    SetPlayerStartLocation(Player(2), 2)
    SetPlayerColor(Player(2), ConvertPlayerColor(2))
    SetPlayerRacePreference(Player(2), RACE_PREF_UNDEAD)
    SetPlayerRaceSelectable(Player(2), true)
    SetPlayerController(Player(2), MAP_CONTROL_USER)
    SetPlayerStartLocation(Player(11), 3)
    SetPlayerColor(Player(11), ConvertPlayerColor(11))
    SetPlayerRacePreference(Player(11), RACE_PREF_NIGHTELF)
    SetPlayerRaceSelectable(Player(11), true)
    SetPlayerController(Player(11), MAP_CONTROL_COMPUTER)
end

function InitCustomTeams()
    SetPlayerTeam(Player(0), 0)
    SetPlayerTeam(Player(1), 0)
    SetPlayerTeam(Player(2), 0)
    SetPlayerTeam(Player(11), 0)
end

function InitAllyPriorities()
    SetStartLocPrioCount(0, 1)
    SetStartLocPrio(0, 0, 1, MAP_LOC_PRIO_HIGH)
    SetStartLocPrioCount(1, 2)
    SetStartLocPrio(1, 0, 0, MAP_LOC_PRIO_HIGH)
    SetStartLocPrio(1, 1, 2, MAP_LOC_PRIO_HIGH)
    SetStartLocPrioCount(2, 1)
    SetStartLocPrio(2, 0, 1, MAP_LOC_PRIO_HIGH)
    SetStartLocPrioCount(3, 4)
    SetStartLocPrio(3, 0, 0, MAP_LOC_PRIO_LOW)
    SetStartLocPrio(3, 1, 1, MAP_LOC_PRIO_LOW)
    SetStartLocPrio(3, 2, 2, MAP_LOC_PRIO_LOW)
end

function main()
    SetCameraBounds(-13568.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -13824.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 13568.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 13312.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -13568.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 13312.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 13568.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -13824.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
    NewSoundEnvironment("Default")
    SetAmbientDaySound("CityScapeDay")
    SetAmbientNightSound("CityScapeNight")
    SetMapMusic("Music", true, 0)
    CreateRegions()
    InitBlizzard()
    InitGlobals()
end

function config()
    SetMapName("TRIGSTR_001")
    SetMapDescription("TRIGSTR_003")
    SetPlayers(4)
    SetTeams(4)
    SetGamePlacement(MAP_PLACEMENT_TEAMS_TOGETHER)
    DefineStartLocation(0, -9792.0, 10176.0)
    DefineStartLocation(1, -6400.0, -128.0)
    DefineStartLocation(2, -3584.0, -10368.0)
    DefineStartLocation(3, 10688.0, -11264.0)
    InitCustomPlayerSlots()
    SetPlayerSlotAvailable(Player(0), MAP_CONTROL_USER)
    SetPlayerSlotAvailable(Player(1), MAP_CONTROL_USER)
    SetPlayerSlotAvailable(Player(2), MAP_CONTROL_USER)
    SetPlayerSlotAvailable(Player(11), MAP_CONTROL_COMPUTER)
    InitGenericPlayerSlots()
    InitAllyPriorities()
end

