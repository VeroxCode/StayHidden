local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local SendToGrave = game.ServerStorage.Events.Prey:WaitForChild("sendToGrave")
local onMobileInput = game.ServerStorage.Events:WaitForChild("onMobileInput")
local ServerTick = game.ServerStorage.Events.Game:WaitForChild("ServerTick")
local onMouseClick = game.ServerStorage.Events:WaitForChild("onMouseClick")
local onInputClick = game.ServerStorage.Events:WaitForChild("onInputClick")
local onEscape = game.ServerStorage.Events.Prey:WaitForChild("onEscape")
local onDeath = game.ServerStorage.Events.Prey:WaitForChild("onDeath")

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ACTIVATION_DISTANCE = 4.5

local ObjectList = workspace:WaitForChild("Map").Interactables.Exits
local ObjectModule = Modules.Exit
local Interaction = Modules.Actions.Interactions.Exit
local InteractionName = "Escape"
local InteractionCategory = "Interactions"

local DebugTable = {
	inDebug = workspace:GetAttribute("Debug"),
	Players = workspace:GetAttribute("DebugPlayers"),
	needHunter = workspace:GetAttribute("DebugNeedHunter")
}

local function getObjectValues(Player, Object)

	local WSPlayer = Modules.Game:getWorkspacePlayer(Player.UserId)
	local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")

	local Object = Object
	local PlayerPosition = RootPart.CFrame.Position
	local PlayerXZ = {PlayerPosition.X, PlayerPosition.Z}
	local ObjectPosition = Object.InteractionSpot.CFrame.Position
	local ObjectXZ = {ObjectPosition.X, ObjectPosition.Z}
	local DistanceXZ = Modules.PlayerUtils:getVectorDistanceXZ(PlayerPosition, ObjectPosition)

	local hasInteractor = ObjectModule:hasInteractor(Object)
	local Interactor = ObjectModule:getInteractor(Object)
	
	local InteractionTime = ObjectModule:getInteractionTime(Object)
	local OpeningTime = ObjectModule:getOpeningTime(Object)
	local isUsed = ObjectModule:isUsed(Object)

	local Values = {
		["DistanceXZ"] = DistanceXZ,
		["Interactor"] = Interactor,
		["hasInteractor"] = hasInteractor,
		["InteractionTime"] = InteractionTime,
		["OpeningTime"] = OpeningTime,
		["isUsed"] = isUsed
	}
	return Values

end

function validateInteractor(Object, ObjectValues, PlayerId)
	if (ObjectValues.DistanceXZ > ACTIVATION_DISTANCE + 2) then
		if (ObjectValues.Interactor == PlayerId) then
			local Interactor = Players:GetPlayerByUserId(ObjectValues.Interactor)
			Object:SetAttribute("Interactor", 0)
			Object:SetAttribute("InteractionTime", 0)

			task.wait(2)

			Modules.PlayerUtils:setTransparency(Interactor.Name, 0)
		end
	end
end

function manageTransparency(Object, ObjectValues)
	
	local Extractions = Modules.Game:getExtractionProgress()
	local MaxExtractions = Modules.Game:getMaxExtractions()
	
	Object.CanCollide = (Extractions >= MaxExtractions)
	
	if (Extractions < MaxExtractions) then
		
		local Framegoal = {Transparency = 1}
		local Areagoal = {Transparency = 1}
		
		local FrameTween = TweenService:Create(Object, TweenInfo.new(2), Framegoal)
		local AreaTween = TweenService:Create(Object.Area, TweenInfo.new(2), Areagoal)
		
		FrameTween:Play()
		AreaTween:Play()
		
	else
		if (ObjectValues.isUsed) then
			
			local Framegoal = {Transparency = 1}
			local Areagoal = {Transparency = 1}

			local FrameTween = TweenService:Create(Object, TweenInfo.new(2), Framegoal)
			local AreaTween = TweenService:Create(Object.Area, TweenInfo.new(2), Areagoal)

			FrameTween:Play()
			AreaTween:Play()
		else
			
			local Framegoal = {Transparency = 0}
			local Areagoal = {Transparency = 0.1}

			local FrameTween = TweenService:Create(Object, TweenInfo.new(2), Framegoal)
			local AreaTween = TweenService:Create(Object.Area, TweenInfo.new(2), Areagoal)

			FrameTween:Play()
			AreaTween:Play()
		end
	end
end

ServerTick.Event:Connect(function(delta)
	
	if (not Modules.Game:isRunning()) then
		return
	end

	for i, Player in ipairs(Players:GetPlayers()) do
		for count = 1, (#ObjectList:GetChildren() - 1) do
			
			local Object = ObjectList[count]			
			local isHunter = Modules.Game:isHunter(Player.UserId)
			local ObjectValues = getObjectValues(Player, Object)

			if (ObjectValues ~= nil and not isHunter) then
				
				manageTransparency(Object, ObjectValues)
				
				if (ObjectValues.hasInteractor) then
					local Interactor = Players:GetPlayerByUserId(ObjectValues.Interactor)
					validateInteractor(Object, ObjectValues, Player.UserId)
					
					local MatchPlayer = Modules.Game:getMatchPlayer(Interactor.UserId)
					local InteractionSpeed = Modules.Game:getInteractionSpeed(MatchPlayer)
					
					local newTime = ObjectValues.InteractionTime + (delta * InteractionSpeed)
					ObjectModule:setInteractionTime(Object, newTime)
					
					Modules.PlayerUtils:setRotation(Interactor.Character.PrimaryPart, Object.PrimaryPart.Position, .2)
					Modules.PlayerUtils:setPositionXZ(Interactor.Character.PrimaryPart, Object.InteractionSpot.CFrame.Position, .2)
					Modules.PlayerUtils:setTransparency(Interactor.Name, (1 / ObjectValues.OpeningTime) * newTime)
					
					if (newTime >= ObjectValues.OpeningTime) then
						onEscape:Fire(Interactor)
						ObjectModule:setInteractor(Object, 0)
						ObjectModule:setInteractionTime(Object, 0)
						ObjectModule:setUsed(Object, true)
					end
					
				end
				
				if (ObjectValues.DistanceXZ < ACTIVATION_DISTANCE) then
					if (not ObjectValues.isUsed and Modules.Game:canEscape() and not ObjectValues.hasInteractor) then
						Modules.Actions:setInteraction(Player.UserId, Interaction)
						Modules.Game:spawnPrompt(Player.UserId, InteractionCategory, InteractionName)
					end	
				end
			end	
		end
	end
end)

onInputClick.Event:Connect(function(Player, Key, Down)
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local isHunter = Modules.Game:isHunter(Player.UserId)

	if (not Modules.Game:isRunning()) then
		return
	end

	local Binds = Modules.BindStorage:get(Player.UserId)
	local Interactions = {Binds.Controller[InteractionCategory], Binds.Keyboard[InteractionCategory]}

	if (table.find(Interactions, Key.Value) and Down) then
		for count = 1, (#ObjectList:GetChildren() - 1) do

			local WSPlayer = Modules.Game:getWorkspacePlayer(Player.UserId)
			local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
			local MatchPlayerID = MatchPlayer:GetAttribute("ID")
			local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")

			local Object = ObjectList[count]
			local ObjectValues = getObjectValues(Player, Object)

			if (ObjectValues ~= nil) then
				if (ObjectValues.DistanceXZ < ACTIVATION_DISTANCE and Modules.Actions:getInteraction(MatchPlayerID) == Interaction) then
					if (not ObjectValues.hasInteractor) then
						Modules.Speed:addMultiplier(MatchPlayer, "Exit", 0, ObjectValues.OpeningTime + 2)
						Object:SetAttribute("Interactor", Player.UserId)
						Object:SetAttribute("InteractionTime", 0)
					end
				end
			end
		end
	end
end)

onMobileInput.Event:Connect(function(Player, Action, Down)
	if (Action == Interaction and Down) then
		for count = 1, (#ObjectList:GetChildren() - 1) do

			local WSPlayer = Modules.Game:getWorkspacePlayer(Player.UserId)
			local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
			local MatchPlayerID = MatchPlayer:GetAttribute("ID")
			local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")

			local Object = ObjectList[count]
			local ObjectValues = getObjectValues(Player, Object)

			if (ObjectValues ~= nil) then
				if (ObjectValues.DistanceXZ < ACTIVATION_DISTANCE and Modules.Actions:getInteraction(MatchPlayerID) == Interaction) then
					if (not ObjectValues.hasInteractor) then
						Modules.Speed:addMultiplier(MatchPlayer, "Exit", 0, ObjectValues.OpeningTime + 2)
						Object:SetAttribute("Interactor", Player.UserId)
						Object:SetAttribute("InteractionTime", 0)
					end
				end
			end
		end
	end
end)