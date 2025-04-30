-- Blox Fruits Auto Chest Farm v1.0
-- By: SeuNome (ajustado por IA)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Blox Fruits Chest Farmer", "Sentinel")

-- Configurações
local Settings = {
    Enabled = false,
    Delay = 1,
    Notify = true
}

-- Main Tab
local MainTab = Window:NewTab("Principal")
local MainSection = MainTab:NewSection("Controles")

MainSection:NewToggle("Ativar Auto-Farm", "Farma baús automaticamente", function(state)
    Settings.Enabled = state
    if Settings.Enabled then
        if Settings.Notify then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Blox Fruits Farmer",
                Text = "Auto-Farm ATIVADO",
                Duration = 3
            })
        end
        StartFarming()
    else
        if Settings.Notify then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Blox Fruits Farmer",
                Text = "Auto-Farm DESATIVADO",
                Duration = 3
            })
        end
    end
end)

local SettingsTab = Window:NewTab("Configurações")
local SettingsSection = SettingsTab:NewSection("Opções")

SettingsSection:NewSlider("Delay entre baús", "Tempo entre cada teleporte", 5, 0.5, function(value)
    Settings.Delay = value
end)

SettingsSection:NewToggle("Mostrar Notificações", "Exibe alertas", function(state)
    Settings.Notify = state
end)

-- Função principal
function StartFarming()
    spawn(function()
        while Settings.Enabled and wait(Settings.Delay) do
            pcall(function()
                local character = game.Players.LocalPlayer.Character
                if not character then return end
                
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if not humanoidRootPart then return end
                
                -- Encontrar todos os baús
                for _, chest in pairs(game:GetService("Workspace"):GetChildren()) do
                    if not Settings.Enabled then break end
                    
                    if chest.Name:find("Chest") and chest:FindFirstChild("Chest") then
                        local chestPart = chest.Chest
                        
                        -- Teleportar para o baú
                        humanoidRootPart.CFrame = chestPart.CFrame * CFrame.new(0, 3, 0)
                        
                        -- Esperar um pouco para o jogo registrar
                        wait(0.5)
                        
                        -- Coletar o baú
                        firetouchinterest(humanoidRootPart, chestPart, 0)
                        firetouchinterest(humanoidRootPart, chestPart, 1)
                        
                        -- Delay configurável
                        wait(Settings.Delay)
                    end
                end
                
                -- Notificação quando completar uma rodada
                if Settings.Notify then
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Blox Fruits Farmer",
                        Text = "Rodada de baús completada! Reiniciando...",
                        Duration = 3
                    })
                end
            end)
        end
    end)
end

-- Inicialização
if Settings.Notify then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Blox Fruits Farmer",
        Text = "Carregado com sucesso!",
        Duration = 3
    })
end
