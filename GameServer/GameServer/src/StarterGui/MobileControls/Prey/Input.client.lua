local Remotes = game.ReplicatedStorage.Remotes
local MobileInputEvent = Remotes.MobileInputEvent

local LocalPlayer = game.Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local ClientEvents = Backpack:WaitForChild("Events")

local Crouch = script.Parent.Crouch
local Sprint = script.Parent.Sprint
local Interact = script.Parent.Interact

local GameUI = LocalPlayer.PlayerGui.GameUI.BaseFrame.Loadout.Inventory

Crouch.InputBegan:Connect(function(Input)
	MobileInputEvent:FireServer("Crouch")
end)

Sprint.InputBegan:Connect(function(Input)
	MobileInputEvent:FireServer("Sprint")
end)

function PressInteraction(Input, Down)
	local Hunter = game.ReplicatedStorage:WaitForChild("Match"):WaitForChild("Players"):WaitForChild(LocalPlayer.Name)
	local Interaction = Hunter:GetAttribute("Interaction")

	MobileInputEvent:FireServer(Interaction, Down)
end

function PressPower(Input, Down)
	MobileInputEvent:FireServer("Power", Down)
end

function PressTracking(Input, Down)
	MobileInputEvent:FireServer("Secondary", Down)
end

function onRender()
	if (game.ReplicatedStorage:FindFirstChild("Match") ~= nil) then
		local Player = game.ReplicatedStorage:WaitForChild("Match"):WaitForChild("Players"):WaitForChild(LocalPlayer.Name)
		local Interaction = Player:GetAttribute("Interaction")

		if (Interaction == 0) then
			Interact.Visible = false
		else
			Interact.Visible = true
		end
	end
end

GameUI.Tracking.Middle.MouseButton1Down:Connect(function(Input) PressTracking(Input, true) end)
GameUI.Tracking.Middle.MouseButton1Up:Connect(function(Input) PressTracking(Input, false) end)

GameUI.Power.Middle.MouseButton1Down:Connect(function(Input) PressPower(Input, true) end)
GameUI.Power.Middle.MouseButton1Up:Connect(function(Input) PressPower(Input, false) end)

Interact.InputBegan:Connect(function(Input) PressInteraction(Input, true) end)
Interact.InputEnded:Connect(function(Input) PressInteraction(Input, false) end)

ClientEvents.RenderTick.Event:Connect(onRender)
