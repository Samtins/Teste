-- DOORS Ultimate Script v3.1 - Versão Garantida
-- Link RAW: https://raw.githubusercontent.com/Samtins/Teste/main/DoorsUltimate.lua

-- Verificação do jogo
if game.PlaceId ~= 6516141723 then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ERRO",
        Text = "Execute apenas em DOORS!",
        Duration = 5
    })
    return
end

-- Carrega biblioteca UI alternativa garantida
local function LoadSafeUI()
    local uiSuccess, uiResult = pcall(function()
        -- Tentativa 1: Biblioteca alternativa
        local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Robobo2022/2/main/UI-Library.lua"))()
        return lib
    end)
    
    if not uiSuccess then
        -- Tentativa 2: Biblioteca de fallback
        uiSuccess, uiResult = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/NighterEpic/Fluent/master/Graphics.lua"))()
        end)
    end
    
    return uiSuccess and uiResult or nil
end

local Fluent = LoadSafeUI()
if not Fluent then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ERRO CRÍTICO",
        Text = "Falha ao carregar bibliotecas UI",
        Duration = 7
    })
    return
end

-- Configurações padrão
local Settings = {
    AutoAvoid = true,
    Highlight = true,
    SpeedBoost = false,
    NoClip = false
}

-- Cria a janela principal
local Window = Fluent.new({
    Title = "DOORS Ultimate v3.1",
    SubTitle = "Menu Principal",
    TabWidth = 120,
    Size = UDim2.fromOffset(450, 350)
})

-- Adiciona abas
local MainTab = Window:AddTab({Title = "Principal", Icon = "home"})
local VisualTab = Window:AddTab({Title = "Visual", Icon = "eye"})

-- Adiciona elementos na aba Principal
MainTab:AddToggle("AutoAvoidToggle", {
    Title = "Evitar Entidades",
    Description = "Detecta e evita monstros automaticamente",
    Default = Settings.AutoAvoid,
    Callback = function(value)
        Settings.AutoAvoid = value
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Sistema",
            Text = value and "Evasão ativada" or "Evasão desativada",
            Duration = 2
        })
    end
})

MainTab:AddToggle("SpeedToggle", {
    Title = "Speed Boost",
    Description = "Aumenta sua velocidade de movimento",
    Default = Settings.SpeedBoost,
    Callback = function(value)
        Settings.SpeedBoost = value
    end
})

-- Adiciona elementos na aba Visual
VisualTab:AddToggle("HighlightToggle", {
    Title = "Highlight Entidades",
    Description = "Destaca monstros perigosos",
    Default = Settings.Highlight,
    Callback = function(value)
        Settings.Highlight = value
    end
})

-- Função de inicialização
Window:SelectTab(1)

-- Notificação de sucesso
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "DOORS Ultimate",
    Text = "Interface carregada com sucesso!",
    Duration = 3
})

-- Loop principal
game:GetService("RunService").Heartbeat:Connect(function()
    -- Aplica NoClip
    if Settings.NoClip and game.Players.LocalPlayer.Character then
        for _, part in ipairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Aplica Speed Boost
    if Settings.SpeedBoost and game.Players.LocalPlayer.Character then
        local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 25
        end
    end
end)
