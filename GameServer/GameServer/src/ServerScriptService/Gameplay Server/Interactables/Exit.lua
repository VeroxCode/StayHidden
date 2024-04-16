local this = {}

function this:isUsed(Exit)
	local Amount = Exit:GetAttribute("Used")
	return Amount
end

function this:getOpeningTime(Exit)
	local Amount = Exit:GetAttribute("OpeningTime")
	return Amount
end

function this:getInteractor(Exit)
	local Interactor = Exit:GetAttribute("Interactor")
	return Interactor
end

function this:getInteractionTime(Exit)
	local Interactor = Exit:GetAttribute("InteractionTime")
	return Interactor
end

function this:hasInteractor(Exit)
	local Interactor = Exit:GetAttribute("Interactor")
	
	if (Interactor ~= 0) then
		return true
	end
	
	return false
end

function this:setUsed(Exit, Bool)
	Exit:SetAttribute("Used", Bool)
end

function this:setOpeningTime(Exit, Value)
	Exit:SetAttribute("OpeningTime", Value)
end

function this:setInteractionTime(Exit, Value)
	Exit:SetAttribute("InteractionTime", Value)
end

function this:setInteractor(Exit, ID)
	Exit:SetAttribute("Interactor", ID)
end

return this
