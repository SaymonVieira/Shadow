-- SymonHub: Token Generator for Educational Purposes
-- Features:
-- - Adds 100 tokens per second.
-- - Toggle to enable/disable the token generator.
-- - Basic GUI for mobile players.

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables
local tokens = 0
local isTokenGeneratorActive = false

-- Function to create GUI
local function createGUI(player)
    -- Create a ScreenGui for the player
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SymonHubGUI"
    screenGui.Parent = player.PlayerGui

    -- Create a Frame for the GUI
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 100)
    frame.Position = UDim2.new(0.5, -100, 0.5, -50)
    frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    -- Create a TextLabel to display tokens
    local tokenLabel = Instance.new("TextLabel")
    tokenLabel.Size = UDim2.new(1, 0, 0, 30)
    tokenLabel.Position = UDim2.new(0, 0, 0, 0)
    tokenLabel.Text = "Tokens: 0"
    tokenLabel.TextColor3 = Color3.new(1, 1, 1)
    tokenLabel.BackgroundTransparency = 1
    tokenLabel.TextScaled = true
    tokenLabel.Parent = frame

    -- Create a Toggle Button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, 0, 0, 30)
    toggleButton.Position = UDim2.new(0, 0, 0, 40)
    toggleButton.Text = "Start Token Generator"
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.BackgroundColor3 = Color3.new(0.1, 0.5, 0.1)
    toggleButton.Parent = frame

    -- Toggle functionality
    toggleButton.MouseButton1Click:Connect(function()
        isTokenGeneratorActive = not isTokenGeneratorActive
        if isTokenGeneratorActive then
            toggleButton.Text = "Stop Token Generator"
            toggleButton.BackgroundColor3 = Color3.new(0.5, 0.1, 0.1)
        else
            toggleButton.Text = "Start Token Generator"
            toggleButton.BackgroundColor3 = Color3.new(0.1, 0.5, 0.1)
        end
    end)

    -- Update token label
    RunService.Heartbeat:Connect(function()
        tokenLabel.Text = "Tokens: " .. tokens
    end)
end

-- Function to add tokens
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

-- Player setup
Players.PlayerAdded:Connect(function(player)
    -- Create leaderstats folder
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    -- Create Tokens variable
    local tokensValue = Instance.new("IntValue")
    tokensValue.Name = "Tokens"
    tokensValue.Value = 0
    tokensValue.Parent = leaderstats

    -- Create GUI
    createGUI(player)

    -- Start token generator loop
    coroutine.wrap(addTokens)(player)
end)
