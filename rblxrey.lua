-- Получаем игрока
local eu = game:GetService("Players").LocalPlayer

-- Настройки по умолчанию
local Settings = {
    WalkSpeed = 16,
    JumpPower = 50
}

-- Флаги
getgenv().WalkSpeed = false
getgenv().JumpPower = false
getgenv().PermTpTool = false

-- Функции
local function GetTP()
    pcall(function()
        local mouse = eu:GetMouse()
        local tool = Instance.new("Tool")
        tool.RequiresHandle = false
        tool.Name = "Teleport Tool"
        tool.ToolTip = "Equip and click somewhere to teleport"

        tool.Activated:Connect(function()
            local pos = mouse.Hit.Position + Vector3.new(0, 2.5, 0)
            eu.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
        end)

        tool.Parent = eu.Backpack
    end)
end

local function DelTP()
    pcall(function()
        for _, tool in pairs(eu.Character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Teleport Tool" then
                tool:Destroy()
            end
        end
        for _, tool in pairs(eu.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Teleport Tool" then
                tool:Destroy()
            end
        end
    end)
end

local function PermTpTool()
    while getgenv().PermTpTool and task.wait(1) do
        if not eu.Backpack:FindFirstChild("Teleport Tool") and not eu.Character:FindFirstChild("Teleport Tool") then
            GetTP()
        end
    end
end

local function WalkSpeed()
    while getgenv().WalkSpeed and task.wait(0.1) do
        if eu.Character and eu.Character:FindFirstChild("Humanoid") then
            eu.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
        end
    end
end

local function JumpPower()
    while getgenv().JumpPower and task.wait(0.1) do
        if eu.Character and eu.Character:FindFirstChild("Humanoid") then
            eu.Character.Humanoid.JumpPower = Settings.JumpPower
        end
    end
end

-- Загружаем WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "Simple Hub",
    Icon = "triangle",
    Author = "Custom",
    Size = UDim2.fromOffset(400, 250),
    Theme = "Dark"
})

-- Вкладка Movement
local Movement = Window:Tab({ Title = "Movement", Icon = "chevrons-up" })

Movement:Section({ Title = "WalkSpeed" })
Movement:Toggle({
    Title = "Loop WalkSpeed",
    Value = false,
    Callback = function(state)
        getgenv().WalkSpeed = state
        WalkSpeed()
    end
})
Movement:Input({
    Title = "WalkSpeed",
    Value = tostring(Settings.WalkSpeed),
    Callback = function(input)
        Settings.WalkSpeed = tonumber(input) or 16
    end
})

Movement:Section({ Title = "JumpPower" })
Movement:Toggle({
    Title = "Loop JumpPower",
    Value = false,
    Callback = function(state)
        getgenv().JumpPower = state
        JumpPower()
    end
})
Movement:Input({
    Title = "JumpPower",
    Value = tostring(Settings.JumpPower),
    Callback = function(input)
        Settings.JumpPower = tonumber(input) or 50
    end
})

-- Вкладка Teleport
local Teleport = Window:Tab({ Title = "Teleport Tool", Icon = "map-pin" })

Teleport:Button({
    Title = "Get Tool",
    Desc = "Gives you the teleport tool.",
    Callback = GetTP
})
Teleport:Button({
    Title = "Remove Tool",
    Desc = "Removes the teleport tool.",
    Callback = DelTP
})
Teleport:Toggle({
    Title = "Permanent Tool",
    Desc = "Keeps teleport tool always.",
    Value = false,
    Callback = function(state)
        getgenv().PermTpTool = state
        PermTpTool()
    end
})

Window:SelectTab(1)
