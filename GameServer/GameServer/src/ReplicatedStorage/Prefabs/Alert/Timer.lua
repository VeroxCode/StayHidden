local LocalPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

local Backpack = LocalPlayer:WaitForChild("Backpack")
local ClientEvents = Backpack:WaitForChild("Events")
local Object = script.Parent

local RenderTick

RenderTick = RunService.RenderStepped:Connect(function(delta)

	local NewTimer = Object:GetAttribute("Timer")
	NewTimer -= delta
	Object:SetAttribute("Timer", NewTimer)

	if (NewTimer <= 0) then
		RenderTick:Disconnect()
		local tween = game.TweenService:Create(Object.ImageLabel, TweenInfo.new(1.2), {BackgroundTransparency = 1, ImageTransparency = 1})
		tween:Play()
		
		tween.Completed:Connect(function()
			Object:Destroy()
		end)
	end
end)

local module = {}

return module
