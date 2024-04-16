local this = {}


function this:getInteractor(Object)
	local Interactor = Object:GetAttribute("Interactor")
	return Interactor
end

function this:getInteractionTime(Object)
	local Interactor = Object:GetAttribute("InteractionTime")
	return Interactor
end

function this:isActive(Object)
	return Object:GetAttribute("Active")
end

function this:getStuntime(Object)
	return Object:GetAttribute("Stuntime")
end

function this:getInstalltime(Object)
	return Object:GetAttribute("Installtime")
end

function this:getProgress(Collector)
	local Progress = Collector:GetAttribute("Progress")
	return Progress
end

function this:hasInteractor(Object)
	local Interactor = Object:GetAttribute("Interactor")
	
	if (Interactor ~= 0) then
		return true
	end
	
	return false
end

function this:setActive(Object, Value)
	Object:SetAttribute("Active", Value)
end

function this:setStuntime(Object, Value)
	Object:SetAttribute("Stuntime", Value)
end

function this:setInstalltime(Object, Value)
	Object:SetAttribute("Installtime", Value)
end

function this:setProgress(Object, Value)
	Object:SetAttribute("Progress", Value)
end

function this:setInteractionTime(Object, Value)
	Object:SetAttribute("InteractionTime", Value)
end

function this:setInteractor(Object, ID)
	Object:SetAttribute("Interactor", ID)
end

return this
