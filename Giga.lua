-- // Giga GUI v4.0 - Все функции из Zentrix + Невидимость из Pastebin
-- // Автор: Gigaed

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")

repeat wait() until Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer

-- Анти-АФК
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- ========== ЗАГРУЗКА НЕВИДИМОСТИ ==========
local InvisModule = nil
pcall(function()
    InvisModule = loadstring(game:HttpGet('https://pastebin.com/raw/3Rnd9rHf'))()
end)

-- ========== ВСЕ ПЕРЕМЕННЫЕ ==========
local MenuVisible = false
local CheatDisabled = false
local GuiDestroyed = false

-- Movement
local SpeedEnabled = false
local CustomSpeed = 24
local FlyEnabled = false
local FlySpeed = 1
local NoclipEnabled = false
local JumpEnabled = false
local JumpPower = 50

-- ESP
local ESPEnabled = false
local ESPPlayers = true
local ESPKillers = true
local ESPGenerators = true
local ESPFuseBoxes = false
local ESPBattery = false
local ESPTraps = false
local ESPWireEyes = false
local ESPDistance = false
local ESPLines = false
local LimitRangerESP = 100
local DisableLimitRanger = false

-- Utility
local InvisEnabled = false
local AutoGenEnabled = false
local AutoBarricadeEnabled = false
local InfiniteStaminaEnabled = false
local AutoEscapeEnabled = false
local AutoFarmEnabled = false
local AutoSafeSpotEnabled = false
local NoBlindnessEnabled = false
local AntiConfusionEnabled = false
local InstantPromptEnabled = false
local BigPromptEnabled = false
local AutoShakeWireEyes = false
local FighterAutoParry = false
local HitboxExpanderEnabled = false
local HitboxSize = 15
local InvisibilityKiller = false
local AutoHighlightKiller = false

-- Teleport
local TeleportToExitEnabled = false

-- Settings
local TimeForGenerator = 1.25
local ShakeTime = 0.5
local BarricadeSize = 0.3
local TimeAutoHighlight = 0.1

-- ESP Highlights
local ESPHighlights = {}
local NoclipConn = nil

-- Fly variables
local FLYING = false
local flyKeyDown, flyKeyUp
local BodyGyro, BodyVelocity

-- AutoFarm variables
local LastAction = 0
local Cooldown = 0.5
local CanGo = true
local State = "Idle"
local Teleported = false
local SavedCFrame = nil
local CanShake = true
local CanParry = true

-- Drawing for ESP Lines
local Drawing = nil
pcall(function() Drawing = loadstring(game:HttpGet("https://raw.githubusercontent.com/linx/drawing/main/library.lua"))() end)

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
local bindElements = {}

-- ========== ФУНКЦИИ ==========

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
    AutoEscapeEnabled = false
    AutoFarmEnabled = false
    AutoSafeSpotEnabled = false
    JumpEnabled = false
    
    if InvisEnabled and InvisModule and InvisModule.Disable then
        pcall(function() InvisModule:Disable() end)
    end
    InvisEnabled = false
    
    if SG then SG:Destroy(); SG = nil end
    
    print("❌ Giga GUI отключен")
end

-- Ноуклип
function UpdateNoclip()
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

-- Скорость
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

-- Прыжок
function UpdateJump()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.UseJumpPower = JumpEnabled
        hum.JumpPower = JumpEnabled and JumpPower or 50
    end
end

-- Полёт
function sFLY()
    repeat wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
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
    
    flyKeyDown = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 1
        elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = -1
        elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = -1
        elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = 1
        end
    end)
    
    flyKeyUp = UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 0
        elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = 0
        elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = 0
        elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = 0
        end
    end)
    
    FLY()
end

function NOFLY()
    FLYING = false
    if flyKeyDown then flyKeyDown:Disconnect() end
    if flyKeyUp then flyKeyUp:Disconnect() end
    if LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
        LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
    end
end

-- Авто Генератор
function doGenerator()
    if not AutoGenEnabled or CheatDisabled then return end
    local gui = LocalPlayer.PlayerGui:FindFirstChild("Gen")
    if gui and gui:FindFirstChild("GeneratorMain") then
        gui.GeneratorMain.Event:FireServer({ Wires = true, Switches = true, Lever = true })
    end
end

-- Авто Барикада
function getNewestDot()
    for _, child in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        if child.Name == "Dot" then return child end
    end
    return nil
end

function doBarricade()
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
                frame.Position = UDim2.new(0, (boxAbs.X + boxSize.X * 0.5) - conAbs.X, 0, (boxAbs.Y + boxSize.Y * 0.5) - conAbs.Y)
                box.Size = UDim2.new(BarricadeSize, 0, BarricadeSize, 0)
            end
        end
    end
end

-- Бесконечная стамина
function UpdateStamina()
    if not InfiniteStaminaEnabled or CheatDisabled then return end
    local char = LocalPlayer.Character
    if char then
        local max = char:GetAttribute("MaxStamina") or 100
        if (char:GetAttribute("Stamina") or max) < max then
            char:SetAttribute("Stamina", max)
        end
    end
end

-- Невидимость
function ToggleInvis(state)
    if CheatDisabled and state then return end
    if not InvisModule then return end
    if state then
        pcall(function() InvisModule:Enable() end)
    else
        pcall(function() InvisModule:Disable() end)
    end
end

-- Невидимость для киллера (Mimic/Ennard)
function ApplyInvisibility(enabled)
    local char = LocalPlayer.Character
    if not char then return end
    if char:GetAttribute("Team") ~= "Killer" then return end
    local killerType = char:GetAttribute("Character")
    if killerType ~= "Mimic" and killerType ~= "Ennard" then return end

    if not enabled then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.Transparency = 0 end
        end
        return
    end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 1
        end
    end
end

-- No Blindness
function UpdateNoBlindness()
    if not NoBlindnessEnabled then return end
    local blind = ReplicatedStorage:FindFirstChild("Modules"):FindFirstChild("BlindnessModule")
    if blind then
        local atm = blind:FindFirstChildOfClass("Atmosphere")
        if atm then atm:Destroy() end
    end
end

-- Anti Confusion
CollectionService:GetInstanceAddedSignal("Confusion"):Connect(function(instance)
    if AntiConfusionEnabled then
        if instance == LocalPlayer.Character then
            CollectionService:RemoveTag(instance, "Confusion")
        end
    end
end)

-- Instant Prompt
function UpdateInstantPrompt()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            if InstantPromptEnabled then
                if obj.HoldDuration ~= 0.1 then
                    obj:SetAttribute("HoldDurationOld", obj.HoldDuration)
                    obj.HoldDuration = 0.1
                end
            else
                local old = obj:GetAttribute("HoldDurationOld")
                if old then obj.HoldDuration = old end
            end
        end
    end
end

-- Auto Shake Wire Eyes
function doShake(wireyesUI)
    task.spawn(function()
        local wireyesClient = wireyesUI:WaitForChild("WireyesClient")
        if wireyesClient then
            local remote = wireyesClient:WaitForChild("WireyesEvent")
            if remote then
                CanShake = false
                task.spawn(function() task.wait(ShakeTime); CanShake = true end)
                pcall(function() remote:FireServer("Shaking") end)
                task.wait(0.05)
                pcall(function() remote:FireServer("TakeOff", workspace:GetServerTimeNow()) end)
            end
        end
    end)
end

-- Tween для AutoFarm
function TweenTo(character, cf)
    local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    if not root then return end
    local distance = (root.Position - cf.Position).Magnitude
    local time = distance / 15
    local tween = TweenService:Create(root, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = cf})
    tween:Play()
    tween.Completed:Wait()
end

-- Auto Farm
function doAutoFarm()
    if not AutoFarmEnabled or CheatDisabled then return end
    local char = LocalPlayer.Character
    if tick() - LastAction < Cooldown then return end
    if not char or not char.PrimaryPart or char.Parent ~= workspace.PLAYERS.ALIVE then return end
    
    if CanGo then
        -- Батарейки
        if not LocalPlayer.PlayerGui:FindFirstChild("Gen") and not char:FindFirstChild("Battery") then
            for _, child in pairs(workspace.IGNORE:GetChildren()) do
                if child.Name == "Battery" and child:IsA("BasePart") then
                    local attachment = child:FindFirstChild("Attachment")
                    local prompt = attachment and attachment:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then
                        CanGo = false
                        LastAction = tick()
                        TweenTo(char, child.CFrame)
                        task.wait(0.1)
                        fireproximityprompt(prompt)
                        task.spawn(function() task.wait(prompt.HoldDuration + 0.25); CanGo = true end)
                        break
                    end
                end
            end
        end
        
        -- Генераторы
        if CanGo and workspace.GAME.Tasks.Gens.Enabled.Value then
            local gens = workspace.MAPS["GAME MAP"]:FindFirstChild("Generators")
            if gens and not LocalPlayer.PlayerGui:FindFirstChild("Gen") then
                for _, gen in pairs(gens:GetChildren()) do
                    if gen.Name == "Generator" and gen:GetAttribute("Progress") < 100 then
                        local root = gen:FindFirstChild("RootPart")
                        if root then
                            for _, atch in pairs(root:GetChildren()) do
                                if atch:IsA("Attachment") then
                                    local prompt = atch:FindFirstChildOfClass("ProximityPrompt")
                                    if prompt and prompt.Enabled then
                                        local point = gen:FindFirstChild(atch.Name)
                                        if point then
                                            CanGo = false
                                            LastAction = tick()
                                            TweenTo(char, point.CFrame)
                                            task.wait(1)
                                            fireproximityprompt(prompt)
                                            task.spawn(function() task.wait(prompt.HoldDuration + 0.75); CanGo = true end)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if not CanGo then break end
                end
            end
        end
        
        -- Выход
        if CanGo and workspace.GAME.CAN_ESCAPE.Value then
            local escapes = workspace.MAPS["GAME MAP"]:FindFirstChild("Escapes")
            if escapes then
                for _, part in pairs(escapes:GetChildren()) do
                    if part:IsA("BasePart") and part:GetAttribute("Enabled") then
                        CanGo = false
                        LastAction = tick()
                        TweenTo(char, part.CFrame)
                        task.spawn(function() task.wait(1); CanGo = true end)
                        break
                    end
                end
            end
        end
    end
end

-- Auto Escape
function doAutoEscape()
    if not AutoEscapeEnabled or CheatDisabled then return end
    if Teleported or not workspace.GAME.CAN_ESCAPE.Value then return end
    local char = LocalPlayer.Character
    if not char or char.Parent ~= workspace.PLAYERS.ALIVE then return end
    
    local escapes = workspace.MAPS["GAME MAP"]:FindFirstChild("Escapes")
    if escapes then
        for _, part in pairs(escapes:GetChildren()) do
            if part:IsA("BasePart") and part:GetAttribute("Enabled") and part:FindFirstChildOfClass("Highlight") and part:FindFirstChildOfClass("Highlight").Enabled then
                if char:FindFirstChild("HumanoidRootPart") then
                    Teleported = true
                    char.HumanoidRootPart.Anchored = true
                    char.PrimaryPart.CFrame = part.CFrame
                    task.spawn(function() wait(0.15); char.HumanoidRootPart.Anchored = false end)
                    wait(10)
                    Teleported = false
                end
            end
        end
    end
end

-- Auto Safe Spot
function doAutoSafeSpot()
    if not AutoSafeSpotEnabled or CheatDisabled or AutoFarmEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    if hum.Health > 35 then
        SavedCFrame = char.PrimaryPart.CFrame
    elseif hum.Health <= 35 then
        char.PrimaryPart.CFrame = CFrame.new(0, 500, 0)
    end
end

-- Fighter Auto Parry
workspace.DescendantAdded:Connect(function(child)
    if not FighterAutoParry then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if child:IsA("Highlight") and child.Name == "Highlight" and child.Parent == workspace.PLAYERS.KILLER:FindFirstChildOfClass("Model") then
        local char = LocalPlayer.Character
        if char and CanParry and not char:GetAttribute("IFrames") and not char:GetAttribute("InAbility") and not char:GetAttribute("Stun") and char:GetAttribute("Team") == "Survivor" and char:GetAttribute("Character") == "Survivor-Fighter" then
            local rootPart = child.Parent:FindFirstChild("RootPart")
            if rootPart and (rootPart.Position - hrp.Position).Magnitude <= 20 then
                CanParry = false
                task.spawn(function()
                    task.wait(0.5)
                    CanParry = true
                end)
                local Module = require(ReplicatedStorage.Modules.Warp).Client("Input")
                if Module then Module:Fire(true, {"Ability", 2}) end
            end
        end
    end
    
    -- Hitbox Expander
    if HitboxExpanderEnabled and child:IsA("BoxHandleAdornment") then
        child.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
    end
end)

-- ESP
function createHighlight(model, color)
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

function updateESP()
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
    
    if ESPFuseBoxes then
        pcall(function()
            local fuses = workspace:FindFirstChild("MAPS"):FindFirstChild("GAME MAP"):FindFirstChild("FuseBoxes")
            if fuses then
                for _, obj in pairs(fuses:GetChildren()) do
                    if obj:IsA("Model") and obj.PrimaryPart then
                        createHighlight(obj, Color3.fromRGB(0, 0, 255))
                    end
                end
            end
        end)
    end
    
    if ESPBattery then
        for _, obj in pairs(workspace.IGNORE:GetChildren()) do
            if obj:IsA("BasePart") and obj.Name == "Battery" then
                createHighlight(obj, Color3.fromRGB(0, 0, 255))
            end
        end
    end
    
    if ESPTraps then
        for _, obj in pairs(workspace.IGNORE:GetChildren()) do
            if obj:IsA("Model") and obj.Name == "Trap" and obj.PrimaryPart then
                createHighlight(obj, Color3.fromRGB(255, 0, 0))
            end
        end
    end
    
    if ESPWireEyes then
        for _, obj in pairs(workspace.IGNORE:GetChildren()) do
            if obj:IsA("Model") and obj.Name == "Minion" and obj.PrimaryPart then
                createHighlight(obj, Color3.fromRGB(255, 0, 0))
            end
        end
    end
end

-- Телепорт
function TeleportToPlayer(targetRoot)
    if CheatDisabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root and targetRoot and targetRoot.Parent then
        root.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 2)
    end
end

function TeleportToNearest()
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

function TeleportToExit()
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

function GetAllPlayersList()
    local list = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(list, {Name = plr.Name, Root = plr.Character.HumanoidRootPart})
        end
    end
    return list
end

-- Удаление дверей
function DeleteDoors()
    if workspace.MAPS:FindFirstChild("GAME MAP") then
        local doors = workspace.MAPS["GAME MAP"]:FindFirstChild("Doors")
        if doors then doors:Destroy() end
    end
end

-- Пропуск катсцены
function SkipCutscene()
    local rigs = ReplicatedStorage:FindFirstChild("Modules"):FindFirstChild("Cutscenes"):FindFirstChild("Rigs")
    if rigs then
        for _, name in pairs({"IntroCam", "IntroCamWithLight", "KillCam", "OutroCam"}) do
            local rig = rigs:FindFirstChild(name)
            if rig then rig:Destroy() end
        end
    end
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
Main.Size = UDim2.new(0, 650, 0, 550)
Main.Position = UDim2.new(0.5, -325, 0.5, -275)
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
Title.Text = "GIGA GUI v4.0"
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
CheatTab.Size = UDim2.new(0.33, -2, 1, 0)
CheatTab.Position = UDim2.new(0, 0, 0, 0)
CheatTab.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
CheatTab.Text = "ЧИТ"
CheatTab.TextColor3 = Color3.fromRGB(255, 255, 255)
CheatTab.Font = Enum.Font.GothamBold
CheatTab.TextSize = 14
CheatTab.Parent = TopTabs

local BindsTab = Instance.new("TextButton")
BindsTab.Size = UDim2.new(0.33, -2, 1, 0)
BindsTab.Position = UDim2.new(0.33, 2, 0, 0)
BindsTab.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
BindsTab.Text = "БИНДЫ"
BindsTab.TextColor3 = Color3.fromRGB(220, 220, 220)
BindsTab.Font = Enum.Font.GothamBold
BindsTab.TextSize = 14
BindsTab.Parent = TopTabs

local MiscTab = Instance.new("TextButton")
MiscTab.Size = UDim2.new(0.34, -2, 1, 0)
MiscTab.Position = UDim2.new(0.66, 2, 0, 0)
MiscTab.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
MiscTab.Text = "ПРОЧЕЕ"
MiscTab.TextColor3 = Color3.fromRGB(220, 220, 220)
MiscTab.Font = Enum.Font.GothamBold
MiscTab.TextSize = 14
MiscTab.Parent = TopTabs

-- Основной контейнер
local MainContainer = Instance.new("Frame")
MainContainer.Size = UDim2.new(1, 0, 1, -70)
MainContainer.Position = UDim2.new(0, 0, 0, 70)
MainContainer.BackgroundTransparency = 1
MainContainer.Parent = Main

-- Боковое меню
local SideMenu = Instance.new("Frame")
SideMenu.Size = UDim2.new(0, 140, 1, 0)
SideMenu.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
SideMenu.BorderSizePixel = 0
SideMenu.Parent = MainContainer

-- Контент
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Size = UDim2.new(1, -145, 1, 0)
ContentArea.Position = UDim2.new(0, 145, 0, 0)
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

-- Контейнеры для вкладок
local BindsContainer = Instance.new("ScrollingFrame")
BindsContainer.Size = UDim2.new(1, -145, 1, 0)
BindsContainer.Position = UDim2.new(0, 145, 0, 0)
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

local MiscContainer = Instance.new("ScrollingFrame")
MiscContainer.Size = UDim2.new(1, -145, 1, 0)
MiscContainer.Position = UDim2.new(0, 145, 0, 0)
MiscContainer.BackgroundTransparency = 1
MiscContainer.BorderSizePixel = 0
MiscContainer.ScrollBarThickness = 5
MiscContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
MiscContainer.CanvasSize = UDim2.new(0, 0, 0, 400)
MiscContainer.Visible = false
MiscContainer.Parent = MainContainer

local MiscInner = Instance.new("Frame")
MiscInner.Size = UDim2.new(1, 0, 1, 0)
MiscInner.BackgroundTransparency = 1
MiscInner.Parent = MiscContainer

-- Функции GUI
local function CreateSideButton(name, icon, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 38)
    btn.Position = UDim2.new(0, 5, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    btn.Text = icon .. "  " .. name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = SideMenu
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CreateToggle(name, y, default, callback, parent)
    parent = parent or ContentInner
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 280, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local state = default
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 20, 0, 20)
    box.Position = UDim2.new(1, -30, 0.5, -10)
    box.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 12, 0, 12)
    fill.Position = UDim2.new(0.5, -6, 0.5, -6)
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

local function CreateSlider(name, y, min, max, default, callback, parent)
    parent = parent or ContentInner
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 60)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local slider = Instance.new("TextBox")
    slider.Size = UDim2.new(1, -20, 0, 24)
    slider.Position = UDim2.new(0, 10, 0, 28)
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

local function CreateButton(name, y, callback, parent)
    parent = parent or ContentInner
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        if CheatDisabled then return end
        callback()
    end)
    return btn
end

local function CreateBindSetting(name, y, keybindName)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 45)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    frame.Parent = BindsInner
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 220, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0, 110, 0, 28)
    bindBtn.Position = UDim2.new(1, -122, 0.5, -14)
    bindBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    bindBtn.Text = Keybinds[keybindName] == nil and "None" or tostring(Keybinds[keybindName]):gsub("Enum.KeyCode.", "")
    bindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.TextSize = 12
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

local function ClearContent()
    for _, child in pairs(ContentInner:GetChildren()) do child:Destroy() end
end

local function ClearMisc()
    for _, child in pairs(MiscInner:GetChildren()) do child:Destroy() end
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
        empty.TextSize = 12
        empty.Parent = ContentInner
        return yStart + 35
    end
    
    local yPos = yStart
    for _, data in pairs(allPlayers) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 30)
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
        yPos = yPos + 35
    end
    
    return yPos
end

local function ShowSection(section)
    CurrentSection = section
    ClearContent()
    BindsContainer.Visible = false
    MiscContainer.Visible = false
    ContentArea.Visible = true
    SideMenu.Visible = true
    
    local y = 10
    
    if section == "Info" then
        local info = Instance.new("TextLabel")
        info.Size = UDim2.new(1, -20, 0, 220)
        info.Position = UDim2.new(0, 10, 0, y)
        info.BackgroundTransparency = 1
        info.Text = "GIGA GUI v4.0\n\nВСЕ ФУНКЦИИ ИЗ ZENTRIX + НЕВИДИМОСТЬ\n\n• Speed Hack • Fly • Noclip • Jump\n• ESP (Players, Killers, Gens, Fuses, Battery, Traps, WireEyes)\n• Невидимость • Авто-генератор • Авто-барикада\n• Беск. стамина • Авто-выход • Авто-ферма\n• Auto Safe Spot • No Blindness • Anti Confusion\n• Instant Prompt • Auto Shake WireEyes\n• Fighter Auto Parry • Hitbox Expander\n• Телепорты • Удаление дверей • Пропуск катсцен\n\nСоздатель: Gigaed"
        info.TextColor3 = Color3.fromRGB(200, 200, 200)
        info.Font = Enum.Font.Gotham
        info.TextSize = 12
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.TextYAlignment = Enum.TextYAlignment.Top
        info.Parent = ContentInner
        
        local footer = Instance.new("TextLabel")
        footer.Size = UDim2.new(1, -20, 0, 30)
        footer.Position = UDim2.new(0, 10, 0, 400)
        footer.BackgroundTransparency = 1
        footer.Text = "It's time to take your final bow!"
        footer.TextColor3 = Color3.fromRGB(255, 105, 180)
        footer.Font = Enum.Font.GothamBold
        footer.TextSize = 14
        footer.Parent = ContentInner
        
        ContentArea.CanvasSize = UDim2.new(0, 0, 0, 450)
        
    elseif section == "ESP" then
        CreateToggle("👥 Игроки (зелёные)", y, true, function(v) ESPPlayers = v end)
        y = y + 40
        CreateToggle("🔪 Киллеры (красные)", y, true, function(v) ESPKillers = v end)
        y = y + 40
        CreateToggle("⚡ Генераторы (жёлтые)", y, true, function(v) ESPGenerators = v end)
        y = y + 40
        CreateToggle("📦 Fuse Boxes (синие)", y, false, function(v) ESPFuseBoxes = v end)
        y = y + 40
        CreateToggle("🔋 Батарейки (синие)", y, false, function(v) ESPBattery = v end)
        y = y + 40
        CreateToggle("⚠️ Ловушки (красные)", y, false, function(v) ESPTraps = v end)
        y = y + 40
        CreateToggle("👁 Wire Eyes (красные)", y, false, function(v) ESPWireEyes = v end)
        y = y + 40
        CreateToggle("✅ Включить ESP", y, false, function(v) ESPEnabled = v end)
        ContentArea.CanvasSize = UDim2.new(0, 0, 0, y + 50)
        
    elseif section == "Movement" then
        CreateToggle("🚀 Speed Hack", y, false, function(v) SpeedEnabled = v; UpdateSpeed() end)
        y = y + 40
        CreateSlider("⚡ Скорость", y, 16, 150, 24, function(v) CustomSpeed = v; UpdateSpeed() end)
        y = y + 65
        CreateToggle("✈️ Полёт", y, false, function(v) FlyEnabled = v; if v then sFLY() else NOFLY() end end)
        y = y + 40
        CreateSlider("🕊️ Скорость полёта", y, 1, 10, 1, function(v) FlySpeed = v end)
        y = y + 65
        CreateToggle("🧱 Ноуклип", y, false, function(v) NoclipEnabled = v; UpdateNoclip() end)
        y = y + 40
        CreateToggle("🦘 Прыжок", y, false, function(v) JumpEnabled = v; UpdateJump() end)
        y = y + 40
        CreateSlider("📏 Сила прыжка", y, 0, 150, 50, function(v) JumpPower = v; UpdateJump() end)
        ContentArea.CanvasSize = UDim2.new(0, 0, 0, y + 70)
        
    elseif section == "Utility" then
        CreateToggle("👻 Невидимость", y, false, function(v) InvisEnabled = v; ToggleInvis(v) end)
        y = y + 40
        CreateToggle("🔧 Авто-генератор", y, false, function(v) AutoGenEnabled = v end)
        y = y + 40
        CreateToggle("🚧 Авто-барикада", y, false, function(v) AutoBarricadeEnabled = v end)
        y = y + 40
        CreateToggle("⚡ Беск. стамина", y, false, function(v) InfiniteStaminaEnabled = v end)
        y = y + 40
        CreateToggle("🚪 Авто-выход", y, false, function(v) AutoEscapeEnabled = v end)
        y = y + 40
        CreateToggle("🤖 Авто-ферма", y, false, function(v) AutoFarmEnabled = v end)
        y = y + 40
        CreateToggle("🛡️ Auto Safe Spot", y, false, function(v) AutoSafeSpotEnabled = v end)
        y = y + 40
        CreateToggle("👀 No Blindness", y, false, function(v) NoBlindnessEnabled = v end)
        y = y + 40
        CreateToggle("🌀 Anti Confusion", y, false, function(v) AntiConfusionEnabled = v end)
        y = y + 40
        CreateToggle("⚡ Instant Prompt", y, false, function(v) InstantPromptEnabled = v; UpdateInstantPrompt() end)
        y = y + 40
        CreateToggle("🔌 Auto Shake WireEyes", y, false, function(v) AutoShakeWireEyes = v end)
        y = y + 40
        CreateToggle("⚔️ Fighter Auto Parry", y, false, function(v) FighterAutoParry = v end)
        y = y + 40
        CreateToggle("📦 Hitbox Expander", y, false, function(v) HitboxExpanderEnabled = v end)
        y = y + 40
        CreateSlider("📏 Размер хитбокса", y, 0, 30, 15, function(v) HitboxSize = v end)
        y = y + 65
        CreateToggle("🎭 Invisible Killer", y, false, function(v) InvisibilityKiller = v; ApplyInvisibility(v) end)
        ContentArea.CanvasSize = UDim2.new(0, 0, 0, y + 50)
        
    elseif section == "Teleport" then
        local yPos = CreateTPList(y)
        y = yPos + 10
        CreateButton("🚪 ТП на выход", y, TeleportToExit)
        y = y + 40
        CreateButton("❌ Отключить ВСЁ", y, DisableAllCheats)
        ContentArea.CanvasSize = UDim2.new(0, 0, 0, y + 50)
    end
end

local function ShowMisc()
    ClearMisc()
    BindsContainer.Visible = false
    ContentArea.Visible = false
    MiscContainer.Visible = true
    SideMenu.Visible = false
    
    local y = 10
    CreateButton("🚪 Удалить двери", y, DeleteDoors, MiscInner)
    y = y + 40
    CreateButton("🎬 Пропустить катсцену", y, SkipCutscene, MiscInner)
    y = y + 40
    CreateSlider("⏱️ Время генератора", y, 0.5, 3, 1.25, function(v) TimeForGenerator = v end, MiscInner)
    y = y + 65
    CreateSlider("🔌 Shake Time", y, 0.1, 1, 0.5, function(v) ShakeTime = v end, MiscInner)
    y = y + 65
    CreateSlider("📦 Размер барикады", y, 0.3, 1.5, 0.3, function(v) BarricadeSize = v end, MiscInner)
    
    MiscContainer.CanvasSize = UDim2.new(0, 0, 0, y + 50)
end

-- Создание боковых кнопок
CreateSideButton("ℹ️ Инфо", "", 10, function() ShowSection("Info") end)
CreateSideButton("👁 ESP", "", 53, function() ShowSection("ESP") end)
CreateSideButton("🏃 Движение", "", 96, function() ShowSection("Movement") end)
CreateSideButton("🔧 Утилиты", "", 139, function() ShowSection("Utility") end)
CreateSideButton("📍 Телепорт", "", 182, function() ShowSection("Teleport") end)

ShowSection("Info")

-- Создание биндов
local bindsY = 10
local function createBind(name, key)
    local frame, btn, bindName = CreateBindSetting(name, bindsY, key)
    table.insert(bindElements, {Frame = frame, Button = btn, BindName = bindName})
    bindsY = bindsY + 50
end

createBind("Открыть/закрыть меню", "Menu")
createBind("Невидимость", "Invis")
createBind("Полёт", "Fly")
createBind("Телепорт", "Teleport")
createBind("Speed Hack", "Speed")
createBind("Отключить ВСЁ", "DisableAll")

BindsContainer.CanvasSize = UDim2.new(0, 0, 0, bindsY + 20)

-- Переключение вкладок
CheatTab.MouseButton1Click:Connect(function()
    CheatTab.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    BindsTab.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    MiscTab.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    BindsContainer.Visible = false
    MiscContainer.Visible = false
    ContentArea.Visible = true
    SideMenu.Visible = true
end)

BindsTab.MouseButton1Click:Connect(function()
    BindsTab.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    CheatTab.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    MiscTab.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    BindsContainer.Visible = true
    ContentArea.Visible = false
    MiscContainer.Visible = false
    SideMenu.Visible = false
end)

MiscTab.MouseButton1Click:Connect(function()
    MiscTab.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    CheatTab.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    BindsTab.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    ShowMisc()
end)

-- Обработчики
OpenBtn.MouseButton1Click:Connect(function()
    if GuiDestroyed or CheatDisabled then return end
    MenuVisible = not MenuVisible
    Main.Visible = MenuVisible
end)

UserInputService.InputBegan:Connect(function(inp, gp)
    if gp or GuiDestroyed then return end
    
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
    
    if Keybinds.Invis and inp.KeyCode == Keybinds.Invis then
        InvisEnabled = not InvisEnabled
        ToggleInvis(InvisEnabled)
    end
    
    if Keybinds.Fly and inp.KeyCode == Keybinds.Fly then
        FlyEnabled = not FlyEnabled
        if FlyEnabled then sFLY() else NOFLY() end
    end
    
    if Keybinds.Teleport and inp.KeyCode == Keybinds.Teleport then
        TeleportToNearest()
    end
    
    if Keybinds.Speed and inp.KeyCode == Keybinds.Speed then
        SpeedEnabled = not SpeedEnabled
        UpdateSpeed()
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    if GuiDestroyed or CheatDisabled then return end
    task.wait(0.2)
    if NoclipEnabled then UpdateNoclip() end
    if SpeedEnabled then UpdateSpeed() end
    if JumpEnabled then UpdateJump() end
    if InvisEnabled then task.wait(0.3); ToggleInvis(true) end
end)

-- Auto Highlight Killer Camera
LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
    if not AutoHighlightKiller then return end
    if child.Name == "Camera" then
        local main = child:WaitForChild("Main")
        if main then
            local locateRemote = main:WaitForChild("Locate")
            if locateRemote then
                task.wait(TimeAutoHighlight)
                local killerFolder = workspace:WaitForChild("PLAYERS"):WaitForChild("KILLER")
                local killer = killerFolder:FindFirstChildOfClass("Model")
                if killer then
                    local root = killer:FindFirstChild("HumanoidRootPart")
                    if root then locateRemote:FireServer(killer) end
                end
            end
        end
    end
    
    if child.Name == "Gen" then
        if AutoGenEnabled and not AutoFarmEnabled then
            task.wait(TimeForGenerator)
            if child and child:FindFirstChild("GeneratorMain") then
                child.GeneratorMain.Event:FireServer({ Wires = true, Switches = true, Lever = true })
            end
        end
        if AutoFarmEnabled then
            task.wait(TimeForGenerator)
            if child and child:FindFirstChild("GeneratorMain") then
                child.GeneratorMain.Event:FireServer({ Wires = true, Switches = true, Lever = true })
            end
        end
    end
end)

-- Auto Shake Wire Eyes
LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
    if AutoShakeWireEyes and CanShake and child.Name == "WireyesUI" then
        doShake(child)
    end
end)

RunService.RenderStepped:Connect(function()
    if GuiDestroyed or CheatDisabled then return end
    pcall(updateESP)
    pcall(doBarricade)
    pcall(UpdateStamina)
    pcall(UpdateNoBlindness)
    pcall(doAutoEscape)
    pcall(doAutoSafeSpot)
    pcall(doAutoFarm)
end)

spawn(function()
    while task.wait(0.3) do
        if GuiDestroyed or CheatDisabled then continue end
        if SpeedEnabled then pcall(UpdateSpeed) end
    end
end)

print("✅ Giga GUI v4.0 Loaded!")
print("🎮 ВСЕ функции из Zentrix добавлены!")
print("👻 Невидимость из Pastebin работает!")
print("⌨️ Бинды: Insert, X, Z, C, V, P")
