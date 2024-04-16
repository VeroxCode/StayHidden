local this = {}


function this:isPowered(Object)
	local Value = Object:GetAttribute("Powered")
	return Value
end

function this:getFusebox(Object)
	local Value = Object:GetAttribute("Fusebox")
	return Value
end

function this:getInteractor(Object)
	local Interactor = Object:GetAttribute("Player")
	return Interactor
end

function this:hasInteractor(Object)
	local Interactor = Object:GetAttribute("Player")
	
	if (Interactor ~= 0) then
		return true
	end
	
	return false
end

function this:setInteractor(Object, ID)
	Object:SetAttribute("Interactor", ID)
end

function this:setPowered(Object, Value)
	Object:SetAttribute("Powered", Value)
end

return this
