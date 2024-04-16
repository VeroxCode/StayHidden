local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local RadiusUpdate = game.ServerStorage.Events.Hunter.RadiusUpdate

local RunService = game
local Object = script.Parent

local PlayersInOrb = {}

game["Run Service"].Heartbeat:Connect(function(delta)
	
	if (Object.Parent.Name ~= "Workspace") then
		return
	end
	
	if (not Object:GetAttribute("Deployed")) then
		return
	end
	
	local Lifetime = Object:GetAttribute("Lifetime")
	Lifetime -= delta
	
	if (#PlayersInOrb > 0) then
		RadiusUpdate:Fire("Tick", PlayersInOrb)
		for i, v in pairs(PlayersInOrb) do
			local MatchPlayers = game.ReplicatedStorage.Match.Players
			local MatchPlayer = MatchPlayers:FindFirstChild(v.Name)
			local Role = Modules.Game:getRole(MatchPlayer)
			
			if (Role == "Prey") then
				if (Object:GetAttribute("applyParalyzed")) then
					Modules.Game:applyTimedEffect(MatchPlayer, "Paralyzed", Object:GetAttribute("ParalyzedDuration"))
				end
			end
			
			if (Role == "Hunter") then
				Modules.Game:applyTimedEffect(MatchPlayer, "Swiftness", Object:GetAttribute("SwiftnessDuration"))
				Modules.Game:setEffect(MatchPlayer, "Swiftness", "Value", (Object:GetAttribute("SwiftnessValue") / 100))
			end
		end
	end
	
	if (Lifetime <= 0) then
		for i, v in pairs(PlayersInOrb) do
			Modules.AuraManager:removeAura(game.Players:GetPlayerByUserId(Modules.Game:getHunterID()), "Player", v.Name, "Orb")
		end
		RadiusUpdate:Fire("Destroy", PlayersInOrb)
		Object:Destroy()
	end
	
	Object:SetAttribute("Lifetime", Lifetime)
	
end)

Object.Touched:Connect(function(Part)
	
	local PlayerToFind = game.Players:FindFirstChild(Part.Parent.Name)
	
	if (PlayerToFind ~= nil) then
		
		local MatchPlayer = Modules.Game:getMatchPlayer(PlayerToFind.UserId)
		local Role = Modules.Game:getRole(MatchPlayer)
		
		if (table.find(PlayersInOrb, PlayerToFind) == nil and Role == "Prey") then
			table.insert(PlayersInOrb, PlayerToFind)
			RadiusUpdate:Fire("Enter", PlayerToFind)
		end
	end
end)

Object.TouchEnded:Connect(function(Part)
	
	local PlayerToFind = game.Players:FindFirstChild(Part.Parent.Name)
	
	if (PlayerToFind ~= nil) then
		if (table.find(PlayersInOrb, PlayerToFind) ~= nil) then
			table.remove(PlayersInOrb, table.find(PlayersInOrb, PlayerToFind))
			RadiusUpdate:Fire("Leave", PlayerToFind)
		end
	end
end)