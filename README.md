-- Hub Name: SymonHub
-- Function: Adds 100 tokens to the player every second

-- Variable to store the token value
local tokens = 0

-- Function to add tokens
local function addTokens(player)
    while true do
        -- Increment 100 tokens
        tokens = tokens + 100
        
        -- Update the leaderboard or any other scoring system
        -- Assuming you have a "leaderstats" folder in the player with a "Tokens" variable
        if player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Tokens") then
            player.leaderstats.Tokens.Value = tokens
        end
        
        -- Wait 1 second before adding more tokens
        wait(1)
    end
end

-- Function to set up the player when they join the game
game.Players.PlayerAdded:Connect(function(player)
    -- Create a "leaderstats" folder for the player
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    -- Create a "Tokens" variable for the player
    local tokensValue = Instance.new("IntValue")
    tokensValue.Name = "Tokens"
    tokensValue.Value = 0
    tokensValue.Parent = leaderstats

    -- Start the function to add tokens
    addTokens(player)
end)
