-- // Giga GUI v3.2 - Функции из Zentrix (Iliankytb)
-- // Автор: Gigaed

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

repeat wait() until Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer

-- Анти-АФК
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
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
local FlySpeed = 1
local InfiniteStaminaEnabled = false
local CheatDisabled = false
local GuiDestroyed = false

-- ESP настройки
local ESPPlayers = true
local ESPKillers = true
local ESPGenerators = true

local ESPHighlights = {}
local NoclipConn = nil

-- Текущий раздел
local CurrentSection = "Info"

-- Кей-бинды
local Keybinds = {
    Menu = Enum.KeyCode.Insert,
    Invis = Enum.KeyCode.X,
    Fly = Enum.KeyCode.Z,
    Teleport = Enum.KeyCode.C,
    Speed = Enum.KeyCode.V,
    DisableAll = Enum.KeyCode.P
}

-- ========== ФУНКЦИИ ИЗ ZENTRIX ==========

-- Полёт (рабочий из Zentrix)
local FLYING = false
local flyKeyDown, flyKeyUp
local BodyGyro, BodyVelocity

local function sFLY()
    repeat wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    
    if flyKeyDown then flyKeyDown:Disconnect() end
    if flyKeyUp then flyKeyUp:Disconnect() end

    local T = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local CONTROL = {F = 0, B = 0, L = 0, R = 0}
    
    local function FLY()
        FLYING = true
        BodyGyro = Instance.new('BodyGyro')
        BodyVelocity = Instance.new('BodyVelocity')
        BodyGyro.P = 9e4
        BodyGyro.Parent = T
        BodyVelocity.Parent = T
        BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        BodyGyro.CFrame = T.CFrame
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        
        task.spawn(function()
            repeat wait()
                if LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
                    LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
                end
                
                local speed = 50 * FlySpeed
                local vec = Vector3.new(0, 0, 0)
                local cam = workspace.CurrentCamera.CFrame
                
                if CONTROL.F > 0 then vec = vec + cam.LookVector end
                if CONTROL.B < 0 then vec = vec - cam.LookVector end
                if CONTROL.L < 0 then vec = vec - cam.RightVector end
                if CONTROL.R > 0 then vec = vec + cam.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vec = vec + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vec = vec - Vector3.new(0, 1, 0) end
                
                if vec.Magnitude > 0 then
                    BodyVelocity.Velocity = vec.Unit * speed
                else
                    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
                
                BodyGyro.CFrame = cam
            until not FLYING
            
            BodyGyro:Destroy()
            BodyVelocity:Destroy()
            if LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
                LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
            end
        end)
    end
    
    flyKeyDown = game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 1
        elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = -1
        elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = -1
        elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = 1
        end
    end)
    
    flyKeyUp = game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 0
        elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = 0
        elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = 0
        elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = 0
        end
    end)
    
    FLY()
end

local function NOFLY()
    FLYING = false
    if flyKeyDown then flyKeyDown:Disconnect() end
    if flyKeyUp then flyKeyUp:Disconnect() end
    if LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
        LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
    end
end

-- Ноуклип (рабочий)
local function UpdateNoclip()
    if NoclipConn then NoclipConn:Disconnect(); NoclipConn = nil end
    if NoclipEnabled and not CheatDisabled then
        NoclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    else
        local char = LocalPlayer.Character
        if char then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end

-- Скорость (из Zentrix)
function UpdateSpeed()
    local char = LocalPlayer.Character
    if not char then return end
    if CheatDisabled then return end
    
    if SpeedEnabled then
        char:SetAttribute("RunSpeed", CustomSpeed)
        char:SetAttribute("WalkSpeed", CustomSpeed)
    else
        char:SetAttribute("RunSpeed", 24)
        char:SetAttribute("WalkSpeed", 16)
    end
end

-- Авто Генератор (из Zentrix)
local function doGenerator()
    if not AutoGenEnabled or CheatDisabled then return end
    local gui = LocalPlayer.PlayerGui:FindFirstChild("Gen")
    if gui and gui:FindFirstChild("GeneratorMain") then
        gui.GeneratorMain.Event:FireServer({ Wires = true, Switches = true, Lever = true })
    end
end

-- Авто Барикада (из Zentrix)
local function doBarricade()
    if not AutoBarricadeEnabled or CheatDisabled then return end
    local dot = nil
    for _, child in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        if child.Name == "Dot" then dot = child; break end
    end
    if dot then
        local container = dot:FindFirstChild("Container")
        if container then
            local frame = container:FindFirstChild("Frame")
            local box = container:FindFirstChild("Box")
            if frame and box then
                local boxAbs = box.AbsolutePosition
                local boxSize = box.AbsoluteSize
                local conAbs = container.AbsolutePosition
                frame.Position = UDim2.new(0, (boxAbs.X + boxSize.X * 0.5) - conAbs.X, 0, (boxAbs.Y + boxSize.Y * 0.5) - conAbs.Y)
                box.Size = UDim2.new(0.3, 0, 0.3, 0)
            end
        end
    end
end

-- Бесконечная стамина (из Zentrix)
local function UpdateStamina()
    if not InfiniteStaminaEnabled or CheatDisabled then return end
    local char = LocalPlayer.Character
    if char then
        local max = char:GetAttribute("MaxStamina") or 100
        if (char:GetAttribute("Stamina") or max) < max then
            char:SetAttribute("Stamina", max)
        end
    end
end

-- Невидимость (простая прозрачность)
local function ToggleInvis(state)
    if CheatDisabled and state then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    if state then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.Transparency = 1 end
            if part:IsA("Accessory") then part.Handle.Transparency = 1 end
        end
    else
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.Transparency = 0 end
            if part:IsA("Accessory") then part.Handle.Transparency = 0 end
        end
    end
end

-- ESP (из Zentrix)
local function createHighlight(model, color)
    pcall(function()
        for _, ex in pairs(model:GetChildren()) do if ex:IsA("Highlight") then ex:Destroy() end end
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
        for _, h in pairs(ESPHighlights) do pcall(function() h:Destroy() end) end
        ESPHighlights = {}
        return
    end
    
    for _, h in pairs(ESPHighlights) do pcall(function() h:Destroy() end) end
    ESPHighlights = {}
    
    if ESPPlayers then
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
    end
    
    if ESPKillers then
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
    
    if ESPGenerators then
        pcall(function()
            local gens = workspace:FindFirstChild("MAPS"):FindFirstChild("GAME MAP"):FindFirstChild("Generators")
            if gens then
                for _, obj in pairs(gens:GetChildren()) do
                    if obj.Name == "Generator" and obj:FindFirstChild("RootPart") then
                        createHighlight(obj, Color3.fromRGB(255, 255, 0))
                    end
                end
            end
        end)
    end
end

-- Телепорт
local function TeleportToPlayer(targetRoot)
    if CheatDisabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root and targetRoot and targetRoot.Parent then
        root.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 2)
    end
end

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
                    if targetRoot then
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
    end
end

local function TeleportToExit()
    if CheatDisabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    pcall(function()
        local exits = workspace:FindFirstChild("MAPS"):FindFirstChild("GAME MAP"):FindFirstChild("Escapes")
        if exits then
            for _, part in pairs(exits:GetChildren()) do
                if part:IsA("BasePart") and part:GetAttribute("Enabled") then
                    char:MoveTo(part.Position + Vector3.new(0, 3, 0))
                    break
                end
            end
        end
    end)
end

local function GetAllPlayersList()
    local list = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(list, {Name = plr.Name, Root = plr.Character.HumanoidRootPart})
        end
    end
    return list
end

-- Полное отключение
local function DisableAllCheats()
    CheatDisabled = true
    GuiDestroyed = true
    
    SpeedEnabled = false
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("RunSpeed", 24)
        char:SetAttribute("WalkSpeed", 16)
    end
    
    if FlyEnabled then
        FlyEnabled = false
        NOFLY()
    end
    
    NoclipEnabled = false
    UpdateNoclip()
    
    ESPEnabled = false
    for _, h in pairs(ESPHighlights) do pcall(function() h:Destroy() end) end
    ESPHighlights = {}
    
    AutoGenEnabled = false
    AutoBarricadeEnabled = false
    InfiniteStaminaEnabled = false
    
    if InvisEnabled then
        InvisEnabled = false
        ToggleInvis(false)
    end
    
    if SG then SG:Destroy(); SG = nil end
    
    print("❌ Giga GUI отключен")
end

-- ========== GUI ==========
local SG = Instance.new("ScreenGui")
SG.Name = "GigaGUI"
SG.ResetOnSpawn = false
SG.DisplayOrder = 999
pcall(function() SG.Parent = game:GetService("CoreGui") end)
if not SG.Parent then SG.Parent = LocalPlayer:FindFirstChild("PlayerGui") end

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

-- Главное окно
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 600, 0, 500)
Main.Position = UDim2.new(0.5, -300, 0.5, -250)
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
Title.Text = "GIGA GUI v3.2"
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
Close.MouseButton1Click:Connect(function() Main.Visible = false; MenuVisible = false end)

-- Верхние вкладки
local TopTabs = Instance.new("Frame")
TopTabs.Size = UDim2.new(1, 0, 0, 35)
TopTabs.Position = UDim2.new(0, 0, 0, 35)
TopTabs.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
TopTabs.BorderSizePixel = 0
TopTabs.Parent = Main

local CheatTab = Instance.new("TextButton")
CheatTab.Size = UDim2.new(0.5, -2, 1, 0)
CheatTab.Position = UDim2.new(0, 0, 0, 0)
CheatTab.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
CheatTab.Text = "ЧИТ"
CheatTab.TextColor3 = Color3.fromRGB(255, 255, 255)
CheatTab.Font = Enum.Font.GothamBold
CheatTab.TextSize = 14
CheatTab.Parent = TopTabs
Instance.new("UICorner", CheatTab).CornerRadius = UDim.new(0, 0)

local BindsTab = Instance.new("TextButton")
BindsTab.Size = UDim2.new(0.5, -2, 1, 0)
BindsTab.Position = UDim2.new(0.5, 2, 0, 0)
BindsTab.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
BindsTab.Text = "БИНДЫ"
BindsTab.TextColor3 = Color3.fromRGB(220, 220, 220)
BindsTab.Font = Enum.Font.GothamBold
BindsTab.TextSize = 14
BindsTab.Parent = TopTabs
Instance.new("UICorner", BindsTab).CornerRadius = UDim.new(0, 0)

-- Основной контейнер
local MainContainer = Instance.new("Frame")
MainContainer.Size = UDim2.new(1, 0, 1, -70)
MainContainer.Position = UDim2.new(0, 0, 0, 70)
MainContainer.BackgroundTransparency = 1
MainContainer.Parent = Main

-- Боковое меню
local SideMenu = Instance.new("Frame")
SideMenu.Size = UDim2.new(0, 130, 1, 0)
SideMenu.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
SideMenu.BorderSizePixel = 0
SideMenu.Parent = MainContainer
Instance.new("UICorner", SideMenu).CornerRadius = UDim.new(0, 0)

-- Контент
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Size = UDim2.new(1, -135, 1, 0)
ContentArea.Position = UDim2.new(0, 135, 0, 0)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 5
ContentArea.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentArea.Parent = MainContainer

local ContentInner = Instance.new("Frame")
ContentInner.Size = UDim2.new(1, 0, 1, 0)
ContentInner.BackgroundTransparency = 1
ContentInner.Parent = ContentArea

-- Контейнер для биндов
local BindsContainer = Instance.new("ScrollingFrame")
BindsContainer.Size = UDim2.new(1, 0, 1, 0)
BindsContainer.Position = UDim2.new(0, 0, 0, 0)
BindsContainer.BackgroundTransparency = 1
BindsContainer.BorderSizePixel = 0
BindsContainer.ScrollBarThickness = 5
BindsContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
BindsContainer.CanvasSize = UDim2.new(0, 0, 0, 400)
BindsContainer.Visible = false
BindsContainer.Parent = MainContainer

local BindsInner = Instance.new("Frame")
BindsInner.Size = UDim2.new(1, 0, 1, 0)
BindsInner.BackgroundTransparency = 1
BindsInner.Parent = BindsContainer

-- Функции GUI
local function CreateSideButton(name, icon, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 38)
    btn.Position = UDim2.new(0, 5, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    btn.Text = icon .. "  " .. name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = SideMenu
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CreateToggle(name, y, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 38)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    frame.Parent = ContentInner
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 250, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local state = default
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 22, 0, 22)
    box.Position = UDim2.new(1, -32, 0.5, -11)
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

local function CreateSlider(name, y, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 65)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    frame.Parent = ContentInner
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 22)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local slider = Instance.new("TextBox")
    slider.Size = UDim2.new(1, -20, 0, 26)
    slider.Position = UDim2.new(0, 10, 0, 30)
    slider.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    slider.Text = tostring(default)
    slider.TextColor3 = Color3.fromRGB(255, 255, 255)
    slider.Font = Enum.Font.Gotham
    slider.TextSize = 12
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

local function CreateContentButton(name, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 38)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = ContentInner
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        if CheatDisabled then return end
        callback()
    end)
    return btn
end

local function ClearContent()
    for _, child in pairs(ContentInner:GetChildren()) do child:Destroy() end
end

local function CreateTPList(yStart)
    local allPlayers = GetAllPlayersList()
    
    if #allPlayers == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, -20, 0, 30)
        empty.Position = UDim2.new(0, 10, 0, yStart)
        empty.BackgroundTransparency = 1
        empty.Text = "Нет игроков"
        empty.TextColor3 = Color3.fromRGB(150, 150, 150)
        empty.Font = Enum.Font.Gotham
        empty.TextSize = 13
        empty.Parent = ContentInner
        return yStart + 35
    end
    
    local yPos = yStart
    for _, data in pairs(allPlayers) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 32)
        btn.Position = UDim2.new(0, 10, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        btn.Text = data.Name
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = ContentInner
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(function()
            if CheatDisabled then return end
            TeleportToPlayer(data.Root)
        end)
        yPos = yPos + 37
    end
    
    return yPos
end

local function ShowSection(section)
    CurrentSection = section
    ClearContent()
    BindsContainer.Visible = false
    ContentArea.Visible = true
    SideMenu.Visible = true
    
    local y = 10
    
    if section == "Info" then
        local info = Instance.new("TextLabel")
        info.Size = UDim2.new(1, -20, 0, 220)
        info.Position = UDim2.new(0, 10, 0, y)
        info.BackgroundTransparency = 1
        info.Text = "GIGA GUI v3.2\n\nВозможности:\n• Speed Hack (работает!)\n• Fly (работает!)\n• Noclip\n• ESP (WallHack)\n• Невидимость\n• Авто-генератор\n• Авто-барикада\n• Бесконечная стамина\n• Телепорты\n\nСоздатель: Gigaed"
        info.TextColor3 = Color3.fromRGB(200, 200, 200)
        info.Font = Enum.Font.Gotham
        info.TextSize = 13
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.TextYAlignment = Enum.TextYAlignment.Top
        info.Parent = ContentInner
        
        local footer = Instance.new("TextLabel")
        footer.Size = UDim2.new(1, -20, 0, 30)
        footer.Position = UDim2.new(0, 10, 0, 380)
        footer.BackgroundTransparency = 1
        footer.Text = "It's time to take your final bow!"
        footer.TextColor3 = Color3.fromRGB(255, 105, 180)
        footer.Font = Enum.Font.GothamBold
        footer.TextSize = 14
        footer.Parent = ContentInner
        
        ContentArea.CanvasSize = UDim2.new(0, 0, 0, 430)
        
    elseif section == "ESP" then
        CreateToggle("👥 Игроки (зелёные)", y, true, function(v) ESPPlayers = v end)
        y = y + 45
        CreateToggle("🔪 Киллеры (красные)", y, true, function(v) ESPKillers = v end)
        y = y + 45
        CreateToggle("⚡ Генераторы (жёлтые)", y, true, function(v) ESPGenerators = v end)
        y = y + 45
        CreateToggle("👁 Включить ESP", y, false, function(v) ESPEnabled = v end)
        ContentArea.CanvasSize = UDim2.new(0, 0, 0, y + 50)
        
    elseif section == "Movement" then
        CreateToggle("🚀 Speed Hack", y, false, function(v) SpeedEnabled = v; UpdateSpeed() end)
        y = y + 45
        CreateSlider("⚡ Скорость", y, 16, 150, 24, function(v) CustomSpeed = v; UpdateSpeed() end)
        y = y + 75
        CreateToggle("✈️ Полёт", y, false, function(v) FlyEnabled = v; if v then sFLY() else NOFLY() end end)
        y = y + 45
        CreateSlider("🕊️ Скорость полёта", y, 1, 10, 1, function(v) FlySpeed = v end)
        y = y + 75
        CreateToggle("🧱 Ноуклип", y, false, function(v) NoclipEnabled = v; UpdateNoclip() end)
        ContentArea.CanvasSize = UDim2.new(0, 0, 0, y + 50)
        
    elseif section == "Utility" then
        CreateToggle("👻 Невидимость", y, false, function(v) InvisEnabled = v; ToggleInvis(v) end)
        y = y + 45
        CreateToggle("🔧 Авто-генератор", y, false, function(v) AutoGenEnabled = v end)
        y = y + 45
        CreateToggle("🚧 Авто-барикада", y, false, function(v) AutoBarricadeEnabled = v end)
        y = y + 45
        CreateToggle("⚡ Беск. стамина", y, false, function(v) InfiniteStaminaEnabled = v end)
        ContentArea.CanvasSize = UDim2.new(0, 0, 0, y + 50)
        
    elseif section == "Teleport" then
        local yPos = CreateTPList(y)
        y = yPos + 10
        CreateContentButton("🚪 ТП на выход", y, TeleportToExit)
        y = y + 45
        CreateContentButton("❌ Отключить ВСЁ", y, DisableAllCheats)
        ContentArea.CanvasSize = UDim2.new(0, 0, 0, y + 60)
    end
end

-- Создание боковых кнопок
CreateSideButton("Инфо", "ℹ️", 10, function() ShowSection("Info") end)
CreateSideButton("ESP", "👁", 53, function() ShowSection("ESP") end)
CreateSideButton("Движение", "🏃", 96, function() ShowSection("Movement") end)
CreateSideButton("Утилиты", "🔧", 139, function() ShowSection("Utility") end)
CreateSideButton("Телепорт", "📍", 182, function() ShowSection("Teleport") end)

ShowSection("Info")

-- Переключение вкладок
CheatTab.MouseButton1Click:Connect(function()
    CheatTab.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    CheatTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    BindsTab.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    BindsTab.TextColor3 = Color3.fromRGB(220, 220, 220)
    BindsContainer.Visible = false
    ContentArea.Visible = true
    SideMenu.Visible = true
end)

BindsTab.MouseButton1Click:Connect(function()
    BindsTab.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    BindsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    CheatTab.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    CheatTab.TextColor3 = Color3.fromRGB(220, 220, 220)
    BindsContainer.Visible = true
    ContentArea.Visible = false
    SideMenu.Visible = false
end)

-- Обработчики
OpenBtn.MouseButton1Click:Connect(function()
    if GuiDestroyed or CheatDisabled then return end
    MenuVisible = not MenuVisible
    Main.Visible = MenuVisible
end)

UserInputService.InputBegan:Connect(function(inp, gp)
    if gp or GuiDestroyed then return end
    
    if inp.KeyCode == Keybinds.Menu then
        if CheatDisabled then return end
        MenuVisible = not MenuVisible
        Main.Visible = MenuVisible
    end
    
    if inp.KeyCode == Keybinds.DisableAll then
        DisableAllCheats()
        return
    end
    
    if CheatDisabled then return end
    
    if inp.KeyCode == Keybinds.Invis then
        InvisEnabled = not InvisEnabled
        ToggleInvis(InvisEnabled)
    end
    
    if inp.KeyCode == Keybinds.Fly then
        FlyEnabled = not FlyEnabled
        if FlyEnabled then sFLY() else NOFLY() end
    end
    
    if inp.KeyCode == Keybinds.Teleport then
        TeleportToNearest()
    end
    
    if inp.KeyCode == Keybinds.Speed then
        SpeedEnabled = not SpeedEnabled
        UpdateSpeed()
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    if GuiDestroyed or CheatDisabled then return end
    task.wait(0.2)
    if NoclipEnabled then UpdateNoclip() end
    if SpeedEnabled then UpdateSpeed() end
    if InvisEnabled then ToggleInvis(true) end
end)

RunService.RenderStepped:Connect(function()
    if GuiDestroyed or CheatDisabled then return end
    pcall(updateESP)
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

print("✅ Giga GUI v3.2 Loaded!")
print("🎮 Функции из Zentrix (Iliankytb)")
print("⚡ Speed Hack работает!")
print("✈️ Fly работает!")
