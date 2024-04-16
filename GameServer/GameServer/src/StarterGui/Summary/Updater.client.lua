local Gameplay = require(game.ReplicatedStorage.Prefabs["Client Functions"])
local PlayersFolder = script.Parent.MainFrame
local MainFrame = script.Parent.MainFrame
local Players = game:GetService("Players")

local LocalPlayer = game.Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local ClientEvents = Backpack:WaitForChild("Events")

function onJoin(Player)
	
	local LocalMatchPlayer = Gameplay:getMatchPlayer(LocalPlayer.UserId)
	local MatchPlayers = game.ReplicatedStorage.Match.Players
	
	repeat task.wait()
	until MatchPlayers:FindFirstChild(Player.Name) ~= nil

	if (PlayersFolder:FindFirstChild(Player.Name) ~= nil) then
		return
	end

	for i, UIPlayer in pairs(PlayersFolder:GetChildren()) do
		if (UIPlayer.Name == "Empty") then
			
			local Points = MatchPlayers[Player.Name]:GetAttribute("Credits")
			local ID = MatchPlayers[Player.Name]:GetAttribute("ID")

			local ThumbType = Enum.ThumbnailType.HeadShot
			local ThumbSize = Enum.ThumbnailSize.Size100x100
			local Icon = Players:GetUserThumbnailAsync(Player.UserId, ThumbType, ThumbSize)

			UIPlayer.PlayerImage.Image = Icon
			UIPlayer.Name = Player.Name
			UIPlayer.PlayerName.Text = Player.Name
			UIPlayer.PlayerScore.Text = Points

			UIPlayer.Visible = true
			UIPlayer.PlayerName.Visible = true
			UIPlayer.PlayerScore.Visible = true
			UIPlayer.PlayerCharacter.Visible = true
			break	
		end
	end

end

function onLeave(Player)

	for i, UIPlayer in pairs(PlayersFolder:GetChildren()) do
		if (UIPlayer.Name == Player.Name) then
			UIPlayer.Name = "Empty"
			UIPlayer.Visible = false
		end
	end

end

function onRenderUpdate()

	if (not Gameplay:isRunning()) then
		return
	end

	local LocalMatchPlayer = Gameplay:getMatchPlayer(LocalPlayer.UserId)
	local CurrentRole = Gameplay:getRole(LocalMatchPlayer)
	local MatchPlayers = Gameplay:getMatchPlayers()

	for i, Player in pairs(Players:GetPlayers()) do
		onJoin(Player)
	end

	for i, MatchPlayer in pairs(MatchPlayers) do
		updatePoints(MatchPlayer)
	end
end

function updatePoints(Player)
	
	local UIPlayer = PlayersFolder[Player.Name]
	local MatchPlayer = game.ReplicatedStorage.Match.Players[Player.Name]
	local Character = MatchPlayer:GetAttribute("Character")
	local Points = MatchPlayer:GetAttribute("Credits")
	
	Points = string.format("%0.0f", Points)
	
	UIPlayer.PlayerCharacter.Text = Character
	UIPlayer.PlayerScore.Text = Points
	
	local MatchStats = game.ReplicatedStorage:WaitForChild("Match"):WaitForChild("MatchStats")
	local Timer = MatchStats:GetAttribute("Timer")
	local Map = MatchStats:GetAttribute("Map")
	
	local Minutes = math.floor(Timer / 60)
	local Seconds = math.floor(math.clamp(Timer - (Minutes * 60), 0, math.huge))
	
	Minutes = string.format("%0.2i", Minutes)
	Seconds = string.format("%0.2i", Seconds)
	
	MainFrame.Timer.Text = "Timer:	" .. Minutes .. ":" .. Seconds
	MainFrame.Map.Text = "Map:	" .. Map
	
	
end

game.Players.PlayerAdded:Connect(onJoin)
ClientEvents.RenderTick.Event:Connect(onRenderUpdate)