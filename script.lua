-- Script to gain Trade Tokens in Car Dealership Tycoon
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variables
local player = Players.LocalPlayer
local tokensPerSecond = 100 -- Number of Trade Tokens gained per second

-- Function to find the Trade Tokens system
local function findTokenSystem()
    local success, tokenValue = pcall(function()
        -- Assuming the Trade Tokens are stored in a folder like "leaderstats" or similar
        if player:FindFirstChild("leaderstats") then
            local leaderstats = player.leaderstats
            for _, value in pairs(leaderstats:GetChildren()) do
                if value:IsA("IntValue") and value.Name == "Trade Tokens" then
                    return value -- Return the token storage if found
                end
            end
        end
        return nil
    end)

    if success and tokenValue then
        return tokenValue
    else
        warn("Could not find the Trade Tokens system. Make sure you're in the correct game.")
        return nil
    end
end

-- Main function to add tokens
local function addTokens()
    local tokenSystem = findTokenSystem()
    if not tokenSystem then
        warn("Trade Tokens system not found. Exiting script.")
        return
    end

    while true do
        tokenSystem.Value = tokenSystem.Value + tokensPerSecond
        wait(1) -- Wait 1 second before adding more tokens
    end
end

-- Start the token generator
addTokens()
