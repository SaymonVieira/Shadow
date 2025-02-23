-- Serviços do Roblox
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Variáveis Globais
local player = Players.LocalPlayer
local guiEnabled = false

-- Função para criar o GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DeadRailsHubGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui

    -- Quadro Principal
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 150)
    frame.Position = UDim2.new(0.5, -125, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = screenGui

    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.Text = "Dead Rails Hub"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 20
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = frame

    -- Botão Bring GoldBar
    local bringGoldBarButton = Instance.new("TextButton")
    bringGoldBarButton.Size = UDim2.new(1, 0, 0, 40)
    bringGoldBarButton.Position = UDim2.new(0, 0, 0, 40)
    bringGoldBarButton.Text = "Bring GoldBar"
    bringGoldBarButton.TextColor3 = Color3.new(1, 1, 1)
    bringGoldBarButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
    bringGoldBarButton.Font = Enum.Font.SourceSansBold
    bringGoldBarButton.TextSize = 16
    bringGoldBarButton.Parent = frame

    -- Botão Fechar
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(1, 0, 0, 40)
    closeButton.Position = UDim2.new(0, 0, 0, 90)
    closeButton.Text = "Close GUI"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 16
    closeButton.Parent = frame

    -- Lógica do Botão Bring GoldBar
    bringGoldBarButton.MouseButton1Click:Connect(function()
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

        if humanoidRootPart then
            -- Procura por todos os itens chamados "GoldBar" no Workspace
            local goldBars = workspace:FindFirstChild("GoldBar") or workspace:FindFirstChild("GoldBars")
            if goldBars then
                -- Teletransporta cada GoldBar para o jogador
                for _, goldBar in pairs(goldBars:GetChildren()) do
                    if goldBar.Name == "GoldBar" then
                        goldBar.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 5, 0) -- Posiciona acima do jogador
                        print("GoldBar brought to player!")
                    end
                end
            else
                warn("No GoldBars found in the game!")
            end
        end
    end)

    -- Lógica do Botão Fechar
    closeButton.MouseButton1Click:Connect(function()
        frame.Visible = false
        guiEnabled = false
        print("GUI Closed")
    end)

    return frame
end

-- Alternar o GUI com a tecla E
local guiFrame = createGUI()
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end
    if input.KeyCode == Enum.KeyCode.E then
        guiEnabled = not guiEnabled
        guiFrame.Visible = guiEnabled
        if guiEnabled then
            print("GUI Opened")
        else
            print("GUI Closed")
        end
    end
end)
