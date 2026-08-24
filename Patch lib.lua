-- =======================================================================
-- BRPlayerCharacterBase - COMPLETE WORKING SCRIPT
-- WITH "ADD YOUR PATCH HERE" SECTION
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

    --[EXAMPLE 1] Simple patch
    -- PATCH_LIB("libanogs.so", 0x123456, "00 00 80 D2 C0 03 5F D6")

    --[EXAMPLE 2] Multiple patches
    -- PATCH_LIB("libUE4.so", 0xCB93C5, "00 00 80 D2 C0 03 5F D6")
    -- PATCH_LIB("libgcloud.so", 0x359BB0, "C0 03 5F D6")

    --[EXAMPLE 3] Different bytes
    -- PATCH_LIB("libanogs.so", 0x789ABC, "AE 93 93 3D")
    -- PATCH_LIB("libanogs.so", 0x789ABD, "AE 93 93 3D")

    -- ============================================================
    -- 🔥 YOUR PATCHES GO HERE 🔥
    -- ============================================================

    -- [[
    -- UNCOMMENT AND ADD YOUR PATCHES BELOW
    -- Copy your PATCH_LIB lines here

    -- EXAMPLE:
    PATCH_LIB("libanogs.so", 0x213360 + 0x8, "00 00 80 D2 C0 03 5F D6")  -- crash fix
    PATCH_LIB("libanogs.so", 0x3206F8, "00 00 80 D2 C0 03 5F D6")  -- CASE 15
    PATCH_LIB("libanogs.so", 0x3206FC, "00 00 80 D2 C0 03 5F D6")  -- CASE 16
    PATCH_LIB("libanogs.so", 0x320974, "00 00 80 D2 C0 03 5F D6")  -- CASE 23
    PATCH_LIB("libanogs.so", 0x37A3D0, "00 00 80 D2 C0 03 5F D6")  -- CASE 35
    PATCH_LIB("libanogs.so", 0x37A3D8, "00 00 80 D2 C0 03 5F D6")  -- CASE 37
    PATCH_LIB("libanogs.so", 0x50A638, "00 00 80 D2 C0 03 5F D6")  -- MALLOC
    PATCH_LIB("libanogs.so", 0x385628, "00 00 80 D2 C0 03 5F D6")  -- GETTIMEOFDAY
    PATCH_LIB("libanogs.so", 0x500DC0, "00 00 80 D2 C0 03 5F D6")  -- STRCMP
    PATCH_LIB("libanogs.so", 0x51E4BC, "00 00 80 D2 C0 03 5F D6")  -- CASE 30
    PATCH_LIB("libanogs.so", 0x4D4C94, "00 00 80 D2 C0 03 5F D6")  -- MONITOR
    PATCH_LIB("libanogs.so", 0x4D49E4, "00 00 80 D2 C0 03 5F D6")  -- COREREPORT
    PATCH_LIB("libanogs.so", 0x4DF4B4, "00 00 80 D2 C0 03 5F D6")  -- CMD
    PATCH_LIB("libanogs.so", 0x4642E4, "00 00 80 D2 C0 03 5F D6")  -- GETPID
    PATCH_LIB("libanogs.so", 0x37966C, "00 00 80 D2 C0 03 5F D6")  -- NAME=%S
    PATCH_LIB("libanogs.so", 0x4633F4, "00 00 80 D2 C0 03 5F D6")  -- STRSTR
    PATCH_LIB("libanogs.so", 0x46C2B4, "00 00 80 D2 C0 03 5F D6")  -- MUNMAP
    PATCH_LIB("libanogs.so", 0x4F7D84, "00 00 80 D2 C0 03 5F D6")  -- ANDROID LOG PRINT
    PATCH_LIB("libanogs.so", 0x37B4E0, "00 00 80 D2 C0 03 5F D6")  -- CLOSE
    PATCH_LIB("libanogs.so", 0x4D47D8, "00 00 80 D2 C0 03 5F D6")  -- TDM REPORT
    PATCH_LIB("libanogs.so", 0x4DF96C, "00 00 80 D2 C0 03 5F D6")  -- SOCKET
    PATCH_LIB("libanogs.so", 0x4D3E2C, "00 00 80 D2 C0 03 5F D6")  -- REPORT
    PATCH_LIB("libanogs.so", 0x1D081C, "00 00 80 D2 C0 03 5F D6")  -- REPORT COMPLAINT
    PATCH_LIB("libanogs.so", 0x32EBF8, "00 00 80 D2 C0 03 5F D6")  -- DLOPEN
    PATCH_LIB("libanogs.so", 0x43B62C, "00 00 80 D2 C0 03 5F D6")  -- MEMSET CHECK
    PATCH_LIB("libanogs.so", 0x505A44, "00 00 80 D2 C0 03 5F D6")  -- malloc
    PATCH_LIB("libanogs.so", 0x51C7A8, "00 00 80 D2 C0 03 5F D6")  -- 1DAY FIX
    PATCH_LIB("libanogs.so", 0x4E08B4, "00 00 80 D2 C0 03 5F D6")  -- 1DAY FIX
    PATCH_LIB("libanogs.so", 0x446738, "00 00 80 D2 C0 03 5F D6")  -- 1DAY FIX
    PATCH_LIB("libanogs.so", 0x2F2FDC, "00 00 80 D2 C0 03 5F D6")  -- 1DAY FIX
    PATCH_LIB("libanogs.so", 0x2F221C, "00 00 80 D2 C0 03 5F D6")  -- 1DAY FIX
    PATCH_LIB("libanogs.so", 0x51EE78, "00 00 80 D2 C0 03 5F D6")  -- 1DAY FIX
    PATCH_LIB("libanogs.so", 0x466F6C, "00 00 80 D2 C0 03 5F D6")  -- 1DAY FIX
    PATCH_LIB("libanogs.so", 0x2FF5A0, "00 00 80 D2 C0 03 5F D6")  -- 1DAY FIX
    PATCH_LIB("libanogs.so", 0x36A5B8, "00 00 80 D2 C0 03 5F D6")  -- 1DAY FIX
    PATCH_LIB("libanogs.so", 0x382140, "00 00 80 D2 C0 03 5F D6")  -- 1DAY FIX
    PATCH_LIB("libanogs.so", 0x26C260, "00 00 80 D2 C0 03 5F D6")  -- 1DAY FIX
    PATCH_LIB("libanogs.so", 0x447750, "00 00 80 D2 C0 03 5F D6")  -- 1DAY FIX
    PATCH_LIB("libanogs.so", 0x4E0810, "00 00 80 D2 C0 03 5F D6")  -- 1DAY FIX
    PATCH_LIB("libanogs.so", 0x373D60, "00 00 80 D2 C0 03 5F D6")  -- 1DAY FIX
    PATCH_LIB("libanogs.so", 0x44F080, "00 00 80 D2 C0 03 5F D6")  -- 1DAY FIX
    PATCH_LIB("libanogs.so", 0x3792CC, "00 00 80 D2 C0 03 5F D6")  -- 1DAY FIX

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
