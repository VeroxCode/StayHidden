local SaveStorage = require(game.ServerScriptService.Handlers["Save Storage"])
local Utils = require(game.ServerScriptService.Handlers.Utils)
local GameModifiers = game.ServerStorage.Modifiers
local GamePerks = game.ReplicatedStorage.Perks
local Remotes = game.ReplicatedStorage.Remotes

local Cards = {}

local Colors = {
	[0] = Color3.new(0.5, 0.16, 0);
	[1] = Color3.new(0.4, 0.4, 0.34);
	[2] = Color3.new(0.52, 0.42, 0);
	[3] = Color3.new(0.5, 0, 0);
}

local OwnerTier = {
	["None"] = 0;
	["Standard"] = 1;
	["Master"] = 2;
}

local Packs = {
	["Small"] = {
		Rarities = {
			[0] = 70;
			[1] = 50;
			[2] = 12;
			[3] = 6;
		},
		ModifierCount = 8,
		PerkType = "None",
		Price = 15000,
		Exp = 750
	},
	["Medium"] = {
		Rarities = {
			[0] = 65;
			[1] = 55;
			[2] = 25;
			[3] = 10;
		},
		ModifierCount = 7,
		PerkType = "Standard",
		Price = 25000,
		Exp = 1000
	},
	["Large"] = {
		Rarities = {
			[0] = 60;
			[1] = 55;
			[2] = 28;
			[3] = 12;
		},
		ModifierCount = 7,
		PerkType = "Standard",
		Price = 35000,
		Exp = 1500
	},
}

function Cards.create(Player, PackType, Role)
	
	local Profile = SaveStorage:get(Player.UserId)
	local Selected = Profile[Role].Selected
	local Inventory = Profile[Role][Selected].Inventory
	
	local Pack = Packs[PackType]
	local ModifierCount = Pack.ModifierCount
	
	local Modifiers = GameModifiers[Role][Selected]
	local Perks = GamePerks[Role]
	
	local ToAward = {}
	local DisplayList = {}
	
	for count = 1, ModifierCount do
		local Rarity = chooseRarity(Pack.Rarities)
		local Items = gatherRarityItems(Rarity, Modifiers, Inventory.Modifiers)
		local chosen = pickFromItems(Items)
		table.insert(ToAward, chosen)
		DisplayList[#DisplayList + 1] = {chosen, Rarity}
	end
	
	if (ModifierCount < 8) then
		local Items = gatherPerks(Pack.PerkType, Perks, Inventory.Perks)
		
		if (#Items > 0) then
			local chosen = pickFromItems(Items)
			Profile = giveItems(Player, "Perks", {chosen}, Profile, Role)
			DisplayList[#DisplayList + 1] = {chosen, (getPerkTier(chosen, Profile[Role][Selected].Inventory) + 1)}
		else
			local Rarity = chooseRarity(Pack.Rarities)
			Items = gatherRarityItems(Rarity, Modifiers, Inventory.Modifiers)
			local chosen = pickFromItems(Items)
			table.insert(ToAward, chosen)
			DisplayList[#DisplayList + 1] = {chosen, Rarity}
		end
	end
	
	Profile = giveItems(Player, "Modifiers", ToAward, Profile, Role)
	Utils:giveExp(Player, Role, Profile, Pack.Exp)
	
	game.ServerStorage.Events.SaveData:Fire(Player)
	Remotes.RequestPurchase:InvokeClient(Player, DisplayList, Role, Selected)
	
end

function Cards:getPrice(PackType)
	return Packs[PackType].Price
end

function chooseRarity(Rarity)
	for index, chance in pairs(Rarity) do
		local random = math.random(1, 100)

		if (random < chance) then
			return index
		end
	end
	
	return 0
end

function gatherRarityItems(Rarity, Pool, Inventory)
	
	local Items = {}
	
	for index, item in pairs(Pool:GetChildren()) do
		if (item:GetAttribute("Rarity") == Rarity) then
			table.insert(Items, item.Name)
		end
	end
	
	return Items
end

function gatherPerks(PerkType, Pool, Inventory)
	
	local Items = {}
	
	for index, item in pairs(Pool:GetChildren()) do
		print(getPerkTier(item.Name, Inventory), OwnerTier[PerkType])
		if (item:GetAttribute("Type") == PerkType and getPerkTier(item.Name, Inventory) < OwnerTier[PerkType]) then
			table.insert(Items, item.Name)
		end
	end
	
	return Items
end

function getPerkTier(PerkName, Inventory)
	
	if (Inventory == nil or Inventory == {}) then
		return 0
	end
	
	if (Inventory[PerkName] ~= nil) then
		return Inventory[PerkName]
	end
	
	return 0
end

function pickFromItems(Items)
	
	local ListSize = #Items
	local random = math.random(1, ListSize)
	
	return Items[random]
end

function giveItems(Player, Type, List, Profile, Role)
	
	local Selected = Profile[Role].Selected
	local Inventory = Profile[Role][Selected].Inventory
	
	if (Type == "Perks") then
		for i, v in pairs(List) do
			Inventory.Perks[v] = math.clamp(getPerkTier(v, Inventory.Perks) + 1, 0, 2)
		end
	end
	
	if (Type == "Modifiers") then
		for i, v in pairs(List) do
			if (Inventory.Modifiers[v] == nil) then
				Inventory.Modifiers[v] = 1
			else
				Inventory.Modifiers[v] += 1
			end
		end
	end
	
	SaveStorage:update(Player.UserId, Profile)
	return Profile
end

return Cards
