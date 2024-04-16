local GameUtils = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Utils"):WaitForChild("Game Functions"))
local Aura = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Aura Manager"))
local Speed = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Player"):WaitForChild("Speed"))
local SpawnNotification = game.ReplicatedStorage.Remotes:WaitForChild("SpawnNotification")
local AssignCamera = game.ReplicatedStorage.Remotes:WaitForChild("AssignCamera")


local Remotes = game.ReplicatedStorage.Remotes
local Events = game.ServerStorage.Events

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local DebugTable = {
	inDebug = workspace:GetAttribute("Debug"),
	Players = workspace:GetAttribute("DebugPlayers"),
	needHunter = workspace:GetAttribute("DebugNeedHunter")
}

local TempColors = {
	[1] = Color3.new(0.709804, 0.0156863, 0.0156863),
	[2] = Color3.new(0.607843, 0.647059, 0.192157),
	[3] = Color3.new(0.129412, 0.541176, 0.0156863),
	[4] = Color3.new(0.380392, 0.0431373, 0.52549),
	[5] = Color3.new(0.0352941, 0.101961, 0.67451),
}

local this = {}

function this:spawnAsHunter(PlayerID)
	
	local MatchPlayer = GameUtils:getMatchPlayer(PlayerID)
	local Player = Players:GetPlayerByUserId(PlayerID)
	local Backpack = Player.Backpack
	local Sounds = Backpack.BasePlayer.SoundHandler
		
	local Map = workspace:WaitForChild("Map")
	local Interactables = Map:WaitForChild("Interactables")
	local Spawns = Map:WaitForChild("Spawns"):WaitForChild("Hunter")
	local Humanoid = workspace:WaitForChild(Player.Name):WaitForChild("Humanoid")
	local RootPart = workspace:WaitForChild(Player.Name):WaitForChild("HumanoidRootPart")
	
	Player.CameraMode = Enum.CameraMode.LockFirstPerson
	
	GameUtils:setAnimationAction(MatchPlayer, "Run")
	Player.PlayerGui.MobileControls.Prey:Destroy()
	
	if (not DebugTable.inDebug) then
		local Description : HumanoidDescription = Players:GetHumanoidDescriptionFromUserId(PlayerID)
		Description.Head = 0
		Description.Torso = 0
		Description.RightArm = 0
		Description.RightLeg = 0
		Description.LeftArm = 0
		Description.LeftLeg = 0
		Humanoid:ApplyDescription(Description)
	end
	
	for i, v in pairs(Humanoid:GetChildren()) do
		if (string.find(v.Name, "Scale")) then
			v.Value = 1
		end
		
		Humanoid.HeadScale.Value = 1.6
		Humanoid.BodyTypeScale.Value = 1
		Humanoid.BodyHeightScale.Value = 1.4
		Humanoid.BodyDepthScale.Value = 1.2
		Humanoid.BodyWidthScale.Value = 1.2
		Humanoid.BodyProportionScale.Value = 0
	end
	
	for i, Extractor in pairs(Interactables.Extractors:GetChildren()) do
		Aura:createAura(Player, "Extractors", Extractor.Name, false, 0, Color3.new(0.94902, 1, 0), Color3.new(0.839216, 0.839216, 0.0901961), "Base")
	end
	
	for i, Fusebox in pairs(Interactables.Fuseboxes:GetChildren()) do
		Aura:createAura(Player, "Fuseboxes", Fusebox.Name, false, 0, Color3.new(1,1,1), Color3.new(1,1,1), "Base")
	end
	
	local TransitionTween = TweenService:Create(Player.PlayerGui.LoadingScreen.Frame, TweenInfo.new(3), {BackgroundTransparency = 0})
	TransitionTween:Play()
	
	TransitionTween.Completed:Connect(function()
		if (RootPart) then
			
			AssignCamera:FireClient(Player, "Unlock")
			AssignCamera:FireClient(Player, "Create")
			
			local randomSpawn = math.random(1, #Spawns:GetChildren()) 
			RootPart.CFrame = Spawns[randomSpawn].CFrame
			
			RootPart.Anchored = false
			Remotes.UpdatePosition:InvokeClient(Player, "Force", Spawns[randomSpawn].CFrame.Position)
			Player.AudioDeviceInput:Destroy()
			Player.Character.AudioEmitter:Destroy()
			
			local AudioTween = TweenService:Create(Sounds.Other.PregameLobby, TweenInfo.new(3), {Volume = 0})
			AudioTween:Play()
			
			AudioTween.Completed:Connect(function()
				Sounds.Other.PregameLobby:Destroy()
			end)
		end
	end)
	
end

function this:spawnAsPrey(PlayerID)
	
	local Player = Players:GetPlayerByUserId(PlayerID)
	local Backpack = Player.Backpack
	local Sounds = Backpack.BasePlayer.SoundHandler
	
	local Map = workspace:WaitForChild("Map")
	local Spawns = Map:WaitForChild("Spawns"):WaitForChild("Prey")
	local Humanoid : Humanoid = workspace:WaitForChild(Player.Name):WaitForChild("Humanoid")
	local RootPart = workspace:WaitForChild(Player.Name):WaitForChild("HumanoidRootPart")
	
	if (not DebugTable.inDebug) then
		local Description : HumanoidDescription = Players:GetHumanoidDescriptionFromUserId(PlayerID)
		Description.Head = 0
		Description.Torso = 0
		Description.RightArm = 0
		Description.RightLeg = 0
		Description.LeftArm = 0
		Description.LeftLeg = 0
		Humanoid:ApplyDescription(Description)
	end
	
	for i, v in pairs(Humanoid:GetChildren()) do
		if (string.find(v.Name, "Scale")) then
			v.Value = 1
		end
		Humanoid.HeadScale.Value = 1.15
		Humanoid.BodyTypeScale.Value = 0.75
		Humanoid.BodyHeightScale.Value = 1
		Humanoid.BodyProportionScale.Value = 0
	end
	
	local TransitionTween = TweenService:Create(Player.PlayerGui.LoadingScreen.Frame, TweenInfo.new(3), {BackgroundTransparency = 0})
	TransitionTween:Play()

	TransitionTween.Completed:Connect(function()
		if (RootPart) then
			AssignCamera:FireClient(Player, "Unlock")
			Player.CameraMode = Enum.CameraMode.Classic
			Player.PlayerGui.MobileControls.Hunter:Destroy()

			local randomSpawn = math.random(1, #Spawns:GetChildren()) 
			RootPart.CFrame = Spawns[randomSpawn].CFrame
			
			RootPart.Anchored = false
			Remotes.UpdatePosition:InvokeClient(Player, "Force", Spawns[randomSpawn].CFrame.Position)
			
			local AudioTween = TweenService:Create(Sounds.Other.PregameLobby, TweenInfo.new(3), {Volume = 0})
			AudioTween:Play()

			AudioTween.Completed:Connect(function()
				Sounds.Other.PregameLobby:Destroy()
			end)
		end
	end)
	
end

function this:spawnPlayers()
	local MatchPlayers = game.ReplicatedStorage.Match.Players
	
	local count = 0
	
	for i, Player in pairs(MatchPlayers:GetChildren()) do
		local Role = Player:GetAttribute("Role")
		local ID = Player:GetAttribute("ID")
		
		if (Role == "Hunter") then
			this:spawnAsHunter(ID)
		else
			this:spawnAsPrey(ID)
		end
	end
end

function this:startCountdown()
	
	local MatchPlayers = game.ReplicatedStorage.Match.Players:GetChildren()
	
	for count = 5, 0, -1 do
		task.wait(1)
	end
	
	for i, MatchPlayer in pairs(MatchPlayers) do
		local Player = game.Players:GetPlayerByUserId(MatchPlayer:GetAttribute("ID"))
		local RootPart = Player.Character.PrimaryPart
		
		Speed:addMultiplier(MatchPlayer, "Intro", 0, 7)
		AssignCamera:FireClient(Player, "EndIntro")
		Player.PlayerGui.GameUI.Enabled = false
		Player.PlayerGui.LoadingScreen.Countdown.Visible = false
		local TransitionTween = TweenService:Create(Player.PlayerGui.LoadingScreen.Frame, TweenInfo.new(3), {BackgroundTransparency = 0})
		TransitionTween:Play()

		TransitionTween.Completed:Connect(function()
			
			local IntroTween = TweenService:Create(Player.PlayerGui.LoadingScreen.Frame, TweenInfo.new(4), {BackgroundTransparency = 1})
			IntroTween:Play()
			
			IntroTween.Completed:Connect(function()
				if (RootPart) then

					Player.PlayerGui.LoadingScreen.Enabled = false
					Player.PlayerGui.GameUI.Enabled = true
				end
			end)
		end)
		
		if (MatchPlayer:GetAttribute("Role") == "Hunter") then
			SpawnNotification:FireClient(Player, "Hunter", "Eliminate your Prey to Win!")
		else
			SpawnNotification:FireClient(Player, "Prey", "Find Parts from Part Chests!")
		end
		
		GameUtils:setRunning(true)
		
	end
	
end

return this
