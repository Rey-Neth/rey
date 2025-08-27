local eu = game:GetService("Players").LocalPlayer
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
                    -- BillboardGui (текст)
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

                    -- Highlight (обводка)
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

--========== Movement / TP Tool ==========--
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
    Desc  = "Set outline color to random",
    Callback = function()
        local new = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
        Settings.ESPColor = new
        UpdateESP()
    end
})

Window:SelectTab(1)
