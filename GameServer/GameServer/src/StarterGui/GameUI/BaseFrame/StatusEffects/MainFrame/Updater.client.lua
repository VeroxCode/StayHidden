local LocalPlayer = game.Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local ClientEvents = Backpack:WaitForChild("Events")

local Active = script.Parent.ActiveEffects

function onRenderUpdate(delta)
	
	local count = 0
	
	local MatchPlayers = game.ReplicatedStorage:WaitForChild("Match"):WaitForChild("Players")
	local MatchPlayer = MatchPlayers:WaitForChild(LocalPlayer.Name)
	local Effects = MatchPlayer:WaitForChild("Effects")
	local Role = MatchPlayer:GetAttribute("Role")
	
	for i, v in pairs(Active[Role]:GetChildren()) do
		
		if (v:isA("Frame")) then
			local Left = v.Left.Circle
			local Right = v.Right.Circle
			local MaxProgress = Effects[v.Name]:GetAttribute("Duration")
			local Progress = Effects[v.Name]:GetAttribute("Timer")
			local CircleProgress = math.clamp((360 / MaxProgress) * Progress, 0, 360)
			
			Right.UIGradient.Rotation = math.clamp(CircleProgress, 0, 180)
			Left.UIGradient.Rotation = math.clamp(CircleProgress, 180, 360)
			
			--v.Position = UDim2.new(0.5, 0, count * 0.5, 0)
			
			v.Visible = Effects[v.Name]:GetAttribute("Active")
		end
	end
end

ClientEvents.RenderTick.Event:Connect(onRenderUpdate)