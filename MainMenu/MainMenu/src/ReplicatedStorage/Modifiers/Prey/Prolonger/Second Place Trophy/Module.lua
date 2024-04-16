local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Power = script.Parent.Parent.Parent
local LoaderPlayer = Power.Parent
local Config = script.Parent

local this = {}

function this:apply()
	Power:SetAttribute("ApplySpeed", false)
end

function onAttack(Player)
	
	if (Player.Name ~= LoaderPlayer.Name or getTokens() <= 0) then
		return
	end
	
	local Hunter = Modules.Game:getHunter()
	local Tokens = getTokens()
	
	local Duration = Config:GetAttribute("Duration")
	local Slowness = Config:GetAttribute("Slowness")
	
	Modules.Game:setEffect(Hunter, "Slowness", "Value", Slowness)
	Modules.Game:applyTimedEffect(Hunter, "Slowness", Duration)
	
	setTokens(0)
	
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

function setTokens(Value)
	Power:SetAttribute("Token", Value)
end

function getMaxTokens()
	return Power:GetAttribute("MaxTokens")
end

Modules.Events.Hunter.onAttack.Event:Connect(onAttack)

return this
