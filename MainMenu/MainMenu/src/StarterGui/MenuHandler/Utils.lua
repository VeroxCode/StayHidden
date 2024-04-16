local TweenService = game:GetService("TweenService")
local Remotes = game.ReplicatedStorage.Remotes

local this = {}

function this:closeScenes(Player: Player)
	
	local PlayerGui = Player.PlayerGui
	
	PlayerGui.AccountUI.Enabled = false
	
	for i, v in pairs(PlayerGui:GetChildren()) do
		if (v:isA("ScreenGui")) then
			v.Enabled = false
		end
	end
	
end

function this:closeRoleMenus(Player: Player)

	local PlayerGui = Player.PlayerGui
	local Prey = PlayerGui:WaitForChild("Prey").BaseFrame.HolderFrame
	local Hunter = PlayerGui:WaitForChild("Hunter").BaseFrame.HolderFrame

	for i, v in pairs(Prey:GetChildren()) do
		if (v:isA("Frame") and string.find(v.Name, "B_")) then
			v.Visible = false
		end
	end
	
	for i, v in pairs(Hunter:GetChildren()) do
		if (v:isA("Frame") and string.find(v.Name, "B_")) then
			v.Visible = false
		end
	end

end

function this:FindElement(Type, Name, Parent)
	for i, v in pairs(Parent:GetDescendants()) do
		if (v:isA(Type) and string.lower(v.Name) == string.lower(Name)) then
			return v
		end
	end
end

function this:setMenuTheme(Player, Theme) : "Main"|"MountainClimber"|"ShowStarter"
	local Sound = Player.PlayerGui.CurrentTheme
	local Profile = Remotes.RequestData:InvokeServer("Profile")
	
	if (Sound.SoundId == Sound:GetAttribute(Theme)) then
		return
	end
	
	if (Sound.Volume > 0) then
		local Fadeout = TweenService:Create(Sound, TweenInfo.new(2), {Volume = 0})
		Fadeout:Play()
		
		Fadeout.Completed:Connect(function()
			
			Sound.SoundId = Sound:GetAttribute(Theme)
			Sound.TimePosition = 0
			
			local Tween = TweenService:Create(Sound, TweenInfo.new(2), {Volume = (Profile.Account.Settings["Music Volume"] / 200)})
			Tween:Play()
		end)
	else
		
		Sound.SoundId = Sound:GetAttribute(Theme)
		Sound.TimePosition = 0
		
		local Tween = TweenService:Create(Sound, TweenInfo.new(2), {Volume = (Profile.Account.Settings["Music Volume"] / 200)})
		Tween:Play()
	end
end

function this:adjustThemeVolume(Player, Volume)
	local Sound = Player.PlayerGui.CurrentTheme
	Sound.Volume = Volume
end

return this
