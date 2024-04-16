local this = {}

function this:isFilled(Collector)
	local Filled = Collector:GetAttribute("Filled")
	return Filled
end

function this:getProgress(Collector)
	local Progress = Collector:GetAttribute("Progress")
	return Progress
end

function this:getMaximum(Collector)
	local Maximum = Collector:GetAttribute("Maximum")
	return Maximum
end

function this:getInteractor(Collector)
	local Interactor = Collector:GetAttribute("Interactor")
	return Interactor
end

function this:getInteractionTime(Collector)
	local InteractionTime = Collector:GetAttribute("InteractionTime")
	return InteractionTime
end

function this:hasInteractor(Collector)
	local Interactor = Collector:GetAttribute("Interactor")
	
	if (Interactor ~= 0) then
		return true
	end
	
	return false
end

function this:setFilled(Collector, Value)
	Collector:SetAttribute("Filled", Value)
end

function this:setProgress(Collector, Value)
	Collector:SetAttribute("Progress", Value)
end

function this:setMaximum(Collector, Value)
	Collector:SetAttribute("Maximum", Value)
end

function this:setInteractor(Collector, Player)
	Collector:SetAttribute("Interactor", Player)
end

function this:setInteractionTime(Collector, Value)
	Collector:SetAttribute("InteractionTime", Value)
end

return this
