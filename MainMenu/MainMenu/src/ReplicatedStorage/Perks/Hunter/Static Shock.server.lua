local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Events = game.ServerStorage.Events

local PerkPlayer = script.Parent

local Data = {
	Damage = 0;
	Timer = 0;
}

function onMatchStart()
	
	local Hunter = Modules.Game:getHunter()
	Data.Damage = Modules.Game:getDamage(Hunter)
	
end

function onServerTick(delta)
	
	if (Data.Timer >= 0) then
		local Hunter = Modules.Game:getHunter()
		Data.Timer -= delta
		
		if (Data.Timer > 0) then
			Modules.Game:setPerkLocally(Hunter, getSlot(), "Duration", Data.Timer)
			Modules.Game:setPerkLocally(Hunter, getSlot(), "MaxDuration", script.Config:GetAttribute("Duration"))
			Modules.Game:setDamage(Hunter, Data.Damage + (script.Config:GetAttribute("Bonus")))
		else
			Modules.Game:setDamage(Hunter, Data.Damage)
			Modules.Game:setPerkLocally(Hunter, getSlot(), "Duration", 0)
		end
	end
	
end

function onFuseboxDestroy(Player, Object)
	
	local Hunter = Modules.Game:getHunter()
	Data.Damage = Modules.Game:getDamage(Hunter)
	Data.Timer = script.Config:GetAttribute("Duration")
	
end

function getSlot()
	return `Slot{tostring(script.Config:GetAttribute("Slot"))}` 
end

Events.Game.MatchStart.Event:Connect(onMatchStart)
Events.Game.ServerTick.Event:Connect(onServerTick)
Events.Hunter.onFuseboxDestroy.Event:Connect(onFuseboxDestroy)