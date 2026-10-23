--[[
    ═════════════════════════════════════════════════════════════════════════
    🔍 LIAN SPY — REAL-TIME REMOTE DETECTIVE & GAME INVESTIGATOR 🔍
    Author : Lian (@brilliantgibrann16)
    Fungsi : Mencatat SEMUA remote saat Bubu klik Collect, Daily, Quest
    ═════════════════════════════════════════════════════════════════════════
--]]

repeat task.wait(0.2) until game:IsLoaded()

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local logs = {}
local discoveredRemotes = {}

-- 1. SCAN SEMUA REMOTE DI REPLICATEDSTORAGE
table.insert(logs, "═══════════════════════════════════════════════════════")
table.insert(logs, "📍 DISCOVERED REMOTES IN REPLICATEDSTORAGE:")
table.insert(logs, "═══════════════════════════════════════════════════════")

for _, obj in ipairs(RS:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        local line = string.format("[%s] %s", obj.ClassName, obj:GetFullName())
        table.insert(discoveredRemotes, line)
        table.insert(logs, line)
    end
end

table.insert(logs, "")
table.insert(logs, "═══════════════════════════════════════════════════════")
table.insert(logs, "🎯 LIVE REMOTE SPY (KLIK TOMBOL GAME SEKARANG!):")
table.insert(logs, "═══════════════════════════════════════════════════════")

-- 2. CREATE IN-GAME GUI CONSOLE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LianSpyConsole"
ScreenGui.ResetOnSpawn = false
pcall(function()
    ScreenGui.Parent = (type(gethui) == "function" and gethui()) or game.CoreGui
end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 520, 0, 360)
Frame.Position = UDim2.new(0.5, -260, 0.5, -180)
Frame.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
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
Title.Text = "🔍 Lian Spy Console — Klik Collect/Daily/Quest di Game!"
Title.TextColor3 = Color3.fromRGB(0, 220, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -85)
Scroll.Position = UDim2.new(0, 10, 0, 40)
Scroll.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
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
TextBox.Text = table.concat(logs, "\n")
TextBox.Parent = Scroll

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0.48, 0, 0, 32)
CopyBtn.Position = UDim2.new(0, 10, 1, -38)
CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 230)
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 12
CopyBtn.Text = "📋 Copy Semua Log ke Clipboard"
CopyBtn.Parent = Frame
local BtnCorner1 = Instance.new("UICorner", CopyBtn)
BtnCorner1.CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.48, 0, 0, 32)
CloseBtn.Position = UDim2.new(0.52, 0, 1, -38)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Text = "❌ Tutup Console"
CloseBtn.Parent = Frame
local BtnCorner2 = Instance.new("UICorner", CloseBtn)
BtnCorner2.CornerRadius = UDim.new(0, 6)

local function updateUI()
    TextBox.Text = table.concat(logs, "\n")
    pcall(function()
        if setclipboard then setclipboard(TextBox.Text) end
        if writefile then writefile("LianSpy_AnimeDice.txt", TextBox.Text) end
    end)
end

CopyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(TextBox.Text)
        CopyBtn.Text = "✅ Tersalin ke Clipboard!"
        task.wait(1.5)
        CopyBtn.Text = "📋 Copy Semua Log ke Clipboard"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- 3. HOOK METAMETHOD (__namecall) UNTUK MENANGKAP KLIK USER
local function serializeArg(val)
    local t = typeof(val)
    if t == "string" then
        return string.format("%q", val)
    elseif t == "number" or t == "boolean" then
        return tostring(val)
    elseif t == "Instance" then
        return val:GetFullName()
    elseif t == "table" then
        local ok, json = pcall(function() return HttpService:JSONEncode(val) end)
        return ok and json or "{table}"
    else
        return tostring(val)
    end
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if (method == "FireServer" or method == "InvokeServer") and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
        -- Abaikan remote kamera / default movement roblox yang nyampah
        local name = self.Name
        if name ~= "SetPlayerBlockList" and name ~= "UpdateMouseData" and not self:IsDescendantOf(LocalPlayer.Character) then
            local strArgs = {}
            for i, a in ipairs(args) do
                table.insert(strArgs, serializeArg(a))
            end
            local logLine = string.format("⚡ [%s] %s:%s(%s)", os.date("%X"), self:GetFullName(), method, table.concat(strArgs, ", "))
            table.insert(logs, logLine)
            updateUI()
        end
    end
    
    return oldNamecall(self, ...)
end)

updateUI()
print("[LianSpy] Active and listening to all remotes!")
