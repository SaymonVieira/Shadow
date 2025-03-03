-- Carregar a biblioteca Fluent e gerenciadores de add-ons
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Criar a janela principal
local Window = Fluent:CreateWindow({
    Title = "ShadowHat v1.0",
    SubTitle = "by Saymon Vieira",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- Efeito de desfoque
    Theme = "Dark", -- Tema escuro
    MinimizeKey = Enum.KeyCode.LeftControl -- Tecla para minimizar
})

-- Adicionar abas
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Variáveis globais
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local ESPEnabled = false

-- Função para desenhar linhas ESP
local function drawESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local screenPosition, onScreen = workspace.CurrentCamera:WorldToScreenPoint(rootPart.Position)

            if onScreen then
                -- Desenhar uma linha fina na tela
                local line = Drawing.new("Line")
                line.Color = Color3.new(1, 1, 1) -- Cor branca
                line.Thickness = 1 -- Linha fina
                line.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                line.To = Vector2.new(screenPosition.X, screenPosition.Y)
                line.Visible = ESPEnabled

                -- Remover a linha quando o jogador sair da tela
                RunService.RenderStepped:Wait()
                line:Remove()
            end
        end
    end
end

-- Toggle para ativar/desativar o ESP
local ESPButton = Tabs.Main:AddToggle("ESPEnabled", {
    Title = "Player ESP"
})

ESPButton:OnChanged(function(Value)
    ESPEnabled = Value
    if ESPEnabled then
        print("ESP ativado!")
    else
        print("ESP desativado!")
    end
end)

-- Loop para atualizar o ESP continuamente
RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        drawESP()
    end
end)

-- Integrar gerenciadores de add-ons
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Finalizar
Window:SelectTab(1) -- Seleciona a aba "Main"
Fluent:Notify({
    Title = "ShadowHat",
    Content = "Script carregado com sucesso!"
})
