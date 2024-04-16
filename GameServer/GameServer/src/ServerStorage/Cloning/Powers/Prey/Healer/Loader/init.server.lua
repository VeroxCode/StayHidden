local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Events = game.ServerStorage.Events

local LoaderPlayer = script.Parent.Parent
local Main = require(script.Main)
local Power = script.Parent

function ServerTick(delta)
	
	local Cooldown = Power:GetAttribute("ActiveCooldown")
	local Player = game.Players:WaitForChild(LoaderPlayer.Name)
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	
	if (Cooldown > 0) then
		Power:SetAttribute("ActiveCooldown", Cooldown - delta)
		Modules.Game:setAbilityValue(MatchPlayer, "Cooldown", Cooldown - delta)
	end
end

function MouseClickEvent(Player, Key, Down)
	
	if (Player.Name ~= LoaderPlayer.Name) then
		return
	end
	
	if (Key == 2) then
		if (Down) then
			Main:performAbility(Player)
		else
			Main:cancelAbility(Player)
		end
	end
end

function InputClickEvent(Player, Key, Down)
	
	if (Player.Name ~= LoaderPlayer.Name) then
		return
	end
	
	local Binds = Modules.BindStorage:get(Player.UserId)

	if (Binds) then

		local Secondary = {Binds.Controller.SecondaryAbility, Binds.Keyboard.SecondaryAbility} 
		
		if (Key.Value == Enum.KeyCode.ButtonL2.Value) then
			if (Down) then
				Main:performAbility(Player)
			else
				Main:cancelAbility(Player)
			end
		end
		
		if (table.find(Secondary, Key.Value)) then
			if (Down) then
				Main:performSecondary(Player)
			else
				Main:cancelSecondary(Player)
			end
		end
	end
end

function MobileInputEvent(Player, Action, Down)

	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local Role = Modules.Game:getRole(MatchPlayer)

	if (Role == "Hunter" or Player.Name ~= LoaderPlayer.Name) then
		return
	end

	if (Action == "Power") then
		if (Down) then
			Main:performAbility(Player)
		else
			Main:cancelAbility(Player)
		end
	end

	if (Action == "Secondary") then
		if (Down) then
			Main:performSecondary(Player)
		else
			Main:cancelSecondary(Player)
		end
	end

end

Events.Game.ServerTick.Event:Connect(ServerTick)
Events.onMouseClick.Event:Connect(MouseClickEvent)
Events.onInputClick.Event:Connect(InputClickEvent)
Events.onMobileInput.Event:Connect(MobileInputEvent)