local LocalPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

local Backpack = LocalPlayer:WaitForChild("Backpack")
local ClientEvents = Backpack:WaitForChild("Events")
local AuraObject = script.Parent

local RenderTick

RenderTick = RunService.RenderStepped:Connect(function(delta)

	local NewTimer = AuraObject:GetAttribute("Timer")
	NewTimer -= delta
	AuraObject:SetAttribute("Timer", NewTimer)

	if (NewTimer <= 0) then
		RenderTick:Disconnect()
		AuraObject:Destroy()
	end
end)

local module = {}

return module
