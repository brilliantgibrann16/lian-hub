--[[
    ═════════════════════════════════════════════════════════════════════════
    ⚡ LIAN HUB — 100% KEYLESS ROBLOX SUITE & ANIME DICE AUTO FARM ⚡
    Author : Lian (@brilliantgibrann16)
    Repo   : https://github.com/brilliantgibrann16/lian-hub
    Status : 100% KEYLESS • NO LINKVERTISE • NO ADS • NO LUARMOR
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

local LocalPlayer = Players.LocalPlayer

-- Anti-AFK (Bebas idle kick 20 menit)
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0, 0))
    task.wait(1)
end)

-- Deteksi Network Anime Dice
local NET = RS:FindFirstChild("Network")
local okDC, DC = pcall(function()
    return require(RS.Framework.Features.Data.DataController)
end)

-- Global State Flags
_G.LianHub = {
    AutoRoll = false,
    FastRoll = false,
    AutoCollectMoney = false,
    AutoClaimQuests = false,
    InfJump = false,
    Noclip = false
}

-- Load UI (Rayfield — Pure Keyless)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "⚡ Lian Hub | Universal Suite",
    Icon = 0,
    LoadingTitle = "Lian Hub Injecting...",
    LoadingSubtitle = "by iannn (@brilliantgibrann16)",
    Theme = "Ocean",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = { Enabled = false },
    KeySystem = false -- 🔥 NO KEY SYSTEM / NO ADS / INSTANT ACCESS
})

-- Tabs
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local QuestTab = Window:CreateTab("Quests & Plot", 4483362458)
local PlayerTab = Window:CreateTab("Player & Move", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483362458)
local ServerTab = Window:CreateTab("Server & Utils", 4483362458)

-- ═════════════════════════════════════════════════════════════════════
-- TAB 1: AUTO FARM (ROLL DICE)
-- ═════════════════════════════════════════════════════════════════════
FarmTab:CreateSection("🎲 Anime Dice Rolling Engine")

-- Auto Roll Toggle
FarmTab:CreateToggle({
    Name = "Auto Roll Dice",
    CurrentValue = false,
    Flag = "ToggleAutoRoll",
    Callback = function(Value)
        _G.LianHub.AutoRoll = Value
        if Value then
            task.spawn(function()
                while _G.LianHub.AutoRoll do
                    pcall(function()
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
                    task.wait(_G.LianHub.FastRoll and 0.05 or 0.25)
                end
            end)
        else
            pcall(function()
                if NET and NET:FindFirstChild("RollService") then
                    local RE_Auto = NET.RollService:FindFirstChild("RE") and NET.RollService.RE:FindFirstChild("SetAutoRoll")
                    if RE_Auto then RE_Auto:FireServer(false) end
                end
            end)
        end
    end,
})

-- Fast Roll Toggle
FarmTab:CreateToggle({
    Name = "Fast Roll Mode (No Animation Delay)",
    CurrentValue = false,
    Flag = "ToggleFastRoll",
    Callback = function(Value)
        _G.LianHub.FastRoll = Value
    end,
})

FarmTab:CreateSection("Unit Management")

FarmTab:CreateButton({
    Name = "Equip Best Unit",
    Callback = function()
        pcall(function()
            if NET and NET:FindFirstChild("UnitService") then
                local RF_Equip = NET.UnitService:FindFirstChild("RF") and NET.UnitService.RF:FindFirstChild("Equip")
                if RF_Equip then RF_Equip:InvokeServer("Best") end
            end
        end)
        Rayfield:Notify({ Title = "Lian Hub", Content = "Equip Best triggered!", Duration = 3 })
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 2: QUESTS & PLOT COLLECTOR
-- ═════════════════════════════════════════════════════════════════════
QuestTab:CreateSection("💰 Plot Economy")

-- Auto Collect Plot Coins
QuestTab:CreateToggle({
    Name = "Auto Collect Plot Balance",
    CurrentValue = false,
    Flag = "ToggleCollectMoney",
    Callback = function(Value)
        _G.LianHub.AutoCollectMoney = Value
        if Value then
            task.spawn(function()
                while _G.LianHub.AutoCollectMoney do
                    pcall(function()
                        if NET and NET:FindFirstChild("PlotService") then
                            local RE_Collect = NET.PlotService:FindFirstChild("RE") and NET.PlotService.RE:FindFirstChild("CollectBalance")
                            if RE_Collect then RE_Collect:FireServer() end
                        end
                    end)
                    task.wait(1.5)
                end
            end)
        end
    end,
})

QuestTab:CreateSection("📜 Auto Quests")

-- Auto Claim Quests
QuestTab:CreateToggle({
    Name = "Auto Claim Quests (Daily & Weekly)",
    CurrentValue = false,
    Flag = "ToggleAutoQuests",
    Callback = function(Value)
        _G.LianHub.AutoClaimQuests = Value
        if Value then
            task.spawn(function()
                while _G.LianHub.AutoClaimQuests do
                    pcall(function()
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
-- TAB 3: PLAYER & MOVEMENT
-- ═════════════════════════════════════════════════════════════════════
PlayerTab:CreateSection("🏃 Movement Modification")

PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 250},
    Increment = 1,
    Suffix = " Speed",
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
    Suffix = " Power",
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
    Callback = function(Value)
        _G.LianHub.InfJump = Value
    end,
})

UserInputService.JumpRequest:Connect(function()
    if _G.LianHub.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

PlayerTab:CreateToggle({
    Name = "Noclip (Walk Through Walls)",
    CurrentValue = false,
    Callback = function(Value)
        _G.LianHub.Noclip = Value
    end,
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

-- ═════════════════════════════════════════════════════════════════════
-- TAB 4: VISUALS (ESP & Fullbright)
-- ═════════════════════════════════════════════════════════════════════
VisualTab:CreateSection("👁️ ESP & Wallhack")

VisualTab:CreateToggle({
    Name = "Player ESP (Chams Highlight)",
    CurrentValue = false,
    Callback = function(Value)
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local highlight = plr.Character:FindFirstChild("LianChams")
                if Value then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "LianChams"
                        highlight.FillColor = Color3.fromRGB(0, 200, 255)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0
                        highlight.Parent = plr.Character
                    end
                else
                    if highlight then highlight:Destroy() end
                end
            end
        end
    end,
})

VisualTab:CreateButton({
    Name = "Fullbright (Terang Tanpa Gelap)",
    Callback = function()
        local Lighting = game:GetService("Lighting")
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 5: SERVER & UTILS
-- ═════════════════════════════════════════════════════════════════════
ServerTab:CreateSection("⚡ Performance")

ServerTab:CreateButton({
    Name = "Boost FPS (Potato Mode)",
    Callback = function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            end
        end
        Rayfield:Notify({ Title = "Lian Hub", Content = "Potato Mode Enabled!", Duration = 3 })
    end,
})

ServerTab:CreateSection("🌐 Reconnect")

ServerTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end,
})

ServerTab:CreateButton({
    Name = "Server Hop (Pindah Server)",
    Callback = function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local success, res = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
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
    Content = "100% Keyless Suite ready! Enjoy!",
    Duration = 5
})
