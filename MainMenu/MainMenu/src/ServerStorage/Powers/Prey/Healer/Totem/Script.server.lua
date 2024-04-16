local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LoaderPlayer = script.Parent.Parent.Parent
local Remotes = game.ReplicatedStorage.Remotes
local Events = game.ServerStorage.Events
local Power = script.Parent.Parent

local PlayersInRadius = {}

function onUpdate(delta)
	
	for i, Player in pairs(Players:GetPlayers()) do
		local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
		local Role = Modules.Game:getRole(MatchPlayer)
		
		if (Role == "Hunter") then
			continue
		end
		
		local Totem = script.Parent
		local TotemPos = Totem.CFrame.Position
		local TotemXZ = Vector3.new(TotemPos.X, 0, TotemPos.Z)
		
		local PlayerPos = Player.Character.PrimaryPart.CFrame
		local PlayerXZ = Vector3.new(PlayerPos.X, 0, PlayerPos.Z)
		
		local DistanceXZ = (TotemXZ - PlayerXZ).Magnitude
		local DistanceY = math.abs(TotemPos.Y - PlayerPos.Y)
		
		local Radius = Totem:GetAttribute("Radius")
		local HealAmount = Totem:GetAttribute("HealAmount")
		local Lifetime = Totem:GetAttribute("Lifetime")
		
		if (DistanceXZ <= Radius) then
			
			if (not isInRadius(Player)) then
				EnteredRadius(Player)
			end
			
			Modules.Game:healPlayer(Player, HealAmount * delta)
			Events.Prey.onTotemHeal:Fire(Player)
		else
			if (isInRadius(Player)) then
				LeftRadius(Player)
			end
		end
		
		Lifetime -= delta
		Totem:SetAttribute("Lifetime", Lifetime)
		
		if (Lifetime <= 0) then
			Events.Prey.onTotemEvent:Fire(nil, "Destroy")
			Totem:Destroy()
		end
	end
end

function isInRadius(Player)
	
	if (PlayersInRadius[Player.Name] ~= nil) then
		return PlayersInRadius[Player.Name][1]
	end
	
	return false
end

function EnteredRadius(Player)
	
	if (PlayersInRadius[Player.Name] ~= nil) then
		PlayersInRadius[Player.Name][1] = true
		PlayersInRadius[Player.Name][2] += 1
	else
		PlayersInRadius[Player.Name] = {
		[1] = true,
		[2] = 1
	}
	end
	
	Events.Prey.onTotemEvent:Fire(Player, "Enter", PlayersInRadius[Player.Name][2])
end

function LeftRadius(Player)
	
	if (PlayersInRadius[Player.Name] ~= nil) then
		PlayersInRadius[Player.Name][1] = false
	else
		PlayersInRadius[Player.Name] = {
			[1] = false,
			[2] = 1
		}
	end
	
	Events.Prey.onTotemEvent:Fire(Player, "Leave", PlayersInRadius[Player.Name][2])
end

RunService.Heartbeat:Connect(onUpdate)