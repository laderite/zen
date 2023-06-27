--[[
    Zen X Library
    by jsn#0499
]]

local Release = "v1.0"
local LibraryFolder = "ZenXLibrary"
local ConfigurationFolder = LibraryFolder .. "/Configurations"
local ConfigurationExtension = ".znx"
local ObjectID = "13320138735"

local ZenLibrary = {
    Flags = {}, 
    Themes = {
        Default = {
            Text = Color3.fromHex('#ffffff'),
            Background = Color3.fromHex('#000000'),
            PrimaryButton = Color3.fromHex('#232323'),
            SecondaryButton = Color3.fromHex('#232323'),
            Accent = Color3.fromHex('#323232'),

            ToggleBackground = Color3.fromRGB(0,0,0),
            ToggleEnabled = Color3.fromRGB(255, 100, 100),
            ToggleEnabledStroke = Color3.fromRGB(255, 100, 100),
            ToggleDisabled = Color3.fromRGB(29, 29, 29),
            ToggleDisabledStroke = Color3.fromRGB(50, 50, 50),
        }, 
        Test = {
            Text = Color3.fromHex('#ffffff'),
            Background = Color3.fromHex('#000000'),
            PrimaryButton = Color3.fromHex('#232323'),
            SecondaryButton = Color3.fromHex('#232323'),
            Accent = Color3.fromHex('#323232'),

            ToggleBackground = Color3.fromRGB(0,0,0),
            ToggleEnabled = Color3.fromRGB(255, 100, 100),
            ToggleEnabledStroke = Color3.fromRGB(255, 100, 100),
            ToggleDisabled = Color3.fromRGB(29, 29, 29),
            ToggleDisabledStroke = Color3.fromRGB(50, 50, 50),
        }
    },
}
local SelectedTheme = ZenLibrary.Themes.Default

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- UI
local Zen = game:GetObjects("rbxassetid://" .. ObjectID)[1]
Zen.Menu.Visible = false

local containerUI = gethui and gethui() or CoreGui
Zen.Parent = containerUI;
for _, UI in ipairs(containerUI:GetChildren()) do
    if UI.Name == Zen.Name and UI ~= Zen then
        UI.Enabled = false
        UI.Name = "Zen Old"
    end
end

-- Object Variables

local Camera = workspace.CurrentCamera
local Main = Zen.Menu 
local Topbar = Main.Topbar
local Toolbar = Main.Toolbar
local TabHolder = Main.TabHolder

local PremiumPrompt = Zen['Premium Prompt']
PremiumPrompt.Visible = false

Zen.DisplayOrder = 100

local Minimised = false
local Hidden = false
local Debounce = false
local CFileName = nil
local CEnabled = false
local firstTab
local firstTabName
local premiumMode = false
local libraryLoaded = false

local function loadModule(module)
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/laderite/zenscripthub/main/modules/' .. module .. '.lua'))()
end
local discord = loadModule('discord')

PremiumPrompt.Close.MouseButton1Click:Connect(function()
    PremiumPrompt.Visible = false
end)

PremiumPrompt.Invite.MouseButton1Click:Connect(function()
    PremiumPrompt.Invite.TextLabel.Text = "COPIED!"

    setclipboard(discord:GetDiscordInvite())
    discord:PromptDiscordInvite(discord:GetDiscordInvite())
    
    task.wait(1.5)
    PremiumPrompt.Invite.TextLabel.Text = "COPY INVITE"
end)

local function AddDraggingFunctionality(DragPoint, Main)
	pcall(function()
		local Dragging, DragInput, MousePos, FramePos = false
		DragPoint.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Dragging = true
				MousePos = Input.Position
				FramePos = Main.Position

				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)
		DragPoint.InputChanged:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement then
				DragInput = Input
			end
		end)
		UserInputService.InputChanged:Connect(function(Input)
			if Input == DragInput and Dragging then
				local Delta = Input.Position - MousePos
				TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position  = UDim2.new(FramePos.X.Scale,FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)}):Play()
			end
		end)
	end)
end   

local function LoadConfiguration(Configuration)
	local Data = HttpService:JSONDecode(Configuration)
	for FlagName, FlagValue in next, Data do
		if ZenLibrary.Flags[FlagName] then
            print(ZenLibrary.Flags[FlagName].CurrentValue)
			spawn(function() 
				if FlagValue then 
                    ZenLibrary.Flags[FlagName]:Set(FlagValue) 
                end  
			end)
		else
            print'error'
		end
	end
end

local function SaveConfiguration()
	if not CEnabled then return end
	local Data = {}
	for i,v in pairs(ZenLibrary.Flags) do
		Data[i] = v.CurrentValue or v.CurrentKeybind or v.CurrentOption or v.Color
	end	
	writefile(ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension, tostring(HttpService:JSONEncode(Data)))
end

function hideMenu()
    Debounce = true
    if not Topbar or not Topbar:FindFirstChild('Close') then return end
    TweenService:Create(Topbar.Close.ImageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = 1
    }):Play()
    TweenService:Create(Topbar.Close.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Transparency = 1}):Play()

    TweenService:Create(Topbar.Minimize.ImageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = 1
    }):Play()
    TweenService:Create(Topbar.Minimize.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Transparency = 1}):Play()

    TweenService:Create(Topbar.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()

    TweenService:Create(Toolbar.FirstSeperator, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Toolbar.SecondSeperator, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()

    TweenService:Create(Toolbar.Menu.Seperator, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Toolbar.Menu.ImageButton, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()


    TweenService:Create(Toolbar.TabDisplay.Seperator, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Toolbar.TabDisplay.Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()


    TweenService:Create(Toolbar.Settings.Seperator, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Toolbar.Settings.ImageButton, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()

    for _, shadow in ipairs(Main.shadowHolder:GetChildren()) do
        TweenService:Create(shadow, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
    end

    local tweenParams = {
        Quint = Enum.EasingStyle.Quint,
        BackgroundTransparency = 1,
        ImageColor3 = Color3.fromRGB(134, 134, 134),
        ImageTransparency = 1,
        TextTransparency = 1,
        Transparency = 1,
        Size = UDim2.new(1, 0, 0, 1),
        OtherSize = UDim2.new(0, 1, 0, 36)
    }
    
    local function hideContainerElements()
        for _, container in pairs(Main:GetChildren()) do
            if container.Name == "Container" then
                for _, side in pairs{"Left", "Right"} do
                    local sideContainer = container[side]
                    for _, frame in pairs(sideContainer:GetChildren()) do
                        if frame.ClassName == "Frame" and frame.Name ~= "ExampleSection" then
                            frame.Visible = false
                            TweenService:Create(frame.Title.TextLabel, TweenInfo.new(0.7, tweenParams.Quint), {TextTransparency = tweenParams.TextTransparency}):Play()
                            for _, element in pairs(frame.Holder:GetChildren()) do
                                if element.ClassName ~= "UIListLayout" then
                                    TweenService:Create(element, TweenInfo.new(0.7, tweenParams.Quint), {BackgroundTransparency = tweenParams.BackgroundTransparency}):Play()
                                    for _, child in pairs(element:GetDescendants()) do
                                        local property = child.ClassName == "UIStroke" and "Transparency" or
                                            child.ClassName == "ImageLabel" and "ImageTransparency" or
                                            child.ClassName == "TextLabel" and "TextTransparency" or child.ClassName == "TextBox" and "TextTransparency" or 
                                            child.Name == "Progress" and "BackgroundTransparency" or
                                            child.Name == "ToggleBckg" and "BackgroundTransparency" or
                                            child.Name == "Bar" and "BackgroundTransparency" or
                                            child.Name == "Circle" and "BackgroundTransparency"
                                        if property then
                                            TweenService:Create(child, TweenInfo.new(0.7, tweenParams.Quint), {[property] = tweenParams[property]}):Play()
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    hideContainerElements()
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Main.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
    TweenService:Create(Topbar, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Toolbar, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()

    wait(0.5)
    Main.Visible = false
    Minimised = true
    Debounce = false
end


function unHideMenu(firstTime)
    Debounce = true
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Visible = true
    Main.ExampleContainer.Visible = false
    local tweenParams = {
        Quint = Enum.EasingStyle.Quint,
        BackgroundTransparency = 0,
        ImageColor3 = Color3.fromRGB(134, 134, 134),
        ImageTransparency = 0,
        TextTransparency = 0,
        Transparency = 0,
        Size = UDim2.new(1, 0, 0, 1),
        OtherSize = UDim2.new(0, 1, 0, 36)
    }

    TweenService:Create(Main, TweenInfo.new(0.3, tweenParams.Quint), {BackgroundTransparency = tweenParams.BackgroundTransparency}):Play()
    wait(0.1)

    TweenService:Create(Topbar.Close.ImageLabel, TweenInfo.new(0.7, tweenParams.Quint), {ImageColor3 = tweenParams.ImageColor3, ImageTransparency = tweenParams.ImageTransparency}):Play()
    TweenService:Create(Topbar.Close.UIStroke, TweenInfo.new(0.3, tweenParams.Quint), {Transparency = tweenParams.Transparency}):Play()
    TweenService:Create(Topbar.Minimize.ImageLabel, TweenInfo.new(0.7, tweenParams.Quint), {ImageColor3 = tweenParams.ImageColor3, ImageTransparency = tweenParams.ImageTransparency}):Play()
    TweenService:Create(Topbar.Minimize.UIStroke, TweenInfo.new(0.3, tweenParams.Quint), {Transparency = tweenParams.Transparency}):Play()
    TweenService:Create(Topbar.Title, TweenInfo.new(0.7, tweenParams.Quint), {TextTransparency = tweenParams.TextTransparency}):Play()
    TweenService:Create(Toolbar.FirstSeperator, TweenInfo.new(1, tweenParams.Quint), {BackgroundTransparency = tweenParams.BackgroundTransparency}):Play()
    TweenService:Create(Toolbar.SecondSeperator, TweenInfo.new(1, tweenParams.Quint), {BackgroundTransparency = tweenParams.BackgroundTransparency}):Play()
    TweenService:Create(Toolbar.Menu.Seperator, TweenInfo.new(0.5, tweenParams.Quint), {BackgroundTransparency = tweenParams.BackgroundTransparency}):Play()
    TweenService:Create(Toolbar.TabDisplay.Seperator, TweenInfo.new(0.5, tweenParams.Quint), {BackgroundTransparency = tweenParams.BackgroundTransparency}):Play()
    TweenService:Create(Toolbar.Settings.Seperator, TweenInfo.new(0.5, tweenParams.Quint), {BackgroundTransparency = tweenParams.BackgroundTransparency}):Play()

    TweenService:Create(Main.UIStroke, TweenInfo.new(0.3, tweenParams.Quint), {Transparency = tweenParams.Transparency}):Play()
    TweenService:Create(Topbar, TweenInfo.new(0.5, tweenParams.Quint), {BackgroundTransparency = tweenParams.BackgroundTransparency}):Play()
    TweenService:Create(Toolbar, TweenInfo.new(0.5, tweenParams.Quint), {BackgroundTransparency = tweenParams.BackgroundTransparency}):Play()
    TweenService:Create(Topbar.Title, TweenInfo.new(0.5, tweenParams.Quint), {TextTransparency = tweenParams.TextTransparency}):Play()

    task.spawn(function()
        TweenService:Create(Toolbar.Menu.Seperator, TweenInfo.new(0.5, tweenParams.Quint), {Size = tweenParams.OtherSize}):Play()
        TweenService:Create(Toolbar.Menu.ImageButton, TweenInfo.new(0.5, tweenParams.Quint), {ImageTransparency = tweenParams.ImageTransparency}):Play()
        task.wait(0.1)

        TweenService:Create(Toolbar.TabDisplay.Seperator, TweenInfo.new(0.5, tweenParams.Quint), {Size = tweenParams.OtherSize}):Play()
        TweenService:Create(Toolbar.TabDisplay.Title, TweenInfo.new(0.5, tweenParams.Quint), {TextTransparency = tweenParams.TextTransparency}):Play()
        task.wait(0.1)

        TweenService:Create(Toolbar.Settings.Seperator, TweenInfo.new(0.5, tweenParams.Quint), {Size = tweenParams.OtherSize}):Play()
        TweenService:Create(Toolbar.Settings.ImageButton, TweenInfo.new(0.5, tweenParams.Quint), {ImageTransparency = tweenParams.ImageTransparency}):Play()

        for _, v in pairs(Main.shadowHolder:GetChildren()) do
            TweenService:Create(v, TweenInfo.new(0.7, tweenParams.Quint), {ImageTransparency = 0.88}):Play()
        end
    end)

    if firstTime then
        if firstTab then
            firstTab.Visible = true
            Toolbar.TabDisplay.Title.Text = firstTabName
        end
        TweenService:Create(Toolbar.FirstSeperator, TweenInfo.new(1, tweenParams.Quint), {Size = tweenParams.Size}):Play()
        TweenService:Create(Toolbar.SecondSeperator, TweenInfo.new(1, tweenParams.Quint), {Size = tweenParams.Size}):Play()
        wait(0.1)
        TweenService:Create(Topbar.Title, TweenInfo.new(0.7, tweenParams.Quint), {TextTransparency = tweenParams.TextTransparency}):Play()
        wait(0.1)
        TweenService:Create(Topbar.Minimize.ImageLabel, TweenInfo.new(0.7, tweenParams.Quint), {ImageColor3 = tweenParams.ImageColor3}):Play()
        TweenService:Create(Topbar.Minimize.ImageLabel, TweenInfo.new(0.7, tweenParams.Quint), {ImageTransparency = tweenParams.ImageTransparency}):Play()
        TweenService:Create(Topbar.Minimize.UIStroke, TweenInfo.new(0.7, tweenParams.Quint), {Transparency = tweenParams.Transparency}):Play()
        wait(0.1)
        TweenService:Create(Topbar.Close.ImageLabel, TweenInfo.new(0.7, tweenParams.Quint), {ImageColor3 = tweenParams.ImageColor3}):Play()
        TweenService:Create(Topbar.Close.ImageLabel, TweenInfo.new(0.7, tweenParams.Quint), {ImageTransparency = tweenParams.ImageTransparency}):Play()
        TweenService:Create(Topbar.Close.UIStroke, TweenInfo.new(0.7, tweenParams.Quint), {Transparency = tweenParams.Transparency}):Play()
    end

    local function showContainerElements()
        for _, container in pairs(Main:GetChildren()) do
            if container.Name == "Container" then
                for _, side in pairs{"Left", "Right"} do
                    local sideContainer = container[side]
                    for _, frame in pairs(sideContainer:GetChildren()) do
                        if frame.ClassName == "Frame" and frame.Name ~= "ExampleSection" then
                            frame.Visible = true
                            TweenService:Create(frame.Title.TextLabel, TweenInfo.new(0.7, tweenParams.Quint), {TextTransparency = tweenParams.TextTransparency}):Play()
                            for _, element in pairs(frame.Holder:GetChildren()) do
                                if element.ClassName ~= "UIListLayout" then
                                    TweenService:Create(element, TweenInfo.new(0.7, tweenParams.Quint), {BackgroundTransparency = tweenParams.BackgroundTransparency}):Play()
                                    for _, child in pairs(element:GetDescendants()) do
                                        local property = child.ClassName == "UIStroke" and "Transparency" or
                                            (child.ClassName == "ImageLabel" and child.Name ~= "Icon") and "ImageTransparency" or
                                            child.ClassName == "TextLabel" and "TextTransparency" or child.ClassName == "TextBox" and "TextTransparency" or 
                                            child.Name == "Progress" and "BackgroundTransparency" or
                                            child.Name == "ToggleBckg" and "BackgroundTransparency" or
                                            child.Name == "Bar" and "BackgroundTransparency" or
                                            child.Name == "Circle" and "BackgroundTransparency"
                                        if property then
                                            TweenService:Create(child, TweenInfo.new(0.7, tweenParams.Quint), {[property] = tweenParams[property]}):Play()
                                        end
                                    end
                                end
                                task.wait(0.02)
                            end
                        end
                    end
                end
            end
        end
    end
    showContainerElements()


    wait(0.5)
	Minimised = false
	Debounce = false
    if firstTime then libraryLoaded = true end
end

function maximizeMenu()
end

function minimizeMenu()
end

function openTabHolder()
    Debounce = true
    TabHolder.BackgroundTransparency = 1
    TabHolder.MainHolder.Size = UDim2.new(0, 1, 0, 392)
    TabHolder.Visible = true

    local tweenParams = {
        Quint = Enum.EasingStyle.Quint,
        BackgroundTransparency = 0,
        TextTransparency = 0,
        Size = UDim2.new(0, 200, 0, 392),
    }

    TweenService:Create(TabHolder, TweenInfo.new(0.3, tweenParams.Quint), {BackgroundTransparency = 0.55}):Play()
    TweenService:Create(TabHolder.MainHolder, TweenInfo.new(0.2, tweenParams.Quint), {Size = tweenParams.Size}):Play()
    wait(0.1)
    for _,v in pairs(TabHolder.MainHolder.Holder:GetChildren()) do
        if v.ClassName == "TextButton" then
            TweenService:Create(v, TweenInfo.new(0.3, tweenParams.Quint), {BackgroundTransparency = tweenParams.BackgroundTransparency}):Play()
            TweenService:Create(v.UIStroke, TweenInfo.new(0.3, tweenParams.Quint), {Transparency = tweenParams.TextTransparency}):Play()
            TweenService:Create(v.TextLabel, TweenInfo.new(0.3, tweenParams.Quint), {TextTransparency = tweenParams.TextTransparency}):Play()
        end
        task.wait(0.03)
    end

    wait(0.1)
    Debounce = false
end

function closeTabHolder()    
    Debounce = true
    local tweenParams = {
        Quint = Enum.EasingStyle.Quint,
        BackgroundTransparency = 1,
        TextTransparency = 1,
        Size = UDim2.new(0, 1, 0, 392),
    }
    
    for _,v in pairs(TabHolder.MainHolder.Holder:GetChildren()) do
        if v.ClassName == "TextButton" then
            TweenService:Create(v, TweenInfo.new(0.3, tweenParams.Quint), {BackgroundTransparency = tweenParams.BackgroundTransparency}):Play()
            TweenService:Create(v.UIStroke, TweenInfo.new(0.3, tweenParams.Quint), {Transparency = tweenParams.BackgroundTransparency}):Play()
            TweenService:Create(v.TextLabel, TweenInfo.new(0.3, tweenParams.Quint), {TextTransparency = tweenParams.TextTransparency}):Play()
        end
    end
    
    wait(0.1)
    TweenService:Create(TabHolder.MainHolder, TweenInfo.new(0.3, tweenParams.Quint), {Size = tweenParams.Size}):Play()
    wait(0.1)
    TweenService:Create(TabHolder, TweenInfo.new(0.3, tweenParams.Quint), {BackgroundTransparency = tweenParams.BackgroundTransparency}):Play()
    wait(0.2)
    TabHolder.Visible = false
    Debounce = false
end

function ZenLibrary:Notification(NotificationSettings)
    
end

function showElement(element)
    local tweenParams = {
        Quint = Enum.EasingStyle.Quint,
        BackgroundTransparency = 0,
        ImageColor3 = Color3.fromRGB(134, 134, 134),
        ImageTransparency = 0,
        TextTransparency = 0,
        Transparency = 0,
        Size = UDim2.new(1, 0, 0, 1),
        OtherSize = UDim2.new(0, 1, 0, 36)
    }
    TweenService:Create(element, TweenInfo.new(0.7, tweenParams.Quint), {BackgroundTransparency = 0}):Play()
    for _, child in pairs(element:GetDescendants()) do
        local property = child.ClassName == "UIStroke" and "Transparency" or
            child.ClassName == "ImageLabel" and "ImageTransparency" or
            child.ClassName == "TextLabel" and "TextTransparency" or child.ClassName == "TextBox" and "TextTransparency" or 
            child.Name == "Progress" and "BackgroundTransparency" or
            child.Name == "ToggleBckg" and "BackgroundTransparency" or
            child.Name == "Bar" and "BackgroundTransparency" or
            child.Name == "Circle" and "BackgroundTransparency"
        if property then
            TweenService:Create(child, TweenInfo.new(0.7, tweenParams.Quint), {[property] = tweenParams[property]}):Play()
        end
    end
end

function promptPremium()
    if PremiumPrompt.Visible then return end
    local tweenParams = {
        Quint = Enum.EasingStyle.Quint,
        BackgroundTransparency = 1,
        ImageTransparency = 1,
        TextTransparency = 1,
        Transparency = 1,
    }
    PremiumPrompt.BackgroundTransparency = 1
    for _, child in pairs(PremiumPrompt:GetDescendants()) do
        local property = child.ClassName == "UIStroke" and "Transparency" or
            child.ClassName == "ImageLabel" and "ImageTransparency" or
            child.ClassName == "TextLabel" and "TextTransparency" or child.ClassName == "TextBox" and "TextTransparency" or child.ClassName == "TextButton" and "BackgroundTransparency" or 
            child.Name == "Progress" and "BackgroundTransparency" or
            child.Name == "ToggleBckg" and "BackgroundTransparency" or
            child.Name == "Bar" and "BackgroundTransparency" or
            child.Name == "Circle" and "BackgroundTransparency"
        if property then
            child[property] = tweenParams[property]
        end
    end
    PremiumPrompt.Visible = true
    local tweenParams = {
        Quint = Enum.EasingStyle.Quint,
        BackgroundTransparency = 0,
        ImageTransparency = 0,
        TextTransparency = 0,
        Transparency = 0,
    }

    TweenService:Create(PremiumPrompt, TweenInfo.new(0.2, tweenParams.Quint), {BackgroundTransparency = tweenParams.BackgroundTransparency}):Play()
    wait(0.1)

    TweenService:Create(PremiumPrompt.Close.ImageLabel, TweenInfo.new(0.7, tweenParams.Quint), {ImageColor3 = tweenParams.ImageColor3, ImageTransparency = tweenParams.ImageTransparency}):Play()
    TweenService:Create(PremiumPrompt.Close.UIStroke, TweenInfo.new(0.5, tweenParams.Quint), {Transparency = tweenParams.Transparency}):Play()
    TweenService:Create(PremiumPrompt.Title, TweenInfo.new(0.7, tweenParams.Quint), {TextTransparency = tweenParams.TextTransparency}):Play()
    TweenService:Create(PremiumPrompt.Desc, TweenInfo.new(0.7, tweenParams.Quint), {TextTransparency = tweenParams.TextTransparency}):Play()

    TweenService:Create(PremiumPrompt.Invite, TweenInfo.new(0.7, tweenParams.Quint), {BackgroundTransparency = tweenParams.TextTransparency}):Play()
    TweenService:Create(PremiumPrompt.Invite.TextLabel, TweenInfo.new(0.7, tweenParams.Quint), {TextTransparency = tweenParams.TextTransparency}):Play()
    TweenService:Create(PremiumPrompt.Invite.UIStroke, TweenInfo.new(0.5, tweenParams.Quint), {Transparency = tweenParams.Transparency}):Play()

    TweenService:Create(PremiumPrompt.UIStroke, TweenInfo.new(0.5, tweenParams.Quint), {Transparency = tweenParams.Transparency}):Play()
end

function ZenLibrary:CreateMenu(Settings)
    Main.BackgroundTransparency = 1
    Topbar.BackgroundTransparency = 1
    Topbar.Title.Text = Settings.Name
    Topbar.Title.TextTransparency = 1

    Topbar.Close.UIStroke.Transparency = 1
    Topbar.Close.ImageLabel.ImageTransparency = 1
    Topbar.Minimize.UIStroke.Transparency = 1
    Topbar.Minimize.ImageLabel.ImageTransparency = 1

    Toolbar.BackgroundTransparency = 1
    Toolbar.FirstSeperator.Size = UDim2.new(0,0,0,1)
    Toolbar.SecondSeperator.Size = UDim2.new(0,0,0,1)
    Toolbar.Menu.Seperator.Size = UDim2.new(0,1,0,0)
    Toolbar.Menu.ImageButton.ImageTransparency = 1

    Toolbar.Settings.Seperator.Size = UDim2.new(0,1,0,0)
    Toolbar.Settings.ImageButton.ImageTransparency = 1 

    Toolbar.TabDisplay.Seperator.Size = UDim2.new(0,1,0,0)
    Toolbar.TabDisplay.Title.TextTransparency = 1

    TabHolder.Visible = false

    local ExampleSection = Main.ExampleContainer.Left.ExampleSection
    ExampleSection.Visible = false

    Main.Position = UDim2.new(0.5,0,0.5,0)
    Main.Visible = false

    pcall(function()
		if not Settings.ConfigurationSaving.FileName then
			Settings.ConfigurationSaving.FileName = tostring(game.PlaceId)
		end
		if not isfolder(LibraryFolder.."/".."Configurations") then
			
		end
		if Settings.ConfigurationSaving.Enabled == nil then
			Settings.ConfigurationSaving.Enabled = false
		end
		CFileName = Settings.ConfigurationSaving.FileName
		ConfigurationFolder = Settings.ConfigurationSaving.FolderName or ConfigurationFolder
		CEnabled = Settings.ConfigurationSaving.Enabled

		if Settings.ConfigurationSaving.Enabled then
			if not isfolder(ConfigurationFolder) then
				makefolder(ConfigurationFolder)
			end	
		end
	end)

    -- Tab
    local tabHandler = {}

    function tabHandler:Load()
        if Debounce then return end
        task.wait(1)
        unHideMenu(true)
    end

    function tabHandler:SetPremiumMode()
        premiumMode = not premiumMode
        if premiumMode then
            for _, container in pairs(Main:GetChildren()) do
                if container.Name == "Container" then
                    for _, side in pairs{"Left", "Right"} do
                        local sideContainer = container[side]
                        for _, frame in pairs(sideContainer:GetDescendants()) do
                            if frame.ClassName == "TextButton" and frame:FindFirstChild('TextLabel') and frame.Name:match('(Locked)') then
                                frame.Visible = false
                            end
                        end
                    end
                end
            end
        end
    end

    function tabHandler:CreateTab(Name)
        TabHolder.MainHolder.Holder.Example.Visible = false
        local TabButton = TabHolder.MainHolder.Holder.Example:Clone()
        TabButton.Name = Name
        TabButton.TextLabel.Text = Name
        TabButton.BackgroundTransparency = 1
        TabButton.TextLabel.TextTransparency = 1
        TabButton.UIStroke.Transparency = 1
        TabButton.Parent = TabHolder.MainHolder.Holder
        TabButton.Visible = true

        local Container = Main.ExampleContainer:Clone()
        Container.Name = "Container"
        Container.Parent = Main
        Container.Visible = false

        if firstTab == nil then
            firstTab = Container
            firstTabName = Name
        end

        TabButton.MouseButton1Click:Connect(function()
            if Debounce then return end
            for _,v in pairs(Main:GetChildren()) do
                if v.Name == "Container" then
                    v.Visible = false
                end
            end
            Toolbar.TabDisplay.Title.Text = TabButton.TextLabel.Text
            Container.Visible = true
            closeTabHolder()
        end)
        
        local sectionHandler = {}

        function sectionHandler:CreateSection(SectionSettings)
            local ExampleSection = Main.ExampleContainer.Left.ExampleSection
            local Section = ExampleSection:Clone()
            
            Section.Name = SectionSettings.Name
            Section.Title.TextLabel.Text = SectionSettings.Name
            if SectionSettings.Side == "Left" then 
                Section.Parent = Container.Left 
            else 
                Section.Parent = Container.Right 
            end
            for _,v in pairs(Section.Holder:GetChildren()) do
                if v.ClassName ~= "UIListLayout" then
                    v:Destroy()
                end
            end

            local elementHandler = {}

            function elementHandler:CreateSlider(SliderSettings)
                local Dragging = false
                -- title,min,max,start,inc,callback
                local min = SliderSettings.Min
                local max = SliderSettings.Max
                local start = SliderSettings.CurrentValue
                local inc = SliderSettings.Increment
                local suffix = SliderSettings.Suffix
            
                local Slider = ExampleSection.Holder.Slider:Clone()
                Slider.Name = SliderSettings.Name
                Slider.Title.Text = SliderSettings.Name
                Slider.Bar.BackgroundTransparency = 1
                Slider.Bar.Progress.BackgroundTransparency = 1
                Slider.Bar.Progress.Circle.BackgroundTransparency = 1
                Slider.BackgroundTransparency = 1
                Slider.UIStroke.Transparency = 1
                Slider.Title.TextTransparency = 1
                Slider.Value.TextTransparency = 1
                Slider.Visible = true
                Slider.Parent = Section.Holder

                if libraryLoaded then showElement(Slider) end
            
                local Slider,SliderMain = {Value = start}, Slider
                local value = SliderMain:FindFirstChild('Value')
                local dragging = false
            
                local function move(Input)
                    local XSize = math.clamp((Input.Position.X - SliderMain.Bar.AbsolutePosition.X) / SliderMain.Bar.AbsoluteSize.X, 0, 1)
                    local Increment = inc and (max / ((max - min) / (inc * 4))) or (max >= 50 and max / ((max - min) / 4)) or (max >= 25 and max / ((max - min) / 2)) or (max / (max - min))
                    local SizeRounded = UDim2.new((math.round(XSize * ((max / Increment) * 4)) / ((max / Increment) * 4)), 0, 1, 0) 
                    TweenService:Create(SliderMain.Bar.Progress,TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Size = SizeRounded}):Play() 
                    local Val = math.round((((SizeRounded.X.Scale * max) / max) * (max - min) + min) * 20) / 20
                    value.Text = tostring(Val) .. suffix
                    Slider.Value = Val
                    SliderSettings.Callback(Slider.Value)
                    SaveConfiguration()
                end
            
                SliderMain.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
                SliderMain.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                game:GetService("UserInputService").InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then move(input) end end)
            
                function SliderSettings:Set(val)
                    Slider.Value = val
                    local a = tostring(val and (val / max) * (max - min) + min) or 0
                    value.Text = tostring(a) .. suffix
                    SliderMain.Bar.Progress.Size = UDim2.new((val or 0 - min) / (max - min), 0, 1, 0)
                    sliderHandler.Callback(Slider.Value)
                    SaveConfiguration()
                end	
            
                SliderSettings:Set(start)

                if Settings.ConfigurationSaving then
                    if Settings.ConfigurationSaving.Enabled and SliderSettings.Flag then
                        ZenLibrary.Flags[SliderSettings.Flag] = SliderSettings
                    end
                end
                return SliderSettings
            end

            function elementHandler:CreateToggle(ToggleSettings)

                local Toggle = ExampleSection.Holder.Toggle:Clone()
                Toggle.Name = ToggleSettings.Name
                Toggle.TextLabel.Text = ToggleSettings.Name
                Toggle.Status.ToggleBckg.BackgroundTransparency = 1
                Toggle.Status.ToggleBckg.UIStroke.Transparency = 1
                Toggle.Status.ToggleBckg.Icon.ImageTransparency = 1
                Toggle.BackgroundTransparency = 1
                Toggle.UIStroke.Transparency = 1
                Toggle.TextLabel.TextTransparency = 1
                Toggle.Visible = true
                Toggle.Parent = Section.Holder

                if libraryLoaded then showElement(Toggle) end

                if not ToggleSettings.CurrentValue then
                    Toggle.Status.ToggleBckg.BackgroundColor3 = SelectedTheme.ToggleDisabled
                    Toggle.Status.ToggleBckg.UIStroke.Transparency = 0
                    Toggle.Status.ToggleBckg.UIStroke.Color = SelectedTheme.ToggleDisabledStroke
                else
                    Toggle.Status.ToggleBckg.BackgroundColor3 = SelectedTheme.Accent
                    Toggle.Status.ToggleBckg.UIStroke.Transparency = 1
                end

                Toggle.MouseEnter:Connect(function()
                    game:GetService('TweenService'):Create(Toggle, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(42, 42, 42)}):Play()
                end)
    
                Toggle.MouseLeave:Connect(function()
                    game:GetService('TweenService'):Create(Toggle, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
                    TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(50, 50, 50)}):Play()
                end)

                Toggle.MouseButton1Click:Connect(function()
                    if ToggleSettings.CurrentValue then
                        ToggleSettings.CurrentValue = false
                        game:GetService('TweenService'):Create(Toggle.Status.ToggleBckg, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(29, 29, 29)}):Play()
                        game:GetService('TweenService'):Create(Toggle.Status.ToggleBckg.UIStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(50, 50, 50)}):Play()
                        game:GetService('TweenService'):Create(Toggle.Status.ToggleBckg.UIStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
                        game:GetService('TweenService'):Create(Toggle.Status.ToggleBckg.Icon, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
                    else
                        ToggleSettings.CurrentValue = true
                        game:GetService('TweenService'):Create(Toggle.Status.ToggleBckg, TweenInfo.new(0.3), {BackgroundColor3 = SelectedTheme.ToggleEnabled}):Play()
                        game:GetService('TweenService'):Create(Toggle.Status.ToggleBckg.UIStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
                        game:GetService('TweenService'):Create(Toggle.Status.ToggleBckg.Icon, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
                    end

                    local Success, Response = pcall(function()
                        ToggleSettings.Callback(ToggleSettings.CurrentValue)
                    end)
                    if not Success then
                        Toggle.TextLabel.Text = "Callback Error"
                        warn("» Zen X Callback Error ("..ToggleSettings.Name..")\n" ..tostring(Response))
                        task.wait(1.5)
                        Toggle.TextLabel.Text = ToggleSettings.Name
                    end
                    SaveConfiguration()
                end)

                function ToggleSettings:Set(newValue)
                    print"called!!!"
                    if not newValue then
                        ToggleSettings.CurrentValue = false
                        game:GetService('TweenService'):Create(Toggle.Status.ToggleBckg, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(29, 29, 29)}):Play()
                        game:GetService('TweenService'):Create(Toggle.Status.ToggleBckg.UIStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(50, 50, 50)}):Play()
                        game:GetService('TweenService'):Create(Toggle.Status.ToggleBckg.UIStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
                        game:GetService('TweenService'):Create(Toggle.Status.ToggleBckg.Icon, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
                    else
                        ToggleSettings.CurrentValue = true
                        game:GetService('TweenService'):Create(Toggle.Status.ToggleBckg, TweenInfo.new(0.3), {BackgroundColor3 = SelectedTheme.ToggleEnabled}):Play()
                        game:GetService('TweenService'):Create(Toggle.Status.ToggleBckg.UIStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
                        game:GetService('TweenService'):Create(Toggle.Status.ToggleBckg.Icon, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
                    end

                    local Success, Response = pcall(function()
                        ToggleSettings.Callback(ToggleSettings.CurrentValue)
                    end)
                    if not Success then
                        Toggle.TextLabel.Text = "Callback Error"
                        warn("» Zen X Callback Error ("..TextboxSettings.Name..")\n" ..tostring(Response))
                        task.wait(1.5)
                        Toggle.TextLabel.Text = ToggleSettings.Name
                    end
                    SaveConfiguration()
                end

                if Settings.ConfigurationSaving then
                    if Settings.ConfigurationSaving.Enabled and ToggleSettings.Flag then
                        ZenLibrary.Flags[ToggleSettings.Flag] = ToggleSettings
                    end
                end
    
                return ToggleSettings
            end

            function elementHandler:CreateTextbox(TextboxSettings)
                local errored = false
                local Textbox = ExampleSection.Holder.Textbox:Clone()

                Textbox.Name = TextboxSettings.Name
                Textbox.Status.TextBox.PlaceholderText = "..."
                Textbox.TextLabel.Text = TextboxSettings.Name
                Textbox.BackgroundTransparency = 1
                Textbox.UIStroke.Transparency = 1
                Textbox.Status.TextBox.UIStroke.Transparency = 1
                Textbox.TextLabel.TextTransparency = 1
                Textbox.Visible = true
                Textbox.Parent = Section.Holder

                if libraryLoaded then showElement(Textbox) end

                Textbox.MouseEnter:Connect(function()
                    game:GetService('TweenService'):Create(Textbox, TweenInfo.new(0.6), {BackgroundColor3 = Color3.fromRGB(42, 42, 42)}):Play()
                end)
    
                Textbox.MouseLeave:Connect(function()
                    game:GetService('TweenService'):Create(Textbox, TweenInfo.new(0.6), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
                end)
    
                Textbox.Status.TextBox.FocusLost:Connect(function()
                    TextboxSettings.CurrentText = Textbox.Status.TextBox.Text
                    local Success, Response = pcall(function()
                        TextboxSettings.Callback(TextboxSettings.CurrentText)
                    end)
                    if not Success then
                        TweenService:Create(Textbox, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(40, 0, 0)}):Play() -- ERROR
                        TweenService:Create(Textbox.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(76, 0, 0)}):Play()
                        TweenService:Create(Textbox.Status.TextBox.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(76, 0, 0)}):Play()
                        Textbox.TextLabel.Text = "Callback Error"
                        warn("» Zen X Callback Error ("..TextboxSettings.Name..")\n" ..tostring(Response))
                        errored = true
                        wait(1)
                        errored = false
                        Textbox.TextLabel.Text = TextboxSettings.Name
                        TweenService:Create(Textbox, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play() -- Still
                        TweenService:Create(Textbox.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(50, 50, 50)}):Play()
                        TweenService:Create(Textbox.Status.TextBox.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(50, 50, 50)}):Play()
                    else
                        if TextboxSettings.RemoveTextAfterFocusLost then
                            Textbox.Status.TextBox.Text = ""
                        end
                    end
                    SaveConfiguration()
                end)

                function TextboxSettings:Set(NewButton)
                    TextboxSettings.CurrentText = NewButton
                    local Success, Response = pcall(function()
                        TextboxSettings.Callback(TextboxSettings.CurrentText)
                    end)
                    if not Success then
                        TweenService:Create(Textbox, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(40, 0, 0)}):Play() -- ERROR
                        TweenService:Create(Textbox.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(76, 0, 0)}):Play()
                        TweenService:Create(Textbox.Status.TextBox.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(76, 0, 0)}):Play()
                        Textbox.TextLabel.Text = "Callback Error"
                        warn("» Zen X Callback Error ("..TextboxSettings.Name..")\n" ..tostring(Response))
                        errored = true
                        wait(1)
                        errored = false
                        Textbox.TextLabel.Text = TextboxSettings.Name
                        TweenService:Create(Textbox, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play() -- Still
                        TweenService:Create(Textbox.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(50, 50, 50)}):Play()
                        TweenService:Create(Textbox.Status.TextBox.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(50, 50, 50)}):Play()
                    else
                        if TextboxSettings.RemoveTextAfterFocusLost then
                            Textbox.Status.TextBox.Text = ""
                        end
                    end
                    SaveConfiguration()
                end

                if Settings.ConfigurationSaving then
                    if Settings.ConfigurationSaving.Enabled and TextboxSettings.Flag then
                        ZenLibrary.Flags[TextboxSettings.Flag] = TextboxSettings
                    end
                end
    
                return TextboxSettings
            end

            function elementHandler:CreateButton(ButtonSettings)
                local hovering = false
                local errored = false

                local Button = ExampleSection.Holder.Button:Clone()

                Button.Name = ButtonSettings.Name
                Button.TextLabel.Text = ButtonSettings.Name
                Button.BackgroundTransparency = 1
                Button.UIStroke.Transparency = 1
                Button.Status.ActualThing.ImageLabel.ImageTransparency = 1
                Button.TextLabel.TextTransparency = 1
                Button.Visible = true
                Button.Parent = Section.Holder

                if libraryLoaded then showElement(Button) end

                Button.MouseButton1Click:Connect(function()
                    if errored then return end
                    local Success, Response = pcall(ButtonSettings.Callback)
                    if not Success then
                        TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(40, 0, 0)}):Play() -- ERROR
                        TweenService:Create(Button.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(76, 0, 0)}):Play()
                        Button.TextLabel.Text = "Callback Error! Check Console"
                        warn("» Zen X Callback Error ("..ButtonSettings.Name..")\n" ..tostring(Response))
                        errored = true
                        wait(1)
                        errored = false
                        Button.TextLabel.Text = ButtonSettings.Name
                        TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play() -- Still
                        TweenService:Create(Button.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(50, 50, 50)}):Play()
                    else
                        TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(49, 49, 49)}):Play() -- Clicked
                        TweenService:Create(Button.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(50, 50, 50)}):Play()
                        wait(0.2)
                        if not hovering then 
                            TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
                        else
                            TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(42, 42, 42)}):Play() -- Hover
                        end
                    end
                end)
    
                Button.MouseEnter:Connect(function()
                    if errored then return end
                    hovering = true
                    TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(42, 42, 42)}):Play()
                    TweenService:Create(Button.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(50, 50, 50)}):Play()
                end)
    
                Button.MouseLeave:Connect(function()
                    if errored then return end
                    hovering = false
                    TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
                    TweenService:Create(Button.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(50, 50, 50)}):Play()
                end)
    
                function ButtonSettings:Set(NewButton)
                    Button.Title.Text = NewButton
                    Button.Name = NewButton
                end
    
                return ButtonSettings
            end

            function elementHandler:CreateDropdown(DropdownSettings)
                local Dropdown = ExampleSection.Holder.Dropdown:Clone()
                Dropdown.Name = DropdownSettings.Name
                Dropdown.Main.Title.Text = DropdownSettings.Name
                Dropdown.BackgroundTransparency = 1
                Dropdown.UIStroke.Transparency = 1
                Dropdown.Main.Image.ImageLabel.ImageTransparency = 1
                Dropdown.Main.Image.ImageLabel.Rotation = 180
                Dropdown.Main.Title.TextTransparency = 1
                Dropdown.Visible = true
                Dropdown.List.Visible = false
                Dropdown.Parent = Section.Holder
                local hovering = false

                if libraryLoaded then showElement(Dropdown) end

                Dropdown.List.Holder.Option.Visible = false

                if typeof(DropdownSettings.CurrentOption) == "string" then
                    DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption}
                end
                
                if not DropdownSettings.MultipleOptions then
                    DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption[1]}
                end
                
                if DropdownSettings.MultipleOptions then
                    if #DropdownSettings.CurrentOption == 1 then
                        Dropdown.Main.Title.Text = DropdownSettings.Name .. " - " .. DropdownSettings.CurrentOption[1]
                    elseif #DropdownSettings.CurrentOption == 0 then
                        Dropdown.Main.Title.Text = DropdownSettings.Name .. " - "
                    else
                        Dropdown.Main.Title.Text = DropdownSettings.Name .. " - multiple.."
                    end
                else
                    Dropdown.Main.Title.Text = DropdownSettings.Name .. " - " .. DropdownSettings.CurrentOption[1]
                end

                Dropdown.MouseButton1Click:Connect(function()
                    if Debounce then return end
                    if Dropdown.List.Visible then
                        Debounce = true
                        for _, DropdownOpt in ipairs(Dropdown.List.Holder:GetChildren()) do
                            if DropdownOpt.ClassName == "Frame" and DropdownOpt.Name ~= "Option" then
                                TweenService:Create(DropdownOpt.Title, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
                                TweenService:Create(DropdownOpt.Seperator, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
                            end
                        end
                        TweenService:Create(Dropdown.Main.Image.ImageLabel, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Rotation = 180}):Play()	
                        Dropdown.List.Visible = false
                        Debounce = false
                    else
                        Dropdown.List.Visible = true
                        TweenService:Create(Dropdown.Main.Image.ImageLabel, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Rotation = 0}):Play()	
                        for _, DropdownOpt in ipairs(Dropdown.List.Holder:GetChildren()) do
                            if DropdownOpt.ClassName == "Frame" and DropdownOpt.Name ~= "Option" then
                                TweenService:Create(DropdownOpt.Title, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
                                TweenService:Create(DropdownOpt.Seperator, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
                            end
                        end
                    end
                end)

                Dropdown.MouseEnter:Connect(function()
                    TweenService:Create(Dropdown.Main, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(42, 42, 42)}):Play()
                    TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(50, 50, 50)}):Play()
                end)
    
                Dropdown.MouseLeave:Connect(function()
                    TweenService:Create(Dropdown.Main, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
                    TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Color = Color3.fromRGB(50, 50, 50)}):Play()
                end)


                for _, Option in ipairs(DropdownSettings.Options) do
                    local DropdownOption = ExampleSection.Holder.Dropdown.List.Holder.Option:Clone()
                    DropdownOption.Name = Option
                    DropdownOption.Title.Text = Option
                    DropdownOption.Parent = Dropdown.List.Holder
                    DropdownOption.Visible = true
    
                    if DropdownSettings.CurrentOption == Option then
                        DropdownOption.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                        DropdownOption.Title.TextColor3 = Color3.fromRGB(175, 175, 175)
                    end
    
                    DropdownOption.BackgroundTransparency = 1
                    DropdownOption.Title.TextTransparency = 1
    
                    DropdownOption.ZIndex = 50
                    DropdownOption.MouseButton1Click:Connect(function()
                        if not DropdownSettings.MultipleOptions and table.find(DropdownSettings.CurrentOption, Option) then 
                            return
                        end
    
                        if table.find(DropdownSettings.CurrentOption, Option) then
                            table.remove(DropdownSettings.CurrentOption, table.find(DropdownSettings.CurrentOption, Option))
                            if DropdownSettings.MultipleOptions then
                                if #DropdownSettings.CurrentOption == 1 then
                                    Dropdown.Main.Title.Text = DropdownSettings.Name .. " - " .. DropdownSettings.CurrentOption[1]
                                elseif #DropdownSettings.CurrentOption == 0 then
                                    Dropdown.Main.Title.Text = DropdownSettings.Name .. " - "
                                else
                                    Dropdown.Main.Title.Text = DropdownSettings.Name .. " - multiple.."
                                end
                            else
                                Dropdown.Main.Title.Text = DropdownSettings.Name .. " - " .. DropdownSettings.CurrentOption[1]
                            end
                        else
                            if not DropdownSettings.MultipleOptions then
                                table.clear(DropdownSettings.CurrentOption)
                            end
                            table.insert(DropdownSettings.CurrentOption, Option)
                            if DropdownSettings.MultipleOptions then
                                if #DropdownSettings.CurrentOption == 1 then
                                    Dropdown.Main.Title.Text = DropdownSettings.Name .. " - " .. DropdownSettings.CurrentOption[1]
                                elseif #DropdownSettings.CurrentOption == 0 then
                                    Dropdown.Main.Title.Text = DropdownSettings.Name .. " - "
                                else
                                    Dropdown.Main.Title.Text = DropdownSettings.Name .. " - multiple.."
                                end
                            else
                                Dropdown.Main.Title.Text = DropdownSettings.Name .. " - " .. DropdownSettings.CurrentOption[1]
                            end
                        end
                        
    
                        DropdownSettings.Callback(DropdownSettings.CurrentOption)
                        SaveConfiguration()	
                    end)
                end
                
                for _, droption in ipairs(Dropdown.List.Holder:GetChildren()) do
                    if droption.ClassName == "Frame" and droption.Name ~= "Option" then
                        if not table.find(DropdownSettings.CurrentOption, droption.Name) then
                            droption.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                        else
                            droption.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                        end
                    end
                end

                function DropdownSettings:Set(NewOption)
                    if typeof(DropdownSettings.CurrentOption) == "string" then
                        DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption}
                    end
                    
                    if not DropdownSettings.MultipleOptions then
                        DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption[1]}
                    end
                    
                    if DropdownSettings.MultipleOptions then
                        if #DropdownSettings.CurrentOption == 1 then
                            Dropdown.Main.Title.Text = DropdownSettings.Name .. " - " .. DropdownSettings.CurrentOption[1]
                        elseif #DropdownSettings.CurrentOption == 0 then
                            Dropdown.Main.Title.Text = DropdownSettings.Name .. " - "
                        else
                            Dropdown.Main.Title.Text = DropdownSettings.Name .. " - multiple.."
                        end
                    else
                        Dropdown.Main.Title.Text = DropdownSettings.Name .. " - " .. DropdownSettings.CurrentOption[1]
                    end

                    DropdownSettings.Callback(NewOption)
                    for _, droption in ipairs(Dropdown.List.Holder:GetChildren()) do
                        if droption.ClassName == "Frame" and droption.Name ~= "Option" then
                            if not table.find(DropdownSettings.CurrentOption, droption.Name) then
                                droption.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                            else
                                droption.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                            end
                        end
                    end
                end

                if Settings.ConfigurationSaving then
                    if Settings.ConfigurationSaving.Enabled and DropdownSettings.Flag then
                        ZenLibrary.Flags[DropdownSettings.Flag] = DropdownSettings
                    end
                end    
                
                return DropdownSettings
            end

            function elementHandler:CreateLockedButton(ButtonSettings)
                local hovering = false
                local errored = false

                local Button = ExampleSection.Holder.ButtonLocked:Clone()

                Button.Name = ButtonSettings.Name .. " (Locked)"
                Button.TextLabel.Text = ButtonSettings.Name
                Button.BackgroundTransparency = 1
                Button.UIStroke.Transparency = 1
                Button.Status.ActualThing.ImageLabel.ImageTransparency = 1
                Button.TextLabel.TextTransparency = 1
                Button.Visible = true
                Button.Parent = Section.Holder

                if libraryLoaded then showElement(Button) end

                Button.MouseButton1Click:Connect(function()
                    promptPremium()
                end)

                Button.MouseEnter:Connect(function()
                    if errored then return end
                    hovering = true
                    TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
                    --TweenService:Create(Button.Status.ActualThing.ImageLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageColor3 = Color3.fromRGB(110, 0, 0)}):Play()
                end)
    
                Button.MouseLeave:Connect(function()
                    if errored then return end
                    hovering = false
                    TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
                    --TweenService:Create(Button.Status.ActualThing.ImageLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageColor3 = Color3.fromRGB(90, 90, 90)}):Play()
                end)
    
                return ButtonSettings
            end

            return elementHandler
        end

        return sectionHandler
    end

    AddDraggingFunctionality(Topbar,Main)

    Topbar.Close.MouseEnter:Connect(function()
        TweenService:Create(Topbar.Close.ImageLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageColor3 = Color3.fromRGB(220,220,220)}):Play()
    end)

    Topbar.Close.MouseLeave:Connect(function()
        TweenService:Create(Topbar.Close.ImageLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageColor3 = Color3.fromRGB(134, 134, 134)}):Play()
    end)

    Topbar.Close.MouseButton1Click:Connect(function()
        hideMenu()
        Zen:Destroy()
    end)

    Topbar.Minimize.MouseEnter:Connect(function()
        TweenService:Create(Topbar.Minimize.ImageLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageColor3 = Color3.fromRGB(220,220,220)}):Play()
    end)

    Topbar.Minimize.MouseLeave:Connect(function()
        TweenService:Create(Topbar.Minimize.ImageLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageColor3 = Color3.fromRGB(134, 134, 134)}):Play()
    end)

    Topbar.Minimize.MouseButton1Click:Connect(function()
        if Debounce then return end
        if Hidden then
            Hidden = false
            Minimised = false
            unHideMenu()
        else
            Hidden = true
            hideMenu()
        end
    end)

    Topbar.Title.MouseEnter:Connect(function()
        TweenService:Create(Topbar.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextColor3 = Color3.fromRGB(220,220,220)}):Play()
    end)

    Topbar.Title.MouseLeave:Connect(function()
        TweenService:Create(Topbar.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextColor3 = Color3.fromRGB(161, 161, 161)}):Play()
    end)

    Toolbar.Menu.MouseEnter:Connect(function()
        TweenService:Create(Toolbar.Menu.ImageButton, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageColor3 = Color3.fromRGB(220,220,220)}):Play()
    end)

    Toolbar.Menu.MouseLeave:Connect(function()
        TweenService:Create(Toolbar.Menu.ImageButton, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageColor3 = Color3.fromRGB(134, 134, 134)}):Play()
    end)

    Toolbar.Settings.MouseEnter:Connect(function()
        TweenService:Create(Toolbar.Settings.ImageButton, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageColor3 = Color3.fromRGB(220,220,220)}):Play()
    end)

    Toolbar.Settings.MouseLeave:Connect(function()
        TweenService:Create(Toolbar.Settings.ImageButton, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageColor3 = Color3.fromRGB(134, 134, 134)}):Play()
    end)

    Toolbar.TabDisplay.MouseEnter:Connect(function()
        TweenService:Create(Toolbar.TabDisplay.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextColor3 = Color3.fromRGB(220,220,220)}):Play()
    end)

    Toolbar.TabDisplay.MouseLeave:Connect(function()
        TweenService:Create(Toolbar.TabDisplay.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextColor3 = Color3.fromRGB(161, 161, 161)}):Play()
    end)

    return tabHandler
end

Toolbar.Menu.ImageButton.MouseButton1Click:Connect(function()
    if Debounce then return end
    if TabHolder.Visible then
        closeTabHolder()
    else
        openTabHolder()
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if (input.KeyCode == Enum.KeyCode.RightShift and not processed) then
		if Debounce then return end
		if Hidden then
			Hidden = false
			unHideMenu()
		else
			Hidden = true
			hideMenu()
		end
	end
end)

function ZenLibrary:LoadConfiguration()
	if CEnabled then
		pcall(function()
			if isfile(ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension) then
                print('loading ' .. ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension) 
				LoadConfiguration(readfile(ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension))
			end
		end)
	end
end

task.spawn(function()
    task.wait(1.5)
    ZenLibrary.LoadConfiguration() 
end)

applyTheme(Main)

return ZenLibrary
