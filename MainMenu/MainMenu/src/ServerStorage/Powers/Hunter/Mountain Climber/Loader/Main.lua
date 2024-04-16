local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Remotes = game.ReplicatedStorage:WaitForChild("Remotes")
local Events = game.ServerStorage:WaitForChild("Events")

local TrackingAttributes = script.Parent.Parent.TrackingAttributes
local Tracker = script.Parent.Parent.Tracking

local PowerTrap = script.Parent.Parent.PowerTrap
local Power = script.Parent.Parent

local LoaderPlayer : Player = script.Parent.Parent.Parent
local Players = game:GetService("Players")
local Runner = nil

local this = {}

function this:initialize()
	
	local Player = game.Players:WaitForChild(LoaderPlayer.Name)
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local Role = Modules.Game:getRole(MatchPlayer)
	
	local SaveState = Modules.SaveStorage:get(Player.UserId)
	local Selected = SaveState[Role].Selected 
	local Perks = SaveState[Role][Selected].LoadOut.Modifiers
	
	Modules.Game:setPowerLocally(MatchPlayer, "Icon", "Mountain Climber")
	Modules.Game:setAbilityValue(MatchPlayer, "MaxCooldown", 0)
	Modules.Game:setAbilityValue(MatchPlayer, "Cooldown", 0)
	Modules.Game:setAbilityValue(MatchPlayer, "Amount", 0)
	
	PowerTrap:SetAttribute("SlowdownValue", Modules.Speed.Modifiers.Other.Climber_Slowdown)
	
	for i, v in pairs(Perks) do
		if (v ~= "") then
			local Modifiers = game.ServerStorage.Modifiers[Role][Selected]
			local Modifier = Modifiers[v]:Clone()
			Modifier.Name = v
			Modifier.Parent = Power.Loader
			
			local Module = require(Modifier.Module)
			Module:apply()
		end
	end
	
end

function this:performAbility(Player)
	
	if ((Modules.Actions:getAction(Player.UserId) == Modules.Actions.List.IDLE or Modules.Actions:getAction(Player.UserId) == Modules.Actions.List.ABILITY) == false or Tracker:GetAttribute("Radius") > 0) then
		return
	end
	
	Modules.Actions:setAction(Player.UserId, Modules.Actions.List.ABILITY)
	
	local Interactables = workspace.Map.Interactables
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local RootPart = workspace:WaitForChild(Player.Name):WaitForChild("HumanoidRootPart")
	
	if (Interactables:FindFirstChild("Traps") == nil) then
		local Folder = Instance.new("Folder")
		Folder.Name = "Traps"
		Folder.Parent = Interactables
	end
	
	if (Power:GetAttribute("AllowPlacement")) then
		
		Power:SetAttribute("isPlacing", true)
		Modules.Speed:addMultiplier(MatchPlayer, "Action", 0, 0)
		Modules.Game:setAnimationAction(MatchPlayer, "TrapSet")
		RootPart.Anchored = true
		Remotes.AssignCamera:FireClient(Player, "Lock")
		
		wait(Power:GetAttribute("PlaceTime"))
		
		Remotes.AssignCamera:FireClient(Player, "Unlock")
		RootPart.Anchored = false
		Modules.Game:setAnimationAction(MatchPlayer, "Run")
		Modules.Speed:removeMultiplier(MatchPlayer, "Action")
		
		local Traps = Power:GetAttribute("Traps")
		local MaxTraps = Power:GetAttribute("MaxTraps")
		
		if (Traps > 0) then
			local PlacedTrap = Power.PowerTrap:Clone()
			local Name = tostring(#Interactables:WaitForChild("Traps"):GetChildren() + 1)
			PlacedTrap.Name = Name
			PlacedTrap.Parent = Interactables.Traps
			PlacedTrap.CFrame = workspace.DisplayTrap.CFrame
			Power:SetAttribute("Traps", math.clamp((Traps - 1), 0, MaxTraps))
			Modules.Credits:increaseCredits(Player.UserId, (Modules.Game_Values.ScoreEvents.Specific.TrapSet))
			Modules.Actions:setAction(Player.UserId, Modules.Actions.List.IDLE)
			Events.Hunter.onTrapSet:Fire(Player, PlacedTrap)
		end
	end
end

function this:cancelAbility(Player)
	
end

function this:performSecondary(Player)
	
	if (Tracker:GetAttribute("Cooldown") > 0) then
		return
	end
	
end

function this:cancelSecondary(Player)
	
end

return this
