local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules

game.ReplicatedStorage.Remotes.MovementUpdate.OnServerEvent:Connect(function(Player, Movement: CFrame)
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	Modules.Game:setMovement(MatchPlayer, Movement)
	
	for i, v in pairs(game.Players:GetPlayers()) do
		if (v.Name ~= Player.Name) then
			game.ReplicatedStorage.Remotes.MovementUpdate:FireClient(v, Player, Movement)
		end
	end
end)