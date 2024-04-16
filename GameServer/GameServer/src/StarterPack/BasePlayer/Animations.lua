local this = {}

local LocalPlayer = game.Players.LocalPlayer
local Assets = game.ReplicatedStorage.Assets
local Remotes = game.ReplicatedStorage.Remotes

local Backpack = LocalPlayer:WaitForChild("Backpack")
local ClientEvents = Backpack.Events
local AnimationEvent = Remotes.AnimationEvent
local AttackRemote = Remotes.AttackRemote

local Humanoid = LocalPlayer.Character:WaitForChild("Humanoid")
local Animator : Animator = Humanoid:WaitForChild("Animator")

local AnimationList = {}

local Prefix = "rbxassetid://"
local Track : AnimationTrack = nil
local KeyframeEvent

local lastAttack = os.time()

local Loopable = {"Idle", "Walk", "Run", "ChestSearch", "IdleInjured", "WalkInjured", "RunInjured", "WalkCrouch", "IdleCrouch", "RunCrouch", "Repair", "Heal", "Crawl"}
local NonLoopable = {"Slide", "Attack", "Recovery", "TrapSet", "Injured", "Death", "Insert", "Scream", "Destroy", "Stun"}

local AnimationIDs = {
	["PreyWalk"] =  13954468130,
	["PreyWalkInjured"] =  14732600453,
	["PreyWalkCrouch"] =  14779627270,
	["PreyIdle"] =  14422133000,
	["PreyIdleInjured"] = 14715664702,
	["PreyIdleCrouch"] = 14779618967,
	["PreyRun"] =  14715227954,
	["PreyRunInjured"] =  14715666656,
	["PreyRunCrouch"] =  14779627270,
	["PreySlide"] = 13953145404,
	["PreyInjured"] = 14519394385,
	["PreyDeath"] = 14519386533,
	["PreyChestSearch"] = 14574794729,
	["PreyInsert"] = 14707458678,
	["PreyPray"] = 14707583579,
	["PreyRepair"] = 14884897574,
	["PreyHeal"] = 15369854786,
	["PreyCrawl"] = 16712676900,
	
	["HunterWalk"] = 14422273388,
	["HunterRun"] = 14422273388,
	["HunterIdle"] = 14421536892,
	["HunterAttack"] = 14421474304,
	["HunterRecovery"] = 14421549572,
	["HunterTrapSet"] = 14421558806,
	["HunterScream"] = 14732689197,
	["HunterDestroy"] = 14884894011,
	["HunterStun"] = 17066881041,
}

local AnimationStats = {
	["PreyWalk"] = {0.5, 1.1, Enum.AnimationPriority.Movement},
	["PreyWalkInjured"] = {0.5, 0.8, Enum.AnimationPriority.Movement},
	["PreyWalkCrouch"] = {0.5, 1, Enum.AnimationPriority.Movement},
	["PreyIdle"] = {1, 1, Enum.AnimationPriority.Movement},
	["PreyIdleInjured"] = {1, 1, Enum.AnimationPriority.Movement},
	["PreyIdleCrouch"] = {1, 1, Enum.AnimationPriority.Movement},
	["PreyRun"] = {0.5, 1.3, Enum.AnimationPriority.Action},
	["PreyRunInjured"] = {0.5, 1.4, Enum.AnimationPriority.Action},
	["PreyRunCrouch"] = {0.5, 1.4, Enum.AnimationPriority.Action},
	["PreySlide"] = {0, 4.5, Enum.AnimationPriority.Action2},
	["PreyInjured"] = {0, 1, Enum.AnimationPriority.Action2},
	["PreyDeath"] = {0, 1, Enum.AnimationPriority.Action2},
	["PreyChestSearch"] = {.5, 1, Enum.AnimationPriority.Action2},
	["PreyInsert"] = {0.5, .35, Enum.AnimationPriority.Action2},
	["PreyPray"] = {0.5, 1, Enum.AnimationPriority.Action2},
	["PreyRepair"] = {0.1, 1, Enum.AnimationPriority.Action2},
	["PreyHeal"] = {0.1, 0.85, Enum.AnimationPriority.Action2},
	["PreyCrawl"] = {0, 1, Enum.AnimationPriority.Action3},
	
	["HunterWalk"] = {0.5, 1.5, Enum.AnimationPriority.Movement},
	["HunterRun"] = {0.5, 1.5, Enum.AnimationPriority.Movement},
	["HunterIdle"] = {1, 1.0, Enum.AnimationPriority.Movement},
	["HunterAttack"] = {0.1, 1.0, Enum.AnimationPriority.Action},
	["HunterRecovery"] = {0.1, 0.5, Enum.AnimationPriority.Action},
	["HunterTrapSet"] = {0.1, 1.8, Enum.AnimationPriority.Action},
	["HunterScream"] = {0.5, 1.6, Enum.AnimationPriority.Action},
	["HunterDestroy"] = {0.1, 1.0, Enum.AnimationPriority.Action},
	["HunterStun"] = {0.1, 0.25, Enum.AnimationPriority.Action},
}

function this:runAnimations()
	
	local MatchPlayer = game.ReplicatedStorage:WaitForChild("Match"):WaitForChild("Players"):WaitForChild(LocalPlayer.Name)
	local AnimationAction = MatchPlayer:GetAttribute("AnimationAction")
	local Moving = LocalPlayer.Character:GetAttribute("Moving") --math.abs(Vector2.new(Humanoid.MoveDirection.X + Humanoid.MoveDirection.Z).Magnitude)
	local WalkSpeed = Humanoid.WalkSpeed
	
	local Match = game.ReplicatedStorage:WaitForChild("Match")
	local MatchPlayer = Match:WaitForChild("Players"):WaitForChild(LocalPlayer.Name)
	local isSprinting = MatchPlayer:GetAttribute("isSprinting")
	local Role = MatchPlayer:GetAttribute("Role")
	
	local Health = MatchPlayer:WaitForChild("Values"):GetAttribute("Health")
	local MaxHealth = MatchPlayer:WaitForChild("Values"):GetAttribute("MaxHealth")
	local isCrouching = MatchPlayer:GetAttribute("isCrouching")
	local AnimationString = Role .. AnimationAction
	local isInjured = if (Role == "Prey") then (Health <= 50) else false

	if (Track == nil or AnimationList[AnimationString] == nil or LocalPlayer.Character:GetAttribute("Falling") or LocalPlayer.Character:GetAttribute("Stagger")) then
		Track = AnimationList[AnimationString]
		AnimationString = Role .. "Run"
		return
	end
	
	if (AnimationAction == "Run" or AnimationAction == "Walk" or AnimationAction == "Idle") then
		
		if (Role == "Prey") then
			if (isSprinting) then
				AnimationAction = "Run"
				AnimationString = Role .. "Run"
			else
				AnimationAction = "Walk"
				AnimationString = Role .. "Walk"
			end
		end
		
		
		if (not Moving) then
			AnimationString = Role .. "Idle"
			AnimationAction = "Idle"
		end
		
		if (isInjured and not isCrouching) then
			AnimationString = AnimationString .. "Injured"
			AnimationAction = AnimationAction .. "Injured"
		end
		
		if (isCrouching) then
			AnimationString = AnimationString .. "Crouch"
			AnimationAction = AnimationAction .. "Crouch"
		end
		
		Track = AnimationList[AnimationString]
	end

	if (Track == AnimationList[AnimationString]) then
		if (table.find(NonLoopable, AnimationAction)) then
			return
		end
		
		if ((table.find(Loopable, AnimationAction)) and Track.IsPlaying) then
			return
		end
	else
		Track = AnimationList[AnimationString]
	end
	
	if (AnimationString == nil) then
		AnimationString = "PreyIdle"
		return
	end
	
	this:stopAnimation()
	Track.Priority = AnimationStats[AnimationString][3]
	Track:Play(AnimationStats[AnimationString][1], 1, AnimationStats[AnimationString][2])
end

function this:accelerateAttack()
	AnimationList["HunterAttack"]:AdjustSpeed(3.5)
end

function this:playAttack()
	AnimationList["HunterAttack"].Priority = Enum.AnimationPriority.Action4
	AnimationList["HunterAttack"]:Play()
end

function this:setAnimation(Action)
	AnimationEvent:FireServer(Action)
end

function this:stopAnimation()

	for i, v in pairs(Animator:GetPlayingAnimationTracks()) do
		if (v.Name == "HunterAttack") then continue end
		v:Stop()
		v:Destroy()
		v = nil
	end
	
	if (Track == nil) then
		return
	end
	
	Track:Stop()
	Track:Destroy()
end

function this:initialize()
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
		script.Parent:SetAttribute("RunAttack", true)
	end)
	
end

this:initialize()

--[[AnimationList["HunterAttack"].KeyframeReached:Connect(function(Keyframe)
	
	local Match = game.ReplicatedStorage:WaitForChild("Match")
	local MatchPlayer = Match:WaitForChild("Players"):WaitForChild(LocalPlayer.Name)
	
	if (Keyframe == "Begin" and (os.time() - lastAttack) > 5) then
		lastAttack = os.time()
		AttackRemote:FireServer("Begin")
	end
	
	if (Keyframe == "Swing") then
		AttackRemote:FireServer("Swing")
	end
	
	if (Keyframe == "End") then
		AttackRemote:FireServer("Recovery")
	end
end)]]

ClientEvents.RenderTick.Event:Connect(function()
	local MatchPlayer = game.ReplicatedStorage:WaitForChild("Match"):WaitForChild("Players"):WaitForChild(LocalPlayer.Name)
	local AnimationAction = MatchPlayer:GetAttribute("AnimationAction")
	local MoveSpeed = math.abs(Humanoid.MoveDirection.X + Humanoid.MoveDirection.Z)
	local isSprinting = MatchPlayer:GetAttribute("isSprinting")
	
	if (table.find(NonLoopable, AnimationAction) and not Track.IsPlaying) then
		if (MoveSpeed <= 0) then
			this:setAnimation("Idle")
		else
			if (isSprinting) then
				this:setAnimation("Run")
			else
				this:setAnimation("Walk")
			end
		end
	end
	
end)



return this
