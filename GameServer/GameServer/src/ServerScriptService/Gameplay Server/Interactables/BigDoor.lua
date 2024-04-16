local this = {}

function this:isOpened(Object)
	local Value = Object:GetAttribute("Opened")
	return Value
end

function this:isPowered(Object)
	local Value = Object:GetAttribute("Powered")
	return Value
end

function this:getFusebox(Object)
	local Value = Object:GetAttribute("Fusebox")
	return Value
end

function this:getTimer(Object, Value)
	local Value = Object:GetAttribute("Timer")
	return Value
end

function this:getCloseTime(Object, Value)
	local Value = Object:GetAttribute("CloseTime")
	return Value
end

function this:isTweening(Object, Value)
	local Value = Object:GetAttribute("Tweening")
	return Value
end

function this:getInteractor(Object)
	local Interactor = Object:GetAttribute("Interactor")
	return Interactor
end

function this:hasInteractor(Object)
	local Interactor = Object:GetAttribute("Interactor")
	
	if (Interactor ~= 0) then
		return true
	end
	
	return false
end

function this:setInteractor(Object, ID)
	Object:SetAttribute("Interactor", ID)
end

function this:setOpened(Object, Value)
	Object:SetAttribute("Opened", Value)
end

function this:setPowered(Object, Value)
	Object:SetAttribute("Powered", Value)
end

function this:setTimer(Object, Value)
	Object:SetAttribute("Timer", Value)
end

function this:setCloseTime(Object, Value)
	Object:SetAttribute("CloseTime", Value)
end

function this:setTweening(Object, Value)
	Object:SetAttribute("Tweening", Value)
end

return this
