local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Matchmaking = require(script.Parent.Matchmaking)

local ClientParty = game.ReplicatedStorage.Remotes.Party
local LocalPlayer = Players.LocalPlayer

local Empty = "rbxassetid://15891053995"

local PartyData = {
	Host = 0;
	LobbyID = 0;
	Members = {};
}

local this = {}

function this:createFriendlist()
	
	local Main = LocalPlayer.PlayerGui:WaitForChild("Main").BaseFrame
	local FriendList = Main.Separator.FriendList.ScrollingFrame
	local Prefab = FriendList.Prefab
	
	for i, v in pairs(FriendList.List:GetChildren()) do
		if (v:isA("TextLabel")) then
			v:Destroy()
		end
	end
	
	local Friends = LocalPlayer:GetFriendsOnline()
	
	for index, friend in pairs(Friends) do
		if (friend.IsOnline) then
			local FriendSlot = Prefab:Clone()
			FriendSlot.Name = friend.DisplayName
			FriendSlot.Text = friend.DisplayName
			FriendSlot.Parent = FriendList.List
			FriendSlot.Visible = true
			FriendSlot.Invite.MouseButton1Click:Connect(function()
				this:invitePlayer(friend.VisitorId)
			end)
		end
	end
	
end

function this:addToPartyList(PlayerID)
	
	local Slots = this:getAvailableSlots()
	
	if (this:isInPartyList(PlayerID)) then
		return
	end
	
	if (#Slots > 0) then
		local Slot: ImageButton = Slots[1]
		Slot:SetAttribute("PlayerID", PlayerID)
		Slot.Image = Players:GetUserThumbnailAsync(PlayerID, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		
		Slot.Kick.MouseButton1Click:Connect(function()
			this:kickPlayer(Slot:GetAttribute("PlayerID"))
		end)
		
	end
	
end

function this:removeFromPartyList(PlayerID)
	local Main = LocalPlayer.PlayerGui:WaitForChild("Main").BaseFrame
	local PartyList = Main.Separator.PartyList

	for i, v in pairs(PartyList:GetChildren()) do
		if (v:isA("ImageButton") and string.find(v.Name, "Slot")) then
			if (v:GetAttribute("PlayerID") == PlayerID) then
				v:SetAttribute("PlayerID", 0)
				v.Kick.Visible = false
				v.Image = Empty
			end
		end
	end
end

function this:isInPartyList(PlayerID)
	local Main = LocalPlayer.PlayerGui:WaitForChild("Main").BaseFrame
	local PartyList = Main.Separator.PartyList

	for i, v in pairs(PartyList:GetChildren()) do
		if (v:isA("ImageButton") and string.find(v.Name, "Slot")) then
			if (v:GetAttribute("PlayerID") == PlayerID) then
				return true
			end
		end
	end
	
	return false
end

function this:getAvailableSlots()
	
	local Slots = {}
	
	local Main = LocalPlayer.PlayerGui:WaitForChild("Main").BaseFrame
	local PartyList = Main.Separator.PartyList
	
	for i, v in pairs(PartyList:GetChildren()) do
		if (v:isA("ImageButton") and string.find(v.Name, "Slot")) then
			if (v:GetAttribute("PlayerID") == 0) then
				table.insert(Slots, v)
			end
		end
	end
	
	return Slots
	
end

function this:clearPartySlots()

	local Main = LocalPlayer.PlayerGui:WaitForChild("Main").BaseFrame
	local PartyList = Main.Separator.PartyList

	for i, v in pairs(PartyList:GetChildren()) do
		if (v:isA("ImageButton") and string.find(v.Name, "Slot")) then
			v:SetAttribute("PlayerID", 0)
			v.Kick.Visible = false
			v.Image = Empty
		end
	end

end

function this:leaveParty()
	this:clearPartySlots()
	this:addToPartyList(LocalPlayer.UserId)
	ClientParty.LeaveParty:InvokeServer()
end

function this:invitePlayer(Recipient)
	ClientParty.ShowInvite:InvokeServer(Recipient)
end

function this:kickPlayer(Recipient)
	ClientParty.KickMember:InvokeServer(Recipient)
end

function this:showKickPrompts(isHost)
	
	local Main = LocalPlayer.PlayerGui:WaitForChild("Main").BaseFrame
	local PartyList = Main.Separator.PartyList

	for i, v in pairs(PartyList:GetChildren()) do
		if (v:isA("ImageButton") and string.find(v.Name, "Slot")) then
			if ((v:GetAttribute("PlayerID") ~= 0 and v:GetAttribute("PlayerID") ~= LocalPlayer.UserId) and isHost) then
				v.Kick.Visible = true
			else
				v.Kick.Visible = false
			end
		end
	end
end

function promptInvitation(Data)
	
	local Prefab = script.Invitation:Clone()
	Prefab.Frame.TextLabel.Text = `{Players:GetNameFromUserIdAsync(Data.Host)} Sent you a Party Invitation!`
	Prefab.Parent = LocalPlayer.PlayerGui.Main.BaseFrame
	
	Prefab.Frame.Accept.MouseButton1Click:Connect(function()
		ClientParty.AcceptInvite:InvokeServer(Data)
		Prefab:Destroy()
	end)
	
	Prefab.Frame.Deny.MouseButton1Click:Connect(function()
		Prefab:Destroy()
	end)
	
end

function onInviteAccept(Data)
	
	PartyData.LobbyID = Data.LobbyID
	PartyData.Members = Data.Members
	PartyData.Host = Data.Host
	
	for i, member in pairs(PartyData.Members) do
		this:addToPartyList(member)
	end
	
end

function syncParty(Data)
	
	Matchmaking:constructServerlist()
	
	local Main = LocalPlayer.PlayerGui:WaitForChild("Main").BaseFrame
	local PartyList = Main.Separator.PartyList
	
	PartyData.Members = Data.Members
	PartyData.Host = Data.Host
	
	this:clearPartySlots()
	
	for i, member in pairs(Data.Members) do
		this:addToPartyList(member)
	end
	
	PartyList.Separator.LeaveParty.Visible = #PartyData.Members > 1
	this:showKickPrompts(Data.Host == LocalPlayer.UserId)
end

ClientParty.ShowInvite.OnClientInvoke = promptInvitation
ClientParty.AcceptInvite.OnClientInvoke = onInviteAccept
ClientParty.SyncParty.OnClientInvoke = syncParty

return this
