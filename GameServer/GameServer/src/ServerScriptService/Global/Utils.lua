local this = {}

function this.isInGroup(Player)
	return Player:isInGroup(32403089)
end

function this:isStaff(Player)
	if (this.isInGroup(Player)) then
		return Player:getRankInGroup(32403089) >= 3
	end

	return false
end

function this:isTester(Player)
	if (this.isInGroup(Player)) then
		return Player:getRankInGroup(32403089) >= 2
	end

	return false
end

return this
