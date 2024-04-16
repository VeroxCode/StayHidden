local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local SpawnNotification = game.ReplicatedStorage.Remotes:WaitForChild("SpawnNotification")
local Events = game.ServerStorage.Events

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ACTIVATION_DISTANCE = 4.5

local ObjectList = workspace:WaitForChild("Map").Interactables.Graves
local ObjectModule = Modules.Grave
local Interaction = Modules.Actions.Interactions.Grave
local InteractionCategory = "Interactions"
local InteractionName = "Pray \n (Hold)"

local DebugTable = {
	inDebug = workspace:GetAttribute("Debug"),
	Players = workspace:GetAttribute("DebugPlayers"),
	needHunter = workspace:GetAttribute("DebugNeedHunter")
}

local function getObjectValues(Player, Object)

	local WSPlayer = Modules.Game:getWorkspacePlayer(Player.UserId)
	local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")

	local Object = Object
	local PlayerPosition = RootPart.CFrame.Position
	local PlayerXZ = {PlayerPosition.X, PlayerPosition.Z}
	local ObjectPosition = Object.Position
	local ObjectXZ = {ObjectPosition.X, ObjectPosition.Z}
	local DistanceXZ = {math.abs(PlayerXZ[1] - ObjectXZ[1]), math.abs(PlayerXZ[2] - ObjectXZ[2])}
	local DistanceY = math.abs(PlayerPosition.Y - ObjectPosition.Y)

	local RespawnSpeed = ObjectModule:getRespawnSpeed(Object)
	local PrayBonus = ObjectModule:getPrayBonus(Object)
	local SpawnTime = ObjectModule:getSpawnTime(Object)
	
	local HasOccupant = ObjectModule:hasOccupant(Object)
	local Occupant = ObjectModule:getOccupant(Object)

	local hasInteractor = ObjectModule:hasInteractor(Object)
	local Interactor = ObjectModule:getInteractor(Object)

	local Values = {
		["DistanceXZ"] = DistanceXZ,
		["DistanceY"] = DistanceY,
		["Interactor"] = Interactor,
		["hasInteractor"] = hasInteractor,
		["RespawnSpeed"] = RespawnSpeed,
		["PrayBonus"] = PrayBonus,
		["SpawnTime"] = SpawnTime,
		["HasOccupant"] = HasOccupant,
		["Occupant"] = Occupant,
	}
	return Values

end

function validateInteractor(Object, ObjectValues, PlayerId)
	if ((ObjectValues.DistanceXZ[1] > ACTIVATION_DISTANCE or ObjectValues.DistanceXZ[2] > ACTIVATION_DISTANCE)) then
		if (ObjectValues.Interactor == PlayerId) then
			
			releaseInteractor(ObjectValues.Interactor)
			
			Object:SetAttribute("Interactor", 0)
			Object:SetAttribute("InteractionTime", 0)
		end
	end
end

function releaseInteractor(InteractorID)
	
	if (InteractorID == 0 or InteractorID == nil) then
		return
	end

	local MatchPlayer = Modules.Game:getMatchPlayer(InteractorID)
	local isSprinting = Modules.Game:isSprinting(MatchPlayer)
	Modules.Actions:setAction(InteractorID, Modules.Actions.List.IDLE)
	Modules.Speed:removeMultiplier(MatchPlayer, "Interaction")
	Modules.Game:setAnimationAction(MatchPlayer, if (isSprinting) then "Run" else "Walk")
end

function manageTransparency(Object, ObjectValues)
	
	if (ObjectValues.HasOccupant) then
		local goal = {Transparency = 0}
		local Tween = TweenService:Create(Object, TweenInfo.new(1), goal)
		Tween:Play()
	else
		local goal = {Transparency = 1}
		local Tween = TweenService:Create(Object, TweenInfo.new(1), goal)
		Tween:Play()
	end
	
end

function releasePlayer(Object, Occupant)
	
	local Player = game.Players[Occupant]
	local WSPlayer = workspace:WaitForChild(Occupant)
	local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")
	local MatchPlayers = game.ReplicatedStorage.Match.Players
	local MatchPlayer = MatchPlayers[Occupant]
	local isSprinting = Modules.Game:isSprinting(MatchPlayer)

	local ObjectPosition = Object.CFrame.Position
	RootPart.CFrame = CFrame.new(ObjectPosition)
	RootPart.Anchored = false
	Modules.PlayerUtils:setTransparency(Occupant, 0)
	
	for i, p in pairs(Players:GetPlayers()) do
		Modules.AuraManager:removeAura(p, "Graves", Object.Name, Occupant)
	end
	
	Modules.Game:setVulnerable(MatchPlayer, true)
	Modules.Game:setEffect(MatchPlayer, "Swiftness", "Value", 1.25)
	Modules.Game:applyTimedEffect(MatchPlayer, "Protection", 2.5)
	Modules.Game:applyTimedEffect(MatchPlayer, "Swiftness", 2.5)
	Modules.Actions:setInteraction(MatchPlayer:GetAttribute("ID"), 0)
	Modules.Game:stopIProgress(Player.UserId)
	Modules.Game:setAnimationAction(MatchPlayer, if (isSprinting) then "Run" else "Walk")
	Modules.Actions:setAction(Player.UserId, Modules.Actions.List.IDLE)
	
	Object:SetAttribute("SpawnTime", 0)
	Object:SetAttribute("Player", "")
	
end

function onServerTick(delta)
	
	if (not Modules.Game:isRunning()) then
		return
	end
	
	for i, Object in pairs(ObjectList:GetChildren()) do
		if (not Object:isA("Part") and not Object:isA("MeshPart")) then continue end
		
		local RespawnSpeed = ObjectModule:getRespawnSpeed(Object)
		local PrayBonus = ObjectModule:getPrayBonus(Object)
		local SpawnTime = ObjectModule:getSpawnTime(Object)

		local HasOccupant = ObjectModule:hasOccupant(Object)
		local Occupant = ObjectModule:getOccupant(Object)

		local hasInteractor = ObjectModule:hasInteractor(Object)
		local Interactor = ObjectModule:getInteractor(Object)
		
		Object.CanCollide = HasOccupant
		
		if (HasOccupant) then
			if (SpawnTime < 100) then
				local WSPlayer = workspace:WaitForChild(Occupant)
				local Player = game.Players[Occupant]
				local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")

				local ObjectPosition = Object.CFrame.Position
				RootPart.CFrame = CFrame.new(ObjectPosition)
				RootPart.Anchored = true
				Modules.PlayerUtils:setTransparency(Occupant, 1)

				local spawnSpeed = hasInteractor == true and (delta * PrayBonus) + (delta * RespawnSpeed) or (delta * RespawnSpeed)
				local newSpawnTime = math.clamp(SpawnTime + spawnSpeed, 0, 100)

				Modules.Game:setIProgress(Player.UserId, "Respawning", newSpawnTime, 100)
				Object:SetAttribute("SpawnTime", newSpawnTime)
			else
				releaseInteractor(Interactor)
				releasePlayer(Object, Occupant)
			end

		end
		
		for i, Player in ipairs(Players:GetPlayers()) do
			if (not Object:isA("Part") and not Object:isA("MeshPart")) then continue end

			local isHunter = Modules.Game:isHunter(Player.UserId)
			local ObjectValues = getObjectValues(Player, Object)
			
			if (ObjectValues ~= nil) then
				manageTransparency(Object, ObjectValues)
				
				if (ObjectValues.hasInteractor) then
					validateInteractor(Object, ObjectValues, Player.UserId)
				end
					
				if ((ObjectValues.DistanceXZ[1] <= ACTIVATION_DISTANCE and ObjectValues.DistanceXZ[2] <= ACTIVATION_DISTANCE)) then
					if (not ObjectValues.hasInteractor and ObjectValues.HasOccupant and Player.Name ~= ObjectValues.Occupant and not isHunter) then
						Modules.Actions:setInteraction(Player.UserId, Interaction)
						Modules.Game:spawnPrompt(Player.UserId, InteractionCategory, InteractionName)
					end
				end
			end
		end
	end
end

function onInputClick(Player, Key, Down)
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local isHunter = Modules.Game:isHunter(Player.UserId)

	if (isHunter or not Modules.Game:isRunning()) then
		return
	end

	local Binds = Modules.BindStorage:get(Player.UserId)
	local Interactions = {Binds.Controller[InteractionCategory], Binds.Keyboard[InteractionCategory]}

	if (table.find(Interactions, Key.Value)) then
		for count = 1, (#ObjectList:GetChildren() - 1) do

			local WSPlayer = Modules.Game:getWorkspacePlayer(Player.UserId)
			local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
			local MatchPlayerID = MatchPlayer:GetAttribute("ID")
			local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")

			local HasSerum = MatchPlayer:GetAttribute("hasSerum")

			local Object = ObjectList[count]
			local ObjectValues = getObjectValues(Player, Object)

			if (ObjectValues ~= nil) then
				if (Down) then
					if ((ObjectValues.DistanceXZ[1] <= ACTIVATION_DISTANCE and ObjectValues.DistanceXZ[2] <= ACTIVATION_DISTANCE) and Modules.Actions:getInteraction(MatchPlayerID) == Interaction) then
						if (not ObjectValues.hasInteractor) then
							local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)

							Modules.Actions:setAction(Player.UserId, Modules.Actions.List.PRAYING)
							Modules.PlayerUtils:setRotation(RootPart, Object.Position, .2)
							Modules.Game:setAnimationAction(MatchPlayer, "Pray")
							Modules.Speed:addMultiplier(MatchPlayer, "Interaction", 0, 0)

							Object:SetAttribute("Interactor", Player.UserId)
							Object:SetAttribute("InteractionTime", 0)
						end
					end
				else
					if (ObjectValues.Interactor == Player.UserId) then
						local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)

						Modules.Actions:setAction(Player.UserId, Modules.Actions.List.IDLE)
						Modules.Speed:removeMultiplier(MatchPlayer, "Interaction")
						Modules.Game:setAnimationAction(MatchPlayer, "Walk")

						Object:SetAttribute("Interactor", 0)
						Object:SetAttribute("InteractionTime", 0)
					end
				end
			end
		end
	end

end

function onMobileInput(Player, Action, Down)
	if (Action == Interaction and Down) then
		for count = 1, (#ObjectList:GetChildren() - 1) do

			local WSPlayer = Modules.Game:getWorkspacePlayer(Player.UserId)
			local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
			local MatchPlayerID = MatchPlayer:GetAttribute("ID")
			local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")

			local Object = ObjectList[count]
			local ObjectValues = getObjectValues(Player, Object)

			if (ObjectValues ~= nil) then
				if ((ObjectValues.DistanceXZ[1] <= ACTIVATION_DISTANCE and ObjectValues.DistanceXZ[2] <= ACTIVATION_DISTANCE) and Modules.Actions:getInteraction(MatchPlayerID) == Interaction) then
					if (not ObjectValues.hasInteractor) then
						Object:SetAttribute("Interactor", Player.UserId)
						Object:SetAttribute("InteractionTime", 0)
					end
				end
			end
		end
	end
end

function sendToGrave(Player, ObjectID)

	local Object = ObjectList[ObjectID]
	local OPlayer = Object:GetAttribute("Player")
			
	local WSPlayer = workspace:WaitForChild(Player.Name)
	local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")
	local MatchPlayer = game.ReplicatedStorage.Match.Players[Player.Name]
			
	local ObjectPosition = Object.CFrame.Position
	local newMaxHealth = Modules.Game:getMaxHealth(MatchPlayer) - 20
	
	if (newMaxHealth <= 50) then
		Events.Prey.onDeath:Fire(Player)
		return
	end
		
	RootPart.CFrame = CFrame.new(ObjectPosition)
	MatchPlayer.Values:SetAttribute("MaxHealth", newMaxHealth)
	MatchPlayer.Values:SetAttribute("Health", newMaxHealth)
	Modules.Actions:setInteraction(Player.UserId, Modules.Actions.Interactions.Grave)
	Modules.Actions:setAction(Player.UserId, Modules.Actions.List.RESPAWNING)
	Modules.Game:setAnimationAction(MatchPlayer, "Idle")
	Modules.Game:setVulnerable(MatchPlayer, false)
	Modules.Game:setSerum(MatchPlayer, false)
	Object:SetAttribute("Player", Player.Name)
	
	for i, p in pairs(Players:GetPlayers()) do
		if (p.Name ~= Player.Name) then
			
			local MatchP = Modules.Game:getMatchPlayer(p.UserId)
			local Role = Modules.Game:getRole(MatchP)
			
			if (Role == "Prey") then
				Modules.AuraManager:createAura(p, "Graves", ObjectID, false, 0, Color3.new(1, 0, 0.0156863), Color3.new(1, 0, 0.0156863), Player.Name)
				SpawnNotification:FireClient(p, "Prey", `{Player.Name} was sent to a Grave!`)
			end 
		end
	end
end

Events.onInputClick.Event:Connect(onInputClick)
Events.onMobileInput.Event:Connect(onMobileInput)
Events.Game.ServerTick.Event:Connect(onServerTick)
Events.Prey.sendToGrave.Event:Connect(sendToGrave)