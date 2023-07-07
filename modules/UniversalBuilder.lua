Players = game:GetService('Players')
player = Players.LocalPlayer

local initWalkSpeed = player.Character:FindFirstChildWhichIsA('Humanoid').WalkSpeed
local initJumpPower = player.Character:FindFirstChildWhichIsA('Humanoid').JumpPower
local initHipHeight = player.Character:FindFirstChildWhichIsA('Humanoid').HipHeight
local initFOV = math.floor(workspace:FindFirstChildWhichIsA('Camera').FieldOfView)

local UniversalBuilder = {} do

    function UniversalBuilder:SetLibrary(library)
		self.Library = library
	end

    function UniversalBuilder:Init()
        
        task.spawn(function()
            while task.wait() do
                if Toggles.Jumppower.Value and (player.Character and player.Character:FindFirstChildWhichIsA('Humanoid')) then
                    player.Character:FindFirstChildWhichIsA('Humanoid').JumpPower = Options.JumppowerSlider.Value
                else
                    if (player.Character and player.Character:FindFirstChildWhichIsA('Humanoid')) then
                        player.Character:FindFirstChildWhichIsA('Humanoid').JumpPower = initJumpPower
                    end
                end
            end
        end)
        
        task.spawn(function()
            while task.wait() do
                if Toggles.Walkspeed.Value and (player.Character and player.Character:FindFirstChildWhichIsA('Humanoid')) then
                    player.Character:FindFirstChildWhichIsA('Humanoid').WalkSpeed = Options.WalkspeedSlider.Value
                else
                    if (player.Character and player.Character:FindFirstChildWhichIsA('Humanoid')) then
                        player.Character:FindFirstChildWhichIsA('Humanoid').WalkSpeed = initWalkSpeed
                    end
                end
            end
        end)
        
        task.spawn(function()
            while task.wait() do
                if Toggles.HipHeight.Value and (player.Character and player.Character:FindFirstChildWhichIsA('Humanoid')) then
                    player.Character:FindFirstChildWhichIsA('Humanoid').HipHeight = Options.HipHeightSlider.Value
                else
                    if (player.Character and player.Character:FindFirstChildWhichIsA('Humanoid')) then
                        player.Character:FindFirstChildWhichIsA('Humanoid').HipHeight = initHipHeight
                    end
                end
            end
        end)

    end

    function UniversalBuilder:Build(tab)

        local PlayerSection = tab:AddLeftGroupbox('Local Player')
        local othersection = tab:AddLeftGroupbox('Other Features')

        PlayerSection:AddToggle('Walkspeed', {Text = 'Walk Speed', Default = false}):AddKeyPicker('WalkspeedKeybind', { Default = '', SyncToggleState = true, NoUI = false, Text = 'Walk Speed'})
        PlayerSection:AddSlider('WalkspeedSlider', { Text = 'Value', Default = initWalkSpeed, Min = initWalkSpeed, Max = 200, Rounding = 0, Compact = true})

        PlayerSection:AddDivider()

        PlayerSection:AddToggle('Jumppower', {Text = 'Jump Power', Default = false}):AddKeyPicker('JumppowerKeybind', { Default = '', SyncToggleState = true, NoUI = false, Text = 'Jump Power'})
        PlayerSection:AddSlider('JumppowerSlider', { Text = 'Value', Default = initJumpPower, Min = initWalkSpeed, Max = 200, Rounding = 0, Compact = true})

        PlayerSection:AddDivider()

        PlayerSection:AddToggle('HipHeight', {Text = 'Hip Height', Default = false}):AddKeyPicker('HipheightKeybind', { Default = '', SyncToggleState = true, NoUI = false, Text = 'Hip Height'})
        PlayerSection:AddSlider('HipHeightSlider', { Text = 'Value', Default = initHipHeight, Min = initHipHeight, Max = 200, Rounding = 0, Compact = true})

        othersection:AddSlider('FOVSlider', { Text = 'Camera FOV', Default = initFOV, Min = 1, Max = 120, Rounding = 0, Compact = false, Callback = function(v)
            if workspace:FindFirstChild('Camera') then workspace.Camera.FieldOfView = v end
        end})

        othersection:AddButton('Execute Infinite Yield', function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end)

        UniversalBuilder:Init()
    end
end

return UniversalBuilder
