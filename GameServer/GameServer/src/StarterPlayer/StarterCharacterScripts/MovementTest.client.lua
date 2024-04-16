local Gameplay = require(game.ReplicatedStorage.Prefabs["Client Functions"])

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Remotes = game.ReplicatedStorage.Remotes

local RotationTween = nil
local SpeedTween = nil
local Velocity = Vector2.new(0, 0)
local PreviousPos: Vector3 = Vector3.new(0,0,0)

local LastSpeed = 0
local LastTime = 0
local airTimer = 0
local staggerTimer = 0
local rotateTimer = 0

local onGround = true
local animsLoaded = false
local playedStagger = false
local rotatebody = true

local tweens = {}
local AnimationList = {}

local FallAnim = "rbxassetid://16509795190"
local StaggerAnim = "rbxassetid://16509808756"

local Player = game.Players.LocalPlayer

local Keys = {
	[Enum.KeyCode.W.Value] = false,
	[Enum.KeyCode.S.Value] = false,
	[Enum.KeyCode.A.Value] = false,
	[Enum.KeyCode.D.Value] = false
}

function preloadAnims()
	
	if (animsLoaded) then
		return
	end
	
	repeat task.wait()
		
	until Player.Character
	
	local Anims = {
		["Fall"] = FallAnim, 
		["Stagger"] = StaggerAnim
	}
	
	local Animator = Player.Character.Humanoid.Animator
	
	for i, v in pairs(Anims) do
		local Anim = Instance.new("Animation")
		Anim.Name = i
		Anim.AnimationId = v
		Anim.Parent = script

		AnimationList[i] = Animator:LoadAnimation(Anim)
	end
	
	animsLoaded = true
	
end
preloadAnims()

function renderstepped(delta)
	
	if (not Gameplay:isRunning() or not animsLoaded) then
		PreviousPos = Player.Character.PrimaryPart.CFrame.Position
		return
	end
	
	if (Player.Character == nil) then
		return
	end
	
	local MatchPlayer = Gameplay:getMatchPlayer(Player.UserId)

	local Camera = game.Workspace.CurrentCamera
	local PrimaryPart = Player.Character.PrimaryPart
	local Position: Vector3 = PrimaryPart.CFrame.Position
	local x, y, z = PrimaryPart.CFrame:ToOrientation()
	local Rotation = Vector3.new(x, y, z)

	local Role = Gameplay:getRole(MatchPlayer)
	local Action = MatchPlayer:GetAttribute("Action")
	local Speed = MatchPlayer.Values:GetAttribute("Speed")
	local SpeedMultiplier = MatchPlayer.Values:GetAttribute("SpeedMultiplier")
	
	move()
	performGroundScan()
		
		local movespeed = (Speed * SpeedMultiplier)
		local gravity = 0
		
		local Falling: AnimationTrack = AnimationList.Fall
		local Stagger: AnimationTrack = AnimationList.Stagger
		
		Falling.Priority = Enum.AnimationPriority.Action3
		Stagger.Priority = Enum.AnimationPriority.Action4
		
		Player.Character:SetAttribute("Stagger", (staggerTimer >= 0))
		Player.Character:SetAttribute("Falling", not onGround)
		
		if (onGround) then
			Falling:Stop()
			
			if (staggerTimer >= 0) then
				if (Gameplay:getMatchTimer() >= 10) then
					Player.Character.Humanoid.WalkSpeed = 0
				else
					staggerTimer = 0
				end
			elseif (Player.Character.Humanoid.WalkSpeed <= 0) then
				Player.Character.Humanoid.WalkSpeed = movespeed
			end
			
			if (staggerTimer >= 0 or Stagger.IsPlaying) then
				if (not playedStagger and Role ~= "Hunter") then
					playedStagger = true
					Stagger.TimePosition = 0.0
					Stagger:Play(0, 2, if (Role == "Prey") then 0.45 else 0.75)
				end
			end
			
			airTimer = 0
			staggerTimer -= delta
		else
			if (not Stagger.IsPlaying) then
				playedStagger = false
			end
			
			airTimer += delta
			Stagger:Stop()
			
			if (not Falling.IsPlaying and airTimer >= 0.15) then
				Falling:Play()
				Falling.TimePosition = 0.8				
			end
		end
		
	Player.Character:SetAttribute("Moving", isMoving())
	--doBodyRotation(Role)
	
	onGround = false
	
	game.ReplicatedStorage.Remotes.MovementUpdate:FireServer(PrimaryPart.CFrame)
end

function move()
	
	local MatchPlayer = Gameplay:getMatchPlayer(Player.UserId)
	local Role = Gameplay:getRole(MatchPlayer)
	
	if (Role == "Hunter" or MatchPlayer:GetAttribute("Action") ~= 1) then
		Player.Character.ControllerManager.RootPart = nil
		return
	end
	
	Player.Character.ControllerManager.RootPart = Player.Character.PrimaryPart
	
	local Camera = game.Workspace.CurrentCamera
	local PrimaryPart = Player.Character.PrimaryPart
	local Position = PrimaryPart.CFrame.Position
	local rx, ry, rz = PrimaryPart.CFrame.Rotation:ToEulerAnglesXYZ()

	local facedirection = Vector3.new(0, 0, 0)
	local movedirection = Vector3.new(0, 0, 0)

	local forward = (Camera.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
	local right = (Camera.CFrame.RightVector * Vector3.new(1, 0, 1)).Unit
	
	local body_forward = (PrimaryPart.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
	local body_right = (PrimaryPart.CFrame.RightVector * Vector3.new(1, 0, 1)).Unit

	if (Keys[Enum.KeyCode.W.Value]) then
		facedirection = facedirection + forward
		movedirection = movedirection - body_forward
	end

	if (Keys[Enum.KeyCode.S.Value]) then
		facedirection = facedirection - forward
		movedirection = movedirection + body_forward
	end

	if (Keys[Enum.KeyCode.D.Value]) then
		facedirection = facedirection + right
		movedirection = movedirection - body_right
	end

	if (Keys[Enum.KeyCode.A.Value]) then
		facedirection = facedirection - right
		movedirection = movedirection + body_right
	end

	if (facedirection.Magnitude) > 0 then
		Player.Character.ControllerManager.FacingDirection = facedirection
		Player.Character.ControllerManager.MovingDirection = movedirection
	end
end

function isMoving()
	
	if (math.abs(Player.Character.Humanoid.MoveDirection.Z) > 0) then
		return true
	end
	
	if (math.abs(Player.Character.Humanoid.MoveDirection.X) > 0) then
		return true
	end
	
	return false
end

function doMovement(MoveDirection: Vector3, MoveSpeed, Gravity, Delta)
	
	local Player = game.Players.LocalPlayer
	local Character = Player.Character
	
	Character:SetAttribute("Moving", (MoveSpeed > 0 and MoveDirection.Magnitude > 0))
	
end

function doRotation(Role, direction)
	
	if (Role == "Hunter" or Gameplay:getMatchPlayer(Player.UserId):GetAttribute("Action") ~= 1) then
		return
	end
	
	local PrimaryPart = Player.Character.PrimaryPart
	--local rx, ry, rz = CFrame.new(PrimaryPart.CFrame.Position, PrimaryPart.CFrame.Position  + direction).Rotation:ToOrientation()
	local Destination = CFrame.new(PrimaryPart.CFrame.Position, PrimaryPart.CFrame.Position  + direction) --PrimaryPart.CFrame * CFrame.Angles(0, math.deg(ry), 0)
	
	local tween = TweenService:Create(PrimaryPart, TweenInfo.new(0.5), {CFrame = Destination})
	tween:Play()
	
end

function doBodyRotation(Role)
	
	if (Role == "Hunter" or Gameplay:getMatchPlayer(Player.UserId):GetAttribute("Action") ~= 1 or not rotatebody) then
		return
	end
	
	rotateTimer += 1
	
	if (rotateTimer < 30) then
		--return
	end
	
	rotateTimer = 0

	local Camera = game.Workspace.CurrentCamera
	local Character = Player.Character
	local PrimaryPart = Player.Character.PrimaryPart

	local Head = Character.Head
	local UpperTorso = Character.UpperTorso
	
	local function Clamp(Value)
		return math.clamp(Value, -math.pi / 4, math.pi / 4) --Increase/decrease '4' for decreased/increased range of motion respectively.
	end
	
	local Direction = PrimaryPart.CFrame:ToObjectSpace(Camera.CFrame).LookVector
	local math = CFrame.new(0, 0 ,0) * CFrame.Angles(0, -math.asin(Direction.X) / 2, 0) * CFrame.Angles(0, 0, 0)
	UpperTorso.Waist.C0 = math

end

function performGroundScan()
	
	local MatchPlayer = game.ReplicatedStorage:WaitForChild("Match"):WaitForChild("Players"):WaitForChild(Player.Name)

	if (MatchPlayer == nil or not Gameplay:isRunning()) then
		return
	end
	
	local Role = Gameplay:getRole(MatchPlayer)
	local PrimaryPart = Player.Character.PrimaryPart
	local Position: Vector3 = PrimaryPart.CFrame.Position
	
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {Player.Character}
	
	local groundCast = workspace:Raycast(Position, -PrimaryPart.CFrame.UpVector * 6.5, params)
	
	local staggerReset = if (Role == "Prey") then 0.75 else 0.25

	if (groundCast and Player.Character.Humanoid.FloorMaterial ~= Enum.Material.Air) then
		onGround = true
	else
		if (airTimer >= 0.25) then
			staggerTimer = staggerReset
		end
	end
	
	PreviousPos = Position
	
end

game.ReplicatedStorage.Remotes.MovementUpdate.OnClientEvent:Connect(function(UpdatePlayer: Player, Movement: CFrame)
	if (UpdatePlayer.Name == game.Players.LocalPlayer.Name) then
		return
	end
	
	UpdatePlayer.Character.PrimaryPart.CFrame = Movement
	
end)

function oninputbegin(inputobject: InputObject)

	local keycode = inputobject.KeyCode

	if (Keys[keycode.Value] ~= nil) then
		Keys[keycode.Value] = true
	end

end

function oninputend(inputobject: InputObject)

	local keycode = inputobject.KeyCode

	if (Keys[keycode.Value] ~= nil) then
		Keys[keycode.Value] = false
	end

end

function forcePosition(Type, ...)
	
	local args = {...}
	
	if (Type == "Tween") then
		
		local tween: Tween = TweenService:Create(Player.Character.PrimaryPart, TweenInfo.new(args[2], args[3]), {CFrame = args[1]})
		tween:Play()
		
		tween.Completed:Connect(function()
			Remotes.ActionComplete:FireServer(args[4], args[5])
		end)
	end
	
	if (Type == "Force") then
		PreviousPos = args[1]
		Player.Character.PrimaryPart.CFrame = CFrame.new(args[1])
	end
	
end

game["Run Service"]:BindToRenderStep("move", Enum.RenderPriority.Character.Value + 1, renderstepped)
UIS.InputBegan:Connect(oninputbegin)
UIS.InputEnded:Connect(oninputend)
Remotes.UpdatePosition.OnClientInvoke = forcePosition