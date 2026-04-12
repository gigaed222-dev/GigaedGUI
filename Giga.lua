-- // Giga GUI - Forsaken
-- // Функции: Speed (только бег), Fly, Noclip, ESP, AutoGen, AutoBarricade, Invis (все), Teleport

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
local Mouse = LocalPlayer:GetMouse()

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
local BodyFly = nil
local FlySpeed = 50
local SizeBoxBarricade = 0.3

local ESPHighlights = {}
local NoclipConn = nil
local InvisTrack = nil
local InvisConn = nil

-- ========== ФУНКЦИИ ==========

-- Ноуклип
local function UpdateNoclip()
    if NoclipConn then NoclipConn:Disconnect(); NoclipConn = nil end
    if NoclipEnabled then
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

-- Скорость (только бег на Shift)
local function UpdateSpeed()
    local char = LocalPlayer.Character
    if char then
        if SpeedEnabled then
            -- Меняем ТОЛЬКО RunSpeed (бег на Shift)
            char:SetAttribute("RunSpeed", CustomSpeed)
            -- WalkSpeed (обычная ходьба) остаётся стандартной
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
            end
        else
            -- Возвращаем стандартные значения
            char:SetAttribute("RunSpeed", 24)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
            end
        end
    end
end

-- Полёт
local function UpdateFly()
    if not FlyEnabled then
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
    if not AutoGenEnabled then return end
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
    if not AutoBarricadeEnabled then return end
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

-- Невидимость (для ВСЕХ персонажей)
local function ToggleInvis(state)
    local char = LocalPlayer.Character
    if not char then return end
    
    if not state then
        -- Выключение невидимости
        if InvisTrack then 
            InvisTrack:Stop()
            InvisTrack = nil 
        end
        if InvisConn then
            InvisConn:Disconnect()
            InvisConn = nil
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then 
            root.Anchored = false 
        end
        
        -- Возвращаем видимость персонажа
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 0
                part.CanCollide = true
            elseif part:IsA("Decal") or part:IsA("Texture") then
                part.Transparency = 0
            end
        end
        
        -- Включаем коллизию дверей обратно
        pcall(function()
            local doors = workspace.MAPS:FindFirstChild("GAME MAP"):FindFirstChild("Doors")
            if doors then
                for _, part in pairs(doors:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local orig = part:GetAttribute("OriginalCollision")
                        if orig ~= nil then
                            part.CanCollide = orig
                        end
                    end
                end
            end
        end)
        return
    end
    
    -- Включение невидимости
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    -- Делаем персонажа прозрачным
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 1
            part.CanCollide = false
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = 1
        end
    end
    root.Transparency = 0  -- RootPart оставляем видимым для камеры
    root.CanCollide = true
    
    -- Отключаем коллизию дверей
    pcall(function()
        local doors = workspace.MAPS:FindFirstChild("GAME MAP"):FindFirstChild("Doors")
        if doors then
            for _, part in pairs(doors:GetDescendants()) do
                if part:IsA("BasePart") then
                    if part:GetAttribute("OriginalCollision") == nil then
                        part:SetAttribute("OriginalCollision", part.CanCollide)
                    end
                    part.CanCollide = false
                end
            end
        end
    end)
    
    -- Поддержание невидимости при респавне
    InvisConn = RunService.RenderStepped:Connect(function()
        local c = LocalPlayer.Character
        if c and InvisEnabled then
            for _, part in pairs(c:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 1
                    part.CanCollide = false
                elseif part:IsA("Decal") or part:IsA("Texture") then
                    part.Transparency = 1
                end
            end
        end
    end)
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
    if not ESPEnabled then
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
    
    -- Выжившие (зелёные)
    pcall(function()
        local alive = workspace:FindFirstChild("PLAYERS")
        if alive then
            alive = alive:FindFirstChild("ALIVE")
            if alive then
                for _, obj in pairs(alive:GetChildren()) do
                    if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                        createHighlight(obj, Color3.fromRGB(0, 255, 0))
                    end
                end
            end
        end
    end)
    
    -- Убийца (красный)
    pcall(function()
        local killer = workspace:FindFirstChild("PLAYERS")
        if killer then
            killer = killer:FindFirstChild("KILLER")
            if killer then
                for _, obj in pairs(killer:GetChildren()) do
                    if obj:IsA("Model") and (obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("RootPart")) then
                        createHighlight(obj, Color3.fromRGB(255, 0, 0))
                    end
                end
            end
        end
    end)
end

-- Телепорт к игрокам
local function GetSurvivorsList()
    local list = {}
    pcall(function()
        local alive = workspace:FindFirstChild("PLAYERS")
        if alive then
            alive = alive:FindFirstChild("ALIVE")
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
        end
    end)
    return list
end

local function TeleportToPlayer(targetRoot)
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

-- Кнопка открытия (круглая)
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
local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 27)
OpenCorner.Parent = OpenBtn

-- Главное меню
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 350, 0, 550)
Main.Position = UDim2.new(0.5, -175, 0.5, -275)
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

-- Контейнер с прокруткой
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -35)
ScrollFrame.Position = UDim2.new(0, 0, 0, 35)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 580)
ScrollFrame.Parent = Main

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, 0)
Content.BackgroundTransparency = 1
Content.Parent = ScrollFrame

-- Функция создания переключателя
local function CreateToggle(name, y, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    frame.Parent = Content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 230, 1, 0)
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
        if ep then update(slider.Text) end
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
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Функция создания списка ТП
local function CreateTPList()
    local existing = Content:FindFirstChild("TPList")
    if existing then existing:Destroy() end
    
    local sf = Instance.new("ScrollingFrame")
    sf.Name = "TPList"
    sf.Size = UDim2.new(1, -20, 0, 150)
    sf.Position = UDim2.new(0, 10, 0, 430)
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
            TeleportToPlayer(data.Root)
        end)
        yPos = yPos + 37
    end
    sf.CanvasSize = UDim2.new(0, 0, 0, yPos + 10)
end

-- Добавляем все элементы
local currentY = 10

CreateToggle("🚀 Speed Hack (только бег)", currentY, false, function(v)
    SpeedEnabled = v
    UpdateSpeed()
end)
currentY = currentY + 45

CreateSlider("⚡ Скорость бега", currentY, 24, 150, 50, function(v)
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

CreateToggle("👻 Невидимость", currentY, false, function(v)
    InvisEnabled = v
    ToggleInvis(v)
end)
currentY = currentY + 50

CreateButton("📋 Обновить список ТП", currentY, function()
    CreateTPList()
end)

-- Создаём первый список ТП
CreateTPList()

-- Обновляем CanvasSize
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, currentY + 200)

-- Обработчики событий
OpenBtn.MouseButton1Click:Connect(function()
    MenuVisible = not MenuVisible
    Main.Visible = MenuVisible
    if MenuVisible then
        CreateTPList()
    end
end)

UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.Insert then
        MenuVisible = not MenuVisible
        Main.Visible = MenuVisible
        if MenuVisible then
            CreateTPList()
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.2)
    if NoclipEnabled then UpdateNoclip() end
    if SpeedEnabled then UpdateSpeed() end
    if InvisEnabled then
        task.wait(0.3)
        ToggleInvis(true)
    end
end)

RunService.RenderStepped:Connect(function()
    pcall(updateESP)
    pcall(UpdateFly)
    pcall(doBarricade)
end)

spawn(function()
    while task.wait(0.3) do
        if AutoGenEnabled then pcall(doGenerator) end
        if SpeedEnabled then pcall(UpdateSpeed) end
    end
end)

print("✅ Giga GUI Loaded! Нажми Insert или кнопку GIGA слева.")
print("🎮 Функции: Speed(бег), Fly, Noclip, ESP, AutoGen, AutoBarricade, Invis, Teleport")
