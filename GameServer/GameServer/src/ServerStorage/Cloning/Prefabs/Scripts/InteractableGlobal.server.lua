local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ACTIVATION_DISTANCE = 3.5

local BaseValues = nil --Modules.Game_Values.BaseValues["INTERACTABLE"]
local ScoreEvents = Modules.Game_Values.ScoreEvents

local ObjectList = nil --workspace:WaitForChild("Map").Interactables["INTERACTABLE"]
local ObjectModule = nil --Modules.["INTERACTABLE"]

local Interaction = nil --Modules.Actions.Interactions["INTERACTABLE"]
local InteractionCategory = "Actions"
local InteractionName = "INTERACTION_NAME"

local function getObjectValues(Player, Object)

	local WSPlayer = Modules.Game:getWorkspacePlayer(Player.UserId)
	local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")

	local Object = Object
	local PlayerPosition = RootPart.CFrame.Position
	local ObjectPosition = Object.Position
	local DistanceXZ = Modules.PlayerUtils:getVectorDistanceXZ(PlayerPosition, ObjectPosition)
	local DistanceY = Modules.PlayerUtils:getVectorDistanceY(PlayerPosition, ObjectPosition)

	local hasInteractor = ObjectModule:hasInteractor(Object)
	local Interactor = ObjectModule:getInteractor(Object)

	local Values = {
		["DistanceY"] = DistanceY,
		["DistanceXZ"] = DistanceXZ,
		["Interactor"] = Interactor,
		["hasInteractor"] = hasInteractor,
	}
	return Values

end

function validateInteractor(Object, ObjectValues)
	if (not isInRange(ObjectValues)) then
		releaseInteractor(ObjectValues.Interactor)
		ObjectModule:setInteractor(Object, 0)
		ObjectModule:setInteractionTime(Object, 0)
	end
end

function releaseInteractor(InteractorID)
	if (InteractorID == 0 or InteractorID == nil) then
		return
	end

	local MatchPlayer = Modules.Game:getMatchPlayer(InteractorID)
	Modules.Actions:setAction(InteractorID, Modules.Actions.List.IDLE)
	Modules.Speed:removeMultiplier(MatchPlayer, "Interaction")
	Modules.Game:setAnimationAction(MatchPlayer, "Walk")
end

function assignInteractor(Object, PlayerID)
	Modules.Speed:addMultiplier(Modules.Game:getMatchPlayer(PlayerID), "Interaction", 0, 0)
	ObjectModule:setInteractor(Object, PlayerID)
	ObjectModule:setInteractionTime(Object, 0)
end

function spawnPrompt(Object, ObjectValues, Player)
	if (isInRange(ObjectValues)) then
		Modules.Actions:setInteraction(Player.UserId, Interaction)
		Modules.Game:spawnPrompt(Player.UserId, InteractionCategory, InteractionName)
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

function onServerTick(delta)
	
	if (not Modules.Game:isRunning()) then
		return
	end
	
	for i, Player in ipairs(Players:GetPlayers()) do
		for i, Object in pairs(ObjectList:GetChildren()) do
			if (Object:isA("Part")) then

				local ObjectValues = getObjectValues(Player, Object)

				if (ObjectValues ~= nil) then
					if (ObjectValues.hasInteractor) then
						validateInteractor(Object, ObjectValues)
					else
						spawnPrompt(Object, ObjectValues, Player)
					end
				end
			end	
		end
	end
end

function onMouseClick(Player, Key, Down)
	
	local isHunter = Modules.Game:isHunter(Player.UserId)

	if (isHunter) then
		return
	end
	
	if (Key == 1) then
		for count = 1, (#ObjectList:GetChildren() - 1) do

			local WSPlayer = Modules.Game:getWorkspacePlayer(Player.UserId)
			local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)

			local PlayerInteraction = Modules.Actions:getInteraction(Player.UserId)
			local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")

			local Object = ObjectList[count]
			local ObjectValues = getObjectValues(Player, Object)

			if (ObjectValues ~= nil) then
				if (Down) then
					if (isInRange(ObjectValues) and PlayerInteraction == Interaction) then
						if (not ObjectValues.hasInteractor) then
							assignInteractor(Object, Player.UserId)
						end
					end
				else
					if (ObjectValues.Interactor == Player.UserId) then
						assignInteractor(Object, 0)
					end
				end
			end
		end
	end
end

function onInputClick(Player, Key, Down)

	local Binds = Modules.BindStorage:get(Player.UserId)
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local isHunter = Modules.Game:isHunter(Player.UserId)

	if (Binds == nil or isHunter) then
		return
	end

local InteractionBinds = {Binds.Controller[InteractionCategory], Binds.Keyboard[InteractionCategory]} 

	if (table.find(InteractionBinds, Key.Value)) then
		for count = 1, (#ObjectList:GetChildren() - 1) do

			local WSPlayer = Modules.Game:getWorkspacePlayer(Player.UserId)
			local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)

			local PlayerInteraction = Modules.Actions:getInteraction(Player.UserId)
			local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")

			local Object = ObjectList[count]
			local ObjectValues = getObjectValues(Player, Object)

			if (ObjectValues ~= nil) then
				if (Down) then
					if (isInRange(ObjectValues) and PlayerInteraction == Interaction) then
						if (not ObjectValues.hasInteractor) then
							assignInteractor(Object, Player.UserId)
						end
					end
				else
					if (ObjectValues.Interactor == Player.UserId) then
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

			local Object = ObjectList[count]
			local ObjectValues = getObjectValues(Player, Object)

			if (ObjectValues ~= nil) then
				if (isInRange(ObjectValues) and PlayerInteraction == Interaction) then
					if (not ObjectValues.hasInteractor) then
						assignInteractor(Object, Player.UserId)
					end
				end
			end
		end
	end
end

Modules.Events.Game.ServerTick.Event:Connect(onServerTick)
Modules.Events.onMobileInput.Event:Connect(onMobileInput)
Modules.Events.onInputClick.Event:Connect(onInputClick)
Modules.Events.onMouseClick.Event:Connect(onMouseClick)

