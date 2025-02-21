-- Script for Sea: Mythical Fruits and Hit Kill with GUI
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Variables
local guiEnabled = false
local mythicalFruitsEnabled = false
local hitKillEnabled = false

-- Function to create the GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SeaHubGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui

    -- Main Frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 200)
    frame.Position = UDim2.new(0.5, -125, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = screenGui

    -- Title Label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.Text = "Sea Hub"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 20
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = frame

    -- Mythical Fruits Button
    local fruitsButton = Instance.new("TextButton")
    fruitsButton.Size = UDim2.new(1, 0, 0, 40)
    fruitsButton.Position = UDim2.new(0, 0, 0, 40)
    fruitsButton.Text = "Get Mythical Fruits"
    fruitsButton.TextColor3 = Color3.new(1, 1, 1)
    fruitsButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
    fruitsButton.Font = Enum.Font.SourceSansBold
    fruitsButton.TextSize = 16
    fruitsButton.Parent = frame

    -- Hit Kill Button
    local hitKillButton = Instance.new("TextButton")
    hitKillButton.Size = UDim2.new(1, 0, 0, 40)
    hitKillButton.Position = UDim2.new(0, 0, 0, 90)
    hitKillButton.Text = "Enable Hit Kill"
    hitKillButton.TextColor3 = Color3.new(1, 1, 1)
    hitKillButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
    hitKillButton.Font = Enum.Font.SourceSansBold
    hitKillButton.TextSize = 16
    hitKillButton.Parent = frame

    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(1, 0, 0, 40)
    closeButton.Position = UDim2.new(0, 0, 0, 140)
    closeButton.Text = "Close GUI"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 16
    closeButton.Parent = frame

    -- Functionality for Mythical Fruits Button
    fruitsButton.MouseButton1Click:Connect(function()
        mythicalFruitsEnabled = not mythicalFruitsEnabled
        if mythicalFruitsEnabled then
            print("Mythical Fruits Enabled")
            -- Logic to give all mythical fruits
            -- Replace this with the actual logic to grant fruits
            warn("Granting all mythical fruits...")
        else
            print("Mythical Fruits Disabled")
        end
    end)

    -- Functionality for Hit Kill Button
    hitKillButton.MouseButton1Click:Connect(function()
        hitKillEnabled = not hitKillEnabled
        if hitKillEnabled then
            print("Hit Kill Enabled")
            -- Logic for one-hit kill
            -- Replace this with the actual logic for hit kill
            warn("Hit Kill Activated!")
        else
            print("Hit Kill Disabled")
        end
    end)

    -- Functionality for Close Button
    closeButton.MouseButton1Click:Connect(function()
        frame.Visible = false
        guiEnabled = false
        print("GUI Closed")
    end)

    return frame
end

-- Toggle GUI with key E
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
