local SaveStorage = require(game.ServerScriptService.Handlers:WaitForChild("Save Storage"))

local module = {}

function module:giveExp(Player, Role, Profile, Amount)

	local Selected = Profile[Role].Selected
	local Character = Profile[Role][Selected]

	Character.Experience += Amount
	Profile = module:checkLevelUp(Profile, Character)

	SaveStorage:update(Player.UserId, Profile)
	return Profile
end

function module:checkLevelUp(Profile, Character)

	local Level = Character.Level
	local Exp = Character.Experience
	local ExpNeeded = Character.ExperienceNeeded

	if (Exp >= ExpNeeded) then

		local Diff = Exp - ExpNeeded

		Character.Level += math.clamp(1, 0, 30)
		Character.Experience = math.floor(Diff)
		Character.ExperienceNeeded += math.floor((ExpNeeded / 100) * 5)
		
		if (Character.Experience > Character.ExperienceNeeded) then
			Profile = module:checkLevelUp(Profile, Character)
		end
	end

	return Profile
end

function module:giveAccountExp(Player, Profile, Amount)

	Profile.Account.Experience += Amount
	Profile = module:checkAccountLevelUp(Profile)

	SaveStorage:update(Player.UserId, Profile)
	return Profile
end

function module:checkAccountLevelUp(Profile)

	local Level = Profile.Account.Level
	local Exp = Profile.Account.Experience
	local ExpNeeded = Profile.Account.ExperienceNeeded

	if (Exp >= ExpNeeded) then

		local Diff = Exp - ExpNeeded

		Profile.Account.Level += math.clamp(1, 0, 1000)
		Profile.Account.Experience = math.floor(Diff)
		Profile.Account.ExperienceNeeded += math.floor((ExpNeeded / 100) * 15)
		
		if (Profile.Account.Experience > Profile.Account.ExperienceNeeded) then
			Profile = module:checkAccountLevelUp(Profile)
		end
		
	end

	return Profile
end

return module
