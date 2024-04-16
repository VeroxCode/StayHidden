--!native

local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local BaseValues = Modules.Game_Values.BaseValues.Collector
local ScoreEvents = Modules.Game_Values.ScoreEvents

local ACTIVATION_DISTANCE = 4.5
local INTERACTION_TIME = BaseValues.InteractionTime

local ObjectList = workspace:WaitForChild("Map").Interactables["Collectors"]
local ObjectModule = Modules["Collector"]

local Interaction = Modules.Actions.Interactions["Collector"]
local InteractionCategory = "Interactions"
local InteractionName = "Deposit Serum \n (Hold)"

local function getObjectValues(Player, Object)

	local WSPlayer = Modules.Game:getWorkspacePlayer(Player.UserId)
	local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")

	local PlayerPosition = RootPart.CFrame.Position
	local ObjectPosition = Object.InteractionSpot.CFrame.Position
	local DistanceXZ = Modules.PlayerUtils:getVectorDistanceXZ(PlayerPosition, ObjectPosition)
	local DistanceY = Modules.PlayerUtils:getVectorDistanceY(PlayerPosition, ObjectPosition)

	local Progress = ObjectModule:getProgress(Object)
	local Maximum = ObjectModule:getMaximum(Object)
	local Filled = ObjectModule:isFilled(Object)

	local InteractionTime = ObjectModule:getInteractionTime(Object)
	local hasInteractor = ObjectModule:hasInteractor(Object)
	local Interactor = ObjectModule:getInteractor(Object)

	local Values = {
		["DistanceY"] = DistanceY,
		["DistanceXZ"] = DistanceXZ,
		["Interactor"] = Interactor,
		["hasInteractor"] = hasInteractor,
		["InteractionTime"] = InteractionTime,
		["Progress"] = Progress,
		["Maximum"] = Maximum,
		["Filled"] = Filled,
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
	local HasSerum = Modules.Game:HasSerum(MatchPlayer)

	if (isInRange(ObjectValues) and HasSerum and ObjectValues.Progress < ObjectValues.Maximum) then
		Modules.Game:spawnPrompt(Player.UserId, InteractionCategory, InteractionName)
		Modules.Actions:setInteraction(Player.UserId, Interaction)
	end
end

function isInRange(ObjectValues)
	if (ObjectValues.DistanceXZ > ACTIVATION_DISTANCE) then
		return false
	end

	if (ObjectValues.DistanceY > ACTIVATION_DISTANCE * 3) then
		return false
	end

	return true
end

function updateUI(Object, ObjectValues)

	local UI = Object.UI

	if (ObjectValues.Progress >= ObjectValues.Maximum) then
		Object:SetAttribute("Filled", true)
		UI.Progress.Text = "Collector Filled!"
	else
		UI.Progress.Text = "Capacity: " .. ObjectValues.Progress .. "/" .. ObjectValues.Maximum
	end
end

function updateCollecting(Object, ObjectValues, PlayerID, delta)
	
	if (ObjectValues.Interactor == 0 or ObjectValues.Interactor ~= PlayerID) then
		return
	end
	
	local MatchPlayer = Modules.Game:getMatchPlayer(ObjectValues.Interactor)
	local InteractionSpeed = Modules.Game:getInteractionSpeed(MatchPlayer)
	local WSPlayer = Modules.Game:getWorkspacePlayer(PlayerID)
	local isSprinting = Modules.Game:isSprinting(MatchPlayer)
	
	if (ObjectValues.Progress < ObjectValues.Maximum and ObjectValues.hasInteractor) then
		ObjectModule:setInteractionTime(Object, ObjectValues.InteractionTime + (delta * InteractionSpeed))
		Modules.Game:setIProgress(ObjectValues.Interactor, "Depositing", ObjectValues.InteractionTime, INTERACTION_TIME)
		Modules.PlayerUtils:setRotation(WSPlayer.PrimaryPart, Object.Position, .2)

		if (ObjectValues.InteractionTime >= INTERACTION_TIME) then

			Modules.Speed:removeMultiplier(MatchPlayer, "Interaction")
			Modules.Game:setAnimationAction(MatchPlayer, if (isSprinting) then "Run" else "Walk")
			Modules.Game:setSerum(MatchPlayer, false)
			
			ObjectModule:setProgress(Object, ObjectValues.Progress + 1)
			ObjectModule:setInteractionTime(Object, 0)
			releaseInteractor(ObjectValues.Interactor)
			assignInteractor(Object, 0)
			Modules.Events.Game.SerumInserted:Fire(MatchPlayer)
		end
	end
end

function onServerTick(delta)

	if (not Modules.Game:isRunning()) then
		return
	end
	
	for count = 1, (#ObjectList:GetChildren() - 1) do
		
		local Object = ObjectList[count]
		
		for i, Player in ipairs(Players:GetPlayers()) do
			if (Object:isA("Part")) then
				
				local ObjectValues = getObjectValues(Player, Object)
				local isHunter = Modules.Game:isHunter(Player.UserId)

				if (ObjectValues ~= nil) then
					
					updateUI(Object, ObjectValues)

					if (ObjectValues.hasInteractor) then
						updateCollecting(Object, ObjectValues, Player.UserId, delta)
						validateInteractor(Object, ObjectValues, Player.UserId)
					else
						if (not isHunter) then
							spawnPrompt(Object, ObjectValues, Player)
						end
					end
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

							Modules.Actions:setAction(Player.UserId, Modules.Actions.List.INSERT)
							Modules.PlayerUtils:setPositionXZ(RootPart, Object.InteractionSpot.CFrame.Position)
							Modules.Game:setAnimationAction(MatchPlayer, "Insert")
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

						Modules.Actions:setAction(Player.UserId, Modules.Actions.List.INSERT)
						Modules.PlayerUtils:setPositionXZ(RootPart, Object.InteractionSpot.CFrame.Position, .2)
						Modules.Game:setAnimationAction(MatchPlayer, "Insert")
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