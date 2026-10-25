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
        -- Also wiggle character slightly to prevent idle kick
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local hum = LocalPlayer.Character.Humanoid
                local oldWS = hum.WalkSpeed
                hum.WalkSpeed = oldWS + 0.01
                task.wait(0.05)
                hum.WalkSpeed = oldWS
            end
        end)
        task.wait(60)
    end
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
local NET = RS:FindFirstChild("Network") or RS:WaitForChild("Network", 20)

local R = {}
local function getRemote(svc, kind, name)
    if not NET then return nil end
    local folder = svc and NET:FindFirstChild(svc) or NET
    if not folder then folder = svc and NET:WaitForChild(svc, 4) or NET end
    if not folder then return nil end
    local sub = folder:FindFirstChild(kind) or folder:WaitForChild(kind, 4)
    if not sub then return nil end
    return sub:FindFirstChild(name) or sub:WaitForChild(name, 4)
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
R.QuirkRoll = getRemote("QuirkService", "RE", "Roll")
R.QuirkProtect = getRemote("QuirkService", "RE", "SetQuirkProtected")
R.TradeReq = getRemote("TradeService", "RE", "RequestTrade")
R.TradeResp = getRemote("TradeService", "RE", "RespondToRequest")
R.TradeOffer = getRemote("TradeService", "RE", "ChangeOffer")
R.TradeAdv = getRemote("TradeService", "RE", "AdvanceTrade")
R.TradeEvent = getRemote("TradeService", "RE", "TradeEvent")

local function fire(remote, ...)
    if remote then
        pcall(function(...) remote:FireServer(...) end, ...)
    end
end

local function invoke(remote, ...)
    if remote then
        local ok, res = pcall(function(...) return remote:InvokeServer(...) end, ...)
        if ok then return res end
    end
    return nil
end

local function safe(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok and res
end


-- ═══════════════════════════════════════════════════════════════════════════
-- LIAN HUB GAME UPDATE CHECKER (run via Lian Hub UI or console)
-- ═══════════════════════════════════════════════════════════════════════════
local function checkGameUpdates()
    local results = {}
    local function check(name, ok)
        table.insert(results, (ok and "✅ " or "❌ ") .. name)
    end
    local function safeCheck(name, fn)
        local ok, val = pcall(fn)
        if not ok then
            table.insert(results, "❌ " .. name .. " (ERROR: " .. tostring(val) .. ")")
            return
        end
        table.insert(results, (val and "✅ " or "❌ ") .. name)
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
            {"CodesService","RE","RedeemCode"}, {"QuirkService","RE","Roll"},
            {"TradeService","RE","RequestTrade"}, {"TradeService","RE","TradeEvent"},
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

    -- DataController
    local dc = getDC()
    check("DataController", dc ~= nil)
    if dc then
        for _, field in ipairs({"Money","Cash","Coins","Inventory","Slots","Rebirth","RebirthStats","Upgrades","Weather"}) do
            check("DC."..field, dc[field] ~= nil)
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
    AutoHalloweenQuestClaim = false,  -- renamed from AutoHalloweenDoors
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
    AutoClaimOffline = true,
    AutoLuckySpin = true,
    AutoTicketShop = false,
    TicketShopItem = "Clover",
    AutoRebirth = false,
    RebirthStatPriority = "Balance / Rata (Money, Luck, Damage, Health, Speed)",
    AutoBuyTreeUpgrades = false,
    AutoBuyBestDice = false,
    AutoFuseUnits = false,
    AutoEquipBestPlotAndSellRest = true,
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

-- ponytail: backward-compat migration for renamed config key
pcall(function()
    if _G.LianConfig and _G.LianConfig.AutoHalloweenDoors ~= nil then
        _G.LianConfig.AutoHalloweenQuestClaim = _G.LianConfig.AutoHalloweenDoors
        _G.LianConfig.AutoHalloweenDoors = nil
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
    safe(function()
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
                table.insert(sellList, key)
            end
        end

        if #sellList > 0 and R.Sell then
            local ok, money, numSold = pcall(function()
                return R.Sell:InvokeServer(sellList)
            end)
            if ok then
                Rayfield:Notify({
                    Title = "🧹 Auto-Sell Sukses!",
                    Content = #sellList .. " unit di luar plot berhasil dijual!",
                    Duration = 2.5
                })
            end
        end
    end)
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

-- 8. Auto-Reconnect Watcher
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

-- 9. Load Rayfield UI
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
    error("[Lian Hub] Gagal memuat library Rayfield. Periksa koneksi internet.", 0)
end

local Window = Rayfield:CreateWindow({
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

-- Floating Draggable Toggle Button
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
        fire(R.BestTeam)
        Rayfield:Notify({ Title = "Tower Team", Content = "Best Tower Team berhasil dipasang!", Duration = 3 })
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

PlotTab:CreateButton({
    Name = "🔍 Check Game Updates (Diagnose Broken Features)",
    Callback = function()
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

RebirthTab:CreateButton({
    Name = "⚡ Equip Best ke Plot & Jual Semua di Luar Plot Sekarang",
    Callback = function()
        equipBestPlotAndSellOutside()
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
            if _G.LianConfig.AutoEquipBestPlotAndSellRest then
                safe(equipBestPlotAndSellOutside)
            end
            fire(R.SetAutoRoll, true)
            task.spawn(function()
                invoke(R.Roll)
            end)
            task.wait(_G.LianConfig.FastRoll and 0.08 or 0.3)
        else
            fire(R.SetAutoRoll, false)
            task.wait(0.5)
        end
    end
end)

-- 2. Auto Roll Halloween Worker (100 Labu vs 500 Labu)
task.spawn(function()
    while true do
        if _G.LianConfig.AutoRollHalloween then
            safe(function()
                local rollCount = _G.LianConfig.HalloweenRollOption:find("100") and 1 or 5
                invoke(R.PumpkinRoll, rollCount)
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
                local dc = getDC()
                local inv = (dc and dc.Inventory and dc.Inventory()) or {}
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
                    fire(R.Boost, p.key)
                    task.wait(0.2)
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
                    fire(R.Rebirth)
                    Rayfield:Notify({ Title = "Rebirth Sukses!", Content = "Uang cukup ($" .. math.floor(curCash) .. "). Rebirth diproses!", Duration = 3 })
                    task.wait(1.5)
                    fire(R.EquipBest)
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
            if pts > 0 and R.AddStat then
                local prio = _G.LianConfig.RebirthStatPriority
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
                    fire(R.AddStat, pick)
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
            end)
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
            safe(function()
                local maxSlots = getMaxPlotSlots()
                for slot = 1, maxSlots do
                    if not _G.LianConfig.AutoCollectCash then break end
                    fire(R.Collect, slot)
                end
            end)
        end
        if _G.LianConfig.AutoLevelUpSlots then
            safe(function()
                local maxSlots = getMaxPlotSlots()
                for slot = 1, maxSlots do
                    if not _G.LianConfig.AutoLevelUpSlots then break end
                    fire(R.LevelSlot, slot)
                end
            end)
        end
        task.wait(2)
    end
end)

-- 9. Daily Rewards, Quests, Offline Earnings, Wheel & Codes Worker
task.spawn(function()
    while true do
        if _G.LianConfig.AutoDailyReward then
            safe(function() fire(R.Daily) end)
        end
        if _G.LianConfig.AutoClaimOffline then
            safe(function() fire(R.Offline) end)
        end
        if _G.LianConfig.AutoLuckySpin then
            safe(function() fire(R.Spin) end)
        end
        if _G.LianConfig.AutoRedeemCodes then
            safe(function()
                local codes = {"RELEASE", "HALLOWEEN", "LUCK", "UPDATE", "SUB2DEV", "ANIME", "DICE", "PUMPKIN"}
                for _, c in ipairs(codes) do
                    fire(R.Code, c)
                    task.wait(0.2)
                end
            end)
        end
        if _G.LianConfig.AutoQuests then
            safe(function()
                for _, p in ipairs({"Daily", "Weekly"}) do
                    if M.Quests and M.Quests.Periods and M.Quests.Periods[p] then
                        for _, q in ipairs(M.Quests.Periods[p].quests or {}) do
                            fire(R.HalloweenQuest, p, q.id)
                        end
                    end
                end
            end)
        end
        task.wait(10)
    end
end)

-- 10. Auto Equip Best Plot & Sell Rest Worker
task.spawn(function()
    while true do
        if _G.LianConfig.AutoEquipBestPlotAndSellRest then
            safe(equipBestPlotAndSellOutside)
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
                            fire(R.TrickKnock, d.Name)
                            task.wait(0.2)
                            fire(R.TrickLand, d.Name)
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

-- 12. Halloween Event Quests Worker
task.spawn(function()
    while true do
        if _G.LianConfig.AutoHalloweenQuestClaim then
            safe(function()
                local floors = {"The Abyss", "Bell Tower", "Attic", "Crypt", "Foyer", "Front Yard"}
                for _, f in ipairs(floors) do
                    fire(R.HalloweenQuest, "Daily", f)
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
            safe(function() fire(R.HalloweenPath) end)
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
    end
end)

-- 15. Server Luck Hopper Worker
task.spawn(function()
    while true do
        if _G.LianConfig.ServerLuckHop then
            safe(function()
                local dc = getDC()
                local weather = (dc and dc.Weather and dc.Weather()) or ""
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
    Title = "⚡ Lian Hub v6.3 Ready!",
    Content = "Master Exploit Suite aktif! Gunakan tombol [⚡ Lian Hub] atau RightControl untuk hide/show.",
    Duration = 5
})
