-- DOORS Simple Collector v1.1 (Universal)
-- Link RAW: https://raw.githubusercontent.com/Samtins/Teste/main/DoorsSimpleCollectorUniversal.lua

-- Configuração principal
local AutoCollect = false

-- Cria a interface simples
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleCollectorUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.4, 0, 0.1, 0)
MainFrame.Position = UDim2.new(0.3, 0, 0.05, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Botão de toggle
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0.8, 0)
ToggleButton.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleButton.Text = "COLETA AUTOMÁTICA: DESLIGADA"
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.Parent = MainFrame

-- Função de coleta automática
local function CollectItems()
    while AutoCollect and task.wait(0.5) do
        pcall(function()
            local character = game.Players.LocalPlayer.Character
            if character then
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    -- Verifica itens próximos
                    for _, item in ipairs(workspace:GetChildren()) do
                        if item:FindFirstChild("ClickDetector") and (humanoidRootPart.Position - item.Position).Magnitude < 15 then
                            fireclickdetector(item.ClickDetector)
                        end
                    end
                end
            end
        end)
    end
end

-- Controle do toggle
ToggleButton.MouseButton1Click:Connect(function()
    AutoCollect = not AutoCollect
    if AutoCollect then
        ToggleButton.Text = "COLETA AUTOMÁTICA: LIGADA"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        CollectItems()
    else
        ToggleButton.Text = "COLETA AUTOMÁTICA: DESLIGADA"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "DOORS Collector",
        Text = AutoCollect and "Coleta ativada!" or "Coleta desativada",
        Duration = 2
    })
end)

-- Sistema de arrasto simples
local dragging
local dragInput
local dragStart
local startPos

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
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Notificação inicial
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "DOORS Collector",
    Text = "Toque no botão para ativar a coleta!",
    Duration = 3
})

-- Garante que a UI aparece
task.spawn(function()
    repeat task.wait() until ScreenGui
    ScreenGui.Enabled = true
    ScreenGui.DisplayOrder = 999
end)
