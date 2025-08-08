--[[
  ShadowDev - Mobile UI (Universal Tools)
  Coloque este script como LocalScript (ex: StarterPlayerScripts).
  Recursos:
    - Speed (slider)
    - Noclip (atravessar paredes, não cair no void: Y “ancorado” ao chão detectado por raycast)
    - ESP (Billboard com nome e distância)
    - Chams (Highlight AlwaysOnTop)
    - Hitbox (parte acoplada, tamanho ajustável, client-side)
  Observações:
    - Ajuste de Hitbox e visualizações são locais (client-side).
    - Para noclip, mantemos a altura com raycast; você atravessa paredes sem cair.
--]]

-- Serviços
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Configs de estilo
local THEME = {
    bg = Color3.fromRGB(20, 21, 25),
    panel = Color3.fromRGB(30, 32, 38),
    topbar = Color3.fromRGB(25, 27, 33),
    stroke = Color3.fromRGB(60, 64, 72),
    text = Color3.fromRGB(230, 235, 241),
    accent = Color3.fromRGB(90, 175, 255),
    accent2 = Color3.fromRGB(0, 200, 120),
    warn = Color3.fromRGB(255, 135, 70),
}

-- Utilidades
local function safeWaitForCharacter(plr)
    local char = plr.Character
    if not char or not char.Parent then
        char = plr.CharacterAdded:Wait()
    end
    return char
end

local function getLocalHumanoidAndRoot()
    local char = LocalPlayer.Character
    if not char or not char.Parent then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hum and hrp then
        return hum, hrp
    end
    return nil
end

local function makeUiStroke(inst, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = inst
    return s
end

local function corner(inst, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = inst
    return c
end

local function padding(inst, l, t, r, b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = inst
    return p
end

-- Construção da UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShadowDev"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromScale(0.9, 0.6) -- mobile-friendly
MainFrame.Position = UDim2.fromScale(0.05, 0.2)
MainFrame.BackgroundColor3 = THEME.bg
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
corner(MainFrame, 12)
makeUiStroke(MainFrame, THEME.stroke, 1)

-- Drag (mobile + mouse)
do
    MainFrame.Active = true -- necessário para input
    local dragging = false
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        MainFrame.Position = newPos
    end

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

-- Topbar
local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Size = UDim2.new(1,0,0,42)
Topbar.BackgroundColor3 = THEME.topbar
Topbar.BorderSizePixel = 0
Topbar.Parent = MainFrame
corner(Topbar, 12)
makeUiStroke(Topbar, THEME.stroke, 1)

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ShadowDev"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextColor3 = THEME.text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = Topbar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "Close"
CloseBtn.Size = UDim2.new(0, 34, 0, 34)
CloseBtn.Position = UDim2.new(1, -42, 0, 4)
CloseBtn.BackgroundColor3 = THEME.panel
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = THEME.text
CloseBtn.Font = Enum.Font.GothamBlack
CloseBtn.TextSize = 16
CloseBtn.AutoButtonColor = true
CloseBtn.Parent = Topbar
corner(CloseBtn, 8)
makeUiStroke(CloseBtn, THEME.stroke, 1)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

-- Tabs (somente "Universal" por agora)
local Tabs = Instance.new("Frame")
Tabs.Name = "Tabs"
Tabs.Size = UDim2.new(1, -24, 0, 40)
Tabs.Position = UDim2.new(0, 12, 0, 50)
Tabs.BackgroundTransparency = 1
Tabs.Parent = MainFrame

local UniversalTabBtn = Instance.new("TextButton")
UniversalTabBtn.Name = "UniversalTabBtn"
UniversalTabBtn.Size = UDim2.new(0, 120, 1, 0)
UniversalTabBtn.BackgroundColor3 = THEME.panel
UniversalTabBtn.Text = "Universal"
UniversalTabBtn.Font = Enum.Font.GothamSemibold
UniversalTabBtn.TextSize = 16
UniversalTabBtn.TextColor3 = THEME.text
UniversalTabBtn.Parent = Tabs
corner(UniversalTabBtn, 8)
makeUiStroke(UniversalTabBtn, THEME.stroke, 1)

-- Content Area
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -24, 1, -100)
Content.Position = UDim2.new(0, 12, 0, 96)
Content.BackgroundColor3 = THEME.panel
Content.Parent = MainFrame
corner(Content, 12)
makeUiStroke(Content, THEME.stroke, 1)

padding(Content, 12, 12, 12, 12)
local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 10)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = Content

-- Widgets: Toggle e Slider (helpers)
local function makeRow(titleText, height)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, height or 64)
    row.BackgroundColor3 = THEME.bg
    row.Parent = Content
    corner(row, 10)
    makeUiStroke(row, THEME.stroke, 1)

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Text = titleText or "Opção"
    title.TextColor3 = THEME.text
    title.Font = Enum.Font.GothamMedium
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Size = UDim2.new(1, -160, 0, 22)
    title.Position = UDim2.new(0, 12, 0, 8)
    title.Parent = row

    return row, title
end

local function makeToggle(row, defaultState, onChanged)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 64, 0, 30)
    btn.Position = UDim2.new(1, -76, 0, 17)
    btn.BackgroundColor3 = defaultState and THEME.accent2 or Color3.fromRGB(80, 80, 88)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = row
    corner(btn, 16)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 24, 0, 24)
    knob.Position = defaultState and UDim2.new(1, -28, 0.5, -12) or UDim2.new(0, 4, 0.5, -12)
    knob.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
    knob.Parent = btn
    corner(knob, 12)

    local state = defaultState
    local function setState(new)
        state = new
        local goal = {
            BackgroundColor3 = state and THEME.accent2 or Color3.fromRGB(80, 80, 88)
        }
        TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), goal):Play()
        local targetPos = state and UDim2.new(1, -28, 0.5, -12) or UDim2.new(0, 4, 0.5, -12)
        TweenService:Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        if onChanged then
            task.spawn(onChanged, state)
        end
    end

    btn.MouseButton1Click:Connect(function()
        setState(not state)
    end)

    return {Set = setState, Get = function() return state end}
end

local function makeSlider(row, min, max, defaultValue, suffix, onChanged)
    min = min or 0
    max = max or 100
    local value = math.clamp(defaultValue or min, min, max)

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 80, 0, 22)
    valueLabel.Position = UDim2.new(1, -84, 0, 8)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = string.format("%.0f%s", value, suffix or "")
    valueLabel.TextColor3 = THEME.text
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = row

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -24, 0, 30)
    slider.Position = UDim2.new(0, 12, 1, -38)
    slider.BackgroundColor3 = THEME.panel
    slider.Parent = row
    corner(slider, 8)
    makeUiStroke(slider, THEME.stroke, 1)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 6)
    bar.Position = UDim2.new(0, 10, 0.5, -3)
    bar.BackgroundColor3 = Color3.fromRGB(80, 85, 95)
    bar.Parent = slider
    corner(bar, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = THEME.accent
    fill.BorderSizePixel = 0
    fill.Parent = bar
    corner(fill, 3)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = UDim2.new(fill.Size.X.Scale, -11, 0.5, -11)
    knob.BackgroundColor3 = THEME.accent
    knob.Parent = slider
    corner(knob, 11)

    local dragging = false
    local function setValueFromX(px)
        local rel = math.clamp((px - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
        local newValue = min + rel*(max-min)
        value = newValue
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -11, 0.5, -11)
        valueLabel.Text = string.format("%.0f%s", value, suffix or "")
        if onChanged then
            task.spawn(onChanged, value)
        end
    end

    local function begin(input)
        dragging = true
        setValueFromX(input.Position.X)
    end
    local function finish()
        dragging = false
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            begin(input)
        end
    end)
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            begin(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setValueFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            finish()
        end
    end)

    -- valor inicial
    if onChanged then task.defer(onChanged, value) end

    return {
        Get = function() return value end,
        Set = function(v)
            v = math.clamp(v, min, max)
            local rel = (v-min)/(max-min)
            value = v
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -11, 0.5, -11)
            valueLabel.Text = string.format("%.0f%s", value, suffix or "")
            if onChanged then task.spawn(onChanged, value) end
        end
    }
end

-- Estados globais das funções
local state = {
    speed = 16,
    noclip = false,
    esp = false,
    chams = false,
    hitboxEnabled = false,
    hitboxSize = 6, -- edge length (caixa)
}

-- ESP/Chams/Hitbox Gestão
local EspObjects = {}   -- [Player] = BillboardGui
local ChamObjects = {}  -- [Player] = Highlight
local HitboxObjects = {} -- [Player] = Part (welded)

local function cleanupForPlayer(plr)
    if EspObjects[plr] then
        EspObjects[plr]:Destroy()
        EspObjects[plr] = nil
    end
    if ChamObjects[plr] then
        ChamObjects[plr]:Destroy()
        ChamObjects[plr] = nil
    end
    if HitboxObjects[plr] then
        HitboxObjects[plr]:Destroy()
        HitboxObjects[plr] = nil
    end
end

local function applyESP(plr)
    if plr == LocalPlayer then return end
    if not state.esp then return end
    local function attach(char)
        if not state.esp then return end
        local head = char:FindFirstChild("Head")
        if not head then return end
        if EspObjects[plr] then
            EspObjects[plr]:Destroy()
            EspObjects[plr] = nil
        end

        local bb = Instance.new("BillboardGui")
        bb.Name = "ShadowDevESP"
        bb.AlwaysOnTop = true
        bb.Size = UDim2.new(0, 150, 0, 40)
        bb.StudsOffset = Vector3.new(0, 2.5, 0)
        bb.Adornee = head
        bb.Parent = head

        local tl = Instance.new("TextLabel")
        tl.BackgroundTransparency = 1
        tl.TextColor3 = THEME.text
        tl.Font = Enum.Font.GothamSemibold
        tl.TextSize = 14
        tl.Size = UDim2.new(1, 0, 1, 0)
        tl.Parent = bb

        EspObjects[plr] = bb

        -- Atualiza texto com distância
        local alive = true
        task.spawn(function()
            while alive and bb.Parent do
                local myChar = LocalPlayer.Character
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local targetHRP = char:FindFirstChild("HumanoidRootPart")
                local dist = 0
                if myHRP and targetHRP then
                    dist = (myHRP.Position - targetHRP.Position).Magnitude
                end
                tl.Text = string.format("%s  [%.0f]", plr.Name, dist)
                task.wait(0.2)
            end
        end)
        bb.AncestryChanged:Connect(function(_, p)
            if not p then alive = false end
        end)
    end

    -- Char atual e futuros
    local char = plr.Character
    if char then
        attach(char)
    end
    plr.CharacterAdded:Connect(function(newChar)
        task.wait(0.2)
        attach(newChar)
    end)
end

local function applyChams(plr)
    if plr == LocalPlayer then return end
    if not state.chams then return end

    local function attachToChar(char)
        if not state.chams then return end
        if ChamObjects[plr] then
            ChamObjects[plr]:Destroy()
            ChamObjects[plr] = nil
        end
        local h = Instance.new("Highlight")
        h.Name = "ShadowDevChams"
        h.FillColor = Color3.fromRGB(0, 200, 255)
        h.FillTransparency = 0.7
        h.OutlineColor = Color3.fromRGB(255, 255, 255)
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Adornee = char
        h.Parent = char
        ChamObjects[plr] = h
    end

    local char = plr.Character
    if char then
        attachToChar(char)
    end
    plr.CharacterAdded:Connect(function(newChar)
        task.wait(0.2)
        attachToChar(newChar)
    end)
end

local function applyHitbox(plr)
    if plr == LocalPlayer then return end
    if not state.hitboxEnabled then return end

    local function attach(char)
        if not state.hitboxEnabled then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if HitboxObjects[plr] then
            HitboxObjects[plr]:Destroy()
            HitboxObjects[plr] = nil
        end

        local box = Instance.new("Part")
        box.Name = "ShadowDevHitbox"
        box.Size = Vector3.new(state.hitboxSize, state.hitboxSize, state.hitboxSize)
        box.Transparency = 0.9
        box.Color = Color3.fromRGB(255, 100, 100)
        box.CanCollide = false
        box.CanQuery = true
        box.CanTouch = false
        box.Massless = true
        box.Anchored = false
        box.Parent = char

        -- Solda no HRP
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = hrp
        weld.Part1 = box
        weld.Parent = box
        box.CFrame = hrp.CFrame

        HitboxObjects[plr] = box
    end

    local char = plr.Character
    if char then attach(char) end
    plr.CharacterAdded:Connect(function(newChar)
        task.wait(0.2)
        attach(newChar)
    end)
end

local function refreshAllPlayers()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if not state.esp then
                if EspObjects[plr] then EspObjects[plr]:Destroy() EspObjects[plr] = nil end
            else
                applyESP(plr)
            end

            if not state.chams then
                if ChamObjects[plr] then ChamObjects[plr]:Destroy() ChamObjects[plr] = nil end
            else
                applyChams(plr)
            end

            if not state.hitboxEnabled then
                if HitboxObjects[plr] then HitboxObjects[plr]:Destroy() HitboxObjects[plr] = nil end
            else
                applyHitbox(plr)
            end
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    if plr == LocalPlayer then return end
    task.delay(0.5, function()
        if state.esp then applyESP(plr) end
        if state.chams then applyChams(plr) end
        if state.hitboxEnabled then applyHitbox(plr) end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    cleanupForPlayer(plr)
end)

-- Noclip
local noclipConnection
local originalCollide = {}
local savedYOffset = 3 -- altura relativa ao chão mantida

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function setCharacterCollide(char, collide)
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") then
            if collide then
                if originalCollide[d] ~= nil then
                    d.CanCollide = originalCollide[d]
                end
            else
                if originalCollide[d] == nil then
                    originalCollide[d] = d.CanCollide
                end
                d.CanCollide = false
            end
        end
    end
end

local function enableNoclip()
    if noclipConnection then return end
    local char = safeWaitForCharacter(LocalPlayer)
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not (hum and hrp) then return end

    -- preparar raycast
    local ignore = {char}
    rayParams.FilterDescendantsInstances = ignore

    -- medir offset atual do chão -> HRP.Y
    do
        local origin = hrp.Position + Vector3.new(0, 2, 0)
        local res = Workspace:Raycast(origin, Vector3.new(0, -1000, 0), rayParams)
        if res then
            savedYOffset = (hrp.Position.Y - res.Position.Y)
        end
    end

    setCharacterCollide(char, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
    hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)

    noclipConnection = RunService.Heartbeat:Connect(function()
        local h, r = getLocalHumanoidAndRoot()
        if not h or not r then return end

     
