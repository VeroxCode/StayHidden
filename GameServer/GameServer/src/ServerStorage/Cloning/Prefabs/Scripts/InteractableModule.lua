local this = {}


function this:getInteractor(Object)
	local Interactor = Object:GetAttribute("Interactor")
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

function this:setInteractionTime(Object, Value)
	Object:SetAttribute("InteractionTime", Value)
end

function this:setInteractor(Object, ID)
	Object:SetAttribute("Interactor", ID)
end

return this
