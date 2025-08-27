--==[ LocalPlayer ]==--
local eu = game:GetService("Players").LocalPlayer

--==[ Defaults ]==--
local Settings = {
    WalkSpeed = 16,
    JumpPower = 50
}

--==[ Flags ]==--
getgenv().WalkSpeed  = false
getgenv().JumpPower  = false
getgenv().PermTpTool = false
getgenv().ESPPlayer  = false

--==[ Utils ]==--
local function round(n) return math.floor(tonumber(n) + 0.5) end
local Number = math.random(1, 1_000_000)

--==[ ESP ]==--
local function UpdateEspPlayer()
    for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= eu then
            pcall(function()
                local char = plr.Character
                local myChar = eu.Character
                if not char or not myChar then return end

                local head = char:FindFirstChild("Head")
                local myHead = myChar:FindFirstChild("Head")
                if not head or not myHead then return end

                local tag = head:FindFirstChild("NameEsp"..Number)
                if getgenv().ESPPlayer then
                    if not tag then
                        local bill = Instance.new("BillboardGui")
                        bill.Name = "NameEsp"..Number
                        bill.ExtentsOffset = Vector3.new(0, 1, 0)
                        bill.Size = UDim2.new(1, 200, 1, 30)
                        bill.Adornee = head
                        bill.AlwaysOnTop = true
                        bill.Parent = head

                        local lbl = Instance.new("TextLabel")
                        lbl.Name = "Lbl"
                        lbl.Font = Enum.Font.Code
                        lbl.TextSize = 14
                        lbl.TextWrapped = true
                        lbl.BackgroundTransparency = 1
                        lbl.TextStrokeTransparency = 0.5
                        lbl.TextColor3 = Color3.fromRGB(0,255,0)
                        lbl.Size = UDim2.new(1,0,1,0)
                        lbl.TextYAlignment = Enum.TextYAlignment.Top
                        lbl.Parent = bill
                        tag = bill
                    end
                    local hp = char:FindFirstChildOfClass("Humanoid")
                    local dist = round((myHead.Position - head.Position).Magnitude/3)
                    local hpTxt = hp and ("Health: "..round(hp.Health*100/(hp.MaxHealth > 0 and hp.MaxHealth or 100)).."%") or "Health: N/A"
                    local lbl = tag:FindFirstChild("Lbl") or tag:FindFirstChildOfClass("TextLabel")
                    if lbl then
                        lbl.Text = (plr.Name.." | "..dist.." M\n"..hpTxt)
                    end
                else
                    if tag then tag:Destroy() end
                end
            end)
        end
    end
end

task.spawn(function()
    while true do
        if getgenv().ESPPlayer then
            UpdateEspPlayer()
        end
        task.wait(0.5)
    end
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
                local chr = eu.Character
                local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = CFrame.new(pos) end
            end
        end)
        tool.Parent = eu.Backpack
    end)
end

local function DelTP()
    pcall(function()
        for _, t in ipairs(eu.Backpack:GetChildren()) do
            if t:IsA("Tool") and t.Name == "Teleport Tool" then t:Destroy() end
        end
        local c = eu.Character
        if c then
            for _, t in ipairs(c:GetChildren()) do
                if t:IsA("Tool") and t.Name == "Teleport Tool" then t:Destroy() end
            end
        end
    end)
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
    Size = UDim2.fromOffset(420, 300),
    Theme = "Dark",
})

-- Movement tab
local Movement = Window:Tab({ Title = "Movement", Icon = "chevrons-up"})
Movement:Section({ Title = "WalkSpeed" })
Movement:Toggle({ Title = "Loop WalkSpeed", Value = false, Callback = function(s) getgenv().WalkSpeed = s; LoopWalkSpeed() end })
Movement:Input ({ Title = "WalkSpeed",  Value = tostring(Settings.WalkSpeed), Callback = function(i) Settings.WalkSpeed = tonumber(i) or 16 end })

Movement:Section({ Title = "JumpPower" })
Movement:Toggle({ Title = "Loop JumpPower", Value = false, Callback = function(s) getgenv().JumpPower = s; LoopJumpPower() end })
Movement:Input ({ Title = "JumpPower",  Value = tostring(Settings.JumpPower), Callback = function(i) Settings.JumpPower = tonumber(i) or 50 end })

-- Teleport Tool tab
local Teleport = Window:Tab({ Title = "Teleport Tool", Icon = "map-pin" })
Teleport:Button({ Title = "Get Tool",    Desc = "Gives you the teleport tool.",  Callback = GetTP })
Teleport:Button({ Title = "Remove Tool", Desc = "Removes the teleport tool.",    Callback = DelTP })
Teleport:Toggle({ Title = "Permanent Tool", Desc = "Keeps teleport tool always.", Value = false,
    Callback = function(s) getgenv().PermTpTool = s; PermTpTool() end })

-- ESP tab
local EspTab = Window:Tab({ Title = "ESP", Icon = "eye" })
EspTab:Toggle({
    Title = "ESP Players",
    Desc  = "Show names, distance, HP",
    Value = false,
    Callback = function(state)
        getgenv().ESPPlayer = state
        if not state then UpdateEspPlayer() end -- выключили → подчистим
    end
})

Window:SelectTab(1)
