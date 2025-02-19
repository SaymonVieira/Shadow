-- Invisibility Script for Universal Use
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local isInvisible = false
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "InvisibilityGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 100)
    frame.Position = UDim2.new(0.5, -125, 0.8, -50)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.Text = "Enable Invisibility"
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.TextSize = 20
    toggleButton.Parent = frame

    toggleButton.MouseButton1Click:Connect(function()
        isInvisible = not isInvisible
        if isInvisible then
            toggleButton.Text = "Disable Invisibility"
            toggleButton.BackgroundColor3 = Color3.fromRGB(150, 30, 30)

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
            toggleButton.Text = "Enable Invisibility"
            toggleButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)

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
end

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    if not isInvisible then
        return
    end

    wait(1)
    if character:FindFirstChild("Humanoid") then
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
end)

createGUI()
