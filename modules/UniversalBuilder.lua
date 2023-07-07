Players = game:GetService('Players')
player = Players.LocalPlayer

local initWalkSpeed = player.Character:FindFirstChildWhichIsA('Humanoid').WalkSpeed
local initJumpPower = player.Character:FindFirstChildWhichIsA('Humanoid').JumpPower
local initHipHeight = player.Character:FindFirstChildWhichIsA('Humanoid').HipHeight
local initFOV = math.floor(workspace:FindFirstChildWhichIsA('Camera').FieldOfView)

local previousJumpPower = nil
local previousWalkSpeed = nil
local previousHipHeight = nil

local UniversalBuilder = {} do

    function UniversalBuilder:SetLibrary(library)
		self.Library = library
	end

    function UniversalBuilder:Init()
        

        task.spawn(function()
            while task.wait() do
                if Toggles.Jumppower.Value and (player.Character and player.Character:FindFirstChildWhichIsA('Humanoid')) then
                    player.Character:FindFirstChildWhichIsA('Humanoid').JumpPower = Options.JumppowerSlider.Value
                    previousJumpPower = Options.JumppowerSlider.Value
                elseif previousJumpPower ~= nil then
                    if (player.Character and player.Character:FindFirstChildWhichIsA('Humanoid')) then
                        player.Character:FindFirstChildWhichIsA('Humanoid').JumpPower = initialJumpPower
                    end
                    previousJumpPower = nil
                end
            end
        end)
        
        task.spawn(function()
            while task.wait() do
                if Toggles.Walkspeed.Value and (player.Character and player.Character:FindFirstChildWhichIsA('Humanoid')) then
                    player.Character:FindFirstChildWhichIsA('Humanoid').WalkSpeed = Options.WalkspeedSlider.Value
                    previousWalkSpeed = Options.WalkspeedSlider.Value
                elseif previousWalkSpeed ~= nil then
                    if (player.Character and player.Character:FindFirstChildWhichIsA('Humanoid')) then
                        player.Character:FindFirstChildWhichIsA('Humanoid').WalkSpeed = initWalkSpeed
                    end
                    previousWalkSpeed = nil
                end
            end
        end)
        
        task.spawn(function()
            while task.wait() do
                if Toggles.HipHeight.Value and (player.Character and player.Character:FindFirstChildWhichIsA('Humanoid')) then
                    player.Character:FindFirstChildWhichIsA('Humanoid').HipHeight = Options.HipHeightSlider.Value
                    previousHipHeight = Options.HipHeightSlider.Value
                elseif previousHipHeight ~= nil then
                    if (player.Character and player.Character:FindFirstChildWhichIsA('Humanoid')) then
                        player.Character:FindFirstChildWhichIsA('Humanoid').HipHeight = initialHipHeight
                    end
                    previousHipHeight = nil
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

        PlayerSection:AddDivider()

        PlayerSection:AddToggle('InfJump', {Text = 'Infinite Jump', Default = false}):AddKeyPicker('InfJumpKeybind', { Default = '', SyncToggleState = true, NoUI = false, Text = 'Infinite Jump'})
        PlayerSection:AddToggle('Noclip', {Text = 'Noclip', Default = false}):AddKeyPicker('NoclipKeybind', { Default = '', SyncToggleState = true, NoUI = false, Text = 'Noclip'})

        othersection:AddSlider('FOVSlider', { Text = 'Camera FOV', Default = initFOV, Min = 1, Max = 120, Rounding = 0, Compact = false, Callback = function(v)
            if workspace:FindFirstChild('Camera') then workspace.Camera.FieldOfView = v end
        end})

        othersection:AddButton('Execute Infinite Yield', function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end)

        othersection:AddButton('FPS Boost', function()

            local descendants = game:GetDescendants()
            for i = 1, #descendants do
                local v = descendants[i]
                if v.ClassName == "Texture" then
                    v.Texture = ""
                elseif v:IsA("BasePart") and v.Material ~= Enum.Material.Wood then
                    v.Material = Enum.Material.Wood
                end
            end

        end)

        othersection:AddButton('Rejoin Server', function()
            self.Library:Notify('rejoining the same server..')
            game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, game.JobId)
        end)

        othersection:AddButton('Server Hop', function()
            local s, e = pcall(function()
                local Servers = game.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                for i,v in pairs(Servers.data) do
                    if v.playing ~= v.maxPlayers then
                        game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, v.id)
                    end
                end
            end)

            if s then
                self.Library:Notify('server hopping..')
            else
                self.Library:Notify('error occured while server hopping: ' .. tostring(e))
            end
        end)

        UniversalBuilder:Init()
    end
end

return UniversalBuilder
