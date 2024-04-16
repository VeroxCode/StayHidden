local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Events = game.ServerStorage.Events
local Power = script.Parent.Parent.Parent
local PowerObject = Power.Orb
local Config = script.Parent

local PlayerList = {}
local this = {}

function this:apply()
	PowerObject:SetAttribute("applyParalyzed", false)
end

function onRadiusUpdate(Event, Players)
	
	local Drain = Config:GetAttribute("ExtraDrain")
	
	if (Event == "Deployed") then
		for i, v in pairs(game.Players:GetPlayers()) do
			local MatchPlayer = Modules.Game:getMatchPlayer(v.UserId)
			local BatteryDrain = Modules.Game:getBatteryDrain(MatchPlayer)
			
			local indexName = tostring(v.UserId)
			PlayerList[indexName] = {}
			PlayerList[indexName] = BatteryDrain
		end
	end
	
	if (Event == "Destroy") then
		for key, value in pairs(Players) do
			
			local indexName = tostring(value.UserId)
			
			if (PlayerList[indexName] ~= nil) then
				local MatchPlayer = Modules.Game:getMatchPlayer(value.UserId)
				local BatteryDrain = PlayerList[indexName]

				Modules.Game:setBatteryDrain(MatchPlayer, BatteryDrain)
				PlayerList[indexName] = nil
			end
		end
		PlayerList = {}
	end
	
	if (Event == "Tick") then
		for key, value in pairs(PlayerList) do
			local MatchPlayer = Modules.Game:getMatchPlayer(tonumber(key))
			local BatteryDrain = PlayerList[key]
			
			Modules.Game:setBatteryDrain(MatchPlayer, BatteryDrain + (BatteryDrain / 100 * Drain))
		end
	end
	
	if (Event == "Enter") then
		local indexName = tostring(Players.UserId)
		local MatchPlayer = Modules.Game:getMatchPlayer(Players.UserId)
		local BatteryDrain = Modules.Game:getBatteryDrain(MatchPlayer)
		
		PlayerList[indexName] = {}
		PlayerList[indexName] = BatteryDrain
	end
	
	if (Event == "Leave") then
		local indexName = tostring(Players.UserId)
		local MatchPlayer = Modules.Game:getMatchPlayer(Players.UserId)
		local BatteryDrain = PlayerList[tostring(Players.UserId)]
		
		Modules.Game:setBatteryDrain(MatchPlayer, BatteryDrain)
		PlayerList[indexName] = nil
	end
end

function onSlide(Player, Gap)
	
	local indexName = tostring(Player.UserId)
	
	print(PlayerList)
	
	if (PlayerList[indexName] == nil) then
		return
	end
	
	local Fuseboxes = workspace:WaitForChild("Map").Interactables["Fuseboxes"]
	local Fusebox = Fuseboxes[Modules.Gap:getFusebox(Gap)]
	
	local timer = 10
	local runner = nil
	
	runner = Events.Game.ServerTick.Event:Connect(function(delta)
		timer -= delta
		
		if (timer > 0) then
			Modules.Fusebox:setLoads(Fusebox, Modules.Fusebox:getOverload(Fusebox))
			Modules.Fusebox:setActivated(Fusebox, false)
		else
			Modules.Fusebox:setLoads(Fusebox, 0)
			Modules.Fusebox:setActivated(Fusebox, true)
			runner:Disconnect()
		end
		
	end)
	
	
end

Events.Hunter.RadiusUpdate.Event:Connect(onRadiusUpdate)
Events.Prey.onSlide.Event:Connect(onSlide)

return this
