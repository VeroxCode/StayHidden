local Modifiers = game.ServerStorage.Modifiers
local Perks = game.ServerStorage.Perks
local Powers = game.ServerStorage:FindFirstChild("Powers") or game.ServerStorage:FindFirstChild("Cloning"):FindFirstChild("Powers")

local Empty = "rbxassetid://13575130584"
local RichColorStart = `<font color="#FF7800">`
local RichColorEnd = `</font>`

local IgnoreTypes = {"Color3", "boolean"}

local this = {}

this.Characters = {
	Prey = {
		["Healer"] = true,
		["Prolonger"] = true,
	},
	Hunter = {
		["Mountain Climber"] = true,
		["Show Starter"] = true,
	}
}

this.Descriptions = {
	Prey = {
		["Healer"] = "Places down a Totem to Heal himself and his allies when wounded.",
		["Prolonger"] = "Uses Gaps to Increase their Movement Speed.",
	},
	Hunter = {
		["Mountain Climber"] = "Places Traps that inflict the Slowdown Effect on Prey.",
		["Show Starter"] = "Places Orbs that inflict the Paralyzed Effect on Prey."
	}
}

this.ModifierIcons = {
	Prey = {
		["Healer"] = {
			["Blood Covered Swab"] = "rbxassetid://16673513794";
			["Bandage"] = "rbxassetid://16673512779";
			["Cotton Swab"] = "rbxassetid://16673511766";
			["Scalpel"] = "rbxassetid://16673512467";
			["First Aid Kit"] = "rbxassetid://16673513512";
			["Plaster"] = "rbxassetid://16673514096";
			["Oxygen Mask"] = "rbxassetid://16673512974";
			["Gauze Roll"] = "rbxassetid://16673512779";
			["Scissors"] = "rbxassetid://16673512216";
			["Surgical Gloves"] = "rbxassetid://16673512049";
			["Surgical Needle"] = "rbxassetid://16673511913";
		},
		["Prolonger"] = {
			["Athletic Note"] = Empty;
			["Athletic Shoes"] = Empty;
			["Second Place Trophy"] = Empty;
			["Bandage"] = Empty;
			["Crushed Can"] = Empty;
			["Knee Pad"] = Empty;
			["Coach's Guide"] = Empty;
			["Loose Fit Jacket"] = Empty;
			["Washcloth"] = Empty;
			["First Place Trophy"] = Empty;
		}
	},
	Hunter = {
		["Mountain Climber"] = {
			["Ankle Cast"] = "rbxassetid://16897515917";
			["Broken Coil"] = "rbxassetid://16897515748";
			["Dirty Safety Pin"] = "rbxassetid://16897515549";
			["Eviction Notice"] = "rbxassetid://16897515360";
			["Miners Cap"] = "rbxassetid://16897515158";
			["Moldy Bread"] = "rbxassetid://16897514953";
			["Mothers Earrings"] = "rbxassetid://16897514728";
			["Old Picture Frame"] = "rbxassetid://16897514553";
			["Ripped Instructions"] = "rbxassetid://16897514330";
			["Safety Vest"] = "rbxassetid://16897514142";
			["Soggy Rug"] = "rbxassetid://16897513954";
		},
		["Show Starter"] = {
			["Broken Piano Key"] = "rbxassetid://16706173937";
			["Rusty Pipe"] = "rbxassetid://16706172246";
			["Dull Knife"] = "rbxassetid://16706173675";
			["Ripped Autograph"] = "rbxassetid://16706172426";
			["Fathers Advice"] = "rbxassetid://16706173386";
			["Flashlight"] = "rbxassetid://16706173039";
			["Retirement Funds"] = "rbxassetid://16706172623";
			["Missing Person Poster"] = "rbxassetid://16706172777";
			["FBI Papers"] = "rbxassetid://16706173208";
			["Sharp Knife"] = "rbxassetid://16706172087";
			["Infamous Tophat"] = "rbxassetid://16706172907";
		}
	}
}

this.PerkIcons = {
	Prey = {
		["Early Bird"] = "rbxassetid://16269291595";
		["Discharge"] = "rbxassetid://16269291720";
	},
	Hunter = {
		["Electrical Malfunction"] = "rbxassetid://16269291448";
		["Static Shock"] = "rbxassetid://16269291257";
	}
}

this.DescAbility = {
	Prey = {
		["Healer"] = "Click the Activate Ability Button to Place a Totem that lasts for #Lifetime# Seconds. \n \n The Healing Totem has a Radius of #Radius# Studs and will heal everyone nearby by #HealAmount# HP per Second.",
		["Prolonger"] = "After sliding through a Gap, gain a Token, up to #MaxTokens# Tokens. For every Token in your possession, gain a #SpeedIncrease#% Speed Boost. Move Along has a duration of #TokenDuration# seconds. Move Along's Duration is Refreshed every time you gain a Token. \n \n Sliding through the same Gap multiple times will not award multiple Tokens. \n \n Move Along has a cooldown of #MaxCooldown# seconds. "
	},

	Hunter = {
		["Mountain Climber"] = "Start the Match with #MaxTraps# Traps that you can place on the ground. \n \n If Prey stand within a #Radius# Stud Radius of the Trap, they will trigger it and receive a #SlowdownValue#% Slowness Effect for #SlowdownLength# Seconds. ",
		["Show Starter"] = "Click the Activate Ability Button to Place an Orb that lasts for #OrbLifetime# Seconds. Prey that enter the Orb will suffer from the Paralyzed Status. If the Show Starter enters the Orb, he will receive a #SwiftnessValue#% Swiftness Effect for as long as he stays in the Orb. \n \n The Show Starter can only deploy 1 Orb at a time. The Paralyzed Effect lingers for #ParalyzedDuration# Seconds after leaving the Orb"
	}
}

this.DescModifier = {
	Prey = {
		["Healer"] = {
			["Blood Covered Swab"] = "Prey entering the Totem's Radius for the first time gain the Protection Effect for Duration Seconds.\n Increases the Totem's Setup Time by Penalty Seconds";
			["Bandage"] = "Decreases the Totem's Setup Time by Bonus Second";
			["Cotton Swab"] = "Prey leaving the Totem's Radius for the first time gain a Bonus% Swiftness Effect for Duration Seconds";
			["Scalpel"] = "Decreases the Cooldown by Bonus Seconds";
			["First Aid Kit"] = "Increases the Totem's Healing by Bonus HP.\n Decreases the Totem's Lifetime by Penalty Seconds";
			["Plaster"] = "Increases the Totem's Radius by Bonus Studs";
			["Oxygen Mask"] = "Reveals the Aura of every Prey in the Totem's Radius";
			["Gauze Roll"] = "Decreases the Cooldown by Bonus Seconds";
			["Scissors"] = "Decreases the Totem's Setup Time by Bonus Seconds";
			["Surgical Gloves"] = "Increases the Totem's Healing by Bonus HP";
			["Surgical Needle"] = "Increases the Totem's Lifetime by Bonus Seconds";
		},
		["Prolonger"] = {
			["Athletic Note"] = "Reduces Ability Cooldown by Bonus Seconds";
			["Athletic Shoes"] = "Increases Speed Boost per Token by Bonus%";
			["Second Place Trophy"] = "Token don't grant a Speed Bonus anymore. When getting attacked while you have at least 1 Token, the Hunter receives a Slowdown% Slowness Effect for Duration Seconds for each Token";
			["Bandage"] = "Sliding through a Gap grants you a Duration Seconds Protection Effect";
			["Crushed Can"] = "Increases Speed Boost per Token by Bonus%";
			["Knee Pad"] = "Reduces Ability Cooldown by Bonus Seconds";
			["Coach's Guide"] = "Reduces Ability Cooldown by Bonus Seconds. Permanently reduces Default Movement Speed by Penalty%";
			["Loose Fit Jacket"] = "Reduces Ability Cooldown by Bonus Seconds";
			["Washcloth"] = "Reduces Maximum Tokens to Limit. Increases Speed Boost per Token by Bonus";
			["First Place Trophy"] = "Reduces Maximum Tokens to Limit. \nIncreases Speed Boost per Token by Bonus. \nReduces Ability Duration by Reduction Seconds";
		}
	},

	Hunter = {
		["Mountain Climber"] = {
			["Ankle Cast"] = "Increases the Slowdown Multiplier by SlowdownBonus%.",
			["Broken Coil"] = "Prey within the Traps Radius receive Value Damage per Second.",
			["Dirty Safety Pin"] = "Increases the Trap Radius by Bonus.",
			["Eviction Notice"] = "Increases the Slowdown Multiplier by SlowdownBonus%.",
			["Miners Cap"] = "Increases the Slowdown Duration by SlowdownBonus Second(s).",
			["Moldy Bread"] = "Tripping a Trap within TriggerRange Stud(s), increases the Preys Slowdown Multiplier by SlowdownBonus%.",
			["Mothers Earrings"] = "Tripping a Trap within TriggerRange Stud(s) will inflict the Prey with the Vulnerable Effect for the Duration of the Slowness Effect.\nPrey will not be inflicted with Slowness.",
			["Old Picture Frame"] = "Setting a Trap grants you a SpeedBonus% Swiftness Effect for Duration Second(s).",
			["Ripped Instructions"] = "Increases the maximum Amount of Traps you can carry by Bonus.",
			["Safety Vest"] = "Tripping a Trap within TriggerRange Stud(s), grants you a SpeedBonus% Swiftness Effect for Duration Second(s).",
			["Soggy Rug"] = "Increases the Slowdown Duration by SlowdownBonus Second(s).",
		},
		["Show Starter"] = {
			["Broken Piano Key"] = "Increases the additional Movement Speed when inside the Orb by Bonus%";
			["Rusty Pipe"] = "Increases the Orb's Lifetime by Bonus Seconds.";
			["Dull Knife"] = "Instead of the Paralyzed Effect, Prey will get afflicted with the Vulnerable Status Effect.";
			["Ripped Autograph"] = "Prey inside the Orb get afflicted with a Percent% Slowdown Effect";
			["Fathers Advice"] = "Increases the lingering Paralyzed Effect Duration by Bonus Seconds.";
			["Flashlight"] = "Increases the Additional Movement Speed when inside the Orb by Bonus%";
			["Retirement Funds"] = "Prey will get afflicted with the Vulnerable Status Effect in addition to the Paralyzed Effect. \nThe Vulnerable Status Effect lingers for 0.5 Seconds";
			["Missing Person Poster"] = "Increases the lingering Paralyzed Effect Duration by Bonus Seconds.";
			["FBI Papers"] = "Increases the Orb's Lifetime by Bonus Seconds.";
			["Sharp Knife"] = "Prey inside the Radius suffer from following Effects:\n - Battery Drain is increased by ExtraDrain% \n - Sliding through a Gap immediately overloads the associated Fusebox for 10 Seconds \n\nPrey will not be inflicted with the Paralyzed Effect.";
			["Infamous Tophat"] = "Increases the Orb's Lifetime by BonusLifetime Seconds.\nIncreases the lingering Paralyzed Effect Duration by Bonus Seconds.";
		}
	}
}

this.DescPerks = {
	Prey = {
		["Early Bird"] = "Increases Movement Speed by Boost% when less than SerumLimit Serums are extracted.\nDeactivates during Chase and ChaseCooldown Seconds after it ends.";
		["Discharge"] = "Decreases the time a Door stays closed by Bonus Seconds. Increases Battery Usage by Reduce%"
	},
	Hunter = {
		["Electrical Malfunction"] = "Overloads Amount randomly chosen Fuseboxes at the beginning of the Match";
		["Static Shock"] = "After Breaking a Fusebox, this Perk activates: \nYour Attack Damage is increased by Bonus for Duration Seconds.";
	}
}

function this:setupDescriptions()
	for ability, prey in pairs(this.DescModifier.Prey) do
		for modifier, description in pairs(prey) do
			local Mod = Modifiers.Prey[ability][modifier]
			
			for key, value in pairs(Mod:GetAttributes()) do
				local newValue = Mod:GetAttribute(key)
				description = string.gsub(description, key, newValue)
			end
			this.DescModifier.Prey[ability][modifier] = description
		end
	end
	
	for ability, hunter in pairs(this.DescModifier.Hunter) do
		for modifier, description in pairs(hunter) do
			local Mod = Modifiers.Hunter[ability][modifier]

			for key, value in pairs(Mod:GetAttributes()) do
				local newValue = Mod:GetAttribute(key)
				description = string.gsub(description, key, newValue)
			end
			this.DescModifier.Hunter[ability][modifier] = description
		end
	end
	
	for perk, description in pairs(this.DescPerks.Prey) do
		local Mod = Perks.Prey[perk].Config
		
		for key, value in pairs(Mod:GetAttributes()) do
			local newValue = Mod:GetAttribute(key)
			description = string.gsub(description, key, newValue)
		end
		this.DescPerks.Prey[perk] = description
	end
	
	for perk, description in pairs(this.DescPerks.Hunter) do
		local Mod = Perks.Hunter[perk].Config

		for key, value in pairs(Mod:GetAttributes()) do
			local newValue = Mod:GetAttribute(key)
			description = string.gsub(description, key, newValue)
		end
		this.DescPerks.Hunter[perk] = description
	end
end

function this:setupAbilityDescriptions()
	for class, description in pairs(this.DescAbility.Hunter) do
		local PowerClass = Powers.Hunter[class]
		local PowerItem = PowerClass:GetAttribute("PowerItem")
		
		if (PowerItem ~= nil and PowerItem ~= "") then
			for key, value in pairs(PowerClass[PowerItem]:GetAttributes()) do
				key = "#".. key .. "#"
				if (typeof(value) == "Vector3") then
					value = value.X
				end

				if (table.find(IgnoreTypes, typeof(value))) then
					continue
				end

				value = RichColorStart .. value .. RichColorEnd
				description = string.gsub(description, key, value)
			end
		end
		
		for key, value in pairs(PowerClass:GetAttributes()) do
			key = "#".. key .. "#"
			if (typeof(value) == "Vector3") then
				value = value.X
			end
			
			if (table.find(IgnoreTypes, typeof(value))) then
				continue
			end
			
			value = RichColorStart .. value .. RichColorEnd
			description = string.gsub(description, key, value)
		end
		
		this.DescAbility.Hunter[class] = description
	end
	
	for class, description in pairs(this.DescAbility.Prey) do
		local PowerClass = Powers.Prey[class]
		local PowerItem = PowerClass:GetAttribute("PowerItem")

		if (PowerItem ~= nil and PowerItem ~= "") then
			for key, value in pairs(PowerClass[PowerItem]:GetAttributes()) do
				key = "#".. key .. "#"
				if (typeof(value) == "Vector3") then
					value = value.X
				end

				if (table.find(IgnoreTypes, typeof(value))) then
					continue
				end

				description = string.gsub(description, key, value)
			end
		end

		for key, value in pairs(PowerClass:GetAttributes()) do
			key = "#".. key .. "#"
			if (typeof(value) == "Vector3") then
				value = value.X
			end

			if (table.find(IgnoreTypes, typeof(value))) then
				continue
			end

			description = string.gsub(description, key, value)
		end

		this.DescAbility.Prey[class] = description
	end
	
	print(this.DescAbility.Hunter)
	print(this.DescAbility.Prey)
	
end

this:setupAbilityDescriptions()

return this
