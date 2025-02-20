-- Script for Animal Simulator: Instant Level and Strength
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Variables
local desiredLevel = 30000 -- Desired level (30,000)
local desiredStrength = 70000 -- Desired strength (70,000)

-- Function to find the player's stats
local function findStats()
    local success, stats = pcall(function()
        -- Assuming the stats are stored in a folder like "leaderstats" or similar
        if player:FindFirstChild("leaderstats") then
            local leaderstats = player.leaderstats
            local levelStat, strengthStat = nil, nil

            -- Find the Level and Strength stats
            for _, stat in pairs(leaderstats:GetChildren()) do
                if stat.Name == "Level" and stat:IsA("IntValue") then
                    levelStat = stat
                elseif stat.Name == "Strength" and stat:IsA("IntValue") then
                    strengthStat = stat
                end
            end

            return levelStat, strengthStat
        end
        return nil, nil
    end)

    if success and stats then
        return stats
    else
        warn("Could not find the stats system. Make sure you're in the correct game.")
        return nil, nil
    end
end

-- Function to set Level and Strength
local function setStats()
    local levelStat, strengthStat = findStats()

    if not levelStat or not strengthStat then
        warn("Level or Strength stat not found. Exiting script.")
        return
    end

    -- Set the desired values
    levelStat.Value = desiredLevel
    strengthStat.Value = desiredStrength

    print("Stats updated successfully!")
    print("Level:", levelStat.Value)
    print("Strength:", strengthStat.Value)
end

-- Toggle function with key E
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.E then -- Press E to activate
        setStats()
    end
end)
