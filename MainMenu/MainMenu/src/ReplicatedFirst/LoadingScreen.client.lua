local Player = game.Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local TweenService = game:GetService("TweenService")
local Tween: Tween = nil

while task.wait() do
	if (PlayerGui:FindFirstChild("LoadingScreen") ~= nil) then
		PlayerGui.LoadingScreen.Enabled = true
		
		game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		
		if (Tween == nil) then
			local Info = TweenInfo.new(1.0, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, true)
			Tween = TweenService:Create(PlayerGui:FindFirstChild("LoadingScreen").BaseFrame.State, Info, {TextTransparency = 0.95})
			Tween:Play()
		end
		
		if (workspace:GetAttribute("LoggedIn") and workspace:GetAttribute("LoadedSave") and workspace:GetAttribute("LoadedBinds")) then
			
			local LoadingScreen = PlayerGui:FindFirstChild("LoadingScreen")
			local Main = PlayerGui:FindFirstChild("Main")

			Tween:Cancel()
			local count = 0
			
			for i, v in pairs(LoadingScreen:GetDescendants()) do
				if (not v:isA("TextLabel")) then continue end
				
				local vtween = TweenService:Create(v, TweenInfo.new(1.5), {TextTransparency = 1})
				vtween:Play()
				count += 1
				
				if (count >= 2) then
					task.wait(1.75)
				
					LoadingScreen.Enabled = false
					Main.Enabled = true
				end
			end
			
			local Utils = require(PlayerGui:WaitForChild("MenuHandler").Utils)
			Utils:setMenuTheme(Player, "Main")
			
			script.Enabled = false
			return
		end
		
	end
end