local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ACTIVATION_DISTANCE = 12
local PositionOffset = 0.5

local ObjectList = workspace:WaitForChild("Map").Interactables["BigDoors"]
local ObjectModule = Modules["BigDoor"]

local Interaction = Modules.Actions.Interactions["BigDoors"]
local InteractionCategory = "Actions"
local InteractionName = "Close Door"

local DebugTable = {
	inDebug = workspace:GetAttribute("Debug"),
	Players = workspace:GetAttribute("DebugPlayers"),
	needHunter = workspace:GetAttribute("DebugNeedHunter")
}

local function getObjectValues(Player, Object)

	local WSPlayer = Modules.Game:getWorkspacePlayer(Player.UserId)
	local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")

	local PlayerPosition = RootPart.CFrame.Position
	local ObjectPosition = Object.CFrame.Position
	local DistanceXZ = Modules.PlayerUtils:getVectorDistanceXZ(PlayerPosition, ObjectPosition)
	local DistanceY = Modules.PlayerUtils:getVectorDistanceY(PlayerPosition, ObjectPosition)

	local hasInteractor = ObjectModule:hasInteractor(Object)
	local Interactor = ObjectModule:getInteractor(Object)
	
	local isOpened = ObjectModule:isOpened(Object)
	local isPowered = ObjectModule:isPowered(Object)
	local Fusebox = ObjectModule:getFusebox(Object)
	
	local isTweening = ObjectModule:isTweening(Object)
	local Timer = ObjectModule:getTimer(Object)
	local CloseTime = ObjectModule:getCloseTime(Object)

	local Values = {
		["DistanceXZ"] = DistanceXZ,
		["DistanceY"] = DistanceY,
		["Interactor"] = Interactor,
		["hasInteractor"] = hasInteractor,
		["isOpened"] = isOpened,
		["isPowered"] = isPowered,
		["Fusebox"] = Fusebox,
		["isTweening"] = isTweening,
		["Timer"] = Timer,
		["CloseTime"] = CloseTime,
	}
	return Values

end

function validateInteractor(Object, ObjectValues, PlayerId)
	if ((not isInRange(ObjectValues) and (ObjectValues.isOpened and not ObjectValues.isTweening))) then
		if (ObjectValues.Interactor == PlayerId) then
			releaseInteractor(Object, ObjectValues.Interactor)
		end
	end
end

function releaseInteractor(Object, Interactor)
	
	if (Interactor == 0) then
		return
	end
	
	local Player = Players:GetPlayerByUserId(Interactor)
	Modules.AuraManager:removeAura(Player, "BigDoors", Object.Name, "Closed")
	
	assignInteractor(Object, 0)
end

function assignInteractor(Object, PlayerID)
	ObjectModule:setInteractor(Object, PlayerID)
end

function isInRange(ObjectValues)
	if (ObjectValues.DistanceXZ > ACTIVATION_DISTANCE) then
		return false
	end

	if (ObjectValues.DistanceY > ACTIVATION_DISTANCE) then
		return false
	end

	return true
end

function tickDoor(Object, delta)
	
	if (ObjectModule:isTweening(Object)) then
		return
	end
	
	if (ObjectModule:isPowered(Object)) then
		
		local Timer = ObjectModule:getTimer(Object)
		Timer -= delta
		
		ObjectModule:setTimer(Object, Timer)
		
		if (Timer <= 0) then
			manageDoor(Object, true)
			releaseInteractor(Object, ObjectModule:getInteractor(Object))
		end
	end
end

function drainEntryCost(Player)
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local Battery = Modules.Game:getBattery(MatchPlayer)
	local BatteryDrain = Modules.Game:getBatteryDrain(MatchPlayer)
	
	local newBattery = Battery - (BatteryDrain * 1.25)
	Modules.Game:setBattery(MatchPlayer, newBattery)
end

function manageDoor(Object, Open)
	
	local goalTransparency = if (Open) then 0.7 else 0
	local goal = {Transparency = goalTransparency}
	local tween = TweenService:Create(Object, TweenInfo.new(1.25, Enum.EasingStyle.Linear), goal)

	tween:Play()
	ObjectModule:setTweening(Object, true)
	ObjectModule:setTimer(Object, ObjectModule:getCloseTime(Object))
	
	tween.Completed:Connect(function()
		ObjectModule:setTweening(Object, false)
		ObjectModule:setOpened(Object, Open)
		Object.CanCollide = not Open
	end)
	
end

function onServerTick(delta)
	
	if (not Modules.Game:isRunning()) then
		return
	end
	
	for i, Object in pairs(ObjectList:GetChildren()) do
		if (Object:isA("Script")) then continue end
		
		local HasInteractor = ObjectModule:hasInteractor(Object)
		
		if (HasInteractor) then
			local Interactor = ObjectModule:getInteractor(Object)
			local InteractorPlayer = Modules.Game:getMatchPlayer(Interactor)
			local Battery = Modules.Game:getBattery(InteractorPlayer)
			local BatteryDrain = Modules.Game:getBatteryDrain(InteractorPlayer)

			if (Battery > 0) then
				local newBattery = Battery - (BatteryDrain * delta)
				Modules.Game:setBattery(InteractorPlayer, newBattery)
			else
				releaseInteractor(Object, Interactor)
				manageDoor(Object, true)
			end
		end
		
		tickDoor(Object, delta)
		
		for i, Player in ipairs(Players:GetPlayers()) do
			if (Object:isA("Part")) then

				local isHunter = Modules.Game:isHunter(Player.UserId)
				local ObjectValues = getObjectValues(Player, Object)

				if (ObjectValues ~= nil and not isHunter) then
					
					local Fuseboxes = workspace:WaitForChild("Map").Interactables["Fuseboxes"]
					local Fusebox = Fuseboxes[ObjectValues.Fusebox]
					local FuseboxPowered = Modules.Fusebox:isActivated(Fusebox)
					
					local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
					
					--ObjectModule:setPowered(Object, FuseboxPowered)
					
					if (not ObjectValues.isPowered) then
						manageDoor(Object, true)
						ObjectModule:setTimer(Object, ObjectValues.CloseTime)
						if (ObjectModule:hasInteractor(Object)) then
							releaseInteractor(Object, ObjectValues.Interactor)
						end
					end
					
					if (ObjectValues.hasInteractor) then
						validateInteractor(Object, ObjectValues, ObjectValues.Interactor)
					end
					
					if (isInRange(ObjectValues) and ObjectValues.isPowered and not isHunter and not Modules.Game:hasEffect(MatchPlayer, "Paralyzed")) then
						if (Modules.Game:getBattery(MatchPlayer) > 0 and ObjectValues.isOpened) then
							Modules.Actions:setInteraction(Player.UserId, Interaction)
							Modules.Game:spawnPrompt(Player.UserId, InteractionCategory, InteractionName)
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

	if (table.find(Interactions, Key.Value) and Down) then
		for count = 1, (#ObjectList:GetChildren() - 1) do

			local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
			local PlayerInteraction = Modules.Actions:getInteraction(Player.UserId)
			local HasSerum = Modules.Game:HasSerum(MatchPlayer)
			local PlayerParts = Modules.Game:getParts(MatchPlayer)

			local Object = ObjectList[count]
			local ObjectValues = getObjectValues(Player, Object)

			if (ObjectValues ~= nil) then
				if (isInRange(ObjectValues) and PlayerInteraction == Interaction and not Modules.Game:hasEffect(MatchPlayer, "Paralyzed")) then
					if (not ObjectValues.hasInteractor) then
						drainEntryCost(Player)
						assignInteractor(Object, Player.UserId)
						manageDoor(Object, false)
						Modules.Events.Prey.onDoorClose:Fire(Player, Object)
						Modules.AuraManager:createAura(Player, "BigDoors", count, false, 0, Color3.new(1, 1, 1), Color3.new(1, 1, 1), "Closed")
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

			local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
			local PlayerInteraction = Modules.Actions:getInteraction(Player.UserId)
			local HasSerum = Modules.Game:HasSerum(MatchPlayer)
			local PlayerParts = Modules.Game:getParts(MatchPlayer)

			local Object = ObjectList[count]
			local ObjectValues = getObjectValues(Player, Object)

			if (ObjectValues ~= nil) then
				if (isInRange(ObjectValues) and PlayerInteraction == Interaction and not Modules.Game:hasEffect(MatchPlayer, "Paralyzed")) then
					if (not ObjectValues.hasInteractor) then
						--drainEntryCost(Player)
						assignInteractor(Object, Player.UserId)
						manageDoor(Object, false)
						Modules.Events.Prey.onDoorClose:Fire(Player, Object)
						Modules.AuraManager:createAura(Player, "BigDoors", count, false, 0, Color3.new(1, 1, 1), Color3.new(1, 1, 1), "Closed")
					end
				end
			end
		end
	end
end

Modules.Events.Game.ServerTick.Event:Connect(onServerTick)
Modules.Events.onMobileInput.Event:Connect(onMobileInput)
Modules.Events.onInputClick.Event:Connect(onInputClick)