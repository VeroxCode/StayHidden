local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Events = game.ServerStorage.Events

local PerkPlayer = script.Parent

local Data = {
}

function getSlot()
	return `Slot{tostring(script.Config:GetAttribute("Slot"))}` 
end