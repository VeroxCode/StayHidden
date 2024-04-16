--!native

local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules

local MobileInputEvent = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("MobileInputEvent")
local MouseEvent = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("MouseEvent")
local InputEvent = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("InputEvent")

local onMobileInput = game.ServerStorage.Events:WaitForChild("onMobileInput")
local onMouseClick = game.ServerStorage.Events:WaitForChild("onMouseClick")
local onInputClick = game.ServerStorage.Events:WaitForChild("onInputClick")


MouseEvent.OnServerEvent:Connect(function(Player, Key, Down)
	onMouseClick:Fire(Player, Key, Down)
end)

InputEvent.OnServerEvent:Connect(function(Player, Key, Down, Processed)
	local Binds = Modules.BindStorage:get(Player.UserId)
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	
	if (Binds) then
		
		local Crouch = {Binds.Controller.Crouch, Binds.Keyboard.Crouch} 
		local Sprint = {Binds.Controller.Sprint, Binds.Keyboard.Sprint}
		
		if (table.find(Sprint, Key.Value)) then
			Modules.Actions:performAction(Player.UserId, Modules.Actions.List.SPRINT, false, Down)
		end
		
		if (table.find(Crouch, Key.Value)) then
			Modules.Actions:performAction(Player.UserId, Modules.Actions.List.CROUCH, false, Down)
		end
	end
	
	onInputClick:Fire(Player, Key, Down)
	
end)

MobileInputEvent.OnServerEvent:Connect(function(Player, Action, Down)
	
	if (Action == "Attack") then
		Modules.Actions:performAction(Player.UserId, Modules.Actions.List.ATTACK, true)
	end
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local isSprinting = Modules.Game:isSprinting(MatchPlayer)
	local isCrouching = Modules.Game:isCrouching(MatchPlayer)

	if (Action == "Sprint") then
		Modules.Actions:performAction(Player.UserId, Modules.Actions.List.SPRINT, false, not isSprinting)
		Modules.Game:setSprinting(MatchPlayer, not isSprinting)
	end
	
	if (Action == "Crouch") then
		Modules.Actions:performAction(Player.UserId, Modules.Actions.List.CROUCH, false, not isCrouching)
		Modules.Game:setCrouching(MatchPlayer, not isCrouching)
	end
	
	print(Action, Down)
	
	onMobileInput:Fire(Player, Action, Down)
	
end)