local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Speed = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Player"):WaitForChild("Speed"))
local StopAnimationEvent = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StopAnimationEvent")
local AnimationEvent = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AnimationEvent")

local Events = game.ServerStorage:WaitForChild("Events"):WaitForChild("Prey")
local Remotes = game.ReplicatedStorage:WaitForChild("Remotes")

local Gaps = workspace:WaitForChild("Map").Interactables.Gaps
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Actions = Modules.Actions
local ObjectModule = Modules.Gap

local RunningActions = {}

local this = {}

local ActionData = {
	RequiredAction = Actions.List.IDLE,
	RequiresAction = true,
	Role = "Prey",
	YOffset = 1.55
}

function this:performAction(PlayerID, Gap)
	
	local Player = Players:GetPlayerByUserId(PlayerID)
	local WSPlayer = workspace:WaitForChild(Player.Name)
	local RootPart = WSPlayer.HumanoidRootPart
	
	local MatchPlayer = game.ReplicatedStorage.Match.Players:WaitForChild(Players:GetPlayerByUserId(PlayerID).Name)
	local ActionSpeed = Modules.Game:getActionSpeed(MatchPlayer)
	
	local BaseTime = Modules.Setup.DefaultAttributes.Prey.Values.SlideTime
	local SlideTime = BaseTime - (BaseTime / 1 * (ActionSpeed - 1))
	SlideTime = math.clamp(SlideTime, 0, 100)
	
	local Distance = 30
	local Destination = Gap.End
	local Orientation = Gap.EndDirection
	
	local PlayerPosition = Modules.Game:getMovement(MatchPlayer).Position
	local StartPosition = Gap.Start.Position
	local EndPosition = Gap.End.Position
	local StartDistance = math.abs((PlayerPosition - StartPosition).Magnitude)
	local EndDistance = math.abs((PlayerPosition - EndPosition).Magnitude)
	
	if (StartDistance > EndDistance) then
		Destination = Vector3.new(StartPosition.X, PlayerPosition.Y - ActionData.YOffset, StartPosition.Z)
		Distance = EndDistance
	end
	
	if (StartDistance < EndDistance) then
		Destination = Vector3.new(EndPosition.X, PlayerPosition.Y - ActionData.YOffset, EndPosition.Z)
		Distance = StartDistance
	end
	
	local tweenInfo = TweenInfo.new(SlideTime, Enum.EasingStyle.Sine)
	local goal = {CFrame = CFrame.new(Destination, Orientation.CFrame.Position)}
	local tween = TweenService:Create(RootPart, tweenInfo, goal)
	
	RootPart.Anchored = true
	RootPart.CanCollide = false
	RootPart.CollisionGroup = "ActionPerform"
	Player.Character.Head.CollisionGroup = "ActionPerform"
	Player.Character.UpperTorso.CollisionGroup = "ActionPerform"
	Player.Character.LowerTorso.CollisionGroup = "ActionPerform"
	
	Modules.Game:setAnimationAction(MatchPlayer, "Slide")
	Speed:addMultiplier(MatchPlayer, "Slide", 0, 0)

	Gap:SetAttribute("Player", Player.Name)
	
	local Hunter = Modules.Game:getHunterID()
	local HunterPlayer = Players:GetPlayerByUserId(Hunter)
	local HunterDistance = Modules.Game:getHunterDistance(MatchPlayer)

	if (HunterDistance > 35) then
		Modules.AuraManager:createAlert(HunterPlayer, "Gaps", Gap.Name)
	end
	
	local TimeStamp = tick()
	
	local rx, ry, rz = CFrame.lookAt(PlayerPosition, Vector3.new(Destination.X, PlayerPosition.Y, Destination.Z)):ToOrientation()
	
	table.insert(RunningActions, TimeStamp)
	Remotes.UpdatePosition:InvokeClient(Player, "Tween", CFrame.new(Destination) * CFrame.Angles(0, ry, 0), SlideTime, Enum.EasingStyle.Sine, TimeStamp, Gap.Name)

end

function onActionComplete(Player, Timestamp, GapID)
	
	print(Player, Timestamp, GapID)
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local inChase = Modules.Game:inChase(MatchPlayer)
	local RootPart = Player.Character.PrimaryPart
	local Gap = Gaps[GapID]
	
	if (table.find(RunningActions, Timestamp) ~= nil) then
		table.remove(RunningActions, table.find(RunningActions, Timestamp))
		
		Speed:removeMultiplier(MatchPlayer, "Slide")
		Actions:setAction(Player.UserId, Actions.List.IDLE)

		RootPart.Anchored = false
		RootPart.CanCollide = true
		RootPart.CollisionGroup = "Player"
		Player.Character.Head.CollisionGroup = "Player"
		Player.Character.UpperTorso.CollisionGroup = "Player"
		Player.Character.LowerTorso.CollisionGroup = "Player"

		local isSprinting = Modules.Game:isSprinting(MatchPlayer)
		Modules.Game:setAnimationAction(MatchPlayer, if (isSprinting) then "Run" else "Walk")

		local Fuseboxes = workspace:WaitForChild("Map").Interactables["Fuseboxes"]
		local Fusebox = Fuseboxes[ObjectModule:getFusebox(Gap)]
		local Loads = Modules.Fusebox:getLoads(Fusebox)
		Modules.Fusebox:setLoads(Fusebox, Loads + 1)
		
		Events.onSlide:Fire(Player, Gap)

		wait(2.5)

		Gap:SetAttribute("Player", "Empty")
	end
end

Remotes.ActionComplete.OnServerEvent:Connect(onActionComplete)

function this:getRequiredActionID()
	return ActionData.RequiredAction
end

function this:getNeededRole()
	return ActionData.Role
end

function this:RequiresAction()
	return ActionData.RequiresAction
end

return this
