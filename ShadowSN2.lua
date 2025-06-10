-- Shadow 2.0 - Versão Atualizada para Mobile e Computador
-- Desenvolvido por saymon, revisado por Grok

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Configurações
local Settings = {
    ESPEnabled = false,
    HitboxEnabled = false,
    AimbotEnabled = false,
    NoclipEnabled = false,
    NoclipVerticalUp = false, -- Controle para subir (mobile/computador)
    NoclipVerticalDown = false, -- Controle para descer (mobile/computador)
    InvisibilityEnabled = false,
    MultiJumpEnabled = false,
    SpeedEnabled = false,
    AntiCheatEnabled = false,
    HitboxSize = 10,
    AimbotSensitivity = 0.1,
    AimbotSmoothness = 0.05,
    SpeedValue = 16,
    MaxJumps = 3,
    JumpCount = 0
}

-- Carregar Rayfield com tratamento de erro
local Rayfield
pcall(function()
    Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not Rayfield then
    warn("Falha ao carregar Rayfield. O menu não será exibido.")
    return
end

-- Interface (Rayfield UI)
local Window = Rayfield:CreateWindow({
    Name = "Shadow 2.0",
    LoadingTitle = "Shadow 2.0 - Desenvolvido por saymon",
    LoadingSubtitle = "Carregando recursos...",
    ConfigurationSaving = {Enabled = true, FolderName = nil, FileName = "ShadowSettings"},
    Discord = {Enabled = false, Invite = "discord.gg/example", RememberInvites = false},
    KeySystem = false
})

local PrincipalTab = Window:CreateTab("Principal")
local UniversalTab = Window:CreateTab("Universal")
local AntiCheatTab = Window:CreateTab("Anti-Cheat")

-- Seção Principal
local PrincipalSection = PrincipalTab:CreateSection("Controles")
PrincipalTab:CreateToggle({
    Name = "ESP",
    CurrentValue = Settings.ESPEnabled,
    Flag = "ESP",
    Callback = function(Value) Settings.ESPEnabled = Value end
})
PrincipalTab:CreateToggle({
    Name = "Hitbox",
    CurrentValue = Settings.HitboxEnabled,
    Flag = "Hitbox",
    Callback = function(Value) Settings.HitboxEnabled = Value end
})
PrincipalTab:CreateSlider({
    Name = "Tamanho da Hitbox",
    Range = {5, 50},
    Increment = 1,
    CurrentValue = Settings.HitboxSize,
    Flag = "HitboxSize",
    Callback = function(Value) Settings.HitboxSize = Value end
})
PrincipalTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = Settings.AimbotEnabled,
    Flag = "Aimbot",
    Callback = function(Value) Settings.AimbotEnabled = Value end
})
PrincipalTab:CreateSlider({
    Name = "Sensibilidade Aimbot",
    Range = {0.1, 1},
    Increment = 0.1,
    CurrentValue = Settings.AimbotSensitivity,
    Flag = "AimbotSensitivity",
    Callback = function(Value) Settings.AimbotSensitivity = Value end
})

-- Seção Universal
local UniversalSection = UniversalTab:CreateSection("Funcionalidades Universais")
UniversalTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = Settings.NoclipEnabled,
    Flag = "Noclip",
    Callback = function(Value) Settings.NoclipEnabled = Value end
})
UniversalTab:CreateToggle({
    Name = "Noclip - Subir",
    CurrentValue = Settings.NoclipVerticalUp,
    Flag = "NoclipVerticalUp",
    Callback = function(Value) Settings.NoclipVerticalUp = Value end
})
UniversalTab:CreateToggle({
    Name = "Noclip - Descer",
    CurrentValue = Settings.NoclipVerticalDown,
    Flag = "NoclipVerticalDown",
    Callback = function(Value) Settings.NoclipVerticalDown = Value end
})
UniversalTab:CreateToggle({
    Name = "Invisibilidade",
    CurrentValue = Settings.InvisibilityEnabled,
    Flag = "Invisibility",
    Callback = function(Value) Settings.InvisibilityEnabled = Value end
})
UniversalTab:CreateToggle({
    Name = "Multi Jump",
    CurrentValue = Settings.MultiJumpEnabled,
    Flag = "MultiJump",
    Callback = function(Value) Settings.MultiJumpEnabled = Value end
})
UniversalTab:CreateToggle({
    Name = "Velocidade",
    CurrentValue = Settings.SpeedEnabled,
    Flag = "Speed",
    Callback = function(Value) Settings.SpeedEnabled = Value end
})
UniversalTab:CreateSlider({
    Name = "Valor da Velocidade",
    Range = {16, 50}, -- Limitado para evitar detecção
    Increment = 1,
    CurrentValue = Settings.SpeedValue,
    Flag = "SpeedValue",
    Callback = function(Value) Settings.SpeedValue = Value end
})

-- Seção Anti-Cheat
local AntiCheatSection = AntiCheatTab:CreateSection("Proteção Anti-Cheat")
AntiCheatTab:CreateToggle({
    Name = "Ativar Proteção",
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
    if not Settings.ESPEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local esp = player.Character.HumanoidRootPart:FindFirstChild("ESPBillboard")
                if esp then esp:Destroy() end
            end
        end
        return
    end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = player.Character.HumanoidRootPart
            if not humanoidRootPart:FindFirstChild("ESPBillboard") then
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
                text.BackgroundTransparency = 1
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
                humanoidRootPart.Transparency = 0.7
                humanoidRootPart.BrickColor = BrickColor.new("White")
            else
                humanoidRootPart.Size = Vector3.new(2, 2, 1)
                humanoidRootPart.Transparency = 1
                humanoidRootPart.BrickColor = nil
            end
        end
    end
end

local function Aimbot()
    if not Settings.AimbotEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local head = target.Character.Head
        local headPosition = head.Position
        local cameraCFrame = Camera.CFrame
        local lookAtCFrame = CFrame.new(cameraCFrame.Position, headPosition)
        local smoothedCFrame = cameraCFrame:Lerp(lookAtCFrame, Settings.AimbotSmoothness)
        Camera.CFrame = smoothedCFrame
    end
end

local function Noclip()
    if not Settings.NoclipEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        return
    end
    local rootPart = LocalPlayer.Character.HumanoidRootPart
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid and rootPart then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        -- Movimento vertical via toggles
        local moveSpeed = Settings.SpeedValue or 16
        local verticalVelocity = Vector3.new(0, 0, 0)
        if Settings.NoclipVerticalUp then
            verticalVelocity = Vector3.new(0, moveSpeed, 0)
        elseif Settings.NoclipVerticalDown then
            verticalVelocity = Vector3.new(0, -moveSpeed, 0)
        end
        rootPart.Velocity = Vector3.new(rootPart.Velocity.X, verticalVelocity.Y, rootPart.Velocity.Z)
        -- Verificação robusta do chão
        local rayOrigin = rootPart.Position
        local rayDirection = Vector3.new(0, -10, 0)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        if raycastResult and (rootPart.Position.Y - raycastResult.Position.Y) < 3 then
            rootPart.CFrame = CFrame.new(rootPart.Position.X, raycastResult.Position.Y + 3, rootPart.Position.Z)
            rootPart.Velocity = Vector3.new(rootPart.Velocity.X, 0, rootPart.Velocity.Z)
        end
    end
end

local function Invisibility()
    if not LocalPlayer.Character then return end
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = Settings.InvisibilityEnabled and 0.9 or 0
        end
    end
end

local function MultiJump()
    if not Settings.MultiJumpEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    local humanoid = LocalPlayer.Character.Humanoid
    humanoid.StateChanged:Connect(function(oldState, newState)
        if newState == Enum.HumanoidStateType.Landed then
            Settings.JumpCount = 0
        end
    end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch or not Settings.MultiJumpEnabled then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    local humanoid = LocalPlayer.Character.Humanoid
    local rootPart = LocalPlayer.Character.HumanoidRootPart
    if Settings.JumpCount < Settings.MaxJumps and humanoid:GetState() ~= Enum.HumanoidStateType.Swimming then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        rootPart.Velocity = Vector3.new(rootPart.Velocity.X, 40, rootPart.Velocity.Z) -- Reduzido para evitar voo
        Settings.JumpCount = Settings.JumpCount + 1
    end
end)

local function Speed()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    local humanoid = LocalPlayer.Character.Humanoid
    local targetSpeed = Settings.SpeedEnabled and Settings.SpeedValue or 16
    humanoid.WalkSpeed = targetSpeed
end

local function AntiCheat()
    if not Settings.AntiCheatEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    local humanoid = LocalPlayer.Character.Humanoid
    -- Limitar valores suspeitos
    if humanoid.WalkSpeed > 50 then
        humanoid.WalkSpeed = 50
        Rayfield:Notify({
            Title = "Anti-Cheat",
            Content = "Velocidade limitada para evitar detecção!",
            Duration = 3
        })
    end
    if humanoid.JumpPower > 100 then
        humanoid.JumpPower = 50
        Rayfield:Notify({
            Title = "Anti-Cheat",
            Content = "Pulo limitado para evitar detecção!",
            Duration = 3
        })
    end
    -- Simular comportamento natural
    if Settings.SpeedEnabled and Settings.SpeedValue > 40 then
        local randomFluctuation = math.random(-1, 1)
        humanoid.WalkSpeed = math.clamp(humanoid.WalkSpeed + randomFluctuation, 16, 50)
    end
    -- Verificar jogos com anti-cheat conhecido
    local gamePlaceId = game.PlaceId
    local knownAntiCheatGames = { -- Exemplo, substituir por IDs reais
        123456789,
        987654321
    }
    for _, id in pairs(knownAntiCheatGames) do
        if gamePlaceId == id then
            Rayfield:Notify({
                Title = "Aviso de Anti-Cheat",
                Content = "Este jogo possui sistemas anti-cheat fortes. Use com cuidado!",
                Duration = 5
            })
            break
        end
    end
end

-- Loop Principal
RunService.RenderStepped:Connect(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    if Settings.ESPEnabled then ESP() end
    if Settings.HitboxEnabled then Hitbox() end
    if Settings.AimbotEnabled then Aimbot() end
    if Settings.NoclipEnabled then Noclip() end
    if Settings.InvisibilityEnabled then Invisibility() end
    if Settings.MultiJumpEnabled then MultiJump() end
    if Settings.SpeedEnabled then Speed() end
    if Settings.AntiCheatEnabled then AntiCheat() end
end)
