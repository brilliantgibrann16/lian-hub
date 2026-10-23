--[[
    ═════════════════════════════════════════════════════════════════════════
    🔍 LIAN SPY v2 — INSTANT AUTO SCANNER & REMOTE DETECTIVE 🔍
    Author : Lian (@brilliantgibrann16)
    Fitur  : Scan otomatis semua Remote & UI Daily/Quest/Cash tanpa perlu klik!
    ═════════════════════════════════════════════════════════════════════════
--]]

repeat task.wait(0.2) until game:IsLoaded()

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local logs = {}

local function addLog(str)
    table.insert(logs, str)
end

addLog("═══════════════════════════════════════════════════════")
addLog("⚡ LIAN SPY: AUTO-SCANNING REPLICATEDSTORAGE & REMOTES")
addLog("═══════════════════════════════════════════════════════")

-- 1. SCAN SEMUA REMOTE EVENT & FUNCTION DI GAME
local remoteCount = 0
for _, obj in ipairs(RS:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        remoteCount = remoteCount + 1
        addLog(string.format("[%s] %s", obj.ClassName, obj:GetFullName()))
    end
end
addLog(string.format("--> Total Remotes Ditemukan: %d\n", remoteCount))

-- 2. SCAN UI PLAYERGUI TERKAIT DAILY / QUEST / CASH / REWARD
addLog("═══════════════════════════════════════════════════════")
addLog("🎯 SCANNING PLAYERGUI (DAILY / QUEST / REWARD / CASH)")
addLog("═══════════════════════════════════════════════════════")

local pGui = LocalPlayer:FindFirstChild("PlayerGui")
if pGui then
    local keywords = {"daily", "quest", "reward", "cash", "collect", "claim", "plot", "balance"}
    local uiCount = 0
    for _, ui in ipairs(pGui:GetDescendants()) do
        local nameLower = ui.Name:lower()
        local match = false
        for _, kw in ipairs(keywords) do
            if nameLower:find(kw) then
                match = true
                break
            end
        end
        if match and (ui:IsA("GuiButton") or ui:IsA("Frame") or ui:IsA("TextLabel")) then
            uiCount = uiCount + 1
            local info = string.format("[%s] %s", ui.ClassName, ui:GetFullName())
            if ui:IsA("TextLabel") or ui:IsA("TextButton") then
                info = info .. string.format(" (Text: %q)", ui.Text)
            end
            addLog(info)
        end
    end
    addLog(string.format("--> Total UI Target Ditemukan: %d\n", uiCount))
end

-- 3. SCAN MODULESCRIPTS DI NETWORK / PACKAGES
addLog("═══════════════════════════════════════════════════════")
addLog("📦 SCANNING REPLICATEDSTORAGE NETWORK MODULES")
addLog("═══════════════════════════════════════════════════════")
local net = RS:FindFirstChild("Network") or RS:FindFirstChild("Remotes") or RS:FindFirstChild("Events")
if net then
    for _, child in ipairs(net:GetChildren()) do
        addLog(string.format("[Service] %s (Type: %s)", child:GetFullName(), child.ClassName))
        for _, sub in ipairs(child:GetChildren()) do
            addLog(string.format("   ↳ [%s] %s", sub.ClassName, sub.Name))
        end
    end
end

addLog("\n═══════════════════════════════════════════════════════")
addLog("🎯 LIVE HOOK AKTIF (Kalau ada tombol yang bisa diklik):")
addLog("═══════════════════════════════════════════════════════")

-- 4. GUI DISPLAY
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LianSpyConsole"
ScreenGui.ResetOnSpawn = false
pcall(function()
    ScreenGui.Parent = (type(gethui) == "function" and gethui()) or game.CoreGui
end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 540, 0, 380)
Frame.Position = UDim2.new(0.5, -270, 0.5, -190)
Frame.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
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
Title.Text = "🔍 Lian Spy v2 — Data Otomatis Terkumpul!"
Title.TextColor3 = Color3.fromRGB(0, 220, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -85)
Scroll.Position = UDim2.new(0, 10, 0, 40)
Scroll.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
Scroll.BorderSizePixel = 0
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ScrollBarThickness = 6
Scroll.Parent = Frame

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(1, -10, 1, 0)
TextBox.Position = UDim2.new(0, 5, 0, 5)
TextBox.BackgroundTransparency = 1
TextBox.TextColor3 = Color3.fromRGB(220, 220, 220)
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
CloseBtn.Text = "❌ Tutup"
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

-- 5. LIVE HOOK NAMECALL
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if (method == "FireServer" or method == "InvokeServer") and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
        local name = self.Name
        if name ~= "SetPlayerBlockList" and name ~= "UpdateMouseData" and not self:IsDescendantOf(LocalPlayer.Character) then
            local strArgs = {}
            for i, a in ipairs(args) do
                local t = typeof(a)
                if t == "string" then table.insert(strArgs, string.format("%q", a))
                elseif t == "number" or t == "boolean" then table.insert(strArgs, tostring(a))
                else table.insert(strArgs, tostring(a)) end
            end
            local logLine = string.format("⚡ [%s] %s:%s(%s)", os.date("%X"), self:GetFullName(), method, table.concat(strArgs, ", "))
            addLog(logLine)
            updateUI()
        end
    end
    
    return oldNamecall(self, ...)
end)

updateUI()
print("[LianSpy v2] Instant auto scan complete!")
