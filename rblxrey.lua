local eu = game:GetService("Players").LocalPlayer
local Lighting = game:GetService("Lighting")

local Settings = {
    WalkSpeed = 16,
    JumpPower = 50,
    ESPColor = Color3.fromRGB(0,255,0) -- зелёный по умолчанию
}

getgenv().WalkSpeed  = false
getgenv().JumpPower  = false
getgenv().PermTpTool = false
getgenv().ESPPlayer  = false

local function round(n) return math.floor(tonumber(n) + 0.5) end
local Number = math.random(1, 999999)

--========== ESP ==========--
local function UpdateESP()
    for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= eu then
            pcall(function()
                local char = plr.Character
                local myChar = eu.Character
                if not char or not myChar then return end
                local head = char:FindFirstChild("Head")
                local myHead = myChar:FindFirstChild("Head")
                if not head or not myHead then return end

                local bill = head:FindFirstChild("NameEsp"..Number)
                local hl   = char:FindFirstChild("ESP_Highlight")

                if getgenv().ESPPlayer then
                    if not bill then
                        local gui = Instance.new("BillboardGui", head)
                        gui.Name = "NameEsp"..Number
                        gui.ExtentsOffset = Vector3.new(0, 1, 0)
                        gui.Size = UDim2.new(1,200,1,30)
                        gui.AlwaysOnTop = true
                        gui.Adornee = head
                        local lbl = Instance.new("TextLabel", gui)
                        lbl.Name = "Txt"
                        lbl.Font = Enum.Font.Code
                        lbl.TextSize = 14
                        lbl.TextWrapped = true
                        lbl.Size = UDim2.new(1,0,1,0)
                        lbl.BackgroundTransparency = 1
                        lbl.TextStrokeTransparency = 0.5
                        lbl.TextColor3 = Color3.fromRGB(255,255,255)
                        lbl.TextYAlignment = Enum.TextYAlignment.Top
                    end
                    local txt = bill and bill:FindFirstChild("Txt")
                    if txt then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        local hp  = hum and math.floor(hum.Health*100/(hum.MaxHealth>0 and hum.MaxHealth or 100)) or 0
                        local dist= round((myHead.Position - head.Position).Magnitude/3)
                        txt.Text = plr.Name.." | "..dist.." M\nHealth: "..hp.."%"
                    end

                    if not hl then
                        hl = Instance.new("Highlight", char)
                        hl.Name = "ESP_Highlight"
                        hl.FillTransparency = 1
                        hl.OutlineTransparency = 0
                        hl.OutlineColor = Settings.ESPColor
                    else
                        hl.OutlineColor = Settings.ESPColor
                    end
                else
                    if bill then bill:Destroy() end
                    if hl then hl:Destroy() end
                end
            end)
        end
    end
end

task.spawn(function()
    while task.wait(0.5) do
        if getgenv().ESPPlayer then
            UpdateESP()
        end
    end
end)

--========== Teleport Tool ==========--
local function GetTP()
    local mouse = eu:GetMouse()
    local tool = Instance.new("Tool")
    tool.RequiresHandle = false
    tool.Name = "Teleport Tool"
    tool.ToolTip = "Click to teleport"
    tool.Activated:Connect(function()
        local hit = mouse.Hit
        if hit and eu.Character and eu.Character:FindFirstChild("HumanoidRootPart") then
            eu.Character.HumanoidRootPart.CFrame = CFrame.new(hit.Position + Vector3.new(0,2.5,0))
        end
    end)
    tool.Parent = eu.Backpack
end

local function DelTP()
    for _,t in ipairs(eu.Backpack:GetChildren()) do if t:IsA("Tool") and t.Name=="Teleport Tool" then t:Destroy() end end
    if eu.Character then
        for _,t in ipairs(eu.Character:GetChildren()) do if t:IsA("Tool") and t.Name=="Teleport Tool" then t:Destroy() end end
    end
end

local function PermTpTool()
    while getgenv().PermTpTool and task.wait(1) do
        if not eu.Backpack:FindFirstChild("Teleport Tool") and not (eu.Character and eu.Character:FindFirstChild("Teleport Tool")) then
            GetTP()
        end
    end
end

--========== WalkSpeed / JumpPower ==========--
local function LoopWalkSpeed()
    while getgenv().WalkSpeed and task.wait(0.1) do
        local hum = eu.Character and eu.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Settings.WalkSpeed end
    end
end

local function LoopJumpPower()
    while getgenv().JumpPower and task.wait(0.1) do
        local hum = eu.Character and eu.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = Settings.JumpPower end
    end
end

--========== Color Picker ==========--
local function HSVtoRGB(h, s, v)
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    local r, g, b
    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end
    return Color3.new(r, g, b)
end

local function OpenColorPicker(callback)
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = "CustomColorPicker"

    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0, 250, 0, 200)
    Frame.Position = UDim2.new(0.5, -125, 0.5, -100)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Frame.BorderSizePixel = 0

    local Palette = Instance.new("ImageLabel", Frame)
    Palette.Size = UDim2.new(0, 180, 0, 180)
    Palette.Position = UDim2.new(0, 10, 0, 10)
    Palette.Image = "rbxassetid://4155801252"
    Palette.BackgroundTransparency = 1

    local Brightness = Instance.new("TextButton", Frame)
    Brightness.Size = UDim2.new(0, 40, 0, 180)
    Brightness.Position = UDim2.new(0, 200, 0, 10)
    Brightness.Text = ""
    Brightness.AutoButtonColor = false

    local BrFrame = Instance.new("Frame", Brightness)
    BrFrame.Size = UDim2.new(1,0,1,0)
    BrFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)

    local CloseBtn = Instance.new("TextButton", Frame)
    CloseBtn.Size = UDim2.new(0, 230, 0, 20)
    CloseBtn.Position = UDim2.new(0,10,1,-25)
    CloseBtn.Text = "Close"
    CloseBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)

    local hue, sat, val = 0, 1, 1

    Palette.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local relX = (input.Position.X - Palette.AbsolutePosition.X) / Palette.AbsoluteSize.X
            local relY = (input.Position.Y - Palette.AbsolutePosition.Y) / Palette.AbsoluteSize.Y
            relX = math.clamp(relX, 0, 1)
            relY = math.clamp(relY, 0, 1)
            hue, sat = relX, 1-relY
            local col = HSVtoRGB(hue, sat, val)
            callback(col)
            BrFrame.BackgroundColor3 = col
        end
    end)

    Brightness.MouseButton1Down:Connect(function()
        local conn
        conn = game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local relY = (input.Position.Y - Brightness.AbsolutePosition.Y) / Brightness.AbsoluteSize.Y
                relY = math.clamp(relY, 0, 1)
                val = 1 - relY
                local col = HSVtoRGB(hue, sat, val)
                callback(col)
                BrFrame.BackgroundColor3 = col
            end
        end)
        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                conn:Disconnect()
            end
        end)
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
end

--========== UI ==========--
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "Custom Hub",
    Icon = "triangle",
    Size = UDim2.fromOffset(420, 340),
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
    Desc  = "Show names + HP + outline",
    Value = false,
    Callback = function(state)
        getgenv().ESPPlayer = state
        UpdateESP()
    end
})
EspTab:Button({
    Title = "Change ESP Color",
    Desc  = "Open Color Picker",
    Callback = function()
        OpenColorPicker(function(c)
            Settings.ESPColor = c
            for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
                if plr ~= eu and plr.Character and plr.Character:FindFirstChild("ESP_Highlight") then
                    plr.Character.ESP_Highlight.OutlineColor = c
                end
            end
        end)
    end
})

-- Brightness
local BrightnessTab = Window:Tab({ Title = "Brightness", Icon = "sun" })
BrightnessTab:Button({
    Title = "Set Max Brightness",
    Desc  = "Сделать карту яркой",
    Callback = function()
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
    end
})

-- Scripts
local ScriptsTab = Window:Tab({ Title = "Scripts", Icon = "terminal" })
ScriptsTab:Button({
    Title = "Admin Panel (Infinite Yield)",
    Desc  = "Открыть админ панель",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end
})
ScriptsTab:Button({
    Title = "Browser (Dex Explorer)",
    Desc  = "Открыть браузер объектов",
    Callback = function()
        loadstring(game:HttpGet("https://obj.wearedevs.net/2/scripts/Dex%20Explorer.lua"))()
    end
})
ScriptsTab:Button({
    Title = "Browser (Dex Explorer) Lite",
    Desc  = "Открыть браузер объектов",
    Callback = function()
        loadstring(game:HttpGet("https://gist.githubusercontent.com/dannythehacker/1781582ab545302f2b34afc4ec53e811/raw/ee5324771f017073fc30e640323ac2a9b3bfc550/dark%2520dex%2520v4"))()
    end
})



Window:SelectTab(1)
