local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Events = game.ServerStorage.Events

local PerkPlayer = script.Parent

local Data = {
	Config = script.Config;
	Timeout = 0;
}

function onServerTick(delta)
	
	local ID = PerkPlayer:GetAttribute("ID")
	local MatchPlayer = Modules.Game:getMatchPlayer(ID)
	
	local inChase = Modules.Game:inChase(MatchPlayer)
	local ChaseTimer = Modules.Game:getChaseTimer(MatchPlayer)
	local Extractions = Modules.Game:getExtractionProgress()
	
	if (inChase or ChaseTimer > 0) then
		Data.Timeout = Data.Config:GetAttribute("ChaseCooldown")
		Modules.Game:setPerkLocally(MatchPlayer, getSlot(), "Cooldown", Data.Timeout)
		Modules.Game:setPerkLocally(MatchPlayer, getSlot(), "MaxCooldown", Data.Config:GetAttribute("ChaseCooldown"))
	else
		if (Data.Timeout >= 0) then
			Data.Timeout -= delta
			Modules.Game:setPerkLocally(MatchPlayer, getSlot(), "Cooldown", Data.Timeout)
			Modules.Game:setPerkLocally(MatchPlayer, getSlot(), "MaxCooldown", Data.Config:GetAttribute("ChaseCooldown"))
		end
	end
	
	if (not inChase and Extractions < Data.Config:GetAttribute("SerumLimit") and Data.Timeout <= 0) then
		Modules.Speed:addMultiplier(MatchPlayer, script.Name, (Data.Config:GetAttribute("Boost") / 100), 0)
	else
		Modules.Speed:removeMultiplier(MatchPlayer, script.Name)
	end
	
	if (Extractions >=  Data.Config:GetAttribute("SerumLimit")) then
		Modules.Game:setPerkLocally(MatchPlayer, getSlot(), "Cooldown", 1)
		Modules.Game:setPerkLocally(MatchPlayer, getSlot(), "MaxCooldown", 1)
	end
	
end

function getSlot()
	return `Slot{tostring(script.Config:GetAttribute("Slot"))}` 
end

Events.Game.ServerTick.Event:Connect(onServerTick)