--!native

local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ACTIVATION_DISTANCE = 3
local INTERACTION_TIME = 5

local BaseValues = Modules.Game_Values.BaseValues.Extractor
local ScoreEvents = Modules.Game_Values.ScoreEvents

local ObjectList = workspace:WaitForChild("Map").Interactables["Extractors"]
local ObjectModule = Modules["Extractor"]

local Interaction = Modules.Actions.Interactions["Extractor"]
local Interaction2 = Modules.Actions.Interactions["Accelerate"]
local InteractionCategory = "Interactions"
local InteractionName = "Install Parts"
local InteractionName2 = "Collect Serum"
local InteractionName3 = "Accelerate Extraction \n(Hold)"
local InteractionName4 = "Damage Extractor"

local lastKick = {}
local SkillChecks = {}

local function getObjectValues(Player, Object)

	local WSPlayer = Modules.Game:getWorkspacePlayer(Player.UserId)
	local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")

	local PlayerPosition = RootPart.CFrame.Position
	local ObjectPosition = Object.InteractionSpot.CFrame.Position
	local DistanceXZ = Modules.PlayerUtils:getVectorDistanceXZ(PlayerPosition, ObjectPosition)
	local DistanceY = Modules.PlayerUtils:getVectorDistanceY(PlayerPosition, ObjectPosition)
	
	local Cycles = Modules.Extractor:getCycles(Object)
	local Parts = Modules.Extractor:getParts(Object)
	local Progress = Modules.Extractor:getProgress(Object)
	local Fill_Speed = Modules.Extractor:getFillSpeed(Object)
	local PartsRequired = Modules.Extractor:getPartsRequired(Object)
	local PartsInstalled = Modules.Extractor:hasPartsInstalled(Object)
	
	local Damaged = Modules.Extractor:isDamaged(Object)
	local DamageTimeout = Modules.Extractor:getDamageTimeout(Object)
	local InstantRegression = Modules.Extractor:getInstantRregression(Object)
	
	local InteractionTime = ObjectModule:getInteractionTime(Object)
	local hasInteractor = ObjectModule:hasInteractor(Object)
	local Interactor = ObjectModule:getInteractor(Object)

	local Values = {
		["DistanceY"] = DistanceY,
		["DistanceXZ"] = DistanceXZ,
		["Interactor"] = Interactor,
		["hasInteractor"] = hasInteractor,
		["InteractionTime"] = InteractionTime,
		["Parts"] = Parts,
		["Cycles"] = Cycles,
		["Progress"] = Progress,
		["Fill_Speed"] = Fill_Speed,
		["PartsInstalled"] = PartsInstalled,
		["PartsRequired"] = PartsRequired,
		["Damaged"] = Damaged,
		["DamageTimeout"] = DamageTimeout,
		["InstantRegression"] = InstantRegression,
	}
	return Values

end

function validateInteractor(Object, ObjectValues, PlayerID)
	if (not isInRange(ObjectValues) and PlayerID == ObjectValues.Interactor) then
		releaseInteractor(ObjectValues.Interactor)
		assignInteractor(Object, 0)
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
	Modules.Game:stopIProgress(InteractorID)
end

function assignInteractor(Object, PlayerID)
	
	if (PlayerID ~= 0) then
		local Player = Players:GetPlayerByUserId(PlayerID)
		local MatchPlayer = Modules.Game:getMatchPlayer(PlayerID)
		Modules.Speed:addMultiplier(MatchPlayer, "Interaction", 0, 0)
		Modules.Actions:setAction(PlayerID, Modules.Actions.List.ACCELERATING)
		Modules.PlayerUtils:setPositionXZ(Player.Character.PrimaryPart, Object.InteractionSpot.CFrame.Position, .2)
	end
	
	ObjectModule:setInteractor(Object, PlayerID)
	ObjectModule:setInteractionTime(Object, 0)
end

function spawnPrompt(Object, ObjectValues, Player)
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local isHunter = Modules.Game:isHunter(Player.UserId)
	local Action = Modules.Actions:getAction(Player.UserId)
	local HasSerum = Modules.Game:HasSerum(MatchPlayer)
	local Parts = Modules.Game:getParts(MatchPlayer)
	
	if (isInRange(ObjectValues) and isHunter) then
		if (ObjectValues.PartsInstalled and ObjectValues.Progress > 0 and not ObjectValues.Damaged) then
			Modules.Game:spawnPrompt(Player.UserId, InteractionCategory, InteractionName4)
			Modules.Actions:setInteraction(Player.UserId, Interaction)
		end
	end
	
	if (isInRange(ObjectValues) and not isHunter) then
		if (ObjectValues.PartsInstalled) then
			if (ObjectValues.Progress >= 100 and not HasSerum) then
				Modules.Game:spawnPrompt(Player.UserId, InteractionCategory, InteractionName2)
				Modules.Actions:setInteraction(Player.UserId, Interaction)
			end
			
			if (ObjectValues.Progress < 100 and Action == 1 and not ObjectValues.hasInteractor and not ObjectValues.Damaged) then
				Modules.Game:spawnPrompt(Player.UserId, InteractionCategory, InteractionName3)
				Modules.Actions:setInteraction(Player.UserId, Interaction)
			end
			
		else
			if (Parts > 0) then
				Modules.Game:spawnPrompt(Player.UserId, InteractionCategory, InteractionName)
				Modules.Actions:setInteraction(Player.UserId, Interaction)
			end
		end
	end
end

function isInRange(ObjectValues)
	
	if (ObjectValues.DistanceXZ > ACTIVATION_DISTANCE) then
		return false
	end

	if (ObjectValues.DistanceY > ACTIVATION_DISTANCE * 3) then
		return false
	end

	return true
end

function updateUI(Object, ObjectValues)
	
	local UI = Object.UI
	
	if (not ObjectValues.PartsInstalled) then
		UI.Progress.Text = "Install Parts: " .. ObjectValues.Parts .. "/" .. ObjectValues.PartsRequired
	else
		if (ObjectValues.Progress >= 100) then
			UI.Progress.Text = "Extracted: 100%"
		else

			local displayValue = ObjectValues.Progress * 100
			displayValue = math.floor(displayValue)
			displayValue = displayValue / 100

			UI.Progress.Text = `Extracting {math.floor(displayValue)}%`
		end
	end
end

function updateProgress(Object, delta)
	
	local PartsInstalled = ObjectModule:hasPartsInstalled(Object)
	local hasInteractor = ObjectModule:hasInteractor(Object)
	local Fill_Speed = ObjectModule:getFillSpeed(Object)
	local isDamaged = ObjectModule:isDamaged(Object)
	local Progress = ObjectModule:getProgress(Object)
	local Interactor = ObjectModule:getInteractor(Object)
	
	local Multiplier = 1.0
	
	if (not PartsInstalled) then
		ObjectModule:setProgress(Object, 0)
		return
	end
	
	if (Progress >= 100 or isDamaged) then
		return
	end
	
	if (hasInteractor) then
		
		local MatchPlayer = Modules.Game:getMatchPlayer(Interactor)
		
		Modules.InteractionSpeed:addMultiplier(MatchPlayer, "Extractor", 0.5, 0)
		local InteractionSpeed = Modules.Game:getInteractionSpeed(MatchPlayer)
		
		Multiplier = InteractionSpeed
		
		Modules.Actions:setInteraction(Interactor, Interaction2)
		local random = math.random(1, 100)
		
		if (random < 10 and not Modules.Game:isHunter(Interactor)) then
			local id = Modules.SkillCheckManager:spawnSkillCheck(Players:GetPlayerByUserId(Interactor), 0.65, 10)
			
			if (id ~= nil) then
				SkillChecks[id] = {}
				SkillChecks[id] = function()
					FailSkillCheck(Object)
				end
			end
		end
	end
	
	Progress += (Fill_Speed * (delta * Multiplier))
	ObjectModule:setProgress(Object, Progress)
	
	if (Progress >= 100) then
		Modules.AuraManager:createAlert(Modules.Game:getHunter(), "Extractors", Object.Name)
		if (hasInteractor) then
			releaseInteractor(Interactor)
			assignInteractor(Object, 0)
		end
	end
	
end

function updateCollecting(Object, ObjectValues, PlayerID, delta)
	
	local Interactor = tonumber(ObjectValues.Interactor)
	local MatchPlayer = Modules.Game:getMatchPlayer(Interactor)
	local hasSerum = Modules.Game:HasSerum(MatchPlayer)
	local isHunter = Modules.Game:isHunter(PlayerID)
	
	if (not ObjectValues.PartsInstalled or ObjectValues.Progress < 100 or ObjectValues.Interactor == 0 or ObjectValues.Interactor ~= PlayerID or isHunter) then
		return
	end
	
	if (hasSerum) then
		releaseInteractor(Interactor)
		assignInteractor(Object, 0)
		Modules.Game:stopIProgress(Interactor)
		return
	end
	
	if (ObjectValues.Progress >= 100 and ObjectValues.hasInteractor) then
		ObjectModule:setInteractionTime(Object, ObjectValues.InteractionTime + delta)
		Modules.Game:setIProgress(ObjectValues.Interactor, "Collecting", ObjectValues.InteractionTime, INTERACTION_TIME)
		
		if (ObjectValues.InteractionTime >= INTERACTION_TIME) then

			Modules.Credits:increaseCredits(Interactor, (Modules.Game_Values.ScoreEvents.Prey.SerumExtracted))
			Modules.Game:setSerum(MatchPlayer, true)
			Modules.Game:stopIProgress(Interactor)
			ObjectModule:setProgress(Object, 0)
			releaseInteractor(PlayerID)
			assignInteractor(Object, 0)
		end
	else
		ObjectModule:setInteractionTime(Object, 0)
	end
end

function onServerTick(delta)
	
	if (not Modules.Game:isRunning()) then
		return
	end
	
	for count = 1, (#ObjectList:GetChildren() - 1) do

		local Object = ObjectList[count]
		updateProgress(Object, delta)
		
		for i, Player in ipairs(Players:GetPlayers()) do
			if (Object:isA("Part")) then
				local ObjectValues = getObjectValues(Player, Object)
				
				if (ObjectValues ~= nil) then
					
					updateUI(Object, ObjectValues)
					
					if (ObjectValues.hasInteractor) then
						validateInteractor(Object, ObjectValues, Player.UserId)
						updateCollecting(Object, ObjectValues, Player.UserId, delta)
						
						local Interactor = game.Players:GetPlayerByUserId(ObjectValues.Interactor)
						Modules.PlayerUtils:setRotation(Interactor.Character.PrimaryPart, Object.Position, .2)
					else
						spawnPrompt(Object, ObjectValues, Player)
					end
				end
			end	
		end
	end
end

function onInputClick(Player, Key, Down)
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local isHunter = Modules.Game:isHunter(Player.UserId)
	
	if (not Modules.Game:isRunning()) then
		return
	end
	
	local Binds = Modules.BindStorage:get(Player.UserId)
	local Interactions = {Binds.Controller[InteractionCategory], Binds.Keyboard[InteractionCategory]}

	if (table.find(Interactions, Key.Value)) then
		for count = 1, (#ObjectList:GetChildren() - 1) do

			local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
			local PlayerInteraction = Modules.Actions:getInteraction(Player.UserId)
			local HasSerum = Modules.Game:HasSerum(MatchPlayer)
			local PlayerParts = Modules.Game:getParts(MatchPlayer)

			local Object = ObjectList[count]
			local ObjectValues = getObjectValues(Player, Object)

			if (ObjectValues ~= nil) then
				if (Down) then
					if (isInRange(ObjectValues) and PlayerInteraction == Interaction) then
						if (not ObjectValues.hasInteractor) then
							
							if (isHunter) then
								if (ObjectValues.PartsInstalled and ObjectValues.Progress > 0) then
									assignInteractor(Object, Player.UserId)
									DamageExtractor(Object, ObjectValues, MatchPlayer)
								end
							end
							
							if (not ObjectValues.PartsInstalled) then
								
								if (PlayerParts <= 0) then
									return
								end
								
								ObjectModule:setProgress(Object, 0)
								assignInteractor(Object, Player.UserId)
								Modules.Game:setExtractorId(MatchPlayer, count)
								Modules.Remotes.InstallationStart:FireClient(Player, count, "Start")
								return
							end
							assignInteractor(Object, Player.UserId)
						end

						if (ObjectValues.PartsInstalled and ObjectValues.Progress >= 100 and not HasSerum and not ObjectValues.hasInteractor) then
							assignInteractor(Object, Player.UserId)
						end
					end
				else
					if (ObjectValues.Interactor == Player.UserId and ObjectValues.PartsInstalled and not isHunter) then
						Modules.Game:stopIProgress(Player.UserId)
						releaseInteractor(Player.UserId)
						assignInteractor(Object, 0)
					end
				end
			end
		end
	end
	
end

function onMobileInput(Player, Action, Down)
	
	local isHunter = Modules.Game:isHunter(Player.UserId)

	if (not Modules.Game:isRunning()) then
		return
	end
	
	for count = 1, (#ObjectList:GetChildren() - 1) do

		local WSPlayer = Modules.Game:getWorkspacePlayer(Player.UserId)
		local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
			
		local PlayerInteraction = Modules.Actions:getInteraction(Player.UserId)
		local RootPart = WSPlayer:WaitForChild("HumanoidRootPart")
			
		local HasSerum = Modules.Game:HasSerum(MatchPlayer)
		local PlayerParts = Modules.Game:getParts(MatchPlayer)

		local Object = ObjectList[count]
		local ObjectValues = getObjectValues(Player, Object)

		if (ObjectValues ~= nil) then
			
			if (not Down) then
				return
			end
			
			if (isInRange(ObjectValues) and PlayerInteraction == Interaction) then
				
				if (not ObjectValues.hasInteractor) then

					if (isHunter) then
						if (ObjectValues.PartsInstalled and ObjectValues.Progress > 0) then
							assignInteractor(Object, Player.UserId)
							DamageExtractor(Object, ObjectValues, MatchPlayer)
						end
					end

					if (not ObjectValues.PartsInstalled) then

						if (PlayerParts <= 0) then
							return
						end

						ObjectModule:setProgress(Object, 0)
						assignInteractor(Object, Player.UserId)
						Modules.Game:setExtractorId(MatchPlayer, count)
						Modules.Remotes.InstallationStart:FireClient(Player, count, "Start")
						return
					end
					assignInteractor(Object, Player.UserId)
				end

				if (ObjectValues.PartsInstalled and ObjectValues.Progress >= 100 and not HasSerum and not ObjectValues.hasInteractor) then
					assignInteractor(Object, Player.UserId)
				end
			else
				if (PlayerInteraction == Interaction2) then
					if (ObjectValues.Interactor == Player.UserId and ObjectValues.PartsInstalled and not isHunter) then
						Modules.Game:stopIProgress(Player.UserId)
						releaseInteractor(Player.UserId)
						assignInteractor(Object, 0)
					end
				end
			end
		end
	end
end

function DamageExtractor(Object, ObjectValues, MatchPlayer)
	
	if (lastKick[Object.Name] ~= nil) then
		if (tick() - lastKick[Object.Name] < 5) then
			return
		end
	end
	
	lastKick[Object.Name] = tick()
	
	assignInteractor(Object, MatchPlayer:GetAttribute("ID"))
	Modules.Game:setAnimationAction(MatchPlayer, "Destroy")
	
	local timer = 1.5
	local Runner
	
	Runner = RunService.Heartbeat:Connect(function(delta)
		timer -= delta
		
		if (timer <= 0) then
			
			releaseInteractor(MatchPlayer:GetAttribute("ID"))
			Modules.Game:setAnimationAction(MatchPlayer, "Run")
			ObjectModule:setProgress(Object, math.clamp(ObjectValues.Progress - BaseValues.Instant_Regression, 0, 100))
			ObjectModule:setPartsInstalled(Object, false)
			ObjectModule:setParts(Object, 2)
			
			Runner:Disconnect()
			Runner = nil
		end
		
	end)
	
end

function FailSkillCheck(Object)
	local Progress = ObjectModule:getProgress(Object)
	
	if (Progress < 100) then
		Progress = math.clamp(Progress - 10, 0, 100)
	
		ObjectModule:setProgress(Object, Progress)
		ObjectModule:setDamaged(Object, true)
		task.wait(2)
		ObjectModule:setDamaged(Object, false)
	end
end

function onSkillCheckReceive(Player, Result, ID)
	if (SkillChecks[ID] == nil or Result == true) then
		return
	end
	
	SkillChecks[ID]()
	SkillChecks[ID] = nil
	
end

function onCycleComplete(Player, ExtractorID, Correct, GUID)

	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local Object = ObjectList[ExtractorID]
	local ObjectValues = getObjectValues(Player, Object)
	local PlayerParts = Modules.Game:getParts(MatchPlayer)
	
	if (not Correct and Player.UserId == ObjectValues.Interactor) then
		local Hunter = Modules.Game:getHunterID()
		local HunterPlayer = Players:GetPlayerByUserId(Hunter)
		local HunterDistance = Modules.Game:getHunterDistance(MatchPlayer)

		if (HunterDistance > 30) then
			Modules.AuraManager:createAlert(HunterPlayer, "Extractors", ExtractorID)
		end
		
		if (PlayerParts < 1) then
			Modules.Remotes.InstallationStart:FireClient(Player, ExtractorID, "Stop")
			ObjectModule:setCycles(Object, 0)
			releaseInteractor(Player.UserId)
			assignInteractor(Object, 0)
			return
		end
		
		PlayerParts -= 1
		Modules.Game:setParts(MatchPlayer, PlayerParts)
		return
	end

	if (PlayerParts < 1) then
		Modules.Remotes.InstallationStart:FireClient(Player, ExtractorID, "Stop")
		releaseInteractor(Player.UserId)
		assignInteractor(Object, 0)
		return
	end

	if (ObjectValues ~= nil) then
		if ((ObjectValues.Cycles + 1) >= BaseValues.BaseCycles) then
			Modules.Game:setParts(MatchPlayer, PlayerParts - 1)
			ObjectModule:setParts(Object, ObjectValues.Parts + 1)
			ObjectModule:setCycles(Object, 0)
			
			local released = false
			
			if (PlayerParts - 1 <= 0) then
				Modules.Remotes.InstallationStart:FireClient(Player, ExtractorID, "Stop")
				releaseInteractor(Player.UserId)
				assignInteractor(Object, 0)
				released = true
			end
			
			if ((ObjectValues.Parts + 1) >= BaseValues.PartsRequired) then
				Modules.Credits:increaseCredits(Player.UserId, (ScoreEvents.Prey.ExtractorRepaired))
				Modules.Remotes.InstallationStart:FireClient(Player, ExtractorID, "Stop")
				Modules.Game:setExtractorId(MatchPlayer, -1)
				
				ObjectModule:setPartsInstalled(Object, true)
				
				if (not released) then
					releaseInteractor(Player.UserId)
					assignInteractor(Object, 0)
				end
			end
		else
			ObjectModule:setCycles(Object, ObjectValues.Cycles + 1)
		end
	end
end

function onAbort(Player, ExtractorID)
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local Object = ObjectList[ExtractorID]

	ObjectModule:setCycles(Object, 0)
	releaseInteractor(Player.UserId)
	assignInteractor(Object, 0)

end

Modules.Remotes.SkillCheckEvent.OnServerEvent:Connect(onSkillCheckReceive)
Modules.Remotes.CycleComplete.OnServerEvent:Connect(onCycleComplete)
Modules.Remotes.AbortInstallation.OnServerEvent:Connect(onAbort)
Modules.Events.Game.ServerTick.Event:Connect(onServerTick)
Modules.Events.onMobileInput.Event:Connect(onMobileInput)
Modules.Events.onInputClick.Event:Connect(onInputClick)

