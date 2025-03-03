-- Carregar a biblioteca Fluent e gerenciadores de add-ons
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Criar a janela principal
local Window = Fluent:CreateWindow({
    Title = "ShadowHat v2.6",
    SubTitle = "by Saymon Vieira",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- Efeito de desfoque
    Theme = "Dark", -- Tema escuro
    MinimizeKey = Enum.KeyCode.LeftControl -- Tecla para minimizar
})

-- Adicionar abas
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Variáveis globais
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPEnabled = false
local AimbotEnabled = false
local HitboxEnabled = false
local InvisibilityEnabled = false
local NoclipEnabled = false
local FlyEnabled = false
local FlySpeed = 50 -- Velocidade inicial do voo
local FlyControls = {} -- Armazena os controles do Fly GUI

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
    if not HitboxEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    -- Verifica se já existe uma hitbox para evitar duplicatas
    if player.Character:FindFirstChild("Hitbox") then
        player.Character.Hitbox:Destroy()
    end

    -- Cria a hitbox
    local hitbox = Instance.new("Part")
    hitbox.Name = "Hitbox"
    hitbox.Size = Vector3.new(6, 8, 6) -- Tamanho grande (ajustável)
    hitbox.Anchored = false
    hitbox.CanCollide = false
    hitbox.Transparency = 0.7 -- Semi-transparente
    hitbox.Color = Color3.new(1, 0, 0) -- Cor vermelha
    hitbox.Parent = player.Character

    -- Centraliza a hitbox no jogador
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = player.Character.HumanoidRootPart
    weld.Part1 = hitbox
    weld.Parent = hitbox

    -- Ajusta a posição da hitbox para ficar dentro do jogador
    hitbox.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 0) -- Centralizado
end

-- Função para tornar o jogador invisível
local function toggleInvisibility(enabled)
    if not LocalPlayer.Character then
        return
    end

    local character = LocalPlayer.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")

    if enabled then
        -- Desativa a hitbox e outras partes visíveis
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 1 -- Torna todas as partes invisíveis
            end
        end

        -- Remove a hitbox expandida, se existir
        if character:FindFirstChild("Hitbox") then
            character.Hitbox:Destroy()
        end
    else
        -- Restaura a visibilidade das partes
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 0 -- Restaura a transparência padrão
            end
        end

        -- Recria a hitbox, se necessário
        if HitboxEnabled then
            createHitbox(LocalPlayer)
        end
    end
end

-- Função para Noclip
local noclipConnection = nil
local function toggleNoclip(enabled)
    if enabled then
        -- Habilita o Noclip
        noclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false -- Desativa colisões
                    end
                end
            end
        end)
        Fluent:Notify({
            Title = "Noclip",
            Content = "Noclip ativado!"
        })
    else
        -- Desativa o Noclip
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        Fluent:Notify({
            Title = "Noclip",
            Content = "Noclip desativado!"
        })
    end
end

-- Função para Fly GUI
local flyConnection = nil
local function toggleFly(enabled)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local character = LocalPlayer.Character
    local humanoidRootPart = character.HumanoidRootPart

    if enabled then
        -- Habilita o Fly
        local velocity = Vector3.new(0, 0, 0)
        flyConnection = RunService.RenderStepped:Connect(function()
            if FlyControls.Forward then
                velocity = velocity + humanoidRootPart.CFrame.LookVector * FlySpeed
            end
            if FlyControls.Backward then
                velocity = velocity - humanoidRootPart.CFrame.LookVector * FlySpeed
            end
            if FlyControls.Left then
                velocity = velocity - humanoidRootPart.CFrame.RightVector * FlySpeed
            end
            if FlyControls.Right then
                velocity = velocity + humanoidRootPart.CFrame.RightVector * FlySpeed
            end
            if FlyControls.Up then
                velocity = velocity + Vector3.new(0, FlySpeed, 0)
            end
            if FlyControls.Down then
                velocity = velocity - Vector3.new(0, FlySpeed, 0)
            end

            humanoidRootPart.Velocity = velocity
        end)
        Fluent:Notify({
            Title = "Fly",
            Content = "Fly ativado!"
        })
    else
        -- Desativa o Fly
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        Fluent:Notify({
            Title = "Fly",
            Content = "Fly desativado!"
        })
    end
end

-- Toggle para ativar/desativar ESP
Tabs.Main:AddToggle("ESPEnabled", {
    Title = "Player ESP"
}):OnChanged(function(Value)
    ESPEnabled = Value
    if ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                drawESP(player)
            end
        end
    end
end)

-- Toggle para ativar/desativar Hitbox
Tabs.Main:AddToggle("HitboxEnabled", {
    Title = "Hitbox Expandida"
}):OnChanged(function(Value)
    HitboxEnabled = Value
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if HitboxEnabled then
                createHitbox(player)
            else
                if player.Character:FindFirstChild("Hitbox") then
                    player.Character.Hitbox:Destroy()
                end
            end
        end
    end
end)

-- Toggle para ativar/desativar Invisibilidade
Tabs.Main:AddToggle("InvisibilityEnabled", {
    Title = "Invisibilidade"
}):OnChanged(function(Value)
    InvisibilityEnabled = Value
    toggleInvisibility(InvisibilityEnabled)
end)

-- Toggle para ativar/desativar Noclip
Tabs.Main:AddToggle("NoclipEnabled", {
    Title = "Noclip"
}):OnChanged(function(Value)
    NoclipEnabled = Value
    toggleNoclip(NoclipEnabled)
end)

-- Toggle para ativar/desativar Fly
Tabs.Main:AddToggle("FlyEnabled", {
    Title = "Fly"
}):OnChanged(function(Value)
