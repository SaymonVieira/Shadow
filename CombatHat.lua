-- Versão simplificada com Noclip, ESP (Nome + Vida + Linha) e Hitbox
local Fluent
pcall(function()
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not Fluent then
    error("Falha ao carregar a biblioteca Fluent. Verifique sua conexão ou o link da biblioteca.")
end

-- Cria a janela principal
local Window = Fluent:CreateWindow({
    Title = "CombatHat 🎩",
    SubTitle = "Criado por Saymon",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 400),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Variáveis globais
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variáveis compartilhadas
local ESPEnabled = false
local HitboxEnabled = false
local NoclipEnabled = false

-- Função para desenhar ESP com Nome, Vida e Linha
local function drawESP(player)
    local line = Drawing.new("Line")
    local text = Drawing.new("Text")

    RunService.RenderStepped:Connect(function()
        if not ESPEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            line.Visible = false
            text.Visible = false
            return
        end

        local rootPart = player.Character.HumanoidRootPart
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local screenPosition, onScreen = Camera:WorldToScreenPoint(rootPart.Position)

        if onScreen and humanoid then
            -- Desenha a linha conectando o jogador à tela
            line.Visible = true
            line.Color = Color3.new(1, 1, 1) -- Cor branca
            line.Thickness = 1
            line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) -- Centro da tela
            line.To = Vector2.new(screenPosition.X, screenPosition.Y)

            -- Exibe o nome e a vida do jogador
            text.Visible = true
            text.Color = Color3.new(1, 1, 1) -- Cor branca
            text.Size = 16
            text.Position = Vector2.new(screenPosition.X, screenPosition.Y - 20)
            text.Text = string.format("%s [%d/%d]", player.Name, math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
        else
            line.Visible = false
            text.Visible = false
        end
    end)
end

-- Função para criar Hitbox expandida (baseado no exemplo funcional)
local HeadSize = 20 -- Tamanho do hitbox
local IsDisabled = true -- Ativa ou desativa o script
local IsTeamCheckEnabled = false -- Verifica se o jogador é do mesmo time

RunService.RenderStepped:Connect(function()
    if IsDisabled then
        return
    end

    local localPlayer = LocalPlayer
    if not localPlayer then
        return
    end

    local localPlayerTeam = localPlayer.Team

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and (not IsTeamCheckEnabled or player.Team ~= localPlayerTeam) then
            local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.Size = Vector3.new(HeadSize, HeadSize, HeadSize)
                humanoidRootPart.Transparency = 0.7
                humanoidRootPart.BrickColor = BrickColor.new("Really blue")
                humanoidRootPart.Material = Enum.Material.Neon
                humanoidRootPart.CanCollide = false
            end
        end
    end
end)

-- Função para remover Hitbox
local function removeHitbox(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local humanoidRootPart = player.Character.HumanoidRootPart
        humanoidRootPart.Size = Vector3.new(2, 2, 1) -- Restaura o tamanho original
        humanoidRootPart.Transparency = 0
        humanoidRootPart.BrickColor = BrickColor.new("Medium stone grey")
        humanoidRootPart.Material = Enum.Material.Plastic
        humanoidRootPart.CanCollide = true
    end
end

-- Função para Noclip
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

-- Adiciona abas
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" })
}

-- Adiciona opções na aba "Main"
Tabs.Main:AddToggle("ESPEnabled", {
    Title = "Player ESP (Nome + Vida + Linha)"
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

Tabs.Main:AddToggle("HitboxEnabled", {
    Title = "Hitbox Expandida"
}):OnChanged(function(Value)
    IsDisabled = not Value
end)

Tabs.Main:AddToggle("NoclipEnabled", {
    Title = "Noclip"
}):OnChanged(function(Value)
    NoclipEnabled = Value
    toggleNoclip(NoclipEnabled)
end)

print("CombatHat 🎩 (Noclip + ESP + Hitbox) carregado com sucesso!")
