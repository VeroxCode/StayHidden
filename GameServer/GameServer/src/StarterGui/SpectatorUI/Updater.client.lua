local Gameplay = require(game.ReplicatedStorage.Prefabs["Client Functions"])
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local CurrentCamera = workspace.CurrentCamera
local CurrentIndex = 1

local Runner = nil
local CurrentSpectate = nil

function onToggle()
	
	if (not Gameplay:isRunning()) then
		return
	end
	
	if (script.Parent.Enabled) then
		NextPressed()
		TickSpectate()
	else
		CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
	end
end

function InputBegin(InputObject, Processed)
	
	local KeyCode = InputObject.KeyCode
	
	if (KeyCode.Value == Enum.KeyCode.ButtonL1.Value) then
		PreviousPressed()
	end
	
	if (KeyCode.Value == Enum.KeyCode.ButtonR1.Value) then
		NextPressed()
	end
	
	if (InputObject.KeyCode.Value == Enum.KeyCode.A.Value) then
		PreviousPressed()
	end
	
	if (InputObject.KeyCode.Value == Enum.KeyCode.D.Value) then
		NextPressed()
	end
	
end

function PreviousPressed()
	
	local SpectatorList = getSpectatorList()
	
	local LocalMatchPlayer = Gameplay:getMatchPlayer(LocalPlayer.UserId)
	local MaxHealth = Gameplay:getMaxHealth(LocalMatchPlayer)
	local Escaped = Gameplay:isEscaped(LocalMatchPlayer)

	if (not Escaped or MaxHealth > 0) then
		return
	end
	
	if (#SpectatorList <= 0) then
		CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
		PlayerGui.SpectatorUI.Enabled = false
		PlayerGui.Options.Enabled = true
		return
	end
	
	if (CurrentIndex == 1) then
		CurrentIndex = #SpectatorList
	else
		CurrentIndex = math.clamp(CurrentIndex - 1, 1, #SpectatorList)
	end
	
	local Player = SpectatorList[CurrentIndex].Character
	CurrentCamera.CameraSubject = Player.Humanoid
	CurrentSpectate = Player
	script.Parent.MainFrame.Frame.PlayerName.Text = Player.Name
	
end

function NextPressed()
	
	local SpectatorList = getSpectatorList()
	
	local LocalMatchPlayer = Gameplay:getMatchPlayer(LocalPlayer.UserId)
	local MaxHealth = Gameplay:getMaxHealth(LocalMatchPlayer)
	local Escaped = Gameplay:isEscaped(LocalMatchPlayer)

	if (not Escaped or MaxHealth > 0) then
		return
	end
	
	if (#SpectatorList <= 0) then
		CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
		PlayerGui.SpectatorUI.Enabled = false
		PlayerGui.Options.Enabled = true
		return
	end
	
	if (CurrentIndex >= #SpectatorList) then
		CurrentIndex = 1
	else
		CurrentIndex = math.clamp(CurrentIndex + 1, 1, #SpectatorList)
	end

	local Player = SpectatorList[CurrentIndex].Character
	CurrentCamera.CameraSubject = Player.Humanoid
	CurrentSpectate = Player
	script.Parent.MainFrame.Frame.PlayerName.Text = Player.Name
	
end

function ExitPressed()
	CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
	PlayerGui.SpectatorUI.Enabled = false
	PlayerGui.Options.Enabled = true
end

function getSpectatorList()
	
	local List = {}
	
	for i, v in pairs(Players:GetPlayers()) do
		
		local MatchPlayer = Gameplay:getMatchPlayer(v.UserId)
		
		if (MatchPlayer ~= nil) then
			local Role = Gameplay:getRole(MatchPlayer)
			
			if (Role == "Hunter") then
				continue
			end
			
			if (Role == "Prey" and Gameplay:getMaxHealth(MatchPlayer) > 0 and not Gameplay:isEscaped(MatchPlayer)) then
				table.insert(List, v)
			end
		end
	end
	return List
end

function TickSpectate()
	
	if (CurrentSpectate == nil) then
		return
	end
	
	if (Runner == nil) then
		Runner = game["Run Service"].Heartbeat:Connect(function()
			
			local LocalMatchPlayer = Gameplay:getMatchPlayer(LocalPlayer.UserId)
			local MaxHealth = Gameplay:getMaxHealth(LocalMatchPlayer)
			local Escaped = Gameplay:isEscaped(LocalMatchPlayer)
			
			if (not Escaped or MaxHealth > 0) then
				return
			end
			
			if (#getSpectatorList() <= 0) then
				ExitPressed()
				Runner:Disconnect()
				Runner = nil
				return
			end
			
			local MatchPlayer = Gameplay:getMatchPlayer(game.Players[CurrentSpectate.Name].UserId)
			local MaxHealth = 0
			
			if (MatchPlayer ~= nil) then
				MaxHealth = Gameplay:getMaxHealth(MatchPlayer)
			end
			
			if (MaxHealth <= 0 or Gameplay:isEscaped(MatchPlayer)) then
				NextPressed()
			end
		end)
	end
end

script.Parent:GetPropertyChangedSignal("Enabled"):Connect(onToggle)
script.Parent.MainFrame.Frame.Previous.MouseButton1Click:Connect(PreviousPressed)
script.Parent.MainFrame.Frame.Next.MouseButton1Click:Connect(NextPressed)
script.Parent.MainFrame.Frame.Exit.MouseButton1Click:Connect(ExitPressed)