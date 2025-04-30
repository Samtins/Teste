-- DOORS Ultimate Mobile v5.0
-- Link RAW: https://raw.githubusercontent.com/Samtins/Teste/main/DoorsUltimateMobile.lua

-- Verificação do jogo
if game.PlaceId ~= 6516141723 then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ERRO",
        Text = "Execute apenas em DOORS!",
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

-- Variáveis de UI
local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()
local Window = UILibrary:NewWindow("DOORS Ultimate", "Mobile v5.0")

-- Funções principais
local function Notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
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
local MainTab = Window:NewTab("Principal")
local VisualTab = Window:NewTab("Visual")
local PlayerTab = Window:NewTab("Jogador")
local MiscTab = Window:NewTab("Misc")

-- Seção Principal
local AutoSection = MainTab:NewSection("Automação")
AutoSection:NewToggle("Evitar Entidades", "Detecta e evita monstros", Settings.AutoAvoid.Enabled, function(state)
    Settings.AutoAvoid.Enabled = state
    Notify("Sistema", state and "Evasão ativada" or "Evasão desativada")
end)

AutoSection:NewToggle("Pegar Itens", "Coleta itens automaticamente", Settings.Automation.AutoPickItems, function(state)
    Settings.Automation.AutoPickItems = state
end)

-- Seção Visual
local VisualSection = VisualTab:NewSection("Render")
VisualSection:NewToggle("Highlight Entidades", "Destaca monstros perigosos", Settings.Visuals.Highlight, function(state)
    Settings.Visuals.Highlight = state
    if state then
        HighlightEntities()
    else
        RemoveHighlights()
    end
end)

VisualSection:NewColorpicker("Cor do Highlight", Settings.Visuals.HighlightColor, function(color)
    Settings.Visuals.HighlightColor = color
    if Settings.Visuals.Highlight then
        HighlightEntities(color)
    end
end)

-- Seção Jogador
local PlayerSection = PlayerTab:NewSection("Modificações")
PlayerSection:NewToggle("Speed Boost", "Aumenta velocidade", Settings.Player.SpeedBoost, function(state)
    Settings.Player.SpeedBoost = state
    ApplyPlayerMods()
end)

PlayerSection:NewSlider("Multiplicador", "Velocidade do boost", 5, 1, Settings.Player.SpeedMultiplier, false, function(value)
    Settings.Player.SpeedMultiplier = value
    if Settings.Player.SpeedBoost then
        ApplyPlayerMods()
    end
end)

PlayerSection:NewToggle("NoClip", "Atravessar paredes", Settings.Player.NoClip, function(state)
    Settings.Player.NoClip = state
end)

-- Seção Misc
local MiscSection = MiscTab:NewSection("Utilitários")
MiscSection:NewButton("Teleport para Saída", function()
    local exit = workspace:FindFirstChild("ExitDoor")
    if exit then
        game.Players.LocalPlayer.Character:MoveTo(exit.Position + Vector3.new(0, 3, 0))
        Notify("Teleport", "Teleportado para a saída")
    else
        Notify("Erro", "Saída não encontrada")
    end
end)

-- Sistema de arrasto para mobile
local UserInputService = game:GetService("UserInputService")
local gui = Window.Gui
local dragToggle = nil
local dragSpeed = 0.25
local dragStart = nil
local startPos = nil

local function updateInput(input)
    local delta = input.Position - dragStart
    gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

gui.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
        dragToggle = true
        dragStart = input.Position
        startPos = gui.Position
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
            updateInput(input)
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
end)

-- Inicialização
Notify("DOORS Ultimate", "Interface carregada com sucesso!")
Window:SelectTab(1)
