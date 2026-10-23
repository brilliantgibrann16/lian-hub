--[[
    ═════════════════════════════════════════════════════════════════════════
    ⚡ LIAN HUB — 100% KEYLESS ANIME DICE NUYUL & AUTO FARM SUITE ⚡
    Author : Lian (@brilliantgibrann16)
    Repo   : https://github.com/brilliantgibrann16/lian-hub
    Status : 100% KEYLESS • ZERO ADS • FULL NUYUL CLUSTER FEATURES
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

-- 2. Anime Dice Network & Data Controller Detection
local NET = RS:WaitForChild("Network", 10)
local okDC, DC = pcall(function()
    return require(RS.Framework.Features.Data.DataController)
end)

-- Helper Functions
local function safeCall(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok, res
end

local function getRoot()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

-- Global State Flags
_G.LianNuyul = {
    AutoRoll = false,
    FastRoll = false,
    AutoCollectPlot = false,
    AutoQuests = false,
    AutoEquipBest = false,
    AutoQuirk = false,
    QuirkTarget = "Prodigy", -- "Prodigy" atau "Fortune's Favor"
    AutoSell = false,
    AutoTutorial = false,
    TargetRolls = 1000,
    LeaveOnTarget = false,
    DiscordWebhook = "",
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
local NuyulTab = Window:CreateTab("Nuyul Automation", 4483362458)
local QuirkTab = Window:CreateTab("Quirk Reroll", 4483362458)
local EconomyTab = Window:CreateTab("Plot & Quest", 4483362458)
local PerfTab = Window:CreateTab("Multi-Account Perf", 4483362458)
local PlayerTab = Window:CreateTab("Movement & Misc", 4483362458)

-- ═════════════════════════════════════════════════════════════════════
-- TAB 1: NUYUL AUTOMATION (DICE & TUTORIAL)
-- ═════════════════════════════════════════════════════════════════════
NuyulTab:CreateSection("🎲 Auto Roll & Farm")

NuyulTab:CreateToggle({
    Name = "Auto Roll Dice",
    CurrentValue = false,
    Flag = "ToggleAutoRoll",
    Callback = function(Value)
        _G.LianNuyul.AutoRoll = Value
        if Value then
            task.spawn(function()
                while _G.LianNuyul.AutoRoll do
                    safeCall(function()
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
            safeCall(function()
                if NET and NET:FindFirstChild("RollService") then
                    local RE_Auto = NET.RollService:FindFirstChild("RE") and NET.RollService.RE:FindFirstChild("SetAutoRoll")
                    if RE_Auto then RE_Auto:FireServer(false) end
                end
            end)
        end
    end,
})

NuyulTab:CreateToggle({
    Name = "Fast Roll Mode (No Animation)",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianNuyul.FastRoll = Value
    end,
})

NuyulTab:CreateToggle({
    Name = "Auto Skip / Complete Tutorial (Akun Baru)",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianNuyul.AutoTutorial = Value
        if Value then
            task.spawn(function()
                while _G.LianNuyul.AutoTutorial do
                    safeCall(function()
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

NuyulTab:CreateSection("🎯 Target Rolls & Auto Disconnect")

NuyulTab:CreateInput({
    Name = "Target Rolls (Syarat Trade)",
    PlaceholderText = "Default: 1000",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then _G.LianNuyul.TargetRolls = num end
    end,
})

NuyulTab:CreateToggle({
    Name = "Auto Disconnect Saat Target Tercapai",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianNuyul.LeaveOnTarget = Value
        if Value then
            task.spawn(function()
                while _G.LianNuyul.LeaveOnTarget do
                    local curRolls = (DC and DC.Rolls and DC.Rolls()) or 0
                    if curRolls >= _G.LianNuyul.TargetRolls then
                        Rayfield:Notify({ Title = "Target Tercapai!", Content = "Rolls sudah " .. curRolls .. ". Disconnecting...", Duration = 5 })
                        task.wait(2)
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
-- TAB 2: QUIRK REROLL (LUCK & TRAIT HUNTER)
-- ═════════════════════════════════════════════════════════════════════
QuirkTab:CreateSection("✨ Auto Quirk Rolling")

QuirkTab:CreateDropdown({
    Name = "Pilih Target Trait / Quirk",
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
                    safeCall(function()
                        if NET and NET:FindFirstChild("QuirkService") then
                            local RE_Roll = NET.QuirkService:FindFirstChild("RE") and NET.QuirkService.RE:FindFirstChild("Roll")
                            if RE_Roll then
                                -- Cari unit key
                                local okInv, inv = pcall(function() return DC.Inventory.Units() end)
                                if okInv and inv then
                                    for key, unit in pairs(inv) do
                                        if unit.Quirk ~= _G.LianNuyul.QuirkTarget then
                                            RE_Roll:FireServer(key)
                                            break
                                        end
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
-- TAB 3: PLOT ECONOMY & QUESTS
-- ═════════════════════════════════════════════════════════════════════
EconomyTab:CreateSection("💰 Plot Money & Units")

EconomyTab:CreateToggle({
    Name = "Auto Collect Plot Balance",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianNuyul.AutoCollectPlot = Value
        if Value then
            task.spawn(function()
                while _G.LianNuyul.AutoCollectPlot do
                    safeCall(function()
                        if NET and NET:FindFirstChild("PlotService") then
                            local RE_Collect = NET.PlotService.RE:FindFirstChild("CollectBalance")
                            if RE_Collect then RE_Collect:FireServer() end
                        end
                    end)
                    task.wait(1.5)
                end
            end)
        end
    end,
})

EconomyTab:CreateButton({
    Name = "Auto Equip Best Unit",
    Callback = function()
        safeCall(function()
            if NET and NET:FindFirstChild("UnitService") then
                local RF_Equip = NET.UnitService.RF:FindFirstChild("Equip")
                if RF_Equip then RF_Equip:InvokeServer("Best") end
            end
        end)
        Rayfield:Notify({ Title = "Lian Hub", Content = "Best unit equipped!", Duration = 3 })
    end,
})

EconomyTab:CreateSection("📜 Auto Quests")

EconomyTab:CreateToggle({
    Name = "Auto Claim All Quests (Daily & Weekly)",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianNuyul.AutoQuests = Value
        if Value then
            task.spawn(function()
                while _G.LianNuyul.AutoQuests do
                    safeCall(function()
                        local QuestConfig = require(RS.Framework.Features.Quests.QuestConfig)
                        local Network = require(RS.Packages.Network)
                        local questClaim = Network.ClientComm.new(RS.Network, false, "QuestService"):GetSignal("Claim")
                        local now = math.floor(workspace:GetServerTimeNow())
                        
                        for _, period in ipairs({"Daily", "Weekly"}) do
                            local ok, data = pcall(function() return DC.Quests[period]() end)
                            if ok and data and data.progress and data.claimed then
                                if data.expiresAt == 0 or data.expiresAt > now then
                                    local periodConfig = QuestConfig.Periods[period]
                                    if periodConfig and periodConfig.quests then
                                        for _, quest in ipairs(periodConfig.quests) do
                                            local progress = data.progress[quest.id] or 0
                                            if progress >= quest.target and not data.claimed[quest.id] then
                                                questClaim:Fire(period, quest.id, data.expiresAt)
                                                task.wait(0.3)
                                            end
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

-- ═════════════════════════════════════════════════════════════════════
-- TAB 4: MULTI-ACCOUNT POTATO OPTIMIZER (KHUSUS NUYUL)
-- ═════════════════════════════════════════════════════════════════════
PerfTab:CreateSection("❄️ CPU / GPU Saver (Buat Buka 10-20 Akun)")

PerfTab:CreateButton({
    Name = "Extreme Potato Mode (FPS Cap 30 + No Graphics)",
    Callback = function()
        -- 1. Cap FPS to 30
        pcall(function()
            if setfpscap then setfpscap(30) end
        end)
        -- 2. Strip Lights & Particles
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
        -- 3. Lighting shadows off
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Rayfield:Notify({ Title = "Potato Mode Aktif!", Content = "GPU & CPU load turun drastis!", Duration = 4 })
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 5: MOVEMENT & SERVER
-- ═════════════════════════════════════════════════════════════════════
PlayerTab:CreateSection("🏃 Player Movement")

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
    Title = "Lian Hub Loaded!",
    Content = "100% Keyless Nuyul Suite Active!",
    Duration = 5
})
