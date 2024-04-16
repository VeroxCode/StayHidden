local BindStorage = require(game.ServerScriptService["Handlers"]:WaitForChild("Bind Storage"))
local Remotes = game.ReplicatedStorage.Remotes
local Items = game.ServerStorage.Cloning.Items
local Events = game.ServerStorage.Events

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local SpecialKeys = {
	--["Actions"] = {"ButtonA", "M1"},
	["Ability"] = {"L2", "M2"},
}

local this = {}

function this:isRunning()
	local Match = game.ReplicatedStorage:WaitForChild("Match")
	local Running = Match:GetAttribute("Running")
	return Running
end

function this:setRunning(Value)
	local Match = game.ReplicatedStorage:WaitForChild("Match")
	Match:SetAttribute("Running", Value)
end

function this:getHunter()
	for i, Player in pairs(game.ReplicatedStorage.Match.Players:GetChildren()) do
		if (Player:GetAttribute("Role") == "Hunter") then
			return Player
		end
	end
	return nil
end

function this:getServerHunter()
	
	if (RunService:IsClient()) then 
		return nil
	end
	
	for i, Player in pairs(game.ServerScriptService.Match.Players:GetChildren()) do
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

function this:setMatchCountdown(Value)
	local Match = game.ReplicatedStorage:WaitForChild("Match")
	Match:SetAttribute("Countdown", Value)
end

function this:getMatchCountdown()
	local Match = game.ReplicatedStorage:WaitForChild("Match")
	local Countdown = Match:GetAttribute("Countdown")
	return Countdown
end

function this:getHunterID()
	
	local ID = 0
	local Hunter = this:getHunter()
	
	if (Hunter ~= nil) then
		ID = Hunter:GetAttribute("ID")
	end
	
	return ID
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

function this:getServerPlayer(PlayerID)
	
	if (RunService:IsClient()) then 
		return nil
	end
	
	for i, Player in pairs(game.ServerScriptService.Match.Players:GetChildren()) do
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

function this:setChaseTheme(Value)
	local MatchStats = game.ReplicatedStorage:WaitForChild("Match"):WaitForChild("MatchStats")
	MatchStats:SetAttribute("Theme", Value)
end

function this:isEscaped(MatchPlayer)
	local Amount = MatchPlayer:GetAttribute("Escaped")
	return Amount
end

function this:setEscaped(MatchPlayer, Value)
	
	if (RunService:IsClient()) then 
		return nil
	end
	
	MatchPlayer:SetAttribute("Escaped", Value)
end

function this:setMouseLock(Player, Value)
	local Backpack = Player:WaitForChild("Backpack")
	local BasePlayer = Backpack:WaitForChild("BasePlayer")
	BasePlayer:SetAttribute("MouseLock", Value)
end

function this:getPowerAttribute(PlayerID, Attribute)
	local ServerPlayer = this:getServerPlayer(PlayerID)
	return ServerPlayer.Power:GetAttribute(Attribute)
end

function this:setPowerAttribute(PlayerID, Attribute, Value)
	local ServerPlayer = this:getServerPlayer(PlayerID)
	ServerPlayer.Power:SetAttribute(Attribute, Value)
end

function this:setPowerLocally(MatchPlayer, Attribute, Value)
	local Ability = MatchPlayer.Ability
	Ability:SetAttribute(Attribute, Value)
end

function this:setPerkLocally(MatchPlayer, Perk, Attribute, Value)
	local Perks = MatchPlayer.Perks[Perk]
	Perks:SetAttribute(Attribute, Value)
end

function this:getPowerLocally(MatchPlayer, Attribute)
	local Ability = MatchPlayer.Ability
	return Ability:GetAttribute(Attribute)
end

function this:getAnimationAction(MatchPlayer)
	return MatchPlayer:GetAttribute("AnimationAction")
end

function this:setAnimationAction(MatchPlayer, Value)
	MatchPlayer:SetAttribute("AnimationAction", Value)
end

function this:getAttackKey(MatchPlayer)
	return MatchPlayer:GetAttribute("AttackKey")
end

function this:setAttackKey(MatchPlayer, Value)
	MatchPlayer:SetAttribute("AttackKey", Value)
end

function this:getMovement(MatchPlayer)
	return MatchPlayer:GetAttribute("Movement")
end

function this:setMovement(MatchPlayer, Value)
	MatchPlayer:SetAttribute("Movement", Value)
end

function this:getEffects(MatchPlayer)
	return MatchPlayer.Effects
end

function this:hasEffect(MatchPlayer, Effect)
	if (MatchPlayer == nil) then
		return
	end
	
	return MatchPlayer.Effects[Effect]:GetAttribute("Active")
end

function this:getEffect(MatchPlayer, Effect : string, Attribute)
	return MatchPlayer.Effects[Effect]:GetAttribute(Attribute)
end

function this:applyTimedEffect(MatchPlayer, Effect : string, Duration : number)
	
	local ID = MatchPlayer:GetAttribute("ID")
	local Player = Players:GetPlayerByUserId(ID)
	
	MatchPlayer.Effects[Effect]:SetAttribute("Duration", Duration)
	MatchPlayer.Effects[Effect]:SetAttribute("Timer", Duration)
	MatchPlayer.Effects[Effect]:SetAttribute("Active", true)
	Events.Game.EffectApplied:Fire(Player, Effect)
end

function this:setEffect(MatchPlayer, Effect : string, Attribute : string, Value : any)
	MatchPlayer.Effects[Effect]:SetAttribute(Attribute, Value)
end

function this:getRole(MatchPlayer)
	
	if (MatchPlayer == nil) then
		return "Hunter"
	end
	
	local Role = MatchPlayer:GetAttribute("Role")
	return Role
end

function this:getUserId(MatchPlayer)
	local ID = MatchPlayer:GetAttribute("ID")
	return ID
end

function this:setSprinting(MatchPlayer, Value)
	MatchPlayer:SetAttribute("isSprinting", Value)
end

function this:isSprinting(MatchPlayer)
	local isSprinting = MatchPlayer:GetAttribute("isSprinting")
	return isSprinting
end

function this:setCrouching(MatchPlayer, Value)
	MatchPlayer:SetAttribute("isCrouching", Value)
end

function this:isCrouching(MatchPlayer)
	local isCrouching = MatchPlayer:GetAttribute("isCrouching")
	return isCrouching
end

function this:isVulnerable(MatchPlayer)
	local isVulnerable = MatchPlayer:GetAttribute("isVulnerable")
	return isVulnerable
end

function this:setVulnerable(MatchPlayer, Value)
	MatchPlayer:SetAttribute("isVulnerable", Value)
end

function this:getLastAttack(MatchPlayer)
	local LastAttack = MatchPlayer:GetAttribute("lastAttack")
	return LastAttack
end

function this:setLastAttack(MatchPlayer, Value)
	MatchPlayer:SetAttribute("lastAttack", Value)
end

function this:getExtractorId(MatchPlayer)
	local ExtractorId = MatchPlayer:GetAttribute("Extractor")
	return ExtractorId
end

function this:setExtractorId(MatchPlayer, Value)
	MatchPlayer:SetAttribute("Extractor", Value)
end

function this:getHealth(MatchPlayer)
	local Health = MatchPlayer.Values:GetAttribute("Health")
	return Health
end

function this:setHealth(MatchPlayer, Value)
	MatchPlayer.Values:SetAttribute("Health", math.clamp(Value, 0, this:getMaxHealth(MatchPlayer)))
end

function this:getParts(MatchPlayer)
	local Parts = MatchPlayer:GetAttribute("Parts")
	return Parts
end

function this:setParts(MatchPlayer, Value)
	MatchPlayer:SetAttribute("Parts", Value)
end

function this:HasSerum(MatchPlayer)
	local hasSerum = MatchPlayer:GetAttribute("hasSerum")
	return hasSerum
end

function this:setSerum(MatchPlayer, Value: boolean)
	MatchPlayer:SetAttribute("hasSerum", Value)
end

function this:HasItem(MatchPlayer)
	local hasItem = (MatchPlayer:GetAttribute("Item") ~= "")
	return hasItem
end

function this:getItem(MatchPlayer)
	local Item = MatchPlayer:GetAttribute("Item")
	return Item
end

function this:setItem(MatchPlayer, Item)
	MatchPlayer:SetAttribute("Item", Item)
end

function this:getMaxHealth(MatchPlayer)
	local Health = MatchPlayer.Values:GetAttribute("MaxHealth")
	return Health
end

function this:setMaxHealth(MatchPlayer, Value)
	MatchPlayer.Values:SetAttribute("MaxHealth", math.clamp(Value, 0, math.huge))
end

function this:getActionSpeed(MatchPlayer)
	local FuseSpeed = MatchPlayer.Values:GetAttribute("ActionSpeed")
	return FuseSpeed
end

function this:setActionSpeed(MatchPlayer, Value)
	MatchPlayer.Values:SetAttribute("ActionSpeed", Value)
end

function this:getInteractionSpeed(MatchPlayer)
	local FuseSpeed = MatchPlayer.Values:GetAttribute("InteractionSpeed")
	return FuseSpeed
end

function this:setInteractionSpeed(MatchPlayer, Value)
	MatchPlayer.Values:SetAttribute("InteractionSpeed", Value)
end

function this:getBattery(MatchPlayer)
	local Battery = MatchPlayer.Values:GetAttribute("Battery")
	return Battery
end

function this:setBattery(MatchPlayer, Value)
	MatchPlayer.Values:SetAttribute("Battery", math.clamp(Value, 0, 100))
end

function this:getBatteryDrain(MatchPlayer)
	local Battery = MatchPlayer.Values:GetAttribute("BatteryDrain")
	return Battery
end

function this:setDamage(MatchPlayer, Value)
	MatchPlayer.Values:SetAttribute("Damage", Value)
end

function this:getDamage(MatchPlayer)
	local Damage = MatchPlayer.Values:GetAttribute("Damage")
	return Damage
end

function this:setBatteryDrain(MatchPlayer, Value)
	MatchPlayer.Values:SetAttribute("BatteryDrain", Value)
end

function this:inChase(MatchPlayer)
	local inChase = MatchPlayer:GetAttribute("inChase")
	return inChase
end

function this:setInChase(MatchPlayer, Value)
	MatchPlayer:SetAttribute("inChase", Value)
end

function this:getChaseTimer(MatchPlayer)
	
	if (MatchPlayer == nil) then
		return -1
	end
	
	local Value = MatchPlayer:GetAttribute("ChaseTimer")
	return Value
end

function this:setChaseTimer(MatchPlayer, Value)
	MatchPlayer:SetAttribute("ChaseTimer", Value)
end

function this:getHunterDistance(MatchPlayer)
	
	if (MatchPlayer == nil) then
		return 1000
	end
	
	local Value = MatchPlayer:GetAttribute("HunterDistance")
	return Value
end

function this:setHunterDistance(MatchPlayer, Value)
	MatchPlayer:SetAttribute("HunterDistance", Value)
end

function this:getAbilityValues(MatchPlayer)
	local Value = MatchPlayer.Ability:GetAttributes()
	return Value
end

function this:setAbilityValue(MatchPlayer, Attribute, Value)
	MatchPlayer.Ability:SetAttribute(Attribute, Value)
end

function this:getProximityRadius()
	local Hunter =  this:getHunter()
	local Value = Hunter.Values:GetAttribute("ProximityRadius")
	return Value
end

function this:setProximityRadius(MatchPlayer, Value)
	MatchPlayer.Values:SetAttribute("ProximityRadius", Value)
end

function this:applyDamage(Player, Amount)
	local MatchPlayer = this:getMatchPlayer(Player.UserId)
	local Role = this:getRole(MatchPlayer)

	if (Role == "Hunter") then
		return
	end
	
	local newHealth = math.clamp(this:getHealth(MatchPlayer) - Amount, 0, 999)
	this:setHealth(MatchPlayer, newHealth)
	Events.Prey.onHealthUpdate:Fire(Player, newHealth)
end

function this:healPlayer(Player, Amount)
	local MatchPlayer = this:getMatchPlayer(Player.UserId)
	local Role = this:getRole(MatchPlayer)
	
	if (Role == "Hunter") then
		return
	end
	
	local MaxHealth = this:getMaxHealth(MatchPlayer)
	local newHealth = math.clamp(this:getHealth(MatchPlayer) + Amount, 0, MaxHealth)
	this:setHealth(MatchPlayer, newHealth)
end

function this:giveItem(ServerPlayer, Item)
	local PlayerID = ServerPlayer:GetAttribute("ID")
	local MatchPlayer = this:getMatchPlayer(PlayerID)
	local ItemClone = Items[Item]:Clone()
	ItemClone.Parent = ServerPlayer
	ItemClone.Enabled = true
	this:setItem(MatchPlayer, Item)
end

function this:spawnPrompt(PlayerID, Key, ActionName)
	
	local Player = Players:GetPlayerByUserId(PlayerID)
	local Binds = BindStorage:get(PlayerID)
	local Keys = {"", ""}
	
	if (Binds ~= nil) then
		local Controller = Binds.Controller[Key]
		local Keyboard = Binds.Keyboard[Key]
		local Inputs = {Controller, Keyboard}
		
		for count = 1, 2 do
			local toFind = tonumber(Inputs[count])
			Keys[count] = Inputs[count]
		end
		
		local MatchPlayer = this:getMatchPlayer(PlayerID)
		local Prompt = MatchPlayer["Prompt"]
		
		Prompt:SetAttribute("Keys", (Keys[1] .. "|" .. Keys[2]))
		Prompt:SetAttribute("Action", ActionName)
		Prompt:SetAttribute("lastUpdate", os.time())
	end
end

function this:setIProgress(PlayerID, Action, Progress, MaxProgress)
	
	local MatchPlayer = this:getMatchPlayer(PlayerID)
	local ProgressAttr = MatchPlayer["Progress"]
	
	ProgressAttr:SetAttribute("Action", Action)
	ProgressAttr:SetAttribute("Current", Progress)
	ProgressAttr:SetAttribute("Maximum", MaxProgress)
	ProgressAttr:SetAttribute("lastUpdate", os.time())
	
end

function this:stopIProgress(PlayerID)

	local MatchPlayer = this:getMatchPlayer(PlayerID)
	local ProgressAttr = MatchPlayer["Progress"]

	ProgressAttr:SetAttribute("Action", "ABORT")
	ProgressAttr:SetAttribute("lastUpdate", os.time())

end

function searchKeyName(KeyValue)
	local KeyCodes = Enum.KeyCode:GetEnumItems()

	for i, v in pairs(KeyCodes) do
		if (v.Value == KeyValue) then
			return v.Name
		end
	end

end

return this
