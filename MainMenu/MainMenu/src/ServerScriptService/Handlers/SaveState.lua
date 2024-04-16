local this = {}


this.KeyboardDefault = {
	Crouch = Enum.KeyCode.LeftShift.Value,
	Sprint = Enum.KeyCode.LeftControl.Value,
	Interactions = Enum.KeyCode.E.Value,
	Actions = Enum.KeyCode.Space.Value,
	Scoreboard = Enum.KeyCode.Tab.Value,
	SecondaryAbility = Enum.KeyCode.T.Value,
}

this.ControllerDefault = {
	Crouch = Enum.KeyCode.ButtonL2.Value,
	Sprint = Enum.KeyCode.ButtonR2.Value,
	Interactions = Enum.KeyCode.ButtonA.Value,
	Actions = Enum.KeyCode.ButtonA.Value,
	Scoreboard = Enum.KeyCode.ButtonStart.Value,
	SecondaryAbility = Enum.KeyCode.ButtonL1.Value,
}

this.HunterDefault = {
	Level = 0,
	Experience = 0,
	ExperienceNeeded = 2000,
	Cosmetics = {
		Head = {},
		Torso = {},
		Legs = {}
	},
	LoadOut = {
		Modifiers = {
			Slot1 = "",
			Slot2 = "",
		},
		Perks = {
			Slot1 = "",
			Slot2 = "",
			Slot3 = ""
		}
	},
	Inventory = {
		Modifiers = {},
		Perks = {}
	}
}

this.PreyDefault = {
	Level = 0,
	Experience = 0,
	ExperienceNeeded = 2000,
	Cosmetics = {
		Head = {},
		Torso = {},
		Legs = {}
	},
	LoadOut = {
		Modifiers = {
			Slot1 = "",
			Slot2 = "",
		},
		Perks = {
			Slot1 = "",
			Slot2 = "",
			Slot3 = ""
		}
	},
	Inventory = {
		Modifiers = {},
		Perks = {}
	}
}

this.DefaultBinds = {
	Keyboard = this.KeyboardDefault,
	Controller = this.ControllerDefault
}

this.Default = {
	
	Account = {
		lastSession = os.time(),
		Credits = 0,
		Level = 1,
		Rank = "Rookie-V",
		Experience = 0,
		ExperienceNeeded = 2000,
		Settings = {
			["Game Volume"] = 50,
			["Music Volume"] = 50,
			["First-Person FoV"] = 80,
			["Shadows"] = true,
		}
	},

	Statistics = {
		S_GamesPlayed = 0,
		K_GamesPlayed = 0,
		CreditsEarned = 0,
		CreditsSpent = 0
	},

	Prey = {
		Selected = "Healer",
		["Healer"] = this.PreyDefault,
		["Prolonger"] = this.PreyDefault,
	},
	
	Hunter = {
		Selected = "Mountain Climber",
		["Mountain Climber"] = this.HunterDefault,
		["Show Starter"] = this.HunterDefault,
	}

}


return this
