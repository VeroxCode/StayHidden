local MemoryStoreService = game:GetService("MemoryStoreService")
local DataStoreService = game:GetService("DataStoreService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local Global = require(game.ServerScriptService.Global["Global Variables"])
local Remotes = game.ReplicatedStorage.Remotes
local Events = game.ServerStorage.Events

function onRequest()
	local DefaultList = getServerListClient()
	return DefaultList
end

function joinLobbyPool(Player)
	local Data = Global.ServerTable
	Data.ServerCode = TeleportService:ReserveServer(Global.Places.Live_GameServer)
	Data.LastUpdate = os.time()
	
	local ServerList = DataStoreService:GetDataStore(Global.Datastores.ServerList)
	local DefaultList = getServerListServer()
	
	local success, errorMsg = pcall(function()
		ServerList:SetAsync("Default", addToServerList(DefaultList, Data, Player.UserId))
	end)
	
	if (success) then
		local MMKTable = Global.MatchMakingTable
		MMKTable.Hunter = true
		MMKTable.GroupIDs = {}
		
		Events.SaveData:Fire(Player)
		
		task.wait(5)
		
		TeleportService:TeleportToPrivateServer(Global.Places.Live_GameServer, Data.ServerCode, {Player}, nil, "Hunter")
	end
	
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

function getServerListClient()
	
	local ServerList = DataStoreService:GetDataStore(Global.Datastores.ServerList)
	
	local success, output = pcall(function()
		return ServerList:GetAsync("Default")
	end)
	
	if (success) then
		for i, v in pairs(output) do
			v.ServerCode = 0
		end
		
		return output
	end

	return nil
end

function getServerListServer()

	local ServerList = DataStoreService:GetDataStore(Global.Datastores.ServerList)

	local success, output = pcall(function()
		return ServerList:GetAsync("Default")
	end)

	if (success) then
		return output
	end
	
	return nil
end

Remotes.GetServerList.OnInvoke = getServerListServer
Remotes.RequestServerlist.OnServerInvoke = onRequest
Remotes.JoinServerPool.OnServerEvent:Connect(joinLobbyPool)