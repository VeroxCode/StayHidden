local BindStorage = require(game.ServerScriptService.Handlers["Bind Storage"])
local Remotes = game.ReplicatedStorage.Remotes

function updateBind(Player, InputType, Action, KeyValue)

	local Binds = BindStorage:get(Player.UserId)
	print(`Pre: `, Binds)
	Binds[InputType][Action] = KeyValue
	print(`Post: `, Binds)
	BindStorage:update(Player.UserId, Binds)
	Remotes.updateBind:InvokeClient(Player, Binds)
	print("resend B")

end

Remotes.updateBind.OnServerInvoke = updateBind