-- Shadow 2.0
-- desenvolvido por saymon

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Configurações
local Settings = {
    ESPEnabled = true,
    HitboxEnabled = false,
    AimbotEnabled = false,
    WallhackEnabled = false,
    ToggleKey = Enum.KeyCode.Insert, -- Tecla para toggle (computador)
    ToggleTouch = "TouchLongPress", -- Toggle para Android
    HitboxSize = 10,
    AimbotSensitivity = 0.1,
    WallhackTransparency = 0.5
}

-- Interface (usando Rayfield UI Library)
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Shadow 2.0",
    LoadingTitle = "Shadow 2.0 - desenvolvido por saymon",
    LoadingSubtitle = "Carregando recursos...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "ShadowSettings"
    },
    Discord = {
        Enabled = false,
        Invite = "discord.gg/example",
        RememberInvites = false
    },
    KeySystem = false
})

local MainTab = Window:CreateTab("Principal")
local VisualTab = Window:CreateTab("Visuals")
local AimbotTab = Window:CreateTab("Aimbot")

-- Seção Principal
local MainSection = MainTab:CreateSection("Controles")
local ToggleButton = MainTab:CreateToggle({
    Name = "Ativar/Desativar Tudo",
    CurrentValue = false,
    Flag = "ToggleAll",
    Callback = function(Value)
        Settings.ESPEnabled = Value
        Settings.HitboxEnabled = Value
        Settings.AimbotEnabled = Value
        Settings.WallhackEnabled = Value
    end
})

-- Seção Visual
local ESPSection = VisualTab:CreateSection("ESP")
VisualTab:CreateToggle({
    Name = "ESP",
    CurrentValue = Settings.ESPEnabled,
    Flag = "ESP",
    Callback = function(Value)
        Settings.ESPEnabled = Value
    end
})

local HitboxSection = VisualTab:CreateSection("Hitbox")
VisualTab:CreateToggle({
    Name = "Hitbox",
    CurrentValue = Settings.HitboxEnabled,
    Flag = "Hitbox",
    Callback = function(Value)
        Settings.HitboxEnabled = Value
    end
})
VisualTab:CreateSlider({
    Name = "Tamanho da Hitbox",
    Range = {5, 20},
    Increment = 1,
    CurrentValue = Settings.HitboxSize,
    Flag = "HitboxSize",
    Callback = function(Value)
        Settings.HitboxSize = Value
    end
})

local WallhackSection = VisualTab:CreateSection("Wallhack")
VisualTab:CreateToggle({
    Name = "Atravessar Paredes",
    CurrentValue = Settings.WallhackEnabled,
    Flag = "Wallhack",
    Callback = function(Value)
        Settings.WallhackEnabled = Value
    end
})
VisualTab:CreateSlider({
    Name = "Transparência",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = Settings.WallhackTransparency,
    Flag = "WallhackTransparency",
    Callback = function(Value)
        Settings.WallhackTransparency = Value
    end
})

-- Seção Aimbot
local AimbotSection = AimbotTab:CreateSection("Aimbot")
AimbotTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = Settings.AimbotEnabled,
    Flag = "Aimbot",
    Callback = function(Value)
        Settings.AimbotEnabled = Value
    end
})
AimbotTab:CreateSlider({
    Name = "Sensibilidade",
    Range = {0.1, 1},
    Increment = 0.1,
    CurrentValue = Settings.AimbotSensitivity,
    Flag = "AimbotSensitivity",
    Callback = function(Value)
        Settings.AimbotSensitivity = Value
    end
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
            else
                humanoidRootPart.Size = Vector3.new(2, 2, 1)
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

local function Wallhack()
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 1 and not part:IsDescendantOf(LocalPlayer.Character) then
            if Settings.WallhackEnabled then
                part.Transparency = Settings.WallhackTransparency
            else
                part.Transparency = part.OriginalTransparency or 0
            end
        end
    end
end

-- Toggle
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Settings.ToggleKey then
        local newValue = not (Settings.ESPEnabled and Settings.HitboxEnabled and Settings.AimbotEnabled and Settings.WallhackEnabled)
        Settings.ESPEnabled = newValue
        Settings.HitboxEnabled = newValue
        Settings.AimbotEnabled = newValue
        Settings.WallhackEnabled = newValue
        ToggleButton:Set(newValue)
    end
end)

-- Touch Toggle para Android
UserInputService.TouchLongPress:Connect(function(touch)
    local newValue = not (Settings.ESPEnabled and Settings.HitboxEnabled and Settings.AimbotEnabled and Settings.WallhackEnabled)
    Settings.ESPEnabled = newValue
    Settings.HitboxEnabled = newValue
    Settings.AimbotEnabled = newValue
    Settings.WallhackEnabled = newValue
    ToggleButton:Set(newValue)
end)

-- Loop
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        ESP()
        Hitbox()
        Aimbot()
        Wallhack()
    end
end)
