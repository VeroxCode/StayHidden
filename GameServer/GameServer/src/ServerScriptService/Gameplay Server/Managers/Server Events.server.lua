--!native

local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Global = require(game.ServerScriptService:WaitForChild("Global"):WaitForChild("Global Variables"))
local Notifications = require(game.ServerScriptService.Handlers:WaitForChild("Notifications"))
local PlayFab = require(game.ServerScriptService.Handlers:WaitForChild("PlayFab"))
local json = require(game.ServerScriptService.PlayFab:WaitForChild("json"))
local DatastoreService = game:GetService("DataStoreService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Remotes = game.ReplicatedStorage.Remotes
local Events = game.ServerStorage.Events
local LastAttack = os.time()

function onAttack(Player, Result, Target)
	
	print(`AttackKey {Result}`)
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local failTime = MatchPlayer.Values:GetAttribute("FailRecoveryTime")
	
	Modules.Game:setAttackKey(MatchPlayer, Result)
	
	if (Result == "Begin" and (os.time() - LastAttack) > 2) then
		LastAttack = os.time()
		Modules.Actions:setAction(Player.UserId, Modules.Actions.List.ATTACK)
		Modules.Speed:addMultiplier(MatchPlayer, "Attack", Modules.Speed.Modifiers.Hunter.Attack, 0)
	end
	
	if (Result == "Recovery") then
		Modules.Speed:removeMultiplier(MatchPlayer, "Attack")
		Modules.Speed:addMultiplier(MatchPlayer, "FailAttack", Modules.Speed.Modifiers.Hunter.Recovery, failTime)
		wait(failTime)
		Modules.Actions:setAction(Player.UserId, Modules.Actions.List.IDLE)
		Modules.Game:setAttackKey(MatchPlayer, "Empty")
	end
	
	if (Result == "Hit") then
		Modules.Actions:performAction(Player.UserId, Modules.Actions.List.ATTACK, true, Target)
	end
	
end

function onHealthUpdate(Player, Health)
	
	local GraveList = workspace.Map.Interactables.Graves
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)

	local AvailableList = {}

	if (Health <= 0) then
		Modules.Game:setVulnerable(MatchPlayer, false)
		Modules.Game:setChaseTimer(MatchPlayer, 0)
		Modules.Speed:addMultiplier(MatchPlayer, "Death", 0, 3.5)
		Modules.Game:setAnimationAction(MatchPlayer, "Death")
		
		task.wait(1)
		
		for count = 1, (#GraveList:GetChildren() - 1) do
			local Object = GraveList[count]
			local Occupant = Object:GetAttribute("Player")

			if (Occupant == "") then
				AvailableList[#AvailableList + 1] = count
			end
		end
		
		local random = math.random(1, #AvailableList)
		
		if (Modules.Game:getHunter() ~= nil) then
			Modules.Game:setChaseTimer(Modules.Game:getHunter(), 0)
		end
		
		local alive = 0
		
		for i, v in pairs(Modules.Game:getMatchPlayers()) do
			if (Modules.Game:getRole(v) == "Hunter") then continue end
			
			if (Modules.Game:getMaxHealth(v) > 0 and not Modules.Game:isEscaped(v)) then
				alive += 1
			end
		end
		
		if (alive > 1) then
			Events.Prey.sendToGrave:Fire(Player, random)
		else
			onDeath(Player)
		end
		

	else
		Modules.Game:setAnimationAction(MatchPlayer, "Injured")
	end
	
end

function onDeath(Player)
	
	local WSPlayer = workspace:WaitForChild(Player.Name)
	local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local HunterID = Modules.Game:getHunterID()	
	
	RootPart.CFrame = CFrame.new(0, 2000, 0)
	Modules.PlayerUtils:setTransparency(Player.Name, 1)
	RootPart.Anchored = true
	
	Modules.Game:setHealth(MatchPlayer, 0)
	Modules.Game:setMaxHealth(MatchPlayer, 0)
	Modules.Credits:increaseCredits(HunterID, (Modules.Game_Values.ScoreEvents.Hunter.PreyKilled))
	
	Player.PlayerGui.Options.BaseFrame.Screen.Spectate.Visible = true
	Player.PlayerGui.Options.Enabled = true
	Player.PlayerGui.GameUI.Enabled = false
	
end

function onEscape(Player)
	
	local WSPlayer = workspace:WaitForChild(Player.Name)
	local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)

	RootPart.CFrame = CFrame.new(0, 2000, 0)
	Modules.PlayerUtils:setTransparency(Player.Name, 1)
	RootPart.Anchored = true
	
	Modules.Credits:increaseCredits(Player.UserId, (Modules.Game_Values.ScoreEvents.Prey.Survived))
	Modules.Game:setEscaped(MatchPlayer, true)
	
	Player.PlayerGui.Options.BaseFrame.Screen.Spectate.Visible = true
	Player.PlayerGui.Options.Enabled = true
	Player.PlayerGui.GameUI.Enabled = false
	
end

function onAnimationReceive(Player, Action)
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	Modules.Game:setAnimationAction(MatchPlayer, Action)
end

function onAnimationStop(Player)
	local Humanoid = Player.Character:WaitForChild("Humanoid")
	local Animator : Animator = Humanoid:WaitForChild("Animator")

	for i, v in pairs(Animator:GetPlayingAnimationTracks()) do
		v:Stop()
	end
end

function onSerumInsert(MatchPlayer)
	local Map = workspace:WaitForChild("Map")
	local Interactables = Map:WaitForChild("Interactables")

	local MatchStats = game.ReplicatedStorage.Match.MatchStats
	local Collectors = workspace.Map.Interactables.Collectors
	local Serums = 0

	for count = 1, (#Collectors:GetChildren() - 1) do
		local Object = Collectors[count]
		local Stored = Object:GetAttribute("Progress")

		Serums += Stored
	end

	MatchStats:SetAttribute("Extracted", Serums)

	if (Serums >= Modules.Game_Values.BaseValues.Match.Extractions) then
		MatchStats:SetAttribute("CanEscape", true)
		
		if (workspace:GetAttribute("Debug") and not workspace:GetAttribute("DebugNeedHunter")) then
			return
		end

		local Hunter = Modules.Game:getHunterID()
		local HunterPlayer = Players:GetPlayerByUserId(Hunter)

		for i, Exit in pairs(Interactables.Exits:GetChildren()) do
			Modules.AuraManager:createAura(HunterPlayer, "Exits", Exit.Name, false, 0, Color3.new(1,1,1), Color3.new(1,1,1), "Base")
		end
	end
end

function sendToMainMenu(Player)
	warn("SAVING")
	Modules.Events.SaveData:Fire(Player)
	TeleportService:TeleportAsync(Modules.GlobalVariables.Places.MainMenu, {Player})
end

function onPlayerQuit(Player)
end

function RunServerTick(delta)
	Events.Game.ServerTick:Fire(delta)
	
	updateVulnerability()
	updateInteractionTimer(delta)
	updateMatchTimer(delta)
	generatePlaytimePoints(delta)
	checkAlivePlayers()
	
end

function updateMatchTimer(delta)
	if (Modules.Game:isRunning()) then
		local MatchStats = Modules.Game:getMatchStats()
		local Timer = MatchStats:GetAttribute("Timer")
		MatchStats:SetAttribute("Timer", Timer + delta)
	end
end

function updateInteractionTimer(delta)
	
	local MatchPlayers = Modules.Game:getMatchPlayers()

	for index, MatchPlayer in pairs(MatchPlayers) do
		
		local InteractionTimer = MatchPlayer:GetAttribute("InteractionTimer")
		
		if (InteractionTimer >= 0) then
			InteractionTimer -= delta
			MatchPlayer:SetAttribute("InteractionTimer", InteractionTimer)
		end
		
		if (InteractionTimer <= 0 and Modules.Actions:getInteraction(MatchPlayer) ~= 0) then
			MatchPlayer:SetAttribute("Interaction", 0)
		end
	end
end

function updateVulnerability()
	
	local MatchPlayers = Modules.Game:getMatchPlayers()

	for index, MatchPlayer in pairs(MatchPlayers) do
		local Role = Modules.Game:getRole(MatchPlayer)

		if (Role == "Prey") then

			local hurtTime = os.time() - Modules.Game:getLastAttack(MatchPlayer)
			local MaxHealth = Modules.Game:getMaxHealth(MatchPlayer)
			local Escaped = Modules.Game:isEscaped(MatchPlayer)
			
			local action = Modules.Actions:getAction(MatchPlayer:GetAttribute("ID"))
			local hasProtection = (Modules.Game:getEffect(MatchPlayer, "Protection", "Timer") > 0)
			local inHurttime = (hurtTime < 3)

			if (action ~= Modules.Actions.List.RESPAWNING) then
				Modules.Game:setVulnerable(MatchPlayer, (not hasProtection and not inHurttime))
			end
		end
	end
end

function generatePlaytimePoints(delta)
	
	if (Modules.Game:isRunning() and Modules.Game:getMatchTimer() > 30) then
		local MatchPlayers = Modules.Game:getMatchPlayers()

		for index, MatchPlayer in pairs(MatchPlayers) do
			local Role = Modules.Game:getRole(MatchPlayer)
			local Id = Modules.Game:getUserId(MatchPlayer)

			if (Role == "Hunter") then
				Modules.Credits:increaseCredits(Id, Modules.Game_Values.ScoreEvents.Generic.MatchTime * delta)
			else
				if (Modules.Game:getMaxHealth(MatchPlayer) > 0 and not Modules.Game:isEscaped(MatchPlayer) and (Players:FindFirstChild(MatchPlayer.Name) ~= nil)) then
					Modules.Credits:increaseCredits(Id, Modules.Game_Values.ScoreEvents.Generic.MatchTime * delta)
				end
			end
		end
	end
end

function checkAlivePlayers()
	
	if ((Modules.Game:isRunning()) and Modules.Game:getMatchTimer() > 10) then
		local escaped = false

		local MatchPlayers = Modules.Game:getMatchPlayers()
		for index, MatchPlayer in pairs(MatchPlayers) do
			local Role = Modules.Game:getRole(MatchPlayer)

			if (Role == "Prey") then
				local MaxHealth = Modules.Game:getMaxHealth(MatchPlayer)
				local isEscaped = Modules.Game:isEscaped(MatchPlayer)
				local Connected = Players:FindFirstChild(MatchPlayer.Name) ~= nil

				if (isEscaped) then
					escaped = true
				end

				if (MaxHealth > 0 and not isEscaped and Connected) then
					return
				end
			end
		end

		if (not escaped) then
			local HunterID = Modules.Game:getHunterID()
			if (HunterID == nil) then
				return
			end 
			Modules.Credits:increaseCredits(HunterID, (Modules.Game_Values.ScoreEvents.Hunter.AllPreyKilled))
		end

		for i, Player in pairs(Players:GetPlayers()) do
			
			if (workspace:GetAttribute("Debug")) then
				break
			end
				
			Player.Character.PrimaryPart.CFrame = CFrame.new(0, 2000, 0)
			Modules.PlayerUtils:setTransparency(Player.Name, 1)
			Player.Character.PrimaryPart.Anchored = true
				
			Player.PlayerGui.Options.BaseFrame.Screen.Spectate.Visible = false
			Player.PlayerGui.Options.Enabled = true
			Player.PlayerGui.GameUI.Enabled = false
		end
		
		if (not workspace:GetAttribute("Debug")) then
			Modules.Game:setRunning(false)
		end
	end
end

RunService.Heartbeat:Connect(RunServerTick)
Remotes.AnimationEvent.OnServerEvent:Connect(onAnimationReceive)
Remotes.StopAnimationEvent.OnServerEvent:Connect(onAnimationStop)
Remotes.AttackRemote.OnServerEvent:Connect(onAttack)
Remotes.ExitLobby.OnServerEvent:Connect(sendToMainMenu)

Events.Prey.onDeath.Event:Connect(onDeath)
Events.Prey.onEscape.Event:Connect(onEscape)
Events.Game.SerumInserted.Event:Connect(onSerumInsert)
Events.Prey.onHealthUpdate.Event:Connect(onHealthUpdate)