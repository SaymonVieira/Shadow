-- Carregar a biblioteca Fluent e gerenciadores de add-ons
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Criar a janela principal
local Window = Fluent:CreateWindow({
    Title = "ShadowHat v2.2",
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
local AimbotSmoothness = 0.1 -- Suavidade do Aimbot (ajustável)

-- Variáveis para armazenar a localização salva
local SavedLocation = nil

-- Função para salvar a localização atual
local function saveLocation()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        SavedLocation = LocalPlayer.Character.HumanoidRootPart.CFrame
        Fluent:Notify({
            Title = "Localização Salva",
            Content = "Sua posição foi salva com sucesso!"
        })
    else
        Fluent:Notify({
            Title = "Erro",
            Content = "Não foi possível salvar sua posição."
        })
    end
end

-- Função para teletransportar o jogador para a localização salva
local function teleportToSavedLocation()
    if SavedLocation and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = SavedLocation
        Fluent:Notify({
            Title = "Teletransporte",
            Content = "Você foi teletransportado para a posição salva!"
        })
    else
        Fluent:Notify({
            Title = "Erro",
            Content = "Nenhuma posição salva encontrada."
        })
    end
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

-- Função para o Aimbot
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
        local targetPosition = closestPlayer.Position
        local smoothness = AimbotSmoothness
        local cameraCFrame = Camera.CFrame

        local newLookVector = (targetPosition - cameraCFrame.Position).Unit
        local newCFrame = CFrame.new(cameraCFrame.Position, cameraCFrame.Position + newLookVector)

        Camera.CFrame =
