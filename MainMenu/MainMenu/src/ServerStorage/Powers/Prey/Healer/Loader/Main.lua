local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local LoaderPlayer = script.Parent.Parent.Parent
local Power = script.Parent.Parent

local Players = game:GetService("Players")

local LoaderId = game.Players[LoaderPlayer.Name].UserId
local Remotes = game.ReplicatedStorage.Remotes
local Events = game.ServerStorage.Events

local PlayerToHeal = nil
local Runner = nil

local this = {}

local Data = {
}

function this:initialize()
	local Player = game.Players:WaitForChild(LoaderPlayer.Name)
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local Role = Modules.Game:getRole(MatchPlayer)

	local SaveState = Modules.SaveStorage:get(Player.UserId)
	local Selected = SaveState[Role].Selected 
	local Perks = SaveState[Role][Selected].LoadOut.Modifiers
	
	Modules.Game:setPowerLocally(MatchPlayer, "Icon", "Healer")
	Modules.Game:setAbilityValue(MatchPlayer, "MaxCooldown", Power:GetAttribute("Cooldown"))
	Modules.Game:setAbilityValue(MatchPlayer, "Cooldown", 0)
	Modules.Game:setAbilityValue(MatchPlayer, "Amount", 0)

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
	
	local Attributes = {}
	
	for name, value in pairs(Power:GetAttributes()) do
		Attributes[name] = value
	end

	if (Attributes["ActiveCooldown"] > 0 or Modules.Actions:getAction(Player.UserId) ~= Modules.Actions.List.IDLE) then
		this:cancelAbility(Player)
		return
	end
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	
	Modules.Speed:addMultiplier(MatchPlayer, "Ability", 0, 0)
	Modules.Actions:setAction(Player.UserId, Modules.Actions.List.ABILITY)
	Modules.Game:setAnimationAction(MatchPlayer, "Pray")
	
	local Progress = 0
	
	Runner = Events.Game.ServerTick.Event:Connect(function(delta)
		Progress += (100 / Power:GetAttribute("PlacementTime")) * delta
		Modules.Game:setIProgress(Player.UserId, "Summoning Totem", Progress, 100)
		
		if (Progress >= 100) then
			
			local Totem = Power.Totem:Clone()
			Totem.Parent = workspace
			Totem.CFrame = Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, -1, 0)
			Totem.Script.Enabled = true
			
			this:applyCooldown()
			this:cancelAbility(Player)
			return
		end
	end)
end

function this:cancelAbility(Player)
	if (Runner ~= nil) then
		Runner:Disconnect()
		Runner = nil
	end
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local isSprinting = Modules.Game:isSprinting(MatchPlayer)
	
	Modules.Actions:setAction(Player.UserId, Modules.Actions.List.IDLE)
	Modules.Game:setAnimationAction(MatchPlayer, if (isSprinting) then "Run" else "Walk")
	Modules.Speed:removeMultiplier(MatchPlayer, "Ability")
	Modules.Game:stopIProgress(Player.UserId)
end

function this:performSecondary(Player)
	
end

function this:cancelSecondary(Player)
	
end

function this:applyCooldown()
	Power:SetAttribute("ActiveCooldown", Power:GetAttribute("Cooldown"))
end

return this
