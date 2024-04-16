local Players = game:GetService("Players")

local this = {}

function this:isRunning()
	local Match = game.ReplicatedStorage:WaitForChild("Match")
	local Running = Match:GetAttribute("Running")
	return Running
end

function this:getHunter()
	for i, Player in pairs(game.ReplicatedStorage.Match.Players:GetChildren()) do
		if (Player:GetAttribute("Role") == "Hunter") then
			return Player
		end
	end
end

function this:getMatchPlayers()
	return game.ReplicatedStorage.Match.Players:GetChildren()
end

function this:getMatchStats()
	local MatchStats = game.ReplicatedStorage:WaitForChild("Match"):WaitForChild("MatchStats")
	return MatchStats
end

function this:getHunterID(PlayerID)
	local Hunter = this:getHunter(PlayerID)
	return Hunter:GetAttribute("ID")
end

function this:isHunter(PlayerID)
	
	local MatchPlayer = this:getMatchPlayer(PlayerID)
	
	if (this:getRole(MatchPlayer) == "Hunter") then
		return true
	end
	
	return false
end

function this:getMatchPlayer(PlayerID)
	for i, Player in pairs(game.ReplicatedStorage.Match.Players:GetChildren()) do
		if (Player:GetAttribute("ID") == PlayerID) then
			return Player
		end
	end
end

function this:getWorkspacePlayer(PlayerID)
	local Player = Players:GetPlayerByUserId(PlayerID)
	return workspace:WaitForChild(Player.Name)
end

function this:getExtractionProgress()
	local MatchStats = game.ReplicatedStorage:WaitForChild("Match"):WaitForChild("MatchStats")
	local Amount = MatchStats:GetAttribute("Extracted")
	return Amount
end

function this:getMaxExtractions()
	local MatchStats = game.ReplicatedStorage:WaitForChild("Match"):WaitForChild("MatchStats")
	local Amount = MatchStats:GetAttribute("Extractions")
	return Amount
end

function this:getMatchTimer()
	local MatchStats = game.ReplicatedStorage:WaitForChild("Match"):WaitForChild("MatchStats")
	local Amount = MatchStats:GetAttribute("Timer")
	return Amount
end

function this:canEscape()
	local MatchStats = game.ReplicatedStorage:WaitForChild("Match"):WaitForChild("MatchStats")
	local Amount = MatchStats:GetAttribute("CanEscape")
	return Amount
end

function this:getChaseTheme()
	local MatchStats = game.ReplicatedStorage:WaitForChild("Match"):WaitForChild("MatchStats")
	local Value = MatchStats:GetAttribute("Theme")
	return Value
end

function this:isEscaped(MatchPlayer)
	local Amount = MatchPlayer:GetAttribute("Escaped")
	return Amount
end

function this:getAnimationAction(MatchPlayer)
	return MatchPlayer:GetAttribute("AnimationAction")
end

function this:getAttackKey(MatchPlayer)
	return MatchPlayer:GetAttribute("AttackKey")
end

function this:getEffects(MatchPlayer)
	return MatchPlayer.Effects
end

function this:getEffect(MatchPlayer, Effect : string, Attribute)
	return MatchPlayer.Effects[Effect]:GetAttribute(Attribute)
end

function this:getRole(MatchPlayer)
	local Role = MatchPlayer:GetAttribute("Role")
	return Role
end

function this:getUserId(MatchPlayer)
	local ID = MatchPlayer:GetAttribute("ID")
	return ID
end

function this:isVulnerable(MatchPlayer)
	local isVulnerable = MatchPlayer:GetAttribute("isVulnerable")
	return isVulnerable
end

function this:getLastAttack(MatchPlayer)
	local LastAttack = MatchPlayer:GetAttribute("lastAttack")
	return LastAttack
end

function this:getExtractorId(MatchPlayer)
	local ExtractorId = MatchPlayer:GetAttribute("Extractor")
	return ExtractorId
end

function this:getHealth(MatchPlayer)
	local Health = MatchPlayer.Values:GetAttribute("Health")
	return Health
end

function this:getParts(MatchPlayer)
	local Parts = MatchPlayer:GetAttribute("Parts")
	return Parts
end

function this:HasSerum(MatchPlayer)
	local hasSerum = MatchPlayer:GetAttribute("hasSerum")
	return hasSerum
end

function this:getMaxHealth(MatchPlayer)
	local Health = MatchPlayer.Values:GetAttribute("MaxHealth")
	return Health
end

function this:getActionSpeed(MatchPlayer)
	local FuseSpeed = MatchPlayer.Values:GetAttribute("ActionSpeed")
	return FuseSpeed
end

function this:getInteractionSpeed(MatchPlayer)
	local FuseSpeed = MatchPlayer.Values:GetAttribute("InteractionSpeed")
	return FuseSpeed
end

function this:getBattery(MatchPlayer)
	local Battery = MatchPlayer.Values:GetAttribute("Battery")
	return Battery
end

function this:getMaxBattery(MatchPlayer)
	local Battery = MatchPlayer.Values:GetAttribute("MaxBattery")
	return Battery
end

function this:getBatteryDrain(MatchPlayer)
	local Battery = MatchPlayer.Values:GetAttribute("BatteryDrain")
	return Battery
end

function this:getDamage(MatchPlayer)
	local Damage = MatchPlayer.Values:GetAttribute("Damage")
	return Damage
end

function this:inChase(MatchPlayer)
	local inChase = MatchPlayer:GetAttribute("inChase")
	return inChase
end

function this:getChaseTimer(MatchPlayer)
	
	if (MatchPlayer == nil) then
		return -1
	end
	
	local Value = MatchPlayer:GetAttribute("ChaseTimer")
	return Value
end

function this:getHunterDistance(MatchPlayer)
	
	if (MatchPlayer == nil) then
		return 1000
	end
	
	local Value = MatchPlayer:GetAttribute("HunterDistance")
	return Value
end

function this:getRotationDistance(Rotation : Vector3, RootPart1 : Vector3, RootPart2 : Vector3)
	local Direction = CFrame.new(RootPart1, RootPart2).LookVector
	return (Direction - Rotation).Magnitude
end

function this:getPowerLocally(MatchPlayer, Attribute)
	local Ability = MatchPlayer.Ability
	return Ability:GetAttribute(Attribute)
end

function this:HasItem(MatchPlayer)
	local hasItem = (MatchPlayer:GetAttribute("Item") ~= "")
	return hasItem
end

function this:getItem(MatchPlayer)
	local Item = MatchPlayer:GetAttribute("Item")
	return Item
end

function this:getProximityRadius()
	local Hunter =  this:getHunter()
	local Value = Hunter.Values:GetAttribute("ProximityRadius")
	return Value
end

return this
