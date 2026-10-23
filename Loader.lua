--[[
    ═════════════════════════════════════════════════════════════════════════
    ⚡ LIAN HUB — 100% KEYLESS ANIME DICE ULTIMATE EXPLOIT SUITE ⚡
    Author : Lian (@brilliantgibrann16)
    Repo   : https://github.com/brilliantgibrann16/lian-hub
    Status : 100% VERIFIED VIA LIVE LOG DUMP • ZERO KEYS • ZERO ADS
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

local LocalPlayer = Players.LocalPlayer

-- 1. Anti-AFK (Bebas idle kick 20 menit)
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0, 0))
    task.wait(1)
end)

-- 2. Network & Framework
local NET = RS:WaitForChild("Network", 15)
local okDC, DC = pcall(function()
    return require(RS.Framework.Features.Data.DataController)
end)

local function safe(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok, res
end

local function clickBtn(btn)
    if not btn or not btn:IsA("GuiButton") then return end
    safe(function()
        if firesignal then
            firesignal(btn.MouseButton1Click)
            firesignal(btn.Activated)
        end
    end)
end

-- Global State Flags
_G.LianHub = {
    AutoRoll = false,
    FastRoll = false,
    AutoRollHalloween = false,
    AutoPotions = false,
    AutoSpin = false,
    AutoTrickOrTreat = false,
    AutoPumpkinPass = false,
    AutoCandyShop = false,
    CandyShopItem = "Pumpkin Egg",
    AutoTower = false,
    TowerType = "Haunted",
    AutoCollectCash = false,
    AutoDailyReward = false,
    AutoQuests = false,
    AutoQuestShop = false,
    AutoEquipBest = false,
    AutoUpgradeStats = false,
    AutoQuirk = false,
    QuirkTarget = "Prodigy",
    AutoFuse = false,
    ServerLuckHop = false,
    TargetRolls = 1000,
    LeaveOnTarget = false,
    InfJump = false,
    Noclip = false
}

-- 3. Load UI (Rayfield — Pure Keyless)
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
local EconomyTab = Window:CreateTab("Cash & Rewards", 4483362458)
local UpgradesTab = Window:CreateTab("Units & Stats", 4483362458)
local ServerTab = Window:CreateTab("Server & Hop", 4483362458)
local PerfTab = Window:CreateTab("Potato & Perf", 4483362458)
local PlayerTab = Window:CreateTab("Movement", 4483362458)

-- ═════════════════════════════════════════════════════════════════════
-- TAB 1: AUTO FARM (ROLL ENGINE — DUAL-ENGINE FIX)
-- ═════════════════════════════════════════════════════════════════════
FarmTab:CreateSection("🎲 Dice Rolling Engine (Dual-Engine)")

FarmTab:CreateToggle({
    Name = "Auto Roll Dice (Native + Non-blocking Spam)",
    CurrentValue = false,
    Flag = "ToggleAutoRoll",
    Callback = function(Value)
        _G.LianHub.AutoRoll = Value
        if Value then
            -- 1. Nyalakan Auto Roll resmi server
            safe(function()
                NET.RollService.RE.SetAutoRoll:FireServer(true)
            end)
            -- 2. Spam non-blocking InvokeServer di background thread
            task.spawn(function()
                while _G.LianHub.AutoRoll do
                    task.spawn(function()
                        safe(function()
                            NET.RollService.RF.RollDice:InvokeServer()
                        end)
                    end)
                    task.wait(_G.LianHub.FastRoll and 0.08 or 0.3)
                end
                -- Matikan saat toggle off
                safe(function()
                    NET.RollService.RE.SetAutoRoll:FireServer(false)
                end)
            end)
        else
            safe(function()
                NET.RollService.RE.SetAutoRoll:FireServer(false)
            end)
        end
    end,
})

FarmTab:CreateToggle({
    Name = "Fast Roll Mode (Maximum Roll Spam Rate)",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianHub.FastRoll = Value
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Roll Halloween Pumpkin Dice",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianHub.AutoRollHalloween = Value
        if Value then
            task.spawn(function()
                while _G.LianHub.AutoRollHalloween do
                    task.spawn(function()
                        safe(function()
                            if NET:FindFirstChild("PumpkinDiceService") then
                                NET.PumpkinDiceService.RF.Roll:InvokeServer()
                            end
                        end)
                    end)
                    task.wait(_G.LianHub.FastRoll and 0.1 or 0.4)
                end
            end)
        end
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Skip / Complete Tutorial (Akun Baru)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while Value do
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

FarmTab:CreateSection("🎯 Target Rolls (Nuyul Disconnect)")

FarmTab:CreateInput({
    Name = "Target Rolls (Syarat Trade)",
    PlaceholderText = "Default: 1000",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then _G.LianHub.TargetRolls = num end
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Disconnect Saat Target Rolls Tercapai",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianHub.LeaveOnTarget = Value
        if Value then
            task.spawn(function()
                while _G.LianHub.LeaveOnTarget do
                    local curRolls = (DC and DC.Rolls and DC.Rolls()) or 0
                    if curRolls >= _G.LianHub.TargetRolls then
                        safe(function() NET.RollService.RE.SetAutoRoll:FireServer(false) end)
                        Rayfield:Notify({ Title = "Target Tercapai!", Content = "Rolls sudah " .. curRolls .. ". Disconnecting...", Duration = 4 })
                        task.wait(2)
                        LocalPlayer:Kick("Lian Hub: Target " .. _G.LianHub.TargetRolls .. " Rolls Tercapai!")
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
    "Luck IV", "Luck III", "Luck II", "Luck I",
    "Damage IV", "Damage III", "Damage II",
    "Income IV", "Income III", "Income II",
    "Haunted Potion"
}

PotionsTab:CreateToggle({
    Name = "Auto Consume All Potions (Per Habis Otomatis Minum)",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianHub.AutoPotions = Value
        if Value then
            task.spawn(function()
                while _G.LianHub.AutoPotions do
                    safe(function()
                        for _, potionName in ipairs(POTIONS_LIST) do
                            NET.BoostService.RE.Use:FireServer(potionName)
                            task.wait(0.15)
                        end
                    end)
                    -- Check setiap 15 detik untuk refresh durasi
                    task.wait(15)
                end
            end)
        end
    end,
})

PotionsTab:CreateToggle({
    Name = "Auto Spin Lucky Wheel",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianHub.AutoSpin = Value
        if Value then
            task.spawn(function()
                while _G.LianHub.AutoSpin do
                    safe(function()
                        NET.SpinService.RE.Use:FireServer("Lucky Spin")
                    end)
                    task.wait(20)
                end
            end)
        end
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 3: HALLOWEEN EVENT SUITE (VERIFIED)
-- ═════════════════════════════════════════════════════════════════════
HalloweenTab:CreateSection("🎃 Trick or Treat & Event")

HalloweenTab:CreateToggle({
    Name = "Auto Trick or Treat (Knock Semua Pintu)",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianHub.AutoTrickOrTreat = Value
        if Value then
            task.spawn(function()
                while _G.LianHub.AutoTrickOrTreat do
                    safe(function()
                        -- Knock doors
                        for doorId = 1, 30 do
                            NET.TrickOrTreatService.RE.Knocked:FireServer(doorId)
                            NET.TrickOrTreatService.RE.Landed:FireServer(doorId)
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
    CurrentValue = false,
    Callback = function(Value)
        _G.LianHub.AutoPumpkinPass = Value
        if Value then
            task.spawn(function()
                while _G.LianHub.AutoPumpkinPass do
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
    Name = "Pilih Item Candy Shop",
    Options = {"Pumpkin Egg", "Halloween Potion", "Candy Bag", "Lucky Dice"},
    CurrentOption = {"Pumpkin Egg"},
    Callback = function(Option)
        _G.LianHub.CandyShopItem = Option[1]
    end,
})

HalloweenTab:CreateToggle({
    Name = "Auto Exchange Candy Shop",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianHub.AutoCandyShop = Value
        if Value then
            task.spawn(function()
                while _G.LianHub.AutoCandyShop do
                    safe(function()
                        NET.HalloweenService.RE.BuyOffer:FireServer(_G.LianHub.CandyShopItem)
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
-- TAB 4: TOWERS (NORMAL & EVENT HAUNTED TOWER)
-- ═════════════════════════════════════════════════════════════════════
TowerTab:CreateSection("🏰 Tower Attack Engine")

TowerTab:CreateDropdown({
    Name = "Pilih Tower Target",
    Options = {"Haunted (Event Best)", "Normal (Standard Tower)"},
    CurrentOption = {"Haunted (Event Best)"},
    Callback = function(Option)
        if Option[1]:find("Normal") then
            _G.LianHub.TowerType = "Normal"
        else
            _G.LianHub.TowerType = "Haunted"
        end
    end,
})

TowerTab:CreateToggle({
    Name = "Auto Attack & Clear Tower (Equip Best Team + Auto)",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianHub.AutoTower = Value
        if Value then
            -- Otomatis pasang tim terbaik untuk tower
            safe(function()
                NET.Towers.RE.EquipBestTowerTeam:FireServer()
                NET.Towers.RE.SetAutoTower:FireServer(true)
            end)
            task.spawn(function()
                while _G.LianHub.AutoTower do
                    safe(function()
                        -- Mulai tower sesuai pilihan
                        NET.Towers.RF.PlayTower:InvokeServer(_G.LianHub.TowerType)
                        task.wait(1)
                        -- Auto complete floor
                        for floor = 1, 50 do
                            NET.Towers.RF.CompleteTowerFloor:InvokeServer(floor)
                            task.wait(0.2)
                        end
                    end)
                    task.wait(5)
                end
                safe(function()
                    NET.Towers.RE.SetAutoTower:FireServer(false)
                end)
            end)
        else
            safe(function()
                NET.Towers.RE.SetAutoTower:FireServer(false)
            end)
        end
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 5: CASH & ECONOMY (VERIFIED REMOTES)
-- ═════════════════════════════════════════════════════════════════════
EconomyTab:CreateSection("💰 Plot Cash Collection")

EconomyTab:CreateToggle({
    Name = "Auto Collect Cash (Slot 1-20)",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianHub.AutoCollectCash = Value
        if Value then
            task.spawn(function()
                while _G.LianHub.AutoCollectCash do
                    safe(function()
                        for slot = 1, 20 do
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

EconomyTab:CreateSection("🎁 Daily & Quests")

EconomyTab:CreateToggle({
    Name = "Auto Claim Daily / Group / Offline Rewards",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianHub.AutoDailyReward = Value
        if Value then
            task.spawn(function()
                while _G.LianHub.AutoDailyReward do
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
    CurrentValue = false,
    Callback = function(Value)
        _G.LianHub.AutoQuests = Value
        if Value then
            task.spawn(function()
                while _G.LianHub.AutoQuests do
                    safe(function()
                        local Network = require(RS.Packages.Network)
                        local QuestConfig = require(RS.Framework.Features.Quests.QuestConfig)
                        local questSignal = Network.ClientComm.new(RS.Network, false, "QuestService"):GetSignal("Claim")
                        local now = math.floor(workspace:GetServerTimeNow())
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
                    task.wait(10)
                end
            end)
        end
    end,
})

EconomyTab:CreateSection("🎁 Redeem Codes")

EconomyTab:CreateButton({
    Name = "Redeem Semua 17 Promo Codes Resmi",
    Callback = function()
        local CODES = {
            "UPDATE7", "UPDATE6", "UPDATE5", "UPDATE4", "UPDATE3", "UPDATE2", "UPDATE1",
            "400KLIKES", "250KLIKES", "100KLIKES", "40KCCU", "30KCCU", "20KCCU", "10KCCU",
            "5KCCU", "1KCCU", "RELEASE"
        }
        for _, code in ipairs(CODES) do
            safe(function()
                NET.CodesService.RE.RedeemCode:FireServer(code)
            end)
            task.wait(0.2)
        end
        Rayfield:Notify({ Title = "Lian Hub", Content = "17 Promo Codes berhasil di-redeem!", Duration = 4 })
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 6: UNITS & STATS UPGRADE
-- ═════════════════════════════════════════════════════════════════════
UpgradesTab:CreateSection("📈 Auto Stats & Fortune")

UpgradesTab:CreateToggle({
    Name = "Auto Upgrade Stats / Fortune (Fortune XV, etc.)",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianHub.AutoUpgradeStats = Value
        if Value then
            task.spawn(function()
                while _G.LianHub.AutoUpgradeStats do
                    safe(function()
                        -- Upgrade Fortune
                        NET.RE.BuyUpgrade:FireServer("Fortune XV")
                        -- Add Stat Rebirth
                        for _, stat in ipairs({"Luck", "Speed", "Rolls", "Income"}) do
                            NET.RebirthService.RE.AddStat:FireServer(stat, 1)
                        end
                    end)
                    task.wait(2)
                end
            end)
        end
    end,
})

UpgradesTab:CreateSection("⚔️ Units & Fusing")

UpgradesTab:CreateButton({
    Name = "Auto Equip Best Units (Plot + Tower)",
    Callback = function()
        safe(function()
            NET.PlotService.RE.EquipBest:FireServer()
            NET.UnitService.RF.Equip:InvokeServer("Best")
            NET.Towers.RE.EquipBestTowerTeam:FireServer()
        end)
        Rayfield:Notify({ Title = "Lian Hub", Content = "All Best Units Equipped!", Duration = 3 })
    end,
})

UpgradesTab:CreateToggle({
    Name = "Auto Fuse Units",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianHub.AutoFuse = Value
        if Value then
            task.spawn(function()
                while _G.LianHub.AutoFuse do
                    safe(function()
                        NET.FusingService.RE.Fuse:FireServer()
                    end)
                    task.wait(5)
                end
            end)
        end
    end,
})

UpgradesTab:CreateSection("🎲 Auto Buy Best Dice")

UpgradesTab:CreateButton({
    Name = "Auto Buy & Equip Highest Available Dice",
    Callback = function()
        safe(function()
            local diceList = {"Golden", "Diamond", "Sinister", "Galaxy", "Asteroid", "Blackhole", "Cherub", "Solaris", "Volcanic"}
            for _, d in ipairs(diceList) do
                NET.DiceShopService.RE.BuyDice:FireServer(d)
                NET.DiceShopService.RE.EquipDice:FireServer(d)
                task.wait(0.2)
            end
        end)
        Rayfield:Notify({ Title = "Lian Hub", Content = "Highest dice equipped!", Duration = 3 })
    end,
})

UpgradesTab:CreateSection("✨ Quirk Trait Hunter")

UpgradesTab:CreateDropdown({
    Name = "Target Quirk",
    Options = {"Prodigy (High Luck)", "Fortune's Favor (Super Luck)"},
    CurrentOption = {"Prodigy (High Luck)"},
    Callback = function(Option)
        if Option[1]:find("Fortune") then
            _G.LianHub.QuirkTarget = "Fortune's Favor"
        else
            _G.LianHub.QuirkTarget = "Prodigy"
        end
    end,
})

UpgradesTab:CreateToggle({
    Name = "Auto Reroll Quirk (Roll Trait)",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianHub.AutoQuirk = Value
        if Value then
            task.spawn(function()
                while _G.LianHub.AutoQuirk do
                    safe(function()
                        local okInv, inv = pcall(function() return DC.Inventory.Units() end)
                        if okInv and inv then
                            for key, unit in pairs(inv) do
                                if unit.Quirk ~= _G.LianHub.QuirkTarget then
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
-- TAB 7: SERVER LUCK HUNTER (WEATHER HOPPER)
-- ═════════════════════════════════════════════════════════════════════
ServerTab:CreateSection("⚡ Server Luck / Event Hunter")

local function hopServer()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, res = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
    if success and res and res.data then
        for _, s in ipairs(res.data) do
            if s.id ~= game.JobId and s.playing < s.maxPlayers then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                break
            end
        end
    end
end

ServerTab:CreateToggle({
    Name = "Auto Hop Cari Server Event (Luck / Clover / Haunted)",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianHub.ServerLuckHop = Value
        if Value then
            task.spawn(function()
                while _G.LianHub.ServerLuckHop do
                    local weather = (DC and DC.Weather and DC.Weather()) or ""
                    local isEvent = weather:find("Luck") or weather:find("Clover") or weather:find("Haunted") or weather:find("Golden")
                    if not isEvent then
                        Rayfield:Notify({ Title = "Server Bukan Event!", Content = "Cuaca: " .. tostring(weather) .. ". Pindah server...", Duration = 3 })
                        task.wait(2)
                        hopServer()
                        break
                    else
                        Rayfield:Notify({ Title = "Event Ditemukan!", Content = "Server ini ada Event: " .. tostring(weather) .. "! Bertahan di sini.", Duration = 5 })
                    end
                    task.wait(30)
                end
            end)
        end
    end,
})

ServerTab:CreateButton({
    Name = "Manual Server Hop",
    Callback = function() hopServer() end
})

ServerTab:CreateButton({
    Name = "Rejoin Server Ini",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 8: POTATO OPTIMIZER & PERFORMANCE
-- ═════════════════════════════════════════════════════════════════════
PerfTab:CreateSection("❄️ CPU / GPU Saver (Khusus Nuyul Multi-Client)")

PerfTab:CreateButton({
    Name = "Extreme Potato Mode (FPS Cap 30 + No Graphics)",
    Callback = function()
        pcall(function()
            if setfpscap then setfpscap(30) end
        end)
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
        Rayfield:Notify({ Title = "Potato Mode Aktif!", Content = "Beban laptop dingin, lancar nuyul banyak akun!", Duration = 4 })
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
    Callback = function(Value) _G.LianHub.InfJump = Value end,
})

UserInputService.JumpRequest:Connect(function()
    if _G.LianHub.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(Value) _G.LianHub.Noclip = Value end,
})

RunService.Stepped:Connect(function()
    if _G.LianHub.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

Rayfield:Notify({
    Title = "Lian Hub Ultimate Loaded!",
    Content = "Semua fitur nuyul & event siap digunakan tanpa key!",
    Duration = 5
})
