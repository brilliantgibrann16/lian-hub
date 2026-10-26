-- Anime Dice Manual Spy v2
-- No hookmetamethod needed — works on all executors including Solara
-- Usage: inject → click buttons → check UI log or F9 console

print("[LianSpy] Starting... executor: " .. (identifyexecutor and identifyexecutor() or "unknown"))

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Timeout-based load check
local _loadT = os.clock()
while not game:IsLoaded() and os.clock() - _loadT < 15 do task.wait(0.2) end
if not game:IsLoaded() then warn("[LianSpy] game not fully loaded after 15s, proceeding anyway") end

local logs = {}
local function log(msg)
    table.insert(logs, msg)
    print(msg)
end

-- GUI Parent
local _guiParent = nil
if type(gethui) == "function" then pcall(function() _guiParent = gethui() end) end
if not _guiParent then pcall(function() _guiParent = game.CoreGui end) end
if not _guiParent then pcall(function() _guiParent = LocalPlayer:WaitForChild("PlayerGui", 5) end) end

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LianSpyManual"
ScreenGui.ResetOnSpawn = false
if _guiParent then ScreenGui.Parent = _guiParent end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 620, 0, 500)
Frame.Position = UDim2.new(0.5, -310, 0.5, -250)
Frame.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "Lian Spy - Manual Scanner (Solara Compatible)"
Title.TextColor3 = Color3.fromRGB(0, 230, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(1, -20, 0, 320)
TextBox.Position = UDim2.new(0, 10, 0, 40)
TextBox.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
TextBox.BorderSizePixel = 0
TextBox.TextColor3 = Color3.fromRGB(230, 230, 230)
TextBox.Font = Enum.Font.Code
TextBox.TextSize = 10
TextBox.ClearTextOnFocus = false
TextBox.TextEditable = false
TextBox.TextWrapped = true
TextBox.MultiLine = true
TextBox.TextXAlignment = Enum.TextXAlignment.Left
TextBox.TextYAlignment = Enum.TextYAlignment.Top
TextBox.Text = "=== Click a button below to scan ===\n"
TextBox.Parent = Frame

local function addLine(text)
    -- Don't update TextBox on every line (causes lag). Collect in logs, update at end.
    table.insert(logs, text)
    print(text)
end

local function flushLog()
    TextBox.Text = table.concat(logs, "\n")
end

local function clearLog()
    TextBox.Text = ""
    logs = {}
end

local function createBtn(name, pos, size, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = size
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.Text = name
    btn.Parent = Frame
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function()
        btn.Text = "Scanning..."
        callback()
        btn.Text = name
        flushLog()
    end)
    return btn
end

-- Scan 1: Framework modules
createBtn("Framework", UDim2.new(0, 10, 0, 370), UDim2.new(0, 140, 0, 28), Color3.fromRGB(0, 160, 240), function()
    clearLog()
    addLine("=== FRAMEWORK MODULES ===")
    local fw = RS:FindFirstChild("Framework")
    if fw then
        for _, feat in ipairs(fw:GetChildren()) do
            addLine("Feature: " .. feat.Name)
            for _, mod in ipairs(feat:GetDescendants()) do
                if mod:IsA("ModuleScript") then
                    addLine("   Module: " .. mod:GetFullName())
                end
            end
        end
    else
        addLine("Framework not found!")
    end
end)

-- Scan 2: Network remotes
createBtn("Remotes", UDim2.new(0, 160, 0, 370), UDim2.new(0, 140, 0, 28), Color3.fromRGB(0, 160, 240), function()
    clearLog()
    addLine("=== NETWORK REMOTES ===")
    local net = RS:FindFirstChild("Network")
    if net then
        for _, svc in ipairs(net:GetChildren()) do
            addLine("Service: " .. svc.Name .. " (" .. svc.ClassName .. ")")
            for _, kind in ipairs(svc:GetChildren()) do
                addLine("   Kind: " .. kind.Name .. " (" .. kind.ClassName .. ")")
                for _, remote in ipairs(kind:GetChildren()) do
                    addLine("      " .. remote.ClassName .. ": " .. remote.Name)
                end
            end
        end
    else
        addLine("Network not found!")
    end
end)

-- Scan 3: DataController state
createBtn("DataCtrl", UDim2.new(0, 310, 0, 370), UDim2.new(0, 140, 0, 28), Color3.fromRGB(0, 160, 240), function()
    clearLog()
    addLine("=== DATA CONTROLLER ===")
    pcall(function()
        local DC = require(RS.Framework.Features.Data.DataController)
        for k, v in pairs(DC) do
            if type(v) == "function" then
                local ok, res = pcall(v)
                if ok then
                    if type(res) == "string" or type(res) == "number" or type(res) == "boolean" then
                        addLine(string.format("   %s = %s", tostring(k), tostring(res)))
                    elseif type(res) == "table" then
                        local count = 0
                        for _ in pairs(res) do count = count + 1 end
                        addLine(string.format("   %s = table (%d items)", tostring(k), count))
                    end
                end
            end
        end
    end)
end)

-- Scan 4: Workspace teleport destinations
createBtn("Workspace", UDim2.new(0, 460, 0, 370), UDim2.new(0, 140, 0, 28), Color3.fromRGB(0, 160, 240), function()
    clearLog()
    addLine("=== WORKSPACE TELEPORT DESTINATIONS ===")
    for _, name in ipairs({"DiceShop", "Rebirth", "Fusing", "Quests", "Backpack", "Plot", "Plots", "Map", "Halloween"}) do
        local obj = workspace:FindFirstChild(name)
        addLine(string.format("   %s: %s", name, obj and obj:GetFullName() or "MISSING"))
    end
    addLine("")
    addLine("=== Map folder children (teleport destinations) ===")
    local map = workspace:FindFirstChild("Map")
    if map then
        for _, child in ipairs(map:GetChildren()) do
            addLine("   " .. child.Name .. " (" .. child.ClassName .. ")")
        end
    else
        addLine("   Map folder not found!")
    end
    addLine("")
    addLine("=== Plots folder children ===")
    local plots = workspace:FindFirstChild("Plots")
    if plots then
        for _, p in ipairs(plots:GetChildren()) do
            addLine("   " .. p.Name .. " (" .. p.ClassName .. ")")
            local sign = p:FindFirstChild("Sign") or p:FindFirstChild("PlotSign")
            if sign then
                local bb = sign:FindFirstChildWhichIsA("BillboardGui", true)
                if bb then
                    local pn = bb:FindFirstChild("PlayerName")
                    if pn then addLine("      PlayerName: " .. tostring(pn.Text)) end
                end
            end
            local owner = p:FindFirstChild("Owner")
            if owner then addLine("      Owner: " .. tostring(owner.Value)) end
            if p:GetAttribute("OwnerId") then addLine("      OwnerId: " .. tostring(p:GetAttribute("OwnerId"))) end
        end
    else
        addLine("   Plots folder not found!")
    end
end)

-- Scan 5: PlayerGui
createBtn("PlayerGui", UDim2.new(0, 10, 0, 405), UDim2.new(0, 140, 0, 28), Color3.fromRGB(0, 160, 240), function()
    clearLog()
    addLine("=== PLAYER GUI ===")
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        for _, v in ipairs(pg:GetChildren()) do
            addLine("   " .. v.Name .. " (" .. v.ClassName .. ")")
        end
    else
        addLine("   PlayerGui not found!")
    end
end)

-- Scan 6: Test Roll remote
createBtn("Test Roll", UDim2.new(0, 160, 0, 405), UDim2.new(0, 140, 0, 28), Color3.fromRGB(255, 140, 0), function()
    clearLog()
    addLine("=== TEST ROLL REMOTE ===")
    local net = RS:FindFirstChild("Network")
    if net then
        local rollSvc = net:FindFirstChild("RollService")
        if rollSvc then
            local rf = rollSvc:FindFirstChild("RF")
            if rf then
                local rollDice = rf:FindFirstChild("RollDice")
                if rollDice then
                    addLine("Found RollDice remote: " .. rollDice:GetFullName())
                    local ok, res = pcall(function() return rollDice:InvokeServer() end)
                    addLine("InvokeServer result: " .. tostring(ok) .. " | " .. tostring(res))
                else
                    addLine("RollDice not found in RF!")
                end
            else
                addLine("RF folder not found in RollService!")
            end
        else
            addLine("RollService not found!")
        end
    else
        addLine("Network not found!")
    end
end)

-- Scan 7: Test Trade remote
createBtn("Test Trade", UDim2.new(0, 310, 0, 405), UDim2.new(0, 140, 0, 28), Color3.fromRGB(255, 140, 0), function()
    clearLog()
    addLine("=== TEST TRADE REMOTE ===")
    local net = RS:FindFirstChild("Network")
    if net then
        local tradeSvc = net:FindFirstChild("TradeService")
        if tradeSvc then
            addLine("TradeService found!")
            for _, kind in ipairs(tradeSvc:GetChildren()) do
                addLine("   " .. kind.Name .. " (" .. kind.ClassName .. ")")
                for _, remote in ipairs(kind:GetChildren()) do
                    addLine("      " .. remote.ClassName .. ": " .. remote.Name)
                end
            end
        else
            addLine("TradeService not found!")
        end
    else
        addLine("Network not found!")
    end
end)

-- Scan 8: Test Unit Grades remote
createBtn("Test Grades", UDim2.new(0, 460, 0, 405), UDim2.new(0, 140, 0, 28), Color3.fromRGB(255, 140, 0), function()
    clearLog()
    addLine("=== TEST UNIT GRADES REMOTE ===")
    local net = RS:FindFirstChild("Network")
    if net then
        for _, svcName in ipairs({"UnitService", "GradeService", "UnitGradingService"}) do
            local svc = net:FindFirstChild(svcName)
            if svc then
                addLine("Found: " .. svcName)
                for _, kind in ipairs(svc:GetChildren()) do
                    addLine("   " .. kind.Name .. " (" .. kind.ClassName .. ")")
                    for _, remote in ipairs(kind:GetChildren()) do
                        addLine("      " .. remote.ClassName .. ": " .. remote.Name)
                    end
                end
            else
                addLine(svcName .. ": NOT FOUND")
            end
        end
    else
        addLine("Network not found!")
    end
end)

-- Copy button (non-blocking)
createBtn("Copy Log", UDim2.new(0, 10, 0, 440), UDim2.new(0, 140, 0, 28), Color3.fromRGB(0, 200, 100), function()
    local fullLog = table.concat(logs, "\n")
    addLine("Copying... (check clipboard or LianSpy_ManualDump.txt)")
    task.spawn(function()
        local ok1 = pcall(function()
            if setclipboard then setclipboard(fullLog) end
        end)
        local ok2 = pcall(function()
            if writefile then writefile("LianSpy_ManualDump.txt", fullLog) end
        end)
        addLine("Copy done. clipboard=" .. tostring(ok1) .. " file=" .. tostring(ok2))
    end)
end)

-- Close button
createBtn("Close", UDim2.new(0, 160, 0, 440), UDim2.new(0, 140, 0, 28), Color3.fromRGB(200, 50, 50), function()
    ScreenGui:Destroy()
end)

log("[LianSpy] Manual Scanner ready! Click buttons to scan.")