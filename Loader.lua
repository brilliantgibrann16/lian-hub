--[[
    ═════════════════════════════════════════════════════════════════════════
    ⚡ LIAN HUB — 100% KEYLESS ANIME DICE ULTIMATE EXPLOIT SUITE v4.2 ⚡
    Author : Lian (@brilliantgibrann16)
    Repo   : https://github.com/brilliantgibrann16/lian-hub
    Fitur  : • Full TOGGLE Architecture: Semua fitur otomatisasi berbasis ON/OFF
             • Persistent Config: Semua status toggle tersimpan & otomatis aktif saat re-join
             • SMART Rebirth: Hanya klik Rebirth jika Uang Cukup (Anti-Spam)
             • SMART Stat Upgrade: Hanya upgrade saat Ada Poin dari Rebirth
             • SMART Fortune Upgrade: Hanya beli saat Uang Cukup
             • Auto Buy Best Dice (Toggle On/Off)
             • Auto Fuse Units (Toggle On/Off)
             • Extreme Potato Mode (Toggle On/Off, persistent lintas server)
             • Auto Hop Server Luck (queue_on_teleport + Anti-Rejoin Duplicate)
             • Auto Equip Best Unit on Roll + Auto Level Up Units/Plots
             • Halloween Event Suite: TP Doors Trick-or-Treat, Pumpkin Roll 5x
             • Auto Towers (Normal & Event Best Rotation + Floor Complete)
             • Full Auto Potions, Daily/Group/Offline Claims & Quests
    ═════════════════════════════════════════════════════════════════════════
--]]

repeat task.wait(0.2) until game:IsLoaded()

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

local LocalPlayer = Players.LocalPlayer

-- 1. Anti-AFK (Bebas idle kick 20 menit)
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
    task.wait(1)
end)

-- 2. Teleport Auto-Execute Queue (Biar pas pindah server script langsung jalan otomatis!)
local function setupAutoExecuteOnTeleport()
    local qot = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    if qot then
        pcall(function()
            qot('loadstring(game:HttpGet("https://raw.githubusercontent.com/brilliantgibrann16/lian-hub/main/Loader.lua"))()')
        end)
    end
end
setupAutoExecuteOnTeleport()

-- 3. Network & Framework
local NET = RS:WaitForChild("Network", 15)
local okDC, DC = pcall(function()
    return require(RS.Framework.Features.Data.DataController)
end)

local function safe(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok, res
end

-- 4. Persistent Configuration Storage (Auto Save & Load)
local CONFIG_FILE = "LianHub_AnimeDice_Config.json"
local VISITED_FILE = "LianHub_VisitedServers.json"

_G.LianConfig = {
    AutoRoll = false,
    FastRoll = false,
    AutoRollHalloween = false,
    AutoSkipTutorial = false,
    LeaveOnTarget = false,
    TargetRolls = 1000,
    AutoPotions = false,
    AutoSpin = false,
    AutoTrickOrTreat = false,
    AutoPumpkinPass = false,
    AutoCandyShop = false,
    CandyShopItem = "Pumpkin Egg",
    AutoTower = false,
    TowerType = "The Abyss",
    AutoCollectCash = false,
    AutoLevelUpSlots = false,
    AutoDailyReward = false,
    AutoQuests = false,
    AutoRedeemCodes = false,
    AutoRebirth = false,
    UpgradeLuck = true,
    UpgradeDamage = true,
    UpgradeHealth = true,
    UpgradeIncome = true,
    UpgradeSpeed = true,
    UpgradeFortune = true,
    AutoEquipBestOnRoll = false,
    AutoBuyBestDice = false,
    AutoFuseUnits = false,
    AutoQuirk = false,
    QuirkTarget = "Prodigy",
    ServerLuckHop = false,
    ExtremePotatoMode = false,
    InfJump = false,
    Noclip = false
}

local function saveConfig()
    pcall(function()
        if writefile then
            writefile(CONFIG_FILE, HttpService:JSONEncode(_G.LianConfig))
        end
    end)
end

local function loadConfig()
    pcall(function()
        if isfile and readfile and isfile(CONFIG_FILE) then
            local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
            if type(data) == "table" then
                for k, v in pairs(data) do
                    _G.LianConfig[k] = v
                end
            end
        end
    end)
end
loadConfig()

-- 5. Helper Functions & Smart Currency / Rebirth Analyzers
local function parseFormattedNumber(str)
    if not str then return 0 end
    local raw = str:gsub("[$,]", ""):lower()
    local num = tonumber(raw:match("[%d%.]+"))
    if not num then return 0 end
    if raw:find("qa") then return num * 1e15
    elseif raw:find("t") then return num * 1e12
    elseif raw:find("b") then return num * 1e9
    elseif raw:find("m") then return num * 1e6
    elseif raw:find("k") then return num * 1e3
    end
    return num
end

local function getPlayerCash()
    if DC then
        local ok1, c1 = pcall(function() return DC.Cash and DC.Cash() end)
        if ok1 and type(c1) == "number" then return c1 end
        local ok2, c2 = pcall(function() return DC.Coins and DC.Coins() end)
        if ok2 and type(c2) == "number" then return c2 end
        local ok3, c3 = pcall(function() return DC.Balance and DC.Balance() end)
        if ok3 and type(c3) == "number" then return c3 end
    end
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        local c = ls:FindFirstChild("Cash") or ls:FindFirstChild("Coins") or ls:FindFirstChild("Money")
        if c and c.Value then return c.Value end
    end
    local hud = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Root") and LocalPlayer.PlayerGui.Root:FindFirstChild("HUD")
    if hud and hud:FindFirstChild("Cash") then
        local lbl = hud.Cash:FindFirstChildWhichIsA("TextLabel", true)
        if lbl and lbl.Text then
            local val = parseFormattedNumber(lbl.Text)
            if val > 0 then return val end
        end
    end
    return 0
end

local function canAffordRebirth()
    local curCash = getPlayerCash()
    local curRebirths = 0
    if DC and DC.Rebirths then
        pcall(function() curRebirths = DC.Rebirths() end)
    end

    local okRC, RebirthConfig = pcall(function()
        return require(RS.Framework.Features.Rebirth.RebirthConfig)
    end)
    if okRC and RebirthConfig and RebirthConfig.GetCost then
        local okCost, cost = pcall(function() return RebirthConfig.GetCost(curRebirths) end)
        if okCost and type(cost) == "number" then
            return curCash >= cost, curCash, cost
        end
    end

    local rMenu = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Root") and LocalPlayer.PlayerGui.Root:FindFirstChild("Menus") and LocalPlayer.PlayerGui.Root.Menus:FindFirstChild("Rebirth")
    if rMenu then
        local costLabel = rMenu:FindFirstChild("Cash", true)
        if costLabel then
            local txt = costLabel:FindFirstChildWhichIsA("TextLabel", true)
            if txt then
                local cost = parseFormattedNumber(txt.Text)
                if cost > 0 then
                    return curCash >= cost, curCash, cost
                end
            end
        end
    end

    return false, curCash, nil
end

local function getAvailableStatPoints()
    local okRSC, RSC = pcall(function()
        return require(RS.Framework.Features.Rebirth.RebirthStatsConfig)
    end)
    if okRSC and RSC and RSC.GetRemaining then
        local curStats = {}
        local curRebirths = 0
        if DC then
            pcall(function() curStats = (DC.RebirthStats and DC.RebirthStats()) or {} end)
            pcall(function() curRebirths = (DC.Rebirths and DC.Rebirths()) or 0 end)
        end
        local okRem, rem = pcall(function() return RSC.GetRemaining(curRebirths, curStats) end)
        if okRem and type(rem) == "number" then
            return rem
        end
    end

    local rMenu = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Root") and LocalPlayer.PlayerGui.Root:FindFirstChild("Menus") and LocalPlayer.PlayerGui.Root.Menus:FindFirstChild("Rebirth")
    if rMenu then
        for _, lbl in ipairs(rMenu:GetDescendants()) do
            if lbl:IsA("TextLabel") and (lbl.Text:lower():find("point") or lbl.Text:lower():find("remaining") or lbl.Text:lower():find("stat")) then
                local num = tonumber(lbl.Text:match("%d+"))
                if num then return num end
            end
        end
    end
    return 0
end

local function canAffordFortune()
    local curCash = getPlayerCash()
    local curTier = 1
    if DC and DC.Upgrades then
        pcall(function()
            local upg = DC.Upgrades()
            if upg and upg.Fortune then curTier = upg.Fortune end
        end)
    end

    local okUC, UC = pcall(function()
        return require(RS.Framework.Features.Upgrades.UpgradesConfig)
    end)
    if okUC and UC and UC.GetCost then
        local okCost, cost = pcall(function() return UC.GetCost("Fortune", curTier) end)
        if okCost and type(cost) == "number" then
            return curCash >= cost
        end
    end
    return curCash >= 50000
end

local function applyPotatoMode(enable)
    if enable then
        pcall(function() if setfpscap then setfpscap(30) end end)
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("Light") or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                pcall(function() v.Enabled = false end)
            elseif v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.CastShadow = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            end
        end
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
    else
        pcall(function() if setfpscap then setfpscap(60) end end)
        Lighting.GlobalShadows = true
    end
end

local function getCharRoot()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

local function findMyPlot()
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local claimed = plots:FindFirstChild("Claimed")
    if not claimed then return nil end
    for _, plot in ipairs(claimed:GetChildren()) do
        local label = plot:FindFirstChild("Label")
        if label then
            local bb = label:FindFirstChild("BillboardGui")
            if bb then
                local pName = bb:FindFirstChild("PlayerName")
                if pName and (pName.Text == LocalPlayer.DisplayName or pName.Text == LocalPlayer.Name) then
                    return plot
                end
            end
        end
        local owner = plot:FindFirstChild("Owner")
        if owner and owner:IsA("ObjectValue") and owner.Value == LocalPlayer then
            return plot
        end
        if plot:GetAttribute("OwnerId") == LocalPlayer.UserId then
            return plot
        end
    end
    return nil
end

local function getMaxPlotSlots()
    local plot = findMyPlot()
    if not plot then return 18 end
    local slots = plot:FindFirstChild("Slots")
    if not slots then return 18 end
    local m = 0
    for _, s in ipairs(slots:GetChildren()) do
        local n = tonumber(s.Name)
        if n and n > m then m = n end
    end
    return m > 0 and m or 18
end

-- 6. Load UI (Rayfield — Pure Keyless)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "⚡ Lian Hub | Anime Dice Ultimate Suite",
    Icon = 0,
    LoadingTitle = "Lian Hub Injecting...",
    LoadingSubtitle = "by iannn (@brilliantgibrann16)",
    Theme = "Ocean",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = { Enabled = false },
    KeySystem = false -- 🔥 ZERO KEY SYSTEM / ZERO ADS
})

-- TABS
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local PotionsTab = Window:CreateTab("Auto Potions", 4483362458)
local HalloweenTab = Window:CreateTab("Halloween Event", 4483362458)
local TowerTab = Window:CreateTab("Towers", 4483362458)
local EconomyTab = Window:CreateTab("Plot Cash & Quests", 4483362458)
local UpgradesTab = Window:CreateTab("Rebirth & Stats", 4483362458)
local ServerTab = Window:CreateTab("Server Luck Hunter", 4483362458)
local PerfTab = Window:CreateTab("Potato & Perf", 4483362458)
local PlayerTab = Window:CreateTab("Movement", 4483362458)

-- ═════════════════════════════════════════════════════════════════════
-- TAB 1: AUTO FARM (ROLL ENGINE — DUAL-ENGINE FIX)
-- ═════════════════════════════════════════════════════════════════════
FarmTab:CreateSection("🎲 Dice Rolling Engine (Dual-Engine)")

FarmTab:CreateToggle({
    Name = "Auto Roll Dice (Native + Non-blocking Fast Spam)",
    CurrentValue = _G.LianConfig.AutoRoll,
    Flag = "ToggleAutoRoll",
    Callback = function(Value)
        _G.LianConfig.AutoRoll = Value
        saveConfig()
        if Value then
            safe(function() NET.RollService.RE.SetAutoRoll:FireServer(true) end)
            task.spawn(function()
                while _G.LianConfig.AutoRoll do
                    task.spawn(function()
                        safe(function() NET.RollService.RF.RollDice:InvokeServer() end)
                    end)
                    if _G.LianConfig.AutoEquipBestOnRoll then
                        safe(function()
                            NET.PlotService.RE.EquipBest:FireServer()
                            NET.UnitService.RF.Equip:InvokeServer("Best")
                        end)
                    end
                    task.wait(_G.LianConfig.FastRoll and 0.08 or 0.3)
                end
                safe(function() NET.RollService.RE.SetAutoRoll:FireServer(false) end)
            end)
        else
            safe(function() NET.RollService.RE.SetAutoRoll:FireServer(false) end)
        end
    end,
})

FarmTab:CreateToggle({
    Name = "Fast Roll Mode (No Animation Delay)",
    CurrentValue = _G.LianConfig.FastRoll,
    Callback = function(Value)
        _G.LianConfig.FastRoll = Value
        saveConfig()
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Roll Halloween Pumpkin Dice (5x Rolls)",
    CurrentValue = _G.LianConfig.AutoRollHalloween,
    Callback = function(Value)
        _G.LianConfig.AutoRollHalloween = Value
        saveConfig()
        if Value then
            task.spawn(function()
                while _G.LianConfig.AutoRollHalloween do
                    safe(function()
                        if NET:FindFirstChild("PumpkinDiceService") then
                            NET.PumpkinDiceService.RF.Roll:InvokeServer(5)
                        end
                    end)
                    task.wait(_G.LianConfig.FastRoll and 0.15 or 0.5)
                end
            end)
        end
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Skip / Complete Tutorial (Akun Baru)",
    CurrentValue = _G.LianConfig.AutoSkipTutorial,
    Callback = function(Value)
        _G.LianConfig.AutoSkipTutorial = Value
        saveConfig()
        if Value then
            task.spawn(function()
                while _G.LianConfig.AutoSkipTutorial do
                    safe(function()
                        local step = DC and DC.OnboardingStep and DC.OnboardingStep() or -1
                        if step < 14 and step >= 0 then
                            NET.OnboardingService.RE.Advance:FireServer()
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end,
})

FarmTab:CreateSection("🎯 Target Rolls (Auto Disconnect Nuyul)")

FarmTab:CreateInput({
    Name = "Target Rolls (Syarat Trade)",
    PlaceholderText = "Default: 1000",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then
            _G.LianConfig.TargetRolls = num
            saveConfig()
        end
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Disconnect Saat Target Rolls Tercapai",
    CurrentValue = _G.LianConfig.LeaveOnTarget,
    Callback = function(Value)
        _G.LianConfig.LeaveOnTarget = Value
        saveConfig()
        if Value then
            task.spawn(function()
                while _G.LianConfig.LeaveOnTarget do
                    local curRolls = (DC and DC.Rolls and DC.Rolls()) or 0
                    if curRolls >= _G.LianConfig.TargetRolls then
                        safe(function() NET.RollService.RE.SetAutoRoll:FireServer(false) end)
                        Rayfield:Notify({ Title = "Target Rolls Tercapai!", Content = "Rolls sudah " .. curRolls .. ". Disconnecting...", Duration = 4 })
                        task.wait(2)
                        LocalPlayer:Kick("Lian Hub: Target " .. _G.LianConfig.TargetRolls .. " Rolls Tercapai!")
                        break
                    end
                    task.wait(5)
                end
            end)
        end
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 2: AUTO POTIONS & BOOSTS (VERIFIED POTION NAMES)
-- ═════════════════════════════════════════════════════════════════════
PotionsTab:CreateSection("🧪 Potion Auto Drink Engine")

local POTIONS_LIST = {
    "Pumpkin Pot III", "Pumpkin Pot II", "Candy Pot III", "Candy Pot II",
    "Luck IV", "Luck III", "Luck II", "Luck I",
    "Damage IV", "Damage III", "Damage II",
    "Income IV", "Income III", "Income II",
    "Haunted Potion"
}

PotionsTab:CreateToggle({
    Name = "Auto Consume All Potions (Per Habis Otomatis Minum)",
    CurrentValue = _G.LianConfig.AutoPotions,
    Callback = function(Value)
        _G.LianConfig.AutoPotions = Value
        saveConfig()
        if Value then
            task.spawn(function()
                while _G.LianConfig.AutoPotions do
                    safe(function()
                        for _, potionName in ipairs(POTIONS_LIST) do
                            NET.BoostService.RE.Use:FireServer(potionName)
                            task.wait(0.1)
                        end
                    end)
                    task.wait(15)
                end
            end)
        end
    end,
})

PotionsTab:CreateToggle({
    Name = "Auto Spin Lucky Wheel",
    CurrentValue = _G.LianConfig.AutoSpin,
    Callback = function(Value)
        _G.LianConfig.AutoSpin = Value
        saveConfig()
        if Value then
            task.spawn(function()
                while _G.LianConfig.AutoSpin do
                    safe(function()
                        NET.SpinService.RE.Use:FireServer("Lucky Spin")
                    end)
                    task.wait(25)
                end
            end)
        end
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 3: HALLOWEEN EVENT SUITE (DOOR TP + PASS + CANDY SHOP)
-- ═════════════════════════════════════════════════════════════════════
HalloweenTab:CreateSection("🎃 Trick or Treat (Physical TP & Knock)")

HalloweenTab:CreateToggle({
    Name = "Auto Trick or Treat (Teleport ke Semua Pintu Rumah)",
    CurrentValue = _G.LianConfig.AutoTrickOrTreat,
    Callback = function(Value)
        _G.LianConfig.AutoTrickOrTreat = Value
        saveConfig()
        if Value then
            task.spawn(function()
                while _G.LianConfig.AutoTrickOrTreat do
                    safe(function()
                        local hFolder = Workspace:FindFirstChild("Halloween")
                        local hrp = getCharRoot()
                        if hFolder and hrp then
                            for _, house in ipairs(hFolder:GetChildren()) do
                                if not _G.LianConfig.AutoTrickOrTreat then break end
                                if house.Name:find("HouseForTrickOrTreating") then
                                    local door = house:FindFirstChild("DoorOpener")
                                    if door then
                                        hrp.CFrame = door:GetPivot()
                                        hrp.AssemblyLinearVelocity = Vector3.zero
                                        task.wait(0.3)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(5)
                end
            end)
        end
    end,
})

HalloweenTab:CreateToggle({
    Name = "Auto Claim Pumpkin Pass (Claim All Path)",
    CurrentValue = _G.LianConfig.AutoPumpkinPass,
    Callback = function(Value)
        _G.LianConfig.AutoPumpkinPass = Value
        saveConfig()
        if Value then
            task.spawn(function()
                while _G.LianConfig.AutoPumpkinPass do
                    safe(function()
                        NET.HalloweenService.RE.ClaimAllPath:FireServer()
                    end)
                    task.wait(20)
                end
            end)
        end
    end,
})

HalloweenTab:CreateSection("🍬 Candy Shop Auto Exchange")

HalloweenTab:CreateDropdown({
    Name = "Pilih Target Hadiah Candy Shop",
    Options = {"Pumpkin Egg", "Halloween Potion", "Candy Bag", "Lucky Dice"},
    CurrentOption = {_G.LianConfig.CandyShopItem or "Pumpkin Egg"},
    Callback = function(Option)
        _G.LianConfig.CandyShopItem = Option[1]
        saveConfig()
    end,
})

HalloweenTab:CreateToggle({
    Name = "Auto Exchange Candy Shop",
    CurrentValue = _G.LianConfig.AutoCandyShop,
    Callback = function(Value)
        _G.LianConfig.AutoCandyShop = Value
        saveConfig()
        if Value then
            task.spawn(function()
                while _G.LianConfig.AutoCandyShop do
                    safe(function()
                        NET.HalloweenService.RE.BuyOffer:FireServer(_G.LianConfig.CandyShopItem)
                    end)
                    task.wait(10)
                end
            end)
        end
    end,
})

HalloweenTab:CreateButton({
    Name = "Teleport ke Event Island",
    Callback = function()
        safe(function()
            NET.HalloweenService.RF.Teleport:InvokeServer("Island")
        end)
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 4: TOWERS (NORMAL & EVENT ROTATION + FLOOR CLEAR)
-- ═════════════════════════════════════════════════════════════════════
TowerTab:CreateSection("🏰 Tower Attack Engine")

local TOWER_OPTIONS = {
    "The Abyss", "Bell Tower", "Attic", "Crypt", "Foyer", "Front Yard",
    "Dragon Tower", "Cursed Tower", "Pirate Tower", "Hidden Leaf Tower", "Slayer Tower", "Shadow Tower"
}

TowerTab:CreateDropdown({
    Name = "Pilih Tower Target",
    Options = TOWER_OPTIONS,
    CurrentOption = {_G.LianConfig.TowerType or "The Abyss"},
    Callback = function(Option)
        _G.LianConfig.TowerType = Option[1]
        saveConfig()
    end,
})

TowerTab:CreateToggle({
    Name = "Auto Attack & Clear Tower (Equip Best Team + Floor Spam)",
    CurrentValue = _G.LianConfig.AutoTower,
    Callback = function(Value)
        _G.LianConfig.AutoTower = Value
        saveConfig()
        if Value then
            safe(function()
                NET.Towers.RE.EquipBestTowerTeam:FireServer()
                NET.Towers.RE.SetAutoTower:FireServer(true)
            end)
            task.spawn(function()
                while _G.LianConfig.AutoTower do
                    safe(function()
                        NET.Towers.RF.PlayTower:InvokeServer(_G.LianConfig.TowerType)
                        task.wait(1)
                        for floor = 1, 50 do
                            if not _G.LianConfig.AutoTower then break end
                            NET.Towers.RF.CompleteTowerFloor:InvokeServer()
                            task.wait(0.3)
                        end
                    end)
                    task.wait(5)
                end
                safe(function() NET.Towers.RE.SetAutoTower:FireServer(false) end)
            end)
        else
            safe(function() NET.Towers.RE.SetAutoTower:FireServer(false) end)
        end
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 5: PLOT CASH & QUESTS (AUTO LEVEL UP SLOTS)
-- ═════════════════════════════════════════════════════════════════════
EconomyTab:CreateSection("💰 Plot Cash & Slot Upgrades")

EconomyTab:CreateToggle({
    Name = "Auto Collect Cash (Plot Slot 1 to Max)",
    CurrentValue = _G.LianConfig.AutoCollectCash,
    Callback = function(Value)
        _G.LianConfig.AutoCollectCash = Value
        saveConfig()
        if Value then
            task.spawn(function()
                while _G.LianConfig.AutoCollectCash do
                    safe(function()
                        local maxS = getMaxPlotSlots()
                        for slot = 1, maxS do
                            NET.PlotService.RE.CollectBalance:FireServer(slot)
                        end
                        NET.PlotService.RE.CollectBalance:FireServer()
                    end)
                    task.wait(1.5)
                end
            end)
        end
    end,
})

EconomyTab:CreateToggle({
    Name = "Auto Upgrade Level Slot Plot (Menaikkan Level Unit di Plot)",
    CurrentValue = _G.LianConfig.AutoLevelUpSlots,
    Callback = function(Value)
        _G.LianConfig.AutoLevelUpSlots = Value
        saveConfig()
        if Value then
            task.spawn(function()
                while _G.LianConfig.AutoLevelUpSlots do
                    safe(function()
                        local maxS = getMaxPlotSlots()
                        for slot = 1, maxS do
                            NET.PlotService.RE.LevelUpSlot:FireServer(slot)
                            task.wait(0.1)
                        end
                    end)
                    task.wait(5)
                end
            end)
        end
    end,
})

EconomyTab:CreateSection("🎁 Daily, Quests & Codes")

EconomyTab:CreateToggle({
    Name = "Auto Claim Daily / Group / Offline Rewards",
    CurrentValue = _G.LianConfig.AutoDailyReward,
    Callback = function(Value)
        _G.LianConfig.AutoDailyReward = Value
        saveConfig()
        if Value then
            task.spawn(function()
                while _G.LianConfig.AutoDailyReward do
                    safe(function()
                        NET.DailyRewardService.RE.Claim:FireServer()
                        NET.GroupRewardService.RE.Claim:FireServer()
                        NET.OfflineEarningsService.RE.Claim:FireServer()
                    end)
                    task.wait(20)
                end
            end)
        end
    end,
})

EconomyTab:CreateToggle({
    Name = "Auto Claim Quests (Daily, Weekly & Halloween)",
    CurrentValue = _G.LianConfig.AutoQuests,
    Callback = function(Value)
        _G.LianConfig.AutoQuests = Value
        saveConfig()
        if Value then
            task.spawn(function()
                while _G.LianConfig.AutoQuests do
                    -- 1. Normal Quests
                    safe(function()
                        local Network = require(RS.Packages.Network)
                        local QuestConfig = require(RS.Framework.Features.Quests.QuestConfig)
                        local questSignal = Network.ClientComm.new(RS.Network, false, "QuestService"):GetSignal("Claim")
                        for _, period in ipairs({"Daily", "Weekly"}) do
                            local ok, data = pcall(function() return DC.Quests[period]() end)
                            if ok and data and data.progress and data.claimed then
                                local periodConfig = QuestConfig.Periods[period]
                                if periodConfig and periodConfig.quests then
                                    for _, quest in ipairs(periodConfig.quests) do
                                        local prog = data.progress[quest.id] or 0
                                        if prog >= quest.target and not data.claimed[quest.id] then
                                            questSignal:Fire(period, quest.id, data.expiresAt)
                                            task.wait(0.2)
                                        end
                                    end
                                end
                            end
                        end
                    end)

                    -- 2. Halloween Quests
                    safe(function()
                        local hQuests = {"Doors", "Floors", "Potion", "Rolls", "PumpkinRolls", "Dice"}
                        for _, cat in ipairs(hQuests) do
                            NET.HalloweenQuestService.RE.Claim:FireServer("Daily", cat)
                            NET.HalloweenQuestService.RE.Claim:FireServer("Hourly", cat)
                            task.wait(0.1)
                        end
                    end)

                    task.wait(10)
                end
            end)
        end
    end,
})

EconomyTab:CreateToggle({
    Name = "Auto Redeem Promo Codes Baru (On Join / Loop)",
    CurrentValue = _G.LianConfig.AutoRedeemCodes,
    Callback = function(Value)
        _G.LianConfig.AutoRedeemCodes = Value
        saveConfig()
        if Value then
            task.spawn(function()
                local CODES = {
                    "UPDATE7", "UPDATE6", "UPDATE5", "UPDATE4", "UPDATE3", "UPDATE2", "UPDATE1",
                    "400KLIKES", "250KLIKES", "100KLIKES", "40KCCU", "30KCCU", "20KCCU", "10KCCU",
                    "5KCCU", "1KCCU", "RELEASE"
                }
                while _G.LianConfig.AutoRedeemCodes do
                    for _, code in ipairs(CODES) do
                        safe(function() NET.CodesService.RE.RedeemCode:FireServer(code) end)
                        task.wait(0.15)
                    end
                    task.wait(60)
                end
            end)
        end
    end,
})

EconomyTab:CreateButton({
    Name = "🎁 Redeem Semua 17 Promo Codes Sekarang",
    Callback = function()
        local CODES = {
            "UPDATE7", "UPDATE6", "UPDATE5", "UPDATE4", "UPDATE3", "UPDATE2", "UPDATE1",
            "400KLIKES", "250KLIKES", "100KLIKES", "40KCCU", "30KCCU", "20KCCU", "10KCCU",
            "5KCCU", "1KCCU", "RELEASE"
        }
        for _, code in ipairs(CODES) do
            safe(function() NET.CodesService.RE.RedeemCode:FireServer(code) end)
            task.wait(0.15)
        end
        Rayfield:Notify({ Title = "Lian Hub", Content = "17 Promo Codes berhasil di-redeem!", Duration = 4 })
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 6: SMART REBIRTH & STATS UPGRADE (ANTI-SPAM / HANYA SAAT CUKUP)
-- ═════════════════════════════════════════════════════════════════════
UpgradesTab:CreateSection("🔄 SMART Auto Rebirth (Hanya Saat Uang Cukup)")

UpgradesTab:CreateToggle({
    Name = "SMART Auto Rebirth (Cek Harga & Uang Dulu)",
    CurrentValue = _G.LianConfig.AutoRebirth,
    Callback = function(Value)
        _G.LianConfig.AutoRebirth = Value
        saveConfig()
    end,
})

-- Loop Smart Rebirth: Hanya klik saat uang >= harga rebirth
task.spawn(function()
    while true do
        if _G.LianConfig.AutoRebirth then
            safe(function()
                local canRebirth, curCash, cost = canAffordRebirth()
                if canRebirth then
                    NET.RebirthService.RE.Rebirth:FireServer()
                    Rayfield:Notify({ Title = "Rebirth Sukses!", Content = "Uang cukup ($" .. math.floor(curCash) .. "). Rebirth berhasil diproses!", Duration = 3 })
                    task.wait(2)
                end
            end)
        end
        task.wait(4) -- Cek santai tiap 4 detik, TANPA SPAM!
    end
end)

UpgradesTab:CreateSection("📈 SMART Stat Upgrades (Hanya Saat Ada Poin Rebirth)")

UpgradesTab:CreateToggle({
    Name = "Upgrade Stat: Luck",
    CurrentValue = _G.LianConfig.UpgradeLuck,
    Callback = function(v) _G.LianConfig.UpgradeLuck = v; saveConfig() end
})

UpgradesTab:CreateToggle({
    Name = "Upgrade Stat: Damage",
    CurrentValue = _G.LianConfig.UpgradeDamage,
    Callback = function(v) _G.LianConfig.UpgradeDamage = v; saveConfig() end
})

UpgradesTab:CreateToggle({
    Name = "Upgrade Stat: Health",
    CurrentValue = _G.LianConfig.UpgradeHealth,
    Callback = function(v) _G.LianConfig.UpgradeHealth = v; saveConfig() end
})

UpgradesTab:CreateToggle({
    Name = "Upgrade Stat: Income",
    CurrentValue = _G.LianConfig.UpgradeIncome,
    Callback = function(v) _G.LianConfig.UpgradeIncome = v; saveConfig() end
})

UpgradesTab:CreateToggle({
    Name = "Upgrade Stat: Speed",
    CurrentValue = _G.LianConfig.UpgradeSpeed,
    Callback = function(v) _G.LianConfig.UpgradeSpeed = v; saveConfig() end
})

UpgradesTab:CreateToggle({
    Name = "Upgrade Shop: Fortune (Hanya Saat Uang Cukup)",
    CurrentValue = _G.LianConfig.UpgradeFortune,
    Callback = function(v) _G.LianConfig.UpgradeFortune = v; saveConfig() end
})

-- SMART Stat Upgrade Loop: Hanya menambah stat saat ADA poin yang belum dipakai!
task.spawn(function()
    while true do
        safe(function()
            local points = getAvailableStatPoints()
            if points and points > 0 then
                local chosenStats = {}
                if _G.LianConfig.UpgradeLuck then table.insert(chosenStats, "Luck") end
                if _G.LianConfig.UpgradeDamage then table.insert(chosenStats, "Damage") end
                if _G.LianConfig.UpgradeHealth then table.insert(chosenStats, "Health") end
                if _G.LianConfig.UpgradeIncome then table.insert(chosenStats, "Income") end
                if _G.LianConfig.UpgradeSpeed then table.insert(chosenStats, "Speed") end

                if #chosenStats > 0 then
                    for _, stat in ipairs(chosenStats) do
                        if getAvailableStatPoints() <= 0 then break end
                        NET.RebirthService.RE.AddStat:FireServer(stat, 1)
                        task.wait(0.2)
                    end
                end
            end

            -- Fortune Upgrade di Shop (Hanya jika uang cukup)
            if _G.LianConfig.UpgradeFortune and canAffordFortune() then
                NET.RE.BuyUpgrade:FireServer("Fortune XV")
                NET.RE.BuyUpgrade:FireServer("Fortune")
            end
        end)
        task.wait(3) -- Interval aman tanpa spam paket ke server
    end
end)

UpgradesTab:CreateSection("⚔️ Unit Management & Fusing")

UpgradesTab:CreateToggle({
    Name = "Auto Equip Best Unit Tiap Roll (Plot + Tower)",
    CurrentValue = _G.LianConfig.AutoEquipBestOnRoll,
    Callback = function(Value)
        _G.LianConfig.AutoEquipBestOnRoll = Value
        saveConfig()
        if Value then
            safe(function()
                NET.PlotService.RE.EquipBest:FireServer()
                NET.UnitService.RF.Equip:InvokeServer("Best")
                NET.Towers.RE.EquipBestTowerTeam:FireServer()
            end)
        end
    end,
})

UpgradesTab:CreateToggle({
    Name = "Auto Fuse Units (Gabungkan Unit Kembar Otomatis)",
    CurrentValue = _G.LianConfig.AutoFuseUnits,
    Callback = function(Value)
        _G.LianConfig.AutoFuseUnits = Value
        saveConfig()
        if Value then
            task.spawn(function()
                while _G.LianConfig.AutoFuseUnits do
                    safe(function()
                        if NET:FindFirstChild("FusingService") then
                            NET.FusingService.RE.Fuse:FireServer()
                        end
                    end)
                    task.wait(6)
                end
            end)
        end
    end,
})

UpgradesTab:CreateSection("🎲 Auto Buy Best Dice")

UpgradesTab:CreateToggle({
    Name = "Auto Buy & Equip Best Dice (Toggle On/Off)",
    CurrentValue = _G.LianConfig.AutoBuyBestDice,
    Callback = function(Value)
        _G.LianConfig.AutoBuyBestDice = Value
        saveConfig()
        if Value then
            task.spawn(function()
                local diceList = {"Golden", "Diamond", "Sinister", "Galaxy", "Asteroid", "Blackhole", "Cherub", "Solaris", "Volcanic"}
                while _G.LianConfig.AutoBuyBestDice do
                    safe(function()
                        for _, d in ipairs(diceList) do
                            NET.DiceShopService.RE.BuyDice:FireServer(d)
                            NET.DiceShopService.RE.EquipDice:FireServer(d)
                            task.wait(0.1)
                        end
                    end)
                    task.wait(10)
                end
            end)
        end
    end,
})

UpgradesTab:CreateSection("✨ Quirk Trait Hunter")

UpgradesTab:CreateDropdown({
    Name = "Target Quirk",
    Options = {"Prodigy (High Luck)", "Fortune's Favor (Super Luck)"},
    CurrentOption = {_G.LianConfig.QuirkTarget or "Prodigy"},
    Callback = function(Option)
        if Option[1]:find("Fortune") then
            _G.LianConfig.QuirkTarget = "Fortune's Favor"
        else
            _G.LianConfig.QuirkTarget = "Prodigy"
        end
        saveConfig()
    end,
})

UpgradesTab:CreateToggle({
    Name = "Auto Reroll Quirk (Roll Trait)",
    CurrentValue = _G.LianConfig.AutoQuirk,
    Callback = function(Value)
        _G.LianConfig.AutoQuirk = Value
        saveConfig()
        if Value then
            task.spawn(function()
                while _G.LianConfig.AutoQuirk do
                    safe(function()
                        local okInv, inv = pcall(function() return DC.Inventory() end)
                        if okInv and inv then
                            for key, unit in pairs(inv) do
                                local quirk = unit.attributes and unit.attributes.quirk
                                if quirk ~= _G.LianConfig.QuirkTarget then
                                    NET.QuirkService.RE.Roll:FireServer(key)
                                    break
                                end
                            end
                        end
                    end)
                    task.wait(0.3)
                end
            end)
        end
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 7: SERVER LUCK HUNTER (SMART HOPPER + ANTI-REJOIN SAME SERVER)
-- ═════════════════════════════════════════════════════════════════════
ServerTab:CreateSection("⚡ Server Luck Event Hunter (Auto-Loop)")

local function getVisitedServers()
    local visited = {}
    pcall(function()
        if isfile and readfile and isfile(VISITED_FILE) then
            visited = HttpService:JSONDecode(readfile(VISITED_FILE)) or {}
        end
    end)
    return visited
end

local function markServerVisited(jobId)
    pcall(function()
        local v = getVisitedServers()
        v[jobId] = os.time()
        local now = os.time()
        for id, t in pairs(v) do
            if now - t > 3600 then v[id] = nil end
        end
        if writefile then writefile(VISITED_FILE, HttpService:JSONEncode(v)) end
    end)
end

local isHopping = false

local function smartHop()
    if isHopping then return false end
    isHopping = true
    setupAutoExecuteOnTeleport()
    markServerVisited(game.JobId)
    local visited = getVisitedServers()

    local candidates = {}
    local cursor = ""
    -- Cari di 3 halaman public server dengan pemain sedikit (Ascending) agar tidak gagal/penuh
    for page = 1, 3 do
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and ("&cursor=" .. cursor) or "")
        local ok, res = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
        if ok and res and res.data then
            for _, s in ipairs(res.data) do
                if s.id ~= game.JobId and not visited[s.id] and s.playing < (s.maxPlayers - 1) and s.playing >= 1 then
                    table.insert(candidates, s.id)
                end
            end
            if res.nextPageCursor and res.nextPageCursor ~= "" then
                cursor = res.nextPageCursor
            else
                break
            end
        else
            break
        end
    end

    if #candidates > 0 then
        -- Acak dari kandidat server baru yang belum pernah dikunjungi
        local chosenId = candidates[math.random(1, #candidates)]
        markServerVisited(chosenId)
        local okTp = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, chosenId, LocalPlayer)
        end)
        if okTp then return true end
    end

    -- Jika seluruh server di list sudah pernah dikunjungi, reset riwayat lama
    pcall(function()
        if delfile then delfile(VISITED_FILE) end
    end)
    task.wait(2)
    isHopping = false
    return false
end

-- Auto retry jika teleport terputus/gagal
TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
    if player == LocalPlayer and _G.LianConfig.ServerLuckHop then
        task.wait(1)
        smartHop()
    end
end)

ServerTab:CreateToggle({
    Name = "Auto Hop Cari Server Event (Luck / Clover / Haunted)",
    CurrentValue = _G.LianConfig.ServerLuckHop,
    Callback = function(Value)
        _G.LianConfig.ServerLuckHop = Value
        saveConfig()
        if Value then
            task.spawn(function()
                while _G.LianConfig.ServerLuckHop do
                    local weather = (DC and DC.Weather and DC.Weather()) or ""
                    local isEvent = weather:find("Luck") or weather:find("Clover") or weather:find("Haunted") or weather:find("Golden")
                    if not isEvent then
                        -- Mode senyap: jangan spam notifikasi saat hopping
                        task.wait(1)
                        smartHop()
                        break
                    else
                        -- HANYA notifikasi jika event ditemukan!
                        Rayfield:Notify({ Title = "🎉 Event Ditemukan!", Content = "Cuaca: " .. tostring(weather) .. "! Mulai auto-farm di sini.", Duration = 6 })
                    end
                    task.wait(30)
                end
            end)
        end
    end,
})

ServerTab:CreateButton({
    Name = "Manual Smart Server Hop (Cari Server Baru)",
    Callback = function() smartHop() end
})

ServerTab:CreateButton({
    Name = "Rejoin Server Ini",
    Callback = function()
        setupAutoExecuteOnTeleport()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 8: POTATO OPTIMIZER & PERFORMANCE (TOGGLE ON/OFF)
-- ═════════════════════════════════════════════════════════════════════
PerfTab:CreateSection("❄️ CPU / GPU Saver (Khusus Nuyul Multi-Client)")

PerfTab:CreateToggle({
    Name = "Extreme Potato Mode (FPS Cap 30 + No Graphics)",
    CurrentValue = _G.LianConfig.ExtremePotatoMode,
    Callback = function(Value)
        _G.LianConfig.ExtremePotatoMode = Value
        saveConfig()
        applyPotatoMode(Value)
        if Value then
            Rayfield:Notify({ Title = "Potato Mode ON!", Content = "FPS 30 & grafis minimal aktif! Laptop dingin.", Duration = 3 })
        else
            Rayfield:Notify({ Title = "Potato Mode OFF", Content = "Grafis kembali normal.", Duration = 3 })
        end
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 9: PLAYER & MOVEMENT
-- ═════════════════════════════════════════════════════════════════════
PlayerTab:CreateSection("🏃 Movement")

PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 250},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 350},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(Value) _G.LianConfig.InfJump = Value end,
})

UserInputService.JumpRequest:Connect(function()
    if _G.LianConfig.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(Value) _G.LianConfig.Noclip = Value end,
})

RunService.Stepped:Connect(function()
    if _G.LianConfig.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- Initial Auto-Run based on loaded config
task.spawn(function()
    task.wait(2)
    -- Auto apply potato mode if enabled in saved config
    if _G.LianConfig.ExtremePotatoMode then
        applyPotatoMode(true)
    end

    -- Auto check server luck if enabled in saved config (Mode Senyap)
    if _G.LianConfig.ServerLuckHop then
        local weather = (DC and DC.Weather and DC.Weather()) or ""
        local isEvent = weather:find("Luck") or weather:find("Clover") or weather:find("Haunted") or weather:find("Golden")
        if not isEvent then
            task.wait(1)
            smartHop()
        else
            Rayfield:Notify({
                Title = "🎉 Event Ditemukan!",
                Content = "Cuaca Event: " .. tostring(weather) .. "! Mulai auto-farm di sini.",
                Duration = 6
            })
        end
    else
        -- HANYA munculkan notifikasi Lian Hub Loaded jika BUKAN sedang dalam loop Server Hop!
        Rayfield:Notify({
            Title = "Lian Hub Loaded!",
            Content = "Semua konfigurasi tersimpan aktif tanpa notifikasi spam!",
            Duration = 4
        })
    end
end)
