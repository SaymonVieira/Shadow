-- Verifica se o HttpService está ativado
if not game:GetService("HttpService") then
    error("HttpService não está ativado. Ative-o nas configurações do jogo.")
end

-- Função para carregar bibliotecas externas
local function loadLibrary(url)
    local success, response = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)

    if not success then
        error("Erro ao carregar a biblioteca: " .. tostring(response))
    end

    return response
end

-- Carrega a biblioteca Fluent
local Fluent
pcall(function()
    Fluent = loadLibrary("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua")
end)

if not Fluent then
    error("Falha ao carregar a biblioteca Fluent. Verifique sua conexão ou o link da biblioteca.")
end

-- Carrega os addons da Fluent
local SaveManager = loadLibrary("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua")
local InterfaceManager = loadLibrary("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua")

-- Cria a janela principal
local Window = Fluent:CreateWindow({
    Title = "ShadowHat v2.9",
    SubTitle = "Criado por Saymon Vieira",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- Efeito de desfoque
    Theme = "Dark", -- Tema escuro
    MinimizeKey = Enum.KeyCode.LeftControl -- Tecla para minimizar
})

-- Adiciona abas
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

    -- Remove hitbox existente
    if player.Character:FindFirstChild("HitboxAdornment") then
        player.Character.HitboxAdornment:Destroy()
    end

    -- Cria o hitbox usando BoxHandleAdornment
    local hitbox = Instance.new("BoxHandleAdornment")
    hitbox.Name = "HitboxAdornment"
    hitbox.Size = Vector3.new(6, 8, 6) -- Tamanho grande (ajustável)
    hitbox.Adornee = player.Character.HumanoidRootPart
    hitbox.AlwaysOnTop = true
    hitbox.ZIndex = 1
    hitbox.Transparency = 0.5 -- Semi-transparente
    hitbox.Color3 = Color3.new(1, 0, 0) -- Cor vermelha
    hitbox.Parent = player.Character
end

-- Função para remover Hitbox
local function removeHitbox(player)
    if player.Character and player.Character:FindFirstChild("HitboxAdornment") then
        player.Character.HitboxAdornment:Destroy()
    end
end

-- Função para tornar o jogador invisível
local function toggleInvisibility(enabled)
    if not LocalPlayer.Character then
        return
    end

    local character = LocalPlayer.Character
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = enabled and 1 or 0
        end
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

-- Função para Fly GUI
local flyConnection = nil
local function toggleFly(enabled)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local character = LocalPlayer.Character
    local humanoidRootPart = character.HumanoidRootPart

    if enabled then
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
    else
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
    end
end

-- Adiciona toggles e botões na aba "Main"
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

Tabs.Main:AddToggle("HitboxEnabled", {
    Title = "Hitbox Expandida"
}):OnChanged(function(Value)
    HitboxEnabled = Value
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if HitboxEnabled then
                createHitbox(player)
            else
                removeHitbox(player)
            end
        end
    end
end)

Tabs.Main:AddToggle("InvisibilityEnabled", {
    Title = "Invisibilidade"
}):OnChanged(function(Value)
    InvisibilityEnabled = Value
    toggleInvisibility(InvisibilityEnabled)
end)

Tabs.Main:AddToggle("NoclipEnabled", {
    Title = "Noclip"
}):OnChanged(function(Value)
    NoclipEnabled = Value
    toggleNoclip(NoclipEnabled)
end)

Tabs.Main:AddToggle("FlyEnabled", {
    Title = "Fly"
}):OnChanged(function(Value)
    FlyEnabled = Value
    toggleFly(FlyEnabled)
end)

Tabs.Main:AddSlider("FlySpeed", {
    Title = "Velocidade do Fly",
    Min = 10,
    Max = 200,
    Default = 50
}):OnChanged(function(Value)
    FlySpeed = Value
end)

-- Adiciona informações na aba "Settings"
Tabs.Settings:AddParagraph("Sobre o Script", "ShadowHat foi criado por Saymon Vieira. Divirta-se explorando todas as funcionalidades deste script!")

-- Finaliza a interface
Fluent:Notify({
    Title = "ShadowHat",
    Content = "Script carregado com sucesso!"
})
