--[[
    CodeAI - Uma Ferramenta de Próxima Geração
    Criado por Symon e codificado por Gemini.
]]

--================================================================================================================
--[ Iniciação da Biblioteca e Configuração Principal ]
--================================================================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Tabela principal para organizar o estado e as funções do script
local CodeAI = {
    Config = {
        FlySpeed = 1,
        Noclip = false,
        InfiniteJump = false,
        KillAura = false,
        KillAuraDistance = 30,
        AutoChopTree = false,
        AutoChopDistance = 30
    },
    Modules = {},
    Connections = {} -- Para armazenar e gerenciar conexões de eventos
}

--================================================================================================================
--[ Módulo Central (Core) - Funções Utilitárias ]
--================================================================================================================

local Core = {}
CodeAI.Modules.Core = Core

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Função de arrastar item otimizada
function Core.DragItem(item)
    if item then
        pcall(function()
            ReplicatedStorage.RemoteEvents.RequestStartDraggingItem:FireServer(item)
            task.wait() -- Pequena espera para garantir que o evento seja processado
            ReplicatedStorage.RemoteEvents.StopDraggingItem:FireServer(item)
        end)
    end
end

-- Função de notificação centralizada
function Core.Notify(title, content)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = 3,
        Image = "rbxassetid://4483345998", -- Ícone de engrenagem
    })
end

--================================================================================================================
--[ Módulo do Jogador (Player) - Movimento e Habilidades ]
--================================================================================================================

local PlayerModule = {}
CodeAI.Modules.Player = PlayerModule

local isFlying = false
local flyVelocity, flyGyro

-- Função de voo (Fly) aprimorada
function PlayerModule.ToggleFly(value)
    isFlying = value
    local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local RootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if not Humanoid or not RootPart then return end

    if isFlying then
        Humanoid.PlatformStand = true
        flyVelocity = Instance.new("BodyVelocity", RootPart)
        flyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyVelocity.Velocity = Vector3.new(0, 0, 0)
        
        flyGyro = Instance.new("BodyGyro", RootPart)
        flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyGyro.P = 20000
        
        CodeAI.Connections.FlyLoop = RunService.RenderStepped:Connect(function()
            if not isFlying then return end
            
            local camera = Workspace.CurrentCamera
            flyGyro.CFrame = camera.CFrame
            
            local moveVector = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveVector = moveVector + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveVector = moveVector - Vector3.new(0, 1, 0) end

            flyVelocity.Velocity = moveVector.Unit * (50 * CodeAI.Config.FlySpeed)
        end)
    else
        if CodeAI.Connections.FlyLoop then CodeAI.Connections.FlyLoop:Disconnect() end
        if flyVelocity then flyVelocity:Destroy() end
        if flyGyro then flyGyro:Destroy() end
        Humanoid.PlatformStand = false
    end
end

-- Função de atravessar paredes (Noclip)
function PlayerModule.ToggleNoclip(value)
    CodeAI.Config.Noclip = value
    if CodeAI.Connections.NoclipLoop then CodeAI.Connections.NoclipLoop:Disconnect() end
    
    if CodeAI.Config.Noclip then
        CodeAI.Connections.NoclipLoop = RunService.Heartbeat:Connect(function()
            pcall(function()
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end)
        end)
    end
end

-- Função de pulo infinito (Infinite Jump)
function PlayerModule.ToggleInfiniteJump(value)
    CodeAI.Config.InfiniteJump = value
    if CodeAI.Connections.JumpHandler then CodeAI.Connections.JumpHandler:Disconnect() end

    if CodeAI.Config.InfiniteJump then
        CodeAI.Connections.JumpHandler = UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Space then
                pcall(function()
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                end)
            end
        end)
    end
end

--================================================================================================================
--[ Módulo ESP - Sistema de Visualização Universal ]
--================================================================================================================

local ESPModule = {}
CodeAI.Modules.ESP = ESPModule

ESPModule.Enabled = false
ESPModule.Targets = {} -- { TargetFolder = Workspace.Items, Color = Color3.new(1,1,0), Name = "Item", Enabled = false }
ESPModule.ActiveESP = {} -- Objetos atualmente com ESP ativo

function ESPModule.CreateESP(object, config)
    local root = object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")
    if not root or ESPModule.ActiveESP[object] then return end

    local highlight = Instance.new("Highlight", object)
    highlight.FillColor = config.Color
    highlight.OutlineColor = config.Color
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    local billboard = Instance.new("BillboardGui", root)
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.fromOffset(100, 20)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = config.Color
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold

    ESPModule.ActiveESP[object] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = label,
        Object = object,
        Root = root
    }
end

function ESPModule.RemoveESP(object)
    if ESPModule.ActiveESP[object] then
        pcall(function() ESPModule.ActiveESP[object].Highlight:Destroy() end)
        pcall(function() ESPModule.ActiveESP[object].Billboard:Destroy() end)
        ESPModule.ActiveESP[object] = nil
    end
end

function ESPModule.UpdateLoop()
    if CodeAI.Connections.ESPLoop then CodeAI.Connections.ESPLoop:Disconnect() end

    if ESPModule.Enabled then
        CodeAI.Connections.ESPLoop = RunService.RenderStepped:Connect(function()
            local cameraPos = Workspace.CurrentCamera.CFrame.Position
            
            -- Limpar ESP de objetos que não existem mais
            for obj, espData in pairs(ESPModule.ActiveESP) do
                if not obj or not obj.Parent then
                    ESPModule.RemoveESP(obj)
                end
            end

            for _, config in ipairs(ESPModule.Targets) do
                if config.Enabled and config.TargetFolder and config.TargetFolder.Parent then
                    for _, object in ipairs(config.TargetFolder:GetChildren()) do
                        if object:IsA("Model") and object.PrimaryPart then
                            if not ESPModule.ActiveESP[object] then
                                ESPModule.CreateESP(object, config)
                            end

                            -- Atualizar texto e distância
                            if ESPModule.ActiveESP[object] then
                                local espData = ESPModule.ActiveESP[object]
                                local distance = math.floor((espData.Root.Position - cameraPos).Magnitude)
                                espData.Label.Text = string.format("%s [%dm]", object.Name, distance)
                            end
                        end
                    end
                end
            end
        end)
    else
        for obj, _ in pairs(ESPModule.ActiveESP) do
            ESPModule.RemoveESP(obj)
        end
    end
end

function ESPModule.ToggleCategory(categoryName, value)
    local found = false
    for _, config in ipairs(ESPModule.Targets) do
        if config.Name == categoryName then
            config.Enabled = value
            found = true
            break
        end
    end

    if not value then -- Limpar ESP para a categoria desativada
        for obj, espData in pairs(ESPModule.ActiveESP) do
            local objCategory = "" -- Determina a categoria do objeto
            if espData.Object.Parent == Workspace.Items then objCategory = "Items" end
            -- Adicione outras lógicas de categoria aqui...
            
            if objCategory == categoryName then
                ESPModule.RemoveESP(obj)
            end
        end
    end

    local anyEnabled = false
    for _, config in ipairs(ESPModule.Targets) do
        if config.Enabled then
            anyEnabled = true
            break
        end
    end

    ESPModule.Enabled = anyEnabled
    ESPModule.UpdateLoop()
end

--================================================================================================================
--[ Módulo de Automação (Automation) - Tarefas Automáticas ]
--================================================================================================================

local AutomationModule = {}
CodeAI.Modules.Automation = AutomationModule

-- Kill Aura
function AutomationModule.ToggleKillAura(value)
    CodeAI.Config.KillAura = value
    if CodeAI.Connections.KillAuraLoop then CodeAI.Connections.KillAuraLoop:Disconnect() end

    if CodeAI.Config.KillAura then
        CodeAI.Connections.KillAuraLoop = RunService.Heartbeat:Connect(function()
            pcall(function()
                local playerRoot = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart
                if not playerRoot then return end
                
                local closestEnemy, minDist = nil, CodeAI.Config.KillAuraDistance

                for _, char in ipairs(Workspace.Characters:GetChildren()) do
                    if char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and char.Name ~= LocalPlayer.Name and char:FindFirstChild("HumanoidRootPart") then
                        -- Lógica para excluir NPCs amigáveis
                        if char.Name ~= "Lost Child" and char.Name ~= "Pelt Trader" and not string.match(char.Name, "Lost Child%d") then
                            local dist = (playerRoot.Position - char.HumanoidRootPart.Position).Magnitude
                            if dist < minDist then
                                minDist = dist
                                closestEnemy = char
                            end
                        end
                    end
                end

                if closestEnemy then
                    -- Lógica de ataque (simples, pode ser expandida para usar ferramentas)
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") then
                        tool:Activate()
                    end
                    ReplicatedStorage.RemoteEvents.DamageCharacter:FireServer(closestEnemy, 100) -- Exemplo de evento
                end
            end)
        end)
    end
end

-- Auto Chop Tree
function AutomationModule.ToggleAutoChop(value)
    CodeAI.Config.AutoChopTree = value
    if CodeAI.Connections.AutoChopLoop then CodeAI.Connections.AutoChopLoop:Disconnect() end

    if CodeAI.Config.AutoChopTree then
        CodeAI.Connections.AutoChopLoop = RunService.Heartbeat:Connect(function()
            pcall(function()
                local playerRoot = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart
                if not playerRoot then return end

                local closestTree, minDist = nil, CodeAI.Config.AutoChopDistance

                for _, tree in ipairs(Workspace.Trees:GetChildren()) do
                    if tree:IsA("Model") and tree:FindFirstChild("Trunk") and tree.Trunk:FindFirstChild("Health") and tree.Trunk.Health.Value > 0 then
                        local dist = (playerRoot.Position - tree.Trunk.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closestTree = tree
                        end
                    end
                end

                if closestTree then
                    -- Teleporta para a árvore, bate e coleta
                    LocalPlayer.Character:SetPrimaryPartCFrame(closestTree.Trunk.CFrame * CFrame.new(0, 0, 5))
                    ReplicatedStorage.RemoteEvents.DamageTree:FireServer(closestTree, 100) -- Exemplo
                    
                    task.wait(0.5) -- Espera o tronco cair
                    for _, item in ipairs(Workspace.Items:GetChildren()) do
                        if item.Name == "Log" and (item.PrimaryPart.Position - closestTree.Trunk.Position).Magnitude < 15 then
                            item.PrimaryPart.CFrame = playerRoot.CFrame
                            Core.DragItem(item)
                        end
                    end
                end
            end)
        end)
    end
end

--================================================================================================================
--[ Configuração da UI (Rayfield) ]
--================================================================================================================

local Window = Rayfield:CreateWindow({
   Name = "CodeAI",
   Icon = "rbxassetid://6002419409",
   LoadingTitle = "CodeAI - Analisando a Realidade",
   LoadingSubtitle = "Criado por Symon e codificado por Gemini.",
   Theme = "Default",
   ConfigurationSaving = { Enabled = true, FolderName = "CodeAI_Config", FileName = "Settings" }
})

-- Aba: Jogador
local PlayerTab = Window:CreateTab("Player")

PlayerTab:CreateToggle({
   Name = "Fly",
   Flag = "FlyToggle",
   Callback = function(v) PlayerModule.ToggleFly(v) end
})
PlayerTab:CreateSlider({
   Name = "Fly Speed",
   Min = 1, Max = 10, Default = 1,
   Flag = "FlySpeedSlider",
   Callback = function(v) CodeAI.Config.FlySpeed = v end
})
PlayerTab:CreateToggle({
   Name = "Noclip",
   Flag = "NoclipToggle",
   Callback = function(v) PlayerModule.ToggleNoclip(v) end
})
PlayerTab:CreateToggle({
   Name = "Infinite Jump",
   Flag = "InfJumpToggle",
   Callback = function(v) PlayerModule.ToggleInfiniteJump(v) end
})

-- Aba: ESP
local EspTab = Window:CreateTab("ESP")

ESPModule.Targets = {
    {Name = "Items", TargetFolder = Workspace.Items, Color = Color3.fromRGB(255, 255, 0), Enabled = false},
    {Name = "Enemies", TargetFolder = Workspace.Characters, Color = Color3.fromRGB(255, 50, 50), Enabled = false, Exclude = {"Lost Child", "Pelt Trader"}}, -- Lógica de exclusão a ser implementada no loop
    {Name = "Children", TargetFolder = Workspace.Characters, Color = Color3.fromRGB(50, 255, 50), Enabled = false, IncludeOnly = {"Lost Child"}}, -- Lógica de inclusão a ser implementada
    {Name = "Pelt Trader", TargetFolder = Workspace.Characters, Color = Color3.fromRGB(0, 255, 255), Enabled = false, IncludeOnly = {"Pelt Trader"}}
}

EspTab:CreateToggle({Name = "ESP: Items", Flag = "ESP_Items", Callback = function(v) ESPModule.ToggleCategory("Items", v) end})
EspTab:CreateToggle({Name = "ESP: Enemies", Flag = "ESP_Enemies", Callback = function(v) ESPModule.ToggleCategory("Enemies", v) end})
EspTab:CreateToggle({Name = "ESP: Children", Flag = "ESP_Children", Callback = function(v) ESPModule.ToggleCategory("Children", v) end})
EspTab:CreateToggle({Name = "ESP: Pelt Trader", Flag = "ESP_PeltTrader", Callback = function(v) ESPModule.ToggleCategory("Pelt Trader",v) end})

-- Aba: Automação
local AutomationTab = Window:CreateTab("Automation")

AutomationTab:CreateToggle({
    Name = "Kill Aura",
    Flag = "KillAuraToggle",
    Callback = function(v) AutomationModule.ToggleKillAura(v) end
})
AutomationTab:CreateSlider({
    Name = "Kill Aura Distance",
    Min = 10, Max = 100, Default = 30,
    Flag = "KillAuraDistanceSlider",
    Callback = function(v) CodeAI.Config.KillAuraDistance = v end
})
AutomationTab:CreateToggle({
    Name = "Auto Farm (Trees)",
    Flag = "AutoFarmToggle",
    Callback = function(v) AutomationModule.ToggleAutoChop(v) end
})
AutomationTab:CreateSlider({
    Name = "Farm Distance",
    Min = 10, Max = 100, Default = 30,
    Flag = "FarmDistanceSlider",
    Callback = function(v) CodeAI.Config.AutoChopDistance = v end
})

-- Aba: Mundo (World)
local WorldTab = Window:CreateTab("World")
WorldTab:CreateButton({
    Name = "Bring All Items",
    Callback = function()
        Core.Notify("CodeAI", "Trazendo todos os itens...")
        for _, item in ipairs(Workspace.Items:GetChildren()) do
            if item:IsA("Model") and item.PrimaryPart then
                item:SetPrimaryPartCFrame(LocalPlayer.Character.HumanoidRootPart.CFrame)
                Core.DragItem(item)
                task.wait()
            end
        end
    end
})

-- Aba: Configurações
local SettingsTab = Window:CreateTab("Settings")
SettingsTab:CreateParagraph({Title = "CodeAI", Content = "Criado por Symon e codificado por Gemini."})
SettingsTab:CreateParagraph({Title = "Créditos da UI", Content = "Rayfield UI Library"})
SettingsTab:CreateButton({
    Name = "Destruir UI",
    Confirmation = true,
    Callback = function() Rayfield:Destroy() end
})

Core.Notify("CodeAI", "Script carregado com sucesso.")
