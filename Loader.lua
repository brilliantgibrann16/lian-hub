--[[
    ═════════════════════════════════════════════════════════════════════════
    🌙 NYX HUB — ULTIMATE LIQUID GLASS ANIME DICE EXPLOIT SUITE v8.0 🌙
    Author : Lian (@brilliantgibrann16) • Brand: Nyx Hub
    Target : Anime Dice (PlaceId: 113290951185459 / Universe: 10708913337)
    ═════════════════════════════════════════════════════════════════════════
    [FEATURE MATRIX v8.0 LIQUID GLASS EDITION]:
    ★ 100% Native Safe Require: Zero setthreadidentity(2) pollution (Fixes Xeno/Solara module error).
    ★ Liquid Glass Rayfield Theme: Frosted midnight glass + sky-blue glowing borders.
    ★ Multi-Category Potion Stacker: 7-Tier stacking, multi-category selection, target limits, anti-waste buff checker.
    ★ Smart Bag-Aware Auto-Sell: Automatically purges worst units when inventory >= 90% full.
    ★ Auto Trick-or-Treat Engine: Auto-island detection, 7-door nearest tour, 3.5-stud stand-off, server re-arm.
    ★ Complete Quest Claimer: Main Daily/Weekly + Halloween Hourly/Daily + 6 Event Floors.
    ★ Smart Rebirth & Immediate Stats: Multi-source cash reader (udc/ddc/tdc), auto rebirth + stat priorities.
    ★ Upgrades Tree Auto-Buyer: Fast automated tree progression without starvation locks.
    ★ Dynamic Player Scanner & TP: Live player dropdown with instant teleportation.
    ★ Dark 0% GPU Saver: Soothing charcoal eye-friendly dark screen (No blinding white flash!).
    ★ Server Luck Synchronizer: Auto use spins/luck items during luck events with H-5s safety stop.
    ★ WiFi Freeze Watchdog & Auto-Rejoin: Reconnect dialog clicker + 120s cash watchdog freeze recovery.
    ═════════════════════════════════════════════════════════════════════════
]]--

repeat task.wait(0.2) until game:IsLoaded()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.2)
    LocalPlayer = Players.LocalPlayer
end

-- Global execution guard & clean reload
local _ENV = (type(getgenv) == "function" and getgenv()) or _G
if _ENV.__NyxHubLoaded and type(_ENV.__NyxHubCleanup) == "function" then
    pcall(_ENV.__NyxHubCleanup)
end
_ENV.__NyxHubLoaded = true

local aliveToken = {}
_ENV.__NyxHubToken = aliveToken

local function isAlive()
    return _ENV.__NyxHubToken == aliveToken
end

-- Thread & Connection Tracker
local activeThreads = {}
local activeConnections = {}

local function trackThread(th)
    table.insert(activeThreads, th)
    return th
end

local function trackConn(cn)
    table.insert(activeConnections, cn)
    return cn
end

-- 1. Permanent Anti-AFK (Zero WalkSpeed manipulation)
trackThread(task.spawn(function()
    pcall(function()
        local function neutralizeGameAfkScript()
            local ps = LocalPlayer:FindFirstChild("PlayerScripts")
            if not ps then return end
            local afkScript = ps:FindFirstChild("AFK")
            if afkScript and afkScript:IsA("LocalScript") then
                afkScript.Disabled = true
                afkScript:Destroy()
            end
        end
        neutralizeGameAfkScript()
        trackConn(LocalPlayer.ChildAdded:Connect(function(child)
            if child.Name == "PlayerScripts" then
                task.wait(0.5)
                neutralizeGameAfkScript()
            end
        end))
    end)
    local vu = nil
    pcall(function() vu = game:GetService("VirtualUser") end)
    local idledConnection = LocalPlayer.Idled:Connect(function()
        if vu then
            pcall(function() vu:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame) end)
            task.wait(1)
            pcall(function() vu:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame) end)
        end
    end)
    trackConn(idledConnection)
end))

-- 2. Teleport & Auto-Execute Setup
local function setupAutoExecuteOnTeleport()
    if _ENV._NyxQOTQueued then return end
    local qot = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    if type(qot) == "function" then
        local rawJob = tostring(game.JobId or ""):gsub("%s+", "")
        local currentJob = (rawJob ~= "") and rawJob or "server_init"
        local scriptCode = string.format([[
            repeat task.wait(0.2) until game:IsLoaded()
            local rawNewJob = tostring(game.JobId or ""):gsub("%%s+", "")
            local newJob = (rawNewJob ~= "") and rawNewJob or "server_init"
            if newJob ~= %q then
                task.wait(1.5)
                loadstring(game:HttpGet("https://raw.githubusercontent.com/brilliantgibrann16/lian-hub/main/Loader.lua"))()
            end
        ]], currentJob)
        pcall(qot, scriptCode)
        _ENV._NyxQOTQueued = true
    end
end
setupAutoExecuteOnTeleport()

-- 3. Pure Native Safe Require (Zero getrenv / zero identity poisoning)
local function safeRequire(mod)
    if not mod or not mod:IsA("ModuleScript") then return nil end
    local ok, res = pcall(require, mod)
    if ok and res ~= nil then return res end
    return nil
end

-- 4. Verified Knit Network Remote Registry
local NET = RS:FindFirstChild("Network") or RS:WaitForChild("Network", 8)

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
    RollDice       = { { "RollService", "RF", "RollDice" }, { "Rolling", "RF", "RollDice" } },
    SetAutoRoll    = { { "RollService", "RE", "SetAutoRoll" }, { "Rolling", "RE", "SetAutoRoll" } },
    UpdAutoSell    = { { "SellService", "RE", "UpdateAutoSell" }, { nil, "RE", "UpdateAutoSell" } },
    SellInventory  = { { "SellService", "RF", "SellInventory" } },
    SellUnits      = { { "UnitService", "RE", "SellUnits" }, { "SellService", "RF", "SellInventory" } },
    BuyUpgrade     = { { nil, "RE", "BuyUpgrade" }, { "UpgradeService", "RE", "BuyUpgrade" } },
    BuyDice        = { { "DiceShopService", "RE", "BuyDice" }, { "DiceService", "RE", "BuyDice" } },
    EquipDice      = { { "DiceShopService", "RE", "EquipDice" }, { "DiceService", "RE", "EquipDice" } },
    EquipBestUnit  = { { "PlotService", "RE", "EquipBest" }, { "UnitService", "RF", "Equip" } },
    LevelUpSlot    = { { "PlotService", "RE", "LevelUpSlot" } },
    CollectBalance = { { "PlotService", "RE", "CollectBalance" }, { "PlotService", "RF", "CollectCash" } },
    UseBoost       = { { "BoostService", "RE", "Use" } },
    Rebirth        = { { "RebirthService", "RE", "Rebirth" } },
    AddStat        = { { "RebirthService", "RE", "AddStat" } },
    RerollQuirk    = { { "QuirkService", "RE", "Roll" }, { "Quirks", "RE", "Roll" }, { "Quirks", "RF", "Reroll" } },
    ProtectQuirk   = { { "QuirkService", "RE", "SetQuirkProtected" } },
    FuseUnits      = { { "FusingService", "RE", "Fuse" }, { "UnitService", "RF", "Fuse" } },
    SetLocked      = { { "UnitService", "RE", "SetLocked" } },
    PlayTower      = { { "Towers", "RF", "PlayTower" } },
    CompTowerFloor = { { "Towers", "RF", "CompleteTowerFloor" } },
    CancelTower    = { { "Towers", "RF", "CancelTower" } },
    BestTeam       = { { "Towers", "RE", "EquipBestTowerTeam" } },
    SetAutoTower   = { { "Towers", "RE", "SetAutoTower" } },
    QuestClaim     = { { "QuestService", "RE", "Claim" } },
    DailyClaim     = { { "DailyRewardService", "RE", "Claim" } },
    SpinUse        = { { "SpinService", "RE", "Use" } },
    Spin           = { { "SpinService", "RE", "Use" } },
    RedeemCode     = { { "CodesService", "RE", "Redeem" } },
    ClaimOffline   = { { "OfflineEarningsService", "RE", "Claim" } },
    HalloweenRoll  = { { "PumpkinDiceService", "RF", "Roll" } },
    HalloweenClaim = { { "HalloweenQuestService", "RE", "Claim" } },
    HalloweenPass  = { { "HalloweenService", "RE", "ClaimAllPath" } },
    BuyCandyUpg    = { { "HalloweenService", "RE", "BuyUpgrade" }, { "CandyShopService", "RE", "Buy" } },
    TrickKnock     = { { "TrickOrTreatService", "RE", "Knocked" }, { "HalloweenService", "RE", "TrickOrTreat" } }
}

local R = {}
local function resolveRemotes()
    for key, spec in pairs(R_SPECS) do
        local inst = nil
        for _, path in ipairs(spec) do
            inst = getRemote(path[1], path[2], path[3])
            if inst then break end
        end
        R[key] = inst
    end
end
resolveRemotes()

local function fire(remote, ...)
    if not remote then return false end
    if remote:IsA("RemoteEvent") then
        local ok, err = pcall(remote.FireServer, remote, ...)
        return ok, err
    elseif remote:IsA("RemoteFunction") then
        task.spawn(function(...)
            pcall(remote.InvokeServer, remote, ...)
        end, ...)
        return true, nil
    end
    return false
end

-- 5. Game Framework Modules Loader
local M = {}
local function initFramework()
    local fw = RS:FindFirstChild("Framework") or RS:WaitForChild("Framework", 8)
    if fw then
        local Feat = fw:FindFirstChild("Features")
        if Feat then
            if Feat:FindFirstChild("Data") then M.Data = safeRequire(Feat.Data:FindFirstChild("DataController")) end
            if Feat:FindFirstChild("Buffs") then M.Buff = safeRequire(Feat.Buffs:FindFirstChild("BuffController")) end
            if Feat:FindFirstChild("Inventory") then M.Entry = safeRequire(Feat.Inventory:FindFirstChild("EntryRegistry")) end
            if Feat:FindFirstChild("Upgrades") then
                M.Upgrades = safeRequire(Feat.Upgrades:FindFirstChild("Upgrades"))
                M.Tree = safeRequire(Feat.Upgrades:FindFirstChild("TreeStructure"))
            end
            if Feat:FindFirstChild("Rebirth") then
                M.Rebirths = safeRequire(Feat.Rebirth:FindFirstChild("Rebirths"))
                M.RStats = safeRequire(Feat.Rebirth:FindFirstChild("RebirthStats")) or safeRequire(Feat.Rebirth:FindFirstChild("RebirthStatsConfig"))
            end
            if Feat:FindFirstChild("Quests") then M.Quests = safeRequire(Feat.Quests:FindFirstChild("QuestConfig")) end
            if Feat:FindFirstChild("Towers") then M.Towers = safeRequire(Feat.Towers:FindFirstChild("Towers")) end
            if Feat:FindFirstChild("Quirks") then M.Quirks = safeRequire(Feat.Quirks:FindFirstChild("Quirks")) end
        end
    end
end
trackThread(task.spawn(initFramework))

local function unwrapVal(v)
    if type(v) == "function" then
        local ok, res = pcall(v)
        return ok and res or nil
    elseif type(v) == "table" and type(v.Get) == "function" then
        local ok, res = pcall(v.Get, v)
        return ok and res or v
    end
    return v
end

local function readData(key, default)
    if M.Data then
        local ok, raw = pcall(function() return M.Data[key] end)
        if ok and raw ~= nil then
            local val = unwrapVal(raw)
            if val ~= nil then return val end
        end
    end
    return default
end

-- 6. Configuration Engine
local CONFIG_FILE = "NyxHub_" .. (LocalPlayer and tostring(LocalPlayer.UserId) or "shared") .. ".json"
local LEGACY_CONFIG_FILE = "NyxHub_AnimeDice.json"

_G.NyxConfig = {
    -- Auto Farm
    AutoRoll = false,
    FastRoll = true,
    AutoBuyDice = false,
    AutoQuirk = false,
    QuirkTarget = "Prodigy",
    QuirkMaxRolls = 100,
    
    -- Potions Stacker
    AutoPotions = false,
    PotionStackAll7Tiers = true,
    PotionTargetLimit = 100,
    PotionUseLuck = true,
    PotionUseIncome = true,
    PotionUseDamage = true,
    PotionUseSpeed = false,
    PotionUseTower = true,
    PotionUseHalloween = true,
    AntiWastePotionDuration = true,
    
    -- Halloween Event
    AutoRollHalloween = false,
    HalloweenRollOption = "500 Labu (5x Rolls)",
    AutoTrickOrTreat = false,
    AutoHalloweenQuestClaim = false,
    AutoPumpkinPass = false,
    AutoCandyUpgrades = false,
    AutoHalloweenTowers = false,
    
    -- Towers
    SmartTowerAI = false,
    AutoTower = false,
    AutoEquipTowerTeam = true,
    TowerType = "The Abyss",
    
    -- Plot & Quests
    AutoCollectCash = false,
    AutoLevelUpSlots = false,
    AutoMainQuests = false,
    AutoDailyReward = false,
    AutoRedeemCodes = false,
    AutoClaimOffline = true,
    AutoLuckySpin = true,
    
    -- Smart Rebirth & Stats
    AutoRebirth = false,
    AutoAllocStats = false,
    RebirthStatPriority = "Balance / Rata (Money, Luck, Damage, Health, Trait Luck, Grade Luck)",
    AutoBuyTreeUpgrades = false,
    
    -- Smart Bag Auto-Sell
    SmartBagAutoSell = false,
    BagSellThresholdPercent = 90,
    AutoSellMinMultiplier = "1sp",
    AutoEquipBestUnit = true,
    ProtectShiny = true,
    ProtectHaunted = true,
    AutoFuseUnits = false,
    
    -- Server & Teleport
    ServerLuckHop = false,
    AutoUseServerLuckItems = true,
    StopLuckItemsH5 = true,
    AutoReconnectWiFi = true,
    CashWatchdogRejoin = true,
    TargetPlayerTP = "",
    
    -- Optimization & Visuals
    DarkGpuSaver = false,
    TargetFPS = 30,
    PlayerESP = false,
    Fullbright = false,
    JumpPowerValue = 50,
    DiscordWebhook = ""
}

local function saveConfig()
    pcall(function()
        if writefile then
            writefile(CONFIG_FILE, HttpService:JSONEncode(_G.NyxConfig))
        end
    end)
end

local function loadConfig()
    pcall(function()
        local fileToRead = (isfile and isfile(CONFIG_FILE) and CONFIG_FILE) or (isfile and isfile(LEGACY_CONFIG_FILE) and LEGACY_CONFIG_FILE)
        if fileToRead and readfile then
            local data = HttpService:JSONDecode(readfile(fileToRead))
            if type(data) == "table" then
                for k, v in pairs(data) do
                    if _G.NyxConfig[k] ~= nil then
                        _G.NyxConfig[k] = v
                    end
                end
            end
        end
    end)
    _G.NyxConfig.ServerLuckHop = false
end
loadConfig()

-- 7. High-Precision Numeric & Suffix Parser
local SUFFIX_MULT = {
    k = 1e3, m = 1e6, b = 1e9, t = 1e12,
    qa = 1e15, qd = 1e15, qi = 1e18, sx = 1e21, sp = 1e24,
    oc = 1e27, no = 1e30, dc = 1e33,
    udc = 1e36, ddc = 1e39, tdc = 1e42, qdc = 1e45,
    qidc = 1e48, sxdc = 1e51, spdc = 1e54, ocdc = 1e57, nodc = 1e60,
    vg = 1e63, uvg = 1e66
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
        for _, n in ipairs({"Money", "Cash", "Coins", "Balance"}) do
            local val = ls:FindFirstChild(n)
            if val and val.Value then
                local num = parseFormattedNumber(val.Value)
                if num > 0 then return num end
            end
        end
    end
    local pg = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        local hud = pg:FindFirstChild("Root") and pg.Root:FindFirstChild("HUD")
        if hud then
            for _, inst in ipairs(hud:GetDescendants()) do
                if inst:IsA("TextLabel") and (inst.Text:find("%$") or inst.Name:lower():find("money")) then
                    local parsed = parseFormattedNumber(inst.Text)
                    if parsed > 0 then return parsed end
                end
            end
        end
    end
    return 0
end

local function getNextRebirthCost()
    local rb = tonumber(readData("Rebirth", 0)) or 0
    if M.Rebirths and type(M.Rebirths.GetNext) == "function" then
        local ok, nxt = pcall(M.Rebirths.GetNext, rb)
        if ok and type(nxt) == "table" and (nxt.price or nxt.cost) then
            return tonumber(nxt.price or nxt.cost) or 0
        end
    end
    return math.floor(1000 * math.pow(rb + 1, 2.5))
end

local function canAffordRebirth()
    local curCash = getPlayerCash()
    local cost = getNextRebirthCost()
    return curCash >= cost, curCash, cost
end

-- 74 Verified Ground-Truth Upgrades (ordered from cheapest to most expensive)
local ALL_TREE_UPGRADES = {
    { name = "Money I", price = 250 },
    { name = "Luck I", price = 500 },
    { name = "Damage I", price = 1000 },
    { name = "Health I", price = 1000 },
    { name = "Unit Storage I", price = 2500 },
    { name = "Money II", price = 5000 },
    { name = "Luck II", price = 10000 },
    { name = "Health II", price = 20000 },
    { name = "Damage II", price = 20000 },
    { name = "Unit Storage II", price = 50000 },
    { name = "Money III", price = 100000 },
    { name = "Luck III", price = 200000 },
    { name = "Walkspeed I", price = 250000 },
    { name = "Damage III", price = 400000 },
    { name = "Health III", price = 400000 },
    { name = "Sell I", price = 500000 },
    { name = "Unit Storage III", price = 1000000 },
    { name = "Roll Speed I", price = 1000000 },
    { name = "Money IV", price = 2000000 },
    { name = "Luck IV", price = 4000000 },
    { name = "Walkspeed II", price = 5000000 },
    { name = "Health IV", price = 8000000 },
    { name = "Damage IV", price = 8000000 },
    { name = "Sell II", price = 10000000 },
    { name = "Unit Storage IV", price = 20000000 },
    { name = "Money V", price = 40000000 },
    { name = "Luck V", price = 80000000 },
    { name = "Walkspeed III", price = 100000000 },
    { name = "Roll Speed II", price = 100000000 },
    { name = "Damage V", price = 160000000 },
    { name = "Health V", price = 160000000 },
    { name = "Sell III", price = 200000000 },
    { name = "Unit Storage V", price = 400000000 },
    { name = "Money VI", price = 800000000 },
    { name = "Luck VI", price = 1500000000 },
    { name = "Walkspeed IV", price = 2000000000 },
    { name = "Damage VI", price = 3000000000 },
    { name = "Health VI", price = 3000000000 },
    { name = "Sell IV", price = 4000000000 },
    { name = "Unit Storage VI", price = 8000000000 },
    { name = "Roll Speed III", price = 10000000000 },
    { name = "Money VII", price = 15000000000 },
    { name = "Luck VII", price = 30000000000 },
    { name = "Walkspeed V", price = 40000000000 },
    { name = "Health VII", price = 60000000000 },
    { name = "Damage VII", price = 60000000000 },
    { name = "Sell V", price = 80000000000 },
    { name = "Unit Storage VII", price = 160000000000 },
    { name = "Money VIII", price = 300000000000 },
    { name = "Luck VIII", price = 600000000000 },
    { name = "Walkspeed VI", price = 800000000000 },
    { name = "Roll Speed IV", price = 1000000000000 },
    { name = "Health VIII", price = 1200000000000 },
    { name = "Damage VIII", price = 1200000000000 },
    { name = "Sell VI", price = 1500000000000 },
    { name = "Unit Storage VIII", price = 3000000000000 },
    { name = "Money IX", price = 6000000000000 },
    { name = "Luck IX", price = 12000000000000 },
    { name = "Damage IX", price = 25000000000000 },
    { name = "Roll Speed V", price = 100000000000000 },
    { name = "Money X", price = 120000000000000 },
    { name = "Luck X", price = 250000000000000 },
    { name = "Money XI", price = 2500000000000000 },
    { name = "Luck XI", price = 5000000000000000 },
    { name = "Roll Speed VI", price = 10000000000000000 },
    { name = "Fortune I", price = 10000000000000000 },
    { name = "Money XII", price = 50000000000000000 },
    { name = "Luck XII", price = 100000000000000000 },
    { name = "Fortune II", price = 250000000000000000 },
    { name = "Fortune III", price = 1000000000000000000 },
    { name = "Fortune IV", price = 20000000000000000000 },
    { name = "Fortune V", price = 500000000000000000000 },
    { name = "Fortune VI", price = 1e+22 },
    { name = "Fortune VII", price = 2e+23 },
}

-- 26 Verified Ground-Truth Dice Ladder (ordered by luck, low to high)
local DICE_LADDER = {
    { name = "Basic", price = 0, luck = 1 },
    { name = "Normal", price = 1, luck = 2 },
    { name = "Fire", price = 2500, luck = 5 },
    { name = "Water", price = 10000, luck = 10 },
    { name = "Nature", price = 75000, luck = 20 },
    { name = "Lightning", price = 500000, luck = 42.5 },
    { name = "Ice", price = 4000000, luck = 100 },
    { name = "Magma", price = 30000000, luck = 200 },
    { name = "Storm", price = 200000000, luck = 400 },
    { name = "Shadow", price = 1500000000, luck = 750 },
    { name = "Light", price = 12000000000, luck = 1500 },
    { name = "Blood Moon", price = 100000000000, luck = 3000 },
    { name = "Void", price = 750000000000, luck = 6000 },
    { name = "Solar", price = 5000000000000, luck = 12500 },
    { name = "Lunar", price = 37500000000000, luck = 25000 },
    { name = "Galaxy", price = 150000000000000, luck = 50000 },
    { name = "Black Hole", price = 1000000000000000, luck = 100000 },
    { name = "Dragon", price = 8500000000000000, luck = 200000 },
    { name = "Royal", price = 100000000000000000, luck = 400000 },
    { name = "Prismatic", price = 1000000000000000000, luck = 1000000 },
    { name = "Arcane", price = 1.2e19, luck = 2000000 },
    { name = "Corrupted", price = 1.5e20, luck = 5000000 },
    { name = "Titan", price = 1e21, luck = 10000000 },
    { name = "Chrono", price = 1.5e22, luck = 25000000 },
    { name = "Cyber", price = 1e23, luck = 62500000 },
    { name = "Toxic", price = 7.5e23, luck = 150000000 }
}

local function canAffordSpend(price)
    price = price or 0
    local curMoney = getPlayerCash()
    if _G.NyxConfig.AutoRebirth then
        local rbCost = getNextRebirthCost()
        return (curMoney - price) >= rbCost
    end
    return curMoney >= price
end

local function buyUpgradesTree()
    if not R.BuyUpgrade then return end
    local owned = readData("Upgrades", {}) or {}
    for _, node in ipairs(ALL_TREE_UPGRADES) do
        local name = node.name
        local price = node.price
        if not owned[name] and canAffordSpend(price) then
            fire(R.BuyUpgrade, name)
            task.wait(0.12)
        end
    end
end

-- Teleport helpers
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
            if bp then hrp.CFrame = bp.CFrame + Vector3.new(0, 3, 0) end
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

local function findMyPlot()
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local myName = LocalPlayer.Name:lower()
    for _, p in ipairs(plots:GetChildren()) do
        local owner = p:GetAttribute("Owner") or p:GetAttribute("OwnerName") or p.Name
        if tostring(owner):lower() == myName then return p end
    end
    return plots:FindFirstChild("Plot1") or plots:GetChildren()[1]
end

local function goToHalloweenIsland()
    local island = findZoneOrStation({
        "HauntedIsland", "HalloweenIsland", "Halloween", "Haunted",
        "TrickOrTreat", "EventPortal", "HalloweenPortal", "Event"
    })
    if island then
        teleportToTarget(island)
        task.wait(1.5)
        return true
    end
    return false
end

-- 8. Liquid Glass Rayfield UI Setup
local Rayfield
local rawRay
for attempt = 1, 3 do
    local ok, res = pcall(function()
        return game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua')
    end)
    if ok and type(res) == "string" and #res > 100 then
        rawRay = res
        break
    end
    task.wait(0.5)
end
if rawRay and #rawRay > 100 then
    local okCompile, rayChunk = pcall(loadstring, rawRay)
    if okCompile and type(rayChunk) == "function" then
        Rayfield = rayChunk()
    end
end

if not Rayfield then
    Rayfield = { Notify = function() end, CreateWindow = function() return nil end, Destroy = function() end }
end

local Window = nil
if Rayfield and Rayfield.CreateWindow then
    Window = Rayfield:CreateWindow({
        Name = "🌙 Nyx Hub | Anime Dice Master Suite",
        Icon = 0,
        LoadingTitle = "Nyx Hub v8.0 Loading...",
        LoadingSubtitle = "by iannn (@brilliantgibrann16) • Liquid Glass",
        Theme = {
            TextColor = Color3.fromRGB(240, 245, 255),
            Background = Color3.fromRGB(11, 15, 25),
            Topbar = Color3.fromRGB(15, 23, 42),
            Shadow = Color3.fromRGB(5, 8, 15),
            NotificationBackground = Color3.fromRGB(15, 23, 42),
            NotificationActionsBackground = Color3.fromRGB(30, 41, 59),
            TabBackground = Color3.fromRGB(15, 23, 42),
            TabStroke = Color3.fromRGB(30, 41, 59),
            TabBackgroundSelected = Color3.fromRGB(30, 58, 110),
            TabTextColor = Color3.fromRGB(148, 163, 184),
            SelectedTabTextColor = Color3.fromRGB(56, 189, 248),
            ElementBackground = Color3.fromRGB(18, 26, 46),
            ElementBackgroundHover = Color3.fromRGB(24, 34, 60),
            SecondaryElementBackground = Color3.fromRGB(15, 23, 42),
            ElementStroke = Color3.fromRGB(30, 41, 59),
            SecondaryElementStroke = Color3.fromRGB(30, 41, 59),
            SliderBackground = Color3.fromRGB(30, 58, 110),
            SliderProgress = Color3.fromRGB(56, 189, 248),
            SliderStroke = Color3.fromRGB(56, 189, 248),
            ToggleBackground = Color3.fromRGB(15, 23, 42),
            ToggleEnabled = Color3.fromRGB(56, 189, 248),
            ToggleDisabled = Color3.fromRGB(71, 85, 105),
            ToggleCircle = Color3.fromRGB(255, 255, 255),
            ToggleStroke = Color3.fromRGB(30, 41, 59),
            DropdownSelected = Color3.fromRGB(30, 58, 110),
            DropdownUnselected = Color3.fromRGB(18, 26, 46),
            InputBackground = Color3.fromRGB(18, 26, 46),
            InputStroke = Color3.fromRGB(30, 41, 59),
            PlaceholderColor = Color3.fromRGB(100, 116, 139)
        },
        DisableRayfieldPrompts = true,
        DisableBuildWarnings = true,
        ConfigurationSaving = { Enabled = false },
        KeySystem = false
    })
end

-- Teardown Hook
_ENV.__NyxHubCleanup = function()
    aliveToken = nil
    _ENV.__NyxHubLoaded = false
    for _, th in ipairs(activeThreads) do
        pcall(task.cancel, th)
    end
    for _, cn in ipairs(activeConnections) do
        pcall(function() cn:Disconnect() end)
    end
    local pg = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    local oldBtn = pg and pg:FindFirstChild("NyxHubFloatingBtn")
    if oldBtn then oldBtn:Destroy() end
    local darkOv = pg and pg:FindFirstChild("NyxDarkOverlay")
    if darkOv then darkOv:Destroy() end
    pcall(function() RunService:Set3dRenderingEnabled(true) end)
    if Rayfield and type(Rayfield.Destroy) == "function" then
        pcall(function() Rayfield:Destroy() end)
    end
end

-- Liquid Glass Floating Menu Button
local parentGui = nil
if type(gethui) == "function" then pcall(function() parentGui = gethui() end) end
if not parentGui then pcall(function() parentGui = game:GetService("CoreGui") end) end
if not parentGui and LocalPlayer then parentGui = LocalPlayer:FindFirstChild("PlayerGui") end

if parentGui then
    local old = parentGui:FindFirstChild("NyxHubFloatingBtn")
    if old then old:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NyxHubFloatingBtn"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 100
    ScreenGui.Parent = parentGui

    local Btn = Instance.new("TextButton")
    Btn.Name = "ToggleMenu"
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.new(0, 120, 0, 34)
    Btn.Position = UDim2.new(0.015, 0, 0.15, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(11, 15, 25)
    Btn.BackgroundTransparency = 0.2
    Btn.TextColor3 = Color3.fromRGB(56, 189, 248)
    Btn.Text = "🌙 Nyx Hub"
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.Active = true
    Btn.Draggable = true

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Btn

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(56, 189, 248)
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.2
    Stroke.Parent = Btn

    trackConn(Btn.MouseButton1Click:Connect(function()
        pcall(function()
            local rMain = parentGui:FindFirstChild("Rayfield")
            if rMain then rMain.Enabled = not rMain.Enabled end
        end)
    end))

    trackConn(UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and (input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert) then
            local rMain = parentGui:FindFirstChild("Rayfield")
            if rMain then rMain.Enabled = not rMain.Enabled end
        end
    end))
end

-- 9. TABS & CONTROLS (0 CreateButton, All Toggles & Dropdowns)
if Window then
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local PotionsTab = Window:CreateTab("Potion Stacking", 4483362458)
local HalloweenTab = Window:CreateTab("Halloween Event", 4483362458)
local TowerTab = Window:CreateTab("Towers", 4483362458)
local PlotTab = Window:CreateTab("Plot & Quests", 4483362458)
local RebirthTab = Window:CreateTab("Rebirth & Stats", 4483362458)
local UnitsTab = Window:CreateTab("Units & Bag", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local PerfTab = Window:CreateTab("No GPU & Lag", 4483362458)
local ServerTab = Window:CreateTab("Server & WiFi", 4483362458)
local ESPSettingsTab = Window:CreateTab("ESP & Visuals", 4483362458)

-- TAB 1: AUTO FARM
FarmTab:CreateSection("🎲 Dice Rolling Engine")
FarmTab:CreateToggle({
    Name = "Auto Roll Dice (Non-Blocking Native Fast Spam)",
    CurrentValue = _G.NyxConfig.AutoRoll,
    Callback = function(Value)
        _G.NyxConfig.AutoRoll = Value
        saveConfig()
    end,
})

FarmTab:CreateToggle({
    Name = "Fast Roll Mode (No Animation Lag)",
    CurrentValue = _G.NyxConfig.FastRoll,
    Callback = function(Value)
        _G.NyxConfig.FastRoll = Value
        saveConfig()
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Buy Dice (Otomatis Beli Dadu Toko Terbaik)",
    CurrentValue = _G.NyxConfig.AutoBuyDice,
    Callback = function(Value)
        _G.NyxConfig.AutoBuyDice = Value
        saveConfig()
    end,
})

FarmTab:CreateSection("✨ Quirk Reroll Hunter")
FarmTab:CreateToggle({
    Name = "Auto Reroll Quirk (Auto Stop Saat Target Didapat)",
    CurrentValue = _G.NyxConfig.AutoQuirk,
    Callback = function(Value)
        _G.NyxConfig.AutoQuirk = Value
        saveConfig()
    end,
})

FarmTab:CreateDropdown({
    Name = "Target Quirk Pilihan (Real Anime Dice)",
    Options = {
        "Sovereign (1/37k - Top Tier)",
        "Fortune's Favor (1/11k)",
        "Midas Touch (1/5.5k)",
        "Prodigy (1/2.7k - Rekomendasi)",
        "Tycoon (1/2.2k)",
        "Fortune III",
        "Wealth III",
        "Gifted III",
        "Refined III",
        "Swift III"
    },
    CurrentOption = _G.NyxConfig.QuirkTarget or "Prodigy (1/2.7k - Rekomendasi)",
    Callback = function(Option)
        local opt = type(Option) == "table" and Option[1] or Option
        local cleanName = opt:match("^([%w%s%']+)") or opt
        cleanName = cleanName:gsub("%s+$", "")
        _G.NyxConfig.QuirkTarget = cleanName
        saveConfig()
    end,
})

FarmTab:CreateSlider({
    Name = "Batas Maksimal Roll Quirk (Stop Limit)",
    Range = {10, 500},
    Increment = 10,
    Suffix = " rolls",
    CurrentValue = _G.NyxConfig.QuirkMaxRolls or 100,
    Callback = function(Value)
        _G.NyxConfig.QuirkMaxRolls = Value
        saveConfig()
    end,
})

-- TAB 2: POTION STACKING & SELECTOR
PotionsTab:CreateSection("🧪 Multi-Category Potion Stacker Engine")
PotionsTab:CreateToggle({
    Name = "Auto Drink & Stack Potions (Aktifkan Stacker)",
    CurrentValue = _G.NyxConfig.AutoPotions,
    Callback = function(Value)
        _G.NyxConfig.AutoPotions = Value
        saveConfig()
    end,
})

PotionsTab:CreateToggle({
    Name = "Tumpuk Semua 7 Tier Potion Sekaligus (Max Multiplier)",
    CurrentValue = _G.NyxConfig.PotionStackAll7Tiers,
    Callback = function(Value)
        _G.NyxConfig.PotionStackAll7Tiers = Value
        saveConfig()
    end,
})

PotionsTab:CreateToggle({
    Name = "Cek Durasi Buff (Anti Buang-Buang Potion)",
    CurrentValue = _G.NyxConfig.AntiWastePotionDuration,
    Callback = function(Value)
        _G.NyxConfig.AntiWastePotionDuration = Value
        saveConfig()
    end,
})

PotionsTab:CreateSlider({
    Name = "Batas Target Potion (Target Counter)",
    Range = {10, 500},
    Increment = 10,
    Suffix = " pcs",
    CurrentValue = _G.NyxConfig.PotionTargetLimit or 100,
    Callback = function(Value)
        _G.NyxConfig.PotionTargetLimit = Value
        saveConfig()
    end,
})

PotionsTab:CreateSection("🎯 Pilihan Kategori Potion")
PotionsTab:CreateToggle({
    Name = "Kategori Money / Income Potions (I - VII)",
    CurrentValue = _G.NyxConfig.PotionUseIncome,
    Callback = function(Value)
        _G.NyxConfig.PotionUseIncome = Value
        saveConfig()
    end,
})

PotionsTab:CreateToggle({
    Name = "Kategori Luck Potions (I - VII + Bags)",
    CurrentValue = _G.NyxConfig.PotionUseLuck,
    Callback = function(Value)
        _G.NyxConfig.PotionUseLuck = Value
        saveConfig()
    end,
})

PotionsTab:CreateToggle({
    Name = "Kategori Damage / Slayer Potions",
    CurrentValue = _G.NyxConfig.PotionUseDamage,
    Callback = function(Value)
        _G.NyxConfig.PotionUseDamage = Value
        saveConfig()
    end,
})

PotionsTab:CreateToggle({
    Name = "Kategori Speed Potions",
    CurrentValue = _G.NyxConfig.PotionUseSpeed,
    Callback = function(Value)
        _G.NyxConfig.PotionUseSpeed = Value
        saveConfig()
    end,
})

PotionsTab:CreateToggle({
    Name = "Kategori Tower Drop Potions (Shadow/Pirate/Abyss)",
    CurrentValue = _G.NyxConfig.PotionUseTower,
    Callback = function(Value)
        _G.NyxConfig.PotionUseTower = Value
        saveConfig()
    end,
})

PotionsTab:CreateToggle({
    Name = "Kategori Halloween Potions (Pumpkin/Candy/Haunted)",
    CurrentValue = _G.NyxConfig.PotionUseHalloween,
    Callback = function(Value)
        _G.NyxConfig.PotionUseHalloween = Value
        saveConfig()
    end,
})

-- TAB 3: HALLOWEEN EVENT SUITE
HalloweenTab:CreateSection("🎃 Pumpkin Dice Roll Engine")
HalloweenTab:CreateDropdown({
    Name = "Pilihan Roll Dadu Labu",
    Options = {"500 Labu (5x Rolls - Rekomendasi)", "100 Labu (1x Roll)"},
    CurrentOption = _G.NyxConfig.HalloweenRollOption,
    Callback = function(Option)
        _G.NyxConfig.HalloweenRollOption = type(Option) == "table" and Option[1] or Option
        saveConfig()
    end,
})

HalloweenTab:CreateToggle({
    Name = "Auto Roll Pumpkin Dice (Dadu Labu)",
    CurrentValue = _G.NyxConfig.AutoRollHalloween,
    Callback = function(Value)
        _G.NyxConfig.AutoRollHalloween = Value
        saveConfig()
    end,
})

HalloweenTab:CreateSection("🍬 Trick-or-Treat & Event Doors")
HalloweenTab:CreateToggle({
    Name = "Auto Trick-or-Treat (Auto TP ke Island + Ketuk Semua Pintu)",
    CurrentValue = _G.NyxConfig.AutoTrickOrTreat,
    Callback = function(Value)
        _G.NyxConfig.AutoTrickOrTreat = Value
        saveConfig()
    end,
})

HalloweenTab:CreateToggle({
    Name = "Auto Claim Halloween Quests (Hourly, Daily & 6 Event Floors)",
    CurrentValue = _G.NyxConfig.AutoHalloweenQuestClaim,
    Callback = function(Value)
        _G.NyxConfig.AutoHalloweenQuestClaim = Value
        saveConfig()
    end,
})

HalloweenTab:CreateToggle({
    Name = "Auto Claim Pumpkin Pass (All Paths)",
    CurrentValue = _G.NyxConfig.AutoPumpkinPass,
    Callback = function(Value)
        _G.NyxConfig.AutoPumpkinPass = Value
        saveConfig()
    end,
})

HalloweenTab:CreateToggle({
    Name = "Auto Buy Candy Upgrades (Halloween Shop)",
    CurrentValue = _G.NyxConfig.AutoCandyUpgrades,
    Callback = function(Value)
        _G.NyxConfig.AutoCandyUpgrades = Value
        saveConfig()
    end,
})

HalloweenTab:CreateSection("🏰 Halloween Event Towers (Dungeons)")
HalloweenTab:CreateToggle({
    Name = "Auto Attack Halloween Event Towers (The Abyss / Bell / Attic / Crypt)",
    CurrentValue = _G.NyxConfig.AutoHalloweenTowers,
    Callback = function(Value)
        _G.NyxConfig.AutoHalloweenTowers = Value
        saveConfig()
    end,
})

-- TAB 4: TOWERS
TowerTab:CreateSection("⚔️ Smart Tower AI Engine")
TowerTab:CreateToggle({
    Name = "Smart Tower AI (Auto Clear Tower Terkuat)",
    CurrentValue = _G.NyxConfig.SmartTowerAI,
    Callback = function(Value)
        _G.NyxConfig.SmartTowerAI = Value
        saveConfig()
    end,
})

TowerTab:CreateToggle({
    Name = "Auto Equip Best Tower Team Sebelum Serang",
    CurrentValue = _G.NyxConfig.AutoEquipTowerTeam,
    Callback = function(Value)
        _G.NyxConfig.AutoEquipTowerTeam = Value
        saveConfig()
    end,
})

TowerTab:CreateDropdown({
    Name = "Pilihan Manual Tower (Standard & Halloween Event)",
    Options = {
        "🎃 The Abyss (Halloween Event)",
        "🎃 Bell Tower (Halloween Event)",
        "🎃 Attic (Halloween Event)",
        "🎃 Crypt (Halloween Event)",
        "🎃 Foyer (Halloween Event)",
        "🎃 Front Yard (Halloween Event)",
        "⚔️ Infinity Tower (Best / No Cap)",
        "⚔️ Hidden Leaf Tower (Extreme)",
        "⚔️ Pirate Tower (Hard)",
        "⚔️ Cursed Tower (Medium)",
        "⚔️ Dragon Tower (Easy)"
    },
    CurrentOption = "🎃 The Abyss (Halloween Event)",
    Callback = function(Option)
        local opt = type(Option) == "table" and Option[1] or Option
        local clean = opt:gsub("^[🎃⚔️%s]+", ""):match("^([%w%s]+)") or opt
        clean = clean:gsub("%s+$", "")
        _G.NyxConfig.TowerType = clean
        saveConfig()
    end,
})

TowerTab:CreateToggle({
    Name = "Auto Serang Manual Tower Pilihan",
    CurrentValue = _G.NyxConfig.AutoTower,
    Callback = function(Value)
        _G.NyxConfig.AutoTower = Value
        saveConfig()
    end,
})

-- TAB 5: PLOT & QUESTS
PlotTab:CreateSection("💰 Plot Management")
PlotTab:CreateToggle({
    Name = "Auto Collect Cash (Plot Slots 1 - 12)",
    CurrentValue = _G.NyxConfig.AutoCollectCash,
    Callback = function(Value)
        _G.NyxConfig.AutoCollectCash = Value
        saveConfig()
    end,
})

PlotTab:CreateToggle({
    Name = "Auto Level Up Slots (Slots 1 - 12)",
    CurrentValue = _G.NyxConfig.AutoLevelUpSlots,
    Callback = function(Value)
        _G.NyxConfig.AutoLevelUpSlots = Value
        saveConfig()
    end,
})

PlotTab:CreateSection("📜 Quests & Free Rewards")
PlotTab:CreateToggle({
    Name = "Auto Claim Quests (Daily & Weekly Main Quests)",
    CurrentValue = _G.NyxConfig.AutoMainQuests,
    Callback = function(Value)
        _G.NyxConfig.AutoMainQuests = Value
        saveConfig()
    end,
})

PlotTab:CreateToggle({
    Name = "Auto Claim Daily Rewards",
    CurrentValue = _G.NyxConfig.AutoDailyReward,
    Callback = function(Value)
        _G.NyxConfig.AutoDailyReward = Value
        saveConfig()
    end,
})

PlotTab:CreateToggle({
    Name = "Auto Claim Offline Earnings",
    CurrentValue = _G.NyxConfig.AutoClaimOffline,
    Callback = function(Value)
        _G.NyxConfig.AutoClaimOffline = Value
        saveConfig()
    end,
})

PlotTab:CreateToggle({
    Name = "Auto Spin Lucky Wheel & Spins",
    CurrentValue = _G.NyxConfig.AutoLuckySpin,
    Callback = function(Value)
        _G.NyxConfig.AutoLuckySpin = Value
        saveConfig()
    end,
})

PlotTab:CreateToggle({
    Name = "Auto Redeem All Codes",
    CurrentValue = _G.NyxConfig.AutoRedeemCodes,
    Callback = function(Value)
        _G.NyxConfig.AutoRedeemCodes = Value
        saveConfig()
    end,
})

-- TAB 6: SMART REBIRTH & STATS
RebirthTab:CreateSection("🧬 Smart Rebirth Engine")
RebirthTab:CreateToggle({
    Name = "Auto Rebirth (Uang Cukup Langsung Rebirth — No Spam)",
    CurrentValue = _G.NyxConfig.AutoRebirth,
    Callback = function(Value)
        _G.NyxConfig.AutoRebirth = Value
        saveConfig()
    end,
})

RebirthTab:CreateToggle({
    Name = "Auto Alloc Rebirth Stats (Poin Ada Langsung Dialokasi)",
    CurrentValue = _G.NyxConfig.AutoAllocStats,
    Callback = function(Value)
        _G.NyxConfig.AutoAllocStats = Value
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
        "Fokus Health Dulu",
        "Fokus Trait Luck Dulu",
        "Fokus Grade Luck Dulu"
    },
    CurrentOption = _G.NyxConfig.RebirthStatPriority,
    Callback = function(Option)
        _G.NyxConfig.RebirthStatPriority = type(Option) == "table" and Option[1] or Option
        saveConfig()
    end,
})

RebirthTab:CreateSection("🛒 Upgrades Pohon Dadu (Near Dice UI)")
RebirthTab:CreateToggle({
    Name = "Auto Beli Semua Upgrades Pohon (Fortune & Upgrades Dadu)",
    CurrentValue = _G.NyxConfig.AutoBuyTreeUpgrades,
    Callback = function(Value)
        _G.NyxConfig.AutoBuyTreeUpgrades = Value
        saveConfig()
    end,
})

-- TAB 7: UNITS & BAG AUTO-SELL
UnitsTab:CreateSection("🗑️ Smart Bag-Aware Auto-Sell (Worst Unit Purger)")
UnitsTab:CreateToggle({
    Name = "Auto Sell Worst Units Saat Tas Mau Penuh",
    CurrentValue = _G.NyxConfig.SmartBagAutoSell,
    Callback = function(Value)
        _G.NyxConfig.SmartBagAutoSell = Value
        saveConfig()
    end,
})

UnitsTab:CreateDropdown({
    Name = "Batas Kapasitas Tas Pemicu Auto-Sell",
    Options = {"Tas >= 90% Penuh (Rekomendasi)", "Tas >= 80% Penuh", "Tas >= 95% Penuh", "Setiap Selesai Roll"},
    CurrentOption = "Tas >= 90% Penuh (Rekomendasi)",
    Callback = function(Option)
        local opt = type(Option) == "table" and Option[1] or Option
        if opt:find("80") then _G.NyxConfig.BagSellThresholdPercent = 80
        elseif opt:find("95") then _G.NyxConfig.BagSellThresholdPercent = 95
        elseif opt:find("Setiap") then _G.NyxConfig.BagSellThresholdPercent = 10
        else _G.NyxConfig.BagSellThresholdPercent = 90 end
        saveConfig()
    end,
})

UnitsTab:CreateDropdown({
    Name = "Ambang Batas Nilai Terendah yang Dijual",
    Options = {"Di Bawah 1sp", "Di Bawah 10sp", "Di Bawah 100sp", "Di Bawah 1oc", "Di Bawah 1no", "Di Bawah 1dc", "Di Bawah 1udc"},
    CurrentOption = "Di Bawah 1sp",
    Callback = function(Option)
        _G.NyxConfig.AutoSellMinMultiplier = type(Option) == "table" and Option[1] or Option
        saveConfig()
    end,
})

UnitsTab:CreateSection("⭐ Auto Equip Best Unit")
UnitsTab:CreateToggle({
    Name = "Auto Equip Best Units ke Plot Secara Berkala",
    CurrentValue = _G.NyxConfig.AutoEquipBestUnit,
    Callback = function(Value)
        _G.NyxConfig.AutoEquipBestUnit = Value
        saveConfig()
        if Value and R.EquipBestUnit then fire(R.EquipBestUnit) end
    end,
})

UnitsTab:CreateSection("🔒 Proteksi Unit Berharga")
UnitsTab:CreateToggle({
    Name = "Protect Shiny Units (Jangan Pernah Dijual)",
    CurrentValue = _G.NyxConfig.ProtectShiny,
    Callback = function(Value)
        _G.NyxConfig.ProtectShiny = Value
        saveConfig()
    end,
})

UnitsTab:CreateToggle({
    Name = "Protect Haunted Units (Jangan Pernah Dijual)",
    CurrentValue = _G.NyxConfig.ProtectHaunted,
    Callback = function(Value)
        _G.NyxConfig.ProtectHaunted = Value
        saveConfig()
    end,
})

UnitsTab:CreateToggle({
    Name = "Auto Fuse Matching Units",
    CurrentValue = _G.NyxConfig.AutoFuseUnits,
    Callback = function(Value)
        _G.NyxConfig.AutoFuseUnits = Value
        saveConfig()
    end,
})

-- TAB 8: TELEPORT & PLAYER SCANNER
TeleportTab:CreateSection("👥 Live Player Scanner & Instant Teleport")
local playerOptions = {"Pilih Player..."}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then table.insert(playerOptions, p.Name) end
end

local playerDropdown = TeleportTab:CreateDropdown({
    Name = "Target Player (Scan Server)",
    Options = playerOptions,
    CurrentOption = playerOptions[1],
    Callback = function(Option)
        _G.NyxConfig.TargetPlayerTP = type(Option) == "table" and Option[1] or Option
    end,
})

trackConn(Players.PlayerAdded:Connect(function(p)
    local opts = {"Pilih Player..."}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(opts, plr.Name) end
    end
    pcall(function() playerDropdown:Refresh(opts) end)
end))

trackConn(Players.PlayerRemoving:Connect(function(p)
    local opts = {"Pilih Player..."}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr ~= p then table.insert(opts, plr.Name) end
    end
    pcall(function() playerDropdown:Refresh(opts) end)
end))

do
    local _tg
    _tg = TeleportTab:CreateToggle({
        Name = "⚡ Teleport ke Player Pilihan Sekarang",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            task.spawn(function()
                task.wait(0.5)
                pcall(function() _tg:Set(false) end)
            end)
            local targetName = _G.NyxConfig.TargetPlayerTP
            local targetPlr = targetName and Players:FindFirstChild(targetName)
            local targetHrp = targetPlr and targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart")
            local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myHrp and targetHrp then
                myHrp.CFrame = targetHrp.CFrame + Vector3.new(0, 3, 2)
                Rayfield:Notify({ Title = "Teleport", Content = "Berhasil teleport ke " .. targetName .. "!", Duration = 3 })
            else
                Rayfield:Notify({ Title = "Teleport Gagal", Content = "Player tidak ditemukan atau belum spawn!", Duration = 3 })
            end
        end,
    })
end

TeleportTab:CreateSection("📍 Teleport Lokasi Game")
local destinations = {
    { name = "🏠 Teleport ke Plot Sendiri", fn = function() return findMyPlot() end },
    { name = "🎃 Teleport ke Haunted / Halloween Island", fn = function() return goToHalloweenIsland() end },
    { name = "🎲 Teleport ke Dice Shop", fn = function() return findZoneOrStation({"Shop", "DiceShop", "Dice"}) end },
    { name = "🔄 Teleport ke Rebirth Station", fn = function() return findZoneOrStation({"Rebirth", "RebirthStation", "Quirks"}) end },
    { name = "🧬 Teleport ke Fusing Station", fn = function() return findZoneOrStation({"Fusing", "Fuse"}) end },
    { name = "📋 Teleport ke Quest Board", fn = function() return findZoneOrStation({"Quests", "QuestBoard", "Towers"}) end }
}

for _, d in ipairs(destinations) do
    local _tg
    _tg = TeleportTab:CreateToggle({
        Name = d.name,
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            task.spawn(function()
                task.wait(0.5)
                pcall(function() _tg:Set(false) end)
            end)
            local dest = d.fn()
            if typeof(dest) == "Instance" then teleportToTarget(dest) end
        end,
    })
end

-- TAB 9: NO GPU & LAG OPTIMIZER
PerfTab:CreateSection("❄️ Dark 0% GPU Saver (Mata Nyaman & Hemat Daya)")
local darkOverlayGui = nil

local function toggleDarkGpuMode(enable)
    pcall(function() RunService:Set3dRenderingEnabled(not enable) end)
    if enable then
        if not darkOverlayGui then
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if pg then
                darkOverlayGui = Instance.new("ScreenGui")
                darkOverlayGui.Name = "NyxDarkOverlay"
                darkOverlayGui.ResetOnSpawn = false
                darkOverlayGui.DisplayOrder = 0
                darkOverlayGui.Parent = pg
                
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.BackgroundColor3 = Color3.fromRGB(11, 15, 23)
                frame.BackgroundTransparency = 0.05
                frame.Active = false
                frame.Parent = darkOverlayGui
                
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 0, 40)
                lbl.Position = UDim2.new(0, 0, 0.45, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = Color3.fromRGB(56, 189, 248)
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 16
                lbl.Text = "🌙 Nyx Hub — 0% GPU Saver Aktif\n(Render 3D Nonaktif • Layar Redup Ramah Mata)"
                lbl.Parent = frame
            end
        end
    else
        if darkOverlayGui then
            darkOverlayGui:Destroy()
            darkOverlayGui = nil
        end
    end
end

PerfTab:CreateToggle({
    Name = "Layar Redup 0% GPU Saver (Bukan Putih Silau!)",
    CurrentValue = _G.NyxConfig.DarkGpuSaver,
    Callback = function(Value)
        _G.NyxConfig.DarkGpuSaver = Value
        saveConfig()
        toggleDarkGpuMode(Value)
    end,
})

PerfTab:CreateSlider({
    Name = "FPS Cap Tuyul Multi-Akun",
    Range = {10, 60},
    Increment = 5,
    Suffix = " FPS",
    CurrentValue = _G.NyxConfig.TargetFPS,
    Callback = function(Value)
        _G.NyxConfig.TargetFPS = Value
        saveConfig()
        pcall(function() if setfpscap then setfpscap(Value) end end)
    end,
})

-- TAB 10: SERVER, WIFI & LUCK
ServerTab:CreateSection("🌐 Server Luck Event & Synchronizer")
ServerTab:CreateToggle({
    Name = "Auto Use Item Saat Server Luck Event Aktif",
    CurrentValue = _G.NyxConfig.AutoUseServerLuckItems,
    Callback = function(Value)
        _G.NyxConfig.AutoUseServerLuckItems = Value
        saveConfig()
    end,
})

ServerTab:CreateToggle({
    Name = "Safety Stop H-5 Detik Sebelum Luck Event Habis",
    CurrentValue = _G.NyxConfig.StopLuckItemsH5,
    Callback = function(Value)
        _G.NyxConfig.StopLuckItemsH5 = Value
        saveConfig()
    end,
})

ServerTab:CreateToggle({
    Name = "Auto Server Hop Cari Server Luck",
    CurrentValue = _G.NyxConfig.ServerLuckHop,
    Callback = function(Value)
        _G.NyxConfig.ServerLuckHop = Value
        saveConfig()
    end,
})

ServerTab:CreateSection("📶 WiFi Disconnect & Cash Freeze Watchdog")
ServerTab:CreateToggle({
    Name = "Auto Reconnect Saat Muncul Dialog Disconnect",
    CurrentValue = _G.NyxConfig.AutoReconnectWiFi,
    Callback = function(Value)
        _G.NyxConfig.AutoReconnectWiFi = Value
        saveConfig()
    end,
})

ServerTab:CreateToggle({
    Name = "Cash Collect Freeze Watchdog (>120s Auto Rejoin)",
    CurrentValue = _G.NyxConfig.CashWatchdogRejoin,
    Callback = function(Value)
        _G.NyxConfig.CashWatchdogRejoin = Value
        saveConfig()
    end,
})

-- TAB 11: ESP & VISUALS
ESPSettingsTab:CreateSection("👁️ Visual Helpers")
ESPSettingsTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = _G.NyxConfig.PlayerESP,
    Callback = function(Value)
        _G.NyxConfig.PlayerESP = Value
        saveConfig()
    end,
})

ESPSettingsTab:CreateToggle({
    Name = "Fullbright (Terang Bersih)",
    CurrentValue = _G.NyxConfig.Fullbright,
    Callback = function(Value)
        _G.NyxConfig.Fullbright = Value
        saveConfig()
    end,
})
end

-- ═════════════════════════════════════════════════════════════════════
-- 🚀 100% DECOUPLED BACKGROUND WORKERS
-- ═════════════════════════════════════════════════════════════════════

-- Last cash collect timestamp for freeze watchdog
local lastCashCollectTime = os.clock()

-- 1. Auto Roll Dice Worker
local lastAutoRollState = nil
trackThread(task.spawn(function()
    while isAlive() do
        if _G.NyxConfig.AutoRoll ~= lastAutoRollState then
            lastAutoRollState = _G.NyxConfig.AutoRoll
            if R.SetAutoRoll then fire(R.SetAutoRoll, _G.NyxConfig.AutoRoll) end
        end
        if _G.NyxConfig.AutoRoll then
            if R.RollDice then
                fire(R.RollDice)
            end
            task.wait(_G.NyxConfig.FastRoll and 0.08 or 0.3)
        else
            task.wait(0.5)
        end
    end
end))

-- 2. Auto Roll Pumpkin Dice Worker
trackThread(task.spawn(function()
    while isAlive() do
        if _G.NyxConfig.AutoRollHalloween and R.HalloweenRoll then
            local count = _G.NyxConfig.HalloweenRollOption:find("100") and 1 or 5
            fire(R.HalloweenRoll, count)
            task.wait(0.35)
        else
            task.wait(0.5)
        end
    end
end))

-- 3. Auto Potions Stacker Worker (7 Tiers Multiplicative Stacking with Anti-Waste Buff Check)
trackThread(task.spawn(function()
    while isAlive() do
        if _G.NyxConfig.AutoPotions and R.UseBoost then
            local inv = readData("Inventory", {}) or {}
            local activeBuffs = readData("Buffs", {}) or {}
            local targetLimit = _G.NyxConfig.PotionTargetLimit or 100
            local drinkQueue = {}
            local nowTime = Workspace:GetServerTimeNow()
            
            for key, item in pairs(inv) do
                if #drinkQueue >= targetLimit then break end
                if type(item) == "table" and (tonumber(item.amount) or 1) > 0 then
                    local name = tostring(item.name or key):lower()
                    local shouldDrink = false
                    if _G.NyxConfig.PotionUseIncome and (name:find("income") or name:find("money")) then shouldDrink = true
                    elseif _G.NyxConfig.PotionUseLuck and (name:find("luck") or name:find("clover")) then shouldDrink = true
                    elseif _G.NyxConfig.PotionUseDamage and (name:find("damage") or name:find("slayer")) then shouldDrink = true
                    elseif _G.NyxConfig.PotionUseSpeed and name:find("speed") then shouldDrink = true
                    elseif _G.NyxConfig.PotionUseTower and (name:find("shadow") or name:find("pirate") or name:find("abyss")) then shouldDrink = true
                    elseif _G.NyxConfig.PotionUseHalloween and (name:find("pumpkin") or name:find("candy") or name:find("haunted")) then shouldDrink = true
                    end
                    
                    if shouldDrink then
                        -- Check Anti-Waste Buff Duration: if buff still active > 10s, don't waste another potion!
                        local isAlreadyActive = false
                        if _G.NyxConfig.AntiWastePotionDuration and type(activeBuffs) == "table" then
                            for bName, bData in pairs(activeBuffs) do
                                if name:find(tostring(bName):lower()) then
                                    local exp = (type(bData) == "table" and (bData.expiresAt or bData.endTime)) or 0
                                    if exp > (nowTime + 10) then
                                        isAlreadyActive = true
                                        break
                                    end
                                end
                            end
                        end
                        if not isAlreadyActive then
                            table.insert(drinkQueue, key)
                        end
                    end
                end
            end
            
            for _, pKey in ipairs(drinkQueue) do
                if not _G.NyxConfig.AutoPotions or not isAlive() then break end
                fire(R.UseBoost, pKey)
                task.wait(0.18)
            end
            task.wait(4.0)
        else
            task.wait(1.5)
        end
    end
end))

-- 4. Server Luck Event Synchronizer & Consumable User (H-5 Safety Stop)
trackThread(task.spawn(function()
    while isAlive() do
        if _G.NyxConfig.AutoUseServerLuckItems then
            local sb = RS:FindFirstChild("ServerBoosts") or RS:FindFirstChild("Boosts")
            local attrLuck = tonumber(RS:GetAttribute("ServerLuck") or Workspace:GetAttribute("ServerLuck")) or 1
            local hasServerLuck = (attrLuck > 1.2)
            local timeLeft = 9999
            if sb then
                for _, b in ipairs(sb:GetChildren()) do
                    if b.Name:find("Luck") then
                        hasServerLuck = true
                        local exp = tonumber(b:GetAttribute("ExpiresAt") or b:GetAttribute("EndTime"))
                        if exp then
                            local now = Workspace:GetServerTimeNow()
                            timeLeft = math.min(timeLeft, exp - now)
                        end
                    end
                end
            end
            if hasServerLuck then
                if not _G.NyxConfig.StopLuckItemsH5 or (timeLeft > 5) then
                    local inv = readData("Inventory", {}) or {}
                    for key, item in pairs(inv) do
                        local name = tostring(item.name or key):lower()
                        if name:find("lucky roll") or name:find("jackpot") or name:find("lucky bag") or name:find("clover") then
                            if R.SpinUse then fire(R.SpinUse, key) end
                            if R.UseBoost then fire(R.UseBoost, key) end
                            task.wait(0.2)
                        end
                    end
                end
            end
            task.wait(3.0)
        else
            task.wait(1.5)
        end
    end
end))

-- 5. Auto Rebirth & Immediate Stats Allocation Worker
trackThread(task.spawn(function()
    while isAlive() do
        if _G.NyxConfig.AutoRebirth and R.Rebirth then
            local canRebirth, curCash, cost = canAffordRebirth()
            if canRebirth then
                fire(R.Rebirth)
                task.wait(1.2)
                if R.EquipBestUnit then fire(R.EquipBestUnit) end
            end
        end
        if _G.NyxConfig.AutoAllocStats and R.AddStat then
            local prio = _G.NyxConfig.RebirthStatPriority or ""
            local stats = {"Money", "Luck", "Damage", "Health", "Trait Luck", "Grade Luck"}
            if prio:find("Balance") then
                stats = {"Money", "Luck", "Damage", "Health", "Trait Luck", "Grade Luck"}
            elseif prio:find("Money") or prio:find("Income") then
                stats = {"Money"}
            elseif prio:find("Luck") and not prio:find("Trait") and not prio:find("Grade") then
                stats = {"Luck"}
            elseif prio:find("Damage") then
                stats = {"Damage"}
            elseif prio:find("Health") then
                stats = {"Health"}
            elseif prio:find("Trait") then
                stats = {"Trait Luck"}
            elseif prio:find("Grade") then
                stats = {"Grade Luck"}
            end
            for _, s in ipairs(stats) do
                fire(R.AddStat, s)
                task.wait(0.08)
            end
        end
        task.wait(2.0)
    end
end))

-- 6. Upgrades Tree Worker
trackThread(task.spawn(function()
    while isAlive() do
        if _G.NyxConfig.AutoBuyTreeUpgrades then
            buyUpgradesTree()
            task.wait(3.0)
        else
            task.wait(1.0)
        end
    end
end))

-- 7. Plot Cash & Level Up Worker
trackThread(task.spawn(function()
    while isAlive() do
        if _G.NyxConfig.AutoCollectCash and R.CollectBalance then
            for slot = 1, 12 do
                if not _G.NyxConfig.AutoCollectCash or not isAlive() then break end
                fire(R.CollectBalance, slot)
                task.wait(0.08)
            end
        end
        if _G.NyxConfig.AutoLevelUpSlots and R.LevelUpSlot then
            for slot = 1, 12 do
                if not _G.NyxConfig.AutoLevelUpSlots or not isAlive() then break end
                fire(R.LevelUpSlot, slot)
                task.wait(0.08)
            end
        end
        task.wait(2.5)
    end
end))

-- 8. Main & Halloween Quests Claim Worker
trackThread(task.spawn(function()
    while isAlive() do
        local nowStamp = math.floor(Workspace:GetServerTimeNow())
        if _G.NyxConfig.AutoMainQuests and R.QuestClaim then
            for _, p in ipairs({"Daily", "Weekly"}) do
                for qid = 1, 10 do
                    fire(R.QuestClaim, p, qid, nowStamp)
                end
            end
        end
        if _G.NyxConfig.AutoHalloweenQuestClaim and R.HalloweenClaim then
            for _, period in ipairs({"Hourly", "Daily"}) do
                for qid = 1, 15 do
                    fire(R.HalloweenClaim, period, qid)
                end
            end
            for _, floor in ipairs({"The Abyss", "Bell Tower", "Attic", "Crypt", "Foyer", "Front Yard"}) do
                fire(R.HalloweenClaim, "Daily", floor)
            end
        end
        if _G.NyxConfig.AutoDailyReward and R.DailyClaim then
            fire(R.DailyClaim)
        end
        if _G.NyxConfig.AutoPumpkinPass and R.HalloweenPass then
            fire(R.HalloweenPass)
        end
        if _G.NyxConfig.AutoLuckySpin and (R.SpinUse or R.Spin) then
            fire(R.SpinUse or R.Spin)
        end
        if _G.NyxConfig.AutoRedeemCodes and R.RedeemCode then
            local promoCodes = {"50KLikes", "Halloween", "TrickOrTreat", "Update2", "Quirks", "Dungeon", "Sub2Dev", "AnimeDice", "Pumpkin"}
            for _, c in ipairs(promoCodes) do
                fire(R.RedeemCode, c)
                task.wait(0.2)
            end
        end
        if _G.NyxConfig.AutoEquipBestUnit and R.EquipBestUnit then
            fire(R.EquipBestUnit)
        end
        task.wait(10.0)
    end
end))

-- 9. Auto Trick-or-Treat Worker (Tour All Doors & Server Re-Arm)
trackThread(task.spawn(function()
    local fpp = fireproximityprompt or (_ENV and _ENV.fireproximityprompt)
    local doorCooldowns = {}
    local savedOriginCFrame = nil
    local wasRunning = false
    
    local function getDoors()
        local list = {}
        for _, inst in ipairs(CollectionService:GetTagged("TrickOrTreatDoor")) do
            if inst:IsA("BasePart") or inst:IsA("Model") then table.insert(list, inst) end
        end
        if #list == 0 then
            local hw = Workspace:FindFirstChild("Halloween") or Workspace:FindFirstChild("Map")
            local doors = hw and (hw:FindFirstChild("Doors") or hw:FindFirstChild("TrickOrTreat"))
            if doors then
                for _, d in ipairs(doors:GetChildren()) do
                    if d:IsA("BasePart") or d:IsA("Model") then table.insert(list, d) end
                end
            end
        end
        return list
    end

    while isAlive() do
        if _G.NyxConfig.AutoTrickOrTreat then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if not wasRunning then
                    savedOriginCFrame = hrp.CFrame
                    wasRunning = true
                end
                local doors = getDoors()
                if #doors == 0 then
                    goToHalloweenIsland()
                    task.wait(2.0)
                    doors = getDoors()
                end
                if #doors > 0 then
                    for _, door in ipairs(doors) do
                        if not _G.NyxConfig.AutoTrickOrTreat or not isAlive() then break end
                        local last = doorCooldowns[door] or 0
                        if (os.clock() - last) >= 29 then
                            local pivot = door:IsA("BasePart") and door.CFrame or door:GetPivot()
                            if pivot then
                                hrp.CFrame = pivot * CFrame.new(0, 1.5, 3.5)
                                task.wait(0.35)
                                local prompt = door:FindFirstChildOfClass("ProximityPrompt") or door:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt and prompt.Enabled then
                                    pcall(function()
                                        prompt.HoldDuration = 0
                                        prompt.RequiresLineOfSight = false
                                        prompt.MaxActivationDistance = 35
                                    end)
                                    if type(fpp) == "function" then pcall(fpp, prompt) end
                                    pcall(function() prompt:InputHoldBegin() end)
                                    task.wait(0.05)
                                    pcall(function() prompt:InputHoldEnd() end)
                                end
                                if R.TrickKnock then fire(R.TrickKnock, door.Name) end
                                doorCooldowns[door] = os.clock()
                                task.wait(0.3)
                                -- Step back 18 studs for server re-arm (> 17 studs)
                                hrp.CFrame = pivot * CFrame.new(0, 1.5, 18)
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end
            task.wait(4.0)
        else
            if wasRunning and savedOriginCFrame then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = savedOriginCFrame end
                savedOriginCFrame = nil
                wasRunning = false
            end
            task.wait(1.5)
        end
    end
end))

-- 10. Smart Bag-Aware Worst Auto-Sell Worker
trackThread(task.spawn(function()
    while isAlive() do
        if _G.NyxConfig.SmartBagAutoSell and R.SellInventory then
            local inv = readData("Inventory", {}) or {}
            local count = 0
            for _ in pairs(inv) do count = count + 1 end
            local threshold = _G.NyxConfig.BagSellThresholdPercent or 90
            local maxBag = tonumber(readData("MaxInventory", 100)) or 100
            local slots = readData("Slots", {}) or {}
            local protectedUuids = {}
            for _, s in pairs(slots) do
                if type(s) == "table" and s.unitId then protectedUuids[s.unitId] = true end
            end
            
            local thresholdMultiplier = parseFormattedNumber(_G.NyxConfig.AutoSellMinMultiplier or "1sp")
            if (count / maxBag) >= (threshold / 100) then
                local candidateUnits = {}
                for key, item in pairs(inv) do
                    if not protectedUuids[key] and type(item) == "table" then
                        local attrs = item.attributes or item
                        local isLocked = (attrs.locked == true) or (item.locked == true)
                        local isShiny = (attrs.shiny == true) or (item.shiny == true)
                        local isHaunted = (attrs.haunted == true) or (item.haunted == true)
                        local rarity = tostring(item.rarity or attrs.rarity or "")
                        local keep = isLocked
                        if isShiny and _G.NyxConfig.ProtectShiny then keep = true end
                        if isHaunted and _G.NyxConfig.ProtectHaunted then keep = true end
                        if rarity:find("Secret") or rarity:find("Mythic") or rarity:find("Celestial") then keep = true end
                        
                        local mult = parseFormattedNumber(item.multiplier or attrs.multiplier or attrs.rollChance or "1")
                        if not keep and mult <= thresholdMultiplier then
                            table.insert(candidateUnits, { key = key, mult = mult })
                        end
                    end
                end
                
                -- Sort ascending by multiplier: worst units sold first!
                table.sort(candidateUnits, function(a, b) return a.mult < b.mult end)
                
                local sellList = {}
                for _, u in ipairs(candidateUnits) do
                    table.insert(sellList, u.key)
                end
                
                if #sellList > 0 then
                    for i = 1, #sellList, 30 do
                        local batch = {}
                        for j = i, math.min(i + 29, #sellList) do table.insert(batch, sellList[j]) end
                        fire(R.SellInventory, batch)
                        task.wait(0.2)
                    end
                end
            end
            task.wait(4.0)
        else
            task.wait(1.5)
        end
    end
end))

-- 11. WiFi Disconnect & Cash Freeze Watchdog
local lastKnownCashBalance = getPlayerCash()
trackThread(task.spawn(function()
    while isAlive() do
        -- 1. Error prompt overlay detection
        if _G.NyxConfig.AutoReconnectWiFi then
            pcall(function()
                local coreGui = game:GetService("CoreGui")
                local promptGui = coreGui:FindFirstChild("RobloxPromptGui")
                local prompt = promptGui and promptGui:FindFirstChild("promptOverlay") and promptGui.promptOverlay:FindFirstChild("ErrorPrompt")
                if prompt then
                    local recBtn = prompt:FindFirstChild("ReconnectButton", true) or prompt:FindFirstChild("Button", true)
                    if recBtn then
                        pcall(function()
                            if firesignal then firesignal(recBtn.MouseButton1Click) end
                        end)
                    end
                    task.spawn(function()
                        task.wait(2)
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                    end)
                end
            end)
        end
        -- 2. Cash collection freeze watchdog (>120s with AutoCollectCash ON)
        if _G.NyxConfig.CashWatchdogRejoin and _G.NyxConfig.AutoCollectCash then
            local curMoney = getPlayerCash()
            if curMoney ~= lastKnownCashBalance then
                -- Any balance change (collecting or deliberate spending) confirms an active, responsive connection
                lastCashCollectTime = os.clock()
                lastKnownCashBalance = curMoney
            end
            if (os.clock() - lastCashCollectTime) > 120 then
                lastCashCollectTime = os.clock()
                setupAutoExecuteOnTeleport()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        end
        task.wait(3.0)
    end
end))


-- 12. Auto Buy Best Dice Worker (Verified Ground-Truth Dice Ladder)
trackThread(task.spawn(function()
    while isAlive() do
        if _G.NyxConfig.AutoBuyDice and R.BuyDice then
            local money = getPlayerCash()
            local bestAffordable = nil
            for _, d in ipairs(DICE_LADDER) do
                if d.price <= money and canAffordSpend(d.price) then
                    bestAffordable = d.name
                end
            end
            if bestAffordable then
                fire(R.BuyDice, bestAffordable)
                if R.EquipDice then fire(R.EquipDice, bestAffordable) end
            end
            task.wait(4.0)
        else
            task.wait(1.5)
        end
    end
end))

-- 13. Auto Quirk Reroll Worker (Cheap No-Quirk Unit Prioritizer + Max Rolls Stop Limit)
trackThread(task.spawn(function()
    local quirkRollCounter = 0
    while isAlive() do
        if _G.NyxConfig.AutoQuirk and R.RerollQuirk then
            local targetRaw = _G.NyxConfig.QuirkTarget or "Prodigy"
            local target = targetRaw:match("^([%w%s%']+)") or targetRaw
            target = target:gsub("%s+$", "")
            local maxRolls = _G.NyxConfig.QuirkMaxRolls or 100
            
            -- Stop Limit Guard: stop when roll limit is reached!
            if quirkRollCounter >= maxRolls then
                _G.NyxConfig.AutoQuirk = false
                saveConfig()
                quirkRollCounter = 0
                if Rayfield then
                    Rayfield:Notify({
                        Title = "Quirk Stop Limit!",
                        Content = "Batas maksimal (" .. maxRolls .. " roll) telah tercapai. Auto Quirk dinonaktifkan.",
                        Duration = 6
                    })
                end
                task.wait(1.0)
            else
                -- Ensure player is standing near Quirks station (AntiCheatService.IsNearZone check)
                local qStation = findZoneOrStation({"Quirks", "QuirkStation", "Quirk"})
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if qStation and hrp then
                    local dist = (hrp.Position - (qStation:IsA("BasePart") and qStation.Position or qStation:GetPivot().Position)).Magnitude
                    if dist > 35 then
                        teleportToTarget(qStation)
                        task.wait(1.0)
                    end
                end
                
                local RARE_QUIRKS_BLACKLIST = {
                    ["sovereign"] = true, ["fortune's favor"] = true,
                    ["midas touch"] = true, ["prodigy"] = true, ["tycoon"] = true
                }
                local RARITY_TIERS = {
                    ["common"] = 1, ["uncommon"] = 2, ["rare"] = 3, ["epic"] = 4
                }
                
                local inv = readData("Inventory", {}) or {}
                local candidates = {}
                
                for key, item in pairs(inv) do
                    if type(item) == "table" and not item.locked then
                        local attrs = item.attributes or item
                        local curQ = tostring(attrs.quirk or item.quirk or ""):lower()
                        
                        -- Target hit check on ANY unit in inventory
                        if curQ:find(target:lower()) then
                            _G.NyxConfig.AutoQuirk = false
                            saveConfig()
                            quirkRollCounter = 0
                            if R.ProtectQuirk then fire(R.ProtectQuirk, target, true) end
                            if Rayfield then
                                Rayfield:Notify({
                                    Title = "🎉 Quirk Berhasil Didapat!",
                                    Content = "Unit berhasil mendapatkan " .. target .. "! Auto Quirk dihentikan.",
                                    Duration = 6
                                })
                            end
                            candidates = {}
                            break
                        end
                        
                        -- Never touch units holding rare quirks
                        local isRare = false
                        for rk in pairs(RARE_QUIRKS_BLACKLIST) do
                            if curQ:find(rk) then isRare = true break end
                        end
                        
                        local isShiny = (attrs.shiny == true) or (item.shiny == true)
                        local isHaunted = (attrs.haunted == true) or (item.haunted == true)
                        local rarity = tostring(item.rarity or attrs.rarity or ""):lower()
                        local rTier = RARITY_TIERS[rarity] or 99
                        
                        -- Select cheap units (Common/Uncommon/Rare), unlocked, not shiny/haunted, no rare quirk
                        if not isRare and not isShiny and not isHaunted and rTier <= 3 then
                            local hasNoQuirk = (curQ == "" or curQ == "none" or curQ == "nil")
                            local mult = parseFormattedNumber(item.multiplier or attrs.multiplier or "1")
                            table.insert(candidates, {
                                key = key,
                                hasNoQuirk = hasNoQuirk,
                                rTier = rTier,
                                mult = mult
                            })
                        end
                    end
                end
                
                if not _G.NyxConfig.AutoQuirk then
                    task.wait(1.0)
                elseif #candidates > 0 then
                    -- Priority sorting: Units with NO quirk first, then lowest rarity (Common first), then lowest multiplier!
                    table.sort(candidates, function(a, b)
                        if a.hasNoQuirk ~= b.hasNoQuirk then
                            return a.hasNoQuirk == true
                        end
                        if a.rTier ~= b.rTier then
                            return a.rTier < b.rTier
                        end
                        return a.mult < b.mult
                    end)
                    
                    local chosenKey = candidates[1].key
                    if R.ProtectQuirk then fire(R.ProtectQuirk, target, true) end
                    fire(R.RerollQuirk, chosenKey)
                    quirkRollCounter = quirkRollCounter + 1
                    task.wait(0.35)
                else
                    task.wait(1.5)
                end
            end
        else
            quirkRollCounter = 0
            task.wait(1.0)
        end
    end
end))

-- 14. Auto Fuse Units Worker (Safe: Common, Rare, Epic only)
trackThread(task.spawn(function()
    while isAlive() do
        if _G.NyxConfig.AutoFuseUnits and R.FuseUnits then
            local inv = readData("Inventory", {}) or {}
            local nameGroups = {}
            for key, item in pairs(inv) do
                if type(item) == "table" then
                    local attrs = item.attributes or item
                    local isLocked = (attrs.locked == true) or (item.locked == true)
                    local isShiny = (attrs.shiny == true) or (item.shiny == true)
                    local isHaunted = (attrs.haunted == true) or (item.haunted == true)
                    local rarity = tostring(item.rarity or attrs.rarity or "")
                    local safeToFuse = not isLocked and not isShiny and not isHaunted
                        and not rarity:find("Secret") and not rarity:find("Mythic") and not rarity:find("Celestial")
                    if safeToFuse then
                        local name = tostring(item.name or "")
                        if name ~= "" then
                            nameGroups[name] = nameGroups[name] or {}
                            table.insert(nameGroups[name], key)
                        end
                    end
                end
            end
            for name, keys in pairs(nameGroups) do
                if #keys >= 5 then
                    fire(R.FuseUnits, { keys[1], keys[2], keys[3], keys[4], keys[5] })
                    task.wait(0.3)
                end
            end
            task.wait(4.0)
        else
            task.wait(1.5)
        end
    end
end))

-- 15. Smart Towers, Manual Towers & Halloween Event Towers Worker
trackThread(task.spawn(function()
    while isAlive() do
        local shouldRun = _G.NyxConfig.SmartTowerAI or _G.NyxConfig.AutoTower or _G.NyxConfig.AutoHalloweenTowers
        if shouldRun and R.PlayTower then
            if _G.NyxConfig.AutoEquipTowerTeam and R.BestTeam then
                fire(R.BestTeam)
                task.wait(0.5)
            end
            local towerName = _G.NyxConfig.TowerType or "The Abyss"
            if _G.NyxConfig.AutoHalloweenTowers then
                local hwTowers = {"The Abyss", "Bell Tower", "Attic", "Crypt", "Foyer", "Front Yard"}
                towerName = hwTowers[math.random(1, #hwTowers)]
            elseif _G.NyxConfig.SmartTowerAI then
                local allTowers = {
                    "The Abyss", "Bell Tower", "Attic", "Crypt",
                    "Infinity Tower", "Hidden Leaf Tower", "Pirate Tower", "Cursed Tower", "Dragon Tower"
                }
                towerName = allTowers[math.random(1, #allTowers)]
            end
            
            -- Try native TowerController first, otherwise invoke PlayTower in dedicated coroutine
            local okCtrl, TowerController = pcall(function()
                return require(RS.Framework.Features.Towers.TowerController)
            end)
            if okCtrl and TowerController and type(TowerController.startTower) == "function" then
                pcall(TowerController.startTower, towerName)
            else
                task.spawn(function()
                    local okStart, resStart = pcall(R.PlayTower.InvokeServer, R.PlayTower, towerName)
                    if okStart and (resStart == true or type(resStart) == "table") and R.CompTowerFloor then
                        task.wait(0.6)
                        for floor = 1, 60 do
                            if not isAlive() then break end
                            local okFloor, resSeq = pcall(R.CompTowerFloor.InvokeServer, R.CompTowerFloor)
                            if not okFloor or resSeq == "destroyed" then break end
                            if type(resSeq) == "table" then
                                local ended = false
                                for _, a in ipairs(resSeq) do
                                    if type(a) == "table" and a.action == "ended" then ended = true break end
                                end
                                if ended then break end
                            end
                            task.wait(0.25)
                        end
                    end
                end)
            end
            task.wait(5.5)
        else
            task.wait(1.5)
        end
    end
end))

-- 16. Server Luck Hopper Worker (Cooldown-Guarded)
trackThread(task.spawn(function()
    local lastHopAttempt = 0
    while isAlive() do
        if _G.NyxConfig.ServerLuckHop and (os.clock() - lastHopAttempt > 90) then
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
            if attrLuck and attrLuck >= 1.5 then hasServerLuck = true end
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

-- 17. Visuals & ESP Worker
trackThread(task.spawn(function()
    while isAlive() do
        if _G.NyxConfig.Fullbright then
            pcall(function()
                local Lighting = game:GetService("Lighting")
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
            end)
        end
        if _G.NyxConfig.PlayerESP then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local head = plr.Character:FindFirstChild("Head")
                    if head and not head:FindFirstChild("NyxESP") then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "NyxESP"
                        billboard.Size = UDim2.new(0, 100, 0, 40)
                        billboard.StudsOffset = Vector3.new(0, 2, 0)
                        billboard.AlwaysOnTop = true
                        billboard.Parent = head
                        
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = Color3.fromRGB(56, 189, 248)
                        label.TextStrokeTransparency = 0
                        label.Font = Enum.Font.GothamBold
                        label.TextSize = 13
                        label.Text = plr.Name
                        label.Parent = billboard
                    end
                end
            end
        end
        task.wait(2.0)
    end
end))


-- 18. Auto Candy Upgrades Worker (Halloween Shop)
trackThread(task.spawn(function()
    while isAlive() do
        if _G.NyxConfig.AutoCandyUpgrades and R.BuyCandyUpg then
            local shopItems = {"Pumpkin Egg", "Ghost Dice", "Candy Potion", "Lucky Bag"}
            for _, item in ipairs(shopItems) do
                fire(R.BuyCandyUpg, item)
                task.wait(0.2)
            end
            task.wait(6.0)
        else
            task.wait(2.0)
        end
    end
end))

-- Notification Startup
if Rayfield and Window then
    Rayfield:Notify({
        Title = "🌙 Nyx Hub v8.0 Ready!",
        Content = "Liquid Glass Suite aktif sempurna! Tekan [🌙 Nyx Hub] untuk buka/tutup menu.",
        Duration = 6
    })
end
