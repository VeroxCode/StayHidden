local SaveStorage = require(game.ServerScriptService.Handlers["Save Storage"])
local Remotes = game.ReplicatedStorage.Remotes

function updateSettings(Player, Settings)
	
	local Profile = SaveStorage:get(Player.UserId)
	Profile.Account.Settings = Settings
	SaveStorage:update(Player.UserId, Profile)
	Remotes.updateSettings:InvokeClient(Player, Profile)
	print(Profile)
	
end

Remotes.updateSettings.OnServerInvoke = updateSettings