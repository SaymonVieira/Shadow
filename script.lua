-- Universal Script with Invisibility, Speed Toggle, and Open Button
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Variables
local isInvisible = false
local speedBoostEnabled = false
local defaultWalkSpeed = 16 -- Default Roblox walk speed
local currentWalkSpeed = defaultWalkSpeed

-- Function to create the main GUI
local function createMainGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UniversalHubGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui

    -- Main Frame for the GUI
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 200)
    frame.Position = UDim2.new(0.5, -125, 0.8, -100)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Visible = false -- Initially hidden
    frame.Parent = screenGui

    -- Invisibility Toggle Button
    local invisibilityButton = Instance.new("TextButton")
    invisibilityButton.Size = UDim2.new(1, 0, 0, 40)
    invisibilityButton.Position = UDim2.new(0, 0, 0, 0)
    invisibilityButton.Text = "Enable Invisibility"
    invisibilityButton.TextColor3 = Color3.new(1, 1, 1)
    invisibilityButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
    invisibilityButton.Font = Enum.Font.SourceSansBold
    invisibilityButton.TextSize = 20
    invisibilityButton.Parent = frame

    -- Speed Toggle Button
    local speedButton = Instance.new("TextButton")
    speedButton.Size = UDim2.new(1, 0, 0, 40)
    speedButton.Position = UDim2.new(0, 0, 0, 50)
    speedButton.Text = "Enable Speed Boost"
    speedButton.TextColor3 = Color3.new(1, 1, 1)
    speedButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
    speedButton.Font = Enum.Font.SourceSansBold
    speedButton.TextSize = 20
    speedButton.Parent = frame

    -- Speed Input Field
    local speedInput = Instance.new("TextBox")
    speedInput.Size = UDim2.new(1, 0, 0, 40)
    speedInput.Position = UDim2.new(0, 0, 0, 100)
    speedInput.Text = "Set WalkSpeed"
    speedInput.TextColor3 = Color3.new(1, 1, 1)
    speedInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    speedInput.Font = Enum.Font.SourceSans
    speedInput.TextSize = 16
    speedInput.ClearTextOnFocus = true
    speedInput.Parent = frame

    -- Apply Speed Button
    local applySpeedButton = Instance.new("TextButton")
    applySpeedButton.Size = UDim2.new(1, 0, 0, 40)
    applySpeedButton.Position = UDim2.new(0, 0, 0, 150)
    applySpeedButton.Text = "Apply Speed"
    applySpeedButton.TextColor3 = Color3.new(1, 1, 1)
    applySpeedButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
    applySpeedButton.Font = Enum.Font.SourceSansBold
    applySpeedButton.TextSize = 20
    applySpeedButton.Parent = frame

    -- Invisibility Button Functionality
    invisibilityButton.MouseButton1Click:Connect(function()
        isInvisible = not isInvisible
        if isInvisible then
            invisibilityButton.Text = "Disable Invisibility"
            invisibilityButton.BackgroundColor3 = Color3.fromRGB(150, 30, 30)

            if character and character:FindFirstChild("Humanoid") then
                local humanoid = character.Humanoid
                humanoid.NameDisplayDistance = 0
                humanoid.HealthDisplayDistance = 0
            end
            if character:FindFirstChild("Head") then
                character.Head.Transparency = 1
            end
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                elseif part:IsA("Accessory") then
                    part.Handle.Transparency = 1
                end
            end
        else
            invisibilityButton.Text = "Enable Invisibility"
            invisibilityButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)

            if character and character:FindFirstChild("Humanoid") then
                local humanoid = character.Humanoid
                humanoid.NameDisplayDistance = 100
                humanoid.HealthDisplayDistance = 100
            end
            if character:FindFirstChild("Head") then
                character.Head.Transparency = 0
            end
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                elseif part:IsA("Accessory") then
                    part.Handle.Transparency = 0
                end
            end
        end
    end)

    -- Speed Button Functionality
    speedButton.MouseButton1Click:Connect(function()
        speedBoostEnabled = not speedBoostEnabled
        if speedBoostEnabled then
            speedButton.Text = "Disable Speed Boost"
            speedButton.BackgroundColor3 = Color3.fromRGB(150, 30, 30)

            if character and character:FindFirstChild("Humanoid") then
                local humanoid = character.Humanoid
                humanoid.WalkSpeed = 50
                currentWalkSpeed = 50
            end
        else
            speedButton.Text = "Enable Speed Boost"
            speedButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)

            if character and character:FindFirstChild("Humanoid") then
                local humanoid = character.Humanoid
                humanoid.WalkSpeed = defaultWalkSpeed
                currentWalkSpeed = defaultWalkSpeed
            end
        end
    end)

    -- Apply Speed Button Functionality
    applySpeedButton.MouseButton1Click:Connect(function()
        local newSpeed = tonumber(speedInput.Text)
        if newSpeed and newSpeed > 0 then
            if character and character:FindFirstChild("Humanoid") then
                local humanoid = character.Humanoid
                humanoid.WalkSpeed = newSpeed
                currentWalkSpeed = newSpeed
                speedInput.Text = "Set WalkSpeed"
            end
        else
            speedInput.Text = "Invalid Speed"
        end
    end)

    return frame
end

-- Create the Open Button
local function createOpenButton(mainFrame)
    local openButton = Instance.new("TextButton")
    openButton.Size = UDim2.new(0, 50, 0, 20)
    openButton.Position = UDim2.new(0, 10, 0, 10) -- Adjusted position (top-left corner)
    openButton.Text = "Open"
    openButton.TextColor3 = Color3.new(1, 1, 1)
    openButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
    openButton.Font = Enum.Font.SourceSansBold
    openButton.TextSize = 14
    openButton.Parent = player.PlayerGui

    -- Toggle visibility of the main GUI
    openButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)
end

-- Initialize GUI
local mainFrame = createMainGUI()
createOpenButton(mainFrame)

-- Handle character respawns
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    wait(1) -- Wait for the character to fully load

    if isInvisible then
        if character and character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            humanoid.NameDisplayDistance = 0
            humanoid.HealthDisplayDistance = 0
        end
        if character:FindFirstChild("Head") then
            character.Head.Transparency = 1
        end
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            elseif part:IsA("Accessory") then
                part.Handle.Transparency = 1
            end
        end
    end

    if speedBoostEnabled then
        if character and character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            humanoid.WalkSpeed = currentWalkSpeed
        end
    end
end)
