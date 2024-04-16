local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local onMobileInput = game.ServerStorage.Events:WaitForChild("onMobileInput")
local ServerTick = game.ServerStorage.Events.Game:WaitForChild("ServerTick")
local onInputClick = game.ServerStorage.Events:WaitForChild("onInputClick")

local Players = game:GetService("Players")
local Interaction_Distance = 5.5
local Minimum_Distance = 2.6
local Maximum_Angle = 1.45

local Gaps = workspace:WaitForChild("Map").Interactables.Gaps
local Interaction = Modules.Actions.Interactions.Gap
local ObjectModule = Modules.Gap

local InteractionCategory = "Actions"
local InteractionName = "Slide"

local DebugTable = {
	inDebug = workspace:GetAttribute("Debug"),
	Players = workspace:GetAttribute("DebugPlayers"),
	needHunter = workspace:GetAttribute("DebugNeedHunter")
}

function getDistancesOfGap(Player, Gap)

	local WSPlayer = workspace:WaitForChild(Player.Name)
	local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")

	local Occupant = Gap:GetAttribute("Player")
	local PlayerPosition = RootPart.CFrame.Position
	local PlayerRotation = RootPart.CFrame.LookVector

	local StartPosition = Gap.Start.Position
	local EndPosition = Gap.End.Position

	local PlayerPosition = RootPart.CFrame.Position
	local StartDistance = Modules.PlayerUtils:getVectorDistanceXZ(PlayerPosition, StartPosition)
	local EndDistance = Modules.PlayerUtils:getVectorDistanceXZ(PlayerPosition, EndPosition)

	if (Occupant == "Empty") then

		local Furthest = {30, 30}
		local Nearest = {30, 30}
		local Angle = 5
		local Destination = Gap.End
		local Orientation = Gap.EndDirection
		local YDistance = 0
		local isPowered = ObjectModule:isPowered(Gap)
		local Fusebox = ObjectModule:getFusebox(Gap)
		local hasInteractor = Modules.Extractor:hasInteractor(Gap)
		local Interactor = Modules.Extractor:getInteractor(Gap)

		if (StartDistance > EndDistance) then
			Destination = Gap.Start
			Nearest = EndDistance
			Furthest = StartDistance
			Orientation = Gap.StartDirection

			local Direction = CFrame.new(RootPart.CFrame.Position, Gap.Start.Position).LookVector
			Angle = (Direction - PlayerRotation).Magnitude
		end

		if (StartDistance < EndDistance) then
			Destination = Gap.End
			Nearest = StartDistance
			Furthest = EndDistance
			Orientation = Gap.EndDirection

			local Direction = CFrame.new(RootPart.CFrame.Position, Gap.End.Position).LookVector
			Angle = (Direction - PlayerRotation).Magnitude
		end
		
		YDistance = math.abs(Destination.Position.Y - PlayerPosition.Y)

		local Values = {
			["YDistance"] = YDistance,
			["StartDistance"] = StartDistance,
			["EndDistance"] = EndDistance,
			["StartPosition"] = StartPosition,
			["EndPosition"] = EndPosition,
			["Nearest"] = Nearest,
			["Furthest"] = Furthest,
			["Orientation"] = Orientation,
			["AngleDifference"] = Angle,
			["isPowered"] = isPowered,
			["Fusebox"] = Fusebox,
			["hasInteractor"] = hasInteractor,
			["Interactor"] = Interactor,
		}
		return Values
	end
end

function isInRange(ObjectValues)
	return (ObjectValues.Nearest <= Interaction_Distance and ObjectValues.Furthest >= Minimum_Distance and ObjectValues.AngleDifference <= Maximum_Angle and ObjectValues.YDistance <= Minimum_Distance * 2)
end

ServerTick.Event:Connect(function()
	
	if (not Modules.Game:isRunning()) then
		return
	end
	
	for i, Object in pairs(Gaps:GetChildren()) do
		for i, Player in ipairs(Players:GetPlayers()) do
			if (Object:isA("Part")) then
				
				local isHunter = Modules.Game:isHunter(Player.UserId)
				local ObjectValues = getDistancesOfGap(Player, Object)
				
				if (ObjectValues ~= nil and not isHunter) then
					
					local Fuseboxes = workspace:WaitForChild("Map").Interactables["Fuseboxes"]
					local Fusebox = Fuseboxes[ObjectValues.Fusebox]
					local FuseboxPowered = Modules.Fusebox:isActivated(Fusebox)

					local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
					local newTransparency = if (ObjectValues.isPowered) then 1 else 0

					ObjectModule:setPowered(Object, FuseboxPowered)
					Object.Blockade.Transparency = newTransparency
					
					if (isInRange(ObjectValues) and not Modules.Game:hasEffect(MatchPlayer, "Paralyzed")) then
						if (ObjectValues.isPowered) then
							Modules.Actions:setInteraction(Player.UserId, Interaction)
							Modules.Game:spawnPrompt(Player.UserId, InteractionCategory, InteractionName)
						end
					end
				end
			end	
		end
	end
end)

onInputClick.Event:Connect(function(Player, Key, Down)
	
	local MatchPlayer = game.ReplicatedStorage.Match.Players:WaitForChild(Player.Name)
	local Role = MatchPlayer:GetAttribute("Role")
	local Binds = Modules.BindStorage:get(Player.UserId)

	if (Binds and Role == "Prey") then

		local Interactions = {Binds.Controller[InteractionCategory], Binds.Keyboard[InteractionCategory]} 

		if (table.find(Interactions, Key.Value)) then
			AttemptInteraction(Player)
		end
	end
	
end)

onMobileInput.Event:Connect(function(Player, Action, Down)
	if (Action == Interaction) then
		AttemptInteraction(Player)
	end
end)

function AttemptInteraction(Player)
	
	for i, v in pairs(Gaps:GetChildren()) do 
		
		if (v:isA("Part")) then
			local ObjectValues = getDistancesOfGap(Player, v)
			local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
			
			if (ObjectValues ~= nil and Modules.Actions:getInteraction(Player.UserId) == Interaction and not Modules.Game:getEffect(MatchPlayer, "Paralyzed", "Active")) then
				if (isInRange(ObjectValues)) then
					if (ObjectValues.isPowered) then
						Modules.Actions:performAction(Player.UserId, Modules.Actions.List.SLIDE, true, v)
					end
				end
			end
		end
	end
end