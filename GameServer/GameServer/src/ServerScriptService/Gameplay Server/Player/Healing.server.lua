local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local SpawnNotification = game.ReplicatedStorage.Remotes:WaitForChild("SpawnNotification")
local Events = game.ServerStorage.Events

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ACTION_DISTANCE = 4
local TimeToHeal = 10
local AmountToHeal = 12.5

local Interaction = Modules.Actions.Interactions.Heal
local InteractionCategory = "Interactions"
local InteractionName = "Heal"

local DebugTable = {
	inDebug = workspace:GetAttribute("Debug"),
	Players = workspace:GetAttribute("DebugPlayers"),
	needHunter = workspace:GetAttribute("DebugNeedHunter")
}

local connections = {}

function onServerTick(delta)
	
	if (not Modules.Game:isRunning() or Modules.Game:getMatchTimer() < 10) then
		return
	end
	
	for i, v in pairs(Players:GetPlayers()) do
		
		local MatchPlayer = Modules.Game:getMatchPlayer(v.UserId)
		local Role = Modules.Game:getRole(MatchPlayer)
		
		local isParalyzed = Modules.Game:hasEffect(MatchPlayer, "Paralyzed")
		local PInteraction = Modules.Actions:getInteraction(v.UserId)
		local Action = Modules.Actions:getAction(v.UserId)
		
		if (Role == "Hunter" or Action ~= Modules.Actions.List.IDLE or (PInteraction ~= 0 and PInteraction ~= Interaction) or isParalyzed) then
			continue
		end
		
		local Nearest, found = searchNearestPlayer(v)
		
		if (found) then
			Modules.Actions:setInteraction(v.UserId, Interaction)
			if (Action ~= Modules.Actions.List.HEALING) then
				Modules.Game:spawnPrompt(v.UserId, InteractionCategory, InteractionName)
			end
		end
	end
end

function searchNearestPlayer(Player)
	
	local Character = Player.Character
	local PrimaryPart = Character.PrimaryPart
	
	for i, v in pairs(Players:GetPlayers()) do
		if (v.Name ~= Player.Name) then
			
			local TCharacter = v.Character
			local TPrimaryPart = TCharacter.PrimaryPart
			local Dist = Modules.PlayerUtils:getVectorDistanceXZ(PrimaryPart.CFrame.Position, TPrimaryPart.CFrame.Position)
			
			local MatchPlayer = Modules.Game:getMatchPlayer(v.UserId)
			local Role = Modules.Game:getRole(MatchPlayer)
			
			if (Role == "Hunter") then
				continue
			end
			
			local Action = Modules.Actions:getAction(v.UserId)
			local isSprinting = Modules.Game:isSprinting(MatchPlayer)
			local isWounded = Modules.Game:hasEffect(MatchPlayer, "FreshWound")
			local MaxHealth = Modules.Game:getMaxHealth(MatchPlayer)
			local Health = Modules.Game:getHealth(MatchPlayer)
			
			local canHeal = (Action == Modules.Actions.List.IDLE) and not isSprinting and (Health < MaxHealth) and not isWounded
			
			if (Dist <= ACTION_DISTANCE and canHeal) then
				return v, true
			end
			
		end
	end
	
	return nil, false
end

function onInputClick(Player, Key, Down)
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local isHunter = Modules.Game:isHunter(Player.UserId)

	if (isHunter or not Modules.Game:isRunning()) then
		return
	end

	local Binds = Modules.BindStorage:get(Player.UserId)
	local Interactions = {Binds.Controller[InteractionCategory], Binds.Keyboard[InteractionCategory]}

	if (table.find(Interactions, Key.Value)) then
		
		local Nearest, found = searchNearestPlayer(Player)
		
		if (Down) then
			
			if (not found) then
				return
			end
			
			local TMatchPlayer = Modules.Game:getMatchPlayer(Nearest.UserId)
			local Role = Modules.Game:getRole(MatchPlayer)

			local PInteraction = Modules.Actions:getInteraction(Player.UserId)
			local Action = Modules.Actions:getAction(Player.UserId)

			if (Role == "Hunter" or Action ~= Modules.Actions.List.IDLE or PInteraction ~= Interaction) then
				return
			end	

			if (PInteraction == Interaction) then
				startHeal(Player, Nearest)
				Modules.Actions:setAction(Player.UserId, Modules.Actions.List.HEALING)
				Modules.Game:setAnimationAction(MatchPlayer, "Heal")
				Modules.Speed:addMultiplier(MatchPlayer, "BaseHeal", 0, 0)
				Modules.Speed:addMultiplier(TMatchPlayer, "BaseHeal", 0, 0)
			end
		else
			stopHeal(Player)
		end
	end

end

function onMobileInput(Player, Action, Down)
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local Nearest, found = searchNearestPlayer(Player)

	if (Down) then

		if (not found) then
			return
		end

		local TMatchPlayer = Modules.Game:getMatchPlayer(Nearest.UserId)
		local Role = Modules.Game:getRole(MatchPlayer)

		local PInteraction = Modules.Actions:getInteraction(Player.UserId)
		local Action = Modules.Actions:getAction(Player.UserId)

		if (Role == "Hunter" or Action ~= Modules.Actions.List.IDLE or PInteraction ~= Interaction) then
			return
		end	

		if (PInteraction == Interaction) then
			startHeal(Player, Nearest)
			Modules.Actions:setAction(Player.UserId, Modules.Actions.List.HEALING)
			Modules.Game:setAnimationAction(MatchPlayer, "Heal")
			Modules.Speed:addMultiplier(MatchPlayer, "BaseHeal", 0, 0)
			Modules.Speed:addMultiplier(TMatchPlayer, "BaseHeal", 0, 0)
		end
	else
		stopHeal(Player)
	end
end

function startHeal(Player, Target)
	
	print(`start {Player} | {Target}`)
	
	if (connections[Player.Name] ~= nil) then
		return
	end
	
	connections[Player.Name] = {}
	connections[Player.Name][1] = Target
	connections[Player.Name][3] = 0
	connections[Player.Name][2] = Events.Game.ServerTick.Event:Connect(function(delta)
		
		local MatchTarget = Modules.Game:getMatchPlayer(Target.UserId)
		local isSprinting = Modules.Game:isSprinting(MatchTarget)
		local MaxHealth = Modules.Game:getMaxHealth(MatchTarget)
		local Health = Modules.Game:getHealth(MatchTarget)
		
		local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
		local ActionSpeed = Modules.Game:getActionSpeed(MatchPlayer)
		
		if (isSprinting or (Health >= MaxHealth)) then
			stopHeal(Player)
		else
			
			local Character = Player.Character
			local PrimaryPart = Character.PrimaryPart

			local TCharacter = Target.Character
			local TPrimaryPart = TCharacter.PrimaryPart
			local TPosition = TPrimaryPart.CFrame.Position
			
			Modules.PlayerUtils:setRotation(PrimaryPart, TPosition, .2)
			
			connections[Player.Name][3] += (delta * ActionSpeed)
			Modules.Game:setIProgress(Player.UserId, `Healing {Target.Name}`, connections[Player.Name][3], TimeToHeal)
			Modules.Game:setIProgress(Target.UserId, `Getting healed by {Player.Name}`, connections[Player.Name][3], TimeToHeal)
			
			if (connections[Player.Name][3] >= TimeToHeal) then
				Modules.Game:healPlayer(Target, AmountToHeal)
				stopHeal(Player)
			end
		end
	end)
end

function stopHeal(Player)
	
	if (connections[Player.Name] == nil) then
		return
	end
	
	local Target = connections[Player.Name][1]
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local MatchTarget = Modules.Game:getMatchPlayer(Target.UserId)
	
	
	local isSprinting = Modules.Game:isSprinting(MatchPlayer)
	
	Modules.Actions:setAction(Player.UserId, Modules.Actions.List.IDLE)
	Modules.Game:setAnimationAction(MatchPlayer, if (isSprinting) then "Run" else "Walk")
	Modules.Speed:removeMultiplier(MatchPlayer, "BaseHeal")
	Modules.Speed:removeMultiplier(MatchTarget, "BaseHeal")
	
	connections[Player.Name][2]:Disconnect()
	connections[Player.Name] = nil
	
end

Events.Game.ServerTick.Event:Connect(onServerTick)
Events.onInputClick.Event:Connect(onInputClick)
Events.onMobileInput.Event:Connect(onMobileInput)