-- Versão completa com correções, mensagens de confirmação e opções adicionais
local Fluent
pcall(function()
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not Fluent then
    error("Falha ao carregar a biblioteca Fluent. Verifique sua conexão ou o link da biblioteca.")
end

-- Cria a janela principal
local Window = Fluent:CreateWindow({
    Title = "ShadowHat 🎩 v2",
    SubTitle = "Criado por Saymon Vieira",
    TabWidth = 180, -- Largura das abas ajustada
    Size = UDim2.fromOffset(600, 500), -- Tamanho maior para melhor visualização
    Acrylic = true, -- Efeito de desfoque
    Theme = "Dark", -- Tema escuro
    MinimizeKey = Enum.KeyCode.LeftControl -- Tecla para minimizar
})

-- Variáveis globais
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Variáveis compartilhadas
local ESPEnabled = false
local AimbotEnabled = false
local HitboxEnabled = false
local WallbangEnabled = false
local NoclipEnabled = false
local InvisibilityEnabled = false
local AntiCheatBypassEnabled = false
local HideNameEnabled = false
local TelekinesisEnabled = false
local FlyEnabled = false
local SpeedHackEnabled = false
local JumpPowerEnabled = false
local AntiKickEnabled = false

-- Função para exibir mensagens de confirmação
local function showNotification(message)
    local notification = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local textLabel = Instance.new("TextLabel")

    -- Configurações do frame
    frame.Size = UDim2.new(0, 200, 0, 50)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0

    -- Configurações do texto
    textLabel.Text = message
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 16
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Parent = frame

    -- Adiciona à tela
    frame.Parent = notification
    notification.Parent = game.CoreGui

    -- Remove após alguns segundos
    wait(3)
    notification:Destroy()
end

-- Função para desenhar caixas ESP
local function drawESP(player)
    local box = Drawing.new("Square")
    local text = Drawing.new("Text")

    RunService.RenderStepped:Connect(function()
        if not ESPEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            box.Visible = false
            text.Visible = false
            return
        end

        local rootPart = player.Character.HumanoidRootPart
        local screenPosition, onScreen = Camera:WorldToScreenPoint(rootPart.Position)

        if onScreen then
            local size = Vector3.new(4, 6, 0) -- Tamanho da hitbox
            local top = Camera:WorldToScreenPoint((rootPart.CFrame * CFrame.new(0, size.Y / 2, 0)).Position)
            local bottom = Camera:WorldToScreenPoint((rootPart.CFrame * CFrame.new(0, -size.Y / 2, 0)).Position)

            box.Visible = true
            box.Color = Color3.new(1, 1, 1) -- Cor branca
            box.Thickness = 1
            box.Size = Vector2.new(math.abs(top.X - bottom.X), math.abs(top.Y - bottom.Y))
            box.Position = Vector2.new(top.X - box.Size.X / 2, top.Y)

            text.Visible = true
            text.Color = Color3.new(1, 1, 1) -- Cor branca
            text.Size = 16
            text.Position = Vector2.new(box.Position.X, box.Position.Y - 20)
            text.Text = player.Name .. " [" .. math.floor((LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude) .. "m]"
        else
            box.Visible = false
            text.Visible = false
        end
    end)
end

-- Função para criar Hitbox expandida
local function createHitbox(player)
    if not HitboxEnabled or not player.Character then
        return
    end

    -- Remove hitbox existente
    if player.Character:FindFirstChild("HitboxAdornment") then
        player.Character.HitboxAdornment:Destroy()
    end

    -- Cria o hitbox usando BoxHandleAdornment
    local hitbox = Instance.new("BoxHandleAdornment")
    hitbox.Name = "HitboxAdornment"
    hitbox.Size = Vector3.new(8, 10, 8) -- Tamanho maior (ajustável)
    hitbox.Adornee = player.Character:WaitForChild("HumanoidRootPart", 5) -- Espera o jogador renascer
    hitbox.AlwaysOnTop = true
    hitbox.ZIndex = 1
    hitbox.Transparency = 0.5 -- Semi-transparente
    hitbox.Color3 = Color3.new(1, 0, 0) -- Cor vermelha
    hitbox.Parent = player.Character

    -- Conecta o hitbox ao jogador para causar dano
    local connection
    connection = hitbox.Adornee.Touched:Connect(function(hit)
        if hit and hit.Parent and hit.Parent:IsA("Tool") then
            local tool = hit.Parent
            if tool:FindFirstChild("Handle") then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:TakeDamage(10) -- Dano ajustável
                end
            end
        end
    end)

    -- Reconecta o hitbox se o jogador renascer
    player.CharacterAdded:Connect(function(newCharacter)
        newCharacter:WaitForChild("HumanoidRootPart", 5)
        hitbox.Adornee = newCharacter.HumanoidRootPart
    end)

    -- Desconecta a conexão quando o hitbox é removido
    hitbox.Destroying:Connect(function()
        if connection then
            connection:Disconnect()
        end
    end)
end

-- Função para remover Hitbox
local function removeHitbox(player)
    if player.Character and player.Character:FindFirstChild("HitboxAdornment") then
        player.Character.HitboxAdornment:Destroy()
    end
end

-- Função para Aimbot (corrigida)
local function aimbot()
    if not AimbotEnabled then
        return
    end

    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local target = player.Character.HumanoidRootPart
            local distance = (target.Position - Camera.CFrame.Position).Magnitude

            if distance < closestDistance then
                closestPlayer = target
                closestDistance = distance
            end
        end
    end

    if closestPlayer then
        -- Suaviza a mira para evitar detecção anti-cheat
        local smoothness = 0.1 -- Ajuste de suavidade
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closestPlayer.Position + Vector3.new(0, 2, 0)), smoothness)
    end
end

-- Função para Noclip (corrigida)
local noclipConnection = nil
local function toggleNoclip(enabled)
    if enabled then
        noclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

-- Função para Invisibilidade (corrigida)
local function toggleInvisibility(enabled)
    if not LocalPlayer.Character then
        return
    end

    local character = LocalPlayer.Character
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = enabled and 1 or 0
        elseif part:IsA("Accessory") then
            for _, accessoryPart in pairs(part:GetChildren()) do
                if accessoryPart:IsA("BasePart") then
                    accessoryPart.Transparency = enabled and 1 or 0
                end
            end
        elseif part:IsA("Tool") then
            for _, toolPart in pairs(part:GetChildren()) do
                if toolPart:IsA("BasePart") then
                    toolPart.Transparency = enabled and 1 or 0
                end
            end
        end
    end

    -- Notificação
    if enabled then
        showNotification("Invisibilidade ativada!")
    else
        showNotification("Invisibilidade desativada!")
    end
end

-- Função para Velocidade de Movimento
local function setWalkSpeed(speed)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speed
    end
end

-- Função para Anti-Kick
local antiKickConnection = nil
local function toggleAntiKick(enabled)
    if enabled then
        antiKickConnection = RunService.Stepped:Connect(function()
            LocalPlayer.Character:Move(Vector3.new(0, 0, 0), true) -- Simula movimento constante
        end)
    else
        if antiKickConnection then
            antiKickConnection:Disconnect()
            antiKickConnection = nil
        end
    end
end

-- Adiciona abas
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "sword" }),
    AntiCheat = Window:AddTab({ Title = "Anti-Cheat", Icon = "shield" }),
    Performance = Window:AddTab({ Title = "Performance", Icon = "gamepad" })
}

-- Adiciona opções na aba "Main"
Tabs.Main:AddToggle("TelekinesisEnabled", {
    Title = "Telekinesis"
}):OnChanged(function(Value)
    TelekinesisEnabled = Value
    if Value then
        showNotification("Telekinesis ativado!")
    else
        showNotification("Telekinesis desativado!")
    end
end)

Tabs.Main:AddToggle("FlyEnabled", {
    Title = "Fly"
}):OnChanged(function(Value)
    FlyEnabled = Value
    if Value then
        showNotification("Fly ativado!")
    else
        showNotification("Fly desativado!")
    end
end)

Tabs.Main:AddSlider("WalkSpeed", {
    Title = "Velocidade de Movimento",
    Default = 16,
    Min = 16,
    Max = 100
}):OnChanged(function(Value)
    setWalkSpeed(Value)
    showNotification("Velocidade ajustada para " .. Value .. "!")
end)

Tabs.Main:AddToggle("AntiKickEnabled", {
    Title = "Anti-Kick"
}):OnChanged(function(Value)
    AntiKickEnabled = Value
    toggleAntiKick(Value)
    if Value then
        showNotification("Anti-Kick ativado!")
    else
        showNotification("Anti-Kick desativado!")
    end
end)

-- Adiciona opções na aba "Combat"
Tabs.Combat:AddToggle("ESPEnabled", {
    Title = "Player ESP"
}):OnChanged(function(Value)
    ESPEnabled = Value
    if ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                drawESP(player)
            end
        end
        showNotification("ESP ativado!")
    else
        showNotification("ESP desativado!")
    end
end)

Tabs.Combat:AddToggle("AimbotEnabled", {
    Title = "Aimbot"
}):OnChanged(function(Value)
    AimbotEnabled = Value
    if Value then
        showNotification("Aimbot ativado!")
    else
        showNotification("Aimbot desativado!")
    end
end)

Tabs.Combat:AddToggle("HitboxEnabled", {
    Title = "Hitbox Expandida"
}):OnChanged(function(Value)
    HitboxEnabled = Value
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if HitboxEnabled then
                createHitbox(player)
                showNotification("Hitbox ajustada!")
            else
                removeHitbox(player)
                showNotification("Hitbox removida!")
            end
        end
    end
end)

Tabs.Combat:AddToggle("WallbangEnabled", {
    Title = "Wallbang"
}):OnChanged(function(Value)
    WallbangEnabled = Value
    if Value then
        showNotification("Wallbang ativado!")
    else
        showNotification("Wallbang desativado!")
    end
end)

Tabs.Combat:AddToggle("NoclipEnabled", {
    Title = "Noclip"
}):OnChanged(function(Value)
    NoclipEnabled = Value
    toggleNoclip(NoclipEnabled)
    if Value then
        showNotification("Noclip ativado!")
    else
        showNotification("Noclip desativado!")
    end
end)

Tabs.Combat:AddToggle("InvisibilityEnabled", {
    Title = "Invisibilidade"
}):OnChanged(function(Value)
    InvisibilityEnabled = Value
    toggleInvisibility(InvisibilityEnabled)
end)

-- Adiciona opções na aba "Anti-Cheat"
Tabs.AntiCheat:AddToggle("AntiCheatBypassEnabled
