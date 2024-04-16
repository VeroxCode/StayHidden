local TweenService = game:GetService("TweenService")

local this = {}

this.exceptions = {"Hitbox", "AttackTrace", "HumanoidRootPart", "CollisionBox"}

function this:setTransparency(PlayerName, Value)
	local PlayerCharacter = workspace:WaitForChild(PlayerName)
	for i, v in pairs(PlayerCharacter:GetDescendants()) do
		if ((v:isA("BasePart") or v:isA("Decal") or v:isA("Texture")) and not table.find(this.exceptions, v.Name) and v.Name ~= "CollisionBox") then
			local goal = {Transparency = Value}
			local tween = TweenService:Create(v, TweenInfo.new(0.2), goal)
			tween:Play()
		end
	end
end

function this:setCollisionGroup(Player, Group)
	local PlayerCharacter = workspace:WaitForChild(Player.Name)
	for i, v in pairs(PlayerCharacter:GetDescendants()) do
		if (v:isA("BasePart")) then
			v.CollisionGroup = Group
		end
	end
end

function this:setCFrame(RootPart, Position, Rotation, TweenTime)
	local tweenInfo = TweenInfo.new(TweenTime)
	local goal = {CFrame = CFrame.new(Position, Rotation)}
	local tween = TweenService:Create(RootPart, tweenInfo, goal)
	
	tween:Play()
end

function this:setPosition(RootPart, Position : Vector3, TweenTime)
	
	local diffX = RootPart.CFrame.Position.X - Position.X
	local diffY = RootPart.CFrame.Position.Y - Position.Y
	local diffZ = RootPart.CFrame.Position.Z - Position.Z

	local tweenInfo = TweenInfo.new(TweenTime)
	local goal = {CFrame = RootPart.CFrame * CFrame.new(Vector3.new(diffX, diffY, diffZ))}
	local tween = TweenService:Create(RootPart, tweenInfo, goal)

	tween:Play()
end

function this:setPositionXZ(RootPart, Position : Vector3)
	RootPart.CFrame = CFrame.new(Vector3.new(Position.X, RootPart.CFrame.Position.Y, Position.Z))
end

function this:setRotation(RootPart, Rotation, TweenTime)
	local tweenInfo = TweenInfo.new(TweenTime)
	local goal = {CFrame = CFrame.lookAt(RootPart.Position, Vector3.new(Rotation.X, RootPart.Position.Y, Rotation.Z), RootPart.Position * Vector3.new(0, 1, 0))}
	local tween = TweenService:Create(RootPart, tweenInfo, goal)

	tween:Play()
end

function this:getRotationDistance(Rotation : Vector3, RootPart1 : Vector3, RootPart2 : Vector3)
	local Direction = CFrame.new(RootPart1, RootPart2).LookVector
	return (Direction - Rotation).Magnitude
end

function this:getDistanceXZ(RootPart1 : Part, RootPart2 : Part)
	local Vec1 = Vector3.new(RootPart1.CFrame.Position.X, 0, RootPart1.CFrame.Position.Z)
	local Vec2 = Vector3.new(RootPart2.CFrame.Position.X, 0, RootPart2.CFrame.Position.Z)
	
	return math.abs((Vec1 - Vec2).Magnitude)
end

function this:getVectorDistanceXZ(RootPart1 : Vector3, RootPart2 : Vector3)
	local Vec1 = Vector3.new(RootPart1.X, 0, RootPart1.Z)
	local Vec2 = Vector3.new(RootPart2.X, 0, RootPart2.Z)

	return math.abs((Vec1 - Vec2).Magnitude)
end

function this:getDistanceY(RootPart1 : Part, RootPart2 : Part)
	return math.abs(RootPart1.CFrame.Position.Y - RootPart2.CFrame.Position.Y)
end

function this:getVectorDistanceY(RootPart1 : Vector3, RootPart2 : Vector3)
	return math.abs(RootPart1.Y - RootPart2.Y)
end


return this
