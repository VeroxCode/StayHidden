local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Remotes = game.ReplicatedStorage.Remotes
local UpdateRunner = nil
local lastUpdate = 0

local this = {}

function this:constructServerlist()
	
	local Servers = Remotes.RequestServerlist:InvokeServer()
	local BuiltArray = buildArray(Servers)
	local Servers = sortServerList(BuiltArray)
	local PartyMembers = Remotes.Party.RetrieveMembers:InvokeServer()
	
	local ServerBrowser = LocalPlayer.PlayerGui.ServerBrowser
	local ServerList = ServerBrowser.BaseFrame.List.ScrollingFrame
	local Prefab = ServerList.Prefab
	
	ServerList.NoServers.Visible = true
	for i, v in pairs(ServerList.List:GetChildren()) do
		if (v:isA("Frame")) then
			v:Destroy()
		end
	end
	
	ServerBrowser.BaseFrame.List.Refresh.MouseButton1Click:Connect(function()
		this:refresh()
	end)
	
	for index, lobby in pairs(Servers) do
		
		print(`SERVER: {lobby.UserId} | {lobby.Players} | {(os.time() - lobby.LastUpdate)}`)
		
		local Slots = 3 - lobby.Players
		local timeSinceUpdate = (os.time() - lobby.LastUpdate)
		local LobbyName = Players:GetNameFromUserIdAsync(tonumber(lobby.UserId))
		
		if (#PartyMembers <= Slots and timeSinceUpdate <= 60) then
			local ListedServer = Prefab:Clone()
			ListedServer.Players.Text = `{lobby.Players}/3`
			ListedServer.UserName.Text = LobbyName
			ListedServer.Parent = ServerList.List
			ListedServer.Visible = true
			ServerList.NoServers.Visible = false
			
			ListedServer.Join.MouseButton1Click:Connect(function()
				warn(`Joining {lobby.UserId}`)
				Remotes.Party.SendServer:InvokeServer(tonumber(lobby.UserId))
			end)
		end
	end
	
end

function buildArray(Servers)
	
	if (Servers == nil) then
		return
	end
	
	local Array = {}
	
	for i, v in pairs(Servers) do
		v.UserId = tostring(i)
		Array[#Array + 1] = v
	end
	
	return Array
end

function sortServerList(Servers)
	
	if (Servers == nil) then
		return
	end
	
	for i, v in pairs(Servers) do
		local currentIndex = Servers[math.clamp(i, 0, #Servers)]
		local nextIndex = Servers[math.clamp(i + 1, 0, #Servers)]
		
		if (nextIndex.Players > currentIndex.Players) then
			Servers[i] = nextIndex
			Servers[i + 1] = currentIndex
		end
	end
	
	return Servers
end

function this:startAutoRefresh()
	
	if (UpdateRunner ~= nil) then
		return
	end
	
	UpdateRunner = RunService.Heartbeat:Connect(function()
		
		if ((os.time() - lastUpdate) <= 10) then
			return
		end
		
		print("auto refresh")
		
		lastUpdate = os.time()
		this:constructServerlist()
	end)
end

function this:refresh()
	
	print("manual refresh")
	
	lastUpdate = os.time()
	this:constructServerlist()
end

function this:disconnectRefresh()
	
	if (UpdateRunner == nil) then
		return
	end
	
	UpdateRunner:Disconnect()
	
end

return this
