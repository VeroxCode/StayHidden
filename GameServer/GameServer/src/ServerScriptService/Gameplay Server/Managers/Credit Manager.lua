local Gameplay = require(game.ServerScriptService["Gameplay Server"].Utils:WaitForChild("Game Functions"))

local this = {}

function this:setCredits(PlayerID, Amount)
	local MatchPlayer = Gameplay:getMatchPlayer(PlayerID)
	
	if (MatchPlayer == nil) then
		return
	end

	MatchPlayer:SetAttribute("Credits", Amount)
end

function this:resetCredits(PlayerID)
	local MatchPlayer = Gameplay:getMatchPlayer(PlayerID)
	
	if (MatchPlayer == nil) then
		return
	end
	
	MatchPlayer:SetAttribute("Credits", 0)
end

function this:getCredits(PlayerID)
	local MatchPlayer = Gameplay:getMatchPlayer(PlayerID)
	
	if (MatchPlayer == nil) then
		return
	end
	
	local credits = MatchPlayer:GetAttribute("Credits")
	return credits
end

function this:increaseCredits(PlayerID, Amount)
	local MatchPlayer = Gameplay:getMatchPlayer(PlayerID)
	
	if (MatchPlayer == nil) then
		return
	end

	local credits = MatchPlayer:GetAttribute("Credits")
	local newcredits = credits + Amount
		
	MatchPlayer:SetAttribute("Credits", newcredits)
end

function this:decreaseCredits(PlayerID, Amount)
	local MatchPlayer = Gameplay:getMatchPlayer(PlayerID)
	
	if (MatchPlayer == nil) then
		return
	end

	local credits = MatchPlayer:GetAttribute("Credits")
	local newcredits = credits - Amount

	MatchPlayer:SetAttribute("Credits", newcredits)
end


return this
