-- DOORS Ultimate Script v5.1 - Versão Final Garantida
-- Link RAW: https://raw.githubusercontent.com/Samtins/Teste/main/DoorsUltimate.lua

-- Verificação do jogo
if game.PlaceId ~= 6516141723 then
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "ERRO",
        Text = "Execute apenas em DOORS!",
        Duration = 5
    })
    return
end

-- Carrega a biblioteca UI otimizada para mobile
local success, Flux = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/SamPlayZ/UI-Libraries/main/FluxLib.lua"))()
end)

if not success then
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "ERRO",
        Text = "Falha ao carregar a biblioteca UI",
        Duration = 5
    })
    return
end

-- Configurações avançadas
local Settings = {
    AutoAvoid = {
        Enabled = true,
        AlertSound = true,
        SafeDistance = 50,
        Entities = {"Rush", "Ambush", "Eyes", "Halt", "Screech", "Seek"}
    },
    Visuals = {
        Highlight = true,
        HighlightColor = Color3.fromRGB(255, 50, 50),
        ESP = false,
        ESPColor = Color3.fromRGB(0, 255, 255)
    },
    Player = {
        SpeedBoost = false,
        SpeedMultiplier = 1.5,
        NoClip = false,
        JumpBoost = false,
        JumpHeight = 50
    },
    Automation = {
        AutoPickItems = true,
        AutoSolvePuzzles = true,
        AutoOpenDoors = true,
        AvoidTraps = true
    }
}

-- Cria a janela principal com tema escuro
local Window = Flux.new("DOORS Ultimate", "Dark")

-- Funções principais
local function Notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = title,
        Text = text,
        Duration = duration or 3
    })
end

local function HighlightEntities(color)
    color = color or Settings.Visuals.HighlightColor
    for _, entityName in pairs(Settings.AutoAvoid.Entities) do
        local entity = workspace:FindFirstChild(entityName)
        if entity then
            local highlight = entity:FindFirstChildOfClass("Highlight") or Instance.new("Highlight")
            highlight.FillColor = color
            highlight.OutlineColor = color
            highlight.FillTransparency = 0.5
            highlight.Parent = entity
        end
    end
end

local function RemoveHighlights()
    for _, entityName in pairs(Settings.AutoAvoid.Entities) do
        local entity = workspace:FindFirstChild(entityName)
        if entity and entity:FindFirstChildOfClass("Highlight") then
            entity:FindFirstChildOfClass("Highlight"):Destroy()
        end
    end
end

local function ApplyPlayerMods()
    local character = game.Players.LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Settings.Player.SpeedBoost and (16 * Settings.Player.SpeedMultiplier) or 16
            humanoid.JumpPower = Settings.Player.JumpBoost and Settings.Player.JumpHeight or 50
        end
    end
end

-- Criação da interface
local MainTab = Window:Tab("Principal", "rbxassetid://6034287595")
local VisualTab = Window:Tab("Visual", "rbxassetid://6034287588")
local PlayerTab = Window:Tab("Jogador", "rbxassetid://6034287598")
local MiscTab = Window:Tab("Misc", "rbxassetid://6034287602")

-- Seção Principal
local AutoSection = MainTab:Section("Automação", true)
AutoSection:Toggle("Evitar Entidades", "Detecta e evita monstros", Settings.AutoAvoid.Enabled, function(state)
    Settings.AutoAvoid.Enabled = state
    Notify("Sistema", state and "Evasão ativada" or "Evasão desativada")
end)

AutoSection:Toggle("Pegar Itens", "Coleta itens automaticamente", Settings.Automation.AutoPickItems, function(state)
    Settings.Automation.AutoPickItems = state
end)

-- Seção Visual
local VisualSection = VisualTab:Section("Render", true)
VisualSection:Toggle("Highlight Entidades", "Destaca monstros perigosos", Settings.Visuals.Highlight, function(state)
    Settings.Visuals.Highlight = state
    if state then
        HighlightEntities()
    else
        RemoveHighlights()
    end
end)

VisualSection:Colorpicker("Cor do Highlight", Settings.Visuals.HighlightColor, function(color)
    Settings.Visuals.HighlightColor = color
    if Settings.Visuals.Highlight then
        HighlightEntities(color)
    end
end)

-- Seção Jogador
local PlayerSection = PlayerTab:Section("Modificações", true)
PlayerSection:Toggle("Speed Boost", "Aumenta velocidade", Settings.Player.SpeedBoost, function(state)
    Settings.Player.SpeedBoost = state
    ApplyPlayerMods()
end)

PlayerSection:Slider("Multiplicador", "Velocidade do boost", 5, 1, Settings.Player.SpeedMultiplier, false, function(value)
    Settings.Player.SpeedMultiplier = value
    if Settings.Player.SpeedBoost then
        ApplyPlayerMods()
    end
end)

PlayerSection:Toggle("NoClip", "Atravessar paredes", Settings.Player.NoClip, function(state)
    Settings.Player.NoClip = state
end)

-- Seção Misc
local MiscSection = MiscTab:Section("Utilitários", true)
MiscSection:Button("Teleport para Saída", function()
    local exit = workspace:FindFirstChild("ExitDoor")
    if exit then
        game.Players.LocalPlayer.Character:MoveTo(exit.Position + Vector3.new(0, 3, 0))
        Notify("Teleport", "Teleportado para a saída")
    else
        Notify("Erro", "Saída não encontrada")
    end
end)

-- Sistema de arrasto otimizado para mobile
local UserInputService = game:GetService("UserInputService")
local dragToggle = nil
local dragSpeed = 0.25
local dragStart = nil
local startPos = nil

Window.Gui.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
        dragToggle = true
        dragStart = input.Position
        startPos = Window.Gui.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        if dragToggle then
            local delta = input.Position - dragStart
            Window.Gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

-- Loop principal
game:GetService("RunService").Heartbeat:Connect(function()
    -- Aplica NoClip
    if Settings.Player.NoClip and game.Players.LocalPlayer.Character then
        for _, part in ipairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Atualiza modificações do jogador
    ApplyPlayerMods()
    
    -- Destaque de entidades
    if Settings.Visuals.Highlight then
        HighlightEntities()
    end
end)

-- Inicialização
Notify("DOORS Ultimate", "Interface carregada com sucesso!")
Window:SelectTab(1)

-- Garante que a UI aparece
task.spawn(function()
    repeat task.wait() until Window.Gui
    Window.Gui.Enabled = true
    Window.Gui.DisplayOrder = 999
end)
