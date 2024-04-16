local InstallationGame = require(game.Players.LocalPlayer.PlayerGui:WaitForChild("InstallationGame"):WaitForChild("InstallGame"))
local SkillCheck = require(game.Players.LocalPlayer.PlayerGui:WaitForChild("SkillCheck"):WaitForChild("SkillCheck"))
local Gameplay = require(game.ReplicatedStorage.Prefabs["Client Functions"])
local FootSteps = require(script.Footsteps)

local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")
local ChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")

local Animations = require(script:WaitForChild("Animations"))
local Attack = require(script:WaitForChild("Attack"))

local MouseService = game.Players.LocalPlayer:GetMouse()
local LocalPlayer = game.Players.LocalPlayer

local Backpack = LocalPlayer:WaitForChild("Backpack")
local ClientEvents = Backpack:WaitForChild("Events")
local Remotes = game.ReplicatedStorage.Remotes
local Assets = game.ReplicatedStorage.Assets
local Events = game.ReplicatedStorage.Events
local Camera = workspace.CurrentCamera

local initialized = false
local inPregame = true
local cancelAttack = false
local fov = 80
local Profile = nil

local DONT_SEND = {
	Enum.KeyCode.W,
	Enum.KeyCode.A,
	Enum.KeyCode.S,
	Enum.KeyCode.D,
	Enum.KeyCode.Thumbstick1,
	Enum.KeyCode.Thumbstick2,
}

function initialize()
	
	initialized = true
	
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
	
	repeat 
		local success = pcall(function() 
			game.StarterGui:SetCore("ResetButtonCallback", false) 
		end)

		task.wait(1)
	until success
	
end

UserInputService.TouchPan:Connect(function()
	
	if (not Gameplay:isRunning() or Gameplay:getMatchTimer() < 2) then
		return
	end
	
	LocalPlayer.PlayerGui.MobileControls.Enabled = true
end)

function onInputBegin(Input, Processed)
	
	if ((Input.KeyCode == Enum.KeyCode.M or Input.KeyCode == Enum.KeyCode.DPadDown) and not Processed) then
		local MouseLock = script:GetAttribute("MouseLock")
		script:SetAttribute("MouseLock", not MouseLock) 
	end
	
	if (not Gameplay:isRunning() or Gameplay:getMatchTimer() < 1) then
		return
	end
	
	local Match = game.ReplicatedStorage:WaitForChild("Match")
	local MatchPlayer = Match:WaitForChild("Players"):WaitForChild(LocalPlayer.Name)
	local Action = MatchPlayer:GetAttribute("Action")
	local AttackKey = MatchPlayer:GetAttribute("AttackKey")
	
	if (table.find(DONT_SEND, Input.KeyCode) or ChatService.ChatInputBarConfiguration.IsFocused) then
		return
	end
	
	if (Input.KeyCode == Enum.KeyCode.ButtonR2) then
		if (MatchPlayer:GetAttribute("Role") == "Hunter" and AttackKey == "Empty" and Action == 1) then
			cancelAttack = false
			Remotes.AttackRemote:FireServer("Begin")
			Animations:setAnimation("Attack")
		end
	end
	
	Remotes.InputEvent:FireServer(Input.KeyCode, true, Processed)
end

function onInputEnded(Input, Processed)
	
	if (not Gameplay:isRunning() or Gameplay:getMatchTimer() < 1) then
		return
	end
	
	local Match = game.ReplicatedStorage:WaitForChild("Match")
	local MatchPlayer = Match:WaitForChild("Players"):WaitForChild(LocalPlayer.Name)
	local Action = MatchPlayer:GetAttribute("Action")
	
	if (table.find(DONT_SEND, Input.KeyCode) or Processed or ChatService.ChatInputBarConfiguration.IsFocused) then
		return
	end
	
	if (Input.KeyCode == Enum.KeyCode.ButtonR2) then
		if (MatchPlayer:GetAttribute("Role") == "Hunter") then
			task.wait(0.25)
			cancelAttack = true
		end
	end
	
	Remotes.InputEvent:FireServer(Input.KeyCode, false, Processed)
end

function onMouse1Down()
	
	if (not Gameplay:isRunning() or Gameplay:getMatchTimer() < 1) then
		return
	end
	
	local Match = game.ReplicatedStorage:WaitForChild("Match")
	local MatchPlayer = Match:WaitForChild("Players"):WaitForChild(LocalPlayer.Name)
	local Action = MatchPlayer:GetAttribute("Action")
	local AttackKey = MatchPlayer:GetAttribute("AttackKey")
	
	if (UserInputService.TouchEnabled or UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1) then
		return
	end
	
	Remotes.MouseEvent:FireServer(1, true)
	
	if (MatchPlayer:GetAttribute("Role") == "Hunter" and AttackKey == "Empty" and Action == 1) then
		cancelAttack = false
		Remotes.AttackRemote:FireServer("Begin")
		Animations:playAttack()
		ClientEvents.Attack:Fire()
	end
	
	LocalPlayer.PlayerGui.MobileControls.Enabled = false
end

function onMouse1Up()
	
	if (not Gameplay:isRunning() or Gameplay:getMatchTimer() < 1) then
		return
	end
	
	local Match = game.ReplicatedStorage:WaitForChild("Match")
	local MatchPlayer = Match:WaitForChild("Players"):WaitForChild(LocalPlayer.Name)
	local Action = MatchPlayer:GetAttribute("Action")
	
	if (UserInputService.TouchEnabled or UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1) then
		return
	end
	
	if (MatchPlayer:GetAttribute("Role") == "Hunter") then
		task.wait(0.15)
		cancelAttack = true
	end
	
	Remotes.MouseEvent:FireServer(1, false)
end

function onMouse2Down()
	
	if (UserInputService.TouchEnabled or UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1) then
		return
	end
	
	Remotes.MouseEvent:FireServer(2, true)
end

function onMouse2Up()
	
	if (UserInputService.TouchEnabled or UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1) then
		return
	end
	
	Remotes.MouseEvent:FireServer(2, false)
end

function onInstallationStart(ExtractorID, Action)
	
	if (Action == "Start") then
		InstallationGame:spawn(ExtractorID)
		script:SetAttribute("MouseLock", false)
	end
	
	if (Action == "Stop") then
		InstallationGame:despawn()
		task.wait(0.25)
		script:SetAttribute("MouseLock", true)
	end
	
end

function onCamera(Mode)
	
	local Hunter = Gameplay:getHunter()
	
	for i, player in pairs(game.Players:GetPlayers()) do
		if (player.Name ~= LocalPlayer.Name) then
			for i2, v2 in pairs(player.Backpack:GetChildren()) do
				v2:ClearAllChildren()
			end
		end
	end
	
	if (Mode == "Create") then
		Profile = Remotes.RequestData:InvokeServer("Profile")
	end
	
	if (Mode == "EndIntro") then
		inPregame = false
		Camera.CameraSubject = LocalPlayer.Character.Humanoid
		Camera.CameraType = Enum.CameraType.Custom
		removeStain()
		removeBackpack()
		print(workspace.Map.Interactables.BigDoors:GetChildren())
	end
	
end

function onSkillCheck(Speed, Size, ID)
	SkillCheck:spawnSkillCheck(Speed, Size, ID)
end

function removeStain()
	
	local MatchPlayers = Gameplay:getMatchPlayers()
	local MatchPlayer = Gameplay:getMatchPlayer(LocalPlayer.UserId)
	local Role = Gameplay:getRole(MatchPlayer)
	
	for i ,v in pairs(MatchPlayers) do

		local WSPlayer = game.Workspace[v.Name]
		local targetRole = Gameplay:getRole(v)

		if (Role == "Prey" and WSPlayer:FindFirstChild("DisplayTrap") ~= nil) then
			WSPlayer.DisplayTrap:Destroy()
		end
		
		if (targetRole == "Hunter" and WSPlayer:FindFirstChild("DisplayTrap") ~= nil) then
			WSPlayer.DisplayTrap:Destroy()
		end

		if (targetRole == "Prey") then
			if (WSPlayer:FindFirstChild("RedStain") ~= nil) then
				WSPlayer:WaitForChild("RedStain"):Destroy()
			end
		end
	end
	
	if (Role == "Hunter") then
		LocalPlayer.Character:WaitForChild("RedStain"):Destroy()
		Camera:WaitForChild("ViewModel").RedStain:Destroy()
	end

end

function removeBackpack()
	for i2, v2 in pairs(game.Players:GetChildren()) do
		if (v2.Name ~= LocalPlayer.Name) then
			if (v2:WaitForChild("Backpack"):FindFirstChild("BasePlayer") ~= nil) then
				v2:WaitForChild("Backpack"):WaitForChild("BasePlayer"):Destroy()
			end
		end
	end
end

function onMessageReceive(Message)
	local System = string.format("<font color='#BB33FF'>%s</font>", "SYSTEM > ")
	game:GetService("TextChatService").ChatInputBarConfiguration.TextChannel:DisplaySystemMessage(System)
	task.wait(0.2)
	game:GetService("TextChatService").ChatInputBarConfiguration.TextChannel:DisplaySystemMessage(Message)
end

function onUpdate(delta)
	
	if (not initialized) then
		initialize()
	end
	
	ClientEvents.ClientTick:Fire(delta)
	Animations:runAnimations()
	
	local MatchPlayers = Gameplay:getMatchPlayers()
	local MatchPlayer = Gameplay:getMatchPlayer(LocalPlayer.UserId)
	local AttackKey = Gameplay:getAttackKey(MatchPlayer)
	local ChaseTimer = Gameplay:getChaseTimer(MatchPlayer)
	local Role = Gameplay:getRole(MatchPlayer)
	
	local MouseLock = script:GetAttribute("MouseLock")
	local ChaseRay = script:GetAttribute("ChaseRay")
	
	if (Gameplay:getMatchTimer() <= 0) then
		return
	end
	
	if (Profile == nil) then
		Profile = Remotes.RequestData:InvokeServer("Profile")
	end
	
	fov = Profile.Account.Settings["First-Person FoV"] or fov
	
	if (Role == "Prey") then
		Camera.FieldOfView = fov
	else
		Camera.FieldOfView = math.clamp(fov, 80, 100)
		FootSteps:tickFootSteps(delta)
	end
	
	local Hunter = Gameplay:getHunter()
	
	local Humanoid : Humanoid = workspace:WaitForChild(LocalPlayer.Name):WaitForChild("Humanoid")
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	
	if (MouseLock and not LocalPlayer.PlayerGui.Options.Enabled) then
		if (UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1) then
			GamepadService:DisableGamepadCursor()
		else
			UserInputService.MouseIconEnabled = false
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		end
	else
		if (UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1) then
			GamepadService:EnableGamepadCursor(nil)
		else
			UserInputService.MouseIconEnabled = true
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
	end
	
	if (AttackKey == "Begin") then
		Attack:startAttack()
		script:SetAttribute("RunAttack", true)
	end
	
	if (cancelAttack) then
		script:SetAttribute("RunAttack", false)
		Animations:accelerateAttack()
	end
	
end

function updateProfile(Sent)
	Profile = Sent
	ClientEvents.ProfileUpdate:Fire(Sent)
end

function updateBinds(Sent)
	ClientEvents.BindsUpdate:Fire(Sent)
end

function onRender()
	
	if (inPregame) then
		Camera.CFrame = workspace.Pregame.CameraPoint.CFrame
		Camera.CameraSubject = workspace.Pregame.CameraPoint
	end
	
	ClientEvents.RenderTick:Fire()
end

UserInputService.InputBegan:Connect(onInputBegin)
UserInputService.InputEnded:Connect(onInputEnded)
MouseService.Button1Down:Connect(onMouse1Down)
MouseService.Button1Up:Connect(onMouse1Up)
MouseService.Button2Down:Connect(onMouse2Down)
MouseService.Button2Up:Connect(onMouse2Up)
Remotes.InstallationStart.OnClientEvent:Connect(onInstallationStart)
RunService.Heartbeat:Connect(onUpdate)
RunService.RenderStepped:Connect(onRender)
LocalPlayer.CharacterAdded:Connect(initialize)
Remotes.AssignCamera.OnClientEvent:Connect(onCamera)
Remotes.ChatMessage.OnClientEvent:Connect(onMessageReceive)
Remotes.SkillCheckEvent.OnClientEvent:Connect(onSkillCheck)
Remotes.updateSettings.OnClientInvoke = updateProfile
Remotes.updateBind.OnClientInvoke = updateBinds
