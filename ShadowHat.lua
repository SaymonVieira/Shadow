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

-- Cria a janela principal
local Window = Fluent:CreateWindow({
    Title = "ShadowHat 🎩 v4.3",
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
    Combat = Window:AddTab({ Title = "Combat", Icon = "sword" }),
    AntiCheat = Window:AddTab({ Title = "Anti-Cheat", Icon = "shield" }),
    Movement = Window:AddTab({ Title = "Movement", Icon = "run" }),
    Performance = Window:AddTab({ Title = "Performance", Icon = "bolt" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Variáveis globais
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variáveis compartilhadas
local ESPEnabled = false
local AimbotEnabled = false
local HitboxEnabled = false
local WallbangEnabled = false
local NoclipEnabled = false
local InvisibilityEnabled = false
local AntiCheatBypassEnabled = false
local HideNameEnabled = false
local LowGraphicsEnabled = false
local RemoveUnusedAssetsEnabled = false
local DisableShadowsEnabled = false
local CurrentTheme = "Dark"

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

-- Função para Aimbot
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
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Position)
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

-- Função para Invisibilidade
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

-- Função para Wallbang
local function enableWallbang(enabled)
    if enabled then
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    else
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Função para Anti-Cheat Bypass
local function enableAntiCheatBypass(enabled)
    if enabled then
        -- Exemplo básico de bypass (remover scripts de detecção)
        for _, script in pairs(workspace:GetDescendants()) do
            if script:IsA("Script") and script.Name == "AntiCheat" then
                script.Disabled = true
            end
        end
    else
        -- Reativa scripts desativados
        for _, script in pairs(workspace:GetDescendants()) do
            if script:IsA("Script") and script.Name == "AntiCheat" then
                script.Disabled = false
            end
        end
    end
end

-- Função para Ocultar Nome
local function hideName(enabled)
    if enabled then
        LocalPlayer.Name = "Anonymous10101"
        LocalPlayer.DisplayName = "Anonymous10101"
    else
        LocalPlayer.Name = LocalPlayer.Name -- Restaura o nome original
        LocalPlayer.DisplayName = LocalPlayer.DisplayName -- Restaura o nome exibido
    end
end

-- Função para melhorar o desempenho
local function optimizePerformance()
    -- Desativa gráficos pesados
    if LowGraphicsEnabled then
        settings().Rendering.QualityLevel = "Level01" -- Define a qualidade gráfica mais baixa
        for _, child in pairs(workspace:GetDescendants()) do
            if child:IsA("BasePart") then
                child.Material = Enum.Material.Plastic -- Altera materiais para algo mais leve
            elseif child:IsA("Decal") or child:IsA("Texture") then
                child:Destroy() -- Remove decalques e texturas
            elseif child:IsA("ParticleEmitter") then
                child.Enabled = false -- Desativa partículas
            elseif child:IsA("Light") then
                child.Enabled = false -- Desativa luzes
            end
        end
    else
        settings().Rendering.QualityLevel = "Level10" -- Restaura a qualidade gráfica padrão
    end

    -- Remove assets não utilizados
    if RemoveUnusedAssetsEnabled then
        for _, asset in pairs(workspace:GetDescendants()) do
            if not asset:IsDescendantOf(LocalPlayer.Character) and asset:IsA("Model") then
                asset:Destroy()
            end
        end
    end

    -- Desativa sombras
    if DisableShadowsEnabled then
        game.Lighting.GlobalShadows = false
    else
        game.Lighting.GlobalShadows = true
    end
end

-- Função para alterar o tema
local function changeTheme(theme)
    if theme == "Dark" then
        Window:SetTheme("Dark")
    elseif theme == "Light" then
        Window:SetTheme("Light")
    elseif theme == "Custom" then
        Window:SetTheme({
            Accent = Color3.fromRGB(255, 0, 0), -- Vermelho
            Background = Color3.fromRGB(30, 30, 30), -- Cinza escuro
            TextColor = Color3.fromRGB(255, 255, 255) -- Branco
        })
    end
end

-- Adiciona toggles na aba "Combat"
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
    end
end)

Tabs.Combat:AddToggle("AimbotEnabled", {
    Title = "Aimbot"
}):OnChanged(function(Value)
    AimbotEnabled = Value
    if AimbotEnabled then
        RunService.RenderStepped:Connect(aimbot)
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
            else
                removeHitbox(player)
            end
        end
    end
end)

Tabs.Combat:AddToggle("WallbangEnabled", {
    Title = "Wallbang"
}):OnChanged(function(Value)
    WallbangEnabled = Value
    enableWallbang(WallbangEnabled)
end)

Tabs.Combat:AddToggle("NoclipEnabled", {
    Title = "Noclip"
}):OnChanged(function(Value)
    NoclipEnabled = Value
    toggleNoclip(NoclipEnabled)
end)

Tabs.Combat:AddToggle("InvisibilityEnabled", {
    Title = "Invisibilidade"
}):OnChanged(function(Value)
    InvisibilityEnabled = Value
    toggleInvisibility(InvisibilityEnabled)
end)

-- Adiciona toggles na aba "Anti-Cheat"
Tabs.AntiCheat:AddToggle("AntiCheatBypassEnabled", {
    Title = "Anti-Cheat Bypass"
}):OnChanged(function(Value)
    AntiCheatBypassEnabled = Value
    enableAntiCheatBypass(AntiCheatBypassEnabled)
end)

Tabs.AntiCheat:AddToggle("HideNameEnabled", {
    Title = "Ocultar Nome"
}):OnChanged(function(Value)
    HideNameEnabled = Value
    hideName(HideNameEnabled)
end)

-- Adiciona toggles na aba "Performance"
Tabs.Performance:Add
