repeat wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Função de notificação (igual ao seu script)
local function createNotification(title, content, duration, color, parent)
    duration = duration or 5
    color = color or Color3.fromRGB(255, 188, 254)
    -- ... (restante da função igual ao seu script)
    -- (não alterei nada aqui)
    -- ...
end

-- Função para pegar o script do jogo
local function getScriptLoaderUrl()
    local creatorId = game.CreatorId
    local scriptMap = {
        [6042520] = "https://api.luarmor.net/files/v3/loaders/00e140acb477c5ecde501c1d448df6f9.lua", -- 99 noites na floresta
    }
    return scriptMap[creatorId]
end

-- Interface original (sem Key)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SolixHubLogin"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
MainFrame.BackgroundTransparency = 0.06
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.Size = UDim2.fromOffset(400, 370)
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local AcrylicEffect1 = Instance.new("ImageLabel")
AcrylicEffect1.Name = "acrylicthing"
AcrylicEffect1.Image = "rbxassetid://9968344105"
AcrylicEffect1.ImageTransparency = 0.98
AcrylicEffect1.ScaleType = Enum.ScaleType.Tile
AcrylicEffect1.TileSize = UDim2.fromOffset(128, 128)
AcrylicEffect1.BackgroundTransparency = 1
AcrylicEffect1.Size = UDim2.fromScale(1, 1)
AcrylicEffect1.ZIndex = 0
AcrylicEffect1.Parent = MainFrame

local AcrylicCorner1 = Instance.new("UICorner")
AcrylicCorner1.CornerRadius = UDim.new(0, 12)
AcrylicCorner1.Parent = AcrylicEffect1

local AcrylicEffect2 = Instance.new("ImageLabel")
AcrylicEffect2.Name = "acrylicthing"
AcrylicEffect2.Image = "rbxassetid://9968344227"
AcrylicEffect2.ImageTransparency = 0.9
AcrylicEffect2.ScaleType = Enum.ScaleType.Tile
AcrylicEffect2.TileSize = UDim2.fromOffset(128, 128)
AcrylicEffect2.BackgroundTransparency = 1
AcrylicEffect2.Size = UDim2.fromScale(1, 1)
AcrylicEffect2.ZIndex = 0
AcrylicEffect2.Parent = MainFrame

local AcrylicCorner2 = Instance.new("UICorner")
AcrylicCorner2.CornerRadius = UDim.new(0, 12)
AcrylicCorner2.Parent = AcrylicEffect2

local UIStroke = Instance.new("UIStroke")
UIStroke.Name = "_CHILD"
UIStroke.Color = Color3.fromRGB(158, 114, 158)
UIStroke.Transparency = 0.9
UIStroke.Parent = MainFrame

local SideIndicator = Instance.new("Frame")
SideIndicator.Name = "sideindicator"
SideIndicator.AnchorPoint = Vector2.new(0.5, 0)
SideIndicator.BackgroundColor3 = Color3.fromRGB(255, 188, 254)
SideIndicator.BorderSizePixel = 0
SideIndicator.Position = UDim2.fromScale(0.5, 0)
SideIndicator.Size = UDim2.new(1, -50, 0, 2)
SideIndicator.Parent = MainFrame

local SideIndicatorCorner = Instance.new("UICorner")
SideIndicatorCorner.CornerRadius = UDim.new(0, 634)
SideIndicatorCorner.Parent = SideIndicator

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "title"
TitleLabel.FontFace = Font.new("rbxassetid://12187361378", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
TitleLabel.Text = "SolixHub"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 19
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.fromOffset(37, 15)
TitleLabel.Size = UDim2.new(0, 88, 0, 30)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

local ControlsFrame = Instance.new("Frame")
ControlsFrame.Name = "Frame"
ControlsFrame.BackgroundTransparency = 1
ControlsFrame.Position = UDim2.new(1, -75, 0, 15)
ControlsFrame.Size = UDim2.new(0, 60, 0, 30)
ControlsFrame.Parent = MainFrame

local ControlsLayout = Instance.new("UIListLayout")
ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ControlsLayout.Padding = UDim.new(0, 6)
ControlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
ControlsLayout.Parent = ControlsFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "Close"
CloseButton.Text = ""
CloseButton.BackgroundColor3 = Color3.fromRGB(252, 95, 83)
CloseButton.Size = UDim2.fromOffset(7, 7)
CloseButton.AutoButtonColor = false
CloseButton.Parent = ControlsFrame

local CloseButtonCorner = Instance.new("UICorner")
CloseButtonCorner.CornerRadius = UDim.new(0, 50)
CloseButtonCorner.Parent = CloseButton

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "Minimize"
MinimizeButton.Text = ""
MinimizeButton.BackgroundColor3 = Color3.fromRGB(242, 191, 60)
MinimizeButton.Size = UDim2.fromOffset(7, 7)
MinimizeButton.AutoButtonColor = false
MinimizeButton.Parent = ControlsFrame

local MinimizeButtonCorner = Instance.new("UICorner")
MinimizeButtonCorner.CornerRadius = UDim.new(0, 50)
MinimizeButtonCorner.Parent = MinimizeButton

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "Open"
OpenButton.Text = ""
OpenButton.BackgroundColor3 = Color3.fromRGB(117, 166, 87)
OpenButton.Size = UDim2.fromOffset(7, 7)
OpenButton.AutoButtonColor = false
OpenButton.Parent = ControlsFrame

local OpenButtonCorner = Instance.new("UICorner")
OpenButtonCorner.CornerRadius = UDim.new(0, 50)
OpenButtonCorner.Parent = OpenButton

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.fromOffset(0, 60)
ContentFrame.Size = UDim2.new(1, 0, 1, -60)
ContentFrame.Parent = MainFrame

local GameLabel = Instance.new("TextLabel")
GameLabel.Name = "GameLabel"
GameLabel.FontFace = Font.new("rbxassetid://12187365364")
GameLabel.Text = "Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
GameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
GameLabel.TextSize = 12
GameLabel.BackgroundTransparency = 1
GameLabel.Position = UDim2.fromOffset(20, 0)
GameLabel.Size = UDim2.new(1, -40, 0, 20)
GameLabel.Parent = ContentFrame

-- Botão para executar o script
local ExecButton = Instance.new("TextButton")
ExecButton.Name = "ExecButton"
ExecButton.Text = "Executar Script"
ExecButton.Font = Enum.Font.SourceSansSemibold
ExecButton.TextSize = 18
ExecButton.TextColor3 = Color3.fromRGB(255,255,255)
ExecButton.BackgroundColor3 = Color3.fromRGB(158, 114, 158)
ExecButton.Size = UDim2.new(0, 200, 0, 40)
ExecButton.Position = UDim2.new(0.5, -100, 0.5, 40)
ExecButton.Parent = ContentFrame

local ExecButtonCorner = Instance.new("UICorner")
ExecButtonCorner.CornerRadius = UDim.new(0, 8)
ExecButtonCorner.Parent = ExecButton

ExecButton.MouseButton1Click:Connect(function()
    -- Fecha a interface antes de executar o script
    ScreenGui:Destroy()
    -- Executa o loader da forma mais limpa possível
    local scriptUrl = getScriptLoaderUrl()
    if not scriptUrl then
        return
    end
    pcall(function()
        loadstring(game:HttpGet(scriptUrl))()
    end)
end)

-- Fechar/minimizar
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)
OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)
OpenButton.Visible = false

-- Notificação inicial
createNotification("SolixHub", "Clique em 'Executar Script' para iniciar.", 5, Color3.fromRGB(85, 255, 127), ScreenGui)
