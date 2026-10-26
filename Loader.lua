--[[
    ═════════════════════════════════════════════════════════════════════════
    ⚡ LIAN HUB — 100% KEYLESS ANIME DICE MASTER EXPLOIT SUITE v6.3 ⚡
    Author : Lian (@brilliantgibrann16)
    Target : Anime Dice (PlaceId: 113290951185459 / Universe: 10708913337)
    ═════════════════════════════════════════════════════════════════════════
    [CHANGELOG v6.3 REVOLUTION EDITION]:
    ★ 100% Exact Remote Mappings:
      - PlotService.RE.CollectBalance (Fixed from CollectCash!)
      - TrickOrTreatService.RE.Knocked + Landed (Fixed from HalloweenService!)
      - SellService.RF.SellInventory + PlotService.RE.EquipBest
      - Towers.RF.PlayTower + CompleteTowerFloor + EquipBestTowerTeam
      - PumpkinDiceService.RF.Roll + RebirthService.RE.Rebirth + AddStat
    ★ Robust Framework & DataController Resolver:
      - Waits up to 25s for ReplicatedStorage.Framework IsLoaded.
      - Dual-mode require (asGame identity 2 + standard require fallback).
      - Multi-layer cash & rebirth cost resolver (DataController -> HUD -> leaderstats).
    ★ Ruthless Plot Optimizer & Auto-Sell:
      - Equips best units to Plot.
      - Immediately sells all remaining units in inventory outside the plot!
      - Zero locks, zero rarity filters, zero clutter.
    ★ 100% Decoupled Background Workers:
      - Permanent worker loops; toggles take effect instantly on fresh or re-exec.
    ★ Draggable Floating Button & Laptop Hotkeys:
      - [⚡ Lian Hub] floating pill button + RightControl / Insert / LeftAlt.
    ═════════════════════════════════════════════════════════════════════════
]]--

-- Solara-compatible: timeout-based load check (game:IsLoaded may hang on some executors)
local _loadT = os.clock()
while not game:IsLoaded() and os.clock() - _loadT < 15 do task.wait(0.2) end
if not game:IsLoaded() then warn("[Lian Hub] game not fully loaded after 15s, proceeding anyway") end

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

-- 1. Anti-AFK (AUTO — no toggle, runs from script start)
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
    task.wait(1)
end)

-- Permanent Anti-AFK heartbeat (auto, no toggle)
task.spawn(function()
    while true do
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(math.random(0, 100), math.random(0, 100)))
        end)
        -- Also wiggle character slightly to prevent idle kick (guard: skip if custom speed set or non-normal state)
        -- task.wait is OUTSIDE pcall: yielding inside pcall breaks on Solara/Level-3
        local oldWS = nil
        local hum = nil
        pcall(function()
            if LocalPlayer.Character then
                local h = LocalPlayer.Character:FindFirstChild("Humanoid")
                if h and h.Health > 0 then
                    local st = h:GetState()
                    if st ~= Enum.HumanoidStateType.Dead and st ~= Enum.HumanoidStateType.Jumping and st ~= Enum.HumanoidStateType.Freefall then
                        hum = h
                        oldWS = h.WalkSpeed
                        h.WalkSpeed = oldWS + 0.01
                    end
                end
            end
        end)
        if hum and oldWS then
            task.wait(0.05)
            pcall(function() hum.WalkSpeed = oldWS end)
        end
        task.wait(60)
    end
end)


-- Guard: ensure _G.LianConfig exists before any on-load reference
_G.LianConfig = _G.LianConfig or {}

-- Apply ESP to existing players' current characters + respawn
for _, existingPlr in pairs(game:GetService("Players"):GetPlayers()) do
    if existingPlr ~= LocalPlayer then
        -- Apply to current character if exists
        if existingPlr.Character then
            task.spawn(function()
                task.wait(1)
                if _G.LianConfig.PlayerESP then
                    local head = existingPlr.Character:FindFirstChild("Head")
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
                        label.Text = existingPlr.Name
                        label.Parent = billboard
                    end
                end
            end)
        end
        existingPlr.CharacterAdded:Connect(function(char)
            task.wait(1)
            if _G.LianConfig.PlayerESP then
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
                    label.Text = existingPlr.Name
                    label.Parent = billboard
                end
            end
        end)
    end
end

-- Apply ESP to newly joined players
game:GetService("Players").PlayerAdded:Connect(function(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function(char)
        task.wait(1)
        if _G.LianConfig.PlayerESP then
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
                label.Text = p.Name
                label.Parent = billboard
            end
        end
    end)
end)


-- Reapply visual/movement settings on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    pcall(function()
        if _G.LianConfig.Fullbright then
            local Lighting = game:GetService("Lighting")
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        end
        if char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = _G.LianConfig.WalkSpeedValue or 16
            char.Humanoid.JumpPower = _G.LianConfig.JumpPowerValue or 50
        end
    end)
end)

-- 2. Teleport Auto-Execute Queue
local function setupAutoExecuteOnTeleport()
    local qot = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    if qot then
        pcall(function()
            qot('loadstring(game:HttpGet("https://raw.githubusercontent.com/brilliantgibrann16/lian-hub/main/Loader.lua"))()')
        end)
    end
end

-- 3. Thread Identity Dropper (Solara-Safe)
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

-- 4. Verified Remote Registry
local NET = RS:FindFirstChild("Network") or RS:WaitForChild("Network", 1)

local R = {}
local function getRemote(svc, kind, name)
    if not NET then return nil end
    local folder = svc and NET:FindFirstChild(svc) or NET
    if not folder then return nil end
    local sub = folder:FindFirstChild(kind)
    if not sub then return nil end
    return sub:FindFirstChild(name)
end

R.Roll = getRemote("RollService", "RF", "RollDice")
R.SetAutoRoll = getRemote("RollService", "RE", "SetAutoRoll")
R.PumpkinRoll = getRemote("PumpkinDiceService", "RF", "Roll")
R.Collect = getRemote("PlotService", "RE", "CollectBalance")
R.EquipBest = getRemote("PlotService", "RE", "EquipBest")
R.LevelSlot = getRemote("PlotService", "RE", "LevelUpSlot")
R.Sell = getRemote("SellService", "RF", "SellInventory")
R.BuyUpgrade = getRemote(nil, "RE", "BuyUpgrade")
R.BuyDice = getRemote("DiceShopService", "RE", "BuyDice")
R.EquipDice = getRemote("DiceShopService", "RE", "EquipDice")
R.Rebirth = getRemote("RebirthService", "RE", "Rebirth")
R.AddStat = getRemote("RebirthService", "RE", "AddStat")
R.PlayTower = getRemote("Towers", "RF", "PlayTower")
R.FloorTower = getRemote("Towers", "RF", "CompleteTowerFloor")
R.BestTeam = getRemote("Towers", "RE", "EquipBestTowerTeam")
R.Boost = getRemote("BoostService", "RE", "Use")
R.Spin = getRemote("SpinService", "RE", "Use")
R.Daily = getRemote("DailyRewardService", "RE", "Claim")
R.Offline = getRemote("OfflineEarningsService", "RE", "Claim")
R.Code = getRemote("CodesService", "RE", "RedeemCode")
R.HalloweenPath = getRemote("HalloweenService", "RE", "ClaimAllPath")
R.HalloweenQuest = getRemote("HalloweenQuestService", "RE", "Claim")
R.TrickKnock = getRemote("TrickOrTreatService", "RE", "Knocked")
R.TrickLand = getRemote("TrickOrTreatService", "RE", "Landed")
R.QuirkRoll = getRemote("QuirkService", "RE", "Roll") or getRemote("GradeService", "RE", "Roll")
R.QuirkProtect = getRemote("QuirkService", "RE", "SetQuirkProtected") or getRemote("GradeService", "RE", "SetGradeProtected")
R.TradeReq = getRemote("TradeService", "RE", "RequestTrade")
R.TradeResp = getRemote("TradeService", "RE", "RespondToRequest")
R.TradeOffer = getRemote("TradeService", "RE", "ChangeOffer")
R.TradeAdv = getRemote("TradeService", "RE", "AdvanceTrade")
R.TradeEvent = getRemote("TradeService", "RE", "TradeEvent")

local function fire(remote, ...)
    if remote then
        remote:FireServer(...)
    end
end

local function invoke(remote, ...)
    if remote then
        return remote:InvokeServer(...)
    end
    return nil
end

-- (safe() helper removed: unused; pcall-yield constraints documented above)


-- ═══════════════════════════════════════════════════════════════════════════
-- LIAN HUB GAME UPDATE CHECKER (run via Lian Hub UI or console)
-- ═══════════════════════════════════════════════════════════════════════════
local function checkGameUpdates()
    local results = {}
    local function check(name, ok)
        table.insert(results, (ok and "✅ " or "❌ ") .. name)
    end

    -- Wrap all checks in pcall to catch any runtime error
    local function runChecks()


    -- Framework
    local fw = RS:FindFirstChild("Framework")
    check("Framework module", fw ~= nil)
    if fw then
        local feat = fw:FindFirstChild("Features")
        check("Framework.Features", feat ~= nil)
        if feat then
            for _, modName in ipairs({"Data","Buffs","Inventory","Rolling","Upgrades","Rebirth","Plot","Towers","Quests"}) do
                check("Feature."..modName, feat:FindFirstChild(modName) ~= nil)
            end
        end
    end

    -- Network remotes
    local net = RS:FindFirstChild("Network")
    check("Network folder", net ~= nil)
    if net then
        local services = {
            {"RollService","RE","SetAutoRoll"}, {"RollService","RF","RollDice"},
            {"PumpkinDiceService","RF","Roll"}, {"PlotService","RE","CollectBalance"},
            {"PlotService","RE","EquipBest"}, {"SellService","RF","SellInventory"},
            {"RebirthService","RE","Rebirth"}, {"RebirthService","RE","AddStat"},
            {"Towers","RF","PlayTower"}, {"Towers","RF","CompleteTowerFloor"},
            {"TrickOrTreatService","RE","Knocked"}, {"TrickOrTreatService","RE","Landed"},
            {"HalloweenService","RE","ClaimAllPath"}, {"HalloweenQuestService","RE","Claim"},
            {"BoostService","RE","Use"}, {"SpinService","RE","Use"},
            {"DailyRewardService","RE","Claim"}, {"OfflineEarningsService","RE","Claim"},
            {"CodesService","RE","RedeemCode"}, {"GradeService","RE","Roll"},
            {"GradeService","RE","SetGradeProtected"}, {"TradeService","RE","RequestTrade"},
            {"TradeService","RE","TradeEvent"}, {"TradeService","RE","SetTradeRequestsEnabled"},
        }
        for _, s in ipairs(services) do
            local svc = net:FindFirstChild(s[1])
            local sub = svc and svc:FindFirstChild(s[2])
            local remote = sub and sub:FindFirstChild(s[3])
            check(s[1].."."..s[2].."."..s[3], remote ~= nil)
        end
    end

    -- Workspace
    check("Workspace.Plots", Workspace:FindFirstChild("Plots") ~= nil or (Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Plots")) ~= nil)
    check("Workspace.Halloween", Workspace:FindFirstChild("Halloween") ~= nil)

    -- PlayerGui
    local root = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Root")
    check("PlayerGui.Root", root ~= nil)
    check("PlayerGui.Root.HUD", root and root:FindFirstChild("HUD") ~= nil)
    check("PlayerGui.Root.Menus.Rebirth", root and root:FindFirstChild("Menus") and root.Menus:FindFirstChild("Rebirth") ~= nil)

    -- DataController (inlined to avoid upvalue nil issue)
    local dc = nil
    pcall(function()
        if RS:FindFirstChild("Framework") and RS.Framework:FindFirstChild("Features") and RS.Framework.Features:FindFirstChild("Data") then
            dc = asGame(require, RS.Framework.Features.Data.DataController) or require(RS.Framework.Features.Data.DataController)
        end
    end)
    check("DataController", dc ~= nil)
    if dc then
        for _, field in ipairs({"Money","Cash","Coins","Inventory","Slots","Rebirth","RebirthStats","Upgrades","Weather"}) do
            local okField, valField = pcall(function() return dc[field] ~= nil end)
            check("DC."..field, okField and valField or false)
        end
    end

    end -- runChecks

    local okRun, errRun = pcall(runChecks)
    if not okRun then
        table.insert(results, "❌ INTERNAL ERROR: " .. tostring(errRun))
        warn("[LianHub] CheckUpdates internal error: " .. tostring(errRun))
    end

    -- Print report
    print("\n═══════════════════════════════════════════════════════════════════════════")
    print("🔍 LIAN HUB GAME UPDATE CHECKER REPORT")
    print("═══════════════════════════════════════════════════════════════════════════")
    for _, r in ipairs(results) do print(r) end
    local broken = 0
    for _, r in ipairs(results) do if r:find("❌") then broken = broken + 1 end end
    print("\n📊 Total checks: "..#results.." | Broken: "..broken)
    if broken > 0 then
        print("⚠️ Game may have updated! Some remotes/modules are missing.")
    else
        print("✅ All systems nominal. Game structure unchanged.")
    end
    print("═══════════════════════════════════════════════════════════════════════════\n")
    return results
end

-- Expose globally
_G.LianHubCheckUpdates = checkGameUpdates

-- 5. Game Framework Modules Loader
local M = {}
local function initFramework()
    local fw = RS:WaitForChild("Framework", 25)
    if not fw then return end
    local t0 = os.clock()
    while not fw:GetAttribute("IsLoaded") and os.clock() - t0 < 20 do
        task.wait(0.5)
    end
    local Feat = fw:WaitForChild("Features", 15)
    if not Feat then return end

    local function req(mod)
        if not mod then return nil end
        local ok, res = pcall(asGame, require, mod)
        if ok and res then return res end
        local ok2, res2 = pcall(require, mod)
        if ok2 and res2 then return res2 end
        return nil
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
    if Feat:FindFirstChild("Towers") then
        M.Towers = req(Feat.Towers:FindFirstChild("Towers"))
        M.TowerRefs = req(Feat.Towers:FindFirstChild("TowerRefs"))
    end
    if Feat:FindFirstChild("Quests") then M.Quests = req(Feat.Quests:FindFirstChild("QuestConfig")) end
end
task.spawn(initFramework)

local function getDC()
    if M.Data then return M.Data end
    pcall(function()
        if RS:FindFirstChild("Framework") and RS.Framework:FindFirstChild("Features") and RS.Framework.Features:FindFirstChild("Data") then
            M.Data = asGame(require, RS.Framework.Features.Data.DataController) or require(RS.Framework.Features.Data.DataController)
        end
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

-- 6. Persistent Configuration
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
    AutoHalloweenQuestClaim = false,  -- renamed from AutoHalloweenDoors
    AutoPumpkinPass = false,
    AutoTower = false,
    SmartTowerAI = false,
    AutoEquipTowerTeam = true,
    TowerType = "The Abyss",
    AutoCollectCash = false,
    AutoLevelUpSlots = false,
    AutoDailyReward = false,
    AutoRedeemCodes = false,
    AutoClaimOffline = true,
    AutoLuckySpin = true,
    AutoRebirth = false,
    AutoAllocStats = true,
    RebirthStatPriority = "Balance / Rata (Money, Luck, Damage, Health, Speed)",
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
    -- Aligned with groper99/animedice reference features
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
-- Merge previous in-memory state (preserve across re-inject)
if _prevConfig then
    for k, v in pairs(_prevConfig) do
        if _G.LianConfig[k] ~= nil then
            _G.LianConfig[k] = v
        end
    end
end

-- ponytail: backward-compat migration for renamed config key (must run on loaded JSON before nil-reject loop)
pcall(function()
    if isfile and isfile(CONFIG_FILE) and readfile then
        local raw = HttpService:JSONDecode(readfile(CONFIG_FILE))
        if type(raw) == "table" and raw.AutoHalloweenDoors ~= nil then
            -- Only migrate if AutoHalloweenQuestClaim is NOT explicitly present in saved config
            if raw.AutoHalloweenQuestClaim == nil then
                _G.LianConfig.AutoHalloweenQuestClaim = raw.AutoHalloweenDoors
            end
        end
    end
end)

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
    _G.LianConfig.ServerLuckHop = false
end
loadConfig()

-- Apply saved visual/movement settings on load (after config loaded)
pcall(function()
    if _G.LianConfig.WalkSpeedValue and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = _G.LianConfig.WalkSpeedValue
    end
    if _G.LianConfig.JumpPowerValue and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = _G.LianConfig.JumpPowerValue
    end
    if _G.LianConfig.Fullbright then
        local Lighting = game:GetService("Lighting")
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
    end
    if _G.LianConfig.PlayerESP then
        for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local head = plr.Character:FindFirstChild("Head")
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
        end
    end
end)

-- 7. Calculation & Game Data Helpers
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
    local dc = getDC()
    if dc then
        local ok, money = pcall(function()
            if dc.Money then return dc.Money() end
            if dc.Cash then return dc.Cash() end
            if dc.Coins then return dc.Coins() end
            return nil
        end)
        if ok and type(money) == "number" and money >= 0 then
            return money
        end
    end
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        for _, name in ipairs({"Cash", "Coins", "Money", "Balance"}) do
            local val = ls:FindFirstChild(name)
            if val and val.Value then return tonumber(val.Value) or 0 end
        end
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
    local dc = getDC()
    if dc and dc.Rebirth then pcall(function() curRebirths = dc.Rebirth() or 0 end) end

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
    local dc = getDC()
    if dc then
        pcall(function() curStats = (dc.RebirthStats and dc.RebirthStats()) or {} end)
        pcall(function() curRebirths = (dc.Rebirth and dc.Rebirth()) or 0 end)
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
    local dc = getDC()
    local owned = (dc and dc.Upgrades and dc.Upgrades()) or {}
    local cands = {}
    local hasGetParent = M.Tree.GetParent ~= nil
    for name, u in pairs(M.Upgrades) do
        if name ~= "Start" and not owned[name] then
            local allow = false
            if not hasGetParent then
                -- Cannot verify parent dependency: skip to avoid wrong purchases
                allow = false
            else
                local parent = M.Tree.GetParent(name)
                if parent == nil or parent == "Start" or owned[parent] then
                    allow = true
                end
            end
            if allow then
                table.insert(cands, { name = name, price = u.price or 0 })
            end
        end
    end
    table.sort(cands, function(a, b) return a.price < b.price end)
    local bought = 0
    for _, c in ipairs(cands) do
        if bought >= 4 or c.price > money then break end
        fire(R.BuyUpgrade, c.name)
        money = money - c.price
        bought = bought + 1
        task.wait(0.2)
    end
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

-- Ruthless Plot Optimizer: Equip best to plot, immediately sell all rest outside plot!
local function equipBestPlotAndSellOutside()
    fire(R.EquipBest)
    task.wait(1.0)

        local dc = getDC()
        local inv = (dc and dc.Inventory and dc.Inventory()) or {}
        local slots = (dc and dc.Slots and dc.Slots()) or {}

        local plotted = {}
        for slotNum, s in pairs(slots) do
            if type(s) == "table" and (s.unitId or s.key) then
                plotted[s.unitId or s.key] = true
            end
        end

        local sellList = {}
        for key, item in pairs(inv) do
            if not plotted[key] then
                local skip = false
                -- Protect Shiny/Haunted units unless explicitly allowed
                if type(item) == "table" then
                    local isShiny = item.Shiny == true or item.shiny == true or tostring(item.Trait or ""):lower():find("shiny")
                    local isHaunted = item.Haunted == true or item.haunted == true or tostring(item.Trait or ""):lower():find("haunted")
                    if isShiny and _G.LianConfig.ProtectShiny and not _G.LianConfig.AutoSellShiny then skip = true end
                    if isHaunted and _G.LianConfig.ProtectHaunted and not _G.LianConfig.AutoSellHaunted then skip = true end
                    -- Protect high grades
                    if _G.LianConfig.ProtectHighGrades then
                        local gradeOrder = {rare=1, epic=2, legendary=3, mythic=4, secret=5, celestial=6}
                        local grade = gradeOrder[tostring(item.Grade or item.grade or ""):lower()] or 0
                        -- Protect Mythic+ (grade >= 4) regardless of grading target
                        if grade >= 4 then skip = true end
                    end
                end
                if not skip then
                    table.insert(sellList, key)
                end
            end
        end

        if #sellList > 0 and R.Sell then
            local money, numSold = R.Sell:InvokeServer(sellList)
            local ok = money ~= nil
            if ok then
                pcall(function()
                    Rayfield:Notify({
                        Title = "🧹 Auto-Sell Sukses!",
                        Content = #sellList .. " unit di luar plot berhasil dijual!",
                        Duration = 2.5
                    })
                end)
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
                elseif obj:IsA("Decal") then
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

-- 8. Auto-Reconnect Watcher
local isReconnecting = false
GuiService.ErrorMessageChanged:Connect(function(msg)
    if _G.LianConfig.AutoReconnect and not isReconnecting then
        if msg and (msg:find("disconnect") or msg:find("lost") or msg:find("error") or msg:find("277") or msg:find("268") or msg:find("529")) then
            isReconnecting = true
            setupAutoExecuteOnTeleport()
            task.wait(5)
            pcall(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
            isReconnecting = false
        end
    end
end)

print("[Lian Hub] Script starting... executor: " .. (identifyexecutor and identifyexecutor() or "unknown"))

-- 9. Load Rayfield UI
local Rayfield
local rawRay = game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua')
local okRay, rayLib = pcall(function()
    return loadstring(rawRay)()
end)
if okRay and rayLib then
    Rayfield = rayLib
end

if not Rayfield then
    warn("[Lian Hub] Rayfield tidak dapat dimuat. Pastikan koneksi internet aktif. Workers tetap jalan (headless mode).")
    -- Stub so all Rayfield:Notify / CreateWindow call sites become no-ops instead of crashing workers.
    Rayfield = { Notify = function() end, CreateWindow = function() return nil end }
end

local Window
if Rayfield then
    local okWin, win = pcall(function()
        return Rayfield:CreateWindow({

    Name = "⚡ Lian Hub v6.3 | Anime Dice Master Suite",
    Icon = 0,
    LoadingTitle = "Lian Hub Injecting...",
    LoadingSubtitle = "by iannn (@brilliantgibrann16)",
    Theme = "Ocean",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
        })
    end)
    if okWin and win then
        Window = win
    else
        warn("[Lian Hub] CreateWindow failed: " .. tostring(win))
        Window = nil
    end
else
    warn("[Lian Hub] Rayfield not available, skipping UI creation")
    Window = nil
end

-- Floating Draggable Toggle Button
pcall(function()
    local parentGui = nil
    if type(gethui) == "function" then
        pcall(function() parentGui = gethui() end)
    end
    if not parentGui then
        pcall(function() parentGui = game:GetService("CoreGui") end)
    end
    if not parentGui then
        pcall(function() parentGui = LocalPlayer:WaitForChild("PlayerGui", 5) end)
    end
    if not parentGui then
        warn("[Lian Hub] No GUI parent available. UI cannot be created.")
    end
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

-- TABS (skip UI if Window failed to create)
if not Window then
    warn("[Lian Hub] Window is nil, skipping UI. Spawning workers without UI.")
end

if Window then
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
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local GradesTab = Window:CreateTab("Unit Grades", 4483362458)
local ESPSettingsTab = Window:CreateTab("ESP & Visuals", 4483362458)

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



FarmTab:CreateSection("✨ Quirk Reroll Hunter")

FarmTab:CreateToggle({
    Name = "Auto Reroll Quirk (Auto Stop Pas Target)",
    CurrentValue = _G.LianConfig.AutoQuirk,
    Callback = function(Value)
        _G.LianConfig.AutoQuirk = Value
        saveConfig()
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Buy Dice (Beli dice terbaik otomatis)",
    CurrentValue = _G.LianConfig.AutoBuyDice,
    Callback = function(Value)
        _G.LianConfig.AutoBuyDice = Value
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
    Name = "Minum Speed Potions",
    CurrentValue = _G.LianConfig.PotionUseSpeed,
    Callback = function(Value)
        _G.LianConfig.PotionUseSpeed = Value
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

    local _tg
    _tg = PlotTab:CreateToggle({
        Name = "🔍 Check Game Updates (Diagnose Broken Features)",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
        local ok, res = pcall(_G.LianHubCheckUpdates)
        if not ok then
        warn("[LianHub] CheckUpdates error: " .. tostring(res))
        Rayfield:Notify({ Title = "Game Update Check", Content = "Error: " .. tostring(res), Duration = 6 })
        return
        end
        local broken = 0
        for _, r in ipairs(res or {}) do if type(r) == "string" and r:find("❌") then broken = broken + 1 end end
        Rayfield:Notify({
        Title = "Game Update Check",
        Content = broken .. " broken out of " .. #(res or {}) .. " checks. See F9 console for details.",
        Duration = 6
        })
        task.spawn(function()
            task.wait(0.5)
            pcall(function() _tg:Set(false) end)
        end)
    end,
})

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




-- ═════════════════════════════════════════════════════════════════════
-- TAB 6b: UNIT GRADES (name-aligned with groper99/animedice; behavior unverified — reference is obfuscated)
-- ═════════════════════════════════════════════════════════════════════
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

-- ═════════════════════════════════════════════════════════════════════
-- TAB 6c: TELEPORT (name-aligned with groper99/animedice; behavior unverified — reference is obfuscated)
-- ═════════════════════════════════════════════════════════════════════
TeleportTab:CreateSection("📍 Teleport Destinations")

    local _tg
    _tg = TeleportTab:CreateToggle({
        Name = "🏠 Teleport ke Plot Sendiri",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
        pcall(function()
        local plot = findMyPlot()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then Rayfield:Notify({Title="Teleport", Content="Karakter belum siap", Duration=3}) return end
        if plot then
        local spawn = plot:FindFirstChild("Spawn") or plot:FindFirstChildWhichIsA("SpawnLocation")
        if spawn then
        hrp.CFrame = spawn.CFrame + Vector3.new(0,3,0)
        else
        hrp.CFrame = plot:GetPivot() + Vector3.new(0,3,0)
        end
        else
        Rayfield:Notify({ Title = "Teleport", Content = "Plot tidak ditemukan!", Duration = 3 })
        end
        end)
        task.spawn(function()
            task.wait(0.5)
            pcall(function() _tg:Set(false) end)
        end)
    end,
})

    local _tg
    _tg = TeleportTab:CreateToggle({
        Name = "🎲 Teleport ke Dice Shop",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
        pcall(function()
        local shop = workspace:FindFirstChild("DiceShop") or workspace:FindFirstChild("Shop") or (workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("DiceShop"))
        if shop then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = shop:GetPivot() + Vector3.new(0,3,0)
        else
            pcall(function() Rayfield:Notify({ Title = "Teleport", Content = "Character not ready, coba lagi.", Duration = 3 }) end)
        end
        else
        Rayfield:Notify({ Title = "Teleport", Content = "Dice Shop tidak ditemukan!", Duration = 3 })
        end
        end)
        task.spawn(function()
            task.wait(0.5)
            pcall(function() _tg:Set(false) end)
        end)
    end,
})

    local _tg
    _tg = TeleportTab:CreateToggle({
        Name = "🔄 Teleport ke Rebirth Station",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
        pcall(function()
        local rebirth = workspace:FindFirstChild("Rebirth") or workspace:FindFirstChild("RebirthStation") or (workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Rebirth"))
        if rebirth then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = rebirth:GetPivot() + Vector3.new(0,3,0)
        else
            pcall(function() Rayfield:Notify({ Title = "Teleport", Content = "Character not ready, coba lagi.", Duration = 3 }) end)
        end
        else
        Rayfield:Notify({ Title = "Teleport", Content = "Rebirth Station tidak ditemukan!", Duration = 3 })
        end
        end)
        task.spawn(function()
            task.wait(0.5)
            pcall(function() _tg:Set(false) end)
        end)
    end,
})

    local _tg
    _tg = TeleportTab:CreateToggle({
        Name = "🧬 Teleport ke Fusing Station",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
        pcall(function()
        local fuse = workspace:FindFirstChild("Fusing") or workspace:FindFirstChild("Fuse") or (workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Fusing"))
        if fuse then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = fuse:GetPivot() + Vector3.new(0,3,0)
        else
            pcall(function() Rayfield:Notify({ Title = "Teleport", Content = "Character not ready, coba lagi.", Duration = 3 }) end)
        end
        else
        Rayfield:Notify({ Title = "Teleport", Content = "Fusing Station tidak ditemukan!", Duration = 3 })
        end
        end)
        task.spawn(function()
            task.wait(0.5)
            pcall(function() _tg:Set(false) end)
        end)
    end,
})

    local _tg
    _tg = TeleportTab:CreateToggle({
        Name = "📋 Teleport ke Quest Board",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
        pcall(function()
        local q = workspace:FindFirstChild("Quests") or workspace:FindFirstChild("QuestBoard") or (workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Quests"))
        if q then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = q:GetPivot() + Vector3.new(0,3,0)
        else
            pcall(function() Rayfield:Notify({ Title = "Teleport", Content = "Character not ready, coba lagi.", Duration = 3 }) end)
        end
        else
        Rayfield:Notify({ Title = "Teleport", Content = "Quest Board tidak ditemukan!", Duration = 3 })
        end
        end)
        task.spawn(function()
            task.wait(0.5)
            pcall(function() _tg:Set(false) end)
        end)
    end,
})

    local _tg
    _tg = TeleportTab:CreateToggle({
        Name = "🎒 Teleport ke Backpack / Inventory",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
        pcall(function()
        local bp = workspace:FindFirstChild("Backpack") or workspace:FindFirstChild("Inventory") or (workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Backpack"))
        if bp then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = bp:GetPivot() + Vector3.new(0,3,0)
        else
            pcall(function() Rayfield:Notify({ Title = "Teleport", Content = "Character not ready, coba lagi.", Duration = 3 }) end)
        end
        else
        Rayfield:Notify({ Title = "Teleport", Content = "Backpack tidak ditemukan!", Duration = 3 })
        end
        end)
        task.spawn(function()
            task.wait(0.5)
            pcall(function() _tg:Set(false) end)
        end)
    end,
})

TeleportTab:CreateSection("👥 Teleport ke Player")
TeleportTab:CreateInput({
    Name = "Username Target",
    PlaceholderText = "Masukkan username player...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        _G.LianConfig.TeleportTarget = Text:gsub("%s+", "")
    end,
})
    local _tg
    _tg = TeleportTab:CreateToggle({
        Name = "➡️ Teleport ke Player",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
        pcall(function()
        local target = _G.LianConfig.TeleportTarget
        if not target or target == "" then
        Rayfield:Notify({ Title = "Teleport", Content = "Masukkan username dulu!", Duration = 3 })
        return
        end
        for _, p in pairs(game:GetService("Players"):GetPlayers()) do
        if p.Name:lower() == target:lower() and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then Rayfield:Notify({Title="Teleport", Content="Karakter belum siap", Duration=3}) return end
        hrp.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
        Rayfield:Notify({ Title = "Teleport", Content = "Teleported ke " .. p.Name, Duration = 3 })
        return
        end
        end
        Rayfield:Notify({ Title = "Teleport", Content = "Player tidak ditemukan!", Duration = 3 })
        end)
        task.spawn(function()
            task.wait(0.5)
            pcall(function() _tg:Set(false) end)
        end)
    end,
})

    local _tg
    _tg = TeleportTab:CreateToggle({
        Name = "🎲 Teleport ke Random Player",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
        pcall(function()
        local players = game:GetService("Players"):GetPlayers()
        local others = {}
        for _, p in pairs(players) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        table.insert(others, p)
        end
        end
        if #others > 0 then
        local target = others[math.random(1, #others)]
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then Rayfield:Notify({Title="Teleport", Content="Karakter belum siap", Duration=3}) return end
        hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
        Rayfield:Notify({ Title = "Teleport", Content = "Teleported ke " .. target.Name, Duration = 3 })
        else
        Rayfield:Notify({ Title = "Teleport", Content = "Tidak ada player lain!", Duration = 3 })
        end
        end)
        task.spawn(function()
            task.wait(0.5)
            pcall(function() _tg:Set(false) end)
        end)
    end,
})

-- ═════════════════════════════════════════════════════════════════════
-- TAB 6d: ESP & VISUALS (name-aligned with groper99/animedice; behavior unverified — reference is obfuscated)
-- ═════════════════════════════════════════════════════════════════════
ESPSettingsTab:CreateSection("👁️ Player ESP")

ESPSettingsTab:CreateToggle({
    Name = "Player Name ESP",
    CurrentValue = _G.LianConfig.PlayerESP,
    Callback = function(Value)
        _G.LianConfig.PlayerESP = Value
        saveConfig()
        -- Toggle ESP
        for _, p in pairs(game:GetService("Players"):GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local head = p.Character:FindFirstChild("Head")
                if head then
                    local esp = head:FindFirstChild("LianESP")
                    if Value and not esp then
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
                        label.Text = p.Name
                        label.Parent = billboard
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
            local Lighting = game:GetService("Lighting")
            if Value then
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
                Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
            else
                Lighting.Brightness = 1
                Lighting.GlobalShadows = true
            end
        end)
    end,
})

ESPSettingsTab:CreateSection("🔄 Rejoin & Server")
    local _tg
    _tg = ESPSettingsTab:CreateToggle({
        Name = "🔄 Rejoin Server Sekarang",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
        setupAutoExecuteOnTeleport()
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
        task.spawn(function()
            task.wait(0.5)
            pcall(function() _tg:Set(false) end)
        end)
    end,
})

ESPSettingsTab:CreateToggle({
    Name = "Trade Requests (On/Off)",
    CurrentValue = _G.LianConfig.TradeRequests,
    Callback = function(Value)
        _G.LianConfig.TradeRequests = Value
        saveConfig()
        -- Try to find and toggle trade request remote
        local tradeRemote = getRemote("TradeService", "RE", "SetTradeRequestsEnabled")
        if tradeRemote then
            if tradeRemote:IsA("RemoteEvent") then
                tradeRemote:FireServer(Value)
            elseif tradeRemote:IsA("RemoteFunction") then
                tradeRemote:InvokeServer(Value)
            end
        end
    end,
})

ESPSettingsTab:CreateSection("⚡ Performance")
ESPSettingsTab:CreateSlider({
    Name = "WalkSpeed (16-150)",
    Range = {16, 150},
    Increment = 1,
    Suffix = "ws",
    CurrentValue = _G.LianConfig.WalkSpeedValue or 16,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        _G.LianConfig.WalkSpeedValue = Value
        saveConfig()
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = Value
            end
        end)
    end,
})

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
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = Value
            end
        end)
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

    local _tg
    _tg = RebirthTab:CreateToggle({
        Name = "⚡ Equip Best ke Plot & Jual Semua di Luar Plot Sekarang",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
        equipBestPlotAndSellOutside()
        task.spawn(function()
            task.wait(0.5)
            pcall(function() _tg:Set(false) end)
        end)
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

    local _tg
    _tg = ServerTab:CreateToggle({
        Name = "🔄 Force Hop ke Server Lain Sekarang",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
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
        task.spawn(function()
            task.wait(0.5)
            pcall(function() _tg:Set(false) end)
        end)
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
            footer = { text = "⚡ Lian Hub v6.3 | Anime Dice Telemetry" },
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

    local _tg
    _tg = WebhookTab:CreateToggle({
        Name = "🔔 Test Kirim Webhook Sekarang",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
        sendDiscordWebhook("🔔 Test Webhook Lian Hub", "Koneksi webhook dari akun **" .. LocalPlayer.Name .. "** berhasil!", 65280)
        Rayfield:Notify({ Title = "Webhook Terkirim!", Content = "Cek channel Discord Bubu yaa!", Duration = 3 })
        task.spawn(function()
            task.wait(0.5)
            pcall(function() _tg:Set(false) end)
        end)
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
    CurrentValue = _G.LianConfig.WalkSpeedValue or 16,
    Callback = function(Value)
        _G.LianConfig.WalkSpeedValue = Value
        saveConfig()
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
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not _G.LianConfig.Noclip
            end
        end
    end
end)


-- ═════════════════════════════════════════════════════════════════════
-- 🚀 MASTER 100% DECOUPLED BACKGROUND WORKERS
-- ═════════════════════════════════════════════════════════════════════

end -- close if Window

-- 1. Auto Roll Dice Worker
task.spawn(function()
    local autoRollState = false
    while true do
        if _G.LianConfig.AutoRoll then
            if not autoRollState then
                fire(R.SetAutoRoll, true)
                autoRollState = true
            end
            invoke(R.Roll)
            task.wait(_G.LianConfig.FastRoll and 0.08 or 0.3)
        else
            if autoRollState then
                fire(R.SetAutoRoll, false)
                autoRollState = false
            end
            task.wait(0.5)
        end
    end
end)

-- Auto Unit Grades Worker (aligned with groper99/animedice; behavior unverified — reference obfuscated)
task.spawn(function()
    local cachedGradeRemote = R.QuirkRoll or getRemote("GradeService", "RE", "Roll")
    while true do
        if _G.LianConfig.AutoUnitGrades then
            local gradeRemote = cachedGradeRemote
            if gradeRemote then
                gradeRemote:FireServer()
                -- Protect gating: DISABLED until grade read is implemented.
                -- Firing SetGradeProtected(true) after every roll can lock a bad grade.
                -- TODO: read current grade from DataController before protecting.
                -- if _G.LianConfig.ProtectHighGrades then
                --     local protectRemote = R.QuirkProtect or getRemote("GradeService", "RE", "SetGradeProtected")
                --     if protectRemote then
                --         task.wait(0.3) -- wait for server to assign grade
                --         protectRemote:FireServer(true)
                --     end
                -- end
                if _G.LianConfig.RollGradeOnce then
                    _G.LianConfig.AutoUnitGrades = false
                    saveConfig()
                end
            else
                warn("[LianHub] AutoUnitGrades: no grade remote resolved — check game update")
            end
            task.wait(1.0)
        else
            task.wait(0.5)
        end
    end
end)

-- Auto Buy Dice + Auto Equip Best Dice Worker
task.spawn(function()
    local lastBuyTime = 0
    while true do
        if _G.LianConfig.AutoBuyDice and R.BuyDice then
            if os.clock() - lastBuyTime >= 5 then
                lastBuyTime = os.clock()
                fire(R.BuyDice)
                task.wait(0.5)
                if R.EquipDice then
                    fire(R.EquipDice)
                end
            end
        end
        task.wait(2.0)
    end
end)

-- Auto Quirk Reroll Worker
task.spawn(function()
    while true do
        if _G.LianConfig.AutoQuirk then
            if R.QuirkRoll then
                fire(R.QuirkRoll)
                -- Protect gating: DISABLED until quirk read is implemented.
                -- Firing SetGradeProtected(true) after every roll can lock a bad quirk.
                -- TODO: read current quirk from DataController before protecting.
                -- if _G.LianConfig.ProtectHighGrades then
                --     local protectRemote = R.QuirkProtect or getRemote("GradeService", "RE", "SetGradeProtected")
                --     if protectRemote then
                --         task.wait(0.3) -- wait for server to assign quirk
                --         protectRemote:FireServer(true)
                --     end
                -- end
                task.wait(0.5)
            end
        end
        task.wait(1.0)
    end
end)

-- 2. Auto Roll Halloween Worker (100 Labu vs 500 Labu)
task.spawn(function()
    while true do
        if _G.LianConfig.AutoRollHalloween then
            local opt = _G.LianConfig.HalloweenRollOption or ""
            local rollCount = opt:find("100") and 1 or 5
            invoke(R.PumpkinRoll, rollCount)
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
            local queue = {}
            pcall(function()
                local dc = getDC()
                local inv = (dc and dc.Inventory and dc.Inventory()) or {}
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
            end)
            for _, p in ipairs(queue) do
                if not _G.LianConfig.AutoPotions then break end
                fire(R.Boost, p.key)
                task.wait(0.2)
            end
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
            local canRebirth, curCash = false, 0
            pcall(function()
                canRebirth, curCash = canAffordRebirth()
            end)
            if canRebirth then
                fire(R.Rebirth)
                pcall(function()
                    Rayfield:Notify({ Title = "Rebirth Sukses!", Content = "Uang cukup ($" .. math.floor(curCash) .. "). Rebirth diproses!", Duration = 3 })
                end)
                task.wait(1.5)
                fire(R.EquipBest)
            end
            task.wait(1.5)
        else
            task.wait(1)
        end
    end
end)

-- 5. Rebirth Stats Allocation Worker (Zero Spam — Poin > 0 Baru Up)
task.spawn(function()
    while true do
        if _G.LianConfig.AutoAllocStats and R.AddStat then
            local toAdd = {}
            pcall(function()
                local pts = getAvailableStatPoints()
                if pts > 0 then
                    local prio = _G.LianConfig.RebirthStatPriority or ""
                    local statList = {}
                    if prio:find("Balance") then statList = {"Money", "Luck", "Damage", "Health", "Speed"}
                    elseif prio:find("Money") then statList = {"Money"}
                    elseif prio:find("Luck") then statList = {"Luck"}
                    elseif prio:find("Damage") then statList = {"Damage"}
                    elseif prio:find("Health") then statList = {"Health"}
                    elseif prio:find("Speed") then statList = {"Speed"}
                    end
                    local dc = getDC()
                    local spentT = table.clone((dc and dc.RebirthStats and dc.RebirthStats()) or {})
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
                        table.insert(toAdd, pick)
                    end
                end
            end)
            for _, statName in ipairs(toAdd) do
                fire(R.AddStat, statName)
                task.wait(0.15)
            end
        end
        task.wait(2)
    end
end)

-- 6. Auto Buy Tree Upgrades Worker (Fortune dll di Dekat Dadu)
task.spawn(function()
    while true do
        if _G.LianConfig.AutoBuyTreeUpgrades then
            buyUpgradesTree()
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
            if _G.LianConfig.AutoEquipTowerTeam then
                fire(R.BestTeam)
                task.wait(1)
            end
            local towerName = _G.LianConfig.TowerType
            if _G.LianConfig.SmartTowerAI then
                local towers = {"The Abyss", "Bell Tower", "Attic", "Crypt", "Foyer", "Front Yard"}
                towerName = towers[math.random(1, #towers)]
            end
            if R.PlayTower then
                local resStart = invoke(R.PlayTower, towerName)
                if resStart then
                    task.wait(1)
                    for floor = 1, 50 do
                        if not (_G.LianConfig.SmartTowerAI or _G.LianConfig.AutoTower) then break end
                        local resSeq = invoke(R.FloorTower)
                        if not resSeq or resSeq == "destroyed" then break end
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
            task.wait(5.5)
        else
            task.wait(1)
        end
    end
end)

-- 8. Plot Cash & Level Up Worker
task.spawn(function()
    while true do
        if _G.LianConfig.AutoCollectCash then
            local maxSlots = getMaxPlotSlots()
            for slot = 1, maxSlots do
                if not _G.LianConfig.AutoCollectCash then break end
                fire(R.Collect, slot)
            end
        end
        if _G.LianConfig.AutoLevelUpSlots then
            local maxSlots = getMaxPlotSlots()
            for slot = 1, maxSlots do
                if not _G.LianConfig.AutoLevelUpSlots then break end
                fire(R.LevelSlot, slot)
            end
        end
        task.wait(2)
    end
end)

-- 9. Daily Rewards, Quests, Offline Earnings, Wheel & Codes Worker
task.spawn(function()
    while true do
        if _G.LianConfig.AutoDailyReward then
            fire(R.Daily)
        end
        if _G.LianConfig.AutoClaimOffline then
            fire(R.Offline)
        end
        if _G.LianConfig.AutoLuckySpin then
            fire(R.Spin)
        end
        if _G.LianConfig.AutoRedeemCodes then
            local codes = {"RELEASE", "HALLOWEEN", "LUCK", "UPDATE", "SUB2DEV", "ANIME", "DICE", "PUMPKIN"}
            for _, c in ipairs(codes) do
                fire(R.Code, c)
                task.wait(0.2)
            end
        end
        task.wait(10)
    end
end)

-- 10. Auto Equip Best Plot & Sell Rest Worker
task.spawn(function()
    while true do
        if _G.LianConfig.AutoEquipBestPlotAndSellRest then
            equipBestPlotAndSellOutside()
            task.wait(3.5)
        else
            task.wait(1)
        end
    end
end)

-- 11. Trick or Treat Worker
task.spawn(function()
    while true do
        if _G.LianConfig.AutoTrickOrTreat then
            local map = Workspace:FindFirstChild("Halloween") or Workspace:FindFirstChild("Map")
            local doors = map and (map:FindFirstChild("Doors") or map:FindFirstChild("TrickOrTreat"))
            if doors and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                local oldCFrame = hrp.CFrame
                for _, d in ipairs(doors:GetChildren()) do
                    if not _G.LianConfig.AutoTrickOrTreat then break end
                    if d:IsA("Model") or d:IsA("BasePart") then
                        pcall(function()
                            local pivot = d:GetPivot()
                            hrp.CFrame = pivot * CFrame.new(0, 2, 3)
                        end)
                        task.wait(0.4)
                        fire(R.TrickKnock, d.Name)
                        task.wait(0.2)
                        fire(R.TrickLand, d.Name)
                        task.wait(0.3)
                    end
                end
                pcall(function() hrp.CFrame = oldCFrame end)
            end
            task.wait(5)
        else
            task.wait(1)
        end
    end
end)

-- 12. Halloween Event Quests Worker
task.spawn(function()
    while true do
        if _G.LianConfig.AutoHalloweenQuestClaim then
            local floors = {"The Abyss", "Bell Tower", "Attic", "Crypt", "Foyer", "Front Yard"}
            for _, f in ipairs(floors) do
                fire(R.HalloweenQuest, "Daily", f)
            end
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
            fire(R.HalloweenPath)
            task.wait(6)
        else
            task.wait(1)
        end
    end
end)

-- 14. Auto Trade Feeder Listener
pcall(function()
    if R.TradeEvent then
        R.TradeEvent.OnClientEvent:Connect(function(event, data)
            task.spawn(function()
                if not _G.LianConfig.AutoTradeFeeder then return end
                local master = _G.LianConfig.MasterAccount
                if not master or master == "" then return end
                if event == "Request" and data and data.player then
                    if data.player.Name:lower() == master:lower() then
                        fire(R.TradeResp, true)
                        Rayfield:Notify({ Title = "Trade Diterima!", Content = "Trade otomatis dari Akun Utama: " .. data.player.Name, Duration = 4 })
                    else
                        fire(R.TradeResp, false)
                    end
                elseif event == "Started" then
                    task.wait(0.5)
                    local dc = getDC()
                    local inv = (dc and dc.Inventory and dc.Inventory()) or {}
                    for key, unit in pairs(inv) do
                        local rarity = unit.rarity or (unit.attrs and unit.attrs.rarity) or ""
                        if (_G.LianConfig.TradeMythic and rarity == "Mythic") or (_G.LianConfig.TradeSecret and rarity == "Secret") then
                            fire(R.TradeOffer, key, 1)
                            task.wait(0.2)
                        end
                    end
                    task.wait(0.5)
                    fire(R.TradeAdv)
                    task.wait(3.2)
                    fire(R.TradeAdv)
                end
            end)
        end)
    end
end)

-- 15. Server Luck Hopper Worker
task.spawn(function()
    while true do
        if _G.LianConfig.ServerLuckHop then
            local dc = getDC()
            local weather = (dc and dc.Weather and dc.Weather()) or ""
            if weather ~= "Bloodmoon" and weather ~= "Eclipse" and weather ~= "Full Moon" then
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
            end
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

pcall(function()
    Rayfield:Notify({
        Title = "⚡ Lian Hub v6.3 Ready!",
        Content = "Master Exploit Suite aktif! Gunakan tombol [⚡ Lian Hub] atau RightControl untuk hide/show.",
        Duration = 5
    })
end)
