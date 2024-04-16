local this = {}

function this:hasOccupant(Grave)
	local Player = Grave:GetAttribute("Player")

	if (Player ~= "") then
		return true
	end

	return false
end

function this:getOccupant(Grave)
	local Amount = Grave:GetAttribute("Player")
	return Amount
end

function this:getRespawnSpeed(Grave)
	local Amount = Grave:GetAttribute("RespawnSpeed")
	return Amount
end

function this:getPrayBonus(Grave)
	local Amount = Grave:GetAttribute("PrayBonus")
	return Amount
end

function this:getSpawnTime(Grave)
	local Amount = Grave:GetAttribute("SpawnTime")
	return Amount
end

function this:getInteractor(Grave)
	local Interactor = Grave:GetAttribute("Interactor")
	return Interactor
end

function this:hasInteractor(Grave)
	local Interactor = Grave:GetAttribute("Interactor")
	
	if (Interactor ~= 0) then
		return true
	end
	
	return false
end

function this:setOccupant(Grave, Player)
	Grave:SetAttribute("Player", Player.Name)
end

function this:setRespawnSpeed(Grave, Value)
	Grave:SetAttribute("RespawnSpeed", Value)
end

function this:setPrayBonus(Grave, Value)
	Grave:SetAttribute("PrayBonus", Value)
end

function this:setSpawnTime(Grave, Value)
	Grave:SetAttribute("SpawnTime", Value)
end

function this:setInteractor(Grave, Player)
	Grave:SetAttribute("Interactor", Player.Name)
end

return this
