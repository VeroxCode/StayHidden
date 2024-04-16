local DataStoreService = game:GetService("DataStoreService")
local MessagingService = game:GetService("MessagingService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Global = require(game.ServerScriptService.Global["Global Variables"])
local Remotes = game.ReplicatedStorage.Remotes
local Events = game.ServerStorage.Events
local ClientParty = Remotes.Party

local PartyData = {
	Host = 0;
	LobbyID = 0;
	Members = {};
}

function onPlayerJoin(Player)
	resetParty(Player)
end

function onPlayerQuit(Player)
	leaveParty(Player)
end

function onShutdown()
	for i, v in (Players:GetPlayers()) do
		leaveParty(v)
	end
end

function handlePartyCall(Message)
	
	local Data = Message.Data
	Data = HttpService:JSONDecode(Data)
	
	local ServerPlayer = game.Players:FindFirstChildOfClass("Player")
	
	warn("----- PARTY CALL -----")
	print(`TYPE: {Data.Type}`)
	print(`LOBBY: {Data.LobbyID} | {PartyData.LobbyID}`)
	print(`HOST: {Data.Host} | {PartyData.Host}`)
	
	if (Data.Type == "Invite") then
		if (ServerPlayer.UserId == Data.Recipient) then
			handleInvite(Data)
		end
	end
	
	if (Data.Type == "AcceptInvite") then
		if (PartyData.LobbyID == Data.LobbyID) then
			handleInviteAccept(Data)
		end
	end
	
	if (Data.Type == "Sync") then
		if (PartyData.LobbyID == Data.LobbyID) then
			handleSync(Data)
		end
	end
	
	if (Data.Type == "Kick") then
		if (PartyData.LobbyID == Data.LobbyID) then
			handleSync(Data)
		end
		
		if (ServerPlayer.UserId == Data.Recipient) then
			resetParty(ServerPlayer)
		end
		
	end
	
	if (Data.Type == "Leave") then
		if (PartyData.LobbyID == Data.LobbyID) then
			handleSync(Data)
		end
	end
	
	if (Data.Type == "Send") then
		if (PartyData.LobbyID == Data.LobbyID and Data.Sender == Data.Host) then
			handleSendParty(Data)
		end
	end
	
end

function sendInvite(Player, RecipientID)
	
	if (isInParty(RecipientID)) then
		return
	end
	
	local Data = {
		Type = "Invite";
		Host = PartyData.Host;
		Recipient = RecipientID;
		LobbyID = PartyData.LobbyID;
		Members = PartyData.Members;
	}
	
	MessagingService:PublishAsync("PartyCall", HttpService:JSONEncode(Data))
end

function handleInvite(Data)
	local ServerPlayer = game.Players:FindFirstChildOfClass("Player")
	
	ClientParty.ShowInvite:InvokeClient(ServerPlayer, Data)
end

function onInviteAccept(Player, Data)
	
	if (#PartyData.Members > 1) then
		leaveParty(Player)
	end
	
	PartyData.LobbyID = Data.LobbyID
	PartyData.Host = Data.Host
	
	local Data = {
		Type = "AcceptInvite";
		Recipient = Player.UserId;
		LobbyID = Data.LobbyID;
	}
	
	MessagingService:PublishAsync("PartyCall", HttpService:JSONEncode(Data))
	
end

function handleInviteAccept(Data)
	
	if (not isHost()) then
		return
	end
	
	table.insert(PartyData.Members, Data.Recipient)
	
	local Data = {
		Host = PartyData.Host;
		LobbyID = PartyData.LobbyID;
		Members = PartyData.Members;
	}
	
	syncParty(Data)
	
end

function syncParty(Data)
	Data.Type = "Sync"
	MessagingService:PublishAsync("PartyCall", HttpService:JSONEncode(Data))
end

function handleSync(Data)
	local ServerPlayer = game.Players:FindFirstChildOfClass("Player")
	
	if (#Data.Members <= 0) then
		return
	end
	
	PartyData.Members = Data.Members
	PartyData.Host = Data.Host
	
	ClientParty.SyncParty:InvokeClient(ServerPlayer, Data)
end

function kickMember(Player, RecipientID)
	
	local Data = {
		Type = "Kick";
		Host = PartyData.Host;
		Recipient = RecipientID;
		LobbyID = PartyData.LobbyID;
		Members = PartyData.Members;
	}
	
	if (Player.UserId == PartyData.Host) then
		if (isInParty(RecipientID)) then
			table.remove(Data.Members, table.find(Data.Members, RecipientID))
			MessagingService:PublishAsync("PartyCall", HttpService:JSONEncode(Data))
		end
	end
end

function leaveParty(Player)
	
	local Data = {
		Type = "Leave";
		Host = PartyData.Host;
		LobbyID = PartyData.LobbyID;
		Members = PartyData.Members;
	}
	
	table.remove(Data.Members, table.find(Data.Members, Player.UserId))
	
	if (Data.Host == Player.UserId) then
		if (#Data.Members > 0) then
			Data.Host = Data.Members[1]
		end
	end
	
	resetParty(Player)
	MessagingService:PublishAsync("PartyCall", HttpService:JSONEncode(Data))
	
end

function sendParty(Player, ServerID)
	
	print(ServerID)
	
	local Data = {
		Type = "Send";
		Host = PartyData.Host;
		ServerID = ServerID;
		Sender = Player.UserId;
		LobbyID = PartyData.LobbyID;
		Members = PartyData.Members;
	}
	
	handleSendParty(Data)
	MessagingService:PublishAsync("PartyCall", HttpService:JSONEncode(Data))
	
end

function handleSendParty(Data)
	
	local ServerList = Remotes.GetServerList:Invoke()
	local ServerPlayer = game.Players:FindFirstChildOfClass("Player")
	local ServerCode = ServerList[tostring(Data.ServerID)].ServerCode
	
	local MMKTable = Global.MatchMakingTable
	MMKTable.Hunter = false
	MMKTable.GroupIDs = {ServerPlayer.UserId}
	
	Events.SaveData:Fire(ServerPlayer)

	task.wait(5)
	
	TeleportService:TeleportToPrivateServer(Global.Places.Live_GameServer, ServerCode, {ServerPlayer}, nil, "Prey")
	
end

function resetParty(Player)
	
	if (Player == nil) then
		return
	end
	
	PartyData = {
		Host = Player.UserId;
		LobbyID = HttpService:GenerateGUID(false);
		Members = {};
	}
	
	table.insert(PartyData.Members, Player.UserId)
	ClientParty.SyncParty:InvokeClient(Player, PartyData)
	
end

function getPartyMembers()
	return PartyData.Members
end

function isInParty(PlayerID)
	return table.find(PartyData.Members, PlayerID) ~= nil
end

function isHost()
	return (PartyData.Host == game.Players:FindFirstChildOfClass("Player").UserId)
end

MessagingService:SubscribeAsync("PartyCall", handlePartyCall)
Players.PlayerAdded:Connect(onPlayerJoin)
Players.PlayerRemoving:Connect(onPlayerQuit)
game:BindToClose(onShutdown)

ClientParty.ShowInvite.OnServerInvoke = sendInvite
ClientParty.AcceptInvite.OnServerInvoke = onInviteAccept
ClientParty.SyncParty.OnServerInvoke = syncParty
ClientParty.KickMember.OnServerInvoke = kickMember
ClientParty.LeaveParty.OnServerInvoke = leaveParty
ClientParty.RetrieveMembers.OnServerInvoke = getPartyMembers
ClientParty.SendServer.OnServerInvoke = sendParty