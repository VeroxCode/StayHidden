local InteractionSpeed = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Player"):WaitForChild("InteractionSpeed"))
local Game_Functions = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Utils"):WaitForChild("Game Functions"))
local ActionSpeed = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Player"):WaitForChild("ActionSpeed"))
local SpawnLogic = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Setup"):WaitForChild("Spawn Logic"))
local GameValues = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Utils"):WaitForChild("Game Values"))
local MapLoader = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Map"):WaitForChild("Map Loader"))
local Actions = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Player"):WaitForChild("Actions"))
local Speed = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Player"):WaitForChild("Speed"))
local SaveStorage = require(game.ServerScriptService["Handlers"]:WaitForChild("Save Storage"))
local AssignCamera = game.ReplicatedStorage.Remotes:WaitForChild("AssignCamera")

local Players = game:GetService("Players")
local Events = game.ServerStorage.Events

local Assets = game.ReplicatedStorage.Assets
local Models = Assets.Models

local this = {}

this.DefaultAttributes = {
	Prey = {
		ID = 0,
		Role = "Prey",
		Action = Actions.List.IDLE,
		Escaped = false,
		isSprinting = false,
		isVulnerable = true,
		isCrouching = false,
		hasSerum = false,
		inChase = false,
		ChaseTimer = 0,
		Interaction = 0,
		InteractionTimer = 0,
		lastAttack = os.time(),
		AnimationAction = "Walk",
		HunterDistance = 1000,
		Movement = CFrame.new(),
		Item = "",
		Credits = 0,
		Parts = 0,
		Extractor = -1,
		Character = "",
		
		Values = {
			Health = 100,
			MaxHealth = 100,
			Battery = 100,
			MaxBattery = 100,
			BatteryDrain = 2,
			Speed = 0,
			SpeedMultiplier = 0,
			SlideTime = 0.75,
			HurtBoost = 3,
			ActionSpeed = 1.0,
			InteractionSpeed = 1.0,
		},
		
		Effects = {
			Slowdown = {
				Active = false,
				Duration = 20,
				Timer = 0,
				Value = 0
			},
			Swiftness = {
				Active = false,
				Duration = 20,
				Timer = 0,
				Value = 0
			},
			Vulnerable = {
				Active = false,
				Duration = 20,
				Timer = 0,
			},
			Protection = {
				Active = false,
				Duration = 20,
				Timer = 0,
			},
			Paralyzed = {
				Active = false,
				Duration = 20,
				Timer = 0,
			},
			FreshWound = {
				Active = false,
				Duration = 25,
				Timer = 0,
			},
		},
		
		Ability = {
			MaxCooldown = 0,
			Cooldown = 0,
			Amount = 0
		},
		
		Progress = {
			Maximum = 100,
			Current = 0,
			Action = "ABORT",
			lastUpdate = 0
		},
		
		Prompt = {
			Keys = "KEY|KEY",
			Action = "ABORT",
			lastUpdate = 0
		},
		
		Sound = {
			Track = "Proximity",
			Volume = 0,
		},
		
		Notification = {
			Text = "",
			lastUpdate = 0
		},
		
		Perks = {
			Slot1 = {
				Name = "",
				Duration = 0,
				Cooldown = 0,
				MaxDuration = 0,
				MaxCooldown = 0,
			},
			Slot2 = {
				Name = "",
				Duration = 0,
				Cooldown = 0,
				MaxDuration = 0,
				MaxCooldown = 0,
			},
			Slot3 = {
				Name = "",
				Duration = 0,
				Cooldown = 0,
				MaxDuration = 0,
				MaxCooldown = 0,
			}
		},
		
	},
	Hunter = {
		ID = 0,
		Role = "Hunter",
		Action = Actions.List.IDLE,
		Interaction = 0,
		InteractionTimer = 0,
		inChase = false,
		ChaseTimer = 0,
		AnimationAction = "Run",
		AttackKey = "Empty",
		Movement = CFrame.new(),
		Credits = 0,
		Character = "",
		
		Values = {
			Speed = 0,
			SpeedMultiplier = 0,
			RecoveryTime = 2.5,
			FailRecoveryTime = 2,
			Damage = 35,
			ProximityRadius = 150,
		},
		
		Effects = {
			Swiftness = {
				Duration = 20,
				Timer = 0,
				Value = 0
			},
			Paralyzed = {
				Active = false,
				Duration = 20,
				Timer = 0,
			},
			Slowdown = {
				Active = false,
				Duration = 20,
				Timer = 0,
				Value = 0
			},
		},
		
		Ability = {
			MaxCooldown = 0,
			Cooldown = 0,
			Amount = 0,
			TrackingMaxCooldown = 0,
			TrackingCooldown = 0,
		},
		
		Progress = {
			Maximum = 100,
			Current = 0,
			Action = "ABORT",
			lastUpdate = os.time()
		},

		Prompt = {
			Keys = "0|0",
			Action = "ABORT",
			lastUpdate = os.time()
		},
		
		Sound = {
			Track = "Proximity",
			Volume = 0,
		},

		Notification = {
			Text = "",
			lastUpdate = os.time()
		},
		
		Perks = {
			Slot1 = {
				Name = "",
				Duration = 0,
				Cooldown = 0,
				MaxDuration = 0,
				MaxCooldown = 0,
			},
			Slot2 = {
				Name = "",
				Duration = 0,
				Cooldown = 0,
				MaxDuration = 0,
				MaxCooldown = 0,
			},
			Slot3 = {
				Name = "",
				Duration = 0,
				Cooldown = 0,
				MaxDuration = 0,
				MaxCooldown = 0,
			}
		},
		
	}
}

local DebugTable = {
	inDebug = workspace:GetAttribute("Debug"),
	Players = workspace:GetAttribute("DebugPlayers"),
	needHunter = workspace:GetAttribute("DebugNeedHunter")
}

function this:createPlayer(Player, Hunter)
	
	local PlayerFolder = Instance.new("Folder")
	PlayerFolder.Name = Player.Name
	PlayerFolder.Parent = game.ReplicatedStorage.Match.Players

	local ServerPlayer = Instance.new("Folder")
	ServerPlayer.Name = Player.Name
	ServerPlayer.Parent = game.ServerScriptService.Match.Players

	local Role = if (Hunter) then "Hunter" else "Prey"
	
	createAttributes(Player, this.DefaultAttributes[Role], PlayerFolder, ServerPlayer)
	
	InteractionSpeed:addToList(Player.Name)
	ActionSpeed:addToList(Player.Name)
	Speed:addToList(Player.Name)
	
	PlayerFolder:SetAttribute("ID", Player.UserId)
	ServerPlayer:SetAttribute("ID", Player.UserId)
	
end

function createAttributes(Player, Default, PlayerFolder, ServerFolder)
	
	for key, value in pairs(Default) do
		if (typeof(value) == "table") then
			local PlayerConfig = Instance.new("Configuration")
			PlayerConfig.Name = key
			PlayerConfig.Parent = PlayerFolder
			
			local ServerConfig = PlayerConfig:Clone()
			ServerConfig.Parent = ServerFolder
			
			createAttributes(Player, Default[key], PlayerConfig, ServerConfig)
		else
			PlayerFolder:SetAttribute(key, value)
			ServerFolder:SetAttribute(key, value)
		end
	end
	
end

function this:attachWeapon()
	
	if (DebugTable.inDebug and not DebugTable.needHunter) then
		return
	end
	
	local Hunter = Game_Functions:getHunter()
	local HunterID = Hunter:GetAttribute("ID")
	local Player = workspace:WaitForChild(Players:GetPlayerByUserId(HunterID).Name) 
	
	local SaveState = SaveStorage:get(HunterID)
	local Selected = SaveState.Hunter.Selected

	local Weapons = Models.Hunter:WaitForChild(Selected .. "_Weapon")
	local WeaponClone = Weapons:WaitForChild("Default"):Clone()
	WeaponClone.Name = "Weapon"
	WeaponClone.Parent = Player.RightHand
	
	local WeaponOffsetY = 0
	local weld = Instance.new("Weld")
	weld.Part0 = Player.RightHand
	weld.Part1 = WeaponClone.PrimaryPart
	weld.Parent = WeaponClone
	weld.C1 = CFrame.new(Vector3.new(0, -WeaponOffsetY, 0), Vector3.new(20, 90, 0))
	
end

function this:assignPower()
	
	for i, p in pairs(game.Players:GetPlayers()) do
		local ServerPlayers = game.ServerScriptService.Match.Players
		local MatchPlayer = Game_Functions:getMatchPlayer(p.UserId)
		local Role = Game_Functions:getRole(MatchPlayer)

		local SaveState = SaveStorage:get(p.UserId)
		local Selected = SaveState[Role].Selected

		local PowerRepo = game.ServerStorage.Cloning.Powers[Role]
		local Power = PowerRepo[Selected]:Clone()
		Power.Name = "Power"
		Power.Parent = ServerPlayers:WaitForChild(p.Name)
		
		game.ReplicatedStorage.Remotes.PowerUpdate:FireClient(p, "Icon", Selected)
		local MainModule = require(Power.Loader.Main)
		MatchPlayer:SetAttribute("Character", Selected)
		MainModule:initialize()
	end
end

function this:assignPerks()

	for i, p in pairs(game.Players:GetPlayers()) do
		local ServerPlayers = game.ServerScriptService.Match.Players
		local MatchPlayer = Game_Functions:getMatchPlayer(p.UserId)
		local Role = Game_Functions:getRole(MatchPlayer)

		local SaveState = SaveStorage:get(p.UserId)
		local Selected = SaveState[Role].Selected
		local Perks = SaveState[Role][Selected].LoadOut.Perks
		
		for slot, perk in pairs(Perks) do
			if (perk == "") then continue end
			
			local Slot = string.gsub(slot, "Slot", "")
			
			local PerkRepo = game.ServerStorage.Perks[Role]
			local Perk = PerkRepo[perk]:Clone()
			Perk.Parent = ServerPlayers:WaitForChild(p.Name)
			Perk.Config:SetAttribute("Slot", tonumber(Slot))
			Perk.Enabled = true
			
			MatchPlayer.Perks["Slot" .. tonumber(Slot)]:SetAttribute("Name", Perk.Name)
		end
		
		game.ReplicatedStorage.Remotes.PowerUpdate:FireClient(p, "Perks", Perks)
		
	end
end

function this:assignHunterSpecifics()
	
	if (DebugTable.inDebug and not DebugTable.needHunter) then
		return
	end
	
	local Hunter = Game_Functions:getHunter()
	local HunterID = Game_Functions:getHunterID()
	local SaveState = SaveStorage:get(HunterID)
	
	repeat task.wait(.1)
		SaveState = SaveStorage:get(HunterID)
	until SaveState ~= nil
	
	local Selected = SaveState["Hunter"].Selected
	local Characters = game.ServerStorage.Modifiers["Hunter"]
	local CharacterStats = Characters[Selected]
	
	Game_Functions:setChaseTheme(Selected)
	print(CharacterStats:GetAttribute("ProximityRadius"))
	Game_Functions:setProximityRadius(Hunter, CharacterStats:GetAttribute("ProximityRadius"))
	Game_Functions:setDamage(Hunter, CharacterStats:GetAttribute("Damage"))
	Speed:setDefault(CharacterStats:GetAttribute("MovementSpeed"))
	
end

function this:chooseMap()
	
	local MatchStats = Game_Functions:getMatchStats()
	local random = math.random(1, #GameValues.MapPool)
	
	MatchStats:SetAttribute("Map", GameValues.MapPool[random].Name)
	return GameValues.MapPool[random]
	
end

function this:spawnMap()
	
	task.wait(5)
	
	local chosenMap = this:chooseMap()
	MapLoader:load(chosenMap)
	MapLoader:setTiles(chosenMap)
	this:attachWeapon()
	SpawnLogic:spawnPlayers()
	
	task.wait(2)
	
	
	this:assignPower()
	this:assignPerks()
	this:assignHunterSpecifics()
	SpawnLogic:startCountdown()
	
	Events.Game.MatchStart:Fire()
	
end

return this
