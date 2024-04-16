local LocalPlayer = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Animations = require(script.Parent.Animations)
local Gameplay = require(game.ReplicatedStorage.Prefabs["Client Functions"])

local Remotes = game.ReplicatedStorage.Remotes
local AttackRemote = Remotes.AttackRemote

local Hitbox = script:GetAttribute("Hitbox")

local Runner = nil

local this = {}

function isPlayer(Name)
	
	if (game.Players[Name] ~= nil) then
		return true
	end
	
	return false
end

function this:startAttack()
	if (Runner ~= nil) then
		Runner:Disconnect()
		Runner = nil
	end
	
	local windup = 0
	local timer = 0.5
	
	Runner = game["Run Service"].Heartbeat:Connect(function(delta)
		
		if (script.Parent:GetAttribute("RunAttack")) then
			timer = 0.5
		else
			if (windup < 0.55) then
				windup += delta
				return
			end
			
			timer -= delta
		end
		
		if (timer <= 0) then
			Runner:Disconnect()
			Runner = nil
		end
		
		local result = this:castAttack()
		
		if (result) then
			script.Parent:SetAttribute("RunAttack", false)
			Runner:Disconnect()
			Runner = nil
			return
		end
		
	end)
	
end

function this:castAttack()
	
	if (not Gameplay:isRunning() or Gameplay:getMatchTimer() < 1) then
		return
	end
	
	local Character = LocalPlayer.Character
	local PrimaryPart = Character.PrimaryPart
	local x, y, z = PrimaryPart.CFrame.Rotation:ToEulerAnglesXYZ()
	
	local params = RaycastParams.new()	
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {Character}
	
	local Cast = workspace:Blockcast(PrimaryPart.CFrame * CFrame.Angles(0, y, 0), Hitbox, Camera.CFrame.LookVector * 5, params)
	
	
	if (Cast) then
		
		if (game.Players:FindFirstChild(Cast.Instance.Parent.Name) ~= nil) then
			AttackRemote:FireServer("Hit", Cast.Instance.Parent)
			return true
		end
		
		--[[local Visualizer = Instance.new("Part")
		Visualizer.Name = "Hitbox"
		Visualizer.Color = Color3.new(1,0,0)
		Visualizer.CanCollide = false
		Visualizer.Size = Hitbox
		Visualizer.Parent = workspace
		Visualizer.CFrame = CFrame.new(PrimaryPart.CFrame.Position, PrimaryPart.CFrame.Position + Camera.CFrame.LookVector * 4)
		Visualizer.Anchored = true

		task.delay(10, function()
			Visualizer:Destroy()
		end)]]
		
	end
	
	return false
	
end

return this
