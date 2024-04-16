local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local SendToGrave = game.ServerStorage.Events.Prey:WaitForChild("sendToGrave")
local onMobileInput = game.ServerStorage.Events:WaitForChild("onMobileInput")
local onInputClick = game.ServerStorage.Events:WaitForChild("onInputClick")
local ServerTick = game.ServerStorage.Events.Game:WaitForChild("ServerTick")
local onMouseClick = game.ServerStorage.Events:WaitForChild("onMouseClick")
local onDeath = game.ServerStorage.Events.Prey:WaitForChild("onDeath")

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ACTIVATION_DISTANCE = 5.5
local OVERLOAD_DURATION = 30
local LOAD_COOLDOWN = 15

local OverloadTimer = {}
local CooldownTimer = {}

local ObjectList = workspace:WaitForChild("Map").Interactables["Fuseboxes"]
local ObjectModule = Modules["Fusebox"]

local Interaction = Modules.Actions.Interactions["Fusebox"]
local InteractionCategory = "Interactions"
local InteractionName2 = "Destroy \n (Hold)"
local InteractionName = "Repair \n (Hold)"

local DebugTable = {
	inDebug = workspace:GetAttribute("Debug"),
	Players = workspace:GetAttribute("DebugPlayers"),
	needHunter = workspace:GetAttribute("DebugNeedHunter")
}

local function getObjectValues(Player, Object)

	local WSPlayer = Modules.Game:getWorkspacePlayer(Player.UserId)
	local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")

	local PlayerPosition = RootPart.CFrame.Position
	local ObjectPosition = Object.InteractionSpot.CFrame.Position
	local DistanceXZ = Modules.PlayerUtils:getVectorDistanceXZ(PlayerPosition, ObjectPosition)
	local DistanceY = Modules.PlayerUtils:getVectorDistanceY(PlayerPosition, ObjectPosition)

	local hasInteractor = ObjectModule:hasInteractor(Object)
	local Interactor = ObjectModule:getInteractor(Object)
	
	local isActivated = ObjectModule:isActivated(Object)
	local ActivationTime = ObjectModule:getActivationTime(Object)
	local DeactivationTime = ObjectModule:getDeactivationTime(Object)
	local Loads = ObjectModule:getLoads(Object)
	local Overload = ObjectModule:getOverload(Object)
	local Refill = ObjectModule:getRefill(Object)

	local Values = {
		["DistanceY"] = DistanceY,
		["DistanceXZ"] = DistanceXZ,
		["Interactor"] = Interactor,
		["hasInteractor"] = hasInteractor,
		["isActivated"] = isActivated,
		["ActivationTime"] = ActivationTime,
		["DeactivationTime"] = DeactivationTime,
		["Loads"] = Loads,
		["Overload"] = Overload,
		["Refill"] = Refill,
	}
	return Values

end

function validateInteractor(Object, ObjectValues, PlayerID)
	if (not isInRange(ObjectValues) and PlayerID == ObjectValues.Interactor) then
		assignInteractor(Object, 0)
		releaseInteractor(ObjectValues.Interactor)
	end
end

function releaseInteractor(InteractorID)
	if (InteractorID == 0 or InteractorID == nil) then
		return
	end

	local MatchPlayer = Modules.Game:getMatchPlayer(InteractorID)
	local isSprinting = Modules.Game:isSprinting(MatchPlayer)
	local isHunter = Modules.Game:isHunter(InteractorID)

	Modules.Actions:setAction(InteractorID, Modules.Actions.List.IDLE)
	Modules.Game:stopIProgress(InteractorID)
	
	if (isHunter) then
		Modules.Game:setAnimationAction(MatchPlayer, "Run")
		Modules.Speed:removeMultiplier(MatchPlayer, "Interaction")
	else
		Modules.Game:setAnimationAction(MatchPlayer, if (isSprinting) then "Run" else "Walk")
		Modules.Speed:removeMultiplier(MatchPlayer, "Interaction")
	end
	
end

function assignInteractor(Object, PlayerID)
	ObjectModule:setInteractor(Object, PlayerID)
	ObjectModule:setInteractionTime(Object, 0)
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


function manageLight(Object, Activated)
	if (Activated) then
		Object.Light.Color = Color3.new(0, 1, 0)
	else
		Object.Light.Color = Color3.new(1, 0, 0)
	end
end

function manageOverload(Player, Gap)
	
	local Object = ObjectList[Modules.Gap:getFusebox(Gap)]
	CooldownTimer[Object.Name] = LOAD_COOLDOWN
	
	if (ObjectModule:getLoads(Object) >= ObjectModule:getOverload(Object)) then
		
		local timer = OVERLOAD_DURATION
		local Runner
		Runner = RunService.Heartbeat:Connect(function(delta)
			timer -= delta
			
			if (timer > 0) then
				ObjectModule:setActivated(Object, false)
			else
				ObjectModule:setActivated(Object, true)
				ObjectModule:setLoads(Object, 0)
				Runner:Disconnect()
				Runner = nil
			end
		end)
	end
end

function manageCooldown(Object, delta)
	
	if (CooldownTimer[Object.Name] == nil) then
		CooldownTimer[Object.Name] = LOAD_COOLDOWN
	else
		if (ObjectModule:getLoads(Object) < ObjectModule:getOverload(Object) and ObjectModule:getLoads(Object) > 0) then
			CooldownTimer[Object.Name] -= delta
			
			if (CooldownTimer[Object.Name] <= 0) then
				CooldownTimer[Object.Name] = LOAD_COOLDOWN
				ObjectModule:setLoads(Object, ObjectModule:getLoads(Object) - 1)
			end
		else
			CooldownTimer[Object.Name] = LOAD_COOLDOWN
		end
	end
	
end

function onServerTick(delta)
	
	if (not Modules.Game:isRunning()) then
		return
	end
	
	for i, Object in pairs(ObjectList:GetChildren()) do
		if (Object:isA("Part") or Object:isA("Model")) then
			manageCooldown(Object, delta)
		end
		for i, Player in ipairs(Players:GetPlayers()) do
			if (Object:isA("Part") or Object:isA("Model")) then

				local isHunter = Modules.Game:isHunter(Player.UserId)
				local ObjectValues = getObjectValues(Player, Object)

				if (ObjectValues ~= nil) then
					
					manageLight(Object, ObjectValues.isActivated)
					
					if (ObjectValues.hasInteractor) then
						validateInteractor(Object, ObjectValues, Player.UserId)
						
						local Interactor = game.Players:GetPlayerByUserId(ObjectValues.Interactor)
						Modules.PlayerUtils:setRotation(Interactor.Character.PrimaryPart, Object.PrimaryPart.Position, .2)
						
						local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
						local FuseSpeed = Modules.Game:getInteractionSpeed(MatchPlayer)
						
						if (Player.UserId == ObjectValues.Interactor) then

							local TimeLimit = if (isHunter) then ObjectValues.DeactivationTime else ObjectValues.ActivationTime
							local newTime = ObjectModule:getInteractionTime(Object) + (delta * FuseSpeed)
							ObjectModule:setInteractionTime(Object, newTime)
							
							if (isHunter) then
								Modules.Game:setIProgress(Player.UserId, "Destroying", newTime, TimeLimit)
							else
								Modules.Game:setIProgress(Player.UserId, "Repairing", newTime, TimeLimit)
							end
							
							if (newTime >= TimeLimit) then
								ObjectModule:setActivated(Object, not isHunter)
								releaseInteractor(ObjectValues.Interactor)
								assignInteractor(Object, 0)
								
								if (isHunter) then
									Modules.Events.Hunter.onFuseboxDestroy:Fire(Player.UserId, Object)
									Modules.Credits:increaseCredits(ObjectValues.Interactor, (Modules.Game_Values.ScoreEvents.Hunter.FuseboxDeactivated))
								else
									Modules.Events.Prey.onFuseboxRepair:Fire(Player.UserId, Object)
									local Battery = Modules.Game:getBattery(MatchPlayer)
									Battery += ObjectValues.Refill
									Modules.Game:setBattery(MatchPlayer, Battery)
								end
							end
						end
					end
					
					if (isInRange(ObjectValues) and not ObjectValues.hasInteractor) then
						
						if (ObjectValues.Loads >= ObjectValues.Overload) then
							return
						end
						
						if (isHunter) then
							if (ObjectValues.isActivated) then
								Modules.Actions:setInteraction(Player.UserId, Interaction)
								Modules.Game:spawnPrompt(Player.UserId, InteractionCategory, InteractionName2)
							end
						else
							if (not ObjectValues.isActivated) then
								Modules.Actions:setInteraction(Player.UserId, Interaction)
								Modules.Game:spawnPrompt(Player.UserId, InteractionCategory, InteractionName)
							end
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

	if (not Modules.Game:isRunning()) then
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
							local Pos = if (Object:isA("Model")) then Object.PrimaryPart.CFrame.Position else Object.CFrame.Position

							Modules.Actions:setAction(Player.UserId, Modules.Actions.List.FUSEBOX)
							Modules.PlayerUtils:setRotation(RootPart, Object.PrimaryPart.Position, .2)
							Modules.PlayerUtils:setPositionXZ(RootPart, Object.InteractionSpot.CFrame.Position, .2)
							Modules.Game:setAnimationAction(MatchPlayer, if (isHunter) then "Destroy" else "Repair")
							Modules.Speed:addMultiplier(MatchPlayer, "Interaction", 0, 0)
							
							assignInteractor(Object, Player.UserId)
						end
					end
				else
					if (ObjectValues.Interactor == Player.UserId) then
						releaseInteractor(Player.UserId)
						assignInteractor(Object, 0)
						Modules.Game:stopIProgress(Player.UserId)
					end
				end
			end
		end
	end

end

function onMobileInput(Player, Action, Down)

	local isHunter = Modules.Game:isHunter(Player.UserId)

	if (not Modules.Game:isRunning()) then
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
						local Pos = if (Object:isA("Model")) then Object.PrimaryPart.CFrame.Position else Object.CFrame.Position

						Modules.Actions:setAction(Player.UserId, Modules.Actions.List.FUSEBOX)
						Modules.PlayerUtils:setRotation(RootPart, Object.PrimaryPart.Position, .2)
						Modules.PlayerUtils:setPositionXZ(RootPart, Object.InteractionSpot.CFrame.Position, .2)
						Modules.Game:setAnimationAction(MatchPlayer, if (isHunter) then "Destroy" else "Repair")
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

Modules.Events.Prey.onSlide.Event:Connect(manageOverload)
Modules.Events.Game.ServerTick.Event:Connect(onServerTick)
Modules.Events.onMobileInput.Event:Connect(onMobileInput)
Modules.Events.onInputClick.Event:Connect(onInputClick)