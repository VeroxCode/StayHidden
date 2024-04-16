local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local PregameHandler = require(game.ServerScriptService["Gameplay Server"].Setup.PregameHandler)
local DataStoreService = game:GetService("DataStoreService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

local initialized = false
local isRunning = false
local MaxPlayers = 4

local RefreshCountdown = if (workspace:GetAttribute("Debug")) then 3 else 15

local Runner = {
	GameStatus = nil;
	ServerStatus = nil;
	Countdown = nil;
	ServerUpdate = os.time();
}

local MatchTable = {
	Extracted = 0,
	Extractions = Modules.Game_Values.BaseValues.Match.Extractions,
	CanEscape = false,
	Running = false,
	Theme = "Mountain Climber",
	Countdown = 5,
	Timer = 0,
	Map = "",
}

local DebugTable = {
	inDebug = workspace:GetAttribute("Debug");
	Players = workspace:GetAttribute("DebugPlayers");
	needHunter = workspace:GetAttribute("DebugNeedHunter");
	startHunter = workspace:GetAttribute("DebugStartHunter");
}

function initialize()
	createMatchStats()
	initialized = true
	checkGameStatus()
	refreshServerStatus()
	PregameHandler:startAnimations()
end

function createMatchStats()
	
	local MatchStats = Instance.new("Configuration")
	MatchStats.Name = "MatchStats"
	MatchStats.Parent = game.ReplicatedStorage.Match

	for key, value in pairs(MatchTable) do
		MatchStats:SetAttribute(key, value)
	end
	
end

function onJoin(Player)

	local Data = Player:GetJoinData()
	local TeleportData = Data.TeleportData
	local isHunter = (TeleportData == "Hunter")
	
	if (workspace:WaitForChild(Player.Name).Animate ~= nil) then
		workspace[Player.Name].Animate:Destroy()
	end
	
	Modules.Game:setMatchCountdown(RefreshCountdown)
	
	--[[if (Player.Name == "VeroxCode") then
		Modules.Setup:createPlayer(Player, true)
		PregameHandler:onJoin(Player)
		PregameHandler:addHunter(Player)
		return
	end]]
	
	if (not DebugTable.inDebug) then
		Modules.Setup:createPlayer(Player, isHunter)
		PregameHandler:onJoin(Player)
		
		if (isHunter) then
			PregameHandler:addHunter(Player)
		else
			PregameHandler:addPrey(Player)
		end
		
		return
	else
		MaxPlayers = DebugTable.Players
		if (DebugTable.startHunter and DebugTable.needHunter) then
			if (not hasHunter()) then
				Modules.Setup:createPlayer(Player, true)
				PregameHandler:onJoin(Player)
				PregameHandler:addHunter(Player)
			else
				Modules.Setup:createPlayer(Player, false)
				PregameHandler:onJoin(Player)
				PregameHandler:addPrey(Player)
			end
		else
			Modules.Setup:createPlayer(Player, false)
			PregameHandler:onJoin(Player)
			PregameHandler:addPrey(Player)
		end
	end
	
	forceServerStatus()
	
end

function onQuit(Player)
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local Role = Modules.Game:getRole(MatchPlayer)
	
	Modules.Game:setMatchCountdown(RefreshCountdown)
	Runner.Countdown:Disconnect()
	
	forceServerStatus()
	
	if (Modules.Game:getHunterID() ~= nil) then
		if (Modules.Game:getHunterID() == Player.UserId) then
			forceServerStatus(true)
		end
	end
	
end

function hasHunter()
	
	local MatchPlayers = Modules.Game:getMatchPlayers()
	
	if (MatchPlayers ~= nil) then
		for i, Player in pairs(MatchPlayers) do
			if (Modules.Game:getRole(Player) == "Hunter") then
				return true
			end
		end
	end
	
	return false
end

function getPrey()
	
	local amount = 0
	local MatchPlayers = Modules.Game:getMatchPlayers()

	if (MatchPlayers) then
		for i, Player in pairs(MatchPlayers) do
			if (Modules.Game:getRole(Player) == "Prey") then
				amount += 1
			end
		end
	end
	
	return amount
end

function checkGameStatus()
	Runner.GameStatus = RunService.Heartbeat:Connect(function()

		local MatchPlayers = Modules.Game:getMatchPlayers()

		if (not initialized or isRunning) then
			return
		end
		
		if ((#MatchPlayers < MaxPlayers and not DebugTable.inDebug)) then
			return
		end
		
		if (DebugTable.inDebug) then
			if (DebugTable.needHunter) then
				if (#MatchPlayers >= DebugTable.Players) then
					startGame()
					return
				end
			else
				if (#MatchPlayers >= DebugTable.Players) then
					startGame()
				end
				return
			end
		end

		if (hasHunter()) then
			startGame()
			return
		end

	end)
end

function forceServerStatus(Quit)
	
	Quit = Quit or false
	
	if (DebugTable.inDebug) then
		return
	end
	
	local ServerList = DataStoreService:GetDataStore(Modules.GlobalVariables.Datastores.ServerList)
	local DefaultList = getServerList()

	local HunterID = Modules.Game:getHunterID()
	local ServerData = DefaultList[tostring(HunterID)]
	
	print(hasHunter())
	
	if (ServerData == nil) then
		return
	end
	
	if (not Quit) then
		ServerData.Players = getPrey()
		ServerData.LastUpdate = os.time()
	else
		ServerData.Players = getPrey()
		ServerData.LastUpdate = 0
	end
	

	local success, errorMsg = pcall(function()
		ServerList:SetAsync("Default", addToServerList(DefaultList, ServerData, HunterID))
	end)

	if (success) then
		print("Updated Server Info")
	end
	
	if (not hasHunter() or Quit) then
		Runner.ServerStatus:Disconnect()
		
		for i, v in pairs(game.Players:GetPlayers()) do
			TeleportService:TeleportAsync(Modules.GlobalVariables.Places.MainMenu, {v})
		end
	end
	
end

function startGame()
	
	if (Runner.Countdown ~= nil) then
		return
	end
	
	Runner.Countdown = RunService.Heartbeat:Connect(function(delta)
		
		local Countdown = Modules.Game:getMatchCountdown()
		Countdown -= delta
		Modules.Game:setMatchCountdown(Countdown)
		PregameHandler:updateCountdown()
		
		if (Countdown <= 0) then
			isRunning = true
			Runner.GameStatus:Disconnect() 
			Runner.ServerStatus:Disconnect()
			Runner.Countdown:Disconnect()
			
			Modules.InteractionSpeed:startRunner()
			Modules.ActionSpeed:startRunner()
			Modules.Speed:startRunner()
			Modules.Setup:spawnMap()
		end
		
	end)
end

function refreshServerStatus()
	
	Runner.ServerStatus = RunService.Heartbeat:Connect(function()
		
		if (not initialized or isRunning) then
			return
		end
		
		if ((os.time() - Runner.ServerUpdate) > 5) then
			Runner.ServerUpdate = os.time()
			forceServerStatus(false)
		end
	end)

end

function addToServerList(List, Data, PlayerID)

	PlayerID = tostring(PlayerID)

	if (List == nil) then
		List = {}
	end

	List[PlayerID] = {}
	List[PlayerID] = Data

	return List
end

function getServerList()

	local ServerList = DataStoreService:GetDataStore(Modules.GlobalVariables.Datastores.ServerList)

	local success, output = pcall(function()
		return ServerList:GetAsync("Default")
	end)

	if (success) then
		return output
	end

	return nil
end

initialize()
game.Players.PlayerAdded:Connect(onJoin)
game.Players.PlayerRemoving:Connect(onQuit)