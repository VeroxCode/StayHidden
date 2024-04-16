local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Events = game.ServerStorage.Events

local PerkPlayer = script.Parent

local Data = {
	DrainApplied = false
}

function onMatchStart()
	
	if (Data.DrainApplied) then
		return
	end
	
	Data.DrainApplied = true
	
	local ID = PerkPlayer:GetAttribute("ID")
	local MatchPlayer = Modules.Game:getMatchPlayer(ID)
	local BatteryDrain = Modules.Game:getBatteryDrain(MatchPlayer)
	local Increase = script.Config:GetAttribute("Reduce")
	
	BatteryDrain += (BatteryDrain / 100) * Increase
	
	Modules.Game:setBatteryDrain(MatchPlayer, BatteryDrain)
	
end

function onDoorClose(Player, Door)
	
	if (Player.Name ~= PerkPlayer.Name) then
		return
	end
	
	local Bonus = script.Config:GetAttribute("Bonus")
	
	Modules.BigDoor:setTimer(Door, (Modules.BigDoor:getTimer(Door) - Bonus))
	
end

function getSlot()
	return `Slot{tostring(script.Config:GetAttribute("Slot"))}` 
end

Events.Game.MatchStart.Event:Connect(onMatchStart)
Events.Prey.onDoorClose.Event:Connect(onDoorClose)