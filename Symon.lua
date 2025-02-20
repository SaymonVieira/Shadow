-- Universal Script with Aimbot, Target Square, and ESP
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local aimbotEnabled = false
local targetSquareEnabled = false
local espEnabled = false
local aimbotTarget = nil

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

-- Function to create a target square
local function createTargetSquare(target)
    if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local rootPart = target.Character.HumanoidRootPart

    -- Create a BoxHandleAdornment for the target square
    local marker = Instance.new("BoxHandleAdornment")
    marker.Name = "TargetSquare"
    marker.Size = Vector3.new(4, 6, 4) -- Size of the square
    marker.Color3 = Color3.new(1, 0, 0) -- Red color
    marker.Transparency = 0.5
    marker.ZIndex = 1
    marker.AlwaysOnTop = true
    marker.Adornee = rootPart
    marker.Parent = rootPart

    return marker
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

-- Function to enable/disable Target Square
local function toggleTargetSquare()
    targetSquareEnabled = not targetSquareEnabled
    if targetSquareEnabled then
        print("Target Square Enabled")
    else
        print("Target Square Disabled")
        if aimbotTarget and aimbotTarget.Character and aimbotTarget.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = aimbotTarget.Character.HumanoidRootPart
            if rootPart:FindFirstChild("TargetSquare") then
                rootPart.TargetSquare:Destroy()
            end
        end
    end
end

-- Function to create ESP
local function createESP(target)
    if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local rootPart = target.Character.HumanoidRootPart

    -- Create a LineHandleAdornment for ESP
    local line = Instance.new("LineHandleAdornment")
    line.Name = "ESPLine"
    line.Thickness = 2
    line.Color3 = Color3.new(0, 1, 0) -- Green color
    line.Transparency = 0.5
    line.Adornee = rootPart
    line.Parent = rootPart

    -- Update line dynamically
    RunService.RenderStepped:Connect(function()
        if espEnabled and rootPart and rootPart.Parent then
            line.Visible = true
            line.From = camera.CFrame.Position
            line.To = rootPart.Position
        else
            line.Visible = false
        end
    end)

    -- Remove ESP when character is removed
    target.CharacterRemoving:Connect(function()
        if line then
            line:Destroy()
        end
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
                if rootPart:FindFirstChild("ESPLine") then
                    rootPart.ESPLine:Destroy()
                end
            end
        end
    end
end

-- Main loop for Aimbot
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local nearestPlayer = findNearestPlayer()
        if nearestPlayer and nearestPlayer.Character and nearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            aimbotTarget = nearestPlayer
            local rootPart = aimbotTarget.Character.HumanoidRootPart

            -- Aim at the target
            camera.CFrame = CFrame.new(camera.CFrame.Position, rootPart.Position)

            -- Create target square if enabled
            if targetSquareEnabled and not rootPart:FindFirstChild("TargetSquare") then
                createTargetSquare(aimbotTarget)
            end
        else
            aimbotTarget = nil
        end
    else
        if aimbotTarget and aimbotTarget.Character and aimbotTarget.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = aimbotTarget.Character.HumanoidRootPart
            if rootPart:FindFirstChild("TargetSquare") then
                rootPart.TargetSquare:Destroy()
            end
        end
    end
end)

-- Damage on hitting the Target Square
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1 and targetSquareEnabled and aimbotTarget then
        local humanoid = aimbotTarget.Character and aimbotTarget.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:TakeDamage(10) -- Adjust damage value here
        end
    end
end)

-- Toggle Aimbot, Target Square, and ESP with keys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.Z then -- Press Z to toggle Aimbot
        toggleAimbot()
    elseif input.KeyCode == Enum.KeyCode.X then -- Press X to toggle Target Square
        toggleTargetSquare()
    elseif input.KeyCode == Enum.KeyCode.C then -- Press C to toggle ESP
        toggleESP()
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
        if rootPart:FindFirstChild("ESPLine") then
            rootPart.ESPLine:Destroy()
        end
    end
end)
