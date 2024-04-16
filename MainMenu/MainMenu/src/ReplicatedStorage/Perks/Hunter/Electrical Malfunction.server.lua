local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Events = Modules.Events

local PerkPlayer = script.Parent

local Data = {
}

function onMatchStart()
	
	local Interactables = workspace.Map.Interactables
	local BoxList = Interactables.Fuseboxes:GetChildren()
	local FuseBoxes = Interactables.Fuseboxes
	
	local Boxes = script.Config:GetAttribute("Amount")
	local toBlock = {}
	
	for i = 1, Boxes, 1 do
		local pick = math.random(1, #BoxList)
		table.insert(toBlock, BoxList[pick]) 
		table.remove(BoxList, pick)
	end
	
	for i, v in pairs(toBlock) do
		Modules.Fusebox:setLoads(FuseBoxes[v.Name], Modules.Fusebox:getOverload(FuseBoxes[v.Name]))
	end
	
end

function getSlot()
	return `Slot{tostring(script.Config:GetAttribute("Slot"))}` 
end

Events.Game.MatchStart.Event:Connect(onMatchStart)