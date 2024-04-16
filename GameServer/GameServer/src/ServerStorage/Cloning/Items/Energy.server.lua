local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Events = game.ServerStorage.Events

local Runner = nil
local HealAmount = 15

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

	local Progress = 0
	local TimeToUse = 5

	Runner = Events.Game.ServerTick.Event:Connect(function(delta)
		
		local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
		local isSprinting = Modules.Game:isSprinting(MatchPlayer)
		
		delta = if (isSprinting) then delta / 2 else delta
		Progress += (100 / TimeToUse) * delta
		Modules.Game:setIProgress(Player.UserId, "Self Healing", Progress, 100)

		if (Progress >= 100) then
			Modules.Game:healPlayer(Player, HealAmount)
			Modules.Game:stopIProgress(Player.UserId)
			Modules.Game:setItem(MatchPlayer, "")
			cancelUsage(Player)
			script.Enabled = false
			script:Destroy()
		end

	end)

end

function cancelUsage(Player)

	if (Runner ~= nil) then
		Runner:Disconnect()
		Runner = nil
	end
	
	Modules.Game:stopIProgress(Player.UserId)

end

Events.onInputClick.Event:Connect(InputClickEvent)
Events.onMobileInput.Event:Connect(MobileInputEvent)