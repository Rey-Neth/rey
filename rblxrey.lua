--==[ LocalPlayer ]==--
local eu = game:GetService("Players").LocalPlayer

--==[ Defaults ]==--
local Settings = {
    WalkSpeed = 16,
    JumpPower = 50,
    ESPColor = Color3.fromRGB(0, 255, 0) -- дефолтный зелёный
}

--==[ Flags ]==--
getgenv().WalkSpeed  = false
getgenv().JumpPower  = false
getgenv().PermTpTool = false
getgenv().ESPPlayer  = false

--==[ ESP ]==--
local function ApplyESP(plr)
    if not getgenv().ESPPlayer then return end
    local char = plr.Character
    if not char then return end
    if char:FindFirstChild("ESP_Highlight") then return end

    local hl = Instance.new("Highlight")
    hl.Name = "ESP_Highlight"
    hl.Adornee = char
    hl.FillTransparency = 1 -- прозрачная заливка
    hl.OutlineTransparency = 0
    hl.OutlineColor = Settings.ESPColor
    hl.Parent = char
end

local function RemoveESP(plr)
    local char = plr.Character
    if char and char:FindFirstChild("ESP_Highlight") then
        char.ESP_Highlight:Destroy()
    end
end

local function UpdateAllESP()
    for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= eu then
            if getgenv().ESPPlayer then
                ApplyESP(plr)
            else
                RemoveESP(plr)
            end
        end
    end
end

-- обновление на респавне игроков
game:GetService("Players").PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        if getgenv().ESPPlayer then
            ApplyESP(plr)
        end
    end)
end)

--==[ Teleport Tool ]==--
local function GetTP()
    pcall(function()
        local mouse = eu:GetMouse()
        local tool = Instance.new("Tool")
        tool.RequiresHandle = false
        tool.Name = "Teleport Tool"
        tool.ToolTip = "Equip and click somewhere to teleport"
        tool.Activated:Connect(function()
            local hit = mouse.Hit
            if hit then
                local pos = hit.Position + Vector3.new(0, 2.5, 0)
                local hrp = eu.Character and eu.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = CFrame.new(pos) end
            end
        end)
        tool.Parent = eu.Backpack
    end)
end

local function DelTP()
    for _, t in ipairs(eu.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.Name == "Teleport Tool" then t:Destroy() end
    end
    local c = eu.Character
    if c then
        for _, t in ipairs(c:GetChildren()) do
            if t:IsA("Tool") and t.Name == "Teleport Tool" then t:Destroy() end
        end
    end
end

local function PermTpTool()
    while getgenv().PermTpTool and task.wait(1) do
        if not eu.Backpack:FindFirstChild("Teleport Tool") and not (eu.Character and eu.Character:FindFirstChild("Teleport Tool")) then
            GetTP()
        end
    end
end

--==[ WalkSpeed / JumpPower ]==--
local function LoopWalkSpeed()
    while getgenv().WalkSpeed and task.wait(0.1) do
        local hum = eu.Character and eu.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= Settings.WalkSpeed then
            hum.WalkSpeed = Settings.WalkSpeed
        end
    end
end

local function LoopJumpPower()
    while getgenv().JumpPower and task.wait(0.1) do
        local hum = eu.Character and eu.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.JumpPower ~= Settings.JumpPower then
            hum.JumpPower = Settings.JumpPower
        end
    end
end

--==[ UI ]==--
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "Custom Hub",
    Icon = "triangle",
    Size = UDim2.fromOffset(420, 320),
    Theme = "Dark",
})

-- Movement
local Movement = Window:Tab({ Title = "Movement", Icon = "chevrons-up"})
Movement:Section({ Title = "WalkSpeed" })
Movement:Toggle({ Title = "Loop WalkSpeed", Value = false, Callback = function(s) getgenv().WalkSpeed = s; LoopWalkSpeed() end })
Movement:Input ({ Title = "WalkSpeed",  Value = tostring(Settings.WalkSpeed), Callback = function(i) Settings.WalkSpeed = tonumber(i) or 16 end })

Movement:Section({ Title = "JumpPower" })
Movement:Toggle({ Title = "Loop JumpPower", Value = false, Callback = function(s) getgenv().JumpPower = s; LoopJumpPower() end })
Movement:Input ({ Title = "JumpPower",  Value = tostring(Settings.JumpPower), Callback = function(i) Settings.JumpPower = tonumber(i) or 50 end })

-- Teleport Tool
local Teleport = Window:Tab({ Title = "Teleport Tool", Icon = "map-pin" })
Teleport:Button({ Title = "Get Tool",    Callback = GetTP })
Teleport:Button({ Title = "Remove Tool", Callback = DelTP })
Teleport:Toggle({ Title = "Permanent Tool", Value = false, Callback = function(s) getgenv().PermTpTool = s; PermTpTool() end })

-- ESP
local EspTab = Window:Tab({ Title = "ESP", Icon = "eye" })
EspTab:Toggle({
    Title = "ESP Players",
    Desc  = "Show outlines on players",
    Value = false,
    Callback = function(state)
        getgenv().ESPPlayer = state
        UpdateAllESP()
    end
})
EspTab:ColorPicker({
    Title = "ESP Color",
    Color = Settings.ESPColor,
    Callback = function(c)
        Settings.ESPColor = c
        for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
            if plr ~= eu and plr.Character and plr.Character:FindFirstChild("ESP_Highlight") then
                plr.Character.ESP_Highlight.OutlineColor = c
            end
        end
    end
})

Window:SelectTab(1)
