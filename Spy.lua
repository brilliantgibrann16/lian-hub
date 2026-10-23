--[[
    ═════════════════════════════════════════════════════════════════════════
    🔍 LIAN SPY v3 — LIVE ACTION SNIFFER & FRAMEWORK DECODER 🔍
    Author : Lian (@brilliantgibrann16)
    Tujuan : Menangkap persis argumen Roll, Potion, Tower, Event, & Shop!
    ═════════════════════════════════════════════════════════════════════════
--]]

repeat task.wait(0.2) until game:IsLoaded()

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local logs = {}
local liveLogs = {}

local function addLog(str)
    table.insert(logs, str)
end

local function addLiveLog(str)
    table.insert(liveLogs, 1, str) -- Taruh paling atas
    if #liveLogs > 50 then table.remove(liveLogs) end
end

-- 1. DUMP DAFTAR CONFIG FRAMEWORK (DICE, POTIONS, TOWERS, WEATHER, HALLOWEEN)
addLog("═══════════════════════════════════════════════════════")
addLog("📦 LIAN SPY: DECODING GAME CONFIGS (FRAMEWORK)")
addLog("═══════════════════════════════════════════════════════")

pcall(function()
    local fw = RS:FindFirstChild("Framework")
    if fw and fw:FindFirstChild("Features") then
        for _, feature in ipairs(fw.Features:GetChildren()) do
            addLog("📁 Feature: " .. feature.Name)
            for _, mod in ipairs(feature:GetDescendants()) do
                if mod:IsA("ModuleScript") and mod.Name:find("Config") then
                    local ok, cfg = pcall(require, mod)
                    if ok and type(cfg) == "table" then
                        addLog(string.format("   ⚙️ Config: %s", mod:GetFullName()))
                        local keys = {}
                        for k, _ in pairs(cfg) do
                            table.insert(keys, tostring(k))
                        end
                        addLog("      Keys: " .. table.concat(keys, ", "))
                    end
                end
            end
        end
    end
end)

-- 2. DUMP DATA CONTROLLER STATE (CURRENT WEATHER, ROLL STATE, BOOSTS)
addLog("\n═══════════════════════════════════════════════════════")
addLog("📊 CURRENT PLAYER STATE (DATA CONTROLLER)")
addLog("═══════════════════════════════════════════════════════")

pcall(function()
    local DC = require(RS.Framework.Features.Data.DataController)
    for k, v in pairs(DC) do
        if type(v) == "function" then
            local ok, res = pcall(v)
            if ok and (type(res) == "string" or type(res) == "number" or type(res) == "boolean") then
                addLog(string.format("   • %s = %s", tostring(k), tostring(res)))
            elseif ok and type(res) == "table" then
                local count = 0
                for _ in pairs(res) do count = count + 1 end
                addLog(string.format("   • %s = table (items: %d)", tostring(k), count))
            end
        end
    end
end)

-- 3. IN-GAME FLOATING HUD UNTUK REAL-TIME ACTION SNIFFING
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LianSpyV3"
ScreenGui.ResetOnSpawn = false
pcall(function()
    ScreenGui.Parent = (type(gethui) == "function" and gethui()) or game.CoreGui
end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 580, 0, 420)
Frame.Position = UDim2.new(0.5, -290, 0.5, -210)
Frame.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "⚡ LIAN SPY v3 — LIVE ACTION SNIFFER (Klik Apapun di Game!)"
Title.TextColor3 = Color3.fromRGB(0, 230, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

local StatusBadge = Instance.new("TextLabel")
StatusBadge.Size = UDim2.new(1, -20, 0, 22)
StatusBadge.Position = UDim2.new(0, 10, 0, 38)
StatusBadge.BackgroundColor3 = Color3.fromRGB(24, 30, 45)
StatusBadge.TextColor3 = Color3.fromRGB(180, 255, 180)
StatusBadge.Font = Enum.Font.Code
StatusBadge.TextSize = 11
StatusBadge.Text = "Status: Menunggu klik Bubu... (Coba klik Roll / Potion / Tower / Shop)"
StatusBadge.Parent = Frame
local BadgeCorner = Instance.new("UICorner", StatusBadge)
BadgeCorner.CornerRadius = UDim.new(0, 4)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -115)
Scroll.Position = UDim2.new(0, 10, 0, 65)
Scroll.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
Scroll.BorderSizePixel = 0
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ScrollBarThickness = 6
Scroll.Parent = Frame

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(1, -10, 1, 0)
TextBox.Position = UDim2.new(0, 5, 0, 5)
TextBox.BackgroundTransparency = 1
TextBox.TextColor3 = Color3.fromRGB(230, 230, 230)
TextBox.Font = Enum.Font.Code
TextBox.TextSize = 11
TextBox.ClearTextOnFocus = false
TextBox.TextEditable = false
TextBox.TextWrapped = true
TextBox.MultiLine = true
TextBox.TextXAlignment = Enum.TextXAlignment.Left
TextBox.TextYAlignment = Enum.TextYAlignment.Top
TextBox.Text = "=== [ LIVE REMOTE CAPTURES AKAN MUNCUL DI SINI SECARA INSTAN ] ===\n"
TextBox.Parent = Scroll

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0.48, 0, 0, 34)
CopyBtn.Position = UDim2.new(0, 10, 1, -42)
CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 240)
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 12
CopyBtn.Text = "📋 Copy Semua Log (Static + Live)"
CopyBtn.Parent = Frame
local BtnCorner1 = Instance.new("UICorner", CopyBtn)
BtnCorner1.CornerRadius = UDim.new(0, 6)

local TestRollBtn = Instance.new("TextButton")
TestRollBtn.Size = UDim2.new(0.48, 0, 0, 34)
TestRollBtn.Position = UDim2.new(0.52, 0, 1, -42)
TestRollBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
TestRollBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TestRollBtn.Font = Enum.Font.GothamBold
TestRollBtn.TextSize = 12
TestRollBtn.Text = "🧪 Test Panggil Roll Remote"
TestRollBtn.Parent = Frame
local BtnCorner2 = Instance.new("UICorner", TestRollBtn)
BtnCorner2.CornerRadius = UDim.new(0, 6)

local function getFullLog()
    local res = {}
    table.insert(res, "═══════════════════════════════════════════════════════")
    table.insert(res, "🎯 LIVE REMOTE CLICKS CAPTURED BY LIAN SPY:")
    table.insert(res, "═══════════════════════════════════════════════════════")
    for _, l in ipairs(liveLogs) do table.insert(res, l) end
    table.insert(res, "\n")
    for _, l in ipairs(logs) do table.insert(res, l) end
    return table.concat(res, "\n")
end

local function updateUI(latest)
    if latest then
        StatusBadge.Text = "Tertangkap: " .. latest:sub(1, 60) .. "..."
    end
    TextBox.Text = table.concat(liveLogs, "\n")
    pcall(function()
        if setclipboard then setclipboard(getFullLog()) end
        if writefile then writefile("LianSpy_LiveDump.txt", getFullLog()) end
    end)
end

CopyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(getFullLog())
        CopyBtn.Text = "✅ Tersalin Lengkap!"
        task.wait(1.5)
        CopyBtn.Text = "📋 Copy Semua Log (Static + Live)"
    end
end)

-- Tombol Percobaan Roll Mandiri
TestRollBtn.MouseButton1Click:Connect(function()
    TestRollBtn.Text = "Testing..."
    local ok1, err1 = pcall(function()
        RS.Network.RollService.RE.SetAutoRoll:FireServer(true)
    end)
    local ok2, err2 = pcall(function()
        return RS.Network.RollService.RF.RollDice:InvokeServer()
    end)
    local msg = string.format("Test: SetAutoRoll=%s (%s) | RollDice=%s (%s)", tostring(ok1), tostring(err1), tostring(ok2), tostring(err2))
    addLiveLog("🧪 [MANUAL TEST] " .. msg)
    updateUI(msg)
    TestRollBtn.Text = "🧪 Test Panggil Roll Remote"
end)

-- 4. ULTRA-DETAILED NAME-CALL & INVOKE HOOK
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if (method == "FireServer" or method == "InvokeServer") and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
        local name = self.Name
        -- Abaikan noise
        if name ~= "SetPlayerBlockList" and name ~= "UpdateMouseData" and not self:IsDescendantOf(LocalPlayer.Character) then
            local strArgs = {}
            for i, a in ipairs(args) do
                local t = typeof(a)
                if t == "string" then
                    table.insert(strArgs, string.format("%q", a))
                elseif t == "number" or t == "boolean" then
                    table.insert(strArgs, tostring(a))
                elseif t == "table" then
                    local okJ, j = pcall(function() return HttpService:JSONEncode(a) end)
                    table.insert(strArgs, okJ and j or "{table}")
                else
                    table.insert(strArgs, tostring(a))
                end
            end
            local line = string.format("[%s] %s:%s(%s)", os.date("%X"), self:GetFullName(), method, table.concat(strArgs, ", "))
            addLiveLog(line)
            updateUI(self.Name)
        end
    end
    
    return oldNamecall(self, ...)
end)

print("[LianSpy v3] Live Action Sniffer is ready! Click actions in-game now.")
