-- // Giga GUI + Рабочая невидимость из Pastebin
-- // Исправлено: Speed Hack, полное отключение, кей-бинды

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

repeat wait() until Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Анти-АФК
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- ========== ЗАГРУЗКА НЕВИДИМОСТИ ИЗ PASTEBIN ==========
local InvisModule = nil
pcall(function()
    InvisModule = loadstring(game:HttpGet('https://pastebin.com/raw/3Rnd9rHf'))()
end)

-- ========== ПЕРЕМЕННЫЕ ==========
local MenuVisible = false
local NoclipEnabled = false
local ESPEnabled = false
local InvisEnabled = false
local AutoGenEnabled = false
local AutoBarricadeEnabled = false
local SpeedEnabled = false
local CustomSpeed = 24
local FlyEnabled = false
local BodyFly = nil
local FlySpeed = 50
local SizeBoxBarricade = 0.3
local InfiniteStaminaEnabled = false
local CheatDisabled = false
local GuiDestroyed = false

local ESPHighlights = {}
local NoclipConn = nil

-- Кей-бинды
local Keybinds = {
    Menu = Enum.KeyCode.Insert,
    Invis = Enum.KeyCode.X,
    Fly = Enum.KeyCode.Z,
    Teleport = Enum.KeyCode.C,
    Speed = Enum.KeyCode.V,
    DisableAll = Enum.KeyCode.P
}

local ListeningForKey = nil

-- ========== ФУНКЦИИ ==========

-- Полное отключение чита (БЕЗВОЗВРАТНО)
local function DisableAllCheats()
    CheatDisabled = true
    GuiDestroyed = true
    
    -- Выключаем все функции
    SpeedEnabled = false
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
        char:SetAttribute("RunSpeed", 24)
    end
    
    FlyEnabled = false
    if BodyFly then
        BodyFly:Destroy()
        BodyFly = nil
    end
    
    NoclipEnabled = false
    if NoclipConn then
        NoclipConn:Disconnect()
        NoclipConn = nil
    end
    if char then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
    
    ESPEnabled = false
    for _, h in pairs(ESPHighlights) do
        pcall(function() h:Destroy() end)
    end
    ESPHighlights = {}
    
    AutoGenEnabled = false
    AutoBarricadeEnabled = false
    InfiniteStaminaEnabled = false
    
    -- Выключаем невидимость через модуль
    if InvisEnabled and InvisModule and InvisModule.Disable then
        pcall(function() InvisModule:Disable() end)
    end
    InvisEnabled = false
    
    -- Уничтожаем GUI
    if SG then
        SG:Destroy()
        SG = nil
    end
    
    MenuVisible = false
    
    print("❌ Чит полностью отключен и уничтожен")
end

-- Бесконечная стамина
local function UpdateStamina()
    if not InfiniteStaminaEnabled or CheatDisabled then return end
    local char = LocalPlayer.Character
    if char then
        local maxStamina = char:GetAttribute("MaxStamina") or 100
        local currentStamina = char:GetAttribute("Stamina") or maxStamina
        if currentStamina < maxStamina then
            char:SetAttribute("Stamina", maxStamina)
        end
    end
end

-- Ноуклип
local function UpdateNoclip()
    if NoclipConn then NoclipConn:Disconnect(); NoclipConn = nil end
    if NoclipEnabled and not CheatDisabled then
        NoclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then 
                        p.CanCollide = false 
                    end
                end
            end
        end)
    else
        local char = LocalPlayer.Character
        if char then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then 
                    p.CanCollide = true 
                end
            end
        end
    end
end

-- Скорость (ИСПРАВЛЕНО - один ползунок)
function UpdateSpeed()
    local char = LocalPlayer.Character
    if char and not CheatDisabled then
        if SpeedEnabled then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = CustomSpeed
            end
            char:SetAttribute("RunSpeed", CustomSpeed)
        else
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
            end
            char:SetAttribute("RunSpeed", 24)
        end
    end
end

-- Полёт
local function UpdateFly()
    if not FlyEnabled or CheatDisabled then
        if BodyFly then 
            BodyFly:Destroy()
            BodyFly = nil 
        end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
        return
    end
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        if BodyFly then BodyFly:Destroy(); BodyFly = nil end
        return
    end
    
    local root = char.HumanoidRootPart
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end
    
    if not BodyFly then
        BodyFly = Instance.new("BodyVelocity")
        BodyFly.MaxForce = Vector3.new(5000, 5000, 5000)
        BodyFly.P = 1250
        BodyFly.Parent = root
    end
    
    local vec = Vector3.new(0, 0, 0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then vec = vec + Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then vec = vec - Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then vec = vec - Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then vec = vec + Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vec = vec + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vec = vec - Vector3.new(0, 1, 0) end
    
    if vec.Magnitude > 0 then
        vec = vec.Unit * FlySpeed
    end
    
    BodyFly.Velocity = vec
end

-- Авто Генератор
local function doGenerator()
    if not AutoGenEnabled or CheatDisabled then return end
    local gui = LocalPlayer.PlayerGui:FindFirstChild("Gen")
    if gui then
        local main = gui:FindFirstChild("GeneratorMain")
        if main then
            local event = main:FindFirstChild("Event")
            if event then
                event:FireServer({ 
                    Wires = true, 
                    Switches = true, 
                    Lever = true 
                })
            end
        end
    end
end

-- Получение точки для барикады
local function getNewestDot()
    local newest = nil
    for _, child in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if child.Name == "Dot" then
            newest = child
        end
    end
    return newest
end

-- Авто Барикада
local function doBarricade()
    if not AutoBarricadeEnabled or CheatDisabled then return end
    local dot = getNewestDot()
    if dot then 
        local container = dot:FindFirstChild("Container")
        if container then
            local frame = container:FindFirstChild("Frame")
            local box = container:FindFirstChild("Box")
            if frame and box then 
                local boxAbs = box.AbsolutePosition
                local boxSize = box.AbsoluteSize
                local conAbs = container.AbsolutePosition
                frame.Position = UDim2.new(
                    0, (boxAbs.X + boxSize.X * 0.5) - conAbs.X,
                    0, (boxAbs.Y + boxSize.Y * 0.5) - conAbs.Y
                )
                box.Size = UDim2.new(SizeBoxBarricade, 0, SizeBoxBarricade, 0)
            end
        end
    end
end

-- Невидимость через Pastebin модуль
local function ToggleInvis(state)
    if CheatDisabled and state then return end
    if not InvisModule then
        print("⚠️ Модуль невидимости не загружен")
        return
    end
    
    if state then
        pcall(function()
            InvisModule:Enable()
        end)
        print("👻 Невидимость ВКЛЮЧЕНА")
    else
        pcall(function()
            InvisModule:Disable()
        end)
        print("👻 Невидимость ВЫКЛЮЧЕНА")
    end
end

-- Телепорт к ближайшему выжившему
local function TeleportToNearest()
    if CheatDisabled then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local nearest = nil
    local minDist = math.huge
    
    pcall(function()
        local alive = workspace:FindFirstChild("PLAYERS"):FindFirstChild("ALIVE")
        if alive then
            for _, obj in pairs(alive:GetChildren()) do
                if obj:IsA("Model") then
                    local targetRoot = obj:FindFirstChild("HumanoidRootPart")
                    local plr = Players:GetPlayerFromCharacter(obj)
                    if targetRoot and plr and plr ~= LocalPlayer then
                        local dist = (root.Position - targetRoot.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            nearest = targetRoot
                        end
                    end
                end
            end
        end
    end)
    
    if nearest then
        root.CFrame = nearest.CFrame + Vector3.new(0, 3, 2)
        for _, p in pairs(char:GetChildren()) do
            if p:IsA("BasePart") and p ~= root then 
                p.CFrame = root.CFrame 
            end
        end
    end
end

-- ESP
local function createHighlight(model, color)
    pcall(function()
        for _, ex in pairs(model:GetChildren()) do 
            if ex:IsA("Highlight") then 
                ex:Destroy() 
            end 
        end
        
        local h = Instance.new("Highlight")
        h.Parent = model
        h.Adornee = model
        h.FillTransparency = 0.65
        h.FillColor = color
        h.OutlineColor = color
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        table.insert(ESPHighlights, h)
    end)
end

local function updateESP()
    if not ESPEnabled or CheatDisabled then
        for _, h in pairs(ESPHighlights) do 
            pcall(function() h:Destroy() end) 
        end
        ESPHighlights = {}
        return
    end
    
    for _, h in pairs(ESPHighlights) do 
        pcall(function() h:Destroy() end) 
    end
    ESPHighlights = {}
    
    pcall(function()
        local alive = workspace:FindFirstChild("PLAYERS"):FindFirstChild("ALIVE")
        if alive then
            for _, obj in pairs(alive:GetChildren()) do
                if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                    createHighlight(obj, Color3.fromRGB(0, 255, 0))
                end
            end
        end
    end)
    
    pcall(function()
        local killer = workspace:FindFirstChild("PLAYERS"):FindFirstChild("KILLER")
        if killer then
            for _, obj in pairs(killer:GetChildren()) do
                if obj:IsA("Model") and (obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("RootPart")) then
                    createHighlight(obj, Color3.fromRGB(255, 0, 0))
                end
            end
        end
    end)
end

-- Список выживших для GUI
local function GetSurvivorsList()
    local list = {}
    pcall(function()
        local alive = workspace:FindFirstChild("PLAYERS"):FindFirstChild("ALIVE")
        if alive then
            for _, obj in pairs(alive:GetChildren()) do
                if obj:IsA("Model") then
                    local root = obj:FindFirstChild("HumanoidRootPart")
                    if root then
                        local plr = Players:GetPlayerFromCharacter(obj)
                        if plr and plr ~= LocalPlayer then
                            table.insert(list, {Name = plr.Name, Root = root})
                        end
                    end
                end
            end
        end
    end)
    return list
end

local function TeleportToPlayer(targetRoot)
    if CheatDisabled then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root and targetRoot and targetRoot.Parent then
        root.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 2)
        for _, p in pairs(char:GetChildren()) do
            if p:IsA("BasePart") and p ~= root then 
                p.CFrame = root.CFrame 
            end
        end
    end
end

-- ========== GUI ==========
local SG = Instance.new("ScreenGui")
SG.Name = "GigaGUI"
SG.ResetOnSpawn = false
SG.DisplayOrder = 999
pcall(function() SG.Parent = game:GetService("CoreGui") end)
if not SG.Parent then pcall(function() SG.Parent = LocalPlayer:FindFirstChild("PlayerGui") end) end

-- Кнопка открытия
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 55, 0, 55)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -27)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
OpenBtn.BackgroundTransparency = 0.15
OpenBtn.Text = "GIGA"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 18
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.Parent = SG
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 27)

-- Главное меню
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 380, 0, 650)
Main.Position = UDim2.new(0.5, -190, 0.5, -325)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 1
Main.BorderColor3 = Color3.fromRGB(45, 45, 55)
Main.Active = true
Main.Draggable = true
Main.Visible = false
Main.Parent = SG
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
Title.Text = "GIGA GUI"
Title.TextColor3 = Color3.fromRGB(0, 162, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 28, 0, 28)
Close.Position = UDim2.new(1, -33, 0, 3)
Close.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
Close.Text = "✕"
Close.TextColor3 = Color3.fromRGB(220, 220, 220)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 16
Close.Parent = Main
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
    MenuVisible = false
end)

-- Вкладки
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, 0, 0, 40)
TabFrame.Position = UDim2.new(0, 0, 0, 35)
TabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = Main

local MainTab = Instance.new("TextButton")
MainTab.Size = UDim2.new(0.5, -2, 1, 0)
MainTab.Position = UDim2.new(0, 0, 0, 0)
MainTab.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
MainTab.Text = "ФУНКЦИИ"
MainTab.TextColor3 = Color3.fromRGB(255, 255, 255)
MainTab.Font = Enum.Font.GothamBold
MainTab.TextSize = 14
MainTab.Parent = TabFrame
Instance.new("UICorner", MainTab).CornerRadius = UDim.new(0, 0)

local BindsTab = Instance.new("TextButton")
BindsTab.Size = UDim2.new(0.5, -2, 1, 0)
BindsTab.Position = UDim2.new(0.5, 2, 0, 0)
BindsTab.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
BindsTab.Text = "БИНДЫ"
BindsTab.TextColor3 = Color3.fromRGB(220, 220, 220)
BindsTab.Font = Enum.Font.GothamBold
BindsTab.TextSize = 14
BindsTab.Parent = TabFrame
Instance.new("UICorner", BindsTab).CornerRadius = UDim.new(0, 0)

-- Контейнеры для вкладок
local MainContent = Instance.new("ScrollingFrame")
MainContent.Size = UDim2.new(1, 0, 1, -75)
MainContent.Position = UDim2.new(0, 0, 0, 75)
MainContent.BackgroundTransparency = 1
MainContent.BorderSizePixel = 0
MainContent.ScrollBarThickness = 5
MainContent.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
MainContent.CanvasSize = UDim2.new(0, 0, 0, 750)
MainContent.Visible = true
MainContent.Parent = Main

local BindsContent = Instance.new("ScrollingFrame")
BindsContent.Size = UDim2.new(1, 0, 1, -75)
BindsContent.Position = UDim2.new(0, 0, 0, 75)
BindsContent.BackgroundTransparency = 1
BindsContent.BorderSizePixel = 0
BindsContent.ScrollBarThickness = 5
BindsContent.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
BindsContent.CanvasSize = UDim2.new(0, 0, 0, 450)
BindsContent.Visible = false
BindsContent.Parent = Main

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, 0)
Content.BackgroundTransparency = 1
Content.Parent = MainContent

local BindsInner = Instance.new("Frame")
BindsInner.Size = UDim2.new(1, 0, 1, 0)
BindsInner.BackgroundTransparency = 1
BindsInner.Parent = BindsContent

-- Переключение вкладок
MainTab.MouseButton1Click:Connect(function()
    MainTab.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    MainTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    BindsTab.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    BindsTab.TextColor3 = Color3.fromRGB(220, 220, 220)
    MainContent.Visible = true
    BindsContent.Visible = false
end)

BindsTab.MouseButton1Click:Connect(function()
    BindsTab.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    BindsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainTab.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    MainTab.TextColor3 = Color3.fromRGB(220, 220, 220)
    MainContent.Visible = false
    BindsContent.Visible = true
end)

-- Функция создания переключателя
local function CreateToggle(name, y, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    frame.Parent = Content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local state = default
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 22, 0, 22)
    box.Position = UDim2.new(1, -34, 0.5, -11)
    box.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 14, 0, 14)
    fill.Position = UDim2.new(0.5, -7, 0.5, -7)
    fill.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    fill.Visible = default
    fill.Parent = box
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame
    btn.MouseButton1Click:Connect(function()
        if CheatDisabled then return end
        state = not state
        fill.Visible = state
        callback(state)
    end)
    return frame
end

-- Функция создания слайдера
local function CreateSlider(name, y, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 65)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    frame.Parent = Content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 12, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local slider = Instance.new("TextBox")
    slider.Size = UDim2.new(1, -24, 0, 24)
    slider.Position = UDim2.new(0, 12, 0, 33)
    slider.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    slider.Text = tostring(default)
    slider.TextColor3 = Color3.fromRGB(255, 255, 255)
    slider.Font = Enum.Font.Gotham
    slider.TextSize = 13
    slider.Parent = frame
    Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 4)

    local function update(val)
        local num = tonumber(val)
        if num then
            num = math.clamp(num, min, max)
            label.Text = name .. ": " .. num
            callback(num)
        end
    end

    slider.FocusLost:Connect(function(ep)
        if ep and not CheatDisabled then update(slider.Text) end
    end)

    return frame
end

-- Функция создания кнопки
local function CreateButton(name, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = Content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(function()
        if CheatDisabled then return end
        callback()
    end)
    return btn
end

-- Функция создания настройки бинда
local function CreateBindSetting(name, y, keybindName)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    frame.Parent = BindsInner
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0, 100, 0, 30)
    bindBtn.Position = UDim2.new(1, -112, 0.5, -15)
    bindBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    bindBtn.Text = Keybinds[keybindName] == nil and "None" or tostring(Keybinds[keybindName]):gsub("Enum.KeyCode.", "")
    bindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.TextSize = 13
    bindBtn.Parent = frame
    Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 4)

    bindBtn.MouseButton1Click:Connect(function()
        if ListeningForKey == bindBtn then
            ListeningForKey = nil
            bindBtn.Text = Keybinds[keybindName] == nil and "None" or tostring(Keybinds[keybindName]):gsub("Enum.KeyCode.", "")
            bindBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        else
            if ListeningForKey then
                ListeningForKey.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            end
            ListeningForKey = bindBtn
            bindBtn.Text = "НАЖМИ..."
            bindBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
        end
    end)

    return frame, bindBtn, keybindName
end

-- Функция создания списка ТП
local function CreateTPList()
    local existing = Content:FindFirstChild("TPList")
    if existing then existing:Destroy() end
    
    local sf = Instance.new("ScrollingFrame")
    sf.Name = "TPList"
    sf.Size = UDim2.new(1, -20, 0, 150)
    sf.Position = UDim2.new(0, 10, 0, 530)
    sf.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 4
    sf.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.Parent = Content
    Instance.new("UICorner", sf).CornerRadius = UDim.new(0, 8)

    local yPos = 5
    local survivors = GetSurvivorsList()
    
    if #survivors == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, 0, 0, 30)
        empty.Position = UDim2.new(0, 0, 0, 5)
        empty.BackgroundTransparency = 1
        empty.Text = "Нет выживших"
        empty.TextColor3 = Color3.fromRGB(150, 150, 150)
        empty.Font = Enum.Font.Gotham
        empty.TextSize = 13
        empty.Parent = sf
        sf.CanvasSize = UDim2.new(0, 0, 0, 40)
        return
    end
    
    for _, data in pairs(survivors) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 32)
        btn.Position = UDim2.new(0, 5, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        btn.Text = data.Name
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.Parent = sf
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(function()
            if CheatDisabled then return end
            TeleportToPlayer(data.Root)
        end)
        yPos = yPos + 37
    end
    sf.CanvasSize = UDim2.new(0, 0, 0, yPos + 10)
end

-- Добавляем элементы на вкладку ФУНКЦИИ
local currentY = 10

CreateToggle("🚀 Speed Hack", currentY, false, function(v)
    SpeedEnabled = v
    UpdateSpeed()
end)
currentY = currentY + 45

CreateSlider("⚡ Скорость", currentY, 16, 150, 24, function(v)
    CustomSpeed = v
    UpdateSpeed()
end)
currentY = currentY + 70

CreateToggle("✈️ Полёт", currentY, false, function(v)
    FlyEnabled = v
    if not v and BodyFly then
        BodyFly:Destroy()
        BodyFly = nil
    end
end)
currentY = currentY + 45

CreateSlider("🕊️ Скорость полёта", currentY, 20, 150, 50, function(v)
    FlySpeed = v
end)
currentY = currentY + 70

CreateToggle("🧱 Ноуклип", currentY, false, function(v)
    NoclipEnabled = v
    UpdateNoclip()
end)
currentY = currentY + 45

CreateToggle("👁 ESP (ВХ)", currentY, false, function(v)
    ESPEnabled = v
end)
currentY = currentY + 45

CreateToggle("🔧 Авто-генератор", currentY, false, function(v)
    AutoGenEnabled = v
end)
currentY = currentY + 45

CreateToggle("🚧 Авто-барикада", currentY, false, function(v)
    AutoBarricadeEnabled = v
end)
currentY = currentY + 45

CreateToggle("⚡ Беск. стамина", currentY, false, function(v)
    InfiniteStaminaEnabled = v
end)
currentY = currentY + 45

CreateToggle("👻 Невидимость", currentY, false, function(v)
    InvisEnabled = v
    ToggleInvis(v)
end)
currentY = currentY + 50

CreateButton("📍 ТП к ближайшему", currentY, function()
    TeleportToNearest()
end)
currentY = currentY + 50

CreateButton("📋 Обновить список ТП", currentY, function()
    CreateTPList()
end)
currentY = currentY + 50

-- Кнопка отключения чита (ПОЛНОЕ УНИЧТОЖЕНИЕ)
local disableBtn = Instance.new("TextButton")
disableBtn.Size = UDim2.new(1, -20, 0, 45)
disableBtn.Position = UDim2.new(0, 10, 0, currentY)
disableBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
disableBtn.Text = "❌ ОТКЛЮЧИТЬ ЧИТ (БЕЗВОЗВРАТНО)"
disableBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
disableBtn.Font = Enum.Font.GothamBold
disableBtn.TextSize = 13
disableBtn.Parent = Content
Instance.new("UICorner", disableBtn).CornerRadius = UDim.new(0, 8)
disableBtn.MouseButton1Click:Connect(DisableAllCheats)

currentY = currentY + 55

-- Создаём первый список ТП
CreateTPList()

MainContent.CanvasSize = UDim2.new(0, 0, 0, currentY + 200)

-- Добавляем элементы на вкладку БИНДЫ
local bindsY = 10

local bindElements = {}

local function createBind(name, key)
    local frame, btn, bindName = CreateBindSetting(name, bindsY, key)
    table.insert(bindElements, {Frame = frame, Button = btn, BindName = bindName})
    bindsY = bindsY + 55
    return frame
end

createBind("Открыть/закрыть меню", "Menu")
createBind("Невидимость", "Invis")
createBind("Полёт", "Fly")
createBind("Телепорт к ближайшему", "Teleport")
createBind("Speed Hack", "Speed")
createBind("Отключить ВСЁ", "DisableAll")

BindsContent.CanvasSize = UDim2.new(0, 0, 0, bindsY + 20)

-- Обработчик нажатий для биндов
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    
    if GuiDestroyed then return end
    
    -- Если ожидаем ввод для бинда
    if ListeningForKey then
        local newKey = inp.KeyCode
        
        if newKey == Enum.KeyCode.Escape then
            for _, elem in pairs(bindElements) do
                if elem.Button == ListeningForKey then
                    Keybinds[elem.BindName] = nil
                    elem.Button.Text = "None"
                    break
                end
            end
            ListeningForKey.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            ListeningForKey = nil
            return
        end
        
        if newKey ~= Enum.KeyCode.Unknown then
            for _, elem in pairs(bindElements) do
                if elem.Button == ListeningForKey then
                    Keybinds[elem.BindName] = newKey
                    elem.Button.Text = tostring(newKey):gsub("Enum.KeyCode.", "")
                    break
                end
            end
        end
        ListeningForKey.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        ListeningForKey = nil
        return
    end
    
    -- Проверяем нажатые кнопки по биндам
    if Keybinds.Menu and inp.KeyCode == Keybinds.Menu then
        if CheatDisabled then return end
        MenuVisible = not MenuVisible
        Main.Visible = MenuVisible
        if MenuVisible then
            CreateTPList()
        end
    end
    
    if Keybinds.DisableAll and inp.KeyCode == Keybinds.DisableAll then
        DisableAllCheats()
        return
    end
    
    if CheatDisabled then return end
    
    if Keybinds.Invis and inp.KeyCode == Keybinds.Invis then
        InvisEnabled = not InvisEnabled
        ToggleInvis(InvisEnabled)
    end
    
    if Keybinds.Fly and inp.KeyCode == Keybinds.Fly then
        FlyEnabled = not FlyEnabled
        if not FlyEnabled and BodyFly then
            BodyFly:Destroy()
            BodyFly = nil
        end
    end
    
    if Keybinds.Teleport and inp.KeyCode == Keybinds.Teleport then
        TeleportToNearest()
    end
    
    if Keybinds.Speed and inp.KeyCode == Keybinds.Speed then
        SpeedEnabled = not SpeedEnabled
        UpdateSpeed()
    end
end)

-- Обработчик открытия через кнопку
OpenBtn.MouseButton1Click:Connect(function()
    if GuiDestroyed or CheatDisabled then return end
    MenuVisible = not MenuVisible
    Main.Visible = MenuVisible
    if MenuVisible then
        CreateTPList()
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    if GuiDestroyed or CheatDisabled then return end
    task.wait(0.2)
    if NoclipEnabled then UpdateNoclip() end
    if SpeedEnabled then UpdateSpeed() end
    if InvisEnabled then
        task.wait(0.3)
        ToggleInvis(true)
    end
end)

RunService.RenderStepped:Connect(function()
    if GuiDestroyed or CheatDisabled then return end
    pcall(updateESP)
    pcall(UpdateFly)
    pcall(doBarricade)
    pcall(UpdateStamina)
end)

spawn(function()
    while task.wait(0.3) do
        if GuiDestroyed or CheatDisabled then continue end
        if AutoGenEnabled then pcall(doGenerator) end
        if SpeedEnabled then pcall(UpdateSpeed) end
        if InfiniteStaminaEnabled then pcall(UpdateStamina) end
    end
end)

print("✅ Giga GUI + Invis Loaded!")
print("👻 Невидимость: модуль из Pastebin")
print("🎮 Управление:")
print("   [Insert] - Меню | [X] - Невидимость | [Z] - Полёт")
print("   [C] - ТП | [V] - Speed | [P] - Отключить ВСЁ (безвозвратно)")
