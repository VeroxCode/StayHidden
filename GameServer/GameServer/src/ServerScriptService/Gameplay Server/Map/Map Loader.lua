local Terrain = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Map"):WaitForChild("TerrainSaveLoad"))
local GameValues = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Utils"):WaitForChild("Game Values"))
local Utils = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Utils"):WaitForChild("Player Utils"))

local DefaultTables = {
	BigDoor = {
		Opened = true,
		Powered = true,
		Interactor = 0,
		Tweening = false,
		CloseTime = GameValues.BaseValues.BigDoor.CloseTime,
		Timer = GameValues.BaseValues.BigDoor.CloseTime,
	},
	Collector = {
		Progress = 0,
		Maximum = GameValues.BaseValues.Collector.Maximum,
		Filled = false,
		Interactor = 0,
		InteractionTime = 0,
	},
	Curtain = {
		Active = false,
		Progress = 0,
		Interactor = 0,
		Installtime = GameValues.BaseValues.Curtain.Installtime,
		Stuntime = GameValues.BaseValues.Curtain.Stuntime,
	},
	Extractor = {
		Parts = 0,
		PartsInstalled = false,
		PartsRequired = GameValues.BaseValues.Extractor.PartsRequired,
		Cycles = 0,
		Progress = 0,
		Fill_Speed = GameValues.BaseValues.Extractor.Fill_Speed,
		InstantRegression = GameValues.BaseValues.Extractor.Instant_Regression,
		DamageTimeout = GameValues.BaseValues.Extractor.Damage_Timeout,
		Damaged = false,
		Interactor = 0,
		InteractionTime = 0,
	},
	Exit = {
		OpeningTime = GameValues.BaseValues.Exit.Opening_Time,
		Used = false,
		Interactor = 0,
		InteractionTime = 0,
	},
	Fusebox = {
		ActivationTime = GameValues.BaseValues.Fusebox.RepairTime,
		DeactivationTime = GameValues.BaseValues.Fusebox.DestroyTime,
		Activated = true,
		Interactor = 0,
		InteractionTime = 0,
		Loads = 0,
		Overload = GameValues.BaseValues.Fusebox.Overload,
		Refill = 8.5,
	},
	Gap = {
		Player = "Empty",
	},
	Grave = {
		Player = "",
		RespawnSpeed = GameValues.BaseValues.Grave.Respawn_Speed,
		PrayBonus = GameValues.BaseValues.Grave.PrayBonus,
		Interactor = 0,
		SpawnTime = 0,
	},
	JunkPile = {
		Looted = false,
		Interactor = 0,
		InteractionTime = 0,
	},
	PartChest = {
		Amount = GameValues.BaseValues.PartChest.Amount,
		Looted = false,
		Interactor = 0,
		InteractionTime = 0,
		Timer = 0,
		Refill = GameValues.BaseValues.PartChest.RefillTime,
	},
}

local this = {}

function this:load(Map: Folder)
	
	if (Map.hasTerrain.Value) then
		Terrain:Load(Map.Terrain)
	end
	
	Map.Name = "Map"
	Map.Parent = workspace
	
end

function this:setTiles(Map)
	
	if (Map:FindFirstChild("Tiles") == nil) then
		
		renameInteractables()
		attachFuseboxes()
		this:setupInteractables()
		
		return
	end
	
	local Tiles = Map.Tiles
	local TilePrebuilt = Map.TilePrebuilt
	
	for i, Tile : Part in pairs(Tiles:GetChildren()) do
		local randomizer = {}
		
		for key, value in pairs(Tile:GetAttributes()) do
			if (value) then
				table.insert(randomizer, key)
			end
		end
		
		local randomNumber = math.random(1, #randomizer)
		local TileName = tostring(randomizer[randomNumber])
		local chosenTile : Model = TilePrebuilt[TileName]:Clone()
		
		print(`chosen: {TileName}`)
		
		local TilePosition = Tile.CFrame.Position
		local Rotation = math.random(1, 4) * 45
		
		if (TileName == "1") then
			Rotation = 0
		end
		
		chosenTile.Parent = workspace
		chosenTile:PivotTo(CFrame.new(TilePosition.X, Map.TileHeight.Value, TilePosition.Z) * CFrame.Angles(0, math.rad(Rotation), 0))
		
		unpackTile(Map, chosenTile)
		Tile:Destroy()
		
	end
	
	Tiles:Destroy()
	TilePrebuilt:Destroy()
	
	limitInteractables() --TODO: Extractors need to consider collectors or the other way around
	
	renameInteractables()
	attachFuseboxes()
	this:setupInteractables()
	
end

function unpackTile(Map, Tile)
	
	for i, child in pairs(Tile:GetChildren()) do
		if (not child:isA("Folder")) then continue end
		
		for i2, object in pairs(child:GetChildren()) do
			if (child.Name == "MapObjects") then
				object.Parent = Map.MapObjects
			else
				local objectName = tostring(#Map.Interactables[child.Name]:GetChildren() + 1)
				object.Name = objectName
				object.Parent = Map.Interactables[child.Name]
			end
		end
	end
	
	Tile:Destroy()
	
end

function limitInteractables()
	
	local Map = workspace.Map
	local Limits = Map.Limits
	local Distances = Map.Distances
	local Interactables = Map.Interactables
	
	for i, folder in pairs(Interactables:GetChildren()) do
		local approved = {}

		for i, v in pairs(folder:GetChildren()) do
			print(folder.Name)
			local extra = if (folder.Name == "Collectors") then farFromApproved(v, Interactables.Extractors:GetChildren(),  100) else true
			
			if (#approved < 1 and extra) then
				table.insert(approved, v)
			else
				local approve = farFromApproved(v, approved,  Distances:GetAttribute(folder.Name)) and (#approved < Limits:GetAttribute(folder.Name))
				
				if (approve and extra) then
					table.insert(approved, v)
				else
					if (folder.Name == "Gaps") then
						moveDisabledGap(v)
					else
						v:Destroy()
					end
				end
			end
		end
	end
	
end

function moveDisabledGap(Gap)
	
	Gap.Blockade.Transparency = 0
	Gap.Blockade.Color = Color3.new(0, 0, 0)
	Gap.Parent = workspace.Map.MapObjects
	
end

function farFromApproved(Object, Approved, MinDistance)
	
	for i, v in pairs(Approved) do
		
		local PosApp = if (v:isA("Model")) then v.PrimaryPart.CFrame.Position else v.CFrame.Position
		local PosObj = if (Object:isA("Model")) then Object.PrimaryPart.CFrame.Position else Object.CFrame.Position
		local Dist = (PosApp - PosObj).Magnitude
		
		if (Dist < MinDistance) then
			return false
		end
	end
	return true
end

function renameInteractables()
	
	local Map = workspace.Map
	
	for index, folder in pairs(Map.Interactables:GetChildren()) do
		local count = 0
		for i, obj in pairs(folder:GetChildren()) do
			if (obj:isA("Script")) then continue end
			
			obj.Name = `{tostring(count + 1)}`
			count += 1
			
		end
	end
	
end

function attachFuseboxes()
	
	local Map = workspace.Map
	local Fuseboxes = Map.Interactables.Fuseboxes
	
	for i, v in pairs(Map.Interactables.BigDoors:GetChildren()) do
		
		local target = nil
		local closest = 10000
		
		for i2, v2 in pairs(Fuseboxes:GetChildren()) do
			
			local Pos = if (v2:isA("Model")) then v2.PrimaryPart.CFrame.Position else v2.CFrame.Position
			
			local dist = Utils:getVectorDistanceXZ(v.CFrame.Position, Pos)
			
			if (dist < closest) then
				target = v2
				closest = dist
			end
		end
		v:SetAttribute("Fusebox", target.Name)
	end
	
	for i, v in pairs(Map.Interactables.Gaps:GetChildren()) do

		local target = nil
		local closest = 10000

		for i2, v2 in pairs(Fuseboxes:GetChildren()) do
			
			local Pos = if (v2:isA("Model")) then v2.PrimaryPart.CFrame.Position else v2.CFrame.Position
			
			local dist = Utils:getVectorDistanceXZ(v.CFrame.Position, Pos)

			if (dist < closest) then
				target = v2
				closest = dist
			end
		end
		v:SetAttribute("Fusebox", target.Name)
	end
	
end

function this:setupInteractables()
	
	local Extractors = workspace.Map.Interactables.Extractors
	local Collectors = workspace.Map.Interactables.Collectors
	local PartChests = workspace.Map.Interactables.PartChests
	local Fuseboxes = workspace.Map.Interactables.Fuseboxes
	local JunkPiles = workspace.Map.Interactables.JunkPiles
	local BigDoors = workspace.Map.Interactables.BigDoors
	local Curtains = workspace.Map.Interactables.Curtains
	local Graves = workspace.Map.Interactables.Graves
	local Exits = workspace.Map.Interactables.Exits
	local Gaps = workspace.Map.Interactables.Gaps
	local CloneRepo = game.ServerStorage.Cloning
	
	local FuseboxClone = CloneRepo:WaitForChild("Fusebox"):Clone()
	FuseboxClone.Parent = Fuseboxes
	FuseboxClone.Enabled = true
	
	local BigDoorClone = CloneRepo:WaitForChild("BigDoor"):Clone()
	BigDoorClone.Parent = BigDoors
	BigDoorClone.Enabled = true
	
	local ExitClone = CloneRepo:WaitForChild("Exit"):Clone()
	ExitClone.Parent = Exits
	ExitClone.Enabled = true
	
	local ExtractorClone = CloneRepo:WaitForChild("Extractor"):Clone()
	ExtractorClone.Parent = Extractors
	ExtractorClone.Enabled = true
	
	local CollectorClone = CloneRepo:WaitForChild("Collector"):Clone()
	CollectorClone.Parent = Collectors
	CollectorClone.Enabled = true
	
	local PartChestClone = CloneRepo:WaitForChild("PartChest"):Clone()
	PartChestClone.Parent = PartChests
	PartChestClone.Enabled = true
	
	local GraveClone = CloneRepo:WaitForChild("Grave"):Clone()
	GraveClone.Parent = Graves
	GraveClone.Enabled = true
	
	local GapClone = CloneRepo:WaitForChild("Gap"):Clone()
	GapClone.Parent = Gaps
	GapClone.Enabled = true
	
	local JunkClone = CloneRepo:WaitForChild("JunkPile"):Clone()
	JunkClone.Parent = JunkPiles
	JunkClone.Enabled = true
	
	local CurtainClone = CloneRepo:WaitForChild("Curtain"):Clone()
	CurtainClone.Parent = Curtains
	CurtainClone.Enabled = true
	
	for i, interactable in pairs(JunkPiles:GetChildren()) do	
		for key, value in pairs(DefaultTables.JunkPile) do
			interactable:SetAttribute(key, value)
		end
	end
	
	for i, interactable in pairs(Fuseboxes:GetChildren()) do	
		for key, value in pairs(DefaultTables.Fusebox) do
			interactable:SetAttribute(key, value)
		end
	end
	
	for i, interactable in pairs(BigDoors:GetChildren()) do	
		for key, value in pairs(DefaultTables.BigDoor) do
			interactable:SetAttribute(key, value)
		end
	end
	
	for i, interactable in pairs(Extractors:GetChildren()) do	
		for key, value in pairs(DefaultTables.Extractor) do
			interactable:SetAttribute(key, value)
		end
	end
		
	for i, interactable in pairs(Collectors:GetChildren()) do
		for key, value in pairs(DefaultTables.Collector) do
			interactable:SetAttribute(key, value)
		end
	end
	
	for i, interactable in pairs(Graves:GetChildren()) do
		for key, value in pairs(DefaultTables.Grave) do
			interactable:SetAttribute(key, value)
		end
	end
	
	for i, interactable in pairs(PartChests:GetChildren()) do
		for key, value in pairs(DefaultTables.PartChest) do
			interactable:SetAttribute(key, value)
		end
	end
	
	for i, interactable in pairs(Curtains:GetChildren()) do
		for key, value in pairs(DefaultTables.Curtain) do
			interactable:SetAttribute(key, value)
		end
	end
	
	for i, interactable in pairs(Gaps:GetChildren()) do
		for key, value in pairs(DefaultTables.Gap) do
			interactable:SetAttribute(key, value)
		end
	end
	
	for i, interactable in pairs(Exits:GetChildren()) do
		for key, value in pairs(DefaultTables.Exit) do
			interactable:SetAttribute(key, value)
		end
	end
	
end

return this
