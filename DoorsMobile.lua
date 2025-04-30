-- DOORS Mobile Script v4.0 - Fluxus
-- Link RAW: https://raw.githubusercontent.com/Samtins/Teste/main/DoorsMobile.lua

-- Verificação do jogo
if game.PlaceId ~= 6516141723 then
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "ERRO",
        Text = "Execute apenas em DOORS!",
        Duration = 5
    })
    return
end

-- Configurações para mobile
local Settings = {
    AutoAvoid = true,
    SpeedBoost = false,
    NoClip = false,
    Highlight = true
}

-- Cria uma UI simples para mobile
local function CreateMobileUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DoorsMobileUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Frame principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0.7, 0, 0.5, 0)
    MainFrame.Position = UDim2.new(0.15, 0, 0.25, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    -- Barra de título
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0.1, 0)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    TitleBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Text = "DOORS MOBILE v4.0"
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.Parent = TitleBar

    -- Botão de fechar
    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "X"
    CloseButton.Size = UDim2.new(0.1, 0, 1, 0)
    CloseButton.Position = UDim2.new(0.9, 0, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.TextColor3 = Color3.white
    CloseButton.Parent = TitleBar

    -- Lista de opções
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Size = UDim2.new(1, 0, 0.9, 0)
    ScrollingFrame.Position = UDim2.new(0, 0, 0.1, 0)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.ScrollBarThickness = 5
    ScrollingFrame.Parent = MainFrame

    -- Função para criar toggles
    local function CreateToggle(text, description, config)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Parent = ScrollingFrame

        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(0.9, 0, 0.8, 0)
        ToggleButton.Position = UDim2.new(0.05, 0, 0.1, 0)
        ToggleButton.Text = ""
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        ToggleButton.Parent = ToggleFrame

        local ToggleText = Instance.new("TextLabel")
        ToggleText.Text = text
        ToggleText.Size = UDim2.new(0.7, 0, 1, 0)
        ToggleText.Position = UDim2.new(0.05, 0, 0, 0)
        ToggleText.TextColor3 = Color3.white
        ToggleText.BackgroundTransparency = 1
        ToggleText.TextXAlignment = Enum.TextXAlignment.Left
        ToggleText.Font = Enum.Font.Gotham
        ToggleText.TextSize = 16
        ToggleText.Parent = ToggleButton

        local ToggleStatus = Instance.new("Frame")
        ToggleStatus.Size = UDim2.new(0.15, 0, 0.6, 0)
        ToggleStatus.Position = UDim2.new(0.8, 0, 0.2, 0)
        ToggleStatus.BackgroundColor3 = Settings[config] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        ToggleStatus.Parent = ToggleButton

        ToggleButton.MouseButton1Click:Connect(function()
            Settings[config] = not Settings[config]
            ToggleStatus.BackgroundColor3 = Settings[config] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
            game:GetService("StarterGui"):SetCore("SendNotification",{
                Title = text,
                Text = Settings[config] and "ATIVADO" or "DESATIVADO",
                Duration = 1
            })
        end)
    end

    -- Cria os toggles
    CreateToggle("Evitar Monstros", "Detecta e evita entidades", "AutoAvoid")
    CreateToggle("Speed Boost", "Aumenta velocidade em 2x", "SpeedBoost")
    CreateToggle("NoClip", "Atravessar paredes", "NoClip")
    CreateToggle("Highlight", "Destacar monstros", "Highlight")

    -- Botão de fechar
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    return ScreenGui
end

-- Cria a UI
CreateMobileUI()

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

-- Notificação inicial
game:GetService("StarterGui"):SetCore("SendNotification",{
    Title = "DOORS MOBILE",
    Text = "Menu aberto! Toque para ajustar",
    Duration = 3
})
