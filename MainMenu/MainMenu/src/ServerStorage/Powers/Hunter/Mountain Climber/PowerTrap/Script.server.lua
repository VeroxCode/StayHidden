local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Events = game.ServerStorage.Events
local Players = game:GetService("Players")
local Object = script.Parent
local Debounce = os.time()

local Lifetime = 3.0
local Triggered = false

function onServerTick(delta)
	
	if (Object.Parent.Name ~= "Traps") then
		return
	end
	
	local SlowdownLength = Object:GetAttribute("SlowdownLength")
	local SlowdownValue = Object:GetAttribute("SlowdownValue")
	local Radius = Object:GetAttribute("Radius")
	
	local MatchPlayers = Modules.Game:getMatchPlayers()
	local PlayersNear = getPlayersNear(MatchPlayers, Radius)
	
	local Hunter = Modules.Game:getHunter()
	local HunterID = Modules.Game:getHunterID()

	local MaxTraps = Modules.Game:getPowerAttribute(HunterID, "MaxTraps")
	local Traps = Modules.Game:getPowerAttribute(HunterID, "Traps")
	
	if (#PlayersNear > 0) then
		
		Triggered = true
		
		for i, MatchPlayer in pairs(PlayersNear) do
			
			local Role = Modules.Game:getRole(MatchPlayer)
			
			if (Role == "Prey") then
				Modules.Game:setEffect(MatchPlayer, "Slowdown", "Value", (SlowdownValue / 100))
				Modules.Game:applyTimedEffect(MatchPlayer, "Slowdown", SlowdownLength)
				Modules.Credits:increaseCredits(HunterID, (Modules.Game_Values.ScoreEvents.Specific.TrapTripped * delta))
				
				local TrippedPlayer = game.Players:FindFirstChild(MatchPlayer.Name)
				Events.Hunter.onTrip:Fire(TrippedPlayer, "Prey", Object, delta)
			end
		end
	end
	
	if (Triggered) then
		
		Object.Particles.CFrame = Object.CFrame
		Object.Rotation = Vector3.new(0, 0, 0)
		Object.Particles.Rotation = Vector3.new(0, 0, 90)
		Object.Particles.Size = Vector3.new(1, Radius * 2, Radius * 2)
		Object.Particles.Emitter1.Enabled = true
		Object.Particles.Emitter2.Enabled = true
		
		Lifetime -= delta
		if (Lifetime <= 0) then
			
			Modules.Game:setPowerAttribute(HunterID, "Traps", math.clamp(Traps + 1, 0, MaxTraps))
			Modules.Game:setAbilityValue(Hunter, "Amount", math.clamp(Traps + 1, 0, MaxTraps))
			
			Object:Destroy()
		end
	end
end

function getPlayersNear(MatchPlayers, Radius)
	
	local PlayersNear = {}
	
	for i, MatchPlayer in pairs(MatchPlayers) do
		local Character = game.Players:WaitForChild(MatchPlayer.Name).Character
		local isVulnerable = Modules.Game:isVulnerable(MatchPlayer)
		local Role = Modules.Game:getRole(MatchPlayer)
		
		local DistanceXZ = Modules.PlayerUtils:getVectorDistanceXZ(Character.HumanoidRootPart.CFrame.Position, Object.CFrame.Position)
		local DistanceY = Modules.PlayerUtils:getVectorDistanceY(Character.HumanoidRootPart.CFrame.Position, Object.CFrame.Position)
		
		if (DistanceXZ <= Radius and DistanceY <= Radius / 3 and Role == "Prey" and Modules.Actions:getAction(MatchPlayer:GetAttribute("ID")) ~= Modules.Actions.List.RESPAWNING) then
			table.insert(PlayersNear, MatchPlayer)
		end
	end
	
	return PlayersNear
	
end

Events.Game.ServerTick.Event:Connect(onServerTick)
	
