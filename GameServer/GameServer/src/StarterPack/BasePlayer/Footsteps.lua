local Gameplay = require(game.ReplicatedStorage.Prefabs["Client Functions"])
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local PlayerList = {}

local this = {}


function this:generateFootSteps(Character, Bloody, Lifetime)
	
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {Character, workspace.Steps}
	local ray = workspace:Raycast(Character.PrimaryPart.CFrame.Position, Vector3.new(0, -1, 0) * 20, params)
	
	if (ray) then
		local rx, ry, rz = Character.PrimaryPart.CFrame.Rotation:toOrientation()
		local steps = Instance.new("Part")
		steps.Size = Vector3.new(2.5, 0.01, 1.5)
		steps.Rotation = Vector3.new(0, math.deg(ry), 0)
		steps.Position = ray.Position + Vector3.new(0, 0.05, 0)
		steps.Material = Enum.Material.Neon
		steps.Transparency = 1
		steps.Anchored = true
		steps.CanCollide = false
		steps.Name = "Footsteps"
		steps.Parent = workspace.Steps
		
		local decal = Instance.new("Decal")
		decal.Face = "Top"
		decal.Texture = "rbxassetid://16646129092"
		decal.Parent = steps
		decal.Color3 = if (Bloody) then Color3.new(2000, 0, 0) else Color3.new(2000, 2000, 2000)
		
		local tween = TweenService:Create(decal, TweenInfo.new(Lifetime), {Transparency = 1})
		tween:Play()
		
		tween.Completed:Connect(function()
			steps:Destroy()
		end)
	end
end

function this:tickFootSteps(delta)
	
	if (not Gameplay:isRunning()) then
		return
	end
	
	for i, player in pairs(Players:GetPlayers()) do
		local MatchPlayer = Gameplay:getMatchPlayer(player.UserId)
		local Role = Gameplay:getRole(MatchPlayer)
		
		if (Role == "Prey") then
			
			local Health = MatchPlayer:WaitForChild("Values"):GetAttribute("Health")
			local MaxHealth = MatchPlayer:WaitForChild("Values"):GetAttribute("MaxHealth")
			local isInjured = if (Role == "Prey") then (Health <= 50) else false
			local isCrouching = MatchPlayer:GetAttribute("isCrouching")
			local isSprinting = MatchPlayer:GetAttribute("isSprinting")
			
			local frequency = if (isSprinting) then 0.15 else 0.25
			local lifetime = if (isSprinting) then 2.75 else 1.5
			
			if (PlayerList[MatchPlayer.Name] == nil and not isCrouching) then
				PlayerList[MatchPlayer.Name] = 0
				this:generateFootSteps(player.Character, false, lifetime)
			end
			
			PlayerList[MatchPlayer.Name] += delta
			
			if (PlayerList[MatchPlayer.Name] >= frequency and not isCrouching) then
				PlayerList[MatchPlayer.Name] = 0
				this:generateFootSteps(player.Character, isInjured, lifetime)
			end
			
		end
		
	end
	
end

return this
