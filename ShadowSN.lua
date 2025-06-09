-- Shadow 2.0
-- desenvolvido por saymon

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputSpace = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Configurações
local Settings = {
    ESPEnabled = true,
    HitboxEnabled = false,
    AimbotEnabled = false,
    WallhackEnabled = false,
    InvisibilityEnabled = false,
    InfJumpEnabled = false,
    SpeedEnabled = false,
    AntiCheatEnabled = false,
    ToggleKey = Enum.KeyCode.Insert,
    ToggleTouch = "TouchLongPress",
    HitboxSize = 10,
    AimbotSensitivity = 0.1,
    WallhackTransparency = 0.5,
    SpeedValue = 16
}

-- Interface (Rayfield UI)
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Shadow 2.0",
    LoadingTitle = "Shadow 2.0 - desenvolvido por saymon",
    LoadingSubtitle = "Carregando recursos...",
    ConfigurationSaving = {Enabled = true, FolderName = nil, FileName = "ShadowSettings"},
    Discord = {Enabled = false, Invite = "discord.gg/example", RememberInvites = false},
    KeySystem = false
})

local MainTab = Window:CreateTab("Principal")
local VisualTab = Window:CreateTab("Visuals")
local AimbotTab = Window:CreateTab("Aimbot")
local ExtraTab = Window:CreateTab("Extras")

-- Seção Visual
local ESPSection = VisualTab:CreateSection("ESP")
VisualTab:CreateToggle({
    Name = "ESP",
    CurrentValue = Settings.ESPEnabled,
    Flag = "ESP",
    Callback = function(Value) Settings.ESPEnabled = Value end
})

local HitboxSection = VisualTab:CreateSection("Hitbox")
VisualTab:CreateToggle({
    Name = "Hitbox",
    CurrentValue = Settings.HitboxEnabled,
    Flag = "Hitbox",
    Callback = function(Value) Settings.HitboxEnabled = Value end
})
VisualTab:CreateSlider({
    Name = "Tamanho da Hitbox",
    Range = {5, 50},
    Increment = 1,
    CurrentValue = Settings.HitboxSize,
    Flag = "HitboxSize",
    Callback = function(Value) Settings.HitboxSize = Value end
})

local WallhackSection = VisualTab:CreateSection("Noclip")
VisualTab:CreateToggle({
    Name = "Atravessar Paredes",
    CurrentValue = Settings.WallhackEnabled,
    Flag = "Wallhack",
    Callback = function(Value) Settings.WallhackEnabled = Value end
})

-- Seção Aimbot
local AimbotSection = AimbotTab:CreateSection("Aimbot")
AimbotTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = Settings.AimbotEnabled,
    Flag = "Aimbot",
    Callback = function(Value) Settings.AimbotEnabled = Value end
})
AimbotTab:CreateSlider({
    Name = "Sensibilidade",
    Range = {0.1, 1},
    Increment = 0.1,
    CurrentValue = Settings.AimbotSensitivity,
    Flag = "AimbotSensitivity",
    Callback = function(Value) Settings.AimbotSensitivity = Value end
})

-- Seção Extras
local ExtraSection = ExtraTab:CreateSection("Extras")
ExtraTab:CreateToggle({
    Name = "Invisibilidade",
    CurrentValue = Settings.InvisibilityEnabled,
    Flag = "Invisibility",
    Callback = function(Value) Settings.InvisibilityEnabled = Value end
})
ExtraTab:CreateToggle({
    Name = "Pulo Infinito",
    CurrentValue = Settings.InfJumpEnabled,
    Flag = "InfJump",
    Callback = function(Value) Settings.InfJumpEnabled = Value end
})
ExtraTab:CreateToggle({
    Name = "Velocidade",
    CurrentValue = Settings.SpeedEnabled,
    Flag = "Speed",
    Callback = function(Value) Settings.SpeedEnabled = Value end
})
ExtraTab:CreateSlider({
    Name = "Valor da Velocidade",
    Range = {16, 100},
    Increment = 1,
    CurrentValue = Settings.SpeedValue,
    Flag = "SpeedValue",
    Callback = function(Value) Settings.SpeedValue = Value end
})
ExtraTab:CreateToggle({
    Name = "Anti-Cheat",
    CurrentValue = Settings.AntiCheatEnabled,
    Flag = "AntiCheat",
    Callback = function(Value) Settings.AntiCheatEnabled = Value end
})

-- Funções
local function getClosestPlayer()
    local maxDist = math.huge
    local target = nil
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist < maxDist then
                maxDist = dist
                target = player
            end
        end
    end
    return target
end

local function ESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = player.Character.HumanoidRootPart
            if not humanoidRootPart:FindFirstChild("ESPBillboard") and Settings.ESPEnabled then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ESPBillboard"
                billboard.Parent = humanoidRootPart
                billboard.Size = UDim2.new(0, 100, 0, 50)
                billboard.AlwaysOnTop = true
                local text = Instance.new("TextLabel")
                text.Parent = billboard
                text.Size = UDim2.new(1, 0, 1, 0)
                text.Text = player.Name
                text.TextColor3 = Color3.new(1, 1, 1)
            elseif humanoidRootPart:FindFirstChild("ESPBillboard") and not Settings.ESPEnabled then
                humanoidRootPart:FindFirstChild("ESPBillboard"):Destroy()
            end
        end
    end
end

local function Hitbox()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = player.Character.HumanoidRootPart
            if Settings.HitboxEnabled then
                humanoidRootPart.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                humanoidRootPart.Transparency = 0.3
            else
                humanoidRootPart.Size = Vector3.new(2, 2, 1)
                humanoidRootPart.Transparency = 1
            end
        end
    end
end

local function Aimbot()
    if Settings.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local head = target.Character.Head
            local screenPoint = workspace.CurrentCamera:WorldToScreenPoint(head.Position)
            local mousePos = Vector2.new(Mouse.X, Mouse.Y)
            local targetPos = Vector2.new(screenPoint.X, screenPoint.Y)
            local moveDirection = (targetPos - mousePos).Unit * 100
            mousemoverel(moveDirection.X * Settings.AimbotSensitivity, moveDirection.Y * Settings.AimbotSensitivity)
        end
    end
end

-- Noclip corrigido (evita cair através do chão)
local function Wallhack()
    if Settings.WallhackEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        local rootPart = LocalPlayer.Character.HumanoidRootPart
        if humanoid and rootPart then
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            rootPart.CanCollide = false
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part ~= rootPart then
                    part.CanCollide = false
                end
            end
            -- Verifica colisão com o chão para evitar cair
            local ray = Ray.new(rootPart.Position, Vector3.new(0, -10, 0))
            local hit, position = workspace:FindPartOnRay(ray, LocalPlayer.Character)
            if hit and (rootPart.Position.Y - position.Y) < 2 then
                rootPart.Position = Vector3.new(rootPart.Position.X, position.Y + 2, rootPart.Position.Z)
            end
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            local rootPart = LocalPlayer.Character.HumanoidRootPart
            if humanoid and rootPart then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
                rootPart.CanCollide = true
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
end

-- Invisibilidade
local function Invisibility()
    if Settings.InvisibilityEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.9
            end
        end
    else
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                end
            end
        end
    end
end

-- Pulo Infinito melhorado (pulo alto)
local function InfJump()
    if Settings.InfJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            humanoid.JumpPower = 100 -- Ajuste para pulo alto
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        else
            humanoid.JumpPower = 50 -- Valor padrão
        end
    end
end

-- Velocidade
local function Speed()
    if Settings.SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        humanoid.WalkSpeed = Settings.SpeedValue
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = LocalPlayer.Character.Humanoid
            humanoid.WalkSpeed = 16
        end
    end
end

-- Anti-Cheat básico (detecta alterações suspeitas)
local function AntiCheat()
    if Settings.AntiCheatEnabled then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            if humanoid.WalkSpeed > 50 or humanoid.JumpPower > 100 then
                humanoid.WalkSpeed = 16
                humanoid.JumpPower = 50
                warn("Alteração suspeita detectada! Valores redefinidos.")
            end
        end
    end
end

-- Toggle
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Settings.ToggleKey then
        local newValue = not Settings.WallhackEnabled
        Settings.ESPEnabled = newValue
        Settings.HitboxEnabled = newValue
        Settings.AimbotEnabled = newValue
        Settings.WallhackEnabled = newValue
        Settings.InvisibilityEnabled = newValue
        Settings.InfJumpEnabled = newValue
        Settings.SpeedEnabled = newValue
        Settings.AntiCheatEnabled = newValue
    end
end)

UserInputService.TouchLongPress:Connect(function(touch)
    local newValue = not Settings.WallhackEnabled
    Settings.ESPEnabled = newValue
    Settings.HitboxEnabled = newValue
    Settings.AimbotEnabled = newValue
    Settings.WallhackEnabled = newValue
    Settings.InvisibilityEnabled = newValue
    Settings.InfJumpEnabled = newValue
    Settings.SpeedEnabled = newValue
    Settings.AntiCheatEnabled = newValue
end)

-- Loop
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        ESP()
        Hitbox()
        Aimbot()
        Wallhack()
        Invisibility()
        InfJump()
        Speed()
        AntiCheat()
    end
end)
