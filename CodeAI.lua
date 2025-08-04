--[[
    CodeAI - Versão Corrigida e Otimizada
    Analisado e aprimorado para estabilidade e poder.
    
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
    },
    Modules = {},
    Connections = {}, -- Armazena conexões de eventos para poder desconectá-las
    State = {
        IsFlying = false
    }
}

--================================================================================================================
--[ Módulo Central (Core) - Funções Utilitárias Essenciais ]
--================================================================================================================

local Core = {}
CodeAI.Modules.Core = Core

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Função otimizada para arrastar um item para o inventário
function Core.DragItem(item)
    pcall(function()
        if item and item:IsA("Model") then
            ReplicatedStorage.RemoteEvents.RequestStartDraggingItem:FireServer(item)
            task.wait() -- Pequena espera para garantir que o evento seja processado pelo servidor
            ReplicatedStorage.RemoteEvents.StopDraggingItem:FireServer(item)
        end
    end)
end

-- Função para teletransportar e arrastar um grupo de itens
function Core.BringAndDragItems(filter)
    local playerRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not playerRoot then return end

    local targetCFrame = playerRoot.CFrame
    for _, item in ipairs(Workspace.Items:GetChildren()) do
        if item:IsA("Model") and item.PrimaryPart then
            -- A função de filtro determina se este item deve ser trazido
            if filter(item) then
                item.PrimaryPart.CFrame = targetCFrame
                Core.DragItem(item)
                task.wait() -- Adiciona um pequeno delay para não sobrecarregar o servidor
            end
        end
    end
end

-- Função de notificação centralizada
function Core.Notify(title, content, image)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = 4,
        Image = image or "rbxassetid://4483345998",
    })
end

--================================================================================================================
--[ Módulo do Jogador (Player) - Movimento e Habilidades ]
--================================================================================================================

local PlayerModule = {}
CodeAI.Modules.Player = PlayerModule

-- Função de voo (Fly) estável, baseada na lógica original
function PlayerModule.ToggleFly(value)
    CodeAI.State.IsFlying = value
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then return end
    
    if CodeAI.Connections.FlyLoop then
        CodeAI.Connections.FlyLoop:Disconnect()
        CodeAI.Connections.FlyLoop = nil
    end

    if rootPart:FindFirstChild("CodeAIFly_Velocity") then rootPart.CodeAIFly_Velocity:Destroy() end
    if rootPart:FindFirstChild("CodeAIFly_Gyro") then rootPart.CodeAIFly_Gyro:Destroy() end
    if character:FindFirstChildOfClass("Humanoid") then character:FindFirstChildOfClass("Humanoid").PlatformStand = false end

    if CodeAI.State.IsFlying then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = true end

        local bv = Instance.new("BodyVelocity", rootPart)
        bv.Name = "CodeAIFly_Velocity"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.new(0, 0, 0)

        local bg = Instance.new("BodyGyro", rootPart)
        bg.Name = "CodeAIFly_Gyro"
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.P = 9e4 -- Valor do script original, provavelmente ajustado para a física do jogo

        CodeAI.Connections.FlyLoop = RunService.RenderStepped:Connect(function()
            local camera = Workspace.CurrentCamera
            bg.CFrame = camera.CFrame
            
            local moveVector = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveVector = moveVector + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveVector = moveVector - Vector3.new(0, 1, 0) end
            
            local speedMultiplier = 50 * CodeAI.Config.FlySpeed
            bv.Velocity = moveVector.Unit * speedMultiplier
        end)
    end
end

-- Função de Noclip que desativa a colisão de forma segura
function PlayerModule.ToggleNoclip(value)
    if CodeAI.Connections.NoclipLoop then CodeAI.Connections.NoclipLoop:Disconnect() end
    CodeAI.Config.Noclip = value
    
    if value then
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

-- Função de Pulo Infinito que utiliza Humanoid:ChangeState, como no original
function PlayerModule.ToggleInfiniteJump(value)
    if CodeAI.Connections.JumpHandler then CodeAI.Connections.JumpHandler:Disconnect() end
    CodeAI.Config.InfiniteJump = value

    if value then
        CodeAI.Connections.JumpHandler = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == Enum.KeyCode.Space then
                pcall(function()
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                end)
            end
        end)
    end
end

--================================================================================================================
--[ Módulo ESP - Sistema de Visualização Universal e Estável ]
--================================================================================================================

local ESP = {}
CodeAI.Modules.ESP = ESP

ESP.Targets = {} -- { Name = "Items", Folder = Workspace.Items, Color = ..., Enabled = false, Filter = function(obj) return true end }
ESP.ActiveRender = {} -- Armazena os objetos que estão sendo renderizados no ESP
ESP.MainLoop = nil

-- Cria os elementos visuais do ESP para um objeto
function ESP.CreateVisuals(object, config)
    local root = object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")
    if not root or ESP.ActiveRender[object] then return end

    local espData = {}
    espData.Object = object
    espData.Root = root
    espData.Config = config

    pcall(function()
        espData.Highlight = Instance.new("Highlight", object)
        espData.Highlight.FillColor = config.Color
        espData.Highlight.OutlineColor = config.Color
        espData.Highlight.FillTransparency = 0.7
        espData.Highlight.OutlineTransparency = 0
        espData.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

        espData.Billboard = Instance.new("BillboardGui", root)
        espData.Billboard.AlwaysOnTop = true
        espData.Billboard.Size = UDim2.fromOffset(120, 25)
        espData.Billboard.StudsOffset = Vector3.new(0, 3, 0)

        espData.Label = Instance.new("TextLabel", espData.Billboard)
        espData.Label.Size = UDim2.fromScale(1, 1)
        espData.Label.BackgroundTransparency = 1
        espData.Label.TextColor3 = config.Color
        espData.Label.TextScaled = true
        espData.Label.Font = Enum.Font.SourceSansSemibold

        ESP.ActiveRender[object] = espData
    end)
end

-- Remove os elementos visuais do ESP
function ESP.RemoveVisuals(object)
    if ESP.ActiveRender[object] then
        pcall(function() ESP.ActiveRender[object].Highlight:Destroy() end)
        pcall(function() ESP.ActiveRender[object].Billboard:Destroy() end)
        ESP.ActiveRender[object] = nil
    end
end

-- Loop principal que gerencia o que deve ser mostrado ou removido
function ESP.Update()
    if ESP.MainLoop then ESP.MainLoop:Disconnect(); ESP.MainLoop = nil end

    local anyEnabled = false
    for _, config in ipairs(ESP.Targets) do
        if config.Enabled then
            anyEnabled = true
            break
        end
    end
    
    if not anyEnabled then
        for obj, _ in pairs(ESP.ActiveRender) do ESP.RemoveVisuals(obj) end
        return
    end

    ESP.MainLoop = RunService.RenderStepped:Connect(function()
        local cameraPos = Workspace.CurrentCamera.CFrame.Position
        
        -- Limpa objetos que não existem mais
        for obj, _ in pairs(ESP.ActiveRender) do
            if not obj or not obj.Parent then
                ESP.RemoveVisuals(obj)
            end
        end

        -- Itera através das categorias de alvos
        for _, config in ipairs(ESP.Targets) do
            if config.Enabled and config.Folder and config.Folder.Parent then
                for _, object in ipairs(config.Folder:GetChildren()) do
                    if config.Filter(object) then -- Usa a função de filtro da categoria
                        if not ESP.ActiveRender[object] then
                            ESP.CreateVisuals(object, config)
                        end
                        if ESP.ActiveRender[object] then
                            local data = ESP.ActiveRender[object]
                            local distance = math.floor((data.Root.Position - cameraPos).Magnitude)
                            data.Label.Text = string.format("%s [%dm]", object.Name, distance)
                        end
                    else
                        if ESP.ActiveRender[object] then
                            ESP.RemoveVisuals(object)
                        end
                    end
                end
            end
        end
    end)
end

function ESP.ToggleCategory(name, value)
    for _, config in ipairs(ESP.Targets) do
        if config.Name == name then
            config.Enabled = value
            break
        end
    end
    ESP.Update()
end

--================================================================================================================
--[ Configuração da UI (Rayfield) - Interface Estável e Funcional ]
--================================================================================================================

pcall(function()
    local Window = Rayfield:CreateWindow({
       Name = "CodeAI",
       Icon = "rbxassetid://6002419409",
       LoadingTitle = "CodeAI - Sincronizando com a Realidade...",
       LoadingSubtitle = "Criado por Symon e codificado por Gemini.",
       Theme = "Midnight",
       ConfigurationSaving = { Enabled = true, FolderName = "CodeAI_Config", FileName = "Config" }
    })

    -- Aba: Jogador
    local PlayerTab = Window:CreateTab("Player")
    PlayerTab:CreateToggle({Name = "Fly", Flag = "FlyToggle", Callback = function(v) PlayerModule.ToggleFly(v) end})
    PlayerTab:CreateSlider({Name = "Fly Speed", Min = 1, Max = 10, Default = 1, Flag = "FlySpeedSlider", Callback = function(v) CodeAI.Config.FlySpeed = v end})
    PlayerTab:CreateToggle({Name = "Noclip", Flag = "NoclipToggle", Callback = function(v) PlayerModule.ToggleNoclip(v) end})
    PlayerTab:CreateToggle({Name = "Infinite Jump", Flag = "InfJumpToggle", Callback = function(v) PlayerModule.ToggleInfiniteJump(v) end})

    -- Aba: ESP
    local EspTab = Window:CreateTab("ESP")
    ESP.Targets = {
        {Name = "Items", Folder = Workspace.Items, Color = Color3.fromRGB(255, 255, 0), Enabled = false, Filter = function(o) return o:IsA("Model") end},
        {Name = "Enemies", Folder = Workspace.Characters, Color = Color3.fromRGB(255, 50, 50), Enabled = false, Filter = function(o) 
            return o:IsA("Model") and o:FindFirstChild("Humanoid") and o.Name ~= LocalPlayer.Name and o.Name ~= "Pelt Trader" and not string.match(o.Name, "Lost Child")
        end},
        {Name = "Children", Folder = Workspace.Characters, Color = Color3.fromRGB(50, 255, 50), Enabled = false, Filter = function(o) 
            return o:IsA("Model") and string.match(o.Name, "Lost Child")
        end},
        {Name = "Pelt Trader", Folder = Workspace.Characters, Color = Color3.fromRGB(0, 255, 255), Enabled = false, Filter = function(o) 
            return o:IsA("Model") and o.Name == "Pelt Trader"
        end}
    }
    EspTab:CreateToggle({Name = "ESP: Items", Flag = "ESP_Items", Callback = function(v) ESP.ToggleCategory("Items", v) end})
    EspTab:CreateToggle({Name = "ESP: Enemies", Flag = "ESP_Enemies", Callback = function(v) ESP.ToggleCategory("Enemies", v) end})
    EspTab:CreateToggle({Name = "ESP: Children", Flag = "ESP_Children", Callback = function(v) ESP.ToggleCategory("Children", v) end})
    EspTab:CreateToggle({Name = "ESP: Pelt Trader", Flag = "ESP_PeltTrader", Callback = function(v) ESP.ToggleCategory("Pelt Trader",v) end})

    -- Aba: Trazer Itens (Funcionalidades originais, agora organizadas)
    local BringTab = Window:CreateTab("Bring Items")
    BringTab:CreateButton({Name = "Bring All Items", Callback = function()
        Core.Notify("CodeAI", "Trazendo todos os itens...", "rbxassetid://1327318385") -- Ícone de caixa
        task.spawn(function() Core.BringAndDragItems(function(item) return true end) end)
    end})
    BringTab:CreateButton({Name = "Bring All Logs", Callback = function()
        Core.Notify("CodeAI", "Trazendo todos os troncos...", "rbxassetid://683987893") -- Ícone de tronco
        task.spawn(function() Core.BringAndDragItems(function(item) return item.Name == "Log" end) end)
    end})
    BringTab:CreateButton({Name = "Bring All Coal", Callback = function()
        Core.Notify("CodeAI", "Trazendo todo o carvão...", "rbxassetid://510159463") -- Ícone de carvão
        task.spawn(function() Core.BringAndDragItems(function(item) return item.Name == "Coal" end) end)
    end})

    -- Aba: Configurações
    local SettingsTab = Window:CreateTab("Settings")
    SettingsTab:CreateParagraph({Title = "CodeAI", Content = "Criado por Symon e codificado por Gemini."})
    SettingsTab:CreateParagraph({Title = "Status", Content = "Versão 2.0: Estável e funcional."})
    SettingsTab:CreateButton({Name = "Destruir UI", Confirmation = true, Callback = function() Rayfield:Destroy() end})

    Core.Notify("CodeAI", "Script carregado com sucesso.", "rbxassetid://1839202472") -- Ícone de sucesso

end)
