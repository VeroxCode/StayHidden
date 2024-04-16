local Storage = {}

local this = {}

function this.add(PlayerID, SaveFile)
	
	local ProfileName = tostring(PlayerID)
	
	Storage[ProfileName] = {}
	Storage[ProfileName] = SaveFile
end

function this:update(PlayerID, SaveFile)
	
	local ProfileName = tostring(PlayerID)

	if (Storage[ProfileName] ~= nil) then
		Storage[ProfileName] = SaveFile
	end

	return nil

end

function this:get(PlayerID)
	local ProfileName = tostring(PlayerID)

	if (Storage[ProfileName] ~= nil) then
		return Storage[ProfileName]
	end

	return nil
end

function this:getAll()
	return Storage
end

return this
