local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local SpawnNotification = game.ReplicatedStorage.Remotes:WaitForChild("SpawnNotification")
local onMobileInput = game.ServerStorage.Events:WaitForChild("onMobileInput")
local ServerTick = game.ServerStorage.Events.Game:WaitForChild("ServerTick")
local onMouseClick = game.ServerStorage.Events:WaitForChild("onMouseClick")

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ObjectList = workspace:WaitForChild("Map").Interactables.JunkPiles
local Interaction = Modules.Actions.Interactions.JunkPile
local ObjectModule = Modules.JunkPile

local ACTIVATION_DISTANCE = 4
local INTERACTION_TIME = 5

local InteractionCategory = "Interactions"
local InteractionName = "Search Pile \n (Hold)"

local DebugTable = {
	inDebug = workspace:GetAttribute("Debug"),
	Players = workspace:GetAttribute("DebugPlayers"),
	needHunter = workspace:GetAttribute("DebugNeedHunter")
}

local function getObjectValues(Player, Object)

	local WSPlayer = Modules.Game:getWorkspacePlayer(Player.UserId)
	local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")

	local PlayerPosition = RootPart.CFrame.Position
	local ObjectPosition = Object.Position
	local DistanceXZ = Modules.PlayerUtils:getVectorDistanceXZ(PlayerPosition, ObjectPosition)
	local DistanceY = Modules.PlayerUtils:getVectorDistanceY(PlayerPosition, ObjectPosition)

	local Looted = Modules.PartChest:isLooted(Object)
	local hasInteractor = Modules.PartChest:hasInteractor(Object)
	local Interactor = Modules.PartChest:getInteractor(Object)
	local InteractionTime = Modules.PartChest:getInteractionTime(Object)

	local Values = {
		["DistanceY"] = DistanceY,
		["DistanceXZ"] = DistanceXZ,
		["Interactor"] = Interactor,
		["InteractionTime"] = InteractionTime,
		["hasInteractor"] = hasInteractor,
		["isLooted"] = Looted,
		
	}
	return Values

end

function validateInteractor(Object, ObjectValues, PlayerID)
	if (not isInRange(ObjectValues) and PlayerID == ObjectValues.Interactor) then
		releaseInteractor(ObjectValues.Interactor)
		assignInteractor(Object, 0)
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
		
		local Item = Modules.Game:getItem(MatchPlayer)
		
		if (not ObjectValues.isLooted and Item == "") then
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

function manageColor(Object, ObjectValues)

	local nColor = Object.Color

	if (ObjectValues.isLooted) then
		nColor = Color3.new(0.588235, 0.588235, 0.588235)
	else
		nColor = Color3.new(0.247059, 0.12549, 0.0352941)
	end

	local goal = {Color = nColor}
	local tween = TweenService:Create(Object, TweenInfo.new(1.5), goal)
	tween:Play()

end

function chooseRandomItem()
	
	local LootTable = {
		["Energy"] = 30;
		["Battery Cell"] = 70;
	}
	
	for item, chance in pairs(LootTable) do
		local random = math.random(1, 100)
		
		if (random <= chance) then
			return item
		end
		
	end
	
	return LootTable[#LootTable]
	
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
			
			ObjectModule:setInteractionTime(Object, ObjectValues.InteractionTime + (delta * InteractionSpeed))
			Modules.Game:setIProgress(ObjectValues.Interactor, "Searching", ObjectValues.InteractionTime, INTERACTION_TIME)
			if (ObjectValues.InteractionTime >= INTERACTION_TIME) then

				local ServerPlayer = Modules.Game:getServerPlayer(ObjectValues.Interactor)
				local Parts = Modules.Game:getParts(MatchPlayer)
				
				Modules.Actions:setAction(ObjectValues.Interactor, Modules.Actions.List.IDLE)
				Modules.Speed:removeMultiplier(MatchPlayer, "Interaction")
				Modules.Game:setAnimationAction(MatchPlayer, "Walk")
				Modules.Game:stopIProgress(Interactor)
				
				ObjectModule:setLooted(Object, true)
				Modules.Game:giveItem(ServerPlayer, chooseRandomItem())
				releaseInteractor(PlayerID)
				assignInteractor(Object, 0)
			end
		end
	end
end

function onServerTick(delta)
	
	if (not Modules.Game:isRunning()) then
		return
	end
	
	for count = 1, (#ObjectList:GetChildren() - 1) do
		
		for i, Player in pairs(Players:GetPlayers()) do
			
			local Object = ObjectList[count]
			local ObjectValues = getObjectValues(Player, Object)
			
			manageColor(Object, ObjectValues)

			if (ObjectValues ~= nil) then
					
				if (ObjectValues.hasInteractor) then
					validateInteractor(Object, ObjectValues, Player.UserId)
					updateScavenging(Object, ObjectValues, Player.UserId, delta)
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
							Modules.PlayerUtils:setRotation(RootPart, Object.Position, .2)
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
						Modules.PlayerUtils:setRotation(RootPart, Object.Position, .2)
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

Modules.Events.Game.ServerTick.Event:Connect(onServerTick)
Modules.Events.onMobileInput.Event:Connect(onMobileInput)
Modules.Events.onInputClick.Event:Connect(onInputClick)