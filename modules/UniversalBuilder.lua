Players = game:GetService('Players')
player = Players.LocalPlayer

local UniversalBuilder = {} do

    function UniversalBuilder.Build(tab)

        local initWalkSpeed = player.Character:FindFirstChildWhichIsA('Humanoid').Walkspeed
        local initJumpPower = player.Character:FindFirstChildWhichIsA('Humanoid').JumpPower
        local initFOV = workspace:FindFirstChildWhichIsA('Camera').FieldOfView

        local WalkspeedSection = tab:AddRightGroupbox('Walk Speed')
        local JumppowerSection = tab:AddRightGroupbox('Jump Power')
        local HipHeightSection = tab:AddRightGroupbox('Hip Height')
        local othersection = tab:AddRightGroupbox('Other Features')

        WalkspeedSection:AddDivider()
        JumppowerSection:AddDivider()
        HipHeightSection:AddDivider()
        othersection:AddDivider()

        WalkspeedSection:AddToggle('Walkspeed', {Text = 'Walk Speed', Default = false})
        WalkspeedSection:AddSlider('WalkspeedSlider', { Text = '', Default = initWalkSpeed, Min = initWalkSpeed, Max = 200, Rounding = 0, Compact = true})

        JumppowerSection:AddToggle('Jumppower', {Text = 'Jump Power', Default = false})
        JumppowerSection:AddSlider('JumppowerSlider', { Text = '', Default = initJumpPower, Min = initJumpPower, Max = 200, Rounding = 0, Compact = true})

        HipHeightSection:AddToggle('HipHeight', {Text = 'Hip Height', Default = false})
        HipHeightSection:AddSlider('HipHeightSlider', { Text = '', Default = 0, Min = 0, Max = 200, Rounding = 0, Compact = true})

        othersection:AddButton('Infinite Yield', function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end)

        othersection:AddSlider('FOVSlider', { Text = 'Camera FOV', Default = initFOV, Min = 1, Max = 120, Rounding = 0, Compact = false, Callback = function(v)
            if workspace:FindFirstChild('Camera') then workspace.Camera.FieldOfView = v end
        end})
    end

end

task.spawn(function()
    while task.wait() and Toggles.Jumppower.Value do
        if (player.Character and player.Character:FindFirstChildWhichIsA('Humanoid')) then
            player.Character:FindFirstChildWhichIsA('Humanoid').JumpPower = Options.JumppowerSlider.Value
        end
    end
end)

task.spawn(function()
    while task.wait() and Toggles.Walkspeed.Value do
        if (player.Character and player.Character:FindFirstChildWhichIsA('Humanoid')) then
            player.Character:FindFirstChildWhichIsA('Humanoid').Walkspeed = Options.WalkspeedSlider.Value
        end
    end
end)

task.spawn(function()
    while task.wait() and Toggles.HipHeight.Value do
        if (player.Character and player.Character:FindFirstChildWhichIsA('Humanoid')) then
            player.Character:FindFirstChildWhichIsA('Humanoid').HipHeight = Options.HipHeightSlider.Value
        end
    end
end)

return UniversalBuilder
