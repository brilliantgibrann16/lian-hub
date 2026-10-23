--[[
    ═════════════════════════════════════════════════════════════════════════
    ⚡ LIAN HUB — 100% KEYLESS ANIME DICE NUYUL & AUTO FARM SUITE ⚡
    Author : Lian (@brilliantgibrann16)
    Repo   : https://github.com/brilliantgibrann16/lian-hub
    Status : VERIFIED WITH LIAN SPY DUMP • 100% WORKING REMOTES & UI CLICKER
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

-- 2. Network & Framework References (Verified via Lian Spy)
local NET = RS:WaitForChild("Network", 10)
local okDC, DC = pcall(function()
    return require(RS.Framework.Features.Data.DataController)
end)

-- Helper Functions
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
_G.LianNuyul = {
    AutoRoll = false,
    FastRoll = false,
    AutoCollectCash = false,
    AutoDailyReward = false,
    AutoQuests = false,
    AutoPumpkinPass = false,
    AutoSpin = false,
    AutoEquipBest = false,
    AutoQuirk = false,
    QuirkTarget = "Prodigy",
    AutoTutorial = false,
    TargetRolls = 1000,
    LeaveOnTarget = false,
    PotatoMode = false,
    InfJump = false,
    Noclip = false
}

-- 3. Load UI (Rayfield — Pure Keyless)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "⚡ Lian Hub | Anime Dice Nuyul Suite",
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
local RewardsTab = Window:CreateTab("Daily & Rewards", 4483362458)
local QuestTab = Window:CreateTab("Quests & Plot", 4483362458)
local QuirkTab = Window:CreateTab("Quirk Reroll", 4483362458)
local PerfTab = Window:CreateTab("Potato & Perf", 4483362458)
local PlayerTab = Window:CreateTab("Player & Move", 4483362458)

-- ═════════════════════════════════════════════════════════════════════
-- TAB 1: AUTO FARM (ROLL & ONBOARDING)
-- ═════════════════════════════════════════════════════════════════════
FarmTab:CreateSection("🎲 Dice Rolling Engine")

FarmTab:CreateToggle({
    Name = "Auto Roll Dice",
    CurrentValue = false,
    Flag = "ToggleAutoRoll",
    Callback = function(Value)
        _G.LianNuyul.AutoRoll = Value
        if Value then
            task.spawn(function()
                while _G.LianNuyul.AutoRoll do
                    safe(function()
                        if NET and NET:FindFirstChild("RollService") then
                            local RF_Roll = NET.RollService:FindFirstChild("RF") and NET.RollService.RF:FindFirstChild("RollDice")
                            if RF_Roll then
                                RF_Roll:InvokeServer()
                            else
                                local RE_Auto = NET.RollService:FindFirstChild("RE") and NET.RollService.RE:FindFirstChild("SetAutoRoll")
                                if RE_Auto then RE_Auto:FireServer(true) end
                            end
                        end
                    end)
                    task.wait(_G.LianNuyul.FastRoll and 0.05 or 0.25)
                end
            end)
        else
            safe(function()
                if NET and NET:FindFirstChild("RollService") then
                    local RE_Auto = NET.RollService:FindFirstChild("RE") and NET.RollService.RE:FindFirstChild("SetAutoRoll")
                    if RE_Auto then RE_Auto:FireServer(false) end
                end
            end)
        end
    end,
})

FarmTab:CreateToggle({
    Name = "Fast Roll Mode (No Animation)",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianNuyul.FastRoll = Value
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Skip / Complete Tutorial (Akun Baru)",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianNuyul.AutoTutorial = Value
        if Value then
            task.spawn(function()
                while _G.LianNuyul.AutoTutorial do
                    safe(function()
                        local step = DC and DC.OnboardingStep and DC.OnboardingStep() or -1
                        if step < 14 and step >= 0 then
                            local RE_Advance = NET:FindFirstChild("OnboardingService") and NET.OnboardingService.RE:FindFirstChild("Advance")
                            if RE_Advance then RE_Advance:FireServer() end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end,
})

FarmTab:CreateSection("🎯 Target Rolls & Disconnect (Nuyul)")

FarmTab:CreateInput({
    Name = "Target Rolls (Syarat Trade)",
    PlaceholderText = "Default: 1000",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then _G.LianNuyul.TargetRolls = num end
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Disconnect Saat Target Rolls Tercapai",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianNuyul.LeaveOnTarget = Value
        if Value then
            task.spawn(function()
                while _G.LianNuyul.LeaveOnTarget do
                    local curRolls = (DC and DC.Rolls and DC.Rolls()) or 0
                    if curRolls >= _G.LianNuyul.TargetRolls then
                        Rayfield:Notify({ Title = "Target Tercapai!", Content = "Rolls sudah " .. curRolls .. ". Keluar game...", Duration = 4 })
                        task.wait(1.5)
                        LocalPlayer:Kick("Lian Hub: Target " .. _G.LianNuyul.TargetRolls .. " Rolls Tercapai!")
                        break
                    end
                    task.wait(5)
                end
            end)
        end
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 2: DAILY REWARDS & FREE CLAIMS (VERIFIED)
-- ═════════════════════════════════════════════════════════════════════
RewardsTab:CreateSection("🎁 Daily & Free Claims")

RewardsTab:CreateToggle({
    Name = "Auto Claim Daily / Group / Offline Rewards",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianNuyul.AutoDailyReward = Value
        if Value then
            task.spawn(function()
                while _G.LianNuyul.AutoDailyReward do
                    -- 1. Remote Firing: Daily Reward (Hari 1-7)
                    safe(function()
                        if NET and NET:FindFirstChild("DailyRewardService") and NET.DailyRewardService.RE:FindFirstChild("Claim") then
                            for day = 1, 7 do
                                NET.DailyRewardService.RE.Claim:FireServer(day)
                            end
                            NET.DailyRewardService.RE.Claim:FireServer()
                        end
                    end)

                    -- 2. Remote Firing: Group Reward & Offline Earnings
                    safe(function()
                        if NET:FindFirstChild("GroupRewardService") and NET.GroupRewardService.RE:FindFirstChild("Claim") then
                            NET.GroupRewardService.RE.Claim:FireServer()
                        end
                        if NET:FindFirstChild("OfflineEarningsService") and NET.OfflineEarningsService.RE:FindFirstChild("Claim") then
                            NET.OfflineEarningsService.RE.Claim:FireServer()
                        end
                    end)

                    -- 3. UI Clicker Fallback (Klik tombol di PlayerGui langsung)
                    safe(function()
                        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                        if pGui and pGui:FindFirstChild("Root") and pGui.Root:FindFirstChild("Menus") then
                            local menus = pGui.Root.Menus
                            -- Group Reward Button
                            if menus:FindFirstChild("GroupRewards") and menus.GroupRewards:FindFirstChild("Claim") then
                                clickBtn(menus.GroupRewards.Claim)
                            end
                            -- Offline Reward Button
                            if menus:FindFirstChild("OfflineRewards") and menus.OfflineRewards:FindFirstChild("Buttons") and menus.OfflineRewards.Buttons:FindFirstChild("Claim") then
                                clickBtn(menus.OfflineRewards.Buttons.Claim)
                            end
                        end
                    end)

                    task.wait(15)
                end
            end)
        end
    end,
})

RewardsTab:CreateToggle({
    Name = "Auto Claim Battle / Pumpkin Pass (Free + Claim All)",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianNuyul.AutoPumpkinPass = Value
        if Value then
            task.spawn(function()
                while _G.LianNuyul.AutoPumpkinPass do
                    -- Remote Firing
                    safe(function()
                        if NET and NET:FindFirstChild("HalloweenService") and NET.HalloweenService.RE:FindFirstChild("ClaimAllPath") then
                            NET.HalloweenService.RE.ClaimAllPath:FireServer()
                        end
                    end)
                    -- UI Clicker
                    safe(function()
                        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                        if pGui and pGui:FindFirstChild("Root") and pGui.Root:FindFirstChild("Menus") then
                            local pass = pGui.Root.Menus:FindFirstChild("PumpkinPass")
                            if pass and pass:FindFirstChild("Body") and pass.Body:FindFirstChild("Header") and pass.Body.Header:FindFirstChild("ClaimAll") then
                                clickBtn(pass.Body.Header.ClaimAll)
                            end
                        end
                    end)
                    task.wait(20)
                end
            end)
        end
    end,
})

RewardsTab:CreateToggle({
    Name = "Auto Use Free Spin Wheel",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianNuyul.AutoSpin = Value
        if Value then
            task.spawn(function()
                while _G.LianNuyul.AutoSpin do
                    safe(function()
                        if NET and NET:FindFirstChild("SpinService") and NET.SpinService.RE:FindFirstChild("Use") then
                            NET.SpinService.RE.Use:FireServer()
                        end
                    end)
                    task.wait(30)
                end
            end)
        end
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 3: QUESTS & PLOT CASH (100% FIXED)
-- ═════════════════════════════════════════════════════════════════════
QuestTab:CreateSection("💰 Plot Cash Collection")

QuestTab:CreateToggle({
    Name = "Auto Collect Cash (Semua Plot Slot 1-20)",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianNuyul.AutoCollectCash = Value
        if Value then
            task.spawn(function()
                while _G.LianNuyul.AutoCollectCash do
                    safe(function()
                        if NET and NET:FindFirstChild("PlotService") and NET.PlotService.RE:FindFirstChild("CollectBalance") then
                            -- Loop semua slot plot 1 sampai 20
                            for slot = 1, 20 do
                                NET.PlotService.RE.CollectBalance:FireServer(slot)
                            end
                            NET.PlotService.RE.CollectBalance:FireServer()
                        end
                    end)
                    task.wait(1.5)
                end
            end)
        end
    end,
})

QuestTab:CreateButton({
    Name = "Equip Best Unit (Plot + Towers)",
    Callback = function()
        safe(function()
            if NET and NET:FindFirstChild("PlotService") and NET.PlotService.RE:FindFirstChild("EquipBest") then
                NET.PlotService.RE.EquipBest:FireServer()
            end
            if NET and NET:FindFirstChild("UnitService") and NET.UnitService.RF:FindFirstChild("Equip") then
                NET.UnitService.RF.Equip:InvokeServer("Best")
            end
            if NET and NET:FindFirstChild("Towers") and NET.Towers.RE:FindFirstChild("EquipBestTowerTeam") then
                NET.Towers.RE.EquipBestTowerTeam:FireServer()
            end
        end)
        Rayfield:Notify({ Title = "Lian Hub", Content = "Best Units & Team Equipped!", Duration = 3 })
    end,
})

QuestTab:CreateSection("📜 Auto Quests (Dual-Engine: Remote + UI)")

QuestTab:CreateToggle({
    Name = "Auto Claim Quests (Daily, Weekly & Event)",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianNuyul.AutoQuests = Value
        if Value then
            task.spawn(function()
                while _G.LianNuyul.AutoQuests do
                    -- Engine 1: ClientComm / Remotes
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

                    -- Engine 2: Direct UI Claim Clicker (Klik semua tombol Claim di Quests Menu)
                    safe(function()
                        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                        if pGui and pGui:FindFirstChild("Root") and pGui.Root:FindFirstChild("Menus") then
                            local qMenu = pGui.Root.Menus:FindFirstChild("Quests")
                            if qMenu then
                                for _, desc in ipairs(qMenu:GetDescendants()) do
                                    if desc:IsA("GuiButton") and desc.Name == "Claim" then
                                        clickBtn(desc)
                                    end
                                end
                            end

                            local hMenu = pGui.Root.Menus:FindFirstChild("HalloweenQuests")
                            if hMenu then
                                for _, desc in ipairs(hMenu:GetDescendants()) do
                                    if desc:IsA("GuiButton") and desc.Name == "Claim" then
                                        clickBtn(desc)
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

-- ═════════════════════════════════════════════════════════════════════
-- TAB 4: QUIRK / TRAIT REROLL
-- ═════════════════════════════════════════════════════════════════════
QuirkTab:CreateSection("✨ Auto Quirk Rolling")

QuirkTab:CreateDropdown({
    Name = "Pilih Target Trait",
    Options = {"Prodigy (High Luck)", "Fortune's Favor (Super Luck)"},
    CurrentOption = {"Prodigy (High Luck)"},
    Callback = function(Option)
        if Option[1]:find("Fortune") then
            _G.LianNuyul.QuirkTarget = "Fortune's Favor"
        else
            _G.LianNuyul.QuirkTarget = "Prodigy"
        end
    end,
})

QuirkTab:CreateToggle({
    Name = "Auto Reroll Quirk (Roll Trait)",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianNuyul.AutoQuirk = Value
        if Value then
            task.spawn(function()
                while _G.LianNuyul.AutoQuirk do
                    safe(function()
                        if NET and NET:FindFirstChild("QuirkService") and NET.QuirkService.RE:FindFirstChild("Roll") then
                            local okInv, inv = pcall(function() return DC.Inventory.Units() end)
                            if okInv and inv then
                                for key, unit in pairs(inv) do
                                    if unit.Quirk ~= _G.LianNuyul.QuirkTarget then
                                        NET.QuirkService.RE.Roll:FireServer(key)
                                        break
                                    end
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
-- TAB 5: POTATO OPTIMIZER (KHUSUS NUYUL MULTI-CLIENT)
-- ═════════════════════════════════════════════════════════════════════
PerfTab:CreateSection("❄️ CPU / GPU Saver")

PerfTab:CreateButton({
    Name = "Extreme Potato Mode (30 FPS + Strip FX)",
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
        Rayfield:Notify({ Title = "Potato Mode Aktif!", Content = "Grafik minimalis, siap nuyul banyak akun!", Duration = 4 })
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 6: MOVEMENT & SERVER
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
    Callback = function(Value) _G.LianNuyul.InfJump = Value end,
})

UserInputService.JumpRequest:Connect(function()
    if _G.LianNuyul.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(Value) _G.LianNuyul.Noclip = Value end,
})

RunService.Stepped:Connect(function()
    if _G.LianNuyul.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

PlayerTab:CreateSection("🌐 Server Controls")

PlayerTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end,
})

PlayerTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
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
    end,
})

Rayfield:Notify({
    Title = "Lian Hub v3 Loaded!",
    Content = "Semua fitur Cash, Daily & Quests sudah aktif!",
    Duration = 5
})
