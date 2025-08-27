-- Получаем игрока
local eu = game:GetService("Players").LocalPlayer

-- Настройки
local Settings = {
    WalkSpeed = 16,
    JumpPower = 50
}

-- Глобальные флаги
getgenv().WalkSpeed = false
getgenv().JumpPower = false
getgenv().PermTpTool = false
getgenv().ESPPlayer = false

-- Утилиты
local function round(n) return math.floor(tonumber(n) + 0.5) end
local function isnil(x) return (x == nil) end
local Number = math.random(1, 1000000)

-- ===== ESP =====
local function UpdateEspPlayer()
    for _, v in pairs(game:GetService("Players"):GetChildren()) do
        pcall(function()
            if not isnil(v.Character) then
                if _G.ESPPlayer then
                    if not isnil(v.Character:FindFirstChild("Head")) and not v.Character.Head:FindFirstChild("NameEsp"..Number) then
                        local bill = Instance.new("BillboardGui", v.Character.Head)
                        bill.Name = "NameEsp"..Number
                        bill.ExtentsOffset = Vector3.new(0, 1, 0)
                        bill.Size = UDim2.new(1,200,1,30)
                        bill.Adornee = v.Character.Head
                        bill.AlwaysOnTop = true

                        local name = Instance.new("TextLabel", bill)
                        name.Font = Enum.Font.Code
                        name.TextWrapped = true
                        name.Text = (v.Name.." | "..round((eu.Character.Head.Position - v.Character.Head.Position).Magnitude/3).." M\nHealth: "..round(v.Character.Humanoid.Health*100/v.Character.Humanoid.MaxHealth).."%")
                        name.Size = UDim2.new(1,0,1,0)
                        name.TextYAlignment = Enum.TextYAlignment.Top
                        name.BackgroundTransparency = 1
                        name.TextStrokeTransparency = 0.5
                        name.TextColor3 = Color3.fromRGB(0,255,0)
                    else
                        -- обновление текста
                        if v.Character.Head:FindFirstChild("NameEsp"..Number) then
                            v.Character.Head["NameEsp"..Number].TextLabel.Text =
                                (v.Name.." | "..round((eu.Character.Head.Position - v.Character.Head.Position).Magnitude/3).." M\nHealth: "..round(v.Character.Humanoid.Health*100/v.Character.Humanoid.MaxHealth).."%")
                        end
                    end
                else
                    if v.Character:FindFirstChild("Head") and v.Character.Head:FindFirstChild("NameEsp"..Number) then
                        v.Character.Head["NameEsp"..Number]:Destroy()
                    end
                end
            end
        end)
    end
end

-- постоянно обновляем ESP
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().ESPPlayer then
            UpdateEspPlayer()
        end
    end
end)

-- ===== Teleport Tool =====
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
    for _, t in pairs(eu.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.Name == "Teleport Tool" then t:Destroy() end
    end
    for _, t in pairs(eu.Character:GetChildren()) do
        if t:IsA("Tool") and t.Name == "Teleport Tool" then t:Destroy() end
    end
end
local function PermTpTool()
    while getgenv().PermTpTool and task.wait(1) do
        if not eu.Backpack:FindFirstChild("Teleport Tool") and not eu.Character:FindFirstChild("Teleport Tool") then
            GetTP()
        end
    end
end

-- ===== WalkSpeed & JumpPower =====
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

-- ===== UI =====
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "Custom Hub",
    Icon = "triangle",
    Size = UDim2.fromOffset(400, 280),
    Theme = "Dark"
})

-- Movement
local Movement = Window:Tab({ Title = "Movement", Icon = "chevrons-up"})
Movement:Section({ Title = "WalkSpeed" })
Movement:Toggle({ Title = "Loop WalkSpeed", Value = false, Callback = function(s) getgenv().WalkSpeed = s; WalkSpeed() end })
Movement:Input({ Title = "WalkSpeed", Value = tostring(Settings.WalkSpeed), Callback = function(i) Settings.WalkSpeed = tonumber(i) or 16 end })
Movement:Section({ Title = "JumpPower" })
Movement:Toggle({ Title = "Loop JumpPower", Value = false, Callback = function(s) getgenv().JumpPower = s; JumpPower() end })
Movement:Input({ Title = "JumpPower", Value = tostring(Settings.JumpPower), Callback = function(i) Settings.JumpPower = tonumber(i) or 50 end })

-- Teleport Tool
local Teleport = Window:Tab({ Title = "Teleport Tool", Icon = "map-pin" })
Teleport:Button({ Title = "Get Tool", Callback = GetTP })
Teleport:Button({ Title = "Remove Tool", Callback = DelTP })
Teleport:Toggle({ Title = "Permanent Tool", Value = false, Callback = function(s) getgenv().PermTpTool = s; PermTpTool() end })

-- ESP
local EspTab = Window:Tab({ Title = "ESP", Icon = "eye" })
EspTab:Toggle({
    Title = "ESP Players",
    Desc = "Show names, distance, HP",
    Value = false,
    Callback = function(state)
        getgenv().ESPPlayer = state
        if not state then UpdateEspPlayer() end
    end
})

Window:SelectTab(1)
