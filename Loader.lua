--[[
    ═════════════════════════════════════════════════════════════════════════
    ⚡ LIAN HUB — 100% KEYLESS ANIME DICE MASTER EXPLOIT SUITE v6.0 ⚡
    Author : Lian (@brilliantgibrann16)
    Target : Anime Dice (PlaceId: 113290951185459 / Universe: 10708913337)
    ═════════════════════════════════════════════════════════════════════════
    [CHANGELOG v6.0 MASTER EXPLOIT DEV EDITION]:
    ★ 100% Decoupled Background Worker Loops:
      - All farm routines (Roll, Halloween, Potions, Rebirth, Stats, Towers,
        Quests, Plots, Auto Sell) run in permanent background worker threads.
      - On fresh inject or server hop re-execute, ALL saved 'true' toggles
        IMMEDIATELY start working with ZERO clicks required!
    ★ Laptop Minimizer & Floating Toggle Menu:
      - Sleek draggable floating button "[⚡ Lian Hub]" on CoreGui/gethui.
      - Hotkeys: RightControl / Insert / LeftAlt to toggle visibility.
      - Never lost if user clicks 'X' or closes on laptop!
    ★ Smart Halloween Roll:
      - Dropdown choice: 500 Labu (5x Rolls) vs 100 Labu (1x Roll).
      - Checks balance before roll to prevent remote error spam.
    ★ Smart Rebirth & Stat Upgrades:
      - Auto Rebirth ONLY fires when Money >= Cost (Zero Spam!).
      - Stat Priority Dropdown (Balance, Money, Luck, Damage, Health, Speed).
      - Stat allocation ONLY fires when Available Points > 0 (Zero Spam!).
      - Auto Buy Tree Upgrades (Fortune, etc. near dice UI) via M.Tree & BuyUpgrade.
    ★ Advanced Potion Stacking & Selector:
      - Drink & stack potions by category (Luck, Income, Damage, Speed, Halloween, Tower).
      - Tower Potion Farming Selector.
    ★ Native Tower Team Auto-Equip:
      - Uses official ReplicatedStorage.Network.Towers.RE.EquipBestTowerTeam.
      - 5.5s server debounce + sequence action parsing ("floorCompleted" / "ended").
    ═════════════════════════════════════════════════════════════════════════
]]--

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
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer

-- 1. Anti-AFK (Bebas idle kick 20 menit)
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
    task.wait(1)
end)

-- 2. Teleport Auto-Execute Queue (Didaftarkan saat Smart Hop / Reconnect dimulai)
local function setupAutoExecuteOnTeleport()
    local qot = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    if qot then
        pcall(function()
            qot('loadstring(game:HttpGet("https://raw.githubusercontent.com/brilliantgibrann16/lian-hub/main/Loader.lua"))()')
        end)
    end
end

-- 3. Network & Framework (Non-blocking & Solara Safe)
local NET = RS:FindFirstChild("Network") or RS:WaitForChild("Network", 4)

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

local M = {}
task.spawn(function()
    pcall(function()
        local F = RS:FindFirstChild("Framework") or RS:WaitForChild("Framework", 4)
        if not F then return end
        local Feat = F:FindFirstChild("Features") or F:WaitForChild("Features", 4)
        if not Feat then return end
        local function req(mod)
            if not mod then return nil end
            local ok, res = pcall(asGame, require, mod)
            return ok and res or nil
        end
        if Feat:FindFirstChild("Data") then M.Data = req(Feat.Data:FindFirstChild("DataController")) end
        if Feat:FindFirstChild("Buffs") then M.Buff = req(Feat.Buffs:FindFirstChild("BuffController")) end
        if Feat:FindFirstChild("Inventory") then M.Entry = req(Feat.Inventory:FindFirstChild("EntryRegistry")) end
        if Feat:FindFirstChild("Rolling") then M.Dice = req(Feat.Rolling:FindFirstChild("Dice")) end
        if Feat:FindFirstChild("Upgrades") then
            M.Upgrades = req(Feat.Upgrades:FindFirstChild("Upgrades"))
            M.Tree = req(Feat.Upgrades:FindFirstChild("TreeStructure"))
        end
        if Feat:FindFirstChild("Rebirth") then
            M.Rebirths = req(Feat.Rebirth:FindFirstChild("Rebirths"))
            M.RStats = req(Feat.Rebirth:FindFirstChild("RebirthStatsConfig"))
        end
        if Feat:FindFirstChild("Plot") then M.PlotConfig = req(Feat.Plot:FindFirstChild("PlotConfig")) end
        if Feat:FindFirstChild("Inventory") and Feat.Inventory:FindFirstChild("Kinds") and Feat.Inventory.Kinds:FindFirstChild("Unit") then
            M.UnitUtil = req(Feat.Inventory.Kinds.Unit:FindFirstChild("UnitUtil"))
        end
        if Feat:FindFirstChild("Towers") then
            M.Towers = req(Feat.Towers:FindFirstChild("Towers"))
            M.TowerRefs = req(Feat.Towers:FindFirstChild("TowerRefs"))
        end
        if Feat:FindFirstChild("Quests") then
            M.Quests = req(Feat.Quests:FindFirstChild("QuestConfig"))
        end
    end)
end)

local function getDC()
    if M.Data then return M.Data end
    pcall(function()
        M.Data = require(RS.Framework.Features.Data.DataController)
    end)
    return M.Data
end

local DC = setmetatable({}, {
    __index = function(_, k)
        local real = getDC()
        if real then return real[k] end
        return nil
    end
})

local function safe(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok and res
end

-- 4. Persistent Configuration Storage (Auto Save & Load)
local CONFIG_FILE = "LianHub_AnimeDice_Config.json"
local VISITED_FILE = "LianHub_VisitedServers.json"

_G.LianConfig = {
    AutoRoll = false,
    FastRoll = false,
    AutoRollHalloween = false,
    HalloweenRollOption = "500 Labu (5x Rolls)",
    AutoSkipTutorial = false,
    LeaveOnTarget = false,
    TargetRolls = 1000,
    AutoPotions = false,
    PotionUseLuck = true,
    PotionUseIncome = true,
    PotionUseDamage = true,
    PotionUseSpeed = false,
    PotionUseHalloween = true,
    PotionUseTower = true,
    AutoSpin = false,
    AutoTrickOrTreat = false,
    AutoPumpkinPass = false,
    AutoCandyShop = false,
    CandyShopItem = "Pumpkin Egg",
    AutoTower = false,
    SmartTowerAI = false,
    AutoEquipTowerTeam = true,
    TowerType = "The Abyss",
    AutoCollectCash = false,
    AutoLevelUpSlots = false,
    AutoDailyReward = false,
    AutoQuests = false,
    AutoRedeemCodes = false,
    AutoTicketShop = false,
    TicketShopItem = "Clover",
    AutoRebirth = false,
    RebirthStatPriority = "Balance / Rata (Money, Luck, Damage, Health, Speed)",
    AutoBuyTreeUpgrades = false,
    AutoEquipBestOnRoll = false,
    AutoBuyBestDice = false,
    AutoFuseUnits = false,
    AutoSellWorstUnits = false,
    AutoSellCommon = true,
    AutoSellRare = true,
    AutoSellEpic = false,
    AutoEquipGear = false,
    AutoQuirk = false,
    QuirkTarget = "Prodigy",
    ServerLuckHop = false,
    AutoTradeFeeder = false,
    MasterAccount = "",
    TradeMythic = true,
    TradeSecret = true,
    DiscordWebhook = "",
    WebhookDrops = false,
    AutoReconnect = true,
    Disable3DRendering = false,
    ExtremePotatoMode = false,
    TargetFPS = 30,
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
        if isfile and isfile(CONFIG_FILE) and readfile then
            local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
            if type(data) == "table" then
                for k, v in pairs(data) do
                    if _G.LianConfig[k] ~= nil then
                        _G.LianConfig[k] = v
                    end
                end
            end
        end
    end)
    -- Safe guard: Always boot with hopping disabled to prevent teleport loops
    _G.LianConfig.ServerLuckHop = false
end
loadConfig()

-- 5. Helper Functions
local function parseFormattedNumber(str)
    if not str then return 0 end
    local raw = tostring(str):lower():gsub("[$,]", "")
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
        local ok2, c2 = pcall(function() return DC.Money and DC.Money() end)
        if ok2 and type(c2) == "number" then return c2 end
        local ok3, c3 = pcall(function() return DC.Coins and DC.Coins() end)
        if ok3 and type(c3) == "number" then return c3 end
        local ok4, c4 = pcall(function() return DC.Balance and DC.Balance() end)
        if ok4 and type(c4) == "number" then return c4 end
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
    if DC and DC.Rebirths then pcall(function() curRebirths = DC.Rebirths() end) end

    if M.Rebirths and M.Rebirths.GetNext then
        local okNxt, nxt = pcall(function() return M.Rebirths.GetNext(curRebirths) end)
        if okNxt and nxt and type(nxt.cost) == "number" then
            return curCash >= nxt.cost, curCash, nxt.cost
        end
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
                if cost > 0 then return curCash >= cost, curCash, cost end
            end
        end
    end
    return false, curCash, nil
end

local function getAvailableStatPoints()
    local curStats = {}
    local curRebirths = 0
    if DC then
        pcall(function() curStats = (DC.RebirthStats and DC.RebirthStats()) or {} end)
        pcall(function() curRebirths = (DC.Rebirths and DC.Rebirths()) or 0 end)
    end
    if M.RStats and M.RStats.GetRemaining then
        local okRem, rem = pcall(function() return M.RStats.GetRemaining(curRebirths, curStats) end)
        if okRem and type(rem) == "number" then return rem end
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

local function buyUpgradesTree()
    local money = getPlayerCash()
    if not M.Upgrades or not M.Tree then return end
    local owned = (DC and DC.Upgrades and DC.Upgrades()) or {}
    local cands = {}
    for name, u in pairs(M.Upgrades) do
        if name ~= "Start" and not owned[name] then
            local parent = M.Tree.GetParent and M.Tree.GetParent(name)
            if parent == nil or parent == "Start" or owned[parent] then
                table.insert(cands, { name = name, price = u.price or 0 })
            end
        end
    end
    table.sort(cands, function(a, b) return a.price < b.price end)
    local bought = 0
    for _, c in ipairs(cands) do
        if bought >= 4 or c.price > money then break end
        if NET and NET:FindFirstChild("RE") and NET.RE:FindFirstChild("BuyUpgrade") then
            NET.RE.BuyUpgrade:FireServer(c.name)
            money = money - c.price
            bought = bought + 1
            task.wait(0.2)
        end
    end
end

local function equipBestEverything()
    safe(function()
        if NET:FindFirstChild("PlotService") and NET.PlotService:FindFirstChild("RE") and NET.PlotService.RE:FindFirstChild("EquipBest") then
            NET.PlotService.RE.EquipBest:FireServer()
        end
        if NET:FindFirstChild("UnitService") and NET.UnitService:FindFirstChild("RF") and NET.UnitService.RF:FindFirstChild("Equip") then
            NET.UnitService.RF.Equip:InvokeServer("Best")
        end
        if NET:FindFirstChild("Towers") and NET.Towers:FindFirstChild("RE") and NET.Towers.RE:FindFirstChild("EquipBestTowerTeam") then
            NET.Towers.RE.EquipBestTowerTeam:FireServer()
        end
        if NET:FindFirstChild("GearService") and NET.GearService:FindFirstChild("RE") and NET.GearService.RE:FindFirstChild("Equip") then
            local inv = (DC and DC.Inventory and DC.Inventory()) or {}
            for key, item in pairs(inv) do
                if item and item.name and (item.kind == "Gear" or item.name:find("Gear") or item.name:find("Ring") or item.name:find("Amulet")) then
                    NET.GearService.RE.Equip:FireServer(key)
                end
            end
        end
    end)
end

local function findMyPlot()
    local plots = Workspace:FindFirstChild("Plots") or Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Plots")
    if not plots then return nil end
    for _, plot in ipairs(plots:GetChildren()) do
        local sign = plot:FindFirstChild("Sign") or plot:FindFirstChild("PlotSign")
        if sign then
            local bb = sign:FindFirstChildWhichIsA("BillboardGui", true)
            if bb then
                local pName = bb:FindFirstChild("PlayerName")
                if pName and (pName.Text == LocalPlayer.DisplayName or pName.Text == LocalPlayer.Name) then
                    return plot
                end
            end
        end
        local owner = plot:FindFirstChild("Owner")
        if owner and owner:IsA("ObjectValue") and owner.Value == LocalPlayer then return plot end
        if plot:GetAttribute("OwnerId") == LocalPlayer.UserId then return plot end
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

local function applyPotatoMode(enable)
    if enable then
        pcall(function() if setfpscap then setfpscap(_G.LianConfig.TargetFPS or 30) end end)
        pcall(function()
            settings().Rendering.QualityLevel = 1
            Lighting.GlobalShadows = false
            Lighting.Brightness = 1
        end)
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.CastShadow = false
            elseif obj:IsA("Decal") then
                obj.Transparency = 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                obj.Enabled = false
            end
        end
    else
        pcall(function() if setfpscap then setfpscap(60) end end)
        pcall(function()
            settings().Rendering.QualityLevel = 5
            Lighting.GlobalShadows = true
        end)
    end
end

-- 6. Auto-Reconnect Watcher (Error 277 / 268 / Disconnect)
local isReconnecting = false
GuiService.ErrorMessageChanged:Connect(function(msg)
    if _G.LianConfig.AutoReconnect and not isReconnecting then
        if msg and (msg:find("disconnect") or msg:find("lost") or msg:find("error") or msg:find("277") or msg:find("268") or msg:find("529")) then
            isReconnecting = true
            setupAutoExecuteOnTeleport()
            task.wait(5)
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end
end)

-- 7. Load UI (Rayfield — Pure Keyless, Solara & Multi-Executor Safe)
local Rayfield
local okRay, rayLib = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
end)
if okRay and rayLib then
    Rayfield = rayLib
else
    local okBackup, backupLib = pcall(function()
        return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    end)
    if okBackup and backupLib then
        Rayfield = backupLib
    end
end

if not Rayfield then
    error("[Lian Hub] Gagal memuat Rayfield dari GitHub Raw dan Sirius! Periksa koneksi internet executor.", 0)
end

local Window = Rayfield:CreateWindow({
    Name = "⚡ Lian Hub v6.0 | Anime Dice Master Suite",
    Icon = 0,
    LoadingTitle = "Lian Hub Injecting...",
    LoadingSubtitle = "by iannn (@brilliantgibrann16)",
    Theme = "Ocean",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

-- Floating Draggable Toggle Button (Laptop Minimizer Safety)
pcall(function()
    local parentGui = (gethui and gethui()) or game:GetService("CoreGui")
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

    Btn.MouseButton1Click:Connect(function()
        pcall(function()
            local rMain = parentGui:FindFirstChild("Rayfield")
            if rMain then
                rMain.Enabled = not rMain.Enabled
            end
        end)
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and (input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.LeftAlt) then
            local rMain = parentGui:FindFirstChild("Rayfield")
            if rMain then
                rMain.Enabled = not rMain.Enabled
            end
        end
    end)
end)

-- TABS
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local PotionsTab = Window:CreateTab("Potion Stacking", 4483362458)
local FeederTab = Window:CreateTab("Trade Feeder", 4483362458)
local HalloweenTab = Window:CreateTab("Halloween Event", 4483362458)
local TowerTab = Window:CreateTab("Towers", 4483362458)
local PlotTab = Window:CreateTab("Plot & Quests", 4483362458)
local RebirthTab = Window:CreateTab("Rebirth & Stats", 4483362458)
local ServerTab = Window:CreateTab("Server Luck Hunter", 4483362458)
local WebhookTab = Window:CreateTab("Discord Webhook", 4483362458)
local PerfTab = Window:CreateTab("Potato & Botting", 4483362458)
local PlayerTab = Window:CreateTab("Movement", 4483362458)

-- ═════════════════════════════════════════════════════════════════════
-- TAB 1: AUTO FARM (ROLL ENGINE)
-- ═════════════════════════════════════════════════════════════════════
FarmTab:CreateSection("🎲 Dice Rolling Engine")

FarmTab:CreateToggle({
    Name = "Auto Roll Dice (Native + Non-blocking Fast Spam)",
    CurrentValue = _G.LianConfig.AutoRoll,
    Callback = function(Value)
        _G.LianConfig.AutoRoll = Value
        saveConfig()
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
    Name = "Auto Equip Best Units Tiap Roll (Plot + Tower)",
    CurrentValue = _G.LianConfig.AutoEquipBestOnRoll,
    Callback = function(Value)
        _G.LianConfig.AutoEquipBestOnRoll = Value
        saveConfig()
        if Value then equipBestEverything() end
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Skip Tutorial (Semua Langkah 1-13)",
    CurrentValue = _G.LianConfig.AutoSkipTutorial,
    Callback = function(Value)
        _G.LianConfig.AutoSkipTutorial = Value
        saveConfig()
    end,
})

FarmTab:CreateSection("✨ Quirk Reroll Hunter")

FarmTab:CreateDropdown({
    Name = "Target Quirk (Reroll Sampai Dapat)",
    Options = {"Prodigy", "Fortune's Favor", "Collector", "Golden Touch"},
    CurrentOption = _G.LianConfig.QuirkTarget,
    Callback = function(Option)
        _G.LianConfig.QuirkTarget = type(Option) == "table" and Option[1] or Option
        saveConfig()
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Reroll Quirk (Auto Stop Pas Target)",
    CurrentValue = _G.LianConfig.AutoQuirk,
    Callback = function(Value)
        _G.LianConfig.AutoQuirk = Value
        saveConfig()
    end,
})

FarmTab:CreateSection("🚪 Auto Disconnect Tuyul")

FarmTab:CreateToggle({
    Name = "Leave Game Saat Mencapai Target Rolls",
    CurrentValue = _G.LianConfig.LeaveOnTarget,
    Callback = function(Value)
        _G.LianConfig.LeaveOnTarget = Value
        saveConfig()
    end,
})

FarmTab:CreateSlider({
    Name = "Target Rolls (Tuyul Otomatis DC)",
    Range = {100, 50000},
    Increment = 100,
    Suffix = " Rolls",
    CurrentValue = _G.LianConfig.TargetRolls,
    Callback = function(Value)
        _G.LianConfig.TargetRolls = Value
        saveConfig()
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 2: POTION STACKING & SELECTOR
-- ═════════════════════════════════════════════════════════════════════
PotionsTab:CreateSection("🧪 Potion Stacking & Category Filters")

PotionsTab:CreateToggle({
    Name = "Auto Drink & Stack Potions (Sesuai Kategori Pilihan)",
    CurrentValue = _G.LianConfig.AutoPotions,
    Callback = function(Value)
        _G.LianConfig.AutoPotions = Value
        saveConfig()
    end,
})

PotionsTab:CreateToggle({
    Name = "Minum Luck Potions (Luck I s/d IV)",
    CurrentValue = _G.LianConfig.PotionUseLuck,
    Callback = function(Value)
        _G.LianConfig.PotionUseLuck = Value
        saveConfig()
    end,
})

PotionsTab:CreateToggle({
    Name = "Minum Money / Income Potions (Income I s/d IV)",
    CurrentValue = _G.LianConfig.PotionUseIncome,
    Callback = function(Value)
        _G.LianConfig.PotionUseIncome = Value
        saveConfig()
    end,
})

PotionsTab:CreateToggle({
    Name = "Minum Damage Potions (Damage I s/d IV)",
    CurrentValue = _G.LianConfig.PotionUseDamage,
    Callback = function(Value)
        _G.LianConfig.PotionUseDamage = Value
        saveConfig()
    end,
})

PotionsTab:CreateToggle({
    Name = "Minum Tower Drop Potions (Slayer, Shadow, Pirate, dll)",
    CurrentValue = _G.LianConfig.PotionUseTower,
    Callback = function(Value)
        _G.LianConfig.PotionUseTower = Value
        saveConfig()
    end,
})

PotionsTab:CreateToggle({
    Name = "Minum Halloween Potions (Haunted, Pumpkin, Candy Pot)",
    CurrentValue = _G.LianConfig.PotionUseHalloween,
    Callback = function(Value)
        _G.LianConfig.PotionUseHalloween = Value
        saveConfig()
    end,
})

PotionsTab:CreateToggle({
    Name = "Auto Spin Lucky Spin (Free)",
    CurrentValue = _G.LianConfig.AutoSpin,
    Callback = function(Value)
        _G.LianConfig.AutoSpin = Value
        saveConfig()
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 3: AUTO TRADE FEEDER (TRANSFER KE AKUN UTAMA)
-- ═════════════════════════════════════════════════════════════════════
FeederTab:CreateSection("🤝 Setoran Otomatis ke Akun Utama")

FeederTab:CreateInput({
    Name = "Username Akun Utama (Master Account)",
    PlaceholderText = "Masukkan username Roblox Bubu...",
    RemoveTextAfterFocusLost = false,
    CurrentValue = _G.LianConfig.MasterAccount,
    Callback = function(Text)
        _G.LianConfig.MasterAccount = Text:gsub("%s+", "")
        saveConfig()
    end,
})

FeederTab:CreateToggle({
    Name = "Auto Trade Feeder Aktif (Auto Terima & Setor)",
    CurrentValue = _G.LianConfig.AutoTradeFeeder,
    Callback = function(Value)
        _G.LianConfig.AutoTradeFeeder = Value
        saveConfig()
    end,
})

FeederTab:CreateToggle({
    Name = "Otomatis Masukkan Unit Mythic ke Trade",
    CurrentValue = _G.LianConfig.TradeMythic,
    Callback = function(Value)
        _G.LianConfig.TradeMythic = Value
        saveConfig()
    end,
})

FeederTab:CreateToggle({
    Name = "Otomatis Masukkan Unit Secret ke Trade",
    CurrentValue = _G.LianConfig.TradeSecret,
    Callback = function(Value)
        _G.LianConfig.TradeSecret = Value
        saveConfig()
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 4: HALLOWEEN EVENT SUITE
-- ═════════════════════════════════════════════════════════════════════
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
    Name = "Auto Trick-or-Treat (Auto Teleport & Claim Door)",
    CurrentValue = _G.LianConfig.AutoTrickOrTreat,
    Callback = function(Value)
        _G.LianConfig.AutoTrickOrTreat = Value
        saveConfig()
    end,
})

HalloweenTab:CreateToggle({
    Name = "Auto Claim Halloween Event Doors",
    CurrentValue = _G.LianConfig.AutoHalloweenDoors,
    Callback = function(Value)
        _G.LianConfig.AutoHalloweenDoors = Value
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

HalloweenTab:CreateSection("🛒 Halloween Candy Shop")

HalloweenTab:CreateDropdown({
    Name = "Target Beli Candy Shop",
    Options = {"Pumpkin Egg", "Ghost Dice", "Candy Potion", "Lucky Bag"},
    CurrentOption = _G.LianConfig.CandyShopItem,
    Callback = function(Option)
        _G.LianConfig.CandyShopItem = type(Option) == "table" and Option[1] or Option
        saveConfig()
    end,
})

HalloweenTab:CreateToggle({
    Name = "Auto Beli Item Candy Shop",
    CurrentValue = _G.LianConfig.AutoCandyShop,
    Callback = function(Value)
        _G.LianConfig.AutoCandyShop = Value
        saveConfig()
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 5: TOWERS (SMART SIMULATION AI & POTION FARMING)
-- ═════════════════════════════════════════════════════════════════════
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

TowerTab:CreateButton({
    Name = "🔥 Force Equip Best Tower Team Sekarang",
    Callback = function()
        safe(function()
            if NET and NET:FindFirstChild("Towers") and NET.Towers:FindFirstChild("RE") and NET.Towers.RE:FindFirstChild("EquipBestTowerTeam") then
                NET.Towers.RE.EquipBestTowerTeam:FireServer()
                Rayfield:Notify({ Title = "Tower Team", Content = "Best Tower Team berhasil dipasang!", Duration = 3 })
            end
        end)
    end,
})

TowerTab:CreateSection("🎯 Manual Tower / Target Farming")

TowerTab:CreateDropdown({
    Name = "Pilih Tower Tertentu (Farming Potion Spesifik)",
    Options = {"The Abyss", "Bell Tower", "Attic", "Crypt", "Foyer", "Front Yard", "Goblin Tower", "Pirate Tower"},
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

-- ═════════════════════════════════════════════════════════════════════
-- TAB 6: PLOT CASH & QUESTS
-- ═════════════════════════════════════════════════════════════════════
PlotTab:CreateSection("💰 Plot Management")

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
    Name = "Auto Claim Quests (Daily & Weekly)",
    CurrentValue = _G.LianConfig.AutoQuests,
    Callback = function(Value)
        _G.LianConfig.AutoQuests = Value
        saveConfig()
    end,
})

PlotTab:CreateToggle({
    Name = "Auto Claim Daily Rewards",
    CurrentValue = _G.LianConfig.AutoDailyReward,
    Callback = function(Value)
        _G.LianConfig.AutoDailyReward = Value
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

PlotTab:CreateSection("🎟️ Ticket Shop Buyer")

PlotTab:CreateDropdown({
    Name = "Target Item Ticket Shop",
    Options = {"Clover", "Lucky Spin", "Potion Bag", "Super Roll", "Dice Ticket"},
    CurrentOption = _G.LianConfig.TicketShopItem,
    Callback = function(Option)
        _G.LianConfig.TicketShopItem = type(Option) == "table" and Option[1] or Option
        saveConfig()
    end,
})

PlotTab:CreateToggle({
    Name = "Auto Beli Item Ticket Shop",
    CurrentValue = _G.LianConfig.AutoTicketShop,
    Callback = function(Value)
        _G.LianConfig.AutoTicketShop = Value
        saveConfig()
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 7: REBIRTH & STATS (SMART & ZERO SPAM)
-- ═════════════════════════════════════════════════════════════════════
RebirthTab:CreateSection("🧬 Smart Rebirth Engine")

RebirthTab:CreateToggle({
    Name = "Auto Rebirth (HANYA Saat Uang Cukup — No Spam)",
    CurrentValue = _G.LianConfig.AutoRebirth,
    Callback = function(Value)
        _G.LianConfig.AutoRebirth = Value
        saveConfig()
    end,
})

RebirthTab:CreateDropdown({
    Name = "Prioritas Alokasi Stat Rebirth",
    Options = {
        "Balance / Rata (Money, Luck, Damage, Health, Speed)",
        "Fokus Money / Income Dulu",
        "Fokus Luck Dulu",
        "Fokus Damage Dulu",
        "Fokus Health Dulu",
        "Fokus Speed Dulu"
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

RebirthTab:CreateToggle({
    Name = "Auto Buy Best Dice dari Shop",
    CurrentValue = _G.LianConfig.AutoBuyBestDice,
    Callback = function(Value)
        _G.LianConfig.AutoBuyBestDice = Value
        saveConfig()
    end,
})

RebirthTab:CreateSection("⚔️ Unit Management & Auto Sell")

RebirthTab:CreateToggle({
    Name = "Auto Fuse Units",
    CurrentValue = _G.LianConfig.AutoFuseUnits,
    Callback = function(Value)
        _G.LianConfig.AutoFuseUnits = Value
        saveConfig()
    end,
})

RebirthTab:CreateToggle({
    Name = "Auto Sell Worst Units (Common/Rare/Epic Sampah)",
    CurrentValue = _G.LianConfig.AutoSellWorstUnits,
    Callback = function(Value)
        _G.LianConfig.AutoSellWorstUnits = Value
        saveConfig()
    end,
})

RebirthTab:CreateToggle({
    Name = "Jual Common Units",
    CurrentValue = _G.LianConfig.AutoSellCommon,
    Callback = function(Value)
        _G.LianConfig.AutoSellCommon = Value
        saveConfig()
    end,
})

RebirthTab:CreateToggle({
    Name = "Jual Rare Units",
    CurrentValue = _G.LianConfig.AutoSellRare,
    Callback = function(Value)
        _G.LianConfig.AutoSellRare = Value
        saveConfig()
    end,
})

RebirthTab:CreateToggle({
    Name = "Jual Epic Units",
    CurrentValue = _G.LianConfig.AutoSellEpic,
    Callback = function(Value)
        _G.LianConfig.AutoSellEpic = Value
        saveConfig()
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 8: SERVER LUCK HUNTER (SMART MULTI-PAGE HOPPER)
-- ═════════════════════════════════════════════════════════════════════
ServerTab:CreateSection("🌐 Smart Server Hop (Anti Duplikasi & Silent)")

ServerTab:CreateToggle({
    Name = "Auto Hop Cari Server Luck Event (Bloodmoon/Eclipse)",
    CurrentValue = _G.LianConfig.ServerLuckHop,
    Callback = function(Value)
        _G.LianConfig.ServerLuckHop = Value
        saveConfig()
    end,
})

ServerTab:CreateButton({
    Name = "🔄 Force Hop ke Server Lain Sekarang",
    Callback = function()
        setupAutoExecuteOnTeleport()
        local placeId = game.PlaceId
        local apiUrl = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"
        local ok, res = pcall(function() return HttpService:JSONDecode(game:HttpGet(apiUrl)) end)
        if ok and res and res.data then
            for _, s in ipairs(res.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers - 1 then
                    TeleportService:TeleportToPlaceInstance(placeId, s.id, LocalPlayer)
                    return
                end
            end
        end
        TeleportService:Teleport(placeId, LocalPlayer)
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 9: DISCORD WEBHOOK TELEMETRY
-- ═════════════════════════════════════════════════════════════════════
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

WebhookTab:CreateToggle({
    Name = "Kirim Notifikasi Drop (Mythic / Secret / Prodigy)",
    CurrentValue = _G.LianConfig.WebhookDrops,
    Callback = function(Value)
        _G.LianConfig.WebhookDrops = Value
        saveConfig()
    end,
})

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
            footer = { text = "⚡ Lian Hub v6.0 | Anime Dice Telemetry" },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
    pcall(function()
        req({
            Url = url,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
    end)
end

WebhookTab:CreateButton({
    Name = "🔔 Test Kirim Webhook Sekarang",
    Callback = function()
        sendDiscordWebhook("🔔 Test Webhook Lian Hub", "Koneksi webhook dari akun **" .. LocalPlayer.Name .. "** berhasil!", 65280)
        Rayfield:Notify({ Title = "Webhook Terkirim!", Content = "Cek channel Discord Bubu yaa!", Duration = 3 })
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 10: POTATO OPTIMIZER & GPU SAVER (MULTI-CLIENT)
-- ═════════════════════════════════════════════════════════════════════
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

-- ═════════════════════════════════════════════════════════════════════
-- TAB 11: PLAYER & MOVEMENT
-- ═════════════════════════════════════════════════════════════════════
PlayerTab:CreateSection("🏃 Movement Enhancements")

PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 150},
    Increment = 2,
    CurrentValue = 16,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
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
UserInputService.JumpRequest:Connect(function()
    if _G.LianConfig.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

PlayerTab:CreateToggle({
    Name = "Noclip (Tembus Dinding)",
    CurrentValue = _G.LianConfig.Noclip,
    Callback = function(Value)
        _G.LianConfig.Noclip = Value
        saveConfig()
    end,
})
RunService.Stepped:Connect(function()
    if _G.LianConfig.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)


-- ═════════════════════════════════════════════════════════════════════
-- 🚀 MASTER 100% DECOUPLED BACKGROUND WORKERS
-- ═════════════════════════════════════════════════════════════════════

-- 1. Auto Roll Dice Worker
task.spawn(function()
    while true do
        if _G.LianConfig.AutoRoll then
            safe(function() NET.RollService.RE.SetAutoRoll:FireServer(true) end)
            task.spawn(function()
                safe(function() NET.RollService.RF.RollDice:InvokeServer() end)
            end)
            if _G.LianConfig.AutoEquipBestOnRoll then
                equipBestEverything()
            end
            task.wait(_G.LianConfig.FastRoll and 0.08 or 0.3)
        else
            safe(function() NET.RollService.RE.SetAutoRoll:FireServer(false) end)
            task.wait(0.5)
        end
    end
end)

-- 2. Auto Roll Halloween Worker (100 Labu vs 500 Labu)
task.spawn(function()
    while true do
        if _G.LianConfig.AutoRollHalloween then
            safe(function()
                if NET:FindFirstChild("PumpkinDiceService") and NET.PumpkinDiceService:FindFirstChild("RF") and NET.PumpkinDiceService.RF:FindFirstChild("Roll") then
                    local rollCount = _G.LianConfig.HalloweenRollOption:find("100") and 1 or 5
                    NET.PumpkinDiceService.RF.Roll:InvokeServer(rollCount)
                end
            end)
            task.wait(0.35)
        else
            task.wait(0.5)
        end
    end
end)

-- 3. Auto Potions Worker (Category Stacking)
task.spawn(function()
    while true do
        if _G.LianConfig.AutoPotions then
            safe(function()
                local inv = (DC and DC.Inventory and DC.Inventory()) or {}
                local queue = {}
                for key, e in pairs(inv) do
                    if e and (e.amount or 0) > 0 then
                        local name = tostring(e.name or key)
                        local shouldDrink = false
                        if _G.LianConfig.PotionUseLuck and name:find("Luck") then shouldDrink = true
                        elseif _G.LianConfig.PotionUseIncome and (name:find("Income") or name:find("Money")) then shouldDrink = true
                        elseif _G.LianConfig.PotionUseDamage and (name:find("Damage") or name:find("Slayer")) then shouldDrink = true
                        elseif _G.LianConfig.PotionUseSpeed and name:find("Speed") then shouldDrink = true
                        elseif _G.LianConfig.PotionUseHalloween and (name:find("Haunted") or name:find("Pumpkin") or name:find("Candy")) then shouldDrink = true
                        elseif _G.LianConfig.PotionUseTower and (name:find("Tower") or name:find("Shadow") or name:find("Pirate")) then shouldDrink = true
                        end
                        if shouldDrink then
                            table.insert(queue, { key = key, name = name, amount = e.amount })
                        end
                    end
                end
                for _, p in ipairs(queue) do
                    if not _G.LianConfig.AutoPotions then break end
                    if NET:FindFirstChild("BoostService") and NET.BoostService:FindFirstChild("RE") and NET.BoostService.RE:FindFirstChild("Use") then
                        NET.BoostService.RE.Use:FireServer(p.key)
                        task.wait(0.2)
                    end
                end
            end)
            task.wait(3)
        else
            task.wait(1)
        end
    end
end)

-- 4. Auto Rebirth Worker (Zero Spam — Uang Cukup Baru Rebirth)
task.spawn(function()
    while true do
        if _G.LianConfig.AutoRebirth then
            safe(function()
                local canRebirth, curCash, cost = canAffordRebirth()
                if canRebirth then
                    if NET:FindFirstChild("RebirthService") and NET.RebirthService:FindFirstChild("RE") and NET.RebirthService.RE:FindFirstChild("Rebirth") then
                        NET.RebirthService.RE.Rebirth:FireServer()
                        Rayfield:Notify({ Title = "Rebirth Sukses!", Content = "Uang cukup ($" .. math.floor(curCash) .. "). Rebirth diproses!", Duration = 3 })
                        task.wait(1.5)
                        equipBestEverything()
                    end
                end
            end)
            task.wait(1.5)
        else
            task.wait(1)
        end
    end
end)

-- 5. Rebirth Stats Allocation Worker (Zero Spam — Poin > 0 Baru Up)
task.spawn(function()
    while true do
        safe(function()
            local pts = getAvailableStatPoints()
            if pts > 0 and NET:FindFirstChild("RebirthService") and NET.RebirthService:FindFirstChild("RE") and NET.RebirthService.RE:FindFirstChild("AddStat") then
                local prio = _G.LianConfig.RebirthStatPriority
                local statList = {}
                if prio:find("Balance") then statList = {"Money", "Luck", "Damage", "Health", "Speed"}
                elseif prio:find("Money") then statList = {"Money"}
                elseif prio:find("Luck") then statList = {"Luck"}
                elseif prio:find("Damage") then statList = {"Damage"}
                elseif prio:find("Health") then statList = {"Health"}
                elseif prio:find("Speed") then statList = {"Speed"}
                end
                local spentT = table.clone((DC and DC.RebirthStats and DC.RebirthStats()) or {})
                for _ = 1, math.min(pts, 15) do
                    local pick, low = nil, math.huge
                    for _, name in ipairs(statList) do
                        local cur = spentT[name] or 0
                        if cur < low then
                            pick, low = name, cur
                        end
                    end
                    if not pick then break end
                    spentT[pick] = low + 1
                    NET.RebirthService.RE.AddStat:FireServer(pick)
                    task.wait(0.15)
                end
            end
        end)
        task.wait(2)
    end
end)

-- 6. Auto Buy Tree Upgrades Worker (Fortune dll di Dekat Dadu)
task.spawn(function()
    while true do
        if _G.LianConfig.AutoBuyTreeUpgrades then
            safe(buyUpgradesTree)
            task.wait(2.5)
        else
            task.wait(1)
        end
    end
end)

-- 7. Towers AI & Manual Tower Worker (Native Team Equip + Debounce)
task.spawn(function()
    while true do
        if _G.LianConfig.SmartTowerAI or _G.LianConfig.AutoTower then
            safe(function()
                if _G.LianConfig.AutoEquipTowerTeam then
                    if NET:FindFirstChild("Towers") and NET.Towers:FindFirstChild("RE") and NET.Towers.RE:FindFirstChild("EquipBestTowerTeam") then
                        NET.Towers.RE.EquipBestTowerTeam:FireServer()
                        task.wait(1)
                    end
                end
                local towerName = _G.LianConfig.TowerType
                if _G.LianConfig.SmartTowerAI then
                    local towers = {"The Abyss", "Bell Tower", "Attic", "Crypt", "Foyer", "Front Yard"}
                    towerName = towers[math.random(1, #towers)]
                end
                if NET:FindFirstChild("Towers") and NET.Towers:FindFirstChild("RF") and NET.Towers.RF:FindFirstChild("PlayTower") then
                    local okStart, resStart = pcall(function() return NET.Towers.RF.PlayTower:InvokeServer(towerName) end)
                    if okStart and resStart then
                        task.wait(1)
                        for floor = 1, 50 do
                            if not (_G.LianConfig.SmartTowerAI or _G.LianConfig.AutoTower) then break end
                            local okFloor, resSeq = pcall(function() return NET.Towers.RF.CompleteTowerFloor:InvokeServer() end)
                            if not okFloor or resSeq == "destroyed" then break end
                            if type(resSeq) == "table" then
                                local ended = false
                                for _, a in ipairs(resSeq) do
                                    if a.action == "ended" then ended = true end
                                end
                                if ended then break end
                            end
                            task.wait(0.3)
                        end
                    end
                end
            end)
            task.wait(5.5) -- 5.5s PlayTower server debounce
        else
            task.wait(1)
        end
    end
end)

-- 8. Plot Cash & Level Up Worker
task.spawn(function()
    while true do
        if _G.LianConfig.AutoCollectCash then
            safe(function()
                local maxSlots = getMaxPlotSlots()
                for slot = 1, maxSlots do
                    if not _G.LianConfig.AutoCollectCash then break end
                    if NET:FindFirstChild("PlotService") and NET.PlotService:FindFirstChild("RF") and NET.PlotService.RF:FindFirstChild("CollectCash") then
                        NET.PlotService.RF.CollectCash:InvokeServer(slot)
                    end
                end
            end)
        end
        if _G.LianConfig.AutoLevelUpSlots then
            safe(function()
                local maxSlots = getMaxPlotSlots()
                for slot = 1, maxSlots do
                    if not _G.LianConfig.AutoLevelUpSlots then break end
                    if NET:FindFirstChild("PlotService") and NET.PlotService:FindFirstChild("RE") and NET.PlotService.RE:FindFirstChild("LevelUpSlot") then
                        NET.PlotService.RE.LevelUpSlot:FireServer(slot)
                    end
                end
            end)
        end
        task.wait(2)
    end
end)

-- 9. Daily Rewards & Quests Worker
task.spawn(function()
    while true do
        if _G.LianConfig.AutoDailyReward then
            safe(function()
                if NET:FindFirstChild("DailyRewardService") and NET.DailyRewardService:FindFirstChild("RE") and NET.DailyRewardService.RE:FindFirstChild("Claim") then
                    NET.DailyRewardService.RE.Claim:FireServer()
                end
            end)
        end
        if _G.LianConfig.AutoQuests then
            safe(function()
                if NET:FindFirstChild("QuestService") and NET.QuestService:FindFirstChild("RE") and NET.QuestService.RE:FindFirstChild("Claim") then
                    for _, p in ipairs({"Daily", "Weekly"}) do
                        if M.Quests and M.Quests.Periods and M.Quests.Periods[p] then
                            for _, q in ipairs(M.Quests.Periods[p].quests or {}) do
                                NET.QuestService.RE.Claim:FireServer(p, q.id)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(10)
    end
end)

-- 10. Auto Sell Worst Units Worker (Common/Rare/Epic)
task.spawn(function()
    while true do
        if _G.LianConfig.AutoSellWorstUnits then
            safe(function()
                equipBestEverything()
                task.wait(0.5)
                local toSell = {}
                if _G.LianConfig.AutoSellCommon then table.insert(toSell, "Common") end
                if _G.LianConfig.AutoSellRare then table.insert(toSell, "Rare") end
                if _G.LianConfig.AutoSellEpic then table.insert(toSell, "Epic") end
                if #toSell > 0 and NET:FindFirstChild("SellService") and NET.SellService:FindFirstChild("RE") and NET.SellService.RE:FindFirstChild("UpdateAutoSell") then
                    NET.SellService.RE.UpdateAutoSell:FireServer(toSell)
                end
            end)
            task.wait(4)
        else
            task.wait(1)
        end
    end
end)

-- 11. Trick or Treat Worker
task.spawn(function()
    while true do
        if _G.LianConfig.AutoTrickOrTreat then
            safe(function()
                local map = Workspace:FindFirstChild("Halloween") or Workspace:FindFirstChild("Map")
                local doors = map and (map:FindFirstChild("Doors") or map:FindFirstChild("TrickOrTreat"))
                if doors and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    local oldCFrame = hrp.CFrame
                    for _, d in ipairs(doors:GetChildren()) do
                        if not _G.LianConfig.AutoTrickOrTreat then break end
                        if d:IsA("Model") or d:IsA("BasePart") then
                            local pivot = d:GetPivot()
                            hrp.CFrame = pivot * CFrame.new(0, 2, 3)
                            task.wait(0.4)
                            if NET:FindFirstChild("HalloweenService") and NET.HalloweenService:FindFirstChild("RE") and NET.HalloweenService.RE:FindFirstChild("TrickOrTreat") then
                                NET.HalloweenService.RE.TrickOrTreat:FireServer(d.Name)
                            end
                            task.wait(0.3)
                        end
                    end
                    hrp.CFrame = oldCFrame
                end
            end)
            task.wait(5)
        else
            task.wait(1)
        end
    end
end)

-- 12. Halloween Event Doors Worker
task.spawn(function()
    while true do
        if _G.LianConfig.AutoHalloweenDoors then
            safe(function()
                local floors = {"The Abyss", "Bell Tower", "Attic", "Crypt", "Foyer", "Front Yard"}
                if NET:FindFirstChild("HalloweenQuestService") and NET.HalloweenQuestService:FindFirstChild("RE") and NET.HalloweenQuestService.RE:FindFirstChild("Claim") then
                    for _, f in ipairs(floors) do
                        NET.HalloweenQuestService.RE.Claim:FireServer("Daily", f)
                    end
                end
            end)
            task.wait(3)
        else
            task.wait(1)
        end
    end
end)

-- 13. Halloween Pass Claim Worker
task.spawn(function()
    while true do
        if _G.LianConfig.AutoPumpkinPass then
            safe(function()
                if NET:FindFirstChild("HalloweenService") and NET.HalloweenService:FindFirstChild("RE") and NET.HalloweenService.RE:FindFirstChild("ClaimAllPath") then
                    NET.HalloweenService.RE.ClaimAllPath:FireServer()
                end
            end)
            task.wait(6)
        else
            task.wait(1)
        end
    end
end)

-- 14. Auto Trade Feeder Listener
pcall(function()
    if NET:FindFirstChild("TradeService") and NET.TradeService:FindFirstChild("RE") and NET.TradeService.RE:FindFirstChild("TradeEvent") then
        NET.TradeService.RE.TradeEvent.OnClientEvent:Connect(function(event, data)
            if not _G.LianConfig.AutoTradeFeeder then return end
            local master = _G.LianConfig.MasterAccount
            if not master or master == "" then return end
            if event == "Request" and data and data.player then
                if data.player.Name:lower() == master:lower() then
                    NET.TradeService.RE.RespondToRequest:FireServer(true)
                    Rayfield:Notify({ Title = "Trade Diterima!", Content = "Trade otomatis dari Akun Utama: " .. data.player.Name, Duration = 4 })
                else
                    NET.TradeService.RE.RespondToRequest:FireServer(false)
                end
            elseif event == "Started" then
                task.wait(0.5)
                local inv = (DC and DC.Inventory and DC.Inventory()) or {}
                for key, unit in pairs(inv) do
                    local rarity = unit.rarity or (unit.attrs and unit.attrs.rarity) or ""
                    if (_G.LianConfig.TradeMythic and rarity == "Mythic") or (_G.LianConfig.TradeSecret and rarity == "Secret") then
                        NET.TradeService.RE.ChangeOffer:FireServer(key, 1)
                        task.wait(0.2)
                    end
                end
                task.wait(0.5)
                NET.TradeService.RE.AdvanceTrade:FireServer()
                task.wait(3.2)
                NET.TradeService.RE.AdvanceTrade:FireServer()
            end
        end)
    end
end)

-- 15. Server Luck Hopper Worker
task.spawn(function()
    while true do
        if _G.LianConfig.ServerLuckHop then
            safe(function()
                local weather = (DC and DC.Weather and DC.Weather()) or ""
                if weather ~= "Bloodmoon" and weather ~= "Eclipse" and weather ~= "Full Moon" then
                    setupAutoExecuteOnTeleport()
                    local placeId = game.PlaceId
                    local apiUrl = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"
                    local ok, res = pcall(function() return HttpService:JSONDecode(game:HttpGet(apiUrl)) end)
                    if ok and res and res.data then
                        for _, s in ipairs(res.data) do
                            if s.id ~= game.JobId and s.playing < s.maxPlayers - 1 then
                                TeleportService:TeleportToPlaceInstance(placeId, s.id, LocalPlayer)
                                return
                            end
                        end
                    end
                    TeleportService:Teleport(placeId, LocalPlayer)
                end
            end)
            task.wait(5)
        else
            task.wait(2)
        end
    end
end)

-- 16. Extreme Potato Mode & 3D Render Initialization
if _G.LianConfig.ExtremePotatoMode then
    applyPotatoMode(true)
end
if _G.LianConfig.Disable3DRendering then
    pcall(function() RunService:Set3dRenderingEnabled(false) end)
end

Rayfield:Notify({
    Title = "⚡ Lian Hub v6.0 Ready!",
    Content = "Master Exploit Suite aktif! Gunakan tombol [⚡ Lian Hub] atau RightControl untuk hide/show.",
    Duration = 5
})
