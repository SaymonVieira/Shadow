-- Roblox Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Global Variables
local player = Players.LocalPlayer
local guiEnabled = false
local noCooldownEnabled = false
local hitboxEnabled = false

-- Function to create the GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UniversalHubGUI"
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
    titleLabel.Text = "Universal Hub"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 20
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = frame

    -- No Cooldown Button
    local noCooldownButton = Instance.new("TextButton")
    noCooldownButton.Size = UDim2.new(1, 0, 0, 40)
    noCooldownButton.Position = UDim2.new(0, 0, 0, 40)
    noCooldownButton.Text = "Enable No Cooldown"
    noCooldownButton.TextColor3 = Color3.new(1, 1, 1)
    noCooldownButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
    noCooldownButton.Font = Enum.Font.SourceSansBold
    noCooldownButton.TextSize = 16
    noCooldownButton.Parent = frame

    -- Hitbox Expansion Button
    local hitboxButton = Instance.new("TextButton")
    hitboxButton.Size = UDim2.new(1, 0, 0, 40)
    hitboxButton.Position = UDim2.new(0, 0, 0, 90)
    hitboxButton.Text = "Enable Hitbox Expansion"
    hitboxButton.TextColor3 = Color3.new(1, 1, 1)
    hitboxButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
    hitboxButton.Font = Enum.Font.SourceSansBold
    hitboxButton.TextSize = 16
    hitboxButton.Parent = frame

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

    -- No Cooldown Button Logic
    noCooldownButton.MouseButton1Click:Connect(function()
        noCooldownEnabled = not noCooldownEnabled
        if noCooldownEnabled then
            noCooldownButton.Text = "Disable No Cooldown"
            print("No Cooldown Enabled")
            -- Logic to remove cooldown
            warn("No Cooldown Activated!")
            -- Example: Force continuous shooting (you need to adapt this to your game's weapon system)
            spawn(function()
                while noCooldownEnabled do
                    -- Simulate firing continuously
                    local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        local remoteEvent = tool:FindFirstChild("RemoteEvent") -- Replace with the actual event name
                        if remoteEvent then
                            remoteEvent:FireServer() -- Fire the server event to simulate shooting
                        end
                    end
                    wait(0.1) -- Adjust the delay as needed
                end
            end)
        else
            noCooldownButton.Text = "Enable No Cooldown"
            print("No Cooldown Disabled")
        end
    end)

    -- Hitbox Expansion Button Logic
    hitboxButton.MouseButton1Click:Connect(function()
        hitboxEnabled = not hitboxEnabled
        if hitboxEnabled then
            hitboxButton.Text = "Disable Hitbox Expansion"
            print("Hitbox Expansion Enabled")
            -- Enable noclip for all players except the local player
            spawn(function()
                while hitboxEnabled do
                    for _, plr in pairs(Players:GetPlayers()) do
                        if plr ~= player then
                            local character = plr.Character
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                local rootPart = character.HumanoidRootPart
                                rootPart.Size = Vector3.new(10, 10, 10) -- Increase hitbox size
                                rootPart.Transparency = 0.5 -- Make it semi-transparent
                                rootPart.BrickColor = BrickColor.new("Bright red") -- Change color for visibility
                                -- Apply noclip
                                rootPart.CanCollide = false
                                rootPart.Velocity = Vector3.new(0, 0, 0) -- Prevent falling
                            end
                        end
                    end
                    wait(0.1) -- Adjust the delay as needed
                end
            end)
        else
            hitboxButton.Text = "Enable Hitbox Expansion"
            print("Hitbox Expansion Disabled")
            -- Reset hitboxes and disable noclip
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player then
                    local character = plr.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local rootPart = character.HumanoidRootPart
                        rootPart.Size = Vector3.new(2, 2, 1) -- Reset to default size
                        rootPart.Transparency = 1 -- Reset transparency
                        rootPart.BrickColor = BrickColor.new("Medium stone grey") -- Reset color
                        rootPart.CanCollide = true -- Re-enable collisions
                    end
                end
            end
        end
    end)

    -- Close Button Logic
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
