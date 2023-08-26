-- Mod Detector Module

local Players = game:GetService("Players") 
local LocalPlayer = Players.LocalPlayer

local ModDetector = {}
ModDetector.__index = ModDetector

-- Keywords
local keywords = {
    "dev","mod","admin","moderator","developer","staff","manager","lead","assistant","operator",
    "supervisor","owner","leader","head","chief","senior","junior","executive","administrator",
    "community","server","site","game","event","team","support","founder","director","officer","organizer"
}

-- Default groups to listen to
local groups = {
    -- None
}

-- Checks if a role name contains keywords
-- @param role The role name to check
-- @returns true if keywords found, false otherwise
local function check_role(role)
    role = role:lower()

    for _, keyword in ipairs(keywords) do
        if role:find(keyword) then
            return true
        end
    end

    return false
end

-- Checks all players for roles that contain keywords
-- @returns boolean, role, group if mod found, otherwise false
local function check_for_mods()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then 

            for _,groupID in ipairs(groups) do
                local role = player:GetRoleInGroup(groupID)
                if check_role(role) then
                    return true, role, group
                end
            end

        end
    end

    return false
end

-- Create a new ModDetector instance
function ModDetector.new(groupIDs)
    local self = setmetatable({}, ModDetector)
    self.onDetectedCallback = nil -- Callback function

    if (groupIDs ~= nil and type(groupIDs) == "table") then
        for _,v in pairs(groupIDs) do
            table.insert(groups, v)
            warn('Registered group ID: ' .. tostring(v) .. " in the groups table.")
        end
    end
    
    task.spawn(function()
        while task.wait() do
            local foundMod, role, group = check_for_mods()
            if foundMod and self.onDetectedCallback then
                warn("Mod detected!")
                self.onDetectedCallback(role, group) -- Call the callback
                task.wait(5)
            end
        end
    end)

    warn('Mod Detector has started.')
    return self
end

-- Set the callback function
function ModDetector:SetOnDetectedCallback(callback)
    self.onDetectedCallback = callback
end

warn('Mod Detector module has loaded.')
return ModDetector
