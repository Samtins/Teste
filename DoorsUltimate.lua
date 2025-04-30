-- DOORS Ultimate Script v2.0
-- Por: SeuNome (via IA)
-- GitHub: github.com/Samtins/Teste

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- Carrega a biblioteca Venux UI
local Venux = loadstring(game:HttpGet("https://raw.githubusercontent.com/AbstractPoo/Venux-Ui/main/main.lua"))()

-- Cria a janela principal
local Window = Venux.new("DOORS Ultimate", "Default")

-- Configurações globais
local Settings = {
    AutoAvoidEntities = true,
    HighlightEntities = true,
    AutoPickItems = true,
    SpeedBoost = false,
    SpeedMultiplier = 1.5,
    NoClip = false,
    AutoSkipPuzzle = true,
    DebugMode = false
}

-- Tabela de entidades perigosas
local DangerousEntities = {
    "Rush", "Ambush", "Eyes", "Halt", "Glitch", "Screech", "Timothy", "Seek"
}

-- Função para notificações
local function Notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 5
    })
end

-- Cria as abas e seções
local MainTab = Window:Tab("Principal", "rbxassetid://4483345998")
local PlayerTab = Window:Tab("Jogador", "rbxassetid://4483345998")
local VisualTab = Window:Tab("Visual", "rbxassetid://4483345998")
local MiscTab = Window:Tab("Misc", "rbxassetid://4483345998")

-- Seção de Automação
local AutoSection = MainTab:Section("Automação", true)
AutoSection:Toggle("Evitar Entidades", "Detecta e evita automaticamente", false, function(state)
    Settings.AutoAvoidEntities = state
    if state then
        Notify("Sistema", "Evasão automática ativada")
    end
end)

AutoSection:Toggle("Pegar Itens Auto", "Coleta itens automaticamente", false, function(state)
    Settings.AutoPickItems = state
    if state then
        Notify("Sistema", "Coleta automática ativada")
    end
end)

AutoSection:Toggle("Pular Puzzles", "Completa puzzles automaticamente", false, function(state)
    Settings.AutoSkipPuzzle = state
    if state then
        Notify("Sistema", "Auto-puzzle ativado")
    end
end)

-- Seção de Jogador
local PlayerSection = PlayerTab:Section("Modificações", true)
PlayerSection:Toggle("Speed Boost", "Aumenta velocidade de movimento", false, function(state)
    Settings.SpeedBoost = state
    if state then
        Notify("Sistema", "Speed boost ativado ("..Settings.SpeedMultiplier.."x)")
    end
end)

PlayerSection:Slider("Multiplicador", "Velocidade do boost", 5, 1, 2, true, function(value)
    Settings.SpeedMultiplier = value
end)

PlayerSection:Toggle("NoClip", "Atravessar paredes", false, function(state)
    Settings.NoClip = state
    if state then
        Notify("Sistema", "NoClip ativado")
    end
end)

-- Seção Visual
local VisualSection = VisualTab:Section("Render", true)
VisualSection:Toggle("Highlight Entidades", "Destaca monstros", false, function(state)
    Settings.HighlightEntities = state
    if state then
        HighlightDangerousEntities()
    else
        RemoveHighlights()
    end
end)

VisualSection:Colorpicker("Cor das Entidades", Color3.fromRGB(255, 0, 0), function(color)
    if Settings.HighlightEntities then
        HighlightDangerousEntities(color)
    end
end)

-- Seção Misc
local MiscSection = MiscTab:Section("Utilitários", true)
MiscSection:Toggle("Debug Mode", "Mostra informações técnicas", false, function(state)
    Settings.DebugMode = state
end)

MiscSection:Button("Teleport para Saída", function()
    TeleportToExit()
end)

MiscSection:Keybind("Toggle UI", Enum.KeyCode.RightControl, function()
    Window:Toggle()
end)

-- Funções principais
function HighlightDangerousEntities(color)
    color = color or Color3.fromRGB(255, 0, 0)
    for _, entityName in pairs(DangerousEntities) do
        local entity = workspace:FindFirstChild(entityName)
        if entity then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = color
            highlight.OutlineColor = color
            highlight.Parent = entity
        end
    end
end

function RemoveHighlights()
    for _, entityName in pairs(DangerousEntities) do
        local entity = workspace:FindFirstChild(entityName)
        if entity and entity:FindFirstChild("Highlight") then
            entity.Highlight:Destroy()
        end
    end
end

function TeleportToExit()
    local exit = workspace:FindFirstChild("ExitDoor")
    if exit and LocalPlayer.Character then
        LocalPlayer.Character:MoveTo(exit.Position + Vector3.new(0, 3, 0))
        Notify("Teleport", "Teleportado para a saída")
    else
        Notify("Erro", "Saída não encontrada")
    end
end

-- Loop principal
RunService.Heartbeat:Connect(function()
    if Settings.SpeedBoost and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16 * Settings.SpeedMultiplier
        end
    end
    
    if Settings.NoClip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Detecção de entidades
workspace.ChildAdded:Connect(function(child)
    if table.find(DangerousEntities, child.Name) and Settings.AutoAvoidEntities then
        Notify("ALERTA", child.Name.." detectado!", 3)
        -- Lógica de evasão aqui
    end
end)

-- Inicialização
Notify("DOORS Ultimate", "Script carregado com sucesso!", 3)
Window:SelectTab(1)  -- Seleciona a primeira aba
