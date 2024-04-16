local Gameplay = require(game.ReplicatedStorage.Prefabs["Client Functions"])
local Settings = require(script.Parent.Settings)

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Remotes = game.ReplicatedStorage.Remotes
local RequestData = Remotes.RequestData

local Assets = game.ReplicatedStorage.Assets
local Icons = Assets.Icons

local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local PlayerList = {}

function PlayerList.add(Player: Player)
	
	local BaseFrame = script.Parent.Parent.BaseFrame
	local MatchScreen = BaseFrame.Screen.Match
	local List = MatchScreen.List
	local Prefab = MatchScreen.PlayerPrefab
	
	if (List:FindFirstChild(Player.Name) ~= nil) then
		return
	end
	
	local LocalMatchPlayer = Gameplay:getMatchPlayer(LocalPlayer.UserId)
	local MatchPlayer = Gameplay:getMatchPlayer(Player.UserId)
	local Character = MatchPlayer:GetAttribute("Character")
	
	local ListPlayer = Prefab:Clone()
	ListPlayer.Name = Player.Name
	ListPlayer.Parent = List
	
	ListPlayer.PlayerName.Text = Player.Name
	PlayerList:updatePoints(ListPlayer, MatchPlayer)
	
	if (Gameplay:getRole(LocalMatchPlayer) == Gameplay:getRole(MatchPlayer)) then
		ListPlayer.Character.Image = Icons.Power[Character].Texture
		PlayerList:setPerks(ListPlayer, MatchPlayer)
	end
	
	ListPlayer.Visible = true
	
end

function PlayerList:setPerks(ListPlayer, MatchPlayer)
	
	local Perks = MatchPlayer.Perks
	
	for i, slot in Perks:GetChildren() do
		local UIPerks = ListPlayer.Perks
		local PerkName = slot:GetAttribute("Name")
		
		if (PerkName == "" or Icons.Perk:FindFirstChild(PerkName) == nil) then
			UIPerks[slot.Name].Image = "rbxassetid://16269352918"
		else
			UIPerks[slot.Name].Image = Icons.Perk[PerkName].Texture
		end
	end
end

function PlayerList:Reveal(Player)
	
	local BaseFrame = script.Parent.Parent.BaseFrame
	local MatchScreen = BaseFrame.Screen.Match
	local List = MatchScreen.List
	local ListPlayer = List:FindFirstChild(Player.Name)
	
	if (ListPlayer == nil) then
		return
	end
	
	local MatchPlayer = Gameplay:getMatchPlayer(Player.UserId)
	local Character = MatchPlayer:GetAttribute("Character")
	
	ListPlayer.Character.Image = Icons.Power[Character].Texture
	PlayerList:setPerks(ListPlayer, MatchPlayer)
	
end

function PlayerList:updatePoints(ListPlayer, MatchPlayer)
	
	local Runner
	
	local function Disconnect(Player)
		if (Player.Name == ListPlayer.Name) then
			
			if (Runner == nil) then
				return
			end
			
			Runner:Disconnect()
			Runner = nil
		end
	end
	
	Runner = RunService.RenderStepped:Connect(function()
		local Points = MatchPlayer:GetAttribute("Credits")
		Points = string.format("%0.0f", Points)
		
		ListPlayer.PlayerPoints.Text = Points
	end)
	
	Players.PlayerRemoving:Connect(Disconnect)
	
end

return PlayerList
