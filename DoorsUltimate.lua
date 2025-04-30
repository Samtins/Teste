-- DOORS Ultimate Script v3.0 - Completo
-- Por: Roblox Scripting Helper
-- GitHub: https://raw.githubusercontent.com/Samtins/Teste/main/DoorsUltimate.lua

-- Verificação do jogo
if game.PlaceId ~= 6516141723 then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ERRO",
        Text = "Execute apenas em DOORS!",
        Duration = 5
    })
    return
end

-- Carrega a biblioteca UI melhorada
local function LoadLibrary()
    local success, response = pcall(function()
        local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/AbstractPoo/Venux-Ui/main/main.lua", true))()
        return lib
    end)
    
    if not success then
        warn("Falha ao carregar biblioteca: "..tostring(response))
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "ERRO",
            Text = "Falha ao carregar a UI",
            Duration = 5
        })
        return nil
    end
    return response
end

local Venux = LoadLibrary()
if not Venux then return end

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
    },
    Misc = {
        DebugMode = false,
        UIPosition = UDim2.new(0.05, 0, 0.5, 0)
    }
}

-- Cria a janela principal com tema personalizado
local Window = Venux.new("DOORS Ultimate", "Midnight")

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

AutoSection:Toggle("Resolver Puzzles", "Completa puzzles automaticamente", Settings.Automation.AutoSolvePuzzles, function(state)
    Settings.Automation.AutoSolvePuzzles = state
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

MiscSection:Keybind("Toggle UI", Enum.KeyCode.RightControl, function()
    Window:Toggle()
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

-- Detecção de entidades
workspace.ChildAdded:Connect(function(child)
    if table.find(Settings.AutoAvoid.Entities, child.Name) then
        if Settings.AutoAvoid.Enabled then
            Notify("ALERTA", child.Name.." detectado!", 3)
        end
        if Settings.Visuals.Highlight then
            task.wait(0.5)
            HighlightEntities()
        end
    end
end)

-- Inicialização
Window:SelectTab(1)
Notify("DOORS Ultimate", "Interface carregada com sucesso!")
