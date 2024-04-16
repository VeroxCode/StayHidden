local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Events = game.ServerStorage.Events

function InputClickEvent(Player, Key, Down)

	if (Player.Name ~= script.Parent.Name) then
		return
	end

	local Binds = Modules.BindStorage:get(Player.UserId)

	if (Binds) then

		local Secondary = {Binds.Controller.SecondaryAbility, Binds.Keyboard.SecondaryAbility} 

		if (table.find(Secondary, Key.Value)) then
			if (Down) then
				useItem(Player)
			else
				cancelUsage(Player)
			end
		end
	end
end

function MobileInputEvent(Player, Action, Down)

	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local Role = Modules.Game:getRole(MatchPlayer)

	if (Role == "Hunter" or Player.Name ~= script.Parent.Name) then
		return
	end

	if (Action == "Secondary") then
		if (Down) then
			useItem(Player)
		else
			cancelUsage(Player)
		end
	end
end

function useItem(Player)
end

function cancelUsage(Player)
end

Events.onInputClick.Event:Connect(InputClickEvent)
Events.onMobileInput.Event:Connect(MobileInputEvent)