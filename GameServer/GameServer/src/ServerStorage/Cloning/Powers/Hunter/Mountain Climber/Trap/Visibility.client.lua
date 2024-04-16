local RunService = game:GetService("RunService")
local ShowModel = {"Scream", "Destroy", "TrapSet"}

RunService.Heartbeat:Connect(function()
	
	local LocalPlayer = game.Players.LocalPlayer
	local Character = workspace:WaitForChild(LocalPlayer.Name)
	local Interactables = workspace.Map.Interactables
	local RootPart = Character.HumanoidRootPart
	
	local MatchPlayers = game.ReplicatedStorage.Match.Players
	local MatchPlayer = MatchPlayers:FindFirstChild(LocalPlayer.Name)
	local AnimationAction = MatchPlayer:GetAttribute("AnimationAction")

	local Params = OverlapParams.new()
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.FilterDescendantsInstances = {Character, workspace.DisplayTrap.Light}
	local PartsInside = workspace:GetPartsInPart(workspace.DisplayTrap, Params)
	
	workspace.DisplayTrap.Transparency = if (table.find(ShowModel, AnimationAction) ~= nil) then 1 else 0

	if (Interactables:FindFirstChild("Traps") ~= nil) then
		for i, v in pairs(Interactables:WaitForChild("Traps"):GetChildren()) do
			local DisplayPos = workspace.DisplayTrap.Position
			local TrapPos = v.Position

			local DistX = math.abs(DisplayPos.X - TrapPos.X)
			local DistZ = math.abs(DisplayPos.Z - TrapPos.Z)

			if (DistX < 5 and DistZ < 5) then
				workspace.DisplayTrap.Color = script:GetAttribute("ColorDisallow")
				return
			end
		end
	end

	if (#PartsInside > 0) then
		workspace.DisplayTrap.Color = script:GetAttribute("ColorDisallow")
	else
		workspace.DisplayTrap.Color = script:GetAttribute("ColorAllow")
	end
end)