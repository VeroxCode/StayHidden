local Global_Variables = require(game.ServerScriptService["Global"]:WaitForChild("Global Variables"))
local PlayFabServer = require(game.ServerScriptService.PlayFab:WaitForChild("PlayFabServerApi"))
local Notifications = require(game.ServerScriptService.Handlers:WaitForChild("Notifications"))
local SaveStorage = require(game.ServerScriptService.Handlers:WaitForChild("Save Storage"))
local BindStorage = require(game.ServerScriptService.Handlers:WaitForChild("Bind Storage"))
local SaveState = require(game.ServerScriptService.Handlers:WaitForChild("SaveState"))
local PlayFab = require(game.ServerScriptService.Handlers:WaitForChild("PlayFab"))
local Utils = require(game.ServerScriptService.Handlers:WaitForChild("Utils"))
local json = require(game.ServerScriptService.PlayFab:WaitForChild("json"))

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ActiveProfileKey = Global_Variables.ActiveProfileKey

function onJoin(Player)
	
	if (not LoginUser(Player)) then
		return
	end
	
	local PlayFabID = PlayFab:getPlayFabID(Player.UserId)
	task.wait(3)
	LoadSave(Player, PlayFabID)
	task.wait(3)
	LoadBinds(Player, PlayFabID)
end

function LoginUser(Player)
	local PFPlayer
	local success, _ = pcall(function()
		PFPlayer = Players:GetPlayerByUserId(Player.UserId)
	end)

	if (not success) then
		Player:Kick("Something went wrong. Please try again!")
		return false
	end

	if (PFPlayer.Name == nil or PFPlayer.UserId == nil) then
		Player:Kick("Something went wrong. Please try again!")
		return false
	end

	PlayFab.loginPlayer(PFPlayer.UserId, PFPlayer.Name)
	workspace:SetAttribute("LoggedIn", true)
	
	return true
end

function LoadSave(Player, PlayFabID)
	
	local SaveStateTable = PlayFab:getData(PlayFabID, ActiveProfileKey)
	local DefaultTable = SaveState.Default
	
	task.wait(1)
	
	if (SaveStateTable == nil or SaveStateTable == "null") then
		print("Missing Save Data")
		PlayFab.setData(PlayFabID, ActiveProfileKey, json.encode(DefaultTable))
		SaveStateTable = DefaultTable
	else
		SaveStateTable = json.decode(SaveStateTable)
	end
	
	FillMissingKeys(Player.UserId, SaveStateTable, DefaultTable)
	
	if (SaveStateTable == nil) then
		return Player:Kick("Something went wrong. Please try again!")
	end
	
	SaveStorage.add(Player.UserId, SaveStateTable)
	SaveStateTable = json.encode(SaveStateTable)
	PlayFab.setData(PlayFabID, ActiveProfileKey, SaveStateTable)
	workspace:SetAttribute("LoadedSave", true)
	
end

function LoadBinds(Player, PlayFabID)
	
	local BindTable = PlayFab:getData(PlayFabID, "Binds")
	local DefaultBinds = SaveState.DefaultBinds
	
	task.wait(1)
	
	if (BindTable == nil or BindTable == "null") then
		warn(`Binds Missing for {Player.Name} | {BindTable}`)
		PlayFab.setData(PlayFabID, "Binds", json.encode(DefaultBinds))
		BindTable = DefaultBinds
	else
		BindTable = json.decode(BindTable)
	end
	
	FillMissingKeys(Player.UserId, BindTable, DefaultBinds)
	
	if (BindTable == nil) then
		return Player:Kick("Something went wrong. Please try again!")
	end
	
	BindStorage:add(Player.UserId, BindTable)
	BindTable = json.encode(BindTable)
	PlayFab.setData(PlayFabID, "Binds", BindTable)
	workspace:SetAttribute("LoadedBinds", true)
	
end

function saveGameServer(Profile, Player)
	
	local Credits = require(game.ServerScriptService["Gameplay Server"].Managers:WaitForChild("Credit Manager"))
	local GameUtils = require(game.ServerScriptService["Gameplay Server"].Utils:WaitForChild("Game Functions"))
	local MatchPlayer = GameUtils:getMatchPlayer(Player.UserId)
	local ServerPlayer = GameUtils:getServerPlayer(Player.UserId)
	
	if (MatchPlayer == nil or ServerPlayer == nil) then
		return Profile
	end
	
	local CurrentCredits = Credits:getCredits(Player.UserId)
	local Role = GameUtils:getRole(MatchPlayer)

	if (GameUtils:isRunning()) then
		if (Role == "Prey") then
			GameUtils:setMaxHealth(MatchPlayer, 0)
			Profile.Statistics.S_GamesPlayed += 1
		else
			Profile.Statistics.K_GamesPlayed += 1
		end
		
		Profile = Utils:giveExp(Player, Role, Profile, (CurrentCredits * 0.1))
		Profile = Utils:giveAccountExp(Player, Profile, (CurrentCredits * 0.1))
		
		local NewCredits = math.ceil(Profile.Account.Credits + CurrentCredits)
		local Earned = math.ceil(Profile.Statistics.CreditsEarned + CurrentCredits)

		Profile.Statistics.CreditsEarned = math.ceil(Earned)
		Profile.Account.Credits = math.ceil(NewCredits)
		
		Credits:setCredits(Player.UserId, 0)
	end
	
	MatchPlayer:Destroy()
	ServerPlayer:Destroy()
	
	SaveStorage:update(Player.UserId, Profile)
	return Profile
end

function saveAll(Player)
	
	local id = PlayFab:getPlayFabID(Player.UserId)
	local Profile = SaveStorage:get(Player.UserId)
	local Binds = BindStorage:get(Player.UserId)

	if (workspace:GetAttribute("isGameServer")) then
		Profile = saveGameServer(Profile, Player)
	end
	
	if (Binds ~= nil) then
		local updateBinds = json.encode(Binds)
		PlayFab.setData(id, "Binds", updateBinds)
	end
	
	Profile.Account.lastSession = os.time()
	local updateState = json.encode(Profile)
	PlayFab.setData(id, ActiveProfileKey, updateState)
	
	print("Data Saved on Quit " .. Player.Name)
end

function FillMissingKeys(PlayerID, Branch, Default)
	
	for key, value in pairs(Default) do
		if (Branch[key] ~= nil) then
			if (typeof(value) == "table") then
				Branch[key] = FillMissingKeys(PlayerID, Branch[key], Default[key])
			end
		else
			Branch[key] = Default[key]
		end
	end
	return Branch
end

function onLeave(Player)
	saveAll(Player)
end

game:BindToClose(function()
	for i, v in (Players:GetPlayers()) do
		saveAll(v)
		task.wait(0.1)
	end
end)

if (game.ServerStorage.Events:FindFirstChild("SaveData") ~= nil) then
	game.ServerStorage.Events:FindFirstChild("SaveData").Event:Connect(saveAll)
end

Players.ChildRemoved:Connect(onLeave)
Players.PlayerAdded:Connect(onJoin)
Players.PlayerRemoving:Connect(onLeave)