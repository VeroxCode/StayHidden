local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local Remotes = game.ReplicatedStorage.Remotes
local Events = game.ServerStorage.Events

local Players = game:GetService("Players")

local DebugTable = {
	inDebug = workspace:GetAttribute("Debug");
	Players = workspace:GetAttribute("DebugPlayers");
	needHunter = workspace:GetAttribute("DebugNeedHunter");
	startHunter = workspace:GetAttribute("DebugStartHunter");
}

Remotes.ChaseEvent.OnServerEvent:Connect(function(Player, Target)
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Target.UserId)
	local Hunter = Modules.Game:getHunter()
	
	warn(`{Player.Name} | {Player.UserId} fired this`)
	
end)

Events.Game.ServerTick.Event:Connect(function(delta)
	
	if (not Modules.Game:isRunning() or Modules.Game:getMatchTimer() < 5 or (DebugTable.inDebug and not DebugTable.needHunter) or (DebugTable.inDebug and DebugTable.Players < 2)) then
		return
	end
	
	local Hunter = Modules.Game:getHunter()
	local HunterWS = workspace:WaitForChild(Hunter.Name)
	local HunterRoot = HunterWS.HumanoidRootPart
	
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {HunterWS}
	local PartsInChaseTrace = workspace:GetPartBoundsInBox(HunterRoot.CFrame, Vector3.new(60, 10, 60), params)

	for i, v in pairs(PartsInChaseTrace) do
		if (game.Players:FindFirstChild(v.Parent.Name) ~= nil) then
			if (v.Parent.Name ~= Hunter.Name) then
				
				local ChaseTimerH = Modules.Game:getChaseTimer(Hunter)
				local MatchPlayer = game.ReplicatedStorage.Match.Players[v.Parent.Name]
				local ChaseTimerP = Modules.Game:getChaseTimer(MatchPlayer)
				local isSprinting = Modules.Game:isSprinting(MatchPlayer)
				
				local Action = Modules.Actions:getAction(MatchPlayer:getAttribute("ID"))
				
				if ((ChaseTimerP <= 2 or ChaseTimerH <= 2) and Action ~= Modules.Actions.List.RESPAWNING and isSprinting) then
					Modules.Game:setChaseTimer(Hunter, 6.5)
					Modules.Game:setChaseTimer(MatchPlayer, 6.5)
				end
			end
		end
	end
	
	for i, Player in pairs(Players:GetPlayers()) do

		local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
		local isSprinting = Modules.Game:isSprinting(MatchPlayer)
		
		local newTimer = Modules.Game:getChaseTimer(MatchPlayer)
		newTimer -= delta

		Modules.Game:setChaseTimer(MatchPlayer, newTimer)
		
		if (newTimer > 0) then
			if (not Modules.Game:inChase(MatchPlayer)) then
				Modules.Game:setInChase(MatchPlayer, true)
			end
		else
			Modules.Game:setInChase(MatchPlayer, false)
		end

		local Player = Players:GetPlayerByUserId(MatchPlayer:GetAttribute("ID"))

		if (newTimer > 0) then
			Modules.Credits:increaseCredits(Player.UserId, (Modules.Game_Values.ScoreEvents.Generic.ChaseTime * delta))
		else

			local Role = Modules.Game:getRole(MatchPlayer)

			if (Role == "Prey") then

				if (Modules.Game:getHunter() == nil) then
					Modules.Game:setHunterDistance(MatchPlayer, 1000)
					return
				end

				local Hunter = Modules.Game:getHunter()
				local HunterWS = workspace:WaitForChild(Hunter.Name)
				local HunterRoot = HunterWS.HumanoidRootPart

				local PlayerWS = workspace:WaitForChild(Player.Name)
				local PlayerRoot = PlayerWS.HumanoidRootPart

				local HunterPos = Vector3.new(HunterRoot.CFrame.Position.X, 0, HunterRoot.CFrame.Position.Z)
				local PlayerPos = Vector3.new(PlayerRoot.CFrame.Position.X, 0, PlayerRoot.CFrame.Position.Z)
				local Distance =  Modules.PlayerUtils:getVectorDistanceXZ(HunterPos, PlayerPos)
				
				Modules.Game:setHunterDistance(MatchPlayer, Distance)
			end
		end	
	end
	
end)