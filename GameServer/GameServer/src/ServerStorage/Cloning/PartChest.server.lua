local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local SpawnNotification = game.ReplicatedStorage.Remotes:WaitForChild("SpawnNotification")
local onMobileInput = game.ServerStorage.Events:WaitForChild("onMobileInput")
local ServerTick = game.ServerStorage.Events.Game:WaitForChild("ServerTick")
local onMouseClick = game.ServerStorage.Events:WaitForChild("onMouseClick")

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ObjectList = workspace:WaitForChild("Map").Interactables.PartChests
local Interaction = Modules.Actions.Interactions.PartChest
local ObjectModule = Modules.PartChest

local ACTIVATION_DISTANCE = 3
local INTERACTION_TIME = 5

local InteractionCategory = "Interactions"
local InteractionName = "Scavenge \n (Hold)"

local DebugTable = {
	inDebug = workspace:GetAttribute("Debug"),
	Players = workspace:GetAttribute("DebugPlayers"),
	needHunter = workspace:GetAttribute("DebugNeedHunter")
}

local BaseRots = {}

local function getObjectValues(Player, Object)

	local WSPlayer = Modules.Game:getWorkspacePlayer(Player.UserId)
	local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")

	local PlayerPosition = RootPart.CFrame.Position
	local ObjectPosition = Object.InteractionSpot.CFrame.Position
	local DistanceXZ = Modules.PlayerUtils:getVectorDistanceXZ(PlayerPosition, ObjectPosition)
	local DistanceY = Modules.PlayerUtils:getVectorDistanceY(PlayerPosition, ObjectPosition)

	local Amount = Modules.PartChest:getAmount(Object)
	local Looted = Modules.PartChest:isLooted(Object)
	local Timer = Modules.PartChest:getTimer(Object)
	local Refill = Modules.PartChest:getRefill(Object)

	local hasInteractor = Modules.PartChest:hasInteractor(Object)
	local Interactor = Modules.PartChest:getInteractor(Object)
	local InteractionTime = Modules.PartChest:getInteractionTime(Object)

	local Values = {
		["DistanceY"] = DistanceY,
		["DistanceXZ"] = DistanceXZ,
		["Interactor"] = Interactor,
		["InteractionTime"] = InteractionTime,
		["hasInteractor"] = hasInteractor,
		["Amount"] = Amount,
		["isLooted"] = Looted,
		["Timer"] = Timer,
		["Refill"] = Refill,
		
	}
	return Values

end

function validateInteractor(Object, ObjectValues, PlayerID)
	if (not isInRange(ObjectValues) and PlayerID == ObjectValues.Interactor) then
		releaseInteractor(ObjectValues.Interactor)
		assignInteractor(Object, 0)
	end
end

function refillChest(Object, delta)
	
	if (not ObjectModule:isLooted(Object)) then
		return
	end
	
	local Timer = ObjectModule:getTimer(Object)
	Timer += delta
	
	ObjectModule:setTimer(Object, Timer)
	
	if (Timer >= ObjectModule:getRefill(Object)) then
		ObjectModule:setLooted(Object, false)
		ObjectModule:setTimer(Object, 0)
	end
	
end

function releaseInteractor(InteractorID)
	if (InteractorID == 0 or InteractorID == nil) then
		return
	end

	local MatchPlayer = Modules.Game:getMatchPlayer(InteractorID)
	local isSprinting = Modules.Game:isSprinting(MatchPlayer)

	Modules.Actions:setAction(InteractorID, Modules.Actions.List.IDLE)
	Modules.Speed:removeMultiplier(MatchPlayer, "Interaction")
	Modules.Game:setAnimationAction(MatchPlayer, if (isSprinting) then "Run" else "Walk")
	Modules.Game:stopIProgress(InteractorID)
end

function assignInteractor(Object, PlayerID)
	ObjectModule:setInteractor(Object, PlayerID)
	ObjectModule:setInteractionTime(Object, 0)
end

function spawnPrompt(Object, ObjectValues, Player)

	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local isHunter = Modules.Game:isHunter(Player.UserId)

	if (isInRange(ObjectValues) and not isHunter) then
		if (not ObjectValues.isLooted) then
			Modules.Game:spawnPrompt(Player.UserId, InteractionCategory, InteractionName)
			Modules.Actions:setInteraction(Player.UserId, Interaction)
		end
	end
end

function isInRange(ObjectValues)
	if (ObjectValues.DistanceXZ > ACTIVATION_DISTANCE) then
		return false
	end

	if (ObjectValues.DistanceY > ACTIVATION_DISTANCE * 2) then
		return false
	end

	return true
end

function updateChest(Object, hasInteractor, Looted)
	 
	 if (not Modules.Game:isRunning() or Modules.Game:getMatchTimer() < 2) then
		return
	 end
	 
	if (hasInteractor or Looted) then
		local base = BaseRots[Object.Name]
		local newcf = base * CFrame.Angles(math.rad(60), 0, 0)
		local tween = TweenService:Create(Object.Top.PrimaryPart, TweenInfo.new(0.2), {CFrame = newcf})
		tween:Play()
	else
		local base = BaseRots[Object.Name]
		local tween = TweenService:Create(Object.Top.PrimaryPart, TweenInfo.new(0.2), {CFrame = base})
		tween:Play()
	end
end

function updateScavenging(Object, ObjectValues, PlayerID, delta)
	
	if (not ObjectValues.hasInteractor or ObjectValues.Interactor ~= PlayerID) then
		return
	end
	
	if (not ObjectValues.Looted) then
		if (ObjectValues.hasInteractor) then
			
			local Interactor = tonumber(ObjectValues.Interactor)
			local MatchPlayer = Modules.Game:getMatchPlayer(ObjectValues.Interactor)
			local InteractionSpeed = Modules.Game:getInteractionSpeed(MatchPlayer)
			local Parts = Modules.Game:getParts(MatchPlayer)
			
			ObjectModule:setInteractionTime(Object, ObjectValues.InteractionTime + (delta * InteractionSpeed))
			Modules.Game:setIProgress(ObjectValues.Interactor, "Scavenging", ObjectValues.InteractionTime, INTERACTION_TIME)
			if (ObjectValues.InteractionTime >= INTERACTION_TIME) then

				SpawnNotification:FireClient(Players:GetPlayerByUserId(Interactor), "Prey", "Install the Parts in an Extractor!")
				
				Modules.Game:setParts(MatchPlayer, Parts + ObjectValues.Amount)
				Modules.Actions:setAction(ObjectValues.Interactor, Modules.Actions.List.IDLE)
				Modules.Speed:removeMultiplier(MatchPlayer, "Interaction")
				Modules.Game:setAnimationAction(MatchPlayer, "Walk")
				Modules.Credits:increaseCredits(ObjectValues.Interactor, (Modules.Game_Values.ScoreEvents.Prey.ChestScavenged))
				Modules.Game:stopIProgress(Interactor)
				
				ObjectModule:setTimer(Object, 0)
				ObjectModule:setLooted(Object, true)
				releaseInteractor(PlayerID)
				assignInteractor(Object, 0)
			end
		end
	end
end

function onMatchStart()
	
	for i, v in pairs(ObjectList:GetChildren()) do
		if (not v:isA("Model")) then
			continue
		end
		
		BaseRots[v.Name] = v.Top.PrimaryPart.CFrame
	end
end

function onServerTick(delta)
	
	if (not Modules.Game:isRunning()) then
		return
	end
	
	for count = 1, (#ObjectList:GetChildren() - 1) do
		
		refillChest(ObjectList[count], delta)
		
		for i, Player in pairs(Players:GetPlayers()) do
		
			local Object = ObjectList[count]
			local ObjectValues = getObjectValues(Player, Object)

			if (ObjectValues ~= nil) then
				updateChest(Object, ObjectValues.hasInteractor, ObjectValues.isLooted)
				if (ObjectValues.hasInteractor) then
					validateInteractor(Object, ObjectValues, Player.UserId)
					updateScavenging(Object, ObjectValues, Player.UserId, delta)
					
					local Interactor = game.Players:GetPlayerByUserId(ObjectValues.Interactor)
					Modules.PlayerUtils:setRotation(Interactor.Character.PrimaryPart, Object.PrimaryPart.Position, .2)
				else
					spawnPrompt(Object, ObjectValues, Player)
				end
			end	
		end
	end
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
		for count = 1, (#ObjectList:GetChildren() - 1) do

			local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
			local PlayerInteraction = Modules.Actions:getInteraction(Player.UserId)
			local HasSerum = Modules.Game:HasSerum(MatchPlayer)
			local PlayerParts = Modules.Game:getParts(MatchPlayer)

			local Object = ObjectList[count]
			local ObjectValues = getObjectValues(Player, Object)

			if (ObjectValues ~= nil) then
				if (Down) then
					if (isInRange(ObjectValues) and PlayerInteraction == Interaction) then
						if (not ObjectValues.hasInteractor) then
							
							local RootPart = Player.Character.HumanoidRootPart
							local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)

							Modules.Actions:setAction(Player.UserId, Modules.Actions.List.SCAVENGING)
							Modules.PlayerUtils:setPositionXZ(RootPart, Object.InteractionSpot.CFrame.Position)
							Modules.Game:setAnimationAction(MatchPlayer, "ChestSearch")
							Modules.Speed:addMultiplier(MatchPlayer, "Interaction", 0, 0)
							
							assignInteractor(Object, Player.UserId)
						end
					end
				else
					if (ObjectValues.Interactor == Player.UserId) then
						Modules.Game:stopIProgress(Player.UserId)
						releaseInteractor(Player.UserId)
						assignInteractor(Object, 0)
					end
				end
			end
		end
	end

end

function onMobileInput(Player, Action, Down)

	local isHunter = Modules.Game:isHunter(Player.UserId)

	if (isHunter) then
		return
	end

	if (Action == Interaction and Down) then
		for count = 1, (#ObjectList:GetChildren() - 1) do

			local WSPlayer = Modules.Game:getWorkspacePlayer(Player.UserId)
			local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)

			local PlayerInteraction = Modules.Actions:getInteraction(Player.UserId)
			local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")

			local HasSerum = Modules.Game:HasSerum(MatchPlayer)
			local PlayerParts = Modules.Game:getParts(MatchPlayer)

			local Object = ObjectList[count]
			local ObjectValues = getObjectValues(Player, Object)

			if (ObjectValues ~= nil) then
				if (isInRange(ObjectValues) and PlayerInteraction == Interaction) then
					if (not ObjectValues.hasInteractor) then

						local RootPart = Player.Character.HumanoidRootPart
						local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)

						Modules.Actions:setAction(Player.UserId, Modules.Actions.List.SCAVENGING)
						Modules.PlayerUtils:setPositionXZ(RootPart, Object.InteractionSpot.CFrame.Position)
						Modules.Game:setAnimationAction(MatchPlayer, "ChestSearch")
						Modules.Speed:addMultiplier(MatchPlayer, "Interaction", 0, 0)

						assignInteractor(Object, Player.UserId)
					end
				end
			else
				if (ObjectValues.Interactor == Player.UserId) then
					Modules.Game:stopIProgress(Player.UserId)
					releaseInteractor(Player.UserId)
					assignInteractor(Object, 0)
				end
			end
		end
	end
end

Modules.Events.Game.MatchStart.Event:Connect(onMatchStart)
Modules.Events.Game.ServerTick.Event:Connect(onServerTick)
Modules.Events.onMobileInput.Event:Connect(onMobileInput)
Modules.Events.onInputClick.Event:Connect(onInputClick)