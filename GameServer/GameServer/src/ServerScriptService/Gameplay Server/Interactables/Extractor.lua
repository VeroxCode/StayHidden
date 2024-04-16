local this = {}

function this:getParts(Extractor)
	local Parts = Extractor:GetAttribute("Parts")
	return Parts
end

function this:getCycles(Extractor)
	local Cycles = Extractor:GetAttribute("Cycles")
	return Cycles
end

function this:getProgress(Extractor)
	local Progress = Extractor:GetAttribute("Progress")
	return Progress
end

function this:getFillSpeed(Extractor)
	local Fill_Speed = Extractor:GetAttribute("Fill_Speed")
	return Fill_Speed
end

function this:getPartsRequired(Extractor)
	local PartsRequired = Extractor:GetAttribute("PartsRequired")
	return PartsRequired
end

function this:getInstantRregression(Extractor)
	local InstantRregression = Extractor:GetAttribute("InstantRregression")
	return InstantRregression
end

function this:getDamageTimeout(Extractor)
	local DamageTimeout = Extractor:GetAttribute("DamageTimeout")
	return DamageTimeout
end

function this:isDamaged(Extractor)
	local Damaged = Extractor:GetAttribute("Damaged")
	return Damaged
end

function this:hasPartsInstalled(Extractor)
	local PartsInstalled = Extractor:GetAttribute("PartsInstalled")
	return PartsInstalled
end

function this:getInteractor(Extractor)
	local Interactor = Extractor:GetAttribute("Interactor")
	return Interactor
end

function this:getInteractionTime(Extractor)
	local InteractionTime = Extractor:GetAttribute("InteractionTime")
	return InteractionTime
end

function this:hasInteractor(Extractor)
	local Interactor = Extractor:GetAttribute("Interactor")
	
	if (Interactor ~= 0) then
		return true
	end
	
	return false
end

function this:setParts(Extractor, Value)
	Extractor:SetAttribute("Parts", Value)
end

function this:setCycles(Extractor, Value)
	Extractor:SetAttribute("Cycles", Value)
end

function this:setProgress(Extractor, Value)
	Extractor:SetAttribute("Progress", Value)
end

function this:setFillSpeed(Extractor, Value)
	Extractor:SetAttribute("Fill_Speed", Value)
end

function this:setPartsRequired(Extractor, Value)
	Extractor:SetAttribute("PartsRequired", Value)
end

function this:setInstantRregression(Extractor, Value)
	Extractor:SetAttribute("InstantRregression", Value)
end

function this:setDamageTimeout(Extractor, Value)
	Extractor:SetAttribute("DamageTimeout", Value)
end

function this:setPartsInstalled(Extractor, Bool)
	Extractor:SetAttribute("PartsInstalled", Bool)
end

function this:setDamaged(Extractor, Value)
	Extractor:SetAttribute("Damaged", Value)
end

function this:setInteractor(Extractor, Player)
	Extractor:SetAttribute("Interactor", Player)
end

function this:setInteractionTime(Extractor, Value)
	Extractor:SetAttribute("InteractionTime", Value)
end

return this
