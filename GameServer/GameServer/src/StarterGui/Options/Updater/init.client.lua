local Gameplay = require(game.ReplicatedStorage.Prefabs["Client Functions"])
local PlayerList = require(script.PlayerList)
local Settings = require(script.Settings)

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Remotes = game.ReplicatedStorage.Remotes
local RequestData = Remotes.RequestData

local BaseFrame = script.Parent.BaseFrame
local Screen = BaseFrame.Screen

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local isRunning = false
local Profile = nil
local Binds = nil

function onInputBegin(InputObj: InputObject)
	
	if (Profile == nil or Binds == nil) then
		Profile = RequestData:InvokeServer("Profile")
		Binds = RequestData:InvokeServer("Binds")
		return
	end
	
	if (Gameplay:getMatchTimer() < 1) then
		return
	end
	
	local Keycode = InputObj.KeyCode
	local PauseBinds = {Binds.Keyboard.Scoreboard, Binds.Controller.Scoreboard}
	
	local MatchPlayer = Gameplay:getMatchPlayer(Player.UserId)
	local MaxHealth = Gameplay:getMaxHealth(MatchPlayer)
	local Role = Gameplay:getRole(MatchPlayer)
	
	if (table.find(PauseBinds, Keycode.Value)) then
		local NewState = not PlayerGui.Options.Enabled
		
		if (NewState == true) then
			Settings:prepareGeneral()
			Settings:prepareBinds()
		else
			Settings:SaveSettings()
		end
		
		if (Role == "Prey") then
			if (MaxHealth > 0) then
				PlayerGui.GameUI.Enabled = not NewState
				PlayerGui.Options.Enabled = NewState
			else
				PlayerGui.Options.Enabled = true
				PlayerGui.GameUI.Enabled = false
				ShowAsSummary()
			end
		else
			if (Gameplay:isRunning()) then
				PlayerGui.GameUI.Enabled = not NewState
				PlayerGui.Options.Enabled = NewState
			else
				PlayerGui.Options.Enabled = true
				PlayerGui.GameUI.Enabled = false
				ShowAsSummary()
			end
		end
	end
end

function updateBinds(Sent)
	Binds = Sent
end

function updateProfile(Sent)
	Profile = Sent
end

function ExitPressed()
	Remotes.ExitLobby:FireServer()
end

function SpectatePressed()
	PlayerGui.SpectatorUI.Enabled = true
	PlayerGui.Options.Enabled = false
end

function RevealAll()
	if (not isRunning) then
		return
	end

	for i, v in pairs(Players:GetPlayers()) do
		PlayerList:Reveal(v)
	end
	ShowAsSummary()
end

function ShowAsSummary()
	for i, v in pairs(Screen.Categories:GetChildren()) do
		if (not v:isA("TextButton")) then
			continue
		end

		local Button: TextButton = v
		Button.Visible = false
	end

	Screen.Categories.SummaryText.Visible = true
end

function WaitForStart()
	
	local Runner
	Runner = RunService.Heartbeat:Connect(function()
		if (Gameplay:isRunning() or Gameplay:getMatchTimer() > 1) then
			for i, v in pairs(game.Players:GetPlayers()) do
				PlayerList.add(v)
				Profile = RequestData:InvokeServer("Profile")
				Binds = RequestData:InvokeServer("Binds")
			end
			if (Runner ~= nil) then
				Runner:Disconnect()
				Runner = nil
				UpdateTimer()
			end
		end
		
	end)
end

function UpdateTimer()
	RunService.Heartbeat:Connect(function()
		
		if (Gameplay:isRunning()) then
			isRunning = true
		else
			RevealAll()
		end
		
		local BaseFrame = script.Parent.BaseFrame
		local MatchScreen = BaseFrame.Screen.Match

		local MatchStats = game.ReplicatedStorage:WaitForChild("Match"):WaitForChild("MatchStats")
		local Timer = MatchStats:GetAttribute("Timer")
		local Map = MatchStats:GetAttribute("Map")

		local Minutes = math.floor(Timer / 60)
		local Seconds = math.floor(math.clamp(Timer - (Minutes * 60), 0, math.huge))

		Minutes = string.format("%0.2i", Minutes)
		Seconds = string.format("%0.2i", Seconds)

		MatchScreen.Timer.Text = Minutes .. ":" .. Seconds
		MatchScreen.Map.Text = Map
	end)
end

WaitForStart()

for i, v in pairs(Screen.Categories:GetChildren()) do
	if (not v:isA("TextButton")) then
		continue
	end
	
	local Button: TextButton = v
	Button.MouseButton1Click:Connect(function()
		local isMatch = (Button.Name == "Match")
		local isGeneral = (Button.Name == "General")
		local isControls = (Button.Name == "Controls")
	
		Settings:showSettings(isGeneral, isControls, isMatch)
	end)
end

Screen.Spectate.MouseButton1Click:Connect(SpectatePressed)
Screen.Quit.MouseButton1Click:Connect(ExitPressed)
UserInputService.InputBegan:Connect(onInputBegin)
Remotes.updateBind.OnClientInvoke = updateBinds
Remotes.updateSettings.OnClientInvoke = updateProfile