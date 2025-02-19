-- SymonHub: Token Generator with GUI
-- Features:
-- - Adds 100 tokens per second.
-- - Toggle to enable/disable the token generator.
-- - Basic GUI for mobile players.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local tokens = 0
local isTokenGeneratorActive = false

local function createGUI(player)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SymonHubGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 150)
    frame.Position = UDim2.new(0.5, -125, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local tokenLabel = Instance.new("TextLabel")
    tokenLabel.Size = UDim2.new(1, 0, 0, 30)
    tokenLabel.Position = UDim2.new(0, 0, 0, 0)
    tokenLabel.Text = "Tokens: 0"
    tokenLabel.TextColor3 = Color3.new(1, 1, 1)
    tokenLabel.BackgroundTransparency = 1
    tokenLabel.TextScaled = true
    tokenLabel.Parent = frame

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, 0, 0, 40)
    toggleButton.Position = UDim2.new(0, 0, 0, 40)
    toggleButton.Text = "Start Token Generator"
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.TextSize = 20
    toggleButton.Parent = frame

    toggleButton.MouseButton1Click:Connect(function()
        isTokenGeneratorActive = not isTokenGeneratorActive
        if isTokenGeneratorActive then
            toggleButton.Text = "Stop Token Generator"
            toggleButton.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
        else
            toggleButton.Text = "Start Token Generator"
            toggleButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
        end
    end)

    RunService.Heartbeat:Connect(function()
        tokenLabel.Text = "Tokens: " .. tokens
    end)
end

local function addTokens(player)
    while true do
        if isTokenGeneratorActive then
            tokens = tokens + 100
            if player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Tokens") then
                player.leaderstats.Tokens.Value = tokens
            end
        end
        wait(1)
    end
end

Players.PlayerAdded:Connect(function(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local tokensValue = Instance.new("IntValue")
    tokensValue.Name = "Tokens"
    tokensValue.Value = 0
    tokensValue.Parent = leaderstats

    createGUI(player)
    coroutine.wrap(addTokens)(player)
end)
