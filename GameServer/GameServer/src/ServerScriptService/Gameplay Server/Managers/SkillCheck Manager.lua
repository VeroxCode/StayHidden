local HttpService = game:GetService("HttpService")
local Remotes = game.ReplicatedStorage.Remotes
local Players = {}

local Cooldown = 4.5

local this = {}

function this:spawnSkillCheck(Player, Speed, Size)
	
	local randomID = HttpService:GenerateGUID(false)
	
	if (Players[Player.Name] ~= nil) then
		if (tick() - Players[Player.Name] < Cooldown) then
			return
		end
		
		Players[Player.Name] = tick()
		Remotes.SkillCheckEvent:FireClient(Player, Speed, Size, randomID)
	else
		Players[Player.Name] = tick()
		Remotes.SkillCheckEvent:FireClient(Player, Speed, Size, randomID)
	end
	return randomID
end

function this:spawnSkillCheckForce(Player, Speed, Size)

	local randomID = HttpService:GenerateGUID(false)

	Players[Player.Name] = tick()
	Remotes.SkillCheckEvent:FireClient(Player, Speed, Size, randomID)
	
	return randomID
end

return this
