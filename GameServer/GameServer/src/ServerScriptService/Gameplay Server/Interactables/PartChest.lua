local this = {}

function this:isLooted(PartChest)
	local Looted = PartChest:GetAttribute("Looted")
	return Looted
end

function this:getAmount(PartChest)
	local Amount = PartChest:GetAttribute("Amount")
	return Amount
end

function this:getInteractor(PartChest)
	local Interactor = PartChest:GetAttribute("Interactor")
	return Interactor
end

function this:getTimer(PartChest)
	local Interactor = PartChest:GetAttribute("Timer")
	return Interactor
end

function this:getRefill(PartChest)
	local Interactor = PartChest:GetAttribute("Refill")
	return Interactor
end

function this:getInteractionTime(PartChest)
	local InteractionTime = PartChest:GetAttribute("InteractionTime")
	return InteractionTime
end

function this:hasInteractor(PartChest)
	local Interactor = PartChest:GetAttribute("Interactor")
	
	if (Interactor ~= 0) then
		return true
	end
	
	return false
end

function this:setLooted(PartChest, bool)
	PartChest:SetAttribute("Looted", bool)
end

function this:setAmount(PartChest, Value)
	PartChest:SetAttribute("Amount", Value)
end

function this:setTimer(PartChest, Value)
	PartChest:SetAttribute("Timer", Value)
end

function this:setRefill(PartChest, Value)
	PartChest:SetAttribute("Refill", Value)
end

function this:setInteractionTime(PartChest, Value)
	PartChest:SetAttribute("InteractionTime", Value)
end

function this:setInteractor(PartChest, Player)
	PartChest:SetAttribute("Interactor", Player)
end

return this
