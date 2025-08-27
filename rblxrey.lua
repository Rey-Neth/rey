-- ... (остальной код Movement/Teleport тот же)

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
