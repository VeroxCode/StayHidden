local LoadoutEvent = game.ReplicatedStorage.Remotes.LoadoutEvent
local RequestData = game.ReplicatedStorage.Remotes.RequestData
local Modifiers = game.ReplicatedStorage.Modifiers
local Perks = game.ReplicatedStorage.Perks
local Player = game.Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local Empty = "rbxassetid://13575130584"

local CaptionRarities = {
	[0] = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0.5, 0.16, 0)), 
		ColorSequenceKeypoint.new(0.35, Color3.new(0.0941176, 0.0941176, 0.0941176)),
		ColorSequenceKeypoint.new(1.0, Color3.new(0.17, 0.17, 0.17))});

	[1] = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0.4, 0.4, 0.34)), 
		ColorSequenceKeypoint.new(0.35, Color3.new(0.0941176, 0.0941176, 0.0941176)),
		ColorSequenceKeypoint.new(1.0, Color3.new(0.17, 0.17, 0.17))});
	
	[2] = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0.52, 0.42, 0)), 
		ColorSequenceKeypoint.new(0.35, Color3.new(0.0941176, 0.0941176, 0.0941176)),
		ColorSequenceKeypoint.new(1.0, Color3.new(0.17, 0.17, 0.17))});
	
	[3] = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0.5, 0, 0)), 
		ColorSequenceKeypoint.new(0.35, Color3.new(0.0941176, 0.0941176, 0.0941176)),
		ColorSequenceKeypoint.new(1.0, Color3.new(0.17, 0.17, 0.17))});
}

local Rarities = {
	[0] = Color3.new(0.5, 0.16, 0);
	[1] = Color3.new(0.4, 0.4, 0.34);
	[2] = Color3.new(0.52, 0.42, 0);
	[3] = Color3.new(0.5, 0, 0);
}

local Selected = {
	Modifier = {
		["Prey"] = "";
		["Hunter"] = "";
	},
	Perk = {
		["Prey"] = "";
		["Hunter"] = "";
	}
}

local Page = {
	Selection = {
		["Prey"] = 1;
		["Hunter"] = 1;
	},
	Modifier = {
		["Prey"] = 1;
		["Hunter"] = 1;
	},
	Perks = {
		["Prey"] = 1;
		["Hunter"] = 1;
	},
}

local AbilityNames = {
	Prey =  {
		["Healer"] = "Healing Totem",
		["Prolonger"] = "Move Along",
	},
	Hunter = {
		["Mountain Climber"] = "Gas Traps",
		["Show Starter"] = "Static Orb",
	}
}

local Descriptions = {
	Modifiers = {},
	Perks = {},
	Characters = {},
	Abilities = {}
}

local Icons = {
	Modifiers = {},
	Perks = {}
}

local SlotConnections = {
	Prey =  {
		Modifier1 = {
			["Enter"] = nil,
			["Leave"] = nil,
		},
		Modifier2 = {
			["Enter"] = nil,
			["Leave"] = nil,
		},
		Perk1 = {
			["Enter"] = nil,
			["Leave"] = nil,
		},
		Perk2 = {
			["Enter"] = nil,
			["Leave"] = nil,
		},
		Perk3 = {
			["Enter"] = nil,
			["Leave"] = nil,
		},
	},
	Hunter = {
		Modifier1 = {
			["Enter"] = nil,
			["Leave"] = nil,
		},
		Modifier2 = {
			["Enter"] = nil,
			["Leave"] = nil,
		},
		Perk1 = {
			["Enter"] = nil,
			["Leave"] = nil,
		},
		Perk2 = {
			["Enter"] = nil,
			["Leave"] = nil,
		},
		Perk3 = {
			["Enter"] = nil,
			["Leave"] = nil,
		},
	}
}

local Data = {}

local this = {}

function this:handleButtonCall(Button: ImageButton, Role)
	
	this:getData()
	
	if (Button.Name == "Selection") then
		this:buildSelection(Role)
	end
	
	if (Button.Name == "Modifier1" or Button.Name == "Modifier2") then
		if (Selected["Modifier"][Role] == "") then
			this:buildModifiers(Role)
			this:showLoadout(Role, true, false)
			Selected["Modifier"][Role] = Button.Name
		else
			if (string.find(Button.Name, Selected["Modifier"][Role])) then
				this:removeModifier(Role, Selected.Modifier[Role])
			end
		end
		
	end
	
	if (Button.Name == "Perk1" or Button.Name == "Perk2" or Button.Name == "Perk3") then
		if (Selected["Perk"][Role] == "") then
			this:buildPerks(Role)
			this:showLoadout(Role, false, true)
			Selected["Perk"][Role] = Button.Name
		else
			if (string.find(Button.Name, Selected["Perk"][Role])) then
				this:removePerk(Role, Selected.Perk[Role])
			end
		end

	end
	
	if (Button.Name == "Next") then
		this:nextPage(Role, Button.Parent)
	end
	
	if (Button.Name == "Previous") then
		this:previousPage(Role, Button.Parent)
	end
	
	if (Button.Name == "Back") then
		Selected = {
			Modifier = {
				["Prey"] = "";
				["Hunter"] = "";
			},
			Perk = {
				["Prey"] = "";
				["Hunter"] = "";
			}
		}
	end
	
end

function this:nextPage(Role, Frame)
	
	local Pages = Frame.Pages
	
	local Counter = {
		["Selection_Character"] = Page.Selection;
		["Selection_Perks"] = Page.Perks;
		["Selection_Modifier"] = Page.Modifier;
	}
	
	if (#Pages:GetChildren() <= 0) then
		return
	end
	
	this:hidePages(Pages)
	local Current = Counter[Frame.Name][Role]
	Counter[Frame.Name][Role] = math.clamp(Current + 1 ,1 ,#Pages:GetChildren())
	this:showPage(Pages[tostring(Counter[Frame.Name][Role])])
	
end

function this:previousPage(Role, Frame)
	
	local Pages = Frame.Pages

	local Counter = {
		["Selection_Character"] = Page.Selection;
		["Selection_Perks"] = Page.Perks;
		["Selection_Modifier"] = Page.Modifier;
	}
	
	if (#Pages:GetChildren() <= 0) then
		return
	end

	this:hidePages(Pages)
	local Current = Counter[Frame.Name][Role]
	Counter[Frame.Name][Role] = math.clamp(Current - 1 ,1 ,#Pages:GetChildren())
	this:showPage(Pages[tostring(Counter[Frame.Name][Role])])
	
end

function this:buildSelection(Role)
	
	local Selection = this:getCharacters()
	
	this:clearSelection(Role)
	this:createSelectionPages(Role, Selection[Role])
	
	local SelectionFrame = PlayerGui[Role].BaseFrame.HolderFrame.B_SelectionFrame
	local Pages = SelectionFrame.Selection_Character.Pages
	
	this:hidePages(Pages)
	this:showPage(Pages["1"])
end

function this:createSelectionPages(Role, Selection)
	
	local function startPage(List)
		
		local SelectionFrame = PlayerGui[Role].BaseFrame.HolderFrame.B_SelectionFrame
		local LoadoutFrame = PlayerGui[Role].BaseFrame.HolderFrame.B_LoadoutFrame
		local Pages = SelectionFrame.Selection_Character.Pages
		
		local Page = SelectionFrame.Selection_Character.PagePrefab:Clone()
		Page.Name = tostring(#Pages:GetChildren() + 1)
		Page.Parent = Pages
		
		for name, unlocked in pairs(List) do
			if (#Page:GetChildren() <= 10) then
				
				local Selection: ImageButton = SelectionFrame.Selection_Character.Prefab:Clone()
				Selection.Name = name
				Selection.Visible = true
				Selection.Selectable = unlocked
				Selection.Parent = Page
				
				Selection.MouseButton1Click:Connect(function()
					LoadoutEvent:FireServer(Role, "Character", Selection.Name)
					
					local Utils = require(PlayerGui.MenuHandler.Utils)
					if (Role == "Hunter") then
						Utils:setMenuTheme(Player, string.gsub(Selection.Name, " ", ""))
					end
					
					this:clearPerks(Role)
					this:clearModifiers(Role)
					this:showLoadout(Role, false, false)

					this:getData()
					this:buildLoadout(Role)
					
				end)
				
				Selection.MouseEnter:Connect(function()
					SelectionFrame.Caption.CharName.Text = name
					SelectionFrame.Caption.CharDesc.Text = Descriptions.Characters[Role][Selection.Name]
					SelectionFrame.Caption.Visible = true
				end)

				Selection.MouseLeave:Connect(function()
					SelectionFrame.Caption.Visible = false
				end)
				
				List[name] = nil
			else
				startPage(List)
				return
			end
		end
	end
	
	startPage(Selection)
	
end

function this:clearSelection(Role)
	local SelectionFrame = PlayerGui[Role].BaseFrame.HolderFrame.B_SelectionFrame
	local Pages = SelectionFrame.Selection_Character.Pages
	
	for i, v in pairs(Pages:GetChildren()) do
		v:Destroy()
	end
	
end

function this:buildModifiers(Role)

	local Selected = Data[Role].Selected
	local Selection = Data[Role][Selected].Inventory.Modifiers
	
	if (workspace:GetAttribute("Playtest")) then
		
		Selection = {}
		
		for i, v in pairs(Modifiers[Role][Selected]:GetChildren()) do
			Selection[v.Name] = 999
		end
	end

	this:clearModifiers(Role)
	this:createModifierPages(Role, Selection)
	
	local SelectionFrame = PlayerGui[Role].BaseFrame.HolderFrame.B_LoadoutFrame
	local Pages = SelectionFrame.Selection_Modifier.Pages

	this:hidePages(Pages)
	this:showPage(Pages["1"])
	
end

function this:createModifierPages(Role, Selection)

	local function startPage(List)

	local LoadoutFrame = PlayerGui[Role].BaseFrame.HolderFrame.B_LoadoutFrame
	local Pages = LoadoutFrame.Selection_Modifier.Pages
	
	local Page = LoadoutFrame.Selection_Modifier.PagePrefab:Clone()
		Page.Name = tostring(#Pages:GetChildren() + 1)
		Page.Parent = Pages

		for name, amount in pairs(List) do
			if (#Page:GetChildren() <= 10) then
				
				local RarityNumber = Modifiers[Role][Data[Role].Selected][name]:GetAttribute("Rarity")
				local CaptionColor = CaptionRarities[RarityNumber]
				local RarityColor = Rarities[RarityNumber]
				
				local Selection: ImageButton = LoadoutFrame.Selection_Modifier.Prefab:Clone()
				Selection.Name = name
				Selection.Visible = true
				Selection.Selectable = (amount > 0)
				Selection.Amount.Text = amount
				Selection.Parent = Page
				
				Selection.Outline.Color = RarityColor
				Selection.Image = Icons.Modifiers[Role][Data[Role].Selected][name]
				
				Selection.MouseButton1Click:Connect(function()
					if (amount > 0 and not this:hasModifierEquipped(Role, Selection.Name)) then
						LoadoutFrame.Caption.Visible = false
						LoadoutEvent:FireServer(Role, "Modifier", Selection.Name, Selected.Modifier[Role])
						this:setModifier(Role, Selected.Modifier[Role], Selection.Name)
					end
				end)
				
				Selection.MouseEnter:Connect(function()
					LoadoutFrame.Caption.Gradient.Color = CaptionColor
					LoadoutFrame.Caption.ItemName.Text = name
					LoadoutFrame.Caption.ItemDesc.Text = Descriptions.Modifiers[Role][Data[Role].Selected][name]
					LoadoutFrame.Caption.Visible = true
					LoadoutFrame.Ability_Caption.Visible = false
				end)
				
				Selection.MouseLeave:Connect(function()
					LoadoutFrame.Caption.Visible = false
					LoadoutFrame.Ability_Caption.Visible = true
				end)

				List[name] = nil
			else
				startPage(List)
				return
			end
		end
	end

	startPage(Selection)

end

function this:clearModifiers(Role)
	local SelectionFrame = PlayerGui[Role].BaseFrame.HolderFrame.B_LoadoutFrame
	local Pages = SelectionFrame.Selection_Modifier.Pages

	Selected.Modifier[Role] = ""

	for i, v in pairs(Pages:GetChildren()) do
		v:Destroy()
	end

end

function this:removeModifier(Role, Slot)
	this:setModifier(Role, Selected.Modifier[Role], "")
	LoadoutEvent:FireServer(Role, "Modifier", "", Slot)
	this:clearModifiers(Role)
end

function this:setModifier(Role, Slot, Modifier)
	
	local LoadoutFrame = PlayerGui[Role].BaseFrame.HolderFrame.B_LoadoutFrame
	local ModifierSlot: ImageButton = LoadoutFrame.LoadoutElements[Slot]
	
	if (Modifier == "" or Modifier == nil) then
		ModifierSlot.Image = Empty
		ModifierSlot.ImageTransparency = 1
		ModifierSlot.Outline.Color = Color3.new(0.094, 0.094, 0.094)
		
		if (SlotConnections[Role][ModifierSlot.Name]["Enter"] ~= nil) then
			SlotConnections[Role][ModifierSlot.Name]["Enter"]:Disconnect()
			SlotConnections[Role][ModifierSlot.Name]["Enter"] = nil
		end
		
		SlotConnections[Role][ModifierSlot.Name]["Enter"] = ModifierSlot.MouseEnter:Connect(function()
			LoadoutFrame.Caption.Visible = false
			LoadoutFrame.Ability_Caption.Visible = true
		end)
		
		if (SlotConnections[Role][ModifierSlot.Name]["Leave"] ~= nil) then
			SlotConnections[Role][ModifierSlot.Name]["Leave"] = nil
		end

		SlotConnections[Role][ModifierSlot.Name]["Leave"] = ModifierSlot.MouseLeave:Connect(function()
			LoadoutFrame.Caption.Visible = false
			LoadoutFrame.Ability_Caption.Visible = true
		end)
		
	else
		
		local RarityNumber = Modifiers[Role][Data[Role].Selected][tostring(Modifier)]:GetAttribute("Rarity")
		local CaptionColor = CaptionRarities[RarityNumber]
		local RarityColor = Rarities[RarityNumber]
		
		ModifierSlot.Image = Icons.Modifiers[Role][Data[Role].Selected][tostring(Modifier)]
		ModifierSlot.ImageTransparency = 0
		ModifierSlot.Outline.Color = RarityColor or Rarities[1]
		
		if (SlotConnections[Role][ModifierSlot.Name]["Enter"] ~= nil) then
			SlotConnections[Role][ModifierSlot.Name]["Enter"]:Disconnect()
			SlotConnections[Role][ModifierSlot.Name]["Enter"] = nil
		end

		SlotConnections[Role][ModifierSlot.Name]["Enter"] = ModifierSlot.MouseEnter:Connect(function()
			LoadoutFrame.Caption.Gradient.Color = CaptionColor
			LoadoutFrame.Caption.ItemName.Text = Modifier
			LoadoutFrame.Caption.ItemDesc.Text = Descriptions.Modifiers[Role][Data[Role].Selected][Modifier]
			LoadoutFrame.Caption.Visible = true
			LoadoutFrame.Ability_Caption.Visible = false
		end)

		if (SlotConnections[Role][ModifierSlot.Name]["Leave"] ~= nil) then
			SlotConnections[Role]["Leave"] = nil
		end

		SlotConnections[Role][ModifierSlot.Name]["Leave"] = ModifierSlot.MouseLeave:Connect(function()
			LoadoutFrame.Caption.Visible = false
			LoadoutFrame.Ability_Caption.Visible = true
		end)
		
	end
	
	this:clearModifiers(Role)
	
end

function this:buildPerks(Role)

	local Selected = Data[Role].Selected
	local Selection = Data[Role][Selected].Inventory.Perks
	
	if (workspace:GetAttribute("Playtest")) then

		Selection = {}

		for i, v in pairs(Perks[Role]:GetChildren()) do
			Selection[v.Name] = 1
		end
	end

	this:clearPerks(Role)
	this:createPerkPages(Role, Selection)

	local SelectionFrame = PlayerGui[Role].BaseFrame.HolderFrame.B_LoadoutFrame
	local Pages = SelectionFrame.Selection_Perk.Pages

	this:hidePages(Pages)
	this:showPage(Pages["1"])

end

function this:createPerkPages(Role, Selection)

	local function startPage(List)

		local SelectionFrame = PlayerGui[Role].BaseFrame.HolderFrame.B_LoadoutFrame
		local Pages = SelectionFrame.Selection_Perk.Pages

		local Page = SelectionFrame.Selection_Perk.PagePrefab:Clone()
		Page.Name = tostring(#Pages:GetChildren() + 1)
		Page.Parent = Pages

		for name, tier in pairs(List) do
			if (#Page:GetChildren() <= 10) then

				local CaptionColor = CaptionRarities[tier]
				local RarityColor = Rarities[tier]

				local Selection: ImageButton = SelectionFrame.Selection_Perk.Prefab:Clone()
				Selection.Name = name
				Selection.Visible = true
				Selection.Selectable = (tier > 0)
				Selection.Parent = Page

				Selection.Outline.Color = RarityColor
				Selection.Image = Icons.Perks[Role][name]

				Selection.MouseButton1Click:Connect(function()
					if (tier > 0 and not this:hasPerkEquipped(Role, Selection.Name)) then
						SelectionFrame.Caption.Visible = false
						LoadoutEvent:FireServer(Role, "Perk", Selection.Name, Selected.Perk[Role])
						this:setPerk(Role, Selected.Perk[Role], Selection.Name, tier)
					end
				end)

				Selection.MouseEnter:Connect(function()
					SelectionFrame.Caption.Gradient.Color = CaptionColor
					SelectionFrame.Caption.ItemName.Text = name
					SelectionFrame.Caption.ItemDesc.Text = Descriptions.Perks[Role][name]
					SelectionFrame.Caption.Visible = true
				end)

				Selection.MouseLeave:Connect(function()
					SelectionFrame.Caption.Visible = false
				end)

				List[name] = nil
			else
				startPage(List)
				return
			end
		end
	end

	startPage(Selection)

end

function this:clearPerks(Role)
	local SelectionFrame = PlayerGui[Role].BaseFrame.HolderFrame.B_LoadoutFrame
	local Pages = SelectionFrame.Selection_Perk.Pages
	
	Selected.Perk[Role] = ""

	for i, v in pairs(Pages:GetChildren()) do
		v:Destroy()
	end

end

function this:removePerk(Role, Slot)
	this:setPerk(Role, Selected.Perk[Role], "")
	LoadoutEvent:FireServer(Role, "Perk", "", Slot)
	this:clearPerks(Role)
end

function this:setPerk(Role, Slot, Perk, Tier)
	
	local LoadoutFrame = PlayerGui[Role].BaseFrame.HolderFrame.B_LoadoutFrame
	local PerkSlot: ImageButton = LoadoutFrame.LoadoutElements[Slot]

	if (tostring(Perk) == "") then
		PerkSlot.Image = Empty
		PerkSlot.ImageTransparency = 1
		PerkSlot.Outline.Color = Color3.new(0.094, 0.094, 0.094)
		
		if (SlotConnections[Role][PerkSlot.Name]["Enter"] ~= nil) then
			SlotConnections[Role][PerkSlot.Name]["Enter"]:Disconnect()
			SlotConnections[Role][PerkSlot.Name]["Enter"] = nil
		end

		SlotConnections[Role][PerkSlot.Name]["Enter"] = PerkSlot.MouseEnter:Connect(function()
			LoadoutFrame.Caption.Visible = false
			LoadoutFrame.Ability_Caption.Visible = true
		end)

		if (SlotConnections[Role][PerkSlot.Name]["Leave"] ~= nil) then
			SlotConnections[Role][PerkSlot.Name]["Leave"] = nil
		end

		SlotConnections[Role][PerkSlot.Name]["Leave"] = PerkSlot.MouseLeave:Connect(function()
			LoadoutFrame.Caption.Visible = false
			LoadoutFrame.Ability_Caption.Visible = true
		end)
	else

		local RarityColor = Rarities[Tier]
		local CaptionColor = CaptionRarities[1]

		PerkSlot.Image = Icons.Perks[Role][tostring(Perk)]
		PerkSlot.ImageTransparency = 0
		PerkSlot.Outline.Color = RarityColor or Rarities[1]
		
		if (SlotConnections[Role][PerkSlot.Name]["Enter"] ~= nil) then
			SlotConnections[Role][PerkSlot.Name]["Enter"]:Disconnect()
			SlotConnections[Role][PerkSlot.Name]["Enter"] = nil
		end

		SlotConnections[Role][PerkSlot.Name]["Enter"] = PerkSlot.MouseEnter:Connect(function()
			LoadoutFrame.Caption.Gradient.Color = CaptionColor
			LoadoutFrame.Caption.ItemName.Text = Perk
			LoadoutFrame.Caption.ItemDesc.Text = Descriptions.Perks[Role][Perk]
			LoadoutFrame.Caption.Visible = true
		end)

		if (SlotConnections[Role][PerkSlot.Name]["Leave"] ~= nil) then
			SlotConnections[Role]["Leave"] = nil
		end

		SlotConnections[Role][PerkSlot.Name]["Leave"] = PerkSlot.MouseLeave:Connect(function()
			LoadoutFrame.Caption.Visible = false
		end)
		
	end
	
	this:clearPerks(Role)

end

function this:hasModifierEquipped(Role, Modifier)

	local SelectionFrame = PlayerGui[Role].BaseFrame.HolderFrame.B_LoadoutFrame
	local Slots = {["Modifier1"] = "Slot1", ["Modifier2"] = "Slot2"}
	local Character = Data[Role].Selected

	for slot, modifier in pairs(Data[Role][Character].LoadOut.Modifiers) do
		if (modifier == Modifier) then
			SelectionFrame.Caption.Visible = false
			this:clearModifiers(Role)
			return true
		end
	end
	return false
end

function this:hasPerkEquipped(Role, Perk)
	
	local SelectionFrame = PlayerGui[Role].BaseFrame.HolderFrame.B_LoadoutFrame
	local Slots = {["Perk1"] = "Slot1", ["Perk2"] = "Slot2", ["Perk3"] = "Slot3"}
	local Character = Data[Role].Selected
	
	for slot, perk in pairs(Data[Role][Character].LoadOut.Perks) do
		if (perk == Perk) then
			SelectionFrame.Caption.Visible = false
			this:clearPerks(Role)
			return true
		end
	end
	return false
end

function this:showLoadout(Role, Modifier, Perks)
	local SelectionFrame = PlayerGui[Role].BaseFrame.HolderFrame.B_LoadoutFrame
	SelectionFrame.Selection_Modifier.Visible = Modifier
	SelectionFrame.Selection_Perk.Visible = Perks
end

function this:buildLoadout(Role)
	
	local Profile = this:getProfile()
	local Character = Profile[Role].Selected
	
	local Perks = Profile[Role][Character].LoadOut.Perks
	local Modifiers = Profile[Role][Character].LoadOut.Modifiers
	
	local RespPerk1 = LoadoutEvent:FireServer(Role, "Perk", Perks.Slot1, "Perk1")
	local RespPerk2 = LoadoutEvent:FireServer(Role, "Perk", Perks.Slot2, "Perk2")
	local RespPerk3 = LoadoutEvent:FireServer(Role, "Perk", Perks.Slot3, "Perk3")
	
	local RespMod1 = LoadoutEvent:FireServer(Role, "Modifier", Modifiers.Slot1, "Modifier1")
	local RespMod2 = LoadoutEvent:FireServer(Role, "Modifier", Modifiers.Slot2, "Modifier2")
	
	local LoadoutFrame = PlayerGui[Role].BaseFrame.HolderFrame.B_LoadoutFrame
	LoadoutFrame.Ability_Caption.ItemName.Text = AbilityNames[Role][Character]
	LoadoutFrame.Ability_Caption.ItemDesc.Text = Descriptions.Abilities[Role][Character]
	
	if (RespPerk1) then
		this:setPerk(Role, "Perk1", Perks.Slot1, Profile[Role][Character].Inventory.Perks[Perks.Slot1])
	else
		this:setPerk(Role, "Perk1", Perks.Slot1, "")
	end
	
	if (RespPerk2) then
		this:setPerk(Role, "Perk2", Perks.Slot2, Profile[Role][Character].Inventory.Perks[Perks.Slot2])
	else
		this:setPerk(Role, "Perk2", Perks.Slot2, "")
	end
	
	if (RespPerk3) then
		this:setPerk(Role, "Perk3", Perks.Slot3, Profile[Role][Character].Inventory.Perks[Perks.Slot3])
	else
		this:setPerk(Role, "Perk3", Perks.Slot3, "")
	end
	
	if (RespMod1) then
		this:setModifier(Role, "Modifier1", Modifiers.Slot1)
	else
		this:setModifier(Role, "Modifier1", Modifiers.Slot1, "")
	end
	
	if (RespMod2) then
		this:setModifier(Role, "Modifier2", Modifiers.Slot2)
	else
		this:setModifier(Role, "Modifier2", Modifiers.Slot2, "")
	end
	
end

function this:showPage(Page)
	for i, v in pairs(Page:getChildren()) do
		if (v:isA("ImageButton")) then
			v.Visible = true
		end
	end
end

function this:hidePages(Page)
	for i, v in pairs(Page:getDescendants()) do
		if (v:isA("ImageButton")) then
			v.Visible = false
		end
	end
end

function this:getData()
	Data = this:getProfile()
	Descriptions.Characters = this:getCharacterDescriptions()
	Descriptions.Modifiers = this:getModifierDescriptions()
	Descriptions.Abilities = this:getAbilityDescriptions()
	Descriptions.Perks = this:getPerkDescriptions()
	Icons.Modifiers = this:getModifierImages()
	Icons.Perks = this:getPerkImages()
end

function this:getCharacterDescriptions()
	local Descriptions = RequestData:InvokeServer("DescCharacters")
	return Descriptions
end

function this:getModifierDescriptions()
	local Descriptions = RequestData:InvokeServer("DescModifiers")
	return Descriptions
end

function this:getAbilityDescriptions()
	local Descriptions = RequestData:InvokeServer("DescAbilities")
	return Descriptions
end

function this:getPerkDescriptions()
	local Descriptions = RequestData:InvokeServer("DescPerks")
	return Descriptions
end

function this:getModifierImages()
	local Images = RequestData:InvokeServer("ImagesModifiers")
	return Images
end

function this:getPerkImages()
	local Images = RequestData:InvokeServer("ImagesPerks")
	return Images
end

function this:getCharacters()
	local Characters = RequestData:InvokeServer("AllCharacters")
	return Characters
end

function this:getProfile()
	local Profile = RequestData:InvokeServer("Profile")
	return Profile
end

return this
