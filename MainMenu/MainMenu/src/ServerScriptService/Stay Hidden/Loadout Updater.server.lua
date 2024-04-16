local SaveStorage = require(game.ServerScriptService.Handlers["Save Storage"])
local CharacterInfo = require(game.ServerScriptService.Global.CharacterInfo)
local LoadoutEvent = game.ReplicatedStorage.Remotes.LoadoutEvent
local GameModifiers = game.ServerStorage.Modifiers
local GamePerks = game.ServerStorage.Perks

function onLoadoutUpdate(Player, Role, Category, Selection, Slot)
	
	if (Category == "Character") then
		return checkCharacter(Player, Role, Selection)
	end
	
	if (Category == "Modifier") then
		return checkModifier(Player, Role, Selection, Slot)
	end
	
	if (Category == "Perk") then
		return checkPerk(Player, Role, Selection, Slot)
	end
	
end

function checkCharacter(Player, Role, Selection)
	
	if (CharacterInfo.Characters[Role][Selection] ~= nil) then
		if (CharacterInfo.Characters[Role][Selection]) then
			local Profile = SaveStorage:get(Player.UserId)
			Profile[Role].Selected = Selection 
			print(`Selected {Selection}`)
		end
	end
end

function checkModifier(Player, Role, Modifier, Slot)
	local Profile = SaveStorage:get(Player.UserId)
	local Character = Profile[Role].Selected
	
	local Slots = {["Modifier1"] = "Slot1", ["Modifier2"] = "Slot2"}
	
	if (Modifier == "") then
		Profile[Role][Character].LoadOut.Modifiers[Slots[Slot]] = ""
		print(`Cleared Modifier on Slot {Slot}`)
		return true
	end
	
	if (validateModifier(Profile, Role, Character, Modifier)) then
		Profile[Role][Character].LoadOut.Modifiers[Slots[Slot]] = Modifier
		print(`Equipped Modifier {Modifier} on Slot {Slot}`)
		return true
	else
		Profile[Role][Character].LoadOut.Modifiers[Slots[Slot]] = ""
		print(`Cleared Modifier on Slot {Slot}`)
		return false
	end
end

function validateModifier(Profile, Role, Character, Modifier)
	
	local Modifiers = Profile[Role][Character].Inventory["Modifiers"]
	
	if (Modifiers ~= nil and not workspace:GetAttribute("Playtest")) then
		
		if (Modifiers[Modifier] == nil) then
			return false
		end
		
		if (Modifiers[Modifier] <= 0) then
			return false
		end
		
		if (GameModifiers[Role][Character]:FindFirstChild(Modifier, false) == nil) then
			return false
		end
		
	end
	
	return true
	
end

function checkPerk(Player, Role, Perk, Slot)
	local Profile = SaveStorage:get(Player.UserId)
	local Character = Profile[Role].Selected

	local Slots = {["Perk1"] = "Slot1", ["Perk2"] = "Slot2", ["Perk3"] = "Slot3"}

	if (Perk == "") then
		Profile[Role][Character].LoadOut.Perks[Slots[Slot]] = ""
		print(`Cleared Perk on Slot {Slot}`)
		return true
	end

	if (validatePerk(Profile, Role, Character, Perk)) then
		Profile[Role][Character].LoadOut.Perks[Slots[Slot]] = Perk
		print(`Equipped Perk {Perk} on Slot {Slot}`)
		return true
	else
		Profile[Role][Character].LoadOut.Perks[Slots[Slot]] = ""
		print(`Cleared Perk on Slot {Slot}`)
		return false
	end
end

function validatePerk(Profile, Role, Character, Perk)

	local Perks = Profile[Role][Character].Inventory["Perks"]

	if (Perks ~= nil and not workspace:GetAttribute("Playtest")) then

		if (Perks[Perk] == nil) then
			return false
		end

		if (Perks[Perk] <= 0) then
			return false
		end

		if (GamePerks[Role]:FindFirstChild(Perk, false) == nil) then
			return false
		end
	
	end

	return true

end

LoadoutEvent.OnServerEvent:Connect(onLoadoutUpdate)