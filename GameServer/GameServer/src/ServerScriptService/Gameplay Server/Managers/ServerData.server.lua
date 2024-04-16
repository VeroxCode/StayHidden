local SaveStorage = require(game.ServerScriptService.Handlers["Save Storage"])
local BindStorage = require(game.ServerScriptService.Handlers["Bind Storage"])
local CharacterInfo = require(game.ServerScriptService.Global.CharacterInfo)

local RequestData = game.ReplicatedStorage.Remotes.RequestData

function onRequest(Player, Character)
	
	if (Character == "AllCharacters") then
		return CharacterInfo.Characters
	end
	
	if (Character == "Profile") then
		return SaveStorage:get(Player.UserId)
	end
	
	if (Character == "Binds") then
		return BindStorage:get(Player.UserId)
	end
	
	if (Character == "DescCharacters") then
		return CharacterInfo.Descriptions
	end
	
	if (Character == "DescModifiers") then
		CharacterInfo:setupDescriptions()
		return CharacterInfo.DescModifier
	end
	
	if (Character == "DescPerks") then
		CharacterInfo:setupDescriptions()
		return CharacterInfo.DescPerks
	end
	
	if (Character == "ImagesModifiers") then
		return CharacterInfo.ModifierIcons
	end

	if (Character == "ImagesPerks") then
		return CharacterInfo.PerkIcons
	end
	
	return searchForCharacter(Player, Character)
	
end

function getCharacters(Player)
	local SaveState = SaveStorage:get(Player.UserId)
	
	local Characters = {
		["Prey"] = SaveState.Prey.Selected;
		["Hunter"] = SaveState.Hunter.Selected;
	}
	return Characters
end

function searchForCharacter(Player, Key)
	
	local Profile = SaveStorage:get(Player.UserId)

	for key, value in pairs(Profile.Prey) do
		if (key == Key) then
			return value
		end
	end
	
	for key, value in pairs(Profile.Hunter) do
		if (key == Key) then
			return value
		end
	end
	
end

RequestData.OnServerInvoke = onRequest