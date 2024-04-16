local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local LoaderPlayer : Player = script.Parent.Parent.Parent
local Power = script.Parent.Parent

local this = {}

local Data = {
}

function this:initialize()
	print("initialize " .. LoaderPlayer.Name)
	
	local Player = game.Players:WaitForChild(LoaderPlayer.Name)
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local Role = Modules.Game:getRole(MatchPlayer)

	local SaveState = Modules.SaveStorage:get(Player.UserId)
	local Selected = SaveState[Role].Selected 
	local Perks = SaveState[Role][Selected].LoadOut.Modifiers

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
	
	Modules.Game:setAbilityValue(MatchPlayer, "MaxCooldown", getMaxCooldown())
	Modules.Game:setAbilityValue(MatchPlayer, "Cooldown", 0)
	Modules.Game:setAbilityValue(MatchPlayer, "Amount", 0)
	
end

function this:performAbility(Player)
	print("Performing Ability")
end

function this:cancelAbility(Player)
	print("Cancelling Ability")
end

function this:performSecondary(Player)
	print("Performing Secondary")
end

function this:cancelSecondary(Player)
	print("Cancelling Secondary")
end

function onServerTick(delta)
	
	if (game.Players:FindFirstChild(LoaderPlayer.Name) == nil) then
		return
	end
	
	local Player = game.Players[LoaderPlayer.Name]
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	
	if (getCooldown() >= 0) then
		local newCooldown = getCooldown() - delta
		setCooldown(newCooldown)
		Modules.Game:setAbilityValue(MatchPlayer, "Cooldown", getCooldown())
		return
	end
	
	if (getTokenCooldown() >= 0) then
		local newCooldown = getTokenCooldown() - delta
		setTokenCooldown(newCooldown)
		Modules.Game:setAbilityValue(MatchPlayer, "Cooldown", getTokenCooldown())
		if (newCooldown <= 0) then
			Modules.Game:setAbilityValue(MatchPlayer, "Amount", 0)
			Modules.Game:setAbilityValue(MatchPlayer, "MaxCooldown", getMaxCooldown())
			Modules.Speed:removeMultiplier(MatchPlayer, "Prolonger")
			setCooldown(getMaxCooldown())
			setTokens(0)
		end
	end
	
end

function onSlide(Player, Gap)
	
	if (Player.Name ~= LoaderPlayer.Name
		or Gap.Name == getLastSlide()
		or getCooldown() > 0
		or getTokens() >= getMaxTokens()) then
		return
	end
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local Tokens = math.clamp(getTokens() + 1, 0, getMaxTokens())
	local TokenDuration = if (Tokens >= getMaxTokens()) then (getTokenDuration() / 2) else getTokenDuration()
	local SpeedIncrease = (Power:GetAttribute("SpeedIncrease") / 100) * Tokens
	
	setTokens(Tokens)
	setTokenCooldown(TokenDuration)
	setLastSlide(Gap.Name)
	
	if (canApplySpeed()) then
		Modules.Speed:addMultiplier(MatchPlayer, "Prolonger", SpeedIncrease, 0)
	end
	
	Modules.Game:setAbilityValue(MatchPlayer, "MaxCooldown", TokenDuration)
	Modules.Game:setAbilityValue(MatchPlayer, "Cooldown", TokenDuration)
	Modules.Game:setAbilityValue(MatchPlayer, "Amount", Tokens)
	
end

function canApplySpeed()
	return Power:GetAttribute("ApplySpeed")
end

function setCooldown(Value)
	Power:SetAttribute("Cooldown", Value)
end

function getCooldown()
	return Power:GetAttribute("Cooldown")
end

function setMaxCooldown(Value)
	Power:SetAttribute("MaxCooldown", Value)
end

function getMaxCooldown()
	return Power:GetAttribute("MaxCooldown")
end

function setTokenCooldown(Value)
	Power:SetAttribute("TokenCooldown", Value)
end

function getTokenCooldown()
	return Power:GetAttribute("TokenCooldown")
end

function setTokenDuration(Value)
	Power:SetAttribute("TokenDuration", Value)
end

function getTokenDuration()
	return Power:GetAttribute("TokenDuration")
end

function setTokens(Value)
	Power:SetAttribute("Token", Value)
end

function getTokens()
	return Power:GetAttribute("Token")
end

function setMaxTokens(Value)
	
	if (getMaxTokens() < Value) then
		return
	end
	
	Power:SetAttribute("MaxTokens", Value)
end

function getMaxTokens()
	return Power:GetAttribute("MaxTokens")
end

function setLastSlide(Value)
	Power:SetAttribute("LastSlide", Value)
end

function getLastSlide()
	return Power:GetAttribute("LastSlide")
end

Modules.Events.Game.ServerTick.Event:Connect(onServerTick)
Modules.Events.Prey.onSlide.Event:Connect(onSlide)

return this
