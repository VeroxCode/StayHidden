local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local AssignCamera = game.ReplicatedStorage.Remotes:WaitForChild("AssignCamera")

local Anim_P1 = "rbxassetid://16331051879"
local Anim_P2 = "rbxassetid://16331069830"
local Anim_P3 = "rbxassetid://16331076085"
local Anim_H = "rbxassetid://16331081166"

local AnimList = {}
local Pregame = workspace.Pregame
local Prey = 1

local Players = game:GetService("Players")
local RefreshCountdown = 15

local DebugTable = {
	inDebug = workspace:GetAttribute("Debug"),
	Players = workspace:GetAttribute("DebugPlayers"),
	needHunter = workspace:GetAttribute("DebugNeedHunter")
}

local this = {}

function this:startAnimations()

	local Anims = {Anim_P1, Anim_P2, Anim_P3, Anim_H}
	local Chars = {Pregame.P1, Pregame.P2, Pregame.P3, Pregame.H}

	for count = 1, 4 do
		local Humanoid = Chars[count].Humanoid

		local Anim = Instance.new("Animation")
		Anim.Name = `Pregame{count}`
		Anim.AnimationId = Anims[count]
		Anim.Parent = script

		
		AnimList[count] = Humanoid:LoadAnimation(Anim)
	end
	
	game.ContentProvider:PreloadAsync(AnimList)
	
	AnimList[1]:Play()
	AnimList[2]:Play()
	AnimList[3]:Play()
	AnimList[4]:Play()
	
end

function this:updateCountdown()
	
	local Countdown = Modules.Game:getMatchCountdown()
	Countdown = math.ceil(Countdown)
	Countdown = math.clamp(Countdown, 0, RefreshCountdown)
	Countdown = math.abs(Countdown)
	
	for i, player in (Players:GetPlayers()) do
		player.PlayerGui.LoadingScreen.Countdown.Visible = true
		player.PlayerGui.LoadingScreen.Countdown.Text = `Match starts in: {math.clamp(math.ceil(Countdown), 0, RefreshCountdown)}`
	end
	
end

function this:onJoin(Player)

	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local WorkspacePlayer = Modules.Game:getWorkspacePlayer(Player.UserId)
	local RootPart = WorkspacePlayer.HumanoidRootPart
	local Role = Modules.Game:getRole(MatchPlayer)
	
	repeat task.wait()
	until WorkspacePlayer ~= nil

	RootPart.CFrame = Pregame.Position.CFrame
	Player.CameraMode = Enum.CameraMode.LockFirstPerson

end

function this:addPrey(Player)
	
	local Humanoid = Pregame:WaitForChild(`P{Prey}`):WaitForChild("Humanoid")
	
	if (not DebugTable.inDebug) then
		local Description : HumanoidDescription = Players:GetHumanoidDescriptionFromUserId(Player.UserId)
		Description.Head = 0
		Description.Torso = 0
		Description.RightArm = 0
		Description.RightLeg = 0
		Description.LeftArm = 0
		Description.LeftLeg = 0
		Humanoid:ApplyDescription(Description)
		
		for i, v in pairs(Humanoid:GetChildren()) do
			if (string.find(v.Name, "Scale")) then
				v.Value = 1
			end
			Humanoid.HeadScale.Value = 1.2
			Humanoid.BodyHeightScale.Value = 1.1
			Humanoid.BodyDepthScale.Value = 0.9
		end
		
	end
	
	

	Prey += 1

end

function this:addHunter(Player)
	
	local Humanoid = Pregame:WaitForChild(`H`):WaitForChild("Humanoid")

	if (not DebugTable.inDebug) then
		local Description : HumanoidDescription = Players:GetHumanoidDescriptionFromUserId(Player.UserId)
		Description.Head = 0
		Description.Torso = 0
		Description.RightArm = 0
		Description.RightLeg = 0
		Description.LeftArm = 0
		Description.LeftLeg = 0
		Humanoid:ApplyDescription(Description)
		
		for i, v in pairs(Humanoid:GetChildren()) do
			if (string.find(v.Name, "Scale")) then
				v.Value = 1.6
			end
			Humanoid.HeadScale.Value = 1.7
			Humanoid.BodyDepthScale.Value = 1.5
		end
		
	end
	
end

function this:startTimer()
	
end

function this:stopTimer()
	
end

return this
