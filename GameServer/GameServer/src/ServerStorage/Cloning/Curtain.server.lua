local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ACTIVATION_DISTANCE = 3.5

local BaseValues = Modules.Game_Values.BaseValues["Curtain"]
local ScoreEvents = Modules.Game_Values.ScoreEvents

local ObjectList = workspace:WaitForChild("Map").Interactables["Curtains"]
local ObjectModule = Modules.Curtain

local Interaction = Modules.Actions.Interactions["Curtain"]
local InteractionCategory = "Interactions"
local InteractionName = "Install Curtain"

local function getObjectValues(Player, Object)

	local WSPlayer = Modules.Game:getWorkspacePlayer(Player.UserId)
	local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")

	local Object = Object
	local PlayerPosition = RootPart.CFrame.Position
	local ObjectPosition = Object.Position
	local DistanceXZ = Modules.PlayerUtils:getVectorDistanceXZ(PlayerPosition, ObjectPosition)
	local DistanceY = Modules.PlayerUtils:getVectorDistanceY(PlayerPosition, ObjectPosition)
	
	local isActive = ObjectModule:isActive(Object)
	local Progress = ObjectModule:getProgress(Object)
	local Stuntime = ObjectModule:getStuntime(Object)
	local Installtime = ObjectModule:getInstalltime(Object)

	local hasInteractor = ObjectModule:hasInteractor(Object)
	local Interactor = ObjectModule:getInteractor(Object)

	local Values = {
		["isActive"] = isActive,
		["Progress"] = Progress,
		["Stuntime"] = Stuntime,
		["Installtime"] = Installtime,
		["DistanceY"] = DistanceY,
		["DistanceXZ"] = DistanceXZ,
		["Interactor"] = Interactor,
		["hasInteractor"] = hasInteractor,
	}
	return Values

end

function validateInteractor(Object, ObjectValues, PlayerID)
	if (not isInRange(ObjectValues) and ObjectValues.Interactor == PlayerID) then
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
	Modules.Game:stopIProgress(InteractorID)
end

function assignInteractor(Object, PlayerID)
	
	if (PlayerID ~= 0) then
		local MatchPlayer = Modules.Game:getMatchPlayer(PlayerID)
		Modules.Speed:addMultiplier(MatchPlayer, "Interaction", 0, 0)
		Modules.Actions:setAction(PlayerID, Modules.Actions.List.INSTALL)
		Modules.Game:setAnimationAction(MatchPlayer, "ChestSearch")
	end
	
	ObjectModule:setInteractor(Object, PlayerID)
	ObjectModule:setInteractionTime(Object, 0)
end

function spawnPrompt(Object, ObjectValues, Player)
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	
	if (Modules.Game:getRole(MatchPlayer) == "Hunter") then
		return
	end
	
	local Parts = Modules.Game:getParts(MatchPlayer)
	
	if (isInRange(ObjectValues) and not ObjectValues.hasInteractor and Parts > 0 and not ObjectValues.isActive) then
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

function updateInstallation(Object, ObjectValues, delta)
	
	local Interactor = ObjectValues.Interactor
	local MatchPlayer = Modules.Game:getMatchPlayer(Interactor)
	local ActionSpeed = Modules.Game:getActionSpeed(MatchPlayer)
	local Parts = Modules.Game:getParts(MatchPlayer)
	
	local Installtime = 100 / ObjectValues.Installtime
	local Progress = ObjectValues.Progress
	Progress += ((Installtime * delta) * ActionSpeed)
	
	ObjectModule:setProgress(Object, Progress)
	Modules.Game:setIProgress(Interactor, "Installing Curtain", Progress, 100)
	
	if (Progress >= 100) then
		ObjectModule:setActive(Object, true)
		ObjectModule:setProgress(Object, 0)
		releaseInteractor(Interactor)
		assignInteractor(Object, 0)
		Modules.Game:stopIProgress(Interactor)
		Modules.Game:setParts(MatchPlayer, Parts - 1)
		return
	end
	
end

function onServerTick(delta)
	
	if (not Modules.Game:isRunning() or Modules.Game:getMatchTimer() < 2) then
		return
	end
	
	for i, Player in ipairs(Players:GetPlayers()) do
		for i, Object in pairs(ObjectList:GetChildren()) do
			if (Object:isA("Part")) then

				local ObjectValues = getObjectValues(Player, Object)

				if (ObjectValues ~= nil) then
					
					Object.Particles.Enabled = ObjectValues.isActive
					
					if (ObjectValues.hasInteractor) then
						validateInteractor(Object, ObjectValues, Player.UserId)
						updateInstallation(Object, ObjectValues, delta)
					else
						spawnPrompt(Object, ObjectValues, Player)
						ObjectModule:setProgress(Object, 0)
					end
				end
			end	
		end
	end
end

function onMatchStart()
	for i, v: Part in pairs(ObjectList:GetChildren()) do
		if (not v:isA("Part")) then
			continue
		end
		
		v.Detection.Touched:Connect(function(Part)
			onDetectionTouched(v, Part)
		end)
		
	end
end

function onDetectionTouched(Object, Part)
	
	local Parent = Part.Parent.Name
	
	if (Players:FindFirstChild(Parent) ~= nil) then
		local Player = Players:FindFirstChild(Parent)
		local ObjectValues = getObjectValues(Player, Object)
		
		local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
		local Role = Modules.Game:getRole(MatchPlayer)
		
		if (Role == "Prey" or not ObjectValues.isActive) then
			return
		end
		
		Modules.Game:setAnimationAction(MatchPlayer, "Stun")
		Modules.Speed:addMultiplier(MatchPlayer, "Stun", 0, ObjectValues.Stuntime)
		task.wait(ObjectValues.Stuntime)
		Modules.Game:setAnimationAction(MatchPlayer, "Run")
		ObjectModule:setActive(Object, false)
		
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
						if (not ObjectValues.hasInteractor and not ObjectValues.isActive) then
							if (Modules.Game:getParts(MatchPlayer) < 1) then
								return
							end
							assignInteractor(Object, Player.UserId)
						end
					end
				else
					if (ObjectValues.Interactor == Player.UserId) then
						assignInteractor(Object, 0)
						releaseInteractor(ObjectValues.Interactor)
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
					if (not ObjectValues.hasInteractor and not ObjectValues.isActive) then
						if (Modules.Game:getParts(MatchPlayer) < 1) then
							return
						end
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
Modules.Events.Game.MatchStart.Event:Connect(onMatchStart)

