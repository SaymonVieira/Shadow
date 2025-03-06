-- Versão completa e estável do ShadowHat 🎩 v2
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
    TabWidth = 180,
    Size = UDim2.fromOffset(600, 500),
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

-- Função para exibir mensagens de confirmação
local function showNotification(message)
    local notification = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local textLabel = Instance.new("TextLabel")

    frame.Size = UDim2.new(0, 200, 0, 50)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0

    textLabel.Text = message
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 16
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Parent = frame

    frame.Parent = notification
    notification.Parent = game.CoreGui

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
            local size = Vector3.new(4, 6, 0)
            local top = Camera:WorldToScreenPoint((rootPart.CFrame * CFrame.new(0, size.Y / 2, 0)).Position)
            local bottom = Camera:WorldToScreenPoint((rootPart.CFrame * CFrame.new(0, -size.Y / 2, 0)).Position)

            box.Visible = true
            box.Color = Color3.new(1, 1, 1)
            box.Thickness = 1
            box.Size = Vector2.new(math.abs(top.X - bottom.X), math.abs(top.Y - bottom.Y))
            box.Position = Vector2.new(top.X - box.Size.X / 2, top.Y)

            text.Visible = true
            text.Color = Color3.new(1, 1, 1)
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
    hitbox.Size = Vector3.new(8, 10, 8)
    hitbox.Adornee = player.Character:WaitForChild("HumanoidRootPart", 5)
    hitbox.AlwaysOnTop = true
    hitbox.ZIndex = 1
    hitbox.Transparency = 0.5
    hitbox.Color3 = Color3.new(1, 0, 0)
    hitbox.Parent = player.Character

    -- Conecta o hitbox ao jogador para causar dano
    local connection
    connection = hitbox.Adornee.Touched:Connect(function(hit)
        if hit and hit.Parent and hit.Parent:IsA("Tool") then
            local tool = hit.Parent
            if tool:FindFirstChild("Handle") then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:TakeDamage(10)
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
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Position + Vector3.new(0, 2, 0))
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
        -- Remove scripts de detecção
        for _, script in pairs(workspace:GetDescendants()) do
            if script:IsA("Script") and script.Name == "AntiCheat" then
                script.Disabled = true
            end
        end

        -- Oculta logs
        game:SetPlaceID(0)
        setfpscap(60)
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
        LocalPlayer.Name = LocalPlayer.Name
        LocalPlayer.DisplayName = LocalPlayer.DisplayName
    end
end

-- Função para Telekinesis (Mobile)
local telekinesisConnection = nil
local selectedObject = nil
local function toggleTelekinesis(enabled)
    if enabled then
        telekinesisConnection = UserInputService.TouchStarted:Connect(function(touch, gameProcessed)
            local target = Mouse.Target
            if target and target.Parent then
                selectedObject = target
            end
        end)

        RunService.RenderStepped:Connect(function()
            if selectedObject then
                selectedObject.CFrame = CFrame.new(Mouse.Hit.Position)
            end
        end)
    else
        if telekinesisConnection then
            telekinesisConnection:Disconnect()
            telekinesisConnection = nil
        end
        selectedObject = nil
    end
end

-- Função para Fly
local flyConnection = nil
local function toggleFly(enabled)
    if enabled then
        local speed = 50
        local velocity = Vector3.new(0, 0, 0)

        flyConnection = RunService.RenderStepped:Connect(function()
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                return
            end

            local rootPart = LocalPlayer.Character.HumanoidRootPart

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                velocity = velocity + rootPart.CFrame.LookVector * speed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                velocity = velocity - rootPart.CFrame.LookVector * speed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                velocity = velocity - rootPart.CFrame.RightVector * speed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                velocity = velocity + rootPart.CFrame.RightVector * speed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                velocity = velocity + Vector3.new(0, speed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                velocity = velocity - Vector3.new(0, speed, 0)
            end

            rootPart.Velocity = velocity
            velocity = velocity * 0.9
        end)
    else
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
    end
end

-- Função para Speed Hack
local function toggleSpeedHack(enabled)
    if enabled then
        LocalPlayer.Character.Humanoid.WalkSpeed = 100
    else
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end

-- Função para Jump Power
local function toggleJumpPower(enabled)
    if enabled then
        LocalPlayer.Character.Humanoid.JumpPower = 100
    else
        LocalPlayer.Character.Humanoid.JumpPower = 50
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
    toggleTelekinesis(TelekinesisEnabled)
    showNotification("Telekinesis " .. (Value and "ativado!" or "desativado!"))
end)

Tabs.Main:AddToggle("FlyEnabled", {
    Title = "Fly"
}):OnChanged(function(Value)
    FlyEnabled = Value
    toggleFly(FlyEnabled)
    showNotification("Fly " .. (Value and "ativado!" or "desativado!"))
end)

Tabs.Main:AddToggle("SpeedHackEnabled", {
    Title = "Speed Hack"
}):OnChanged(function(Value)
    SpeedHackEnabled = Value
    toggleSpeedHack(SpeedHackEnabled)
    showNotification("Speed Hack " .. (Value and "ativado!" or "desativado!"))
end)

Tabs.Main:AddToggle("JumpPowerEnabled", {
    Title = "Jump Power"
}):OnChanged(function(Value)
    JumpPowerEnabled = Value
    toggleJumpPower(JumpPowerEnabled)
    showNotification("Jump Power " .. (Value and "ativado!" or "desativado!"))
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
    if AimbotEnabled then
        RunService.RenderStepped:Connect(aim
