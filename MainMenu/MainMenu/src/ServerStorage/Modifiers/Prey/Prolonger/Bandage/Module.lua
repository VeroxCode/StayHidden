local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Power = script.Parent.Parent.Parent
local LoaderPlayer = Power.Parent
local Config = script.Parent

local this = {}

function this:apply()
end

function onSlide(Player, Gap)
	if (Player.Name ~= LoaderPlayer.Name
		or Gap.Name == getLastSlide()
		or getCooldown() > 0
		or getTokens() >= getMaxTokens()) then
		return
	end
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	Modules.Game:applyTimedEffect(MatchPlayer, "Protection", Config:GetAttribute("Duration"))
	
end

function getLastSlide()
	return Power:GetAttribute("LastSlide")
end

function getCooldown()
	return Power:GetAttribute("Cooldown")
end

function getTokens()
	return Power:GetAttribute("Token")
end

function getMaxTokens()
	return Power:GetAttribute("MaxTokens")
end

Modules.Events.Prey.onSlide.Event:Connect(onSlide)

return this
