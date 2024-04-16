local GameUtils = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Utils"):WaitForChild("Game Functions"))

local this = {}

local Scripts = {
	0;
	script.Hunter.Attack;
	script.Prey.Sprint;
	0;
	0;
	script.Prey.Slide;
	0;
	script.Prey.Crouch;
	0;
	0;
	0;
}

this.List = {
	["IDLE"] = 1,
	["ATTACK"] = 2,
	["SPRINT"] = 3,
	["INSTALL"] = 4,
	["RECOVERY"] = 5,
	["SLIDE"] = 6,
	["SCAVENGING"] = 7,
	["CROUCH"] = 8,
	["INSERT"] = 9,
	["PRAYING"] = 10,
	["ABILITY"] = 11,
	["FUSEBOX"] = 12,
	["RESPAWNING"] = 13,
	["HEALING"] = 14,
	["BEINGHEALED"] = 15,
	["ACCELERATING"] = 16,
}

this.Interactions = {
	["Extractor"] = 1,
	["Collector"] = 2,
	["Gap"] = 3,
	["PartChest"] = 4,
	["Exit"] = 5,
	["Grave"] = 6,
	["BigDoors"] = 7,
	["Fusebox"] = 8,
	["JunkPile"] = 9,
	["Heal"] = 10,
	["Accelerate"] = 11,
	["Curtain"] = 12,
}

function this:performAction(PlayerID, ActionID, setAction, ...)
	
	if (ActionID == this.List.IDLE) then
		return
	end
	
	local ActionScript = require(Scripts[ActionID])
	
	if (ActionScript:RequiresAction() and this:getAction(PlayerID) == ActionScript:getRequiredActionID() and this:isNeededRole(PlayerID, ActionScript:getNeededRole())) then
		
		if (setAction) then
			this:setAction(PlayerID, ActionID)
		end
		ActionScript:performAction(PlayerID, ...)
		return
	end
	
	if (not ActionScript:RequiresAction() and this:isNeededRole(PlayerID, ActionScript:getNeededRole())) then
		
		if (setAction) then
			this:setAction(PlayerID, ActionID)
		end
		ActionScript:performAction(PlayerID, ...)
		return
	end
	
end

function this:setAction(PlayerID, ActionID)
	
	local MatchPlayer = GameUtils:getMatchPlayer(PlayerID)
	
	if (MatchPlayer ~= nil) then
		MatchPlayer:SetAttribute("Action", ActionID)
	end
end

function this:getAction(PlayerID)
	
	local MatchPlayer = GameUtils:getMatchPlayer(PlayerID)

	if (MatchPlayer ~= nil) then
		return MatchPlayer:GetAttribute("Action")
	end
end

function this:setInteraction(PlayerID, InteractionID)
	
	local MatchPlayer = GameUtils:getMatchPlayer(PlayerID)

	if (MatchPlayer ~= nil) then
		MatchPlayer:SetAttribute("Interaction", tonumber(InteractionID))
		MatchPlayer:SetAttribute("InteractionTimer", 0.5)
	end
end

function this:getInteraction(PlayerID)
	
	local MatchPlayer = GameUtils:getMatchPlayer(PlayerID)

	if (MatchPlayer ~= nil) then
		return MatchPlayer:GetAttribute("Interaction")
	end
end

function this:isNeededRole(PlayerID, Role)
	
	local MatchPlayer = GameUtils:getMatchPlayer(PlayerID)
	local PlayerRole = GameUtils:getRole(MatchPlayer)

	if (MatchPlayer ~= nil) then
		if (PlayerRole == Role or Role == "Both") then
			return true
		end
	end
	return false
end

return this
