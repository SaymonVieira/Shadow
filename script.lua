-- Universal Script with Invisibility and Speed Toggle
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Variables
local isInvisible = false
local speedBoostEnabled = false
local defaultWalkSpeed = 16 -- Default Roblox walk speed
local boostedWalkSpeed = 50 -- Custom walk speed when boosted

-- Function to create GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UniversalHubGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui

    -- Frame for the GUI
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 150)
    frame.Position = UDim2.new(0.5, -125, 0.8, -75)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
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
                humanoid.WalkSpeed = boostedWalkSpeed
            end
        else
            speedButton.Text = "Enable Speed Boost"
            speedButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)

            if character and character:FindFirstChild("Humanoid") then
                local humanoid = character.Humanoid
                humanoid.WalkSpeed = defaultWalkSpeed
            end
        end
    end)
end

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
            humanoid.WalkSpeed = boostedWalkSpeed
        end
    end
end)

-- Initialize GUI
createGUI()
