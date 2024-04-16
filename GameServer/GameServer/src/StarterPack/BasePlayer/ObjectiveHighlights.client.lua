local RunService = game["Run Service"]
local Players = game.Players

local LocalPlayer = Players.LocalPlayer
local Gameplay = require(game.ReplicatedStorage.Prefabs["Client Functions"])

local ObjectiveColor = Color3.new(1, 1, 1)
local ObjectiveDistance = 45

function onUpdate()
	
	highlightGaps()
	highlightDoors()
	highlightChests()
	highlightCollectors()
	highlightExtractors()
	
end

function highlightDoors()

	if (not Gameplay:isRunning() or Gameplay:getRole(Gameplay:getMatchPlayer(LocalPlayer.UserId)) == "Hunter") then
		return
	end

	local Interactables = workspace.Map.Interactables
	local BigDoors = Interactables.BigDoors

	for i, v in pairs(BigDoors:GetChildren()) do
		if (not v:isA("Part")) then continue end

		local MatchPlayer = Gameplay:getMatchPlayer(LocalPlayer.UserId)
		local PrimaryPart = LocalPlayer.Character.PrimaryPart
		local Position = PrimaryPart.CFrame.Position
		local DoorPosition = v.CFrame.Position
		local Dist = (Position - DoorPosition).Magnitude

		local enabled = (v:GetAttribute("Powered") == true and Dist <= 30 and not Gameplay:getEffect(MatchPlayer, "Paralyzed", "Active"))

		if (enabled) then

			if (v:FindFirstChild("ClientAura") ~= nil) then
				return
			end

			local ClientAura = Instance.new("Highlight")
			ClientAura.Name = "ClientAura"
			ClientAura.Parent = v

			ClientAura.FillColor = Color3.new(0.619608, 0.6, 0.0117647)
			ClientAura.OutlineColor = Color3.new(0.619608, 0.6, 0.0117647)
			ClientAura.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			ClientAura.FillTransparency = 0.15
			ClientAura.Enabled = true
		else
			if (v:FindFirstChild("ClientAura") ~= nil) then
				v:FindFirstChild("ClientAura"):Destroy()
			end
		end
	end
end

function highlightGaps()

	if (not Gameplay:isRunning() or Gameplay:getRole(Gameplay:getMatchPlayer(LocalPlayer.UserId)) == "Hunter") then
		return
	end

	local Interactables = workspace.Map.Interactables
	local Gaps = Interactables.Gaps

	for i, v in pairs(Gaps:GetChildren()) do
		if (not v:isA("Part")) then continue end

		local MatchPlayer = Gameplay:getMatchPlayer(LocalPlayer.UserId)
		local PrimaryPart = LocalPlayer.Character.PrimaryPart
		local Position = PrimaryPart.CFrame.Position
		local DoorPosition = v.CFrame.Position
		local Dist = (Position - DoorPosition).Magnitude

		local enabled = (Dist <= 30 and not Gameplay:getEffect(MatchPlayer, "Paralyzed", "Active"))

		if (enabled) then

			if (v:FindFirstChild("ClientAura") ~= nil) then
				return
			end

			local ClientAura = Instance.new("Highlight")
			ClientAura.Name = "ClientAura"
			ClientAura.Parent = v

			ClientAura.FillTransparency = 1
			ClientAura.OutlineColor = Color3.new(0.552941, 0.552941, 0.552941)
			ClientAura.DepthMode = Enum.HighlightDepthMode.Occluded
			ClientAura.Enabled = true
		else
			if (v:FindFirstChild("ClientAura") ~= nil) then
				v:FindFirstChild("ClientAura"):Destroy()
			end
		end
	end
end

function highlightChests()

	if (not Gameplay:isRunning() or Gameplay:getRole(Gameplay:getMatchPlayer(LocalPlayer.UserId)) == "Hunter") then
		return
	end

	local Interactables = workspace.Map.Interactables
	local Gaps = Interactables.PartChests

	for i, v in pairs(Gaps:GetChildren()) do
		if (not v:isA("Part")) then continue end

		local MatchPlayer = Gameplay:getMatchPlayer(LocalPlayer.UserId)
		local PrimaryPart = LocalPlayer.Character.PrimaryPart
		local Position = PrimaryPart.CFrame.Position
		local DoorPosition = v.CFrame.Position
		local Dist = (Position - DoorPosition).Magnitude

		local looted = v:GetAttribute("isLooted")
		local enabled = (Dist <= ObjectiveDistance and Gameplay:getParts(MatchPlayer) < 3 and not Gameplay:HasSerum(MatchPlayer) and not looted)

		if (enabled) then

			if (v:FindFirstChild("ClientAura") ~= nil) then
				return
			end

			local ClientAura = Instance.new("Highlight")
			ClientAura.Name = "ClientAura"
			ClientAura.Parent = v

			ClientAura.FillTransparency = 1
			ClientAura.OutlineColor = ObjectiveColor
			ClientAura.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			ClientAura.Enabled = true
		else
			if (v:FindFirstChild("ClientAura") ~= nil) then
				v:FindFirstChild("ClientAura"):Destroy()
			end
		end
	end
end

function highlightExtractors()

	if (not Gameplay:isRunning() or Gameplay:getRole(Gameplay:getMatchPlayer(LocalPlayer.UserId)) == "Hunter") then
		return
	end

	local Interactables = workspace.Map.Interactables
	local Gaps = Interactables.Extractors

	for i, v in pairs(Gaps:GetChildren()) do
		if (not v:isA("Part")) then continue end

		local MatchPlayer = Gameplay:getMatchPlayer(LocalPlayer.UserId)
		local PrimaryPart = LocalPlayer.Character.PrimaryPart
		local Position = PrimaryPart.CFrame.Position
		local DoorPosition = v.CFrame.Position
		local Dist = (Position - DoorPosition).Magnitude

		local PartsInstalled = v:GetAttribute("PartsInstalled")
		local enabled = Dist <= ObjectiveDistance and ((Gameplay:getParts(MatchPlayer) >= 1 and not PartsInstalled) or (not Gameplay:HasSerum(MatchPlayer) and PartsInstalled))

		if (enabled) then

			if (v:FindFirstChild("ClientAura") ~= nil) then
				return
			end

			local ClientAura = Instance.new("Highlight")
			ClientAura.Name = "ClientAura"
			ClientAura.Parent = v

			ClientAura.FillTransparency = 1
			ClientAura.OutlineColor = ObjectiveColor
			ClientAura.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			ClientAura.Enabled = true
		else
			if (v:FindFirstChild("ClientAura") ~= nil) then
				v:FindFirstChild("ClientAura"):Destroy()
			end
		end
	end
end

function highlightCollectors()

	if (not Gameplay:isRunning() or Gameplay:getRole(Gameplay:getMatchPlayer(LocalPlayer.UserId)) == "Hunter") then
		return
	end

	local Interactables = workspace.Map.Interactables
	local Gaps = Interactables.Collectors

	for i, v in pairs(Gaps:GetChildren()) do
		if (not v:isA("Part")) then continue end

		local MatchPlayer = Gameplay:getMatchPlayer(LocalPlayer.UserId)
		local PrimaryPart = LocalPlayer.Character.PrimaryPart
		local Position = PrimaryPart.CFrame.Position
		local DoorPosition = v.CFrame.Position
		local Dist = (Position - DoorPosition).Magnitude

		local enabled = (Dist <= ObjectiveDistance and Gameplay:HasSerum(MatchPlayer))

		if (enabled) then

			if (v:FindFirstChild("ClientAura") ~= nil) then
				return
			end

			local ClientAura = Instance.new("Highlight")
			ClientAura.Name = "ClientAura"
			ClientAura.Parent = v

			ClientAura.FillTransparency = 1
			ClientAura.OutlineColor = ObjectiveColor
			ClientAura.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			ClientAura.Enabled = true
		else
			if (v:FindFirstChild("ClientAura") ~= nil) then
				v:FindFirstChild("ClientAura"):Destroy()
			end
		end
	end
end

RunService.Heartbeat:Connect(onUpdate)