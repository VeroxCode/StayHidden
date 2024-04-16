local AssignCamera = game.ReplicatedStorage.Remotes:WaitForChild("AssignCamera")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character
local Backpack = LocalPlayer:WaitForChild("Backpack")
local ClientEvents = Backpack:WaitForChild("Events")
local Camera = workspace.Camera

local Humanoid = Character:WaitForChild("Humanoid")

local Assets = game.ReplicatedStorage.Assets
local Remotes = game.ReplicatedStorage.Remotes
local AttackRemote = Remotes.AttackRemote

local AnimationList = {}

local Prefix = "rbxassetid://"
local Track : AnimationTrack = nil

local NonLoopable = {"Slide", "Attack", "Recovery", "TrapSet", "Scream", "Destroy", "Stun"}
local ShowModel = {"Scream", "Destroy", "TrapSet"}
local canUpdate = false
local inAnimation = false
local weaponShown = false
local modelShown = false
local lastAttack = os.time()
local fov = 80

local lastUpdate = tick()

function createViewmodel()
	
	if (Camera:FindFirstChild("ViewModel")) then
		Camera.ViewModel:Destroy()
	end
	
	Character.Archivable = true
	local ViewModel : Part = Character:Clone()
	ViewModel.Name = "ViewModel"
	ViewModel.Parent = Camera
	Character.Archivable = false
	
	ViewModel.Head.Anchored = true
	ViewModel.Head.Transparency = 1
	ViewModel.PrimaryPart = ViewModel.Head
	ViewModel:SetPrimaryPartCFrame(Character.Head.CFrame)
	
	if (not workspace:GetAttribute("Debug")) then
		local Description : HumanoidDescription = Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId)
		Description.Head = 0
		Description.Torso = 0
		Description.RightArm = 0
		Description.RightLeg = 0
		Description.LeftArm = 0
		Description.LeftLeg = 0
		ViewModel.Humanoid:ApplyDescription(Description)
	end
	
	for i, v in pairs(ViewModel:GetDescendants()) do
		if (v:isA("BasePart") or v:isA("MeshPart")) then
			v.CanCollide = false
			v.CanQuery = false
			v.CanTouch = false
			--v.Anchored = true
			v.CollisionGroup = "NoCollision"
		end
		
		if (v:isA("Weld") and string.find(v.Parent.Name, "Hand") == nil and string.find(v.Parent.Name, "Weapon") == nil) then
			v:Destroy()
		end
		
	end

	for i, v in pairs(Humanoid:GetChildren()) do
		if (string.find(v.Name, "Scale")) then
			v.Value = 1.6
		end
		Humanoid.HeadScale.Value = 1.7
		Humanoid.BodyDepthScale.Value = 1.5
	end
	
	initialize()
	canUpdate = true
	
	showModel()
	showWeapon()
	
end

function onRender()
	
	if (not canUpdate) then
		return
	end
	
	local Camera = workspace.CurrentCamera
	local CameraCFrame = Camera.CFrame
	local CameraPos = CameraCFrame.Position
	local CameraRot = CameraCFrame.Rotation
	local VMCFrame = CameraCFrame * CFrame.new(0, -1, 0.25)

	local ViewModel = Camera.ViewModel
	local RootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
	local VMRootPart = ViewModel.HumanoidRootPart
	local x, y, z = workspace.CurrentCamera.CFrame.Rotation:ToEulerAnglesYXZ()
	
	ViewModel.PrimaryPart.CFrame = VMCFrame
	runAnimations()
	
end

local AnimationIDs = {
	["HunterWalk"] = 14422114454,
	["HunterRun"] = 14422114454,
	["HunterIdle"] = 14422114454,
	["HunterAttack"] = 14421513833,
	["HunterRecovery"] = 14421529100,
	["HunterTrapSet"] = 14421557178,
	["HunterScream"] = 14732689197,
	["HunterDestroy"] = 14884894011,
	["HunterStun"] = 17066881041,
}

local AnimationStats = {
	["HunterWalk"] = {0.5, 2.2, Enum.AnimationPriority.Movement},
	["HunterRun"] = {0.5, 2.2, Enum.AnimationPriority.Movement},
	["HunterIdle"] = {0.1, 0.0, Enum.AnimationPriority.Movement},
	["HunterAttack"] = {0.1, 1.0, Enum.AnimationPriority.Action},
	["HunterRecovery"] = {0.1, 0.5, Enum.AnimationPriority.Action},
	["HunterTrapSet"] = {0.1, 1.8, Enum.AnimationPriority.Action},
	["HunterScream"] = {0.5, 1.1, Enum.AnimationPriority.Action},
	["HunterDestroy"] = {0.1, 1.0, Enum.AnimationPriority.Action},
	["HunterStun"] = {0.1, 0.25, Enum.AnimationPriority.Action},
}

function runAnimations()

	local MatchPlayer = game.ReplicatedStorage:WaitForChild("Match"):WaitForChild("Players"):WaitForChild(LocalPlayer.Name)
	local AnimationAction = MatchPlayer:GetAttribute("AnimationAction")
	local Moving = LocalPlayer.Character:GetAttribute("Moving")
	local WalkSpeed = Humanoid.WalkSpeed

	local Match = game.ReplicatedStorage:WaitForChild("Match")
	local MatchPlayer = Match:WaitForChild("Players"):WaitForChild(LocalPlayer.Name)
	local isSprinting = MatchPlayer:GetAttribute("isSprinting")
	local Role = MatchPlayer:GetAttribute("Role")
	local AnimationString = Role .. AnimationAction
	
	if (table.find(ShowModel, AnimationAction)) then
		
		hideModel()
		hideWeapon()
		Camera.CameraSubject = LocalPlayer.Character.Head
		
		local CameraCFrame = Camera.CFrame
		local CameraPos = CameraCFrame.Position
		local CameraRot = CameraCFrame.Rotation
		local VMCFrame = Character.PrimaryPart.CFrame * CFrame.new(0, 3, 6.75)
		inAnimation = true
		
		Camera.CFrame = VMCFrame
	else
		Camera.CameraSubject = LocalPlayer.Character.Humanoid
		inAnimation = false
		showModel()
		showWeapon()
	end

	if (Track == nil or AnimationList[AnimationString] == nil) then
		Track = AnimationList[AnimationString]
		AnimationString = Role .. "Run"
		return
	end

	if (AnimationAction == "Run" or AnimationAction == "Walk" or AnimationAction == "Idle") then
		
		if (not Moving) then
			AnimationString = Role .. "Idle"
			AnimationAction = "Idle"
		else
			AnimationString = Role .. "Run"
			AnimationAction = "Run"
		end
	end

	if (Track == AnimationList[AnimationString]) then

		if (table.find(NonLoopable, AnimationAction)) then
			return
		end

		if ((AnimationAction == "Run" or AnimationAction == "Walk" or AnimationAction == "Idle") and Track.IsPlaying) then
			return
		end
	else
		Track = AnimationList[AnimationString]
	end

	if (AnimationString == nil) then
		AnimationString = "PreyWalk"
		return
	end

	stopAnimation()
	Track.Priority = AnimationStats[AnimationString][3]
	Track:Play(AnimationStats[AnimationString][1], 1, AnimationStats[AnimationString][2])
end

function stopAnimation()
	if (Track == nil) then
		return
	end
	
	local ViewModel = Camera:WaitForChild("ViewModel")
	local VMHumanoid = ViewModel:WaitForChild("Humanoid")
	local Animator : Animator = VMHumanoid:WaitForChild("Animator")

	for i, v in pairs(Animator:GetPlayingAnimationTracks()) do
		if (v.Name == "HunterAttack") then continue end
		v:Stop()
	end

	Track.Looped = false
	Track:AdjustWeight(0.0001)
	Track:Stop(0.2)
end

function playAttack()
	AnimationList["HunterAttack"].Priority = Enum.AnimationPriority.Action4
	AnimationList["HunterAttack"]:Play()
end

function initialize()
	
	local ViewModel = Camera:WaitForChild("ViewModel")
	local VMHumanoid = ViewModel:WaitForChild("Humanoid")
	local Animator : Animator = VMHumanoid:WaitForChild("Animator")
	
	local Profile = Remotes.RequestData:InvokeServer("Profile")
	fov = Profile.Account.Settings["First-Person FoV"] or fov
	fov = math.clamp(fov, 80, 100)
	
	for i, v in pairs(AnimationIDs) do
		local Anim = Instance.new("Animation")
		Anim.Name = i
		Anim.AnimationId = Prefix .. v
		Anim.Parent = script

		AnimationList[i] = Animator:LoadAnimation(Anim)
	end

	Track = AnimationList["PreyWalk"]
	
	AnimationList["HunterAttack"].Ended:Connect(function()
		AttackRemote:FireServer("Recovery")
	end)
	
	AnimationList["HunterAttack"].KeyframeReached:Connect(function(Keyframe)

		local Match = game.ReplicatedStorage:WaitForChild("Match")
		local MatchPlayer = Match:WaitForChild("Players"):WaitForChild(LocalPlayer.Name)

		print(Keyframe)

		if (Keyframe == "Begin") then
			lastAttack = os.time()
			AttackRemote:FireServer("Begin")
		end

		if (Keyframe == "Recovery") then
			AttackRemote:FireServer("Recovery")
		end
	end)

end

function hideWeapon()

	local ViewModel = Camera:WaitForChild("ViewModel")
	local Weapon = ViewModel:WaitForChild("RightHand"):FindFirstChild("Weapon")

	if (Weapon == nil or not weaponShown) then
		return
	end

	for i, v in pairs(Weapon:GetChildren()) do
		if (v:isA("BasePart")  or v:isA("MeshPart")) then
			v.CastShadow = false
			v.CanCollide = false
			v.CollisionGroup = "NoCollision"

			if (not string.find(v.Name, "Weapon")) then
				v.Transparency = 1
			end
		else
			if (v:isA("Decal") or v:isA("Accessory")) then
				v:Destroy()
			end
		end
	end

	weaponShown = false

end

function showWeapon()

	local ViewModel = Camera:WaitForChild("ViewModel")
	local Weapon = ViewModel:WaitForChild("RightHand"):FindFirstChild("Weapon")

	if (Weapon == nil or weaponShown) then
		return
	end

	for i, v in pairs(Weapon:GetChildren()) do
		if (v:isA("BasePart") or v:isA("MeshPart")) then
			v.CastShadow = false
			v.CanCollide = false
			v.CollisionGroup = "NoCollision"

			if (not string.find(v.Name, "VMWeapon")) then
				v.Transparency = 0
			end
		else
			if (v:isA("Decal") or v:isA("Accessory")) then
				v:Destroy()
			end
		end
	end

	weaponShown = true

end

function hideModel(hideWeapon: boolean)

	hideWeapon = hideWeapon or false
	local ViewModel = Camera:WaitForChild("ViewModel")

	if (not modelShown) then
		return
	end

	for i, v in pairs(ViewModel:GetDescendants()) do
		if (v:isA("BasePart") or v:isA("MeshPart")) then
			v.CastShadow = false
			v.CanCollide = false
			v.CollisionGroup = "NoCollision"

			if (not hideWeapon) then
				if (not string.find(v.Name, "Weapon")) then
					v.Transparency = 1
				end
			else
				v.Transparency = 1
			end
		else
			if (v:isA("Decal") or v:isA("Accessory")) then
				v:Destroy()
			end
		end
	end

	modelShown = false

end

function showModel()

	local ViewModel = Camera:WaitForChild("ViewModel")

	if (modelShown) then
		return
	end

	for i, v in pairs(ViewModel:GetDescendants()) do
		if (v:isA("BasePart") and v.Name ~= "HumanoidRootPart") then
			v.CastShadow = false
			v.CanCollide = false
			v.CollisionGroup = "NoCollision"

			if (isVisiblePart(v) and v.Name ~= "Weapon") then
				v.Transparency = 0
			end
		else
			if (v:isA("Decal") or v:isA("Accessory")) then
				v:Destroy()
			end
		end
	end

	modelShown = true

end

function isVisiblePart(Part)
	
	local allowed = {"RightUpperArm", "RightLowerArm", "RightHand", "Weapon"}
	
	if (table.find(allowed, Part.Name)) then
		return true
	end
	
	for count = 1, #allowed do
		if (string.find(Part.Name, allowed[count])) then
			return true
		end
	end
	
	return false
	
end

AssignCamera.OnClientEvent:Connect(function(Mode, Weapon)
	
	if (Mode == "Lock") then
		Camera.CameraType = Enum.CameraType.Scriptable
	end
		
	if (Mode == "Unlock") then
		Camera.CameraType = Enum.CameraType.Custom
	end	
	
	if (Mode == "Create") then
		createViewmodel()
	end
	
	--[[if (Mode == "Weapon") then
		
		local ViewModel = Camera:WaitForChild("ViewModel")
		local WeaponClone = Assets.Models.Hunter:WaitForChild(Weapon .. "_Weapon"):Clone()
		WeaponClone.Name = "VMWeapon"
		WeaponClone.Parent = ViewModel.RightHand

		local WeaponOffsetY = WeaponClone.Size.Y
		WeaponOffsetY = 1.5 / 3 * WeaponOffsetY
		
		WeaponClone.Transparency = 1

		local weld = Instance.new("Weld")
		weld.Part0 = ViewModel.RightHand
		weld.Part1 = WeaponClone
		weld.Parent = WeaponClone
		weld.C1 = CFrame.new(Vector3.new(0, -WeaponOffsetY, 0), Vector3.new(0, 90, 0))
	end]]
	
end)

ClientEvents.Attack.Event:Connect(playAttack)
game["Run Service"].RenderStepped:Connect(onRender)