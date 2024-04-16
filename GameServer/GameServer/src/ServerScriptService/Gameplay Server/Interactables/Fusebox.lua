local this = {}

function this:isActivated(Object)
	local Value = Object:GetAttribute("Activated")
	return Value
end

function this:getInteractor(Object)
	local Interactor = Object:GetAttribute("Interactor")
	return Interactor
end

function this:getActivationTime(Object)
	local Interactor = Object:GetAttribute("ActivationTime")
	return Interactor
end

function this:getDeactivationTime(Object)
	local Interactor = Object:GetAttribute("DeactivationTime")
	return Interactor
end

function this:getLoads(Object)
	local Interactor = Object:GetAttribute("Loads")
	return Interactor
end

function this:getOverload(Object)
	local Interactor = Object:GetAttribute("Overload")
	return Interactor
end

function this:getRefill(Object)
	local Interactor = Object:GetAttribute("Refill")
	return Interactor
end

function this:getInteractionTime(Object)
	local Interactor = Object:GetAttribute("InteractionTime")
	return Interactor
end

function this:hasInteractor(Object)
	local Interactor = Object:GetAttribute("Interactor")
	
	if (Interactor ~= 0) then
		return true
	end
	
	return false
end

function this:setActivated(Object, Value)
	Object:SetAttribute("Activated", Value)
end

function this:setInteractionTime(Object, Value)
	Object:SetAttribute("InteractionTime", Value)
end

function this:setActivationTime(Object, Value)
	Object:SetAttribute("ActivationTime", Value)
end

function this:setDeactivationTime(Object, Value)
	Object:SetAttribute("DeactivationTime", Value)
end

function this:setLoads(Object, Value)
	Object:SetAttribute("Loads", Value)
end

function this:setOverload(Object, Value)
	Object:SetAttribute("Overload", Value)
end

function this:setRefill(Object, Value)
	Object:SetAttribute("Refill", Value)
end

function this:setInteractor(Object, ID)
	Object:SetAttribute("Interactor", ID)
end

return this
