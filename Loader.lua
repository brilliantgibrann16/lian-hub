--[[
    ═════════════════════════════════════════════════════════════════════════
    ⚡ LIAN HUB — 100% KEYLESS ANIME DICE MASTER EXPLOIT SUITE v7.1 (Senior Verified) ⚡
    Author : Lian (@brilliantgibrann16)
    Target : Anime Dice (PlaceId: 113290951185459 / Universe: 10708913337)
    ═════════════════════════════════════════════════════════════════════════
    [CHANGELOG v7.0 TOTAL REBUILD EDITION]:
    ★ Anti-Loop-Inject & Singleton Guard:
      - Cooldown + Generation token (_G.__LianHubGen) stops all old worker threads.
      - Full cleanup of old Rayfield / LianHub ScreenGuis in gethui/CoreGui/PlayerGui.
      - Neutralizes Anime Dice's built-in 18-minute PlayerScripts.AFK self-teleport loop!
      - Per-JobId queue_on_teleport guard (queues at most ONCE per server, zero stacking).
    ★ 100% Verified Anime Dice Remotes & Framework Modules (v803/v809+):
      - Rolling.RF.RollDice + Rolling.RE.StartRoll + Rolling.RE.SetAutoRoll
      - DiceService.RE.BuyDice(diceName) + DiceService.RE.EquipDice(diceName)
      - PlotService.RE.Collect(tostring(slot)) + EquipBest + EquipUnit
      - UnitService.RE.LevelUp(unitUUID) + SellUnits(uuidList) + ToggleLock(unitUUID)
      - Network.RE.BuyUpgrade(nodeName) with TreeStructure parent resolution
      - RebirthService.RF.Rebirth + RebirthService.RE.AddStat(Income/Luck/RollSpeed/WalkSpeed)
      - Towers.RF.PlayTower + CompleteTowerFloor loop + CancelTower recovery + EquipBestTowerTeam
      - GradeService / TraitService / QuirkService Roll(unitUUID) + SetProtected
      - QuestService.RE.Claim(period, questId, expiresAt) + CodesConfig live code reader
      - TrickOrTreat.Doors ProximityPrompt bypass + PumpkinDiceService.RF.Roll
    ═════════════════════════════════════════════════════════════════════════
]]--

-- 0. SINGLETON GUARD, COOLDOWN & PREVIOUS INSTANCE TEARDOWN (Prevents UI Stacking & Crash)
local _ENV = (type(getgenv) == "function" and getgenv()) or _G
local _nowClock = os.clock()
local _curJobId = tostring(game.JobId or "")

if _ENV.__LianHubExecuting and (_nowClock - (_ENV.__LianHubLastExec or 0) < 15) then
    warn("[Lian Hub] Execution already in progress, skipping duplicate call.")
    return
end
if _ENV.__LianHubLastExec and (_nowClock - _ENV.__LianHubLastExec < 2.5) and _ENV.__LianHubLastJob == _curJobId then
    warn("[Lian Hub] Duplicate inject detected within 2.5s on same server — ignored to prevent UI stacking.")
    return
end
_ENV.__LianHubExecuting = true
_ENV.__LianHubLastExec = _nowClock
_ENV.__LianHubLastJob = _curJobId

-- Increment generation token so all previous worker loops immediately terminate
_ENV.__LianHubGen = (tonumber(_ENV.__LianHubGen) or 0) + 1
local MY_GEN = _ENV.__LianHubGen
_G.__LianHubGen = MY_GEN

if type(_ENV.__LianHubCleanup) == "function" then
    pcall(_ENV.__LianHubCleanup)
end

local _activeThreads = {}
local _activeConns = {}

local function trackThread(th)
    table.insert(_activeThreads, th)
    return th
end

local function trackConn(conn)
    if conn then
        table.insert(_activeConns, conn)
    end
    return conn
end

local function isAlive()
    return _ENV.__LianHubGen == MY_GEN
end

-- Solara/Xeno-compatible timeout load check
local _loadT = os.clock()
while not game:IsLoaded() and os.clock() - _loadT < 15 do
    task.wait(0.2)
end

-- Services
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    local _plrT = os.clock()
    while not Players.LocalPlayer and os.clock() - _plrT < 10 do
        task.wait(0.2)
    end
    LocalPlayer = Players.LocalPlayer
end

local VirtualInputManager = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)

-- Clean up any existing Rayfield / LianHub GUI before creating a new one
local function destroyOldGuis()
    if _ENV.__LianHubRayfield and type(_ENV.__LianHubRayfield.Destroy) == "function" then
        pcall(function() _ENV.__LianHubRayfield:Destroy() end)
        _ENV.__LianHubRayfield = nil
    end
    local containers = {}
    if type(gethui) == "function" then
        local ok, h = pcall(gethui)
        if ok and h then table.insert(containers, h) end
    end
    local okCore, core = pcall(function() return game:GetService("CoreGui") end)
    if okCore and core then table.insert(containers, core) end
    if LocalPlayer then
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then table.insert(containers, pg) end
    end
    for _, parent in ipairs(containers) do
        pcall(function()
            for _, child in ipairs(parent:GetChildren()) do
                if child:IsA("ScreenGui") then
                    local n = child.Name
                    if n == "Rayfield" or n == "RayfieldLoader" or n == "LianHubFloatingBtn" or n == "LianHubGui" then
                        child:Destroy()
                    else
                        local main = child:FindFirstChild("Main", true)
                        local topbar = main and main:FindFirstChild("Topbar", true)
                        local title = topbar and topbar:FindFirstChild("Title", true)
                        if title and title:IsA("TextLabel") and tostring(title.Text):find("Lian Hub") then
                            child:Destroy()
                        end
                    end
                end
            end
        end)
    end
end

destroyOldGuis()

_ENV.__LianHubCleanup = function()
    for _, conn in ipairs(_activeConns) do
        pcall(function()
            if conn.Disconnect then conn:Disconnect() end
        end)
    end
    table.clear(_activeConns)
    for _, th in ipairs(_activeThreads) do
        pcall(task.cancel, th)
    end
    table.clear(_activeThreads)
    destroyOldGuis()
end

-- 1. Anti-AFK (4-Layer: Kills Anime Dice's 18-minute PlayerScripts.AFK + Idled Disable + VirtualUser + VIM)
local function neutralizeGameAfkScript()
    if not LocalPlayer then return end
    pcall(function()
        local ps = LocalPlayer:FindFirstChild("PlayerScripts")
        if ps then
            for _, child in ipairs(ps:GetDescendants()) do
                if child.Name == "AFK" and (child:IsA("LocalScript") or child:IsA("Script") or child:IsA("ModuleScript")) then
                    pcall(function() child.Disabled = true end)
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end)
end

neutralizeGameAfkScript()
if LocalPlayer then
    local ps = LocalPlayer:FindFirstChild("PlayerScripts")
    if ps then
        pcall(function()
            trackConn(ps.DescendantAdded:Connect(function(desc)
                if desc.Name == "AFK" and (desc:IsA("LocalScript") or desc:IsA("Script")) then
                    pcall(function() desc.Disabled = true end)
                    pcall(function() desc:Destroy() end)
                end
            end))
        end)
    end
end

local _antiAfkConn = nil
local onIdled = nil

local function pulseAntiAfk()
    neutralizeGameAfkScript()
    pcall(function()
        local cam = Workspace.CurrentCamera
        local cf = (cam and cam.CFrame) or CFrame.new()
        VirtualUser:CaptureController()
        VirtualUser:Button2Down(Vector2.new(0, 0), cf)
    end)
    task.wait(0.5)
    pcall(function()
        local cam = Workspace.CurrentCamera
        local cf = (cam and cam.CFrame) or CFrame.new()
        VirtualUser:Button2Up(Vector2.new(0, 0), cf)
        VirtualUser:ClickButton2(Vector2.new(0, 0), cf)
    end)
    pcall(function()
        if VirtualInputManager then
            VirtualInputManager:SendMouseMoveEvent(math.random(1, 5), math.random(1, 5), game)
        end
    end)
end

local function disableIdledConnections()
    pcall(function()
        local gc = getconnections or get_signal_cons or (_ENV and (_ENV.getconnections or _ENV.get_signal_cons))
        if type(gc) == "function" and LocalPlayer then
            for _, conn in pairs(gc(LocalPlayer.Idled)) do
                if conn ~= _antiAfkConn and conn.Connection ~= _antiAfkConn and conn.Function ~= onIdled then
                    if conn.Disable then
                        conn:Disable()
                    elseif conn.Disconnect then
                        conn:Disconnect()
                    end
                end
            end
        end
        if LocalPlayer and onIdled and (not _antiAfkConn or _antiAfkConn.Connected == false) then
            _antiAfkConn = trackConn(LocalPlayer.Idled:Connect(onIdled))
        end
    end)
end

onIdled = function()
    if not isAlive() then return end
    disableIdledConnections()
    pulseAntiAfk()
end

disableIdledConnections()
if LocalPlayer and (not _antiAfkConn or _antiAfkConn.Connected == false) then
    _antiAfkConn = trackConn(LocalPlayer.Idled:Connect(onIdled))
end

trackThread(task.spawn(function()
    while isAlive() do
        disableIdledConnections()
        pulseAntiAfk()
        task.wait(45)
    end
end))

-- Guard: ensure _G.LianConfig exists before any on-load reference
_G.LianConfig = _G.LianConfig or {}

-- Apply ESP helper
local function applyPlayerEspToChar(plr, char)
    if not plr or plr == LocalPlayer or not char then return end
    local head = char:FindFirstChild("Head")
    if head and not head:FindFirstChild("LianESP") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "LianESP"
        billboard.Size = UDim2.new(0, 100, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.Text = plr.Name
        label.Parent = billboard
    end
end

for _, existingPlr in pairs(Players:GetPlayers()) do
    if existingPlr ~= LocalPlayer then
        if existingPlr.Character then
            trackThread(task.spawn(function()
                task.wait(1)
                if isAlive() and _G.LianConfig.PlayerESP then
                    applyPlayerEspToChar(existingPlr, existingPlr.Character)
                end
            end))
        end
        trackConn(existingPlr.CharacterAdded:Connect(function(char)
            task.wait(1)
            if isAlive() and _G.LianConfig.PlayerESP then
                applyPlayerEspToChar(existingPlr, char)
            end
        end))
    end
end

trackConn(Players.PlayerAdded:Connect(function(p)
    if p == LocalPlayer then return end
    trackConn(p.CharacterAdded:Connect(function(char)
        task.wait(1)
        if isAlive() and _G.LianConfig.PlayerESP then
            applyPlayerEspToChar(p, char)
        end
    end))
end))

if LocalPlayer then
    trackConn(LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        if not isAlive() then return end
        pcall(function()
            if _G.LianConfig.Fullbright then
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
                Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = _G.LianConfig.WalkSpeedValue or 16
                hum.JumpPower = _G.LianConfig.JumpPowerValue or 50
            end
        end)
    end))
end

-- 2. Teleport Auto-Execute Queue (STRICT ONE-SHOT PER SERVER — Never Stacks Queue!)
local function setupAutoExecuteOnTeleport(force)
    local rawJob = tostring(game.JobId or "")
    local jobKey = (rawJob ~= "" and rawJob) or "default"
    if not force and (_ENV._LianQOTQueued or _ENV.__LianQueuedJobId == jobKey) then
        return true
    end
    _ENV._LianQOTQueued = true
    _ENV.__LianQueuedJobId = jobKey
    local qot = syn and syn.queue_on_teleport
        or queue_on_teleport
        or queueonteleport
        or (fluxus and fluxus.queue_on_teleport)
        or (_ENV and (_ENV.queue_on_teleport or _ENV.queueonteleport))
    if type(qot) == "function" then
        local ok = pcall(function()
            qot('loadstring(game:HttpGet("https://raw.githubusercontent.com/brilliantgibrann16/lian-hub/main/Loader.lua"))()')
        end)
        return ok
    end
    return false
end

setupAutoExecuteOnTeleport()

-- 3. Thread Identity Helper (Solara/Xeno/Volcano-Safe)
local function asGame(fn, ...)
    if type(setthreadidentity) ~= "function" or type(getthreadidentity) ~= "function" then
        local ok, res = pcall(fn, ...)
        return ok and res or nil
    end
    local prev
    pcall(function() prev = getthreadidentity() end)
    local okSet = pcall(setthreadidentity, 2)
    local packed = table.pack(pcall(fn, ...))
    if okSet and prev then pcall(setthreadidentity, prev) end
    if not packed[1] then return nil end
    return table.unpack(packed, 2, packed.n)
end

-- 4. Verified Anime Dice Remote Registry (v803/v809+ with Multi-Path Resolution)
local NET = RS:FindFirstChild("Network") or RS:WaitForChild("Network", 5)

local function getRemote(svc, kind, name)
    NET = NET or RS:FindFirstChild("Network")
    if not NET then return nil end
    local folder = svc and NET:FindFirstChild(svc) or NET
    if not folder then return nil end
    local sub = kind and folder:FindFirstChild(kind) or folder
    if not sub then return nil end
    return sub:FindFirstChild(name)
end

local R_SPECS = {
    -- Rolling (RollService is verified ground truth)
    RollDice       = { { "RollService", "RF", "RollDice" }, { "Rolling", "RF", "RollDice" } },
    SetAutoRoll    = { { "RollService", "RE", "SetAutoRoll" }, { "Rolling", "RE", "SetAutoRoll" } },
    UpdAutoSell    = { { "SellService", "RE", "UpdateAutoSell" }, { nil, "RE", "UpdateAutoSell" } },
    BuyUpgrade     = { { nil, "RE", "BuyUpgrade" }, { "UpgradeService", "RE", "BuyUpgrade" } },

    -- Dice Shop
    BuyDice        = { { "DiceShopService", "RE", "BuyDice" }, { "DiceService", "RE", "BuyDice" } },
    EquipDice      = { { "DiceShopService", "RE", "EquipDice" }, { "DiceService", "RE", "EquipDice" } },

    -- Plot & Units
    CollectBalance = { { "PlotService", "RE", "CollectBalance" } },
    EquipBest      = { { "PlotService", "RE", "EquipBest" } },
    InteractSlot   = { { "PlotService", "RE", "InteractSlot" } },
    LevelUpSlot    = { { "PlotService", "RE", "LevelUpSlot" } },
    EquipUnit      = { { "UnitService", "RF", "Equip" } },
    UnequipUnit    = { { "UnitService", "RF", "Unequip" } },
    SellInventory  = { { "SellService", "RF", "SellInventory" } },
    SetLocked      = { { "UnitService", "RE", "SetLocked" } },
    Fuse           = { { "FusingService", "RE", "Fuse" } },

    -- Grades, Traits & Quirks
    GradeRoll      = { { "GradeService", "RE", "Roll" } },
    GradeProtect   = { { "GradeService", "RE", "SetGradeProtected" } },
    TraitRoll      = { { "TraitService", "RE", "Roll" } },
    TraitProtect   = { { "TraitService", "RE", "SetTraitProtected" } },
    QuirkRoll      = { { "QuirkService", "RE", "Roll" }, { "GradeService", "RE", "Roll" } },
    QuirkProtect   = { { "QuirkService", "RE", "SetQuirkProtected" } },

    -- Rebirth (RE.Rebirth)
    Rebirth        = { { "RebirthService", "RE", "Rebirth" } },
    AddStat        = { { "RebirthService", "RE", "AddStat" } },

    -- Towers
    PlayTower      = { { "Towers", "RF", "PlayTower" } },
    CompleteFloor  = { { "Towers", "RF", "CompleteTowerFloor" } },
    CancelTower    = { { "Towers", "RF", "CancelTower" } },
    SetAutoTower   = { { "Towers", "RE", "SetAutoTower" } },
    BestTowerTeam  = { { "Towers", "RE", "EquipBestTowerTeam" } },

    -- Boosts, Spins, Gamepass & Gear
    BoostUse       = { { "BoostService", "RE", "Use" } },
    UseSpin        = { { "SpinService", "RE", "Use" } },
    GamepassUse    = { { "GamepassService", "RE", "Use" } },
    GearEquip      = { { "GearService", "RE", "Equip" } },

    -- Quests, Rewards & Codes
    QuestClaim     = { { "QuestService", "RE", "Claim" } },
    QuestBuy       = { { "QuestService", "RE", "Buy" } },
    Daily          = { { "DailyRewardService", "RE", "Claim" } },
    Offline        = { { "OfflineEarningsService", "RE", "Claim" } },
    GroupClaim     = { { "GroupRewardService", "RE", "Claim" } },
    RedeemCode     = { { "CodesService", "RE", "RedeemCode" }, { "MonetizationService", "RE", "RedeemCode" } },

    -- Halloween Event
    PumpkinRoll    = { { "PumpkinDiceService", "RF", "Roll" } },
    HalloweenPath  = { { "HalloweenService", "RE", "ClaimAllPath" } },
    HalloweenBuy   = { { "HalloweenService", "RE", "BuyOffer" } },
    HalloweenQuest = { { "HalloweenQuestService", "RE", "Claim" } },
    TrickKnock     = { { "TrickOrTreatService", "RE", "Knocked" } },
    TrickLand      = { { "TrickOrTreatService", "RE", "Landed" } },
}

local R_ALIASES = {
    Roll = "RollDice",
    Collect = "CollectBalance",
    LevelSlot = "LevelUpSlot",
    Sell = "SellInventory",
    SellUnits = "SellInventory",
    ToggleLock = "SetLocked",
    BestTeam = "BestTowerTeam",
    FloorTower = "CompleteFloor",
    Boost = "BoostUse",
    Spin = "UseSpin",
    Code = "RedeemCode",
}

local R = setmetatable({}, {
    __index = function(t, k)
        k = R_ALIASES[k] or k
        local candidates = R_SPECS[k]
        if not candidates then return nil end
        for _, s in ipairs(candidates) do
            local rem = getRemote(s[1], s[2], s[3])
            if rem then
                rawset(t, k, rem)
                return rem
            end
        end
        return nil
    end
})

local function fire(remote, ...)
    if not remote then return false end
    if remote:IsA("RemoteEvent") then
        local ok = pcall(remote.FireServer, remote, ...)
        return ok
    elseif remote:IsA("RemoteFunction") then
        local args = { ... }
        task.spawn(function()
            remote:InvokeServer(table.unpack(args))
        end)
        return true
    end
    return false
end

local function invoke(remote, ...)
    if not remote then return nil end
    if remote:IsA("RemoteFunction") then
        return remote:InvokeServer(...)
    elseif remote:IsA("RemoteEvent") then
        pcall(remote.FireServer, remote, ...)
        return true
    end
    return nil
end

-- 5. Game Framework Modules Loader & Live Data Unwrapper
local M = {}

local function safeRequire(mod)
    if not mod then return nil end
    local ok, res = pcall(asGame, require, mod)
    if ok and res ~= nil then return res end
    local ok2, res2 = pcall(require, mod)
    if ok2 and res2 ~= nil then return res2 end
    return nil
end

local function initFramework()
    local fw = RS:FindFirstChild("Framework") or RS:WaitForChild("Framework", 15)
    if fw then
        local t0 = os.clock()
        while not fw:GetAttribute("IsLoaded") and os.clock() - t0 < 10 do
            task.wait(0.3)
        end
        local Feat = fw:FindFirstChild("Features") or fw:WaitForChild("Features", 10)
        if Feat then
            if Feat:FindFirstChild("Data") then M.Data = safeRequire(Feat.Data:FindFirstChild("DataController")) end
            if Feat:FindFirstChild("Buffs") then M.Buff = safeRequire(Feat.Buffs:FindFirstChild("BuffController")) end
            if Feat:FindFirstChild("Inventory") then
                M.Entry = safeRequire(Feat.Inventory:FindFirstChild("EntryRegistry"))
                local kinds = Feat.Inventory:FindFirstChild("Kinds")
                local uFolder = kinds and kinds:FindFirstChild("Unit")
                if uFolder then
                    M.UnitConfig = safeRequire(uFolder:FindFirstChild("UnitConfig"))
                    M.UnitUtil = safeRequire(uFolder:FindFirstChild("UnitUtil"))
                end
            end
            if Feat:FindFirstChild("Rolling") then M.Dice = safeRequire(Feat.Rolling:FindFirstChild("Dice")) end
            if Feat:FindFirstChild("Upgrades") then
                M.Upgrades = safeRequire(Feat.Upgrades:FindFirstChild("Upgrades"))
                M.Tree = safeRequire(Feat.Upgrades:FindFirstChild("TreeStructure"))
            end
            if Feat:FindFirstChild("Rebirth") then
                M.Rebirths = safeRequire(Feat.Rebirth:FindFirstChild("Rebirths"))
                M.RStats = safeRequire(Feat.Rebirth:FindFirstChild("RebirthStats"))
                    or safeRequire(Feat.Rebirth:FindFirstChild("RebirthStatsConfig"))
            end
            if Feat:FindFirstChild("Plot") then M.PlotConfig = safeRequire(Feat.Plot:FindFirstChild("PlotConfig")) end
            if Feat:FindFirstChild("Towers") then
                M.Towers = safeRequire(Feat.Towers:FindFirstChild("Towers"))
                M.TowerController = safeRequire(Feat.Towers:FindFirstChild("TowerController"))
            end
            if Feat:FindFirstChild("Quests") then M.Quests = safeRequire(Feat.Quests:FindFirstChild("QuestConfig")) end
            if Feat:FindFirstChild("Codes") then M.Codes = safeRequire(Feat.Codes:FindFirstChild("CodesConfig")) end
            if Feat:FindFirstChild("Grades") then M.Grades = safeRequire(Feat.Grades:FindFirstChild("Grades")) end
            if Feat:FindFirstChild("Traits") then M.Traits = safeRequire(Feat.Traits:FindFirstChild("Traits")) end
            if Feat:FindFirstChild("Quirks") then
                M.Quirks = safeRequire(Feat.Quirks:FindFirstChild("Quirks"))
                M.QuirkUtil = safeRequire(Feat.Quirks:FindFirstChild("QuirkUtil"))
            end
            if Feat:FindFirstChild("Gear") then M.Gear = safeRequire(Feat.Gear:FindFirstChild("Gear")) end
            if Feat:FindFirstChild("Fusing") then M.Fusing = safeRequire(Feat.Fusing:FindFirstChild("FusingConfig")) end
            if Feat:FindFirstChild("DailyRewards") then M.DailyCfg = safeRequire(Feat.DailyRewards:FindFirstChild("DailyRewardsConfig")) end
            if Feat:FindFirstChild("GroupReward") then M.GroupCfg = safeRequire(Feat.GroupReward:FindFirstChild("GroupRewardConfig")) end
        end
    end
    local pkgs = RS:FindFirstChild("Packages")
    local dataPkg = pkgs and pkgs:FindFirstChild("Data")
    if dataPkg and dataPkg:FindFirstChild("Client") then
        M.DataClient = safeRequire(dataPkg.Client)
    end
end
trackThread(task.spawn(initFramework))

local function unwrapVal(v, depth)
    depth = depth or 0
    if depth > 6 then return v end
    if type(v) == "function" then
        local ok, res = pcall(v)
        if ok then return unwrapVal(res, depth + 1) end
        return nil
    elseif type(v) == "table" then
        if v.___X ~= nil then
            return unwrapVal(v.___X, depth + 1)
        elseif type(v.Get) == "function" then
            local ok, res = pcall(v.Get, v)
            if ok then return unwrapVal(res, depth + 1) end
        end
    end
    return v
end

local function getDC()
    if M.Data then return M.Data end
    pcall(function()
        local feat = RS:FindFirstChild("Framework") and RS.Framework:FindFirstChild("Features")
        if feat and feat:FindFirstChild("Data") then
            M.Data = safeRequire(feat.Data:FindFirstChild("DataController"))
        end
    end)
    return M.Data
end

local function readData(key, default)
    local dc = getDC()
    if dc then
        local ok, raw = pcall(function() return dc[key] end)
        if ok and raw ~= nil then
            local val = unwrapVal(raw)
            if val ~= nil then return val end
        end
        local okX, rawX = pcall(function() return dc.___X and dc.___X[key] end)
        if okX and rawX ~= nil then
            local val = unwrapVal(rawX)
            if val ~= nil then return val end
        end
    end
    if not M.DataClient then
        pcall(function()
            local pkgs = RS:FindFirstChild("Packages")
            if pkgs and pkgs:FindFirstChild("Data") and pkgs.Data:FindFirstChild("Client") then
                M.DataClient = safeRequire(pkgs.Data.Client)
            end
        end)
    end
    if M.DataClient and M.DataClient.data then
        local root = unwrapVal(M.DataClient.data)
        if type(root) == "table" and root[key] ~= nil then
            local val = unwrapVal(root[key])
            if val ~= nil then return val end
        end
    end
    return default
end

-- ═══════════════════════════════════════════════════════════════════════════
-- LIAN HUB GAME UPDATE CHECKER
-- ═══════════════════════════════════════════════════════════════════════════
local function checkGameUpdates()
    local results = {}
    local function check(name, ok)
        table.insert(results, (ok and "✅ " or "❌ ") .. name)
    end
    initFramework()
    pcall(function()
        check("Framework.DataController", getDC() ~= nil)
        check("Remote.RollDice", R.Roll ~= nil)
        check("Remote.SetAutoRoll", R.SetAutoRoll ~= nil)
        check("Remote.BuyUpgrade", R.BuyUpgrade ~= nil)
        check("Remote.BuyDice", R.BuyDice ~= nil)
        check("Remote.EquipDice", R.EquipDice ~= nil)
        check("Remote.PlotCollect", R.Collect ~= nil)
        check("Remote.PlotEquipBest", R.EquipBest ~= nil)
        check("Remote.UnitLevelUp", R.LevelSlot ~= nil)
        check("Remote.UnitSellUnits", R.Sell ~= nil)
        check("Remote.Rebirth", R.Rebirth ~= nil)
        check("Remote.AddStat", R.AddStat ~= nil)
        check("Remote.PlayTower", R.PlayTower ~= nil)
        check("Remote.CompleteTowerFloor", R.FloorTower ~= nil)
        check("Remote.GradeRoll", R.GradeRoll ~= nil)
        check("Remote.QuirkRoll", R.QuirkRoll ~= nil)
        check("Remote.BoostUse", R.Boost ~= nil)
        check("Remote.SpinUse", R.Spin ~= nil)
        check("Remote.QuestClaim", R.QuestClaim ~= nil)
        check("Remote.RedeemCode", R.Code ~= nil)
        check("Data.Money", type(readData("Money", nil)) == "number")
        check("Data.Inventory", type(readData("Inventory", nil)) == "table")
        check("Data.Slots", type(readData("Slots", nil)) == "table")
    end)
    print("\n═══════════════════════════════════════════════════════════════════════════")
    print("🔍 LIAN HUB v7.0 GAME UPDATE CHECKER REPORT")
    print("═══════════════════════════════════════════════════════════════════════════")
    local broken = 0
    for _, r in ipairs(results) do
        print(r)
        if r:find("❌") then broken = broken + 1 end
    end
    print("📊 Total checks: " .. #results .. " | Broken: " .. broken)
    print("═══════════════════════════════════════════════════════════════════════════\n")
    return results
end
_G.LianHubCheckUpdates = checkGameUpdates

-- 6. Persistent Configuration (All 56 Keys Preserved)
local CONFIG_FILE = "LianHub_AnimeDice_Config.json"

local _prevConfig = _G.LianConfig
_G.LianConfig = {
    AutoRoll = false,
    AutoBuyDice = false,
    FastRoll = false,
    AutoRollHalloween = false,
    HalloweenRollOption = "500 Labu (5x Rolls)",
    AutoPotions = false,
    PotionUseLuck = true,
    PotionUseIncome = true,
    PotionUseDamage = true,
    PotionUseSpeed = false,
    PotionUseHalloween = true,
    PotionUseTower = true,
    AutoTrickOrTreat = false,
    AutoHalloweenQuestClaim = false,
    AutoPumpkinPass = false,
    AutoTower = false,
    SmartTowerAI = false,
    AutoEquipTowerTeam = true,
    TowerType = "Shadow Tower",
    AutoCollectCash = false,
    AutoLevelUpSlots = false,
    AutoDailyReward = false,
    AutoRedeemCodes = false,
    AutoClaimOffline = true,
    AutoLuckySpin = true,
    AutoRebirth = false,
    AutoAllocStats = true,
    RebirthStatPriority = "Balance / Rata (Money, Luck, Damage, Health, Trait Luck, Grade Luck)",
    AutoBuyTreeUpgrades = false,
    AutoEquipBestPlotAndSellRest = false,
    AutoQuirk = false,
    ServerLuckHop = false,
    AutoTradeFeeder = false,
    MasterAccount = "",
    TradeMythic = true,
    TradeSecret = true,
    DiscordWebhook = "",
    AutoReconnect = true,
    Disable3DRendering = false,
    ExtremePotatoMode = false,
    TargetFPS = 30,
    InfJump = false,
    Noclip = false,
    TeleportTarget = "",
    AutoUnitGrades = false,
    ProtectHighGrades = false,
    RollGradeOnce = false,
    ProtectShiny = true,
    ProtectHaunted = true,
    TradeRequests = true,
    Fullbright = false,
    PlayerESP = false,
    AutoSellShiny = false,
    AutoSellHaunted = false,
    WalkSpeedValue = 16,
    JumpPowerValue = 50
}

if type(_prevConfig) == "table" then
    for k, v in pairs(_prevConfig) do
        if _G.LianConfig[k] ~= nil then
            _G.LianConfig[k] = v
        end
    end
end

local function saveConfig()
    pcall(function()
        if type(writefile) == "function" then
            writefile(CONFIG_FILE, HttpService:JSONEncode(_G.LianConfig))
        end
    end)
end

local function loadConfig()
    pcall(function()
        if type(isfile) == "function" and isfile(CONFIG_FILE) and type(readfile) == "function" then
            local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
            if type(data) == "table" then
                if data.AutoHalloweenDoors ~= nil and data.AutoHalloweenQuestClaim == nil then
                    data.AutoHalloweenQuestClaim = data.AutoHalloweenDoors
                end
                for k, v in pairs(data) do
                    if _G.LianConfig[k] ~= nil then
                        _G.LianConfig[k] = v
                    end
                end
            end
        end
    end)
    _G.LianConfig.ServerLuckHop = _G.LianConfig.ServerLuckHop or false
end
loadConfig()

-- 7. Verified Anime Dice Calculation & Feature Helpers
local SUFFIX_MULT = {
    k = 1e3, m = 1e6, b = 1e9, t = 1e12, qa = 1e15, qi = 1e18,
    sx = 1e21, sp = 1e24, oc = 1e27, no = 1e30, dc = 1e33
}

local function parseFormattedNumber(str)
    if type(str) == "number" then return str end
    if not str then return 0 end
    local raw = tostring(str):lower():gsub("[$,%s]", "")
    local num, suf = raw:match("^([%d%.]+)([a-z]*)$")
    if not num then
        num = raw:match("([%d%.]+)")
        suf = raw:match("([a-z]+)")
    end
    local base = tonumber(num)
    if not base then return 0 end
    if suf and SUFFIX_MULT[suf] then
        return base * SUFFIX_MULT[suf]
    end
    return base
end

local function getPlayerCash()
    local m = readData("Money", nil)
    if type(m) == "number" and m >= 0 then return m end
    local ls = LocalPlayer and LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        for _, name in ipairs({"Money", "Cash", "Coins", "Balance"}) do
            local val = ls:FindFirstChild(name)
            if val and val.Value then
                local n = parseFormattedNumber(val.Value)
                if n > 0 then return n end
            end
        end
    end
    local pg = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    local hud = pg and pg:FindFirstChild("Root") and pg.Root:FindFirstChild("HUD")
    if hud and hud:FindFirstChild("Cash") then
        local lbl = hud.Cash:FindFirstChildWhichIsA("TextLabel", true)
        if lbl and lbl.Text then
            local val = parseFormattedNumber(lbl.Text)
            if val > 0 then return val end
        end
    end
    return 0
end

local function isUuidKey(k)
    return type(k) == "string" and (#k == 36 or (k:find("-", 1, true) ~= nil and #k >= 16))
end

local function getEntryCfg(name)
    if type(name) ~= "string" or name == "" then return nil end
    if not M.Entry then
        local feat = RS:FindFirstChild("Framework") and RS.Framework:FindFirstChild("Features")
        if feat and feat:FindFirstChild("Inventory") then
            M.Entry = safeRequire(feat.Inventory:FindFirstChild("EntryRegistry"))
        end
    end
    if M.Entry then
        if type(M.Entry.getEntryConfig) == "function" then
            local ok, cfg = pcall(M.Entry.getEntryConfig, name)
            if ok and type(cfg) == "table" then return cfg end
            local ok2, cfg2 = pcall(M.Entry.getEntryConfig, M.Entry, name)
            if ok2 and type(cfg2) == "table" then return cfg2 end
        end
        if type(M.Entry.entries) == "table" and M.Entry.entries[name] then
            return M.Entry.entries[name]
        end
    end
    return nil
end

local function isUnitEntry(key, entry)
    if type(entry) ~= "table" then return false end
    local cfg = getEntryCfg(entry.name)
    if cfg and cfg.kind then
        return cfg.kind == "Unit"
    end
    if type(entry.attributes) == "table" or isUuidKey(key) then
        return true
    end
    return false
end

local RARITY_ORDER = {
    Common = 1, Rare = 2, Epic = 3, Legendary = 4,
    Mythic = 5, Secret = 6, Celestial = 7, Limited = 8
}

local GRADE_ORDER = {
    ["F"] = 1, ["E"] = 2, ["D"] = 3, ["C"] = 4, ["B"] = 5,
    ["A"] = 6, ["S"] = 7, ["SS"] = 8, ["SSS"] = 9
}

local RARE_QUIRKS = {
    ["Sovereign"] = true, ["Fortune's Favor"] = true, ["Midas Touch"] = true,
    ["Prodigy"] = true, ["Tycoon"] = true, ["Fortune III"] = true,
    ["Gifted III"] = true, ["Refined III"] = true, ["Swift III"] = true, ["Wealth III"] = true
}

local function getUnitRarity(entry)
    if type(entry) ~= "table" then return "Common" end
    if type(entry.rarity) == "string" then return entry.rarity end
    local attrs = type(entry.attributes) == "table" and entry.attributes or nil
    if attrs and type(attrs.rarity) == "string" then return attrs.rarity end
    local cfg = getEntryCfg(entry.name)
    if cfg then
        if type(cfg.rarity) == "string" then return cfg.rarity end
        if type(cfg.getRarity) == "function" then
            local ok, r = pcall(cfg.getRarity, attrs)
            if ok and type(r) == "string" then return r end
        end
    end
    return "Common"
end

-- Verified Dice Table (from RS.Framework.Features.Rolling.Dice)
local FALLBACK_DICE = {
    { name = "Basic Dice", price = 100, luck = 0 },
    { name = "Silver Dice", price = 400, luck = 0.25 },
    { name = "Golden Dice", price = 2000, luck = 0.5 },
    { name = "Devil Dice", price = 7500, luck = 0.85 },
    { name = "Heavenly Dice", price = 15000, luck = 1.2 },
    { name = "Chakra Dice", price = 45000, luck = 1.45 },
    { name = "Slayer Dice", price = 100000, luck = 1.75 },
    { name = "Blackhole Dice", price = 500000, luck = 2.0 },
    { name = "Yin Yang Dice", price = 1500000, luck = 2.5 },
    { name = "Six Eyes Dice", price = 4500000, luck = 3.0 },
    { name = "Infinity Dice", price = 12500000, luck = 4.0 },
    { name = "Chronos Dice", price = 25000000, luck = 5.0 },
    { name = "Chainsaw Dice", price = 50000000, luck = 5.5 },
    { name = "Idol Dice", price = 125000000, luck = 6.0 },
    { name = "Soul Dice", price = 250000000, luck = 6.5 },
    { name = "Esper Dice", price = 750000000, luck = 7.25 },
    { name = "Shadow Dice", price = 2000000000, luck = 8.0 },
    { name = "Gourmet Dice", price = 10000000000, luck = 9.0 },
    { name = "Dragon Dice", price = 50000000000, luck = 10.0 },
    { name = "Anti Dice", price = 250000000000, luck = 11.0 },
    { name = "Bizarre Dice", price = 1000000000000, luck = 12.0 },
    { name = "Cursed Finger Dice", price = 25000000000000, luck = 13.0 },
    { name = "pirate Dice", price = 100000000000000, luck = 13.75 },
    { name = "One For All Dice", price = 400000000000000, luck = 14.5 },
    { name = "Ego Dice", price = 2500000000000000, luck = 15.0 },
    { name = "Strawhat Dice", price = 15000000000000000, luck = 15.25 },
    { name = "Sun God Dice", price = 50000000000000000, luck = 15.5 },
    { name = "Pro Hero Dice", price = 250000000000000000, luck = 15.75 },
    { name = "Demon King Dice", price = 1000000000000000000, luck = 16.0 },
}

local function getAllDiceList()
    if M.Dice and type(M.Dice.GetAll) == "function" then
        local ok, all = pcall(M.Dice.GetAll)
        if ok and type(all) == "table" then
            local list = {}
            for name, d in pairs(all) do
                if type(d) == "table" and d.currency ~= "Candy" and (d.price or 0) > 0 then
                    table.insert(list, {
                        name = d.name or name,
                        price = tonumber(d.price) or 0,
                        luck = tonumber(d.luck) or 0
                    })
                end
            end
            if #list > 0 then
                table.sort(list, function(a, b) return a.luck < b.luck end)
                return list
            end
        end
    end
    return FALLBACK_DICE
end

-- Verified Upgrade Tree Nodes (from RS.Framework.Features.Upgrades.Upgrades)
local FALLBACK_TREE_UPGRADES = {
    "Money Multiplier I", "Luck I", "Money Multiplier II", "Luck II",
    "Roll Duration I", "Unit Storage I", "Money Multiplier III", "Luck III",
    "Unlock Index", "Roll Duration II", "Luck IV", "Money Multiplier IV",
    "Unit Storage II", "Luck V", "Roll Duration III", "Unlock Auto Roll",
    "Money Multiplier V", "Luck VI", "Unit Storage III", "Roll Duration IV",
    "Luck VII", "Luck VIII", "Unit Storage IV", "Roll Duration V",
    "Luck IX", "Luck X"
}

local function getNextRebirthCost()
    local rb = tonumber(readData("Rebirth", 0)) or 0
    if M.Rebirths and type(M.Rebirths.GetNext) == "function" then
        local ok, nxt = pcall(M.Rebirths.GetNext, rb)
        if ok and type(nxt) == "table" and nxt.price then
            return tonumber(nxt.price) or 0
        end
    end
    -- Fallback exponential formula from Anime Dice Rebirths module
    return math.floor(1000 * math.pow(rb + 1, 2.5))
end

local function canAffordSpend(price)
    local curMoney = getPlayerCash()
    if _G.LianConfig.AutoRebirth then
        local rbCost = getNextRebirthCost()
        return (curMoney - price) >= rbCost
    end
    return curMoney >= price
end

local function buyUpgradesTree()
    if not R.BuyUpgrade then return end
    local owned = readData("Upgrades", {}) or {}
    if M.Upgrades and M.Tree and type(M.Tree.GetParent) == "function" then
        local cands = {}
        for name, u in pairs(M.Upgrades) do
            if type(u) == "table" and name ~= "Start" and not owned[name] then
                local okP, parent = pcall(M.Tree.GetParent, name)
                if okP and (parent == nil or parent == "Start" or owned[parent] == true) then
                    local price = tonumber(u.price) or 0
                    if canAffordSpend(price) then
                        table.insert(cands, { name = name, price = price })
                    end
                end
            end
        end
        table.sort(cands, function(a, b) return a.price < b.price end)
        for i = 1, math.min(5, #cands) do
            local c = cands[i]
            if not canAffordSpend(c.price) then break end
            fire(R.BuyUpgrade, c.name)
            task.wait(0.18)
        end
        return
    end
    for _, upgName in ipairs(FALLBACK_TREE_UPGRADES) do
        if not owned[upgName] and canAffordSpend(500) then
            fire(R.BuyUpgrade, upgName)
            task.wait(0.12)
        end
    end
end

local function canAffordRebirth()
    local curCash = getPlayerCash()
    local curRebirths = tonumber(readData("Rebirth", 0)) or 0
    if M.Rebirths and type(M.Rebirths.GetNext) == "function" then
        local okNxt, nxt = pcall(M.Rebirths.GetNext, curRebirths)
        if okNxt and type(nxt) == "table" then
            local reqPrice = tonumber(nxt.price or nxt.cost)
            if reqPrice then
                return curCash >= reqPrice, curCash, reqPrice
            end
        end
    end
    local pg = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    local rMenu = pg and pg:FindFirstChild("Root") and pg.Root:FindFirstChild("Menus") and pg.Root.Menus:FindFirstChild("Rebirth")
    if rMenu then
        local costLabel = rMenu:FindFirstChild("Cash", true)
        if costLabel then
            local txt = costLabel:FindFirstChildWhichIsA("TextLabel", true)
            if txt and txt.Text then
                local cost = parseFormattedNumber(txt.Text)
                if cost > 0 then return curCash >= cost, curCash, cost end
            end
        end
    end
    local fallbackCost = getNextRebirthCost()
    return curCash >= fallbackCost, curCash, fallbackCost
end

local function getAvailableStatPoints()
    local curStats = readData("RebirthStats", {}) or {}
    local curRebirths = tonumber(readData("Rebirth", 0)) or 0
    if M.RStats and type(M.RStats.GetRemaining) == "function" then
        local okRem, rem = pcall(M.RStats.GetRemaining, curRebirths, curStats)
        if okRem and type(rem) == "number" then return rem end
    end
    local spent = 0
    for _, v in pairs(curStats) do
        spent = spent + (tonumber(v) or 0)
    end
    return math.max(0, curRebirths - spent)
end

local function findMyPlot()
    if not LocalPlayer then return nil end
    local plots = Workspace:FindFirstChild("Plots") or (Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Plots"))
    if not plots then return nil end
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:GetAttribute("OwnerId") == LocalPlayer.UserId or plot:GetAttribute("Owner") == LocalPlayer.Name then
            return plot
        end
        local owner = plot:FindFirstChild("Owner")
        if owner and owner:IsA("ObjectValue") and owner.Value == LocalPlayer then
            return plot
        end
        local sign = plot:FindFirstChild("Sign") or plot:FindFirstChild("PlotSign")
        if sign then
            for _, lbl in ipairs(sign:GetDescendants()) do
                if lbl:IsA("TextLabel") and (lbl.Text:find(LocalPlayer.Name, 1, true) or lbl.Text:find(LocalPlayer.DisplayName, 1, true)) then
                    return plot
                end
            end
        end
    end
    return nil
end

-- Smart Plot Optimizer + Auto-Lock + Auto-Sell Outside Plot
local function equipBestPlotAndSellOutside()
    if R.EquipBest then
        fire(R.EquipBest)
        task.wait(0.8)
    end

    local inv = readData("Inventory", {}) or {}
    local slots = readData("Slots", {}) or {}
    local towerTeam = readData("TowerTeam", {}) or {}

    -- UNIT SAFETY GUARD: if slots data is empty, abort to prevent selling placed units!
    if not next(slots) then
        return
    end

    local protectedKeys = {}
    for _, val in pairs(slots) do
        if type(val) == "string" and val ~= "" then
            protectedKeys[val] = true
        elseif type(val) == "table" and (val.unitId or val.key) then
            protectedKeys[val.unitId or val.key] = true
        end
    end
    for _, uuid in pairs(towerTeam) do
        if type(uuid) == "string" and uuid ~= "" then
            protectedKeys[uuid] = true
        end
    end

    local sellList = {}
    for key, item in pairs(inv) do
        if isUnitEntry(key, item) and not protectedKeys[key] then
            local attrs = type(item.attributes) == "table" and item.attributes or item
            local rarity = getUnitRarity(item)
            local rRank = RARITY_ORDER[rarity] or 1
            local grade = tostring(attrs.grade or item.Grade or ""):upper()
            local gRank = GRADE_ORDER[grade] or 0
            local quirk = tostring(attrs.quirk or "")
            local isLocked = (attrs.locked == true) or (item.locked == true)
            local isHeld = (attrs.held == true) or (item.held == true)
            local isShiny = (attrs.shiny == true) or (item.Shiny == true) or (item.shiny == true)
            local isHaunted = (attrs.haunted == true) or (item.Haunted == true) or tostring(item.name or ""):lower():find("haunted") ~= nil

            local keep = false
            if isLocked or isHeld then keep = true end
            if rRank >= 5 then -- Always protect & lock Mythic / Secret / Celestial / Limited!
                keep = true
                if not isLocked and R.SetLocked then
                    fire(R.SetLocked, { [key] = true })
                end
            end
            if RARE_QUIRKS[quirk] then
                keep = true
                if not isLocked and R.SetLocked then
                    fire(R.SetLocked, { [key] = true })
                end
            end
            if isShiny and _G.LianConfig.ProtectShiny and not _G.LianConfig.AutoSellShiny then
                keep = true
            end
            if isHaunted and _G.LianConfig.ProtectHaunted and not _G.LianConfig.AutoSellHaunted then
                keep = true
            end
            if _G.LianConfig.ProtectHighGrades and gRank >= 7 then -- S, SS, SSS
                keep = true
            end

            if not keep then
                table.insert(sellList, key)
            end
        end
    end

    if #sellList > 0 and R.SellInventory then
        for i = 1, #sellList, 40 do
            local batch = {}
            for j = i, math.min(i + 39, #sellList) do
                table.insert(batch, sellList[j])
            end
            invoke(R.SellInventory, batch)
            task.wait(0.25)
        end
    end
end

local function applyPotatoMode(enable)
    if enable then
        pcall(function() if setfpscap then setfpscap(_G.LianConfig.TargetFPS or 30) end end)
        pcall(function()
            settings().Rendering.QualityLevel = 1
            Lighting.GlobalShadows = false
            Lighting.Brightness = 1
        end)
        for _, obj in ipairs(Workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("BasePart") then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.CastShadow = false
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 1
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled = false
                end
            end)
        end
    else
        pcall(function() if setfpscap then setfpscap(60) end end)
        pcall(function()
            settings().Rendering.QualityLevel = 5
            Lighting.GlobalShadows = true
        end)
    end
end

-- 8. Strict Auto-Reconnect Watcher (Ignores Teleport Errors to Prevent Loop-Inject!)
local isReconnecting = false
local function triggerAutoReconnect(msg)
    if not isAlive() or not _G.LianConfig.AutoReconnect or isReconnecting then return end
    local lower = tostring(msg or ""):lower()
    if lower == "" then return end
    -- CRITICAL: Ignore transient teleport errors so failed hops/teleports NEVER trigger a reconnect loop!
    if lower:find("teleport") or lower:find("processing") then
        return
    end
    if lower:find("disconnect") or lower:find("connection lost") or lower:find("kicked")
        or lower:find("idle") or lower:find("267") or lower:find("266")
        or lower:find("277") or lower:find("279") or lower:find("268") or lower:find("529") then
        isReconnecting = true
        setupAutoExecuteOnTeleport()
        trackThread(task.spawn(function()
            while isAlive() and isReconnecting and _G.LianConfig.AutoReconnect do
                task.wait(5)
                if not isAlive() then break end
                task.spawn(function()
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end)
                task.wait(10)
            end
            isReconnecting = false
        end))
    end
end

trackConn(GuiService.ErrorMessageChanged:Connect(triggerAutoReconnect))

trackThread(task.spawn(function()
    while isAlive() do
        if _G.LianConfig.AutoReconnect and not isReconnecting then
            local okMsg, errMsg = pcall(function() return GuiService:GetErrorMessage() end)
            if okMsg and type(errMsg) == "string" and #errMsg > 0 then
                triggerAutoReconnect(errMsg)
            end
        end
        task.wait(6)
    end
end))

print("[Lian Hub v7.0] Starting... executor: " .. (identifyexecutor and identifyexecutor() or "unknown"))

-- 9. Load Rayfield UI (Execute chunk & CreateWindow outside pcall — both yield internally!)
local Rayfield
_ENV.__LianHubRayfield = nil
local rawRay
for attempt = 1, 3 do
    local ok, res = pcall(function()
        return game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua')
    end)
    if ok and type(res) == "string" and #res > 100 then
        rawRay = res
        break
    end
    task.wait(1.0)
end
if rawRay and #rawRay > 100 then
    local okCompile, rayChunk = pcall(loadstring, rawRay)
    if okCompile and type(rayChunk) == "function" then
        Rayfield = rayChunk()
        _ENV.__LianHubRayfield = Rayfield
    end
end

if not Rayfield then
    warn("[Lian Hub] Rayfield tidak dapat dimuat. Workers tetap jalan (headless mode).")
    Rayfield = { Notify = function() end, CreateWindow = function() return nil end }
end

local Window
if Rayfield and Rayfield.CreateWindow then
    Window = Rayfield:CreateWindow({
        Name = "⚡ Lian Hub v7.0 | Anime Dice Master Suite",
        Icon = 0,
        LoadingTitle = "Lian Hub v7.0 Rebuilt...",
        LoadingSubtitle = "by iannn (@brilliantgibrann16)",
        Theme = "Ocean",
        DisableRayfieldPrompts = true,
        DisableBuildWarnings = true,
        ConfigurationSaving = { Enabled = false },
        KeySystem = false
    })
end

-- Release execution lock once Window is created
_ENV.__LianHubExecuting = false

-- Floating Draggable Toggle Button
local parentGui = nil
if type(gethui) == "function" then
    pcall(function() parentGui = gethui() end)
end
if not parentGui then
    pcall(function() parentGui = game:GetService("CoreGui") end)
end
if not parentGui and LocalPlayer then
    parentGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
end
if parentGui then
    local oldBtn = parentGui:FindFirstChild("LianHubFloatingBtn")
    if oldBtn then oldBtn:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LianHubFloatingBtn"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parentGui

    local Btn = Instance.new("TextButton")
    Btn.Name = "ToggleMenu"
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.new(0, 115, 0, 32)
    Btn.Position = UDim2.new(0.015, 0, 0.15, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
    Btn.TextColor3 = Color3.fromRGB(56, 189, 248)
    Btn.Text = "⚡ Lian Hub"
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.Active = true
    Btn.Draggable = true

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Btn

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(56, 189, 248)
    Stroke.Thickness = 1.5
    Stroke.Parent = Btn

    trackConn(Btn.MouseButton1Click:Connect(function()
        pcall(function()
            local rMain = parentGui:FindFirstChild("Rayfield")
            if rMain then
                rMain.Enabled = not rMain.Enabled
            end
        end)
    end))

    trackConn(UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and (input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.LeftAlt) then
            local rMain = parentGui:FindFirstChild("Rayfield")
            if rMain then
                rMain.Enabled = not rMain.Enabled
            end
        end
    end))
end

local function sendDiscordWebhook(title, desc, color)
    local url = _G.LianConfig.DiscordWebhook
    if not url or url == "" or not url:find("http") then return end
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if not req then return end
    local payload = {
        embeds = {{
            title = title,
            description = desc,
            color = color or 5814783,
            footer = { text = "⚡ Lian Hub v7.0 | Anime Dice Telemetry" },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
    req({
        Url = url,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(payload)
    })
end

local function teleportToTarget(targetInstance)
    local hrp = LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetInstance then return false end
    local ok = pcall(function()
        if targetInstance:IsA("BasePart") then
            hrp.CFrame = targetInstance.CFrame + Vector3.new(0, 3, 0)
        elseif targetInstance:IsA("Model") then
            hrp.CFrame = targetInstance:GetPivot() + Vector3.new(0, 3, 0)
        elseif targetInstance:IsA("Folder") then
            local bp = targetInstance:FindFirstChildWhichIsA("BasePart", true)
            if bp then
                hrp.CFrame = bp.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end)
    return ok
end

local function findZoneOrStation(names)
    local zones = Workspace:FindFirstChild("Zones")
    local map = Workspace:FindFirstChild("Map")
    for _, n in ipairs(names) do
        local found = (zones and zones:FindFirstChild(n, true))
            or Workspace:FindFirstChild(n, true)
            or (map and map:FindFirstChild(n, true))
        if found then return found end
    end
    return nil
end

-- TABS & CONTROLS (61 CreateToggle, 0 CreateButton, 3 CreateDropdown)
if Window then
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local PotionsTab = Window:CreateTab("Potion Stacking", 4483362458)
-- Trade Feeder Tab pruned (TradeService not in Anime Dice Network)

-- TAB 4: HALLOWEEN EVENT SUITE
HalloweenTab:CreateSection("🎃 Pumpkin Dice Roll Engine")

HalloweenTab:CreateDropdown({
    Name = "Pilihan Roll Dadu Labu",
    Options = {"500 Labu (5x Rolls - Rekomendasi)", "100 Labu (1x Roll)"},
    CurrentOption = _G.LianConfig.HalloweenRollOption,
    Callback = function(Option)
        _G.LianConfig.HalloweenRollOption = type(Option) == "table" and Option[1] or Option
        saveConfig()
    end,
})

HalloweenTab:CreateToggle({
    Name = "Auto Roll Pumpkin Dice (Dadu Labu)",
    CurrentValue = _G.LianConfig.AutoRollHalloween,
    Callback = function(Value)
        _G.LianConfig.AutoRollHalloween = Value
        saveConfig()
    end,
})

HalloweenTab:CreateSection("🍬 Trick-or-Treat & Event Doors")

HalloweenTab:CreateToggle({
    Name = "Auto Trick-or-Treat (Knock & Claim Door)",
    CurrentValue = _G.LianConfig.AutoTrickOrTreat,
    Callback = function(Value)
        _G.LianConfig.AutoTrickOrTreat = Value
        saveConfig()
    end,
})

HalloweenTab:CreateToggle({
    Name = "Auto Claim Halloween Event Quests (6 Floors)",
    CurrentValue = _G.LianConfig.AutoHalloweenQuestClaim,
    Callback = function(Value)
        _G.LianConfig.AutoHalloweenQuestClaim = Value
        saveConfig()
    end,
})

HalloweenTab:CreateToggle({
    Name = "Auto Claim Pumpkin Pass (All Paths)",
    CurrentValue = _G.LianConfig.AutoPumpkinPass,
    Callback = function(Value)
        _G.LianConfig.AutoPumpkinPass = Value
        saveConfig()
    end,
})

-- TAB 5: TOWERS
TowerTab:CreateSection("⚔️ Smart Tower AI Engine")

TowerTab:CreateToggle({
    Name = "Smart Tower AI (Hitung Damage Unit & Serang Tower Terkuat)",
    CurrentValue = _G.LianConfig.SmartTowerAI,
    Callback = function(Value)
        _G.LianConfig.SmartTowerAI = Value
        saveConfig()
    end,
})

TowerTab:CreateToggle({
    Name = "Auto Equip Best Tower Team Sebelum Serang",
    CurrentValue = _G.LianConfig.AutoEquipTowerTeam,
    Callback = function(Value)
        _G.LianConfig.AutoEquipTowerTeam = Value
        saveConfig()
    end,
})

do
    local _tg
    _tg = TowerTab:CreateToggle({
        Name = "🔥 Force Equip Best Tower Team Sekarang",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            fire(R.BestTeam)
            Rayfield:Notify({ Title = "Tower Team", Content = "Best Tower Team berhasil dipasang!", Duration = 3 })
            task.spawn(function()
                task.wait(0.5)
                pcall(function() _tg:Set(false) end)
            end)
        end,
    })
end

TowerTab:CreateSection("🎯 Manual Tower / Target Farming")

TowerTab:CreateDropdown({
    Name = "Pilih Tower Tertentu (Farming Potion Spesifik)",
    Options = {"Infinity Tower", "Dragon Tower", "Cursed Tower", "Pirate Tower", "Hidden Leaf Tower", "Slayer Tower", "Shadow Tower"},
    CurrentOption = _G.LianConfig.TowerType,
    Callback = function(Option)
        _G.LianConfig.TowerType = type(Option) == "table" and Option[1] or Option
        saveConfig()
    end,
})

TowerTab:CreateToggle({
    Name = "Auto Attack Manual Tower Pilihan",
    CurrentValue = _G.LianConfig.AutoTower,
    Callback = function(Value)
        _G.LianConfig.AutoTower = Value
        saveConfig()
    end,
})

-- TAB 6: PLOT CASH & QUESTS
PlotTab:CreateSection("💰 Plot Management")

do
    local _tg
    _tg = PlotTab:CreateToggle({
        Name = "🔍 Check Game Updates (Diagnose Broken Features)",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            task.spawn(function()
                task.wait(0.5)
                pcall(function() _tg:Set(false) end)
            end)
            task.spawn(function()
                local ok, res = pcall(_G.LianHubCheckUpdates)
                if not ok then
                    Rayfield:Notify({ Title = "Game Update Check", Content = "Error: " .. tostring(res), Duration = 6 })
                    return
                end
                local broken = 0
                for _, r in ipairs(res or {}) do
                    if type(r) == "string" and r:find("❌") then broken = broken + 1 end
                end
                Rayfield:Notify({
                    Title = "Game Update Check",
                    Content = broken .. " broken out of " .. #(res or {}) .. " checks. Cek F9 console!",
                    Duration = 6
                })
            end)
        end,
    })
end

PlotTab:CreateToggle({
    Name = "Auto Collect Cash Plot (Semua Slot 1-20)",
    CurrentValue = _G.LianConfig.AutoCollectCash,
    Callback = function(Value)
        _G.LianConfig.AutoCollectCash = Value
        saveConfig()
    end,
})

PlotTab:CreateToggle({
    Name = "Auto Level Up Plot Slots",
    CurrentValue = _G.LianConfig.AutoLevelUpSlots,
    Callback = function(Value)
        _G.LianConfig.AutoLevelUpSlots = Value
        saveConfig()
    end,
})

PlotTab:CreateSection("📜 Quests & Rewards")

PlotTab:CreateToggle({
    Name = "Auto Claim Daily Rewards",
    CurrentValue = _G.LianConfig.AutoDailyReward,
    Callback = function(Value)
        _G.LianConfig.AutoDailyReward = Value
        saveConfig()
    end,
})

PlotTab:CreateToggle({
    Name = "Auto Claim Offline Earnings (Saat Join)",
    CurrentValue = _G.LianConfig.AutoClaimOffline,
    Callback = function(Value)
        _G.LianConfig.AutoClaimOffline = Value
        saveConfig()
    end,
})

PlotTab:CreateToggle({
    Name = "Auto Spin Lucky Wheel (Free Spins)",
    CurrentValue = _G.LianConfig.AutoLuckySpin,
    Callback = function(Value)
        _G.LianConfig.AutoLuckySpin = Value
        saveConfig()
    end,
})

PlotTab:CreateToggle({
    Name = "Auto Redeem Promo Codes",
    CurrentValue = _G.LianConfig.AutoRedeemCodes,
    Callback = function(Value)
        _G.LianConfig.AutoRedeemCodes = Value
        saveConfig()
    end,
})

-- TAB 6b: UNIT GRADES
GradesTab:CreateSection("🧬 Auto Roll Unit Grades")

GradesTab:CreateToggle({
    Name = "Auto Roll Unit Grades (Sampai Target Rarity)",
    CurrentValue = _G.LianConfig.AutoUnitGrades,
    Callback = function(Value)
        _G.LianConfig.AutoUnitGrades = Value
        saveConfig()
    end,
})

GradesTab:CreateToggle({
    Name = "Auto Protect High Grades (Jangan Jual)",
    CurrentValue = _G.LianConfig.ProtectHighGrades,
    Callback = function(Value)
        _G.LianConfig.ProtectHighGrades = Value
        saveConfig()
    end,
})

GradesTab:CreateToggle({
    Name = "Roll Grade Once (Sekali Roll Lalu Stop)",
    CurrentValue = _G.LianConfig.RollGradeOnce,
    Callback = function(Value)
        _G.LianConfig.RollGradeOnce = Value
        saveConfig()
    end,
})

GradesTab:CreateSection("🔒 Protect Units (Shiny & Haunted)")

GradesTab:CreateToggle({
    Name = "Protect Shiny Units (Jangan Auto-Sell)",
    CurrentValue = _G.LianConfig.ProtectShiny,
    Callback = function(Value)
        _G.LianConfig.ProtectShiny = Value
        saveConfig()
    end,
})

GradesTab:CreateToggle({
    Name = "Protect Haunted Units (Jangan Auto-Sell)",
    CurrentValue = _G.LianConfig.ProtectHaunted,
    Callback = function(Value)
        _G.LianConfig.ProtectHaunted = Value
        saveConfig()
    end,
})

GradesTab:CreateToggle({
    Name = "Auto-Sell Shiny Units (Override Protect)",
    CurrentValue = _G.LianConfig.AutoSellShiny,
    Callback = function(Value)
        _G.LianConfig.AutoSellShiny = Value
        saveConfig()
    end,
})

GradesTab:CreateToggle({
    Name = "Auto-Sell Haunted Units (Override Protect)",
    CurrentValue = _G.LianConfig.AutoSellHaunted,
    Callback = function(Value)
        _G.LianConfig.AutoSellHaunted = Value
        saveConfig()
    end,
})

-- TAB 6c: TELEPORT
TeleportTab:CreateSection("📍 Teleport Destinations")

do
    local _tg
    _tg = TeleportTab:CreateToggle({
        Name = "🏠 Teleport ke Plot Sendiri",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            task.spawn(function()
                task.wait(0.5)
                pcall(function() _tg:Set(false) end)
            end)
            local plot = findMyPlot()
            if plot and teleportToTarget(plot:FindFirstChild("Spawn") or plot) then
                Rayfield:Notify({ Title = "Teleport", Content = "Berhasil teleport ke Plot sendiri!", Duration = 2.5 })
            else
                Rayfield:Notify({ Title = "Teleport", Content = "Plot belum ditemukan!", Duration = 3 })
            end
        end,
    })
end

do
    local _tg
    _tg = TeleportTab:CreateToggle({
        Name = "🎲 Teleport ke Dice Shop",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            task.spawn(function()
                task.wait(0.5)
                pcall(function() _tg:Set(false) end)
            end)
            local target = findZoneOrStation({"Shop", "DiceShop", "Dice", "Merchant"})
            if target and teleportToTarget(target) then
                Rayfield:Notify({ Title = "Teleport", Content = "Teleported ke Dice Shop!", Duration = 2.5 })
            else
                Rayfield:Notify({ Title = "Teleport", Content = "Dice Shop tidak ditemukan!", Duration = 3 })
            end
        end,
    })
end

do
    local _tg
    _tg = TeleportTab:CreateToggle({
        Name = "🔄 Teleport ke Rebirth Station",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            task.spawn(function()
                task.wait(0.5)
                pcall(function() _tg:Set(false) end)
            end)
            local target = findZoneOrStation({"Rebirth", "RebirthStation", "Quirks"})
            if target and teleportToTarget(target) then
                Rayfield:Notify({ Title = "Teleport", Content = "Teleported ke Rebirth / Quirk Station!", Duration = 2.5 })
            else
                Rayfield:Notify({ Title = "Teleport", Content = "Station tidak ditemukan!", Duration = 3 })
            end
        end,
    })
end

do
    local _tg
    _tg = TeleportTab:CreateToggle({
        Name = "🧬 Teleport ke Fusing Station",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            task.spawn(function()
                task.wait(0.5)
                pcall(function() _tg:Set(false) end)
            end)
            local target = findZoneOrStation({"Fusing", "Fuse", "Grades", "Traits"})
            if target and teleportToTarget(target) then
                Rayfield:Notify({ Title = "Teleport", Content = "Teleported ke Fusing / Grade Station!", Duration = 2.5 })
            else
                Rayfield:Notify({ Title = "Teleport", Content = "Fusing Station tidak ditemukan!", Duration = 3 })
            end
        end,
    })
end

do
    local _tg
    _tg = TeleportTab:CreateToggle({
        Name = "📋 Teleport ke Quest Board",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            task.spawn(function()
                task.wait(0.5)
                pcall(function() _tg:Set(false) end)
            end)
            local target = findZoneOrStation({"Quests", "QuestBoard", "Towers"})
            if target and teleportToTarget(target) then
                Rayfield:Notify({ Title = "Teleport", Content = "Teleported ke Quest / Tower Zone!", Duration = 2.5 })
            else
                Rayfield:Notify({ Title = "Teleport", Content = "Quest Board tidak ditemukan!", Duration = 3 })
            end
        end,
    })
end

do
    local _tg
    _tg = TeleportTab:CreateToggle({
        Name = "🎒 Teleport ke Backpack / Inventory",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            task.spawn(function()
                task.wait(0.5)
                pcall(function() _tg:Set(false) end)
            end)
            local target = findZoneOrStation({"Quirks", "Index", "Backpack", "Inventory"}) or findMyPlot()
            if target and teleportToTarget(target) then
                Rayfield:Notify({ Title = "Teleport", Content = "Teleported!", Duration = 2.5 })
            else
                Rayfield:Notify({ Title = "Teleport", Content = "Target tidak ditemukan!", Duration = 3 })
            end
        end,
    })
end

TeleportTab:CreateSection("👥 Teleport ke Player")

TeleportTab:CreateInput({
    Name = "Username Target",
    PlaceholderText = "Masukkan username player...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        _G.LianConfig.TeleportTarget = Text:gsub("%s+", "")
    end,
})

do
    local _tg
    _tg = TeleportTab:CreateToggle({
        Name = "➡️ Teleport ke Player",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            task.spawn(function()
                task.wait(0.5)
                pcall(function() _tg:Set(false) end)
            end)
            local target = _G.LianConfig.TeleportTarget
            if not target or target == "" then
                Rayfield:Notify({ Title = "Teleport", Content = "Masukkan username dulu!", Duration = 3 })
                return
            end
            for _, p in pairs(Players:GetPlayers()) do
                if p.Name:lower():find(target:lower(), 1, true) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if teleportToTarget(p.Character.HumanoidRootPart) then
                        Rayfield:Notify({ Title = "Teleport", Content = "Teleported ke " .. p.Name, Duration = 3 })
                        return
                    end
                end
            end
            Rayfield:Notify({ Title = "Teleport", Content = "Player tidak ditemukan!", Duration = 3 })
        end,
    })
end

do
    local _tg
    _tg = TeleportTab:CreateToggle({
        Name = "🎲 Teleport ke Random Player",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            task.spawn(function()
                task.wait(0.5)
                pcall(function() _tg:Set(false) end)
            end)
            local others = {}
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(others, p)
                end
            end
            if #others > 0 then
                local pick = others[math.random(1, #others)]
                if teleportToTarget(pick.Character.HumanoidRootPart) then
                    Rayfield:Notify({ Title = "Teleport", Content = "Teleported ke " .. pick.Name, Duration = 3 })
                end
            else
                Rayfield:Notify({ Title = "Teleport", Content = "Tidak ada player lain!", Duration = 3 })
            end
        end,
    })
end

-- TAB 6d: ESP & VISUALS
ESPSettingsTab:CreateSection("👁️ Player ESP")

ESPSettingsTab:CreateToggle({
    Name = "Player Name ESP",
    CurrentValue = _G.LianConfig.PlayerESP,
    Callback = function(Value)
        _G.LianConfig.PlayerESP = Value
        saveConfig()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local head = p.Character:FindFirstChild("Head")
                if head then
                    local esp = head:FindFirstChild("LianESP")
                    if Value and not esp then
                        applyPlayerEspToChar(p, p.Character)
                    elseif not Value and esp then
                        esp:Destroy()
                    end
                end
            end
        end
    end,
})

ESPSettingsTab:CreateSection("💡 Fullbright")

ESPSettingsTab:CreateToggle({
    Name = "Fullbright (Max Brightness)",
    CurrentValue = _G.LianConfig.Fullbright,
    Callback = function(Value)
        _G.LianConfig.Fullbright = Value
        saveConfig()
        pcall(function()
            if Value then
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
                Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            else
                Lighting.Brightness = 1
                Lighting.GlobalShadows = true
            end
        end)
    end,
})

ESPSettingsTab:CreateSection("🔄 Rejoin & Server")

do
    local _tg
    _tg = ESPSettingsTab:CreateToggle({
        Name = "🔄 Rejoin Server Sekarang",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            setupAutoExecuteOnTeleport()
            task.spawn(function()
                task.wait(0.5)
                pcall(function() _tg:Set(false) end)
            end)
            task.spawn(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
        end,
    })
end

ESPSettingsTab:CreateToggle({
    Name = "🔄 Auto Reconnect (Saat Disconnect)",
    CurrentValue = _G.LianConfig.AutoReconnect,
    Callback = function(Value)
        _G.LianConfig.AutoReconnect = Value
        saveConfig()
    end,
})

ESPSettingsTab:CreateToggle({
    Name = "Trade Requests (On/Off)",
    CurrentValue = _G.LianConfig.TradeRequests,
    Callback = function(Value)
        _G.LianConfig.TradeRequests = Value
        saveConfig()
        if R.TradeToggle then
            fire(R.TradeToggle, Value)
        end
    end,
})

ESPSettingsTab:CreateSection("⚡ Performance")

ESPSettingsTab:CreateSlider({
    Name = "JumpPower (50-250)",
    Range = {50, 250},
    Increment = 1,
    Suffix = "jp",
    CurrentValue = _G.LianConfig.JumpPowerValue or 50,
    Flag = "JumpPowerSlider",
    Callback = function(Value)
        _G.LianConfig.JumpPowerValue = Value
        saveConfig()
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = Value
            end
        end)
    end,
})

-- TAB 7: REBIRTH & STATS
RebirthTab:CreateSection("🧬 Smart Rebirth Engine")

RebirthTab:CreateToggle({
    Name = "Auto Rebirth (HANYA Saat Uang Cukup — No Spam)",
    CurrentValue = _G.LianConfig.AutoRebirth,
    Callback = function(Value)
        _G.LianConfig.AutoRebirth = Value
        saveConfig()
    end,
})

RebirthTab:CreateToggle({
    Name = "Auto Alloc Rebirth Stats (Alokasi stat otomatis)",
    CurrentValue = _G.LianConfig.AutoAllocStats,
    Callback = function(Value)
        _G.LianConfig.AutoAllocStats = Value
        saveConfig()
    end,
})

RebirthTab:CreateDropdown({
    Name = "Prioritas Alokasi Stat Rebirth",
    Options = {
        "Balance / Rata (Money, Luck, Damage, Health, Trait Luck, Grade Luck)",
        "Fokus Money / Income Dulu",
        "Fokus Luck Dulu",
        "Fokus Damage Dulu",
        "Fokus Health Dulu"
    },
    CurrentOption = _G.LianConfig.RebirthStatPriority,
    Callback = function(Option)
        _G.LianConfig.RebirthStatPriority = type(Option) == "table" and Option[1] or Option
        saveConfig()
    end,
})

RebirthTab:CreateSection("🛒 Upgrades Pohon Dadu (Fortune dll)")

RebirthTab:CreateToggle({
    Name = "Auto Beli Upgrades Pohon (Fortune & Upgrades Dekat Dadu)",
    CurrentValue = _G.LianConfig.AutoBuyTreeUpgrades,
    Callback = function(Value)
        _G.LianConfig.AutoBuyTreeUpgrades = Value
        saveConfig()
    end,
})

RebirthTab:CreateSection("🌾 Plot Optimization & Auto-Sell Luar Plot")

RebirthTab:CreateToggle({
    Name = "Auto Equip Best ke Plot & Auto-Sell Sisanya (No Lock/Rarity)",
    CurrentValue = _G.LianConfig.AutoEquipBestPlotAndSellRest,
    Callback = function(Value)
        _G.LianConfig.AutoEquipBestPlotAndSellRest = Value
        saveConfig()
        if Value then
            task.spawn(equipBestPlotAndSellOutside)
        end
    end,
})

do
    local _tg
    _tg = RebirthTab:CreateToggle({
        Name = "⚡ Equip Best ke Plot & Jual Semua di Luar Plot Sekarang",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            task.spawn(equipBestPlotAndSellOutside)
            task.spawn(function()
                task.wait(0.5)
                pcall(function() _tg:Set(false) end)
            end)
        end,
    })
end

-- TAB 8: SERVER LUCK HUNTER
ServerTab:CreateSection("🌐 Smart Server Hop (Anti Duplikasi & Silent)")

ServerTab:CreateToggle({
    Name = "Auto Hop Cari Server Luck Event (Bloodmoon/Eclipse)",
    CurrentValue = _G.LianConfig.ServerLuckHop,
    Callback = function(Value)
        _G.LianConfig.ServerLuckHop = Value
        saveConfig()
    end,
})

do
    local _tg
    _tg = ServerTab:CreateToggle({
        Name = "🔄 Force Hop ke Server Lain Sekarang",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            task.spawn(function()
                task.wait(0.5)
                pcall(function() _tg:Set(false) end)
            end)
            task.spawn(function()
                setupAutoExecuteOnTeleport()
                local placeId = game.PlaceId
                local apiUrl = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"
                local raw = game:HttpGet(apiUrl)
                local ok, res = false, nil
                if raw then
                    ok, res = pcall(function() return HttpService:JSONDecode(raw) end)
                end
                local hopped = false
                if ok and res and res.data then
                    for _, s in ipairs(res.data) do
                        if s.id ~= game.JobId and s.playing < s.maxPlayers - 1 then
                            TeleportService:TeleportToPlaceInstance(placeId, s.id, LocalPlayer)
                            hopped = true
                            break
                        end
                    end
                end
                if not hopped then
                    TeleportService:Teleport(placeId, LocalPlayer)
                end
            end)
        end,
    })
end

-- TAB 9: DISCORD WEBHOOK TELEMETRY
WebhookTab:CreateSection("📡 Notifikasi Drop ke Discord HP")

WebhookTab:CreateInput({
    Name = "Discord Webhook URL",
    PlaceholderText = "Paste webhook discord di sini...",
    RemoveTextAfterFocusLost = false,
    CurrentValue = _G.LianConfig.DiscordWebhook,
    Callback = function(Text)
        _G.LianConfig.DiscordWebhook = Text:gsub("%s+", "")
        saveConfig()
    end,
})

do
    local _tg
    _tg = WebhookTab:CreateToggle({
        Name = "🔔 Test Kirim Webhook Sekarang",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            task.spawn(function()
                task.wait(0.5)
                pcall(function() _tg:Set(false) end)
            end)
            task.spawn(function()
                sendDiscordWebhook("🔔 Test Webhook Lian Hub v7.0", "Koneksi webhook dari akun **" .. LocalPlayer.Name .. "** berhasil!", 65280)
                pcall(function()
                    Rayfield:Notify({ Title = "Webhook Terkirim!", Content = "Cek channel Discord Bubu yaa!", Duration = 3 })
                end)
            end)
        end,
    })
end

-- TAB 10: POTATO OPTIMIZER & GPU SAVER
PerfTab:CreateSection("❄️ Extreme Multi-Account Optimizer")

PerfTab:CreateToggle({
    Name = "Matikan Render 3D (0% GPU Usage Mode)",
    CurrentValue = _G.LianConfig.Disable3DRendering,
    Callback = function(Value)
        _G.LianConfig.Disable3DRendering = Value
        saveConfig()
        pcall(function()
            RunService:Set3dRenderingEnabled(not Value)
        end)
    end,
})

PerfTab:CreateToggle({
    Name = "Extreme Potato Mode (Tekstur Plastik, No Partikel)",
    CurrentValue = _G.LianConfig.ExtremePotatoMode,
    Callback = function(Value)
        _G.LianConfig.ExtremePotatoMode = Value
        saveConfig()
        applyPotatoMode(Value)
    end,
})

PerfTab:CreateSlider({
    Name = "FPS Cap Tuyul",
    Range = {10, 60},
    Increment = 5,
    Suffix = " FPS",
    CurrentValue = _G.LianConfig.TargetFPS,
    Callback = function(Value)
        _G.LianConfig.TargetFPS = Value
        saveConfig()
        pcall(function() if setfpscap then setfpscap(Value) end end)
    end,
})

-- TAB 11: PLAYER & MOVEMENT
PlayerTab:CreateSection("🏃 Movement Enhancements")

PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 150},
    Increment = 2,
    CurrentValue = _G.LianConfig.WalkSpeedValue or 16,
    Callback = function(Value)
        _G.LianConfig.WalkSpeedValue = Value
        saveConfig()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = _G.LianConfig.InfJump,
    Callback = function(Value)
        _G.LianConfig.InfJump = Value
        saveConfig()
    end,
})

trackConn(UserInputService.JumpRequest:Connect(function()
    if isAlive() and _G.LianConfig.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

PlayerTab:CreateToggle({
    Name = "Noclip (Tembus Dinding)",
    CurrentValue = _G.LianConfig.Noclip,
    Callback = function(Value)
        _G.LianConfig.Noclip = Value
        saveConfig()
        if not Value and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end,
})

local wasNoclip = false
trackConn(RunService.Stepped:Connect(function()
    if not isAlive() then return end
    if LocalPlayer.Character then
        local noclipOn = _G.LianConfig.Noclip
        if noclipOn then
            wasNoclip = true
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        elseif wasNoclip then
            wasNoclip = false
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
end))

end -- close if Window

-- ═════════════════════════════════════════════════════════════════════
-- 🚀 MASTER 100% VERIFIED ANIME DICE BACKGROUND WORKERS (Generation-Guarded)
-- ═════════════════════════════════════════════════════════════════════

-- 1. Auto Roll Dice Worker (RollService.RE.SetAutoRoll + RollService.RF.RollDice)
trackThread(task.spawn(function()
    local autoRollState = false
    while isAlive() do
        if _G.LianConfig.AutoRoll then
            if not autoRollState then
                fire(R.SetAutoRoll, true)
                autoRollState = true
                if R.UpdAutoSell then
                    fire(R.UpdAutoSell, 1000)
                end
            end
            local rollDur = 2.5
            if M.Buff and type(M.Buff.GetBuff) == "function" then
                local okB, d = pcall(M.Buff.GetBuff, "Roll Duration")
                if okB and type(d) == "number" and d > 0 then
                    rollDur = d
                end
            end
            -- FastRoll paces interval to minimum server limit without flooding
            local waitTime = _G.LianConfig.FastRoll and math.max(0.4, rollDur * 0.75) or math.max(0.5, rollDur + 0.1)
            task.wait(waitTime)
        else
            if autoRollState then
                fire(R.SetAutoRoll, false)
                autoRollState = false
            end
            task.wait(0.5)
        end
    end
end))

-- 2. Auto Buy Best Dice & Auto Equip Best Owned Dice Worker (DiceShopService.RE.BuyDice / EquipDice)
trackThread(task.spawn(function()
    while isAlive() do
        if _G.LianConfig.AutoBuyDice then
            local diceList = getAllDiceList()
            local owned = readData("OwnedDice", {}) or {}
            local curEquipped = tostring(readData("Dice", "Basic Dice") or "Basic Dice")
            local curLuck = 0
            for _, d in ipairs(diceList) do
                if d.name == curEquipped then
                    curLuck = d.luck
                    break
                end
            end

            for i = #diceList, 1, -1 do
                local d = diceList[i]
                local isOwned = (owned[d.name] == true) or (tonumber(owned[d.name]) or 0) > 0
                if not isOwned and canAffordSpend(d.price) and R.BuyDice then
                    fire(R.BuyDice, d.name)
                    break -- Purchase single best affordable dice in this cycle
                end
            end

            owned = readData("OwnedDice", {}) or {}
            local bestName, bestLuck = curEquipped, curLuck
            for _, d in ipairs(diceList) do
                local isOwned = (owned[d.name] == true) or (tonumber(owned[d.name]) or 0) > 0
                if isOwned and d.luck > bestLuck then
                    bestName, bestLuck = d.name, d.luck
                end
            end
            if bestName ~= curEquipped and R.EquipDice then
                fire(R.EquipDice, bestName)
            end
            task.wait(2.5)
        else
            task.wait(1.0)
        end
    end
end))

-- 3. Auto Unit Grades & Traits Worker (GradeService.RE.Roll(unitUUID) + SetGradeProtected)
trackThread(task.spawn(function()
    local protectedSynced = false
    while isAlive() do
        if _G.LianConfig.AutoUnitGrades then
            if _G.LianConfig.ProtectHighGrades and not protectedSynced and R.GradeProtect then
                for _, gName in ipairs({"S", "SS", "SSS"}) do
                    fire(R.GradeProtect, gName, true)
                    task.wait(0.05)
                end
                protectedSynced = true
            end

            local inv = readData("Inventory", {}) or {}
            local slots = readData("Slots", {}) or {}
            local targetUUID = nil

            -- Prefer rolling grades on equipped plot units first
            for _, val in pairs(slots) do
                local uuid = type(val) == "string" and val or (type(val) == "table" and (val.unitId or val.key))
                local entry = uuid and inv[uuid]
                if type(entry) == "table" then
                    local attrs = type(entry.attributes) == "table" and entry.attributes or entry
                    local g = tostring(attrs.grade or entry.Grade or ""):upper()
                    if (GRADE_ORDER[g] or 0) < 7 then -- below S
                        targetUUID = uuid
                        break
                    end
                end
            end

            -- Fallback: any unit in inventory below S grade
            if not targetUUID then
                for uuid, entry in pairs(inv) do
                    if isUnitEntry(uuid, entry) then
                        local attrs = type(entry.attributes) == "table" and entry.attributes or entry
                        local g = tostring(attrs.grade or entry.Grade or ""):upper()
                        if (GRADE_ORDER[g] or 0) < 7 then
                            targetUUID = uuid
                            break
                        end
                    end
                end
            end

            if targetUUID and R.GradeRoll then
                fire(R.GradeRoll, targetUUID)
                if _G.LianConfig.RollGradeOnce then
                    _G.LianConfig.AutoUnitGrades = false
                    saveConfig()
                end
            end
            task.wait(0.5)
        else
            protectedSynced = false
            task.wait(0.8)
        end
    end
end))

-- 4. Auto Quirk Reroll Hunter Worker (QuirkService.RE.Roll(unitUUID) + Zone Auto-Teleport)
trackThread(task.spawn(function()
    local quirkProtectedSynced = false
    while isAlive() do
        if _G.LianConfig.AutoQuirk and R.QuirkRoll then
            if not quirkProtectedSynced and R.QuirkProtect then
                for qName in pairs(RARE_QUIRKS) do
                    fire(R.QuirkProtect, qName, true)
                    task.wait(0.05)
                end
                quirkProtectedSynced = true
            end

            -- Ensure character is near Workspace.Zones.Quirks so server accepts QuirkService.RE.Roll
            local qZone = Workspace:FindFirstChild("Zones") and Workspace.Zones:FindFirstChild("Quirks")
            local hrp = LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if qZone and hrp then
                local qPos = (qZone:IsA("BasePart") and qZone.Position) or (qZone:IsA("Model") and qZone:GetPivot().Position)
                if qPos and (hrp.Position - qPos).Magnitude > 22 then
                    teleportToTarget(qZone)
                    task.wait(0.4)
                end
            end

            local inv = readData("Inventory", {}) or {}
            local slots = readData("Slots", {}) or {}
            local candidateUUID = nil

            for _, val in pairs(slots) do
                local uuid = type(val) == "string" and val or (type(val) == "table" and (val.unitId or val.key))
                local entry = uuid and inv[uuid]
                if type(entry) == "table" then
                    local attrs = type(entry.attributes) == "table" and entry.attributes or entry
                    local q = tostring(attrs.quirk or "")
                    if not RARE_QUIRKS[q] then
                        candidateUUID = uuid
                        break
                    end
                end
            end

            if not candidateUUID then
                for uuid, entry in pairs(inv) do
                    if isUnitEntry(uuid, entry) then
                        local attrs = type(entry.attributes) == "table" and entry.attributes or entry
                        local q = tostring(attrs.quirk or "")
                        if not RARE_QUIRKS[q] then
                            candidateUUID = uuid
                            break
                        end
                    end
                end
            end

            if candidateUUID then
                fire(R.QuirkRoll, candidateUUID)
            end
            task.wait(0.35)
        else
            quirkProtectedSynced = false
            task.wait(0.8)
        end
    end
end))

-- 5. Auto Roll Halloween Pumpkin Dice Worker (PumpkinDiceService.RF.Roll)
trackThread(task.spawn(function()
    while isAlive() do
        if _G.LianConfig.AutoRollHalloween and R.PumpkinRoll then
            local opt = _G.LianConfig.HalloweenRollOption or ""
            local rollCount = opt:find("100") and 1 or 5
            task.spawn(function()
                invoke(R.PumpkinRoll, rollCount)
            end)
            task.wait(0.4)
        else
            task.wait(0.8)
        end
    end
end))

-- 6. Auto Potions, Spins, Gamepass & Best Gear Worker (BoostService + SpinService + GearService)
trackThread(task.spawn(function()
    while isAlive() do
        if _G.LianConfig.AutoPotions or _G.LianConfig.AutoLuckySpin then
            local inv = readData("Inventory", {}) or {}
            for key, e in pairs(inv) do
                if not isAlive() then break end
                local amt = (type(e) == "table" and tonumber(e.amount)) or (type(e) == "number" and e) or 0
                if amt > 0 then
                    local name = (type(e) == "table" and tostring(e.name or key)) or tostring(key)
                    local cfg = getEntryCfg(name)
                    local kind = cfg and cfg.kind or nil

                    if _G.LianConfig.AutoPotions and (kind == "Boost" or name:find("Boost") or name:find("Potion") or name:find("Leaf") or name:find("Brew")) then
                        local cat = tostring((cfg and cfg.category) or name)
                        local drink = false
                        if _G.LianConfig.PotionUseLuck and cat:find("Luck") then drink = true
                        elseif _G.LianConfig.PotionUseIncome and (cat:find("Income") or cat:find("Money") or cat:find("Million")) then drink = true
                        elseif _G.LianConfig.PotionUseDamage and (cat:find("Damage") or cat:find("Slayer")) then drink = true
                        elseif _G.LianConfig.PotionUseSpeed and cat:find("Speed") then drink = true
                        elseif _G.LianConfig.PotionUseHalloween and (cat:find("Haunted") or cat:find("Pumpkin") or cat:find("Candy") or cat:find("Witch")) then drink = true
                        elseif _G.LianConfig.PotionUseTower and (cat:find("Tower") or cat:find("Shadow") or cat:find("Pirate")) then drink = true
                        end
                        if drink and R.Boost then
                            fire(R.Boost, key)
                            task.wait(0.25)
                        end
                    elseif _G.LianConfig.AutoLuckySpin and (kind == "Spin" or name:find("Spin") or name:find("Lucky Roll")) then
                        if R.Spin then
                            fire(R.Spin, key)
                            task.wait(0.25)
                        end
                    elseif kind == "Gamepass" and R.GamepassUse then
                        fire(R.GamepassUse, key)
                        task.wait(0.25)
                    end
                end
            end
            task.wait(3.0)
        else
            task.wait(1.0)
        end
    end
end))

-- 7. Auto Rebirth Worker (RebirthService.RE.Rebirth)
trackThread(task.spawn(function()
    while isAlive() do
        if _G.LianConfig.AutoRebirth and R.Rebirth then
            local canRebirth, curCash = canAffordRebirth()
            if canRebirth then
                fire(R.Rebirth)
                pcall(function()
                    Rayfield:Notify({ Title = "Rebirth Sukses!", Content = "Uang cukup ($" .. math.floor(curCash) .. "). Rebirth diproses!", Duration = 3 })
                end)
                task.wait(1.5)
                if R.EquipBest then fire(R.EquipBest) end
            end
            task.wait(2.0)
        else
            task.wait(1.0)
        end
    end
end))

-- 8. Rebirth Stats Allocation Worker (RebirthService.RE.AddStat: Income, Luck, RollSpeed, WalkSpeed)
trackThread(task.spawn(function()
    while isAlive() do
        if _G.LianConfig.AutoAllocStats and R.AddStat then
            local pts = getAvailableStatPoints()
            if pts > 0 then
                local prio = _G.LianConfig.RebirthStatPriority or ""
                local statList = { "Luck", "Money", "Damage", "Health", "Trait Luck", "Grade Luck" }
                if prio:find("Money") or prio:find("Income") then
                    statList = { "Money", "Luck", "Damage" }
                elseif prio:find("Luck") then
                    statList = { "Luck", "Money", "Damage" }
                elseif prio:find("Damage") or prio:find("Speed") then
                    statList = { "Damage", "Luck", "Money" }
                elseif prio:find("Health") then
                    statList = { "Health", "Luck", "Money" }
                end
                local curStats = table.clone(readData("RebirthStats", {}) or {})
                for _ = 1, math.min(pts, 12) do
                    local pick, low = nil, math.huge
                    for _, sName in ipairs(statList) do
                        local c = tonumber(curStats[sName]) or 0
                        if c < low then
                            pick, low = sName, c
                        end
                    end
                    if not pick then break end
                    curStats[pick] = low + 1
                    fire(R.AddStat, pick)
                    task.wait(0.15)
                end
            end
            task.wait(2.5)
        else
            task.wait(1.0)
        end
    end
end))

-- 9. Auto Buy Tree Upgrades Worker (Network.RE.BuyUpgrade)
trackThread(task.spawn(function()
    while isAlive() do
        if _G.LianConfig.AutoBuyTreeUpgrades then
            buyUpgradesTree()
            task.wait(2.5)
        else
            task.wait(1.0)
        end
    end
end))

-- 10. Smart Tower AI & Manual Tower Worker (PlayTower + CompleteTowerFloor Loop + CancelTower Recovery)
trackThread(task.spawn(function()
    local TOWER_FALLBACK_ORDER = { "Infinity Tower", "Dragon Tower", "Cursed Tower", "Pirate Tower", "Hidden Leaf Tower", "Slayer Tower", "Shadow Tower" }
    while isAlive() do
        if _G.LianConfig.SmartTowerAI or _G.LianConfig.AutoTower then
            if R.SetAutoTower then
                fire(R.SetAutoTower, false)
            end
            if _G.LianConfig.AutoEquipTowerTeam and R.BestTeam then
                fire(R.BestTeam)
                task.wait(0.6)
            end

            -- Build list of candidate towers from live game module or fallback
            local towerCandidates = {}
            if _G.LianConfig.SmartTowerAI then
                if M.Towers and type(M.Towers.GetAll) == "function" then
                    local okT, allT = pcall(M.Towers.GetAll)
                    if okT and type(allT) == "table" then
                        for tName in pairs(allT) do
                            table.insert(towerCandidates, tName)
                        end
                    end
                end
                if #towerCandidates == 0 then
                    towerCandidates = TOWER_FALLBACK_ORDER
                end
            else
                table.insert(towerCandidates, _G.LianConfig.TowerType or "Shadow Tower")
                for _, fb in ipairs(TOWER_FALLBACK_ORDER) do
                    if fb ~= _G.LianConfig.TowerType then
                        table.insert(towerCandidates, fb)
                    end
                end
            end

            if R.PlayTower and R.FloorTower then
                for _, tName in ipairs(towerCandidates) do
                    if not isAlive() or not (_G.LianConfig.SmartTowerAI or _G.LianConfig.AutoTower) then break end
                    local started = false
                    local doneStart = false
                    task.spawn(function()
                        local res = invoke(R.PlayTower, tName)
                        started = (res == true or type(res) == "table")
                        doneStart = true
                    end)
                    local t0 = os.clock()
                    while not doneStart and os.clock() - t0 < 6 do
                        task.wait(0.15)
                    end

                    if not started and R.CancelTower then
                        invoke(R.CancelTower)
                        if R.FloorTower then
                            for _ = 1, 10 do
                                local dRes = invoke(R.FloorTower)
                                if type(dRes) == "table" and dRes.action == "ended" then break end
                                task.wait(0.15)
                            end
                        end
                        task.wait(3.2)
                    elseif started then
                        for _ = 1, 60 do
                            if not isAlive() or not (_G.LianConfig.SmartTowerAI or _G.LianConfig.AutoTower) then break end
                            local stepDone, stepRes = false, nil
                            task.spawn(function()
                                stepRes = invoke(R.FloorTower)
                                stepDone = true
                            end)
                            local ft0 = os.clock()
                            while not stepDone and os.clock() - ft0 < 5 do
                                task.wait(0.1)
                            end
                            if not stepDone or not stepRes or stepRes == "destroyed" then break end
                            if type(stepRes) == "table" then
                                if stepRes.action == "ended" then break end
                                local ended = false
                                for _, a in ipairs(stepRes) do
                                    if type(a) == "table" and a.action == "ended" then
                                        ended = true
                                        break
                                    end
                                end
                                if ended then break end
                            end
                            task.wait(0.25)
                        end
                        break
                    end
                end
            end
            task.wait(4.0)
        else
            task.wait(1.0)
        end
    end
end))

-- 11. Plot Cash Collect & Unit Level Up Worker (PlotService.RE.CollectBalance(slotNum) + PlotService.RE.LevelUpSlot(slotNum))
trackThread(task.spawn(function()
    while isAlive() do
        if _G.LianConfig.AutoCollectCash and R.CollectBalance then
            local slots = readData("Slots", nil)
            if type(slots) == "table" and next(slots) ~= nil then
                for slotKey, val in pairs(slots) do
                    if not _G.LianConfig.AutoCollectCash then break end
                    local sNum = tonumber(slotKey)
                    if sNum then
                        fire(R.CollectBalance, sNum)
                    end
                end
            else
                for slot = 1, 15 do
                    if not _G.LianConfig.AutoCollectCash then break end
                    fire(R.CollectBalance, slot)
                end
            end
        end

        if _G.LianConfig.AutoLevelUpSlots and R.LevelUpSlot then
            local slots = readData("Slots", {}) or {}
            local inv = readData("Inventory", {}) or {}
            local cands = {}
            for slotKey, val in pairs(slots) do
                local sNum = tonumber(slotKey)
                local uuid = type(val) == "string" and val or (type(val) == "table" and (val.unitId or val.key))
                local entry = uuid and inv[uuid]
                if sNum and type(entry) == "table" then
                    local price = 0
                    if M.UnitUtil and type(M.UnitUtil.GetLevelPrice) == "function" then
                        local okP, p = pcall(M.UnitUtil.GetLevelPrice, entry.name, entry.attributes)
                        if okP and type(p) == "number" then price = p end
                    end
                    if canAffordSpend(price) then
                        table.insert(cands, { slot = sNum, price = price })
                    end
                end
            end
            table.sort(cands, function(a, b) return a.price < b.price end)
            for i = 1, math.min(6, #cands) do
                fire(R.LevelUpSlot, cands[i].slot)
                task.wait(0.15)
            end
        end
        task.wait(1.5)
    end
end))

-- 12. Quests (Daily + Weekly), Daily Reward, Offline Earnings, Group Reward & Live Promo Codes Worker
trackThread(task.spawn(function()
    local codeTries = {}
    local groupTries = 0
    local FALLBACK_CODES = {
        "release", "SorryForShutdown", "UPD1", "1MVisits", "10KLikes", "25KLikes",
        "50KLikes", "Halloween", "TrickOrTreat", "Update2", "Quirks", "Dungeon",
        "Shadow", "Dragon", "Lucky", "Sub2Dev", "AnimeDice", "Pumpkin"
    }
    while isAlive() do
        if _G.LianConfig.AutoDailyReward then
            if R.Daily then fire(R.Daily) end
            if R.GroupClaim and readData("ClaimedGroupReward", false) ~= true and groupTries < 3 then
                groupTries = groupTries + 1
                fire(R.GroupClaim)
            end
            -- Auto-claim completed Daily & Weekly Quests via QuestService.RE.Claim(period, id, expiresAt)
            if R.QuestClaim and M.Quests and M.Quests.Periods then
                local d = readData("Quests", {}) or {}
                for period, def in pairs(M.Quests.Periods) do
                    local q = d[period]
                    if type(q) == "table" and type(q.progress) == "table" then
                        local expiresAt = q.expiresAt
                        for _, quest in ipairs(def.quests or {}) do
                            local claimed = q.claimed and q.claimed[quest.id]
                            local prog = tonumber(q.progress[quest.id]) or 0
                            local target = tonumber(quest.target) or math.huge
                            if not claimed and prog >= target then
                                fire(R.QuestClaim, period, quest.id, expiresAt)
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end
        end

        if _G.LianConfig.AutoClaimOffline and R.Offline then
            if (tonumber(readData("PendingOfflineEarnings", 1)) or 1) > 0 then
                fire(R.Offline)
            end
        end

        if _G.LianConfig.AutoRedeemCodes and R.Code then
            local redeemed = readData("RedeemedCodes", {}) or {}
            local allCodes = {}
            local seen = {}
            if type(M.Codes) == "table" then
                for codeName, v in pairs(M.Codes) do
                    if type(codeName) == "string" and type(v) == "table" and not seen[codeName] then
                        seen[codeName] = true
                        table.insert(allCodes, codeName)
                    end
                end
            end
            for _, c in ipairs(FALLBACK_CODES) do
                if not seen[c] then
                    seen[c] = true
                    table.insert(allCodes, c)
                end
            end
            for _, code in ipairs(allCodes) do
                if not _G.LianConfig.AutoRedeemCodes then break end
                if not redeemed[code] and (codeTries[code] or 0) < 2 then
                    codeTries[code] = (codeTries[code] or 0) + 1
                    fire(R.Code, code)
                    task.wait(0.4)
                end
            end
        end
        task.wait(8.0)
    end
end))

-- 13. Auto Equip Best Plot & Sell Rest Worker
trackThread(task.spawn(function()
    local selling = false
    local lastSellStart = 0
    while isAlive() do
        if selling and (os.clock() - lastSellStart > 12) then
            selling = false
        end
        if _G.LianConfig.AutoEquipBestPlotAndSellRest and not selling then
            selling = true
            lastSellStart = os.clock()
            task.spawn(function()
                equipBestPlotAndSellOutside()
                selling = false
            end)
            task.wait(3.5)
        else
            task.wait(1.0)
        end
    end
end))

-- 14. Trick-or-Treat Doors Auto-Tour & Knock Worker
trackThread(task.spawn(function()
    local fpp = fireproximityprompt or (_ENV and _ENV.fireproximityprompt)
    local doorCooldowns = {}
    
    local function getDoorsList()
        local list = {}
        -- 1. CollectionService Tag (Authoritative standard in Anime Dice)
        local tagged = CollectionService:GetTagged("TrickOrTreatDoor")
        if type(tagged) == "table" and #tagged > 0 then
            for _, inst in ipairs(tagged) do
                if inst:IsA("BasePart") or inst:IsA("Model") then
                    table.insert(list, inst)
                end
            end
        end
        -- 2. Workspace Containers & Map Fallbacks
        if #list == 0 then
            local mapContainers = {
                Workspace:FindFirstChild("TrickOrTreat") and Workspace.TrickOrTreat:FindFirstChild("Doors"),
                Workspace:FindFirstChild("Halloween") and Workspace.Halloween:FindFirstChild("Doors"),
                Workspace:FindFirstChild("Halloween") and Workspace.Halloween:FindFirstChild("TrickOrTreat"),
                Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Halloween") and Workspace.Map.Halloween:FindFirstChild("Doors"),
                Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Doors"),
                Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("TrickOrTreat"),
            }
            for _, container in ipairs(mapContainers) do
                if container then
                    for _, child in ipairs(container:GetChildren()) do
                        if child:IsA("BasePart") or child:IsA("Model") then
                            table.insert(list, child)
                        end
                    end
                    if #list > 0 then break end
                end
            end
        end
        -- 3. Recursive fallback under Halloween folders
        if #list == 0 then
            local hw = Workspace:FindFirstChild("Halloween", true)
            if hw then
                for _, inst in ipairs(hw:GetDescendants()) do
                    if inst:IsA("BasePart") and inst.Name:lower():find("door") then
                        table.insert(list, inst)
                    end
                end
            end
        end
        return list
    end

    while isAlive() do
        if _G.LianConfig.AutoTrickOrTreat then
            local char = LocalPlayer and LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local doors = getDoorsList()
                if #doors > 0 then
                    local oldCFrame = hrp.CFrame
                    local now = os.clock()
                    local knockedAny = false
                    
                    for _, door in ipairs(doors) do
                        if not isAlive() or not _G.LianConfig.AutoTrickOrTreat then break end
                        local lastKnock = doorCooldowns[door] or 0
                        if (now - lastKnock) >= 28 then
                            local pivot = nil
                            if door:IsA("BasePart") then
                                pivot = door.CFrame
                            elseif door:IsA("Model") then
                                pivot = door:GetPivot()
                            end
                            
                            if pivot then
                                -- Stand 3.5 studs in front of door, 1.5 studs up
                                local frontCF = pivot * CFrame.new(0, 1.5, 3.5)
                                hrp.CFrame = frontCF
                                task.wait(0.35)
                                
                                -- 1. Trigger ProximityPrompt if available
                                local prompt = door:FindFirstChildOfClass("ProximityPrompt") 
                                    or door:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt and prompt.Enabled then
                                    pcall(function()
                                        prompt.HoldDuration = 0
                                        prompt.RequiresLineOfSight = false
                                        prompt.MaxActivationDistance = 30
                                    end)
                                    if type(fpp) == "function" then
                                        pcall(fpp, prompt)
                                    end
                                    pcall(function() prompt:InputHoldBegin() end)
                                    task.wait(0.05)
                                    pcall(function() prompt:InputHoldEnd() end)
                                end
                                
                                -- 2. Remote Fire Fallback (Knit Network)
                                pcall(function()
                                    local net = RS:FindFirstChild("Network")
                                    if net then
                                        local hwSvc = net:FindFirstChild("HalloweenService")
                                        if hwSvc and hwSvc:FindFirstChild("RE") and hwSvc.RE:FindFirstChild("TrickOrTreat") then
                                            hwSvc.RE.TrickOrTreat:FireServer(door.Name)
                                        end
                                        local totSvc = net:FindFirstChild("TrickOrTreatService")
                                        if totSvc and totSvc:FindFirstChild("RE") and totSvc.RE:FindFirstChild("Knock") then
                                            totSvc.RE.Knock:FireServer(door.Name)
                                        end
                                    end
                                end)
                                
                                doorCooldowns[door] = os.clock()
                                knockedAny = true
                                task.wait(0.4)
                                
                                -- 3. Step back 18 studs to satisfy server re-arm distance (> 17 studs)
                                hrp.CFrame = pivot * CFrame.new(0, 1.5, 18)
                                task.wait(0.2)
                            end
                        end
                    end
                    
                    -- Restore player back to original spot if finished a tour
                    if knockedAny and isAlive() and _G.LianConfig.AutoTrickOrTreat then
                        local curChar = LocalPlayer and LocalPlayer.Character
                        local curHrp = curChar and curChar:FindFirstChild("HumanoidRootPart")
                        if curHrp and oldCFrame then
                            curHrp.CFrame = oldCFrame
                        end
                    end
                end
            end
            task.wait(5.0)
        else
            task.wait(1.5)
        end
    end
end))

-- 15. Halloween Quests & Pumpkin Pass Claim Worker
trackThread(task.spawn(function()
    while isAlive() do
        if _G.LianConfig.AutoHalloweenQuestClaim and R.HalloweenQuest then
            local hw = readData("Halloween", {}) or {}
            for _, period in ipairs({ "Daily", "Hourly" }) do
                local qData = (period == "Daily" and hw.Quests) or hw.HourlyQuests or hw[period]
                if type(qData) == "table" and type(qData.ids) == "table" then
                    local claimed = qData.claimed or {}
                    for _, qid in ipairs(qData.ids) do
                        if not claimed[qid] then
                            fire(R.HalloweenQuest, period, qid)
                            task.wait(0.2)
                        end
                    end
                end
            end
        end
        if _G.LianConfig.AutoPumpkinPass and R.HalloweenPath then
            fire(R.HalloweenPath)
        end
        task.wait(5.0)
    end
end))

-- 16. Auto Trade Feeder Listener
pcall(function()
    if R.TradeEvent and R.TradeEvent:IsA("RemoteEvent") then
        trackConn(R.TradeEvent.OnClientEvent:Connect(function(event, data)
            if not isAlive() or not _G.LianConfig.AutoTradeFeeder then return end
            task.spawn(function()
                local master = _G.LianConfig.MasterAccount
                if not master or master == "" then return end
                if event == "Request" and data and data.player then
                    if data.player.Name:lower() == master:lower() then
                        fire(R.TradeResp, true)
                    else
                        fire(R.TradeResp, false)
                    end
                elseif event == "Started" then
                    task.wait(0.5)
                    local inv = readData("Inventory", {}) or {}
                    for key, unit in pairs(inv) do
                        if isUnitEntry(key, unit) then
                            local rarity = getUnitRarity(unit)
                            if (_G.LianConfig.TradeMythic and rarity == "Mythic") or (_G.LianConfig.TradeSecret and rarity == "Secret") then
                                fire(R.TradeOffer, key, 1)
                                task.wait(0.2)
                            end
                        end
                    end
                    task.wait(0.5)
                    fire(R.TradeAdv)
                    task.wait(3.2)
                    fire(R.TradeAdv)
                end
            end)
        end))
    end
end)

-- 17. Server Luck Hopper Worker (Cooldown-Guarded)
trackThread(task.spawn(function()
    local lastHopAttempt = 0
    while isAlive() do
        if _G.LianConfig.ServerLuckHop and (os.clock() - lastHopAttempt > 90) then
            local hasServerLuck = false
            local sb = RS:FindFirstChild("ServerBoosts") or RS:FindFirstChild("Boosts")
            if sb then
                for _, b in ipairs(sb:GetChildren()) do
                    if b.Name:find("Luck") or (b:GetAttribute("Multiplier") or 0) > 1 then
                        hasServerLuck = true
                        break
                    end
                end
            end
            local attrLuck = tonumber(RS:GetAttribute("ServerLuck") or Workspace:GetAttribute("ServerLuck") or RS:GetAttribute("EventLuck"))
            if attrLuck and attrLuck >= 1.5 then
                hasServerLuck = true
            end
            if not hasServerLuck then
                lastHopAttempt = os.clock()
                task.spawn(function()
                    setupAutoExecuteOnTeleport()
                    local placeId = game.PlaceId
                    local apiUrl = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"
                    local raw = game:HttpGet(apiUrl)
                    if not raw then return end
                    local ok2, res = pcall(function() return HttpService:JSONDecode(raw) end)
                    if ok2 and res and res.data then
                        for _, s in ipairs(res.data) do
                            if s.id ~= game.JobId and s.playing < s.maxPlayers - 1 then
                                TeleportService:TeleportToPlaceInstance(placeId, s.id, LocalPlayer)
                                return
                            end
                        end
                    end
                    TeleportService:Teleport(placeId, LocalPlayer)
                end)
            end
            task.wait(10.0)
        else
            task.wait(3.0)
        end
    end
end))
