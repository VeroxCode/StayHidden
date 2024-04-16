local Storage = {}

local this = {}

function this:add(PlayerID, Binds)
	local newFile = {
		ID = PlayerID,
		Table = Binds
	}
	table.insert(Storage, newFile)
end

function this:delete(PlayerID)
	for count = 1, #Storage, 1 do
		if (Storage[count]["ID"] == PlayerID) then
			table.remove(Storage, count)
		end
	end
end

function this:update(PlayerID, Binds)
	for count = 1, #Storage, 1 do
		if (Storage[count]["ID"] == PlayerID) then
			local newFile = {
				ID = PlayerID,
				Table = Binds
			}
			table.insert(Storage, newFile)
		else
			this:add(PlayerID, Binds)
		end
	end
end

function this:get(PlayerID)
	for count = 1, #Storage, 1 do
		if (Storage[count]["ID"] == PlayerID) then
			return Storage[count]["Table"]
		end
	end
end

return this
