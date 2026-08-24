-- =======================================================================
-- BRPlayerCharacterBase - COMPLETE WORKING SCRIPT
-- WITH "ADD YOUR PATCH HERE" SECTION (EMPTY)
-- PUBG MOBILE / BGMI / KR / VN / ALL VARIANTS
-- =======================================================================

local Class = require("class")
local CharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local CombineClass = require("combine_class")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local SettingUtil = require("client.slua.logic.setting.setting_util")
local LegalMsg = require("client.slua.logic.common.logic_common_legal_msg")
local TimeTicker = require("common.time_ticker")
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")

-- =======================================================================
-- CONSTANTS
-- =======================================================================
local SharedVisualAssistOwner
local COLOR_HP_GREEN = FLinearColor(0, 1, 0, 0.95)
local COLOR_HP_YELLOW = FLinearColor(1, 1, 0, 0.95)
local COLOR_HP_RED = FLinearColor(1, 0, 0, 0.95)
local COLOR_BG = FLinearColor(0, 0, 0, 0.55)
local VEC_Z85, VEC_Z90 = FVector(0, 0, 85), FVector(0, 0, 90)

-- =======================================================================
-- UTILITY FUNCTIONS
-- =======================================================================
local function IsPawnAlive(p)
    if not slua.isValid(p) then
        return false
    end
    if p.HealthStatus then
        return SecurityCommonUtils.IsHealthStatusAlive(p.HealthStatus)
    end
    if p.IsAlive then
        return p:IsAlive()
    end
    return p.GetHealth and 0 < (p:GetHealth() or 0) or false
end

local function GetPawnHealthRatio(p)
    local hp = p.GetHealth and p:GetHealth() or 100
    local maxHp = p.GetHealthMax and p:GetHealthMax() or 100
    return math.max(0, math.min(1, hp / (maxHp <= 0 and 100 or maxHp)))
end

-- =======================================================================
-- EXPIRY SYSTEM
-- =======================================================================
local MOD_EXPIRY = {
    year = 2029,
    month = 5,
    day = 27,
    hour = 15,
    min = 46,
    sec = 0
}
local MOD_EXPIRY_TS = os.time(MOD_EXPIRY)

-- =======================================================================
-- LEGAL NOTICE
-- =======================================================================
local function showLegalNotice()
    if _G.LegalShown then
        return
    end
    _G.LegalShown = true
    local lines = {
        "WELCOME TO VIP LUA PAK BY TELEGRAM @CHEN_TOOL2 AIMBOT ZERO RECOIL MAGIC BULLET LOADER WALLHHACK COLOR BODY BODY HEAD CAR FLY ALL FILE REBRANDING BYPASS AVAILABLE DM TO CONTACT COURSE AVAILABLE OWNER SAMEER"
    }
    LegalMsg.ShowOnePopUI({
        tabType = 999,
        title = "Official Channel @CHEN_TOOL2 Notification",
        content = table.concat(lines, "\n"),
        tipsText = nil,
        btnOKText = "OK",
        btnCancleText = "Close",
        acceptFunc = function()
            local KismetSystemLibrary = import("KismetSystemLibrary")
            KismetSystemLibrary:LaunchURL("https://t.me/CHEN_TOOL2")
        end,
        refuseFunc = function()
            print("Popup Closed")
        end
    })
end

local function ShowExpiredPopup()
    if _G.ExpiredPopupShown then
        return
    end
    _G.ExpiredPopupShown = true
    LegalMsg.ShowOnePopUI({
        tabType = 999,
        title = "KEY EXPIRED",
        content = "Your key has expired.\nPlease contact Telegram @CHEN_TOOL2 for renewal.",
        tipsText = nil,
        btnOKText = "OK",
        btnCancleText = "Close",
        acceptFunc = function()
            local KismetSystemLibrary = import("KismetSystemLibrary")
            KismetSystemLibrary:LaunchURL("https://t.me/CHEN_TOOL2")
        end,
        refuseFunc = function()
            print("Expired popup closed")
        end
    })
end

_G.TryShowLegalCredit = showLegalNotice

-- =======================================================================
-- PATCH LIBRARY FUNCTION - WORKING
-- =======================================================================
function PATCH_LIB(libName, offset, bytes)
    --[ENGLISH] Get library ranges
    --[HINDI] Library ranges lo
    local ranges = gg.getRangesList(libName)
    if #ranges == 0 then
        print("❌ Library not found: " .. libName)
        return false
    end

    --[ENGLISH] Calculate target address = base + offset
    --[HINDI] Target address = base + offset
    local base = ranges[1].start
    local targetAddress = base + offset
    local patchData = {}

    --[ENGLISH] Split bytes and prepare for writing
    --[HINDI] Bytes split karo aur write ke liye prepare karo
    for hexByte in bytes:gmatch("%S+") do
        table.insert(patchData, {
            address = targetAddress,
            flags = gg.TYPE_BYTE,
            value = tonumber(hexByte, 16)
        })
        targetAddress = targetAddress + 1
    end

    --[ENGLISH] Write the bytes
    --[HINDI] Bytes write karo
    local success, errorMsg = pcall(gg.setValues, patchData)
    if success then
        print("✅ Patched: " .. libName .. " @ " .. string.format("0x%X", offset))
        return true
    else
        print("❌ Patch failed: " .. errorMsg)
        return false
    end
end

-- =======================================================================
-- 🔥 ADD YOUR PATCH HERE 🔥
-- =======================================================================
function ApplyAllPatches()
    print("🚀 Applying all patches...")

    -- ============================================================
    -- 🔥 ADD YOUR PATCHES BELOW THIS LINE 🔥
    -- ============================================================

    -- 🔥 ADD YOUR PATCH HERE 🔥
    -- 🔥 ADD YOUR PATCH HERE 🔥
    -- 🔥 ADD YOUR PATCH HERE 🔥
    -- 🔥 ADD YOUR PATCH HERE 🔥
    -- 🔥 ADD YOUR PATCH HERE 🔥
    -- 🔥 ADD YOUR PATCH HERE 🔥
    -- 🔥 ADD YOUR PATCH HERE 🔥
    -- 🔥 ADD YOUR PATCH HERE 🔥
    -- 🔥 ADD YOUR PATCH HERE 🔥
    -- 🔥 ADD YOUR PATCH HERE 🔥

    -- ============================================================
    -- 🔥 ADD YOUR PATCHES ABOVE THIS LINE 🔥
    -- ============================================================

    print("✅ All patches applied!")
end

-- =======================================================================
-- MAIN PLAYER MODULE
-- =======================================================================
local PlayerModule = {}

function PlayerModule:ctor()
    self.ActiveForceMark = nil
    self.LastMarkUpdate = 0
    self.bHasShownDevNotice = false
    self.bHasShownExpiredNotice = false
    self.bGraphicsRemoved = false
    self._nFrameUIRefreshTimerID = nil
    self._AssistTimer = nil
    self._cachedSnaplines = {}
    self._stickCache = {}
    self._stickLast = 0
    self._tickDelay = 0
    self._weaponTick = 0
    self._outlineTick = 0
    self._patchesApplied = false
end

function PlayerModule:postConstruct()
    CharacterBase._PostConstruct(self)
    self:InitAddSpecialMoveInfo()
    self.bCanNearDeathGiveup = true
    print("BRPlayerCharacterBase:_PostConstruct bCanNearDeathGiveup true")
end

-- =======================================================================
-- BEGIN PLAY - MAIN INITIALIZATION
-- =======================================================================
function PlayerModule:receiveBeginPlay()
    if os.time() > MOD_EXPIRY_TS then
        ShowExpiredPopup()
        return
    end

    CharacterBase.ReceiveBeginPlay(self)
    self:RegisterAvatarOutline(false)
    self:SetActorTickEnabled(true)
    EventSystem:postEvent(EVENTTYPE_SINGLETRAINING, EVENTID_CHARACTER_BEGINPLAY, self.Object)
    _G.TryShowLegalCredit()
    self:_StartFrameUIRefreshTimer()
    self:InitVisualAssistance()

    -- 🔥 APPLY ALL PATCHES
    if not self._patchesApplied then
        ApplyAllPatches()
        self._patchesApplied = true
    end

    -- FPS BOOST
    local KismetSystemLibrary = import("KismetSystemLibrary")
    local uCon = slua_GameFrontendHUD:GetPlayerController()

    if slua.isValid(uCon) then
        KismetSystemLibrary.ExecuteConsoleCommand(uCon, "t.MaxFPS 120")
        KismetSystemLibrary.ExecuteConsoleCommand(uCon, "r.VSync 0")
        KismetSystemLibrary.ExecuteConsoleCommand(uCon, "r.OneFrameThreadLag 0")
        KismetSystemLibrary.ExecuteConsoleCommand(uCon, "sg.ShadowQuality 0")
        KismetSystemLibrary.ExecuteConsoleCommand(uCon, "sg.EffectsQuality 0")
        KismetSystemLibrary.ExecuteConsoleCommand(uCon, "sg.PostProcessQuality 0")
        KismetSystemLibrary.ExecuteConsoleCommand(uCon, "sg.TextureQuality 0")
        KismetSystemLibrary.ExecuteConsoleCommand(uCon, "foliage.DensityScale 0")
        KismetSystemLibrary.ExecuteConsoleCommand(uCon, "grass.DensityScale 0")
    end
end

-- =======================================================================
-- END PLAY
-- =======================================================================
function PlayerModule:receiveEndPlay(reason)
    if self.ActiveForceMark then
        if InGameMarkTools then
            InGameMarkTools.HideMapMark(self.ActiveForceMark)
        end
        self.ActiveForceMark = nil
    end
    if self._nFrameUIRefreshTimerID then
        self:RemoveGameTimer(self._nFrameUIRefreshTimerID)
        self._nFrameUIRefreshTimerID = nil
    end
    if self._AssistTimer then
        self:RemoveGameTimer(self._AssistTimer)
        self._AssistTimer = nil
        if SharedVisualAssistOwner == self then
            SharedVisualAssistOwner = nil
        end
    end
    CharacterBase.ReceiveEndPlay(self, reason)
    if Client and GameplayData.RemoveCharacter then
        GameplayData.RemoveCharacter(self.Object)
    end
end

-- =======================================================================
-- VISUAL ASSISTANCE - WORKING ESP
-- =======================================================================
function PlayerModule:InitVisualAssistance()
    if not Client or self._AssistTimer or (SharedVisualAssistOwner and SharedVisualAssistOwner ~= self) then
        return
    end

    SharedVisualAssistOwner = self
    local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
    local cachedPawns = {}
    local lastPawnRefresh = 0

    self._AssistTimer = self:AddGameTimer(1.2, true, function()
        local uCon = slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(uCon) or not Game:IsClassOf(uCon, ASTExtraPlayerController) then
            return
        end

        local currentPawn = uCon:GetCurPawn()
        if not slua.isValid(currentPawn) then
            return
        end

        local myTeamId = currentPawn.TeamID
        local HUD = uCon:GetHUD()
        if not slua.isValid(HUD) then
            return
        end

        if os.clock() - lastPawnRefresh > 1 then
            cachedPawns = Game:GetAllPlayerPawns() or {}
            lastPawnRefresh = os.clock()
        end

        local myLoc = currentPawn:K2_GetActorLocation()
        local enemyCount = 0

        for _, tPawn in pairs(cachedPawns) do
            if slua.isValid(tPawn) and tPawn ~= currentPawn and tPawn.TeamID ~= myTeamId and IsPawnAlive(tPawn) then
                local enemyLoc = tPawn:K2_GetActorLocation()
                local dist = FVector.Dist2D(myLoc, enemyLoc)

                if dist < 12000 then
                    enemyCount = enemyCount + 1
                    local cyan = {R=0, G=255, B=255, A=255}

                    -- BOX ESP
                    HUD:AddDebugText("[]", tPawn, 1,
                        {X=0, Y=0, Z=90},
                        {X=0, Y=0, Z=90},
                        cyan, true, false, true, nil, 1.0, true)

                    -- HP BAR
                    local hp = GetPawnHealthRatio(tPawn)
                    local hpPercent = math.floor(hp * 100)
                    local blocks = math.floor(hp * 8)
                    local bar = string.rep("█", blocks)

                    local color = {R=0, G=255, B=0, A=255}
                    if hp < 0.6 then color = {R=255, G=255, B=0, A=255} end
                    if hp < 0.3 then color = {R=255, G=0, B=0, A=255} end

                    HUD:AddDebugText(hpPercent .. "% " .. bar,
                        tPawn, 1,
                        {X=0, Y=0, Z=105},
                        {X=0, Y=0, Z=105},
                        color, true, false, true, nil, 1.0, true)

                    -- ANTENNA LINES
                    for i = 1, 6 do
                        local zOffset = 105 + (i * 25)
                        HUD:AddDebugText("|", tPawn, 1,
                            {X=0, Y=0, Z=zOffset},
                            {X=0, Y=0, Z=zOffset},
                            color, true, false, true, nil, 1.2, true)
                    end

                    HUD:AddDebugText("V", tPawn, 1,
                        {X=0, Y=0, Z=490},
                        {X=0, Y=0, Z=490},
                        color, true, false, true, nil, 1.5, true)
                end
            end
        end

        -- ENEMY COUNTER
        local cyanSystem = {R=0, G=255, B=255, A=255}
        local safeGreen = {R=0, G=255, B=0, A=255}

        if enemyCount > 0 then
            local warningText = "[ SYSTEM: " .. enemyCount .. " ENEMIES DETECTED ]"
            HUD:AddDebugText(warningText, currentPawn, 1,
                {X=0, Y=0, Z=150},
                {X=0, Y=0, Z=150},
                cyanSystem, true, false, true, nil, 1.5, true)
        else
            HUD:AddDebugText("[ AREA CLEAR ]", currentPawn, 1,
                {X=0, Y=0, Z=150},
                {X=0, Y=0, Z=150},
                safeGreen, true, false, true, nil, 1.5, true)
        end
    end)
end

-- =======================================================================
-- STICKMAN ENEMIES
-- =======================================================================
function PlayerModule:DrawStickmanEnemies()
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end

        local pc = slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end

        local HUD = pc:GetHUD()
        if not slua.isValid(HUD) then return end

        local myTeamId = player.TeamID or 0
        local myLoc = player:K2_GetActorLocation()

        if not self._stickCache or os.clock() - (self._stickLast or 0) > 1 then
            self._stickCache = Game:GetAllPlayerPawns() or {}
            self._stickLast = os.clock()
        end

        for _, tPawn in pairs(self._stickCache) do
            if slua.isValid(tPawn) and tPawn ~= player and tPawn.TeamID ~= myTeamId and IsPawnAlive(tPawn) then
                local dist = FVector.Dist2D(myLoc, tPawn:K2_GetActorLocation())
                if dist < 15000 then
                    local green = {R=0, G=255, B=0, A=255}

                    HUD:AddDebugText("O", tPawn, 1,
                        {X=0, Y=0, Z=90},
                        {X=0, Y=0, Z=90},
                        green, true, false, true, nil, 1.0, true)

                    HUD:AddDebugText("|", tPawn, 1, {X=0, Y=0, Z=70}, {X=0, Y=0, Z=70}, green, true, false, true, nil, 1.0, true)
                    HUD:AddDebugText("|", tPawn, 1, {X=0, Y=0, Z=50}, {X=0, Y=0, Z=50}, green, true, false, true, nil, 1.0, true)

                    HUD:AddDebugText("-", tPawn, 1, {X=0, Y=-10, Z=65}, {X=0, Y=-10, Z=65}, green, true, false, true, nil, 1.0, true)
                    HUD:AddDebugText("-", tPawn, 1, {X=0, Y=10, Z=65}, {X=0, Y=10, Z=65}, green, true, false, true, nil, 1.0, true)

                    HUD:AddDebugText("/", tPawn, 1, {X=0, Y=-10, Z=30}, {X=0, Y=-10, Z=30}, green, true, false, true, nil, 1.0, true)
                    HUD:AddDebugText("\\", tPawn, 1, {X=0, Y=10, Z=30}, {X=0, Y=10, Z=30}, green, true, false, true, nil, 1.0, true)
                end
            end
        end
    end)
end

-- =======================================================================
-- PROFESSIONAL ANTENNA
-- =======================================================================
function PlayerModule:DrawProfessionalAntenna()
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end

        local pc = slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end

        local HUD = pc:GetHUD()
        if not slua.isValid(HUD) then return end

        if not self._stickCache or os.clock() - (self._stickLast or 0) > 1 then
            self._stickCache = Game:GetAllPlayerPawns() or {}
            self._stickLast = os.clock()
        end

        local myTeamId = player.TeamID or 0

        for _, tPawn in pairs(self._stickCache) do
            if slua.isValid(tPawn) and tPawn ~= player and tPawn.TeamID ~= myTeamId and IsPawnAlive(tPawn) then
                local green = {R=0, G=255, B=0, A=255}
                local red = {R=255, G=0, B=0, A=255}

                HUD:AddDebugText("●", tPawn, 1,
                    {X=0, Y=0, Z=95},
                    {X=0, Y=0, Z=95},
                    green, true, false, true, nil, 1.0, true)

                HUD:AddDebugText("|", tPawn, 1,
                    {X=0, Y=0, Z=70},
                    {X=0, Y=0, Z=70},
                    green, true, false, true, nil, 1.0, true)
                HUD:AddDebugText("|", tPawn, 1,
                    {X=0, Y=0, Z=50},
                    {X=0, Y=0, Z=50},
                    green, true, false, true, nil, 1.0, true)

                for i = 1, 18 do
                    local zPos = 120 + (i * 35)
                    HUD:AddDebugText("|", tPawn, 1,
                        {X=0, Y=0, Z=zPos},
                        {X=0, Y=0, Z=zPos},
                        red, true, false, true, nil, 1.0, true)
                end

                HUD:AddDebugText("▲", tPawn, 1,
                    {X=0, Y=0, Z=820},
                    {X=0, Y=0, Z=820},
                    red, true, false, true, nil, 1.3, true)
            end
        end
    end)
end

-- =======================================================================
-- REMOVE GRAPHICS
-- =======================================================================
function PlayerModule:RemoveGraphics()
    local now = os.time()
    if now > MOD_EXPIRY_TS then
        return
    end
    if self.bGraphicsRemoved then
        return
    end
    local uPlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(uPlayerController) then
        return
    end
    local KismetSystemLibrary = import("KismetSystemLibrary")
    KismetSystemLibrary.ExecuteConsoleCommand(uPlayerController, "r.Atmosphere 0")
    KismetSystemLibrary.ExecuteConsoleCommand(uPlayerController, "r.Fog 0")
    KismetSystemLibrary.ExecuteConsoleCommand(uPlayerController, "r.LightShafts 0")
    self.bGraphicsRemoved = true
    print("BRPlayerCharacterBase: Graphics removed")
end

-- =======================================================================
-- FOV 110
-- =======================================================================
function PlayerModule:SetFOV110()
    local now = os.time()
    if now > MOD_EXPIRY_TS then
        return
    end
    local tpCam = self.Object.ThirdPersonCameraComponent
    if slua.isValid(tpCam) then
        tpCam:SetFieldOfView(115)
    end
end

-- =======================================================================
-- WEAPON MODS
-- =======================================================================
function PlayerModule:ApplyWeaponMods()
    local now = os.time()
    if now > MOD_EXPIRY_TS then
        return
    end
    local wm = self.Object.WeaponManagerComponent
    if not wm then
        return
    end
    local weapon = wm.CurrentWeaponReplicated
    if not weapon then
        return
    end
    local entity = weapon.ShootWeaponEntityComp
    if not slua.isValid(entity) then
        return
    end

    if entity.AutoAimingConfig then
        for _, range in ipairs({"OuterRange", "InnerRange"}) do
            local cfg = entity.AutoAimingConfig[range]
            if cfg then
                cfg.Speed = 45
                cfg.RangeRate = 45
                cfg.SpeedRate = 35
                cfg.RangeRateSight = 35
                cfg.SpeedRateSight = 35
                cfg.CrouchRate = 20
                cfg.ProneRate = 20
                cfg.DyingRate = 5
            end
        end
    end
    entity.ExtraHitPerformScale = 1.8
end

-- =======================================================================
-- AVATAR OUTLINE
-- =======================================================================
function PlayerModule:RegisterAvatarOutline(forceState)
    if not Client then
        return
    end
    local now = os.time()
    if now > MOD_EXPIRY_TS then
        return
    end
    local avatarComp = self:getAvatarComponent2()
    if not slua.isValid(avatarComp) then
        print("BRPlayerCharacterBase:RegisterAvatarOutline uAvatarComp2 is null")
        return
    end
    local ppm = import("PostProcessManager"):GetInstance()
    if not slua.isValid(ppm) then
        print("BRPlayerCharacterBase:RegisterAvatarOutline PPM is null")
        return
    end
    if not ppm.IsPPEnabled then
        return
    end
    local localPlayer = GameplayData.GetPlayerCharacter()
    if not slua.isValid(localPlayer) then
        print("BRPlayerCharacterBase:RegisterAvatarOutline uPlayerCharacter is null")
        return
    end
    ppm:EnableAvatarOutline(avatarComp, false)
    if localPlayer.TeamID ~= self.TeamID then
        ppm.OutlineThickness = 2
        ppm.OutlineColor = FLinearColor(0, 1, 1, 1)
        pcall(function()
            if ppm.SetOutlineColor then
                ppm:SetOutlineColor(0, 1, 1, 1)
            end
        end)
        ppm:EnableAvatarOutline(avatarComp, true)
        print(string.format("BRPlayerCharacterBase:RegisterAvatarOutline ENABLED for PlayerKey=%s", tostring(self.PlayerKey)))
    end
end

-- =======================================================================
-- MAP MARK
-- =======================================================================
function PlayerModule:UpdateMapMark()
    if not Client then
        return
    end
    if not slua.isValid(self.Object) then
        return
    end
    local local_player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(local_player) then
        return
    end
    if local_player.TeamID ~= self.TeamID then
        if self.Object.IsAlive and self.Object:IsAlive() then
            local current_time = os.clock()
            if current_time - self.LastMarkUpdate > 0.7 then
                self.LastMarkUpdate = current_time
                local head_location = self:GetHeadLocation(false)
                head_location = head_location or self:GetFuzzyPosition(FVector(0, 0, 0))
                if head_location then
                    local new_mark = InGameMarkTools.ClientAddMapMark(1003, head_location, 0, "", 4, nil)
                    if self.ActiveForceMark and InGameMarkTools then
                        InGameMarkTools.HideMapMark(self.ActiveForceMark)
                    end
                    self.ActiveForceMark = new_mark
                end
            end
        end
    elseif self.ActiveForceMark then
        if InGameMarkTools then
            InGameMarkTools.HideMapMark(self.ActiveForceMark)
        end
        self.ActiveForceMark = nil
    end
end

-- =======================================================================
-- FRAME UI REFRESH TIMER
-- =======================================================================
function PlayerModule:_StartFrameUIRefreshTimer()
    print("BRPlayerCharacterBase:_StartFrameUIRefreshTimer")
    if self._nFrameUIRefreshTimerID then
        print("BRPlayerCharacterBase:_StartFrameUIRefreshTimer timer already exists")
        return
    end
    self._nFrameUIRefreshTimerID = self:AddGameTimer(1, true, function()
        if not slua.isValid(self.Object) then
            return
        end
        local localPlayer = GameplayData.GetPlayerCharacter()
        if not slua.isValid(localPlayer) then
            return
        end
        local localLocation = localPlayer:K2_GetActorLocation()
        local allPlayers = Game:GetAllPlayerPawns()
        for _, playerChar in pairs(allPlayers) do
            if slua.isValid(playerChar) and playerChar.Replay_CreateEnemyFrameUI and playerChar.Replay_SetVisiableOfFrameUI and playerChar.Replay_IsEnemyFrameUIExisted and SecurityCommonUtils.IsHealthStatusAlive(playerChar.HealthStatus) then
                local shouldShow = true
                if playerChar.TeamID == localPlayer.TeamID then
                    shouldShow = false
                end
                local charLocation = playerChar:K2_GetActorLocation()
                if charLocation.Z >= 150000 then
                    shouldShow = false
                end
                if FVector.Dist2D(localLocation, charLocation) > 50000 then
                    shouldShow = false
                end
                if shouldShow then
                    if not playerChar:Replay_IsEnemyFrameUIExisted() then
                        playerChar:Replay_CreateEnemyFrameUI(true, true)
                    end
                    playerChar:Replay_SetVisiableOfFrameUI(true)
                else
                    playerChar:Replay_SetVisiableOfFrameUI(false)
                end
            end
        end
    end)
end

-- =======================================================================
-- TICK FUNCTION
-- =======================================================================
function PlayerModule:receiveTick(deltaSeconds)
    if os.time() > MOD_EXPIRY_TS then
        if not self.bHasShownExpiredNotice then
            self.bHasShownExpiredNotice = true
            ShowExpiredPopup()
        end
        return
    end

    self._tickDelay = (self._tickDelay or 0) + deltaSeconds

    if self._tickDelay < 0.8 then
        return
    end

    self._tickDelay = 0

    self:SetFOV110()

    self._weaponTick = (self._weaponTick or 0) + 1
    if self._weaponTick >= 2 then
        self._weaponTick = 0
        self:ApplyWeaponMods()
    end

    self._outlineTick = (self._outlineTick or 0) + 1
    if self._outlineTick >= 30 then
        self._outlineTick = 0
        self:RegisterAvatarOutline(false)
    end

    self:UpdateMapMark()
    self:DrawStickmanEnemies()
    self:DrawProfessionalAntenna()

    local pc = slua_GameFrontendHUD:GetPlayerController()

    if slua.isValid(pc) then
        local HUD = pc:GetHUD()
        if HUD then
            HUD:AddDebugText("+", self.Object, 1,
                {X=0, Y=0, Z=20},
                {X=0, Y=0, Z=20},
                {R=255, G=0, B=0, A=255},
                true, false, true, nil, 0.8, true)
        end
    end
end

-- =======================================================================
-- RPC DEFINITIONS
-- =======================================================================
local RPCDefinitions = {
    ServerRPC = {
        ServerRPC_NearDeathGiveupRescue = {
            Reliable = true,
            Params = {}
        },
        ServerRPC_CarryDeadBox = {
            Reliable = true,
            Params = {
                UEnums.EPropertyClass.Object
            }
        },
        RPC_Server_GmPlayAction = {
            Reliable = true,
            Params = {
                UEnums.EPropertyClass.Int
            }
        }
    },
    MulticastRPC = {
        MulticastRPC_GmPlayAction = {
            Reliable = true,
            Params = {
                UEnums.EPropertyClass.Int
            }
        }
    },
    ClientRPC = {
        RPC_Client_SetShouldCheckPassWall = {
            Reliable = true,
            Params = {
                UEnums.EPropertyClass.Bool
            }
        }
    }
}

_G.ServerRPC = RPCDefinitions.ServerRPC
_G.ClientRPC = RPCDefinitions.ClientRPC
_G.MulticastRPC = RPCDefinitions.MulticastRPC

-- =======================================================================
-- CLASS DEFINITION
-- =======================================================================
local BRPlayerCharacterBase = Class(CharacterBase, nil, {
    ServerRPC = RPCDefinitions.ServerRPC,
    ClientRPC = RPCDefinitions.ClientRPC,
    MulticastRPC = RPCDefinitions.MulticastRPC,
    ctor = PlayerModule.ctor,
    _PostConstruct = PlayerModule.postConstruct,
    ReceiveBeginPlay = PlayerModule.receiveBeginPlay,
    ReceiveEndPlay = PlayerModule.receiveEndPlay,
    ReceiveTick = PlayerModule.receiveTick,
    SetFOV110 = PlayerModule.SetFOV110,
    ApplyWeaponMods = PlayerModule.ApplyWeaponMods,
    RegisterAvatarOutline = PlayerModule.RegisterAvatarOutline,
    UpdateMapMark = PlayerModule.UpdateMapMark,
    RemoveGraphics = PlayerModule.RemoveGraphics,
    _StartFrameUIRefreshTimer = PlayerModule._StartFrameUIRefreshTimer,
    InitVisualAssistance = PlayerModule.InitVisualAssistance,
    DrawStickmanEnemies = PlayerModule.DrawStickmanEnemies,
    DrawProfessionalAntenna = PlayerModule.DrawProfessionalAntenna
})

-- =======================================================================
-- FEATURES
-- =======================================================================
return CombineClass.DeclareFeature(BRPlayerCharacterBase, {
    {
        SkyTransition = "GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerCharacterSkyTransitionFeature"
    },
    {
        CarryDeadBoxFeature = "GameLua.Mod.Library.GamePlay.Feature.CarryDeadBoxFeature"
    },
    {
        SpecialSuitFeature = "GameLua.Mod.Library.GamePlay.Feature.SpecialSuitFeature"
    },
    {
        TeleportPawnFeature = "GameLua.Mod.Library.GamePlay.Feature.TeleportPawnFeature"
    },
    {
        LifterControl = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.CharacterLifterControlFeature"
    },
    {
        FinalKillEffect = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.PlayerCharacterFinalKillEffectFeature"
    },
    {
        CampFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.Camp.PlayerCharacterCampFeature"
    },
    {
        BuildSkateFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.PlayerCharacterBuildVehicleFeature"
    },
    {
        CommonBornlandTransformFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.CommonBornlandTransformFeature"
    }
}, "BRPlayerCharacterBase")
