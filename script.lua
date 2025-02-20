-- Universal Script with Aimbot and ESP
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Variables
local aimbotEnabled = false
local espEnabled = false
local aimbotTarget = nil

-- Function to create ESP
local function createESP(target)
    if not target.Character or not target.Character:FindFirstChild("Humanoid") then
        return
    end

    local humanoid = target.Character.Humanoid
    local rootPart = target.Character:FindFirstChild("HumanoidRootPart")

    if not rootPart then
        return
    end

    -- Create a BillboardGui for ESP
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Size = UDim2.new(0, 50, 0, 50)
    billboard.Adornee = rootPart
    billboard.AlwaysOnTop = true
    billboard.Parent = rootPart

    -- Create a Frame for the ESP box
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(1, 0, 0) -- Red border
    frame.BackgroundColor3 = Color3.new(1, 1, 1)
    frame.BackgroundTransparency = 0.8
    frame.Parent = billboard

    -- Create a TextLabel for health
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Size = UDim2.new(1, 0, 0, 10)
    healthLabel.Position = UDim2.new(0, 0, 1, 0)
    healthLabel.Text = "Health: " .. math.floor(humanoid.Health)
    healthLabel.TextColor3 = Color3.new(1, 1, 1)
    healthLabel.BackgroundTransparency = 1
    healthLabel.Font = Enum.Font.SourceSansBold
    healthLabel.TextSize = 12
    healthLabel.Parent = frame

    -- Update health dynamically
    humanoid.HealthChanged:Connect(function(newHealth)
        healthLabel.Text = "Health: " .. math.floor(newHealth)
    end)

    -- Remove ESP when character is removed
    target.CharacterRemoving:Connect(function()
        billboard:Destroy()
    end)
end

-- Function to enable/disable ESP
local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        print("ESP Enabled")
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player then
                createESP(plr)
            end
        end
    else
        print("ESP Disabled")
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = plr.Character.HumanoidRootPart
                if rootPart:FindFirstChild("ESP") then
                    rootPart.ESP:Destroy()
                end
            end
        end
    end
end

-- Function to enable/disable Aimbot
local function toggleAimbot()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        print("Aimbot Enabled")
    else
        print("Aimbot Disabled")
        aimbotTarget = nil
    end
end

-- Function to find the nearest player
local function findNearestPlayer()
    local nearestPlayer = nil
    local nearestDistance = math.huge

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = plr.Character.HumanoidRootPart
            local distance = (rootPart.Position - camera.CFrame.Position).Magnitude

            if distance < nearestDistance then
                nearestPlayer = plr
                nearestDistance = distance
            end
        end
    end

    return nearestPlayer
end

-- Main loop for Aimbot
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local nearestPlayer = findNearestPlayer()
        if nearestPlayer and nearestPlayer.Character and nearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            aimbotTarget = nearestPlayer
            local rootPart = nearestPlayer.Character.HumanoidRootPart

            -- Draw a square around the target
            if not rootPart:FindFirstChild("AimbotMarker") then
                local marker = Instance.new("BoxHandleAdornment")
                marker.Name = "AimbotMarker"
                marker.Size = Vector3.new(4, 6, 4) -- Size of the square
                marker.Color3 = Color3.new(1, 0, 0) -- Red color
                marker.Transparency = 0.5
                marker.ZIndex = 1
                marker.AlwaysOnTop = true
                marker.Adornee = rootPart
                marker.Parent = rootPart
            end
        else
            aimbotTarget = nil
        end
    else
        if aimbotTarget and aimbotTarget.Character and aimbotTarget.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = aimbotTarget.Character.HumanoidRootPart
            if rootPart:FindFirstChild("AimbotMarker") then
                rootPart.AimbotMarker:Destroy()
            end
        end
    end
end)

-- Damage on hitting the Aimbot marker
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1 and aimbotEnabled and aimbotTarget then
        local humanoid = aimbotTarget.Character and aimbotTarget.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:TakeDamage(10) -- Adjust damage value here
        end
    end
end)

-- Toggle Aimbot and ESP with keys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.E then -- Press E to toggle ESP
        toggleESP()
    elseif input.KeyCode == Enum.KeyCode.Q then -- Press Q to toggle Aimbot
        toggleAimbot()
    end
end)

-- Handle new players joining
Players.PlayerAdded:Connect(function(plr)
    if espEnabled then
        createESP(plr)
    end
end)

-- Handle players leaving
Players.PlayerRemoving:Connect(function(plr)
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = plr.Character.HumanoidRootPart
        if rootPart:FindFirstChild("ESP") then
            rootPart.ESP:Destroy()
        end
    end
end)
