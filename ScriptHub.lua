-- Universal Script with Nickname Hider and Miniaturization
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Variables
local nicknameHiderEnabled = false
local miniaturizationEnabled = false
local originalName = player.Name
local originalSize = humanoid.HipHeight

-- Function to toggle nickname hider
local function toggleNicknameHider()
    nicknameHiderEnabled = not nicknameHiderEnabled
    if nicknameHiderEnabled then
        -- Alternate between two random names
        local randomNames = {"ShadowSword10123", "ShadowMaster101023"}
        local newName = randomNames[math.random(1, #randomNames)]
        player.Name = newName
        print("Nickname Hider Enabled. New Name:", newName)
    else
        player.Name = originalName
        print("Nickname Hider Disabled. Original Name Restored:", originalName)
    end
end

-- Function to toggle miniaturization
local function toggleMiniaturization()
    miniaturizationEnabled = not miniaturizationEnabled
    if miniaturizationEnabled then
        print("Miniaturization Enabled")
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Size = part.Size / 5 -- Reduce size by 80%
            end
        end
        humanoid.HipHeight = 1 -- Adjust height for smaller size
    else
        print("Miniaturization Disabled")
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Size = part.Size * 5 -- Restore original size
            end
        end
        humanoid.HipHeight = originalSize -- Restore original height
    end
end

-- Toggle functions with keys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.Q then -- Press Q to toggle Nickname Hider
        toggleNicknameHider()
    elseif input.KeyCode == Enum.KeyCode.E then -- Press E to toggle Miniaturization
        toggleMiniaturization()
    end
end)

-- Handle character respawns
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")

    -- Restore original size on respawn
    if miniaturizationEnabled then
        toggleMiniaturization() -- Disable miniaturization temporarily
        wait(1) -- Wait for the character to fully load
        toggleMiniaturization() -- Re-enable miniaturization
    end
end)
