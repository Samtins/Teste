-- DOORS Mobile Script v4.1 - Fluxus (Versão Final)
-- Link RAW: https://raw.githubusercontent.com/Samtins/Teste/main/DoorsMobileFixed.lua

-- Verificação do jogo
if game.PlaceId ~= 6516141723 then
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "ERRO",
        Text = "Execute apenas em DOORS!",
        Duration = 5
    })
    return
end

-- Configurações
local Settings = {
    AutoAvoid = false,
    SpeedBoost = false,
    NoClip = false,
    Highlight = false,
    WalkSpeed = 25,
    JumpPower = 50
}

-- Variáveis de arrasto
local dragging
local dragInput
local dragStart
local startPos

-- Função para criar UI móvel
local function CreateMobileUI()
    -- Cria a ScreenGui principal
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DoorsMobileUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Frame principal (agora movível)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0.7, 0, 0.5, 0)
    MainFrame.Position = UDim2.new(0.15, 0, 0.25, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Selectable = true
    MainFrame.Parent = ScreenGui

    -- Função de arrasto
    local function UpdateInput(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            UpdateInput(input)
        end
    end)

    -- Barra de título
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0.1, 0)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    TitleBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Text = "DOORS MOBILE v4.1"
    Title.Size = UDim2.new(0.8, 0, 1, 0)
    Title.TextColor3 = Color3.white
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.Parent = TitleBar

    -- Botão de fechar
    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "X"
    CloseButton.Size = UDim2.new(0.2, 0, 1, 0)
    CloseButton.Position = UDim2.new(0.8, 0, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.TextColor3 = Color3.white
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar

    -- Área rolável
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Size = UDim2.new(1, 0, 0.9, 0)
    ScrollingFrame.Position = UDim2.new(0, 0, 0.1, 0)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.ScrollBarThickness = 6
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 1.5, 0)
    ScrollingFrame.Parent = MainFrame

    -- Função para criar toggles
    local function CreateToggle(text, config, description)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(0.9, 0, 0, 60)
        ToggleFrame.Position = UDim2.new(0.05, 0, 0, #ScrollingFrame:GetChildren() * 60)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        ToggleFrame.Parent = ScrollingFrame

        local ToggleText = Instance.new("TextLabel")
        ToggleText.Text = text
        ToggleText.Size = UDim2.new(0.7, 0, 0.6, 0)
        ToggleText.Position = UDim2.new(0.05, 0, 0.2, 0)
        ToggleText.TextColor3 = Color3.white
        ToggleText.BackgroundTransparency = 1
        ToggleText.TextXAlignment = Enum.TextXAlignment.Left
        ToggleText.Font = Enum.Font.Gotham
        ToggleText.TextSize = 16
        ToggleText.Parent = ToggleFrame

        local DescText = Instance.new("TextLabel")
        DescText.Text = description
        DescText.Size = UDim2.new(0.9, 0, 0.4, 0)
        DescText.Position = UDim2.new(0.05, 0, 0.6, 0)
        DescText.TextColor3 = Color3.fromRGB(180, 180, 180)
        DescText.BackgroundTransparency = 1
        DescText.TextXAlignment = Enum.TextXAlignment.Left
        DescText.Font = Enum.Font.Gotham
        DescText.TextSize = 12
        DescText.Parent = ToggleFrame

        local ToggleStatus = Instance.new("Frame")
        ToggleStatus.Size = UDim2.new(0.15, 0, 0.5, 0)
        ToggleStatus.Position = UDim2.new(0.8, 0, 0.25, 0)
        ToggleStatus.BackgroundColor3 = Settings[config] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        ToggleStatus.Parent = ToggleFrame

        local function UpdateToggle()
            ToggleStatus.BackgroundColor3 = Settings[config] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
            game:GetService("StarterGui"):SetCore("SendNotification",{
                Title = text,
                Text = Settings[config] and "ATIVADO" or "DESATIVADO",
                Duration = 1
            })
        end

        ToggleFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                Settings[config] = not Settings[config]
                UpdateToggle()
            end
        end)
    end

    -- Cria todos os toggles
    CreateToggle("EVITAR MONSTROS", "AutoAvoid", "Foge automaticamente de Rush/Screech")
    CreateToggle("SPEED BOOST", "SpeedBoost", "Aumenta sua velocidade")
    CreateToggle("NO CLIP", "NoClip", "Atravessa paredes")
    CreateToggle("HIGHLIGHT", "Highlight", "Destaca monstros perigosos")

    -- Botão de fechar
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    return ScreenGui
end

-- Funções de gameplay
local function HighlightEntities()
    for _, entity in ipairs({"Rush", "Ambush", "Screech", "Seek"}) do
        local mob = workspace:FindFirstChild(entity)
        if mob and not mob:FindFirstChildOfClass("Highlight") then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 50, 50)
            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
            highlight.Parent = mob
        end
    end
end

local function RemoveHighlights()
    for _, entity in ipairs({"Rush", "Ambush", "Screech", "Seek"}) do
        local mob = workspace:FindFirstChild(entity)
        if mob and mob:FindFirstChildOfClass("Highlight") then
            mob:FindFirstChildOfClass("Highlight"):Destroy()
        end
    end
end

-- Cria a UI
local MobileUI = CreateMobileUI()

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
            humanoid.WalkSpeed = Settings.WalkSpeed
            humanoid.JumpPower = Settings.JumpPower
        end
    end

    -- Aplica Highlight
    if Settings.Highlight then
        HighlightEntities()
    else
        RemoveHighlights()
    end
end)

-- Notificação inicial
game:GetService("StarterGui"):SetCore("SendNotification",{
    Title = "DOORS MOBILE",
    Text = "Menu carregado com sucesso!\nArraste para mover",
    Duration = 5
})
