local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Create GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "CombatGui"
Gui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 450)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "Combat 🎩"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 20

-- Avatar Image
local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(0, 100, 0, 100)
Avatar.Position = UDim2.new(0.5, -50, 0, 10)
Avatar.BackgroundTransparency = 1
local ThumbnailId = LocalPlayer:GetPlayerThumbnailAsset()
if ThumbnailId then
    Avatar.Image = ThumbnailId
else
    local Credit = Instance.new("TextLabel")
    Credit.Size = UDim2.new(1, 0, 0, 30)
    Credit.Position = UDim2.new(0, 0, 0, 0)
    Credit.Text = "criado por Symon"
    Credit.TextColor3 = Color3.fromRGB(255, 255, 255)
    Credit.TextScaled = true
    Credit.Parent = Avatar
end

-- Speed Section
local SpeedSection = Instance.new("Frame")
SpeedSection.Size = UDim2.new(1, 0, 0, 100)
SpeedSection.Position = UDim2.new(0, 0, 0, 110)
SpeedSection.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 0, 30)
SpeedLabel.Position = UDim2.new(0, 10, 0, 10)
SpeedLabel.Text = "Speed: " .. (Character:FindFirstChild("Humanoid") and Character.Humanoid.WalkSpeed or "0")
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0.6, 0, 0, 30)
SpeedInput.Position = UDim2.new(0, 10, 0, 50)
SpeedInput.PlaceholderText = "Enter speed (e.g., 25)"
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)

local ApplySpeed = Instance.new("TextButton")
ApplySpeed.Size = UDim2.new(0.3, 0, 0, 30)
ApplySpeed.Position = UDim2.new(0.7, 0, 0, 50)
ApplySpeed.Text = "Apply"
ApplySpeed.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ApplySpeed.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Hitbox Section
local HitboxSection = Instance.new("Frame")
HitboxSection.Size = UDim2.new(1, 0, 0, 100)
HitboxSection.Position = UDim2.new(0, 0, 0, 210)
HitboxSection.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

local HitboxLabel = Instance.new("TextLabel")
HitboxLabel.Size = UDim2.new(1, 0, 0, 30)
HitboxLabel.Position = UDim2.new(0, 10, 0, 10)
HitboxLabel.Text = "Hitbox Size: 1"
HitboxLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HitboxLabel.TextXAlignment = Enum.TextXAlignment.Left

local HitboxInput = Instance.new("TextBox")
HitboxInput.Size = UDim2.new(0.6, 0, 0, 30)
HitboxInput.Position = UDim2.new(0, 10, 0, 50)
HitboxInput.PlaceholderText = "Enter size (e.g., 2)"
HitboxInput.TextColor3 = Color3.fromRGB(255, 255, 255)

local ApplyHitbox = Instance.new("TextButton")
ApplyHitbox.Size = UDim2.new(0.3, 0, 0, 30)
ApplyHitbox.Position = UDim2.new(0.7, 0, 0, 50)
ApplyHitbox.Text = "Apply"
ApplyHitbox.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ApplyHitbox.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 50, 0, 30)
CloseBtn.Position = UDim2.new(0.5, 110, 0, 400)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Hierarchy
Avatar.Parent = MainFrame
Title.Parent = MainFrame
SpeedSection.Parent = MainFrame
SpeedLabel.Parent = SpeedSection
SpeedInput.Parent = SpeedSection
ApplySpeed.Parent = SpeedSection
HitboxSection.Parent = MainFrame
HitboxLabel.Parent = HitboxSection
HitboxInput.Parent = HitboxSection
ApplyHitbox.Parent = HitboxSection
CloseBtn.Parent = MainFrame
MainFrame.Parent = Gui
Gui.Parent = PlayerGui

-- Functions
local HitboxPart
ApplySpeed.MouseButton1Click:Connect(function()
    local Speed = tonumber(SpeedInput.Text)
    if Speed and Speed > 0 then
        if Character:FindFirstChild("Humanoid") then
            Character.Humanoid.WalkSpeed = Speed
            SpeedLabel.Text = "Speed: " .. Speed
        end
    end
end)

ApplyHitbox.MouseButton1Click:Connect(function()
    local Size = tonumber(HitboxInput.Text)
    if Size and Size > 0 then
        if HitboxPart then
            HitboxPart:Destroy()
        end
        HitboxPart = Instance.new("Part")
        HitboxPart.Size = Vector3.new(Size, Size, Size)
        HitboxPart.Anchored = true
        HitboxPart.Transparency = 0.5
        HitboxPart.BrickColor = BrickColor.new("Bright red")
        HitboxPart.Parent = Character
        HitboxLabel.Text = "Hitbox Size: " .. Size
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)
