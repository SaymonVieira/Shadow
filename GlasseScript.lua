-- Script para Detecção de Vidros Falsos no Jogo da Ponte de Vidro
-- Autor: Qwen

-- Serviços do Roblox
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Variáveis Globais
local player = Players.LocalPlayer
local guiEnabled = false
local isDragging = false
local offset = Vector2.new(0, 0)

-- Função para criar a GUI
local function createGui()
    -- Criar a tela principal
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GlassDetectorGui"
    screenGui.ResetOnSpawn = false
    screenGui.Enabled = false
    screenGui.Parent = player.PlayerGui

    -- Frame principal
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 150)
    frame.Position = UDim2.new(0.5, -100, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui

    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Detector de Vidros"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.Parent = frame

    -- Informações sobre os vidros
    local info = Instance.new("TextLabel")
    info.Name = "Info"
    info.Size = UDim2.new(1, 0, 0, 80)
    info.Position = UDim2.new(0, 0, 0, 40)
    info.BackgroundTransparency = 1
    info.Text = "Pressione 'E' para ativar.\nToque nos vidros para detectar."
    info.TextColor3 = Color3.fromRGB(255, 255, 255)
    info.Font = Enum.Font.SourceSans
    info.TextSize = 14
    info.TextWrapped = true
    info.Parent = frame

    -- Botão de Fechar
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 14
    closeButton.Parent = frame

    -- Função para fechar o GUI
    closeButton.MouseButton1Click:Connect(function()
        screenGui.Enabled = false
        guiEnabled = false
    end)

    return screenGui, frame
end

-- Criar a GUI
local screenGui, frame = createGui()

-- Função para detectar vidros falsos
local function detectFalseGlass(part)
    if part and part:IsA("BasePart") then
        local transparency = part.Transparency
        if transparency > 0.5 then
            return "Falso"
        else
            return "Verdadeiro"
        end
    end
    return "Desconhecido"
end

-- Evento de toque nos vidros
local function onTouch(input, processed)
    if guiEnabled and input.UserInputType == Enum.UserInputType.Touch then
        local target = game.Players.LocalPlayer:GetMouse().Target
        if target then
            local result = detectFalseGlass(target)
            frame.Info.Text = "Vidro Detectado: " .. result
        end
    end
end

-- Ativar/Desativar GUI com a tecla E
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.E then
        guiEnabled = not guiEnabled
        screenGui.Enabled = guiEnabled
        if guiEnabled then
            frame.Info.Text = "Detector ativado!\nToque nos vidros para detectar."
        else
            frame.Info.Text = "Detector desativado."
        end
    end
end)

-- Movimentação da GUI no Mobile
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        offset = input.Position - frame.Position
    end
end)

frame.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.Touch then
        local newPosition = input.Position - offset
        frame.Position = UDim2.new(0, newPosition.X, 0, newPosition.Y)
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

-- Conectar evento de toque
UserInputService.TouchTap:Connect(onTouch)

print("Script do Detector de Vidros iniciado!")
