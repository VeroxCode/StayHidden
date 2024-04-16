local GamepadService = game:GetService("GamepadService")
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Camera = workspace.CurrentCamera
local CameraPart = workspace.CamPart

RunService.Heartbeat:Connect(function()
	
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CFrame = CameraPart.CFrame
	
	if (UserInput:GetLastInputType() == Enum.UserInputType.Gamepad1) then
		GamepadService:EnableGamepadCursor(nil)
	else
		GamepadService:DisableGamepadCursor()
	end
end)