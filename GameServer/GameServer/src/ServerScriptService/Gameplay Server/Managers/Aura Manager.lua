local SpawnAlert = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AlertEvent")
local SpawnAura = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AuraEvent")

local this = {}

function this:createAlert(Player, Type, Identifier)
	
	if (Player == nil) then
		return
	end
	
	SpawnAlert:FireClient(Player, Type, Identifier)
end

function this:createAura(Player, Type, Identifier, Restricted, TimeLimit, Color, BorderColor, Name)
	
	if (Player == nil) then
		return
	end
	
	SpawnAura:FireClient(Player, "Create", Type, Identifier, Restricted, TimeLimit, Color, BorderColor, Name, false)
end

function this:createOutline(Player, Type, Identifier, Restricted, TimeLimit, BorderColor, Name)
	
	if (Player == nil) then
		return
	end
	
	SpawnAura:FireClient(Player, "Create", Type, Identifier, Restricted, TimeLimit, Color3.new(0,0,0), BorderColor, Name, true)
end

function this:removeAura(Player, Type, Identifier, Name)
	
	if (Player == nil) then
		return
	end
	
	SpawnAura:FireClient(Player, "Remove", Type, Identifier, false, 0, Color3.new(0,0,0), Color3.new(0,0,0), Name)
end

return this
