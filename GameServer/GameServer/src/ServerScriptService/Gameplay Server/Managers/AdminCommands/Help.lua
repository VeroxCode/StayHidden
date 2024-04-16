local ChatMessage = game.ReplicatedStorage.Remotes.ChatMessage

local this = {}

function this:execute(Player, message)
	ChatMessage:FireClient(Player, "Commands: \n" .. 
		"Parts <Amount> (Change Part Amount) \n" ..
		"Serum (Gives Player a Serum) \n" ..
		"Health <Amount> (Change Health) \n"..
		"Blackout (deactivates all Fuseboxes)" 
	)
end

return this
