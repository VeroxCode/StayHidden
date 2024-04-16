local Gameplay = require(game.ReplicatedStorage.Prefabs["Client Functions"])
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer.Backpack
local Events = Backpack.Events

local Remotes = game.ReplicatedStorage.Remotes
local Proximity = script:WaitForChild("Proximity")
local Chase = script:WaitForChild("Chase")
local Other = script:WaitForChild("Other")
local Menu = script:WaitForChild("Menu")

local CurrentlyPlaying = Chase.None
local GameVolume = 0.2

local StartChaseTween = nil
local EndChaseTween = nil
local Profile = nil

function onTick(delta)
	
	if (not Gameplay:isRunning()) then
		if (Other:FindFirstChild("PregameLobby") ~= nil and Gameplay:getMatchTimer() < 1) then
			Other.PregameLobby.Playing = true
		end
		stopSounds()
		adjustProximity(1000, false)
		return
	else
		if (Other:FindFirstChild("PregameLobby") ~= nil) then
			Other.PregameLobby:Destroy()
		end
	end
	
	if (Gameplay:getMatchTimer() < 10) then
		stopSounds()
		adjustProximity(1000, false)
		return
	end
	
	local MatchPlayer = Gameplay:getMatchPlayer(LocalPlayer.UserId)
	
	local ChaseTimer = Gameplay:getChaseTimer(MatchPlayer)
	local ChaseTheme = Gameplay:getChaseTheme()
	local inChase = Gameplay:inChase(MatchPlayer)
	local Role = Gameplay:getRole(MatchPlayer)
	
	if (Gameplay:isRunning()) then
		
		local playChaseDebug = workspace:GetAttribute("DebugStartHunter") and workspace:GetAttribute("DebugNeedHunter")
		
		if (Role == "Prey") then
			
			if (workspace:GetAttribute("Debug") and not playChaseDebug) then
				return
			end
			
			local HunterDistance = Gameplay:getHunterDistance(MatchPlayer)
			
			if (HunterDistance < Gameplay:getProximityRadius()) then
				stopAmbient()
				adjustProximity(HunterDistance, inChase)
			else
				playAmbient(Role)
			end
		else
			playAmbient(Role)
		end

		if (inChase) then
			playSound("Chase", ChaseTheme)
			stopAmbient()
		else
			stopSounds()
		end
	end
	
end

function stopSounds()
	for i, v in pairs(script:GetDescendants()) do
		if (v:isA("Folder") or v.Name == "Alert") then continue end
		
		if (v:isA("Sound") and v.Parent.Name == "Chase") then
			if (v.Volume > 0) then
				
				if (StartChaseTween ~= nil) then
					StartChaseTween:Cancel()
					StartChaseTween = nil
				end
				
				if (EndChaseTween ~= nil) then
					EndChaseTween:Cancel()
					EndChaseTween = nil
				end

				EndChaseTween = TweenService:Create(v, TweenInfo.new(1.5), {Volume = 0})
				EndChaseTween:Play()
			end
		end
	end
end

function playSound(Category, Title, Volume)
	
	if (Profile == nil) then
		Profile = Remotes.RequestData:InvokeServer("Profile")
	end
	
	local Vol = Profile.Account.Settings["Game Volume"] or 0
	GameVolume = 0.5 / 100 * Vol
	
	local toPlay = script[Category][Title]
	Volume = Volume or GameVolume
	
	if ((CurrentlyPlaying ~= toPlay or CurrentlyPlaying.Volume <= 0 or CurrentlyPlaying == Chase.None) and Category ~= "Chase") then
		stopSounds()
		toPlay.Volume = Volume
		CurrentlyPlaying = toPlay
	end
	
	if ((CurrentlyPlaying ~= toPlay or CurrentlyPlaying.Volume <= 0 or CurrentlyPlaying == Chase.None) and Category == "Chase") then
		stopSounds()
		
		if (StartChaseTween ~= nil) then
			StartChaseTween:Cancel()
			StartChaseTween = nil
		end
		
		if (EndChaseTween ~= nil) then
			EndChaseTween:Cancel()
			EndChaseTween = nil
		end
		
		StartChaseTween = TweenService:Create(toPlay, TweenInfo.new(1.5), {Volume = Volume})
		StartChaseTween:Play()
	end
	
end

function playAmbient(Role)
	
	if (Profile == nil) then
		Profile = Remotes.RequestData:InvokeServer("Profile")
	end
	
	local Vol = Profile.Account.Settings["Game Volume"] or 0
	local BaseVolume = 1.5
	local Volume = BaseVolume / 100 * Vol
	Other[`Ambience{Role}`].Volume = Volume
	
end

function stopAmbient()
	
	if (Other[`AmbienceHunter`].Volume > 0) then
		local tweenH = TweenService:Create(Other[`AmbienceHunter`], TweenInfo.new(1.5), {Volume = 0})
		tweenH:Play()
	end
	
	if (Other[`AmbiencePrey`].Volume > 0) then
		local tweenP = TweenService:Create(Other[`AmbiencePrey`], TweenInfo.new(1.5), {Volume = 0})
		tweenP:Play()
	end
	
end

function adjustProximity(HunterDistance, inChase)
	
	if (Profile == nil) then
		Profile = Remotes.RequestData:InvokeServer("Profile")
		return
	end
	
	local Vol = Profile.Account.Settings["Game Volume"] or 0
	local Volume = 0.25 / 100 * Vol
	local ChaseTheme = Gameplay:getChaseTheme()
	local Radius = 1000
	
	if (Gameplay:getHunter() == nil) then
		Radius = 1000
	else
		Radius = Gameplay:getProximityRadius()
	end

	if (inChase) then
		Proximity[ChaseTheme].Volume = 0
	else
		Proximity[ChaseTheme].Volume = Volume - (Volume /  Radius * HunterDistance)
	end
end

function updateProfile(Sent)
	Profile = Sent
end

Events.ClientTick.Event:Connect(onTick)
Events.ProfileUpdate.Event:Connect(updateProfile)