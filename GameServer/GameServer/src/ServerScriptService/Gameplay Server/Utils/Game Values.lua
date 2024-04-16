local Maps = game.ServerStorage.Maps

local this = {}

this.MapPool = {
	--Maps["Cataclysmic Blizzard"],
	Maps["Debug"],
	--Maps["PlayTest"],
	--Maps["PlayTest_2"]
}

this.ScoreEvents = {
	
	Hunter = {
		["PreyAttacked"] = 150,
		["FuseboxDeactivated"] = 250,
		["PreyKilled"] = 800,
		["AllPreyKilled"] = 2000,
	},
	Prey = {
		["ChestScavenged"] = 350,
		["SerumExtracted"] = 850,
		["ExtractorRepaired"] = 1200,
		["Survived"] = 2000,
	},
	Generic = {
		["ChaseTime"] = 10,
		["MatchTime"] = 1,
	},
	Specific = {
		["TrapSet"] = 150,
		["TrapTripped"] = 15,
		["PreyHealed"] = 150,
	},
}

this.BaseValues = {
	BigDoor = {
		CloseTime = 3.5,
	},
	Curtain = {
		Stuntime = 2,
		Installtime = 8,
	},
	Extractor = {
		BaseCycles = 5,
		PartsRequired = 3,
		Fill_Speed = 2.5,
		Instant_Regression = 12.5,
		Damage_Timeout = 15,
	},
	Exit = {
		Opening_Time = 5,
	},
	Collector = {
		Maximum = 5,
		InteractionTime = 20
	},
	PartChest = {
		Amount = 2,
		InteractionTime = 8.0,
		RefillTime = 60
	},
	Grave = {
		Respawn_Time = 24.0,
		Respawn_Speed = 3.2,
		PrayBonus = 8.0
	},
	Fusebox = {
		RepairTime = 8,
		DestroyTime = 1.5,
		Overload = 5,
	},
	Match = {
		Extractions = 8
	}
}

return this
