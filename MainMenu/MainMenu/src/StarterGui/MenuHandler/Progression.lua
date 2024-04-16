local Player = game.Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local AccountUI = require(script.Parent.AccountUI);
local Remotes = game.ReplicatedStorage.Remotes

local Profile = nil
local ExpTweenH = nil
local ExpTweenP = nil

local Rarities = {
	[0] = Color3.new(0.5, 0.16, 0);
	[1] = Color3.new(0.4, 0.4, 0.34);
	[2] = Color3.new(0.52, 0.42, 0);
	[3] = Color3.new(0.5, 0, 0);
}

local Hidden = "rbxassetid://16879549524"

local Progression = {}

function Progression:LoadLevelAndExp(Role)
	
	Profile = Remotes.RequestData:InvokeServer("Profile")
	
	local SelectedCharacter = Profile[Role].Selected
	local Level = Profile[Role][SelectedCharacter].Level
	local Experience = math.floor(Profile[Role][SelectedCharacter].Experience)
	local ExperienceNeeded = math.floor(Profile[Role][SelectedCharacter].ExperienceNeeded)
	
	local PacksUI = PlayerGui[Role].BaseFrame.HolderFrame.B_ProgressionFrame.Packs
	local Exp = PacksUI.Exp
	
	local BarLength = if (Level >= 30) then 1 else 1 / ExperienceNeeded * Experience
	local ProgressUDim = UDim2.fromScale(BarLength, 1)
	local ExpText = if (Level >= 30) then `Max Level reached` else `{Experience} / {ExperienceNeeded} Exp Needed`
	
	local BarTween = game.TweenService:Create(Exp.Progress, TweenInfo.new(1), {Size = ProgressUDim})
	BarTween:Play()
	
	Exp.ExpText.Text = ExpText
	PacksUI.CurrentLevel.Text = `Current Level: {Level}`
end

function Progression:BuyCards(Role, Type)
	
	if (PlayerGui.Cards.Enabled) then
		return
	end
	
	local response = Remotes.RequestPurchase:InvokeServer(Role, "Pack", Type)
	
	if (response == "Purchased") then
		AccountUI:updateCurrency()
	end
	
end

function DisplayPack(List, Role, Selected)
	
	local PlayerGui = Player.PlayerGui
	local Cards = PlayerGui.Cards.BaseFrame
	
	local Cards = PlayerGui[Role].BaseFrame.HolderFrame.B_CardFrame
	local Packs = PlayerGui[Role].BaseFrame.HolderFrame.B_ProgressionFrame.Packs
	local ProgressionFrame = PlayerGui[Role].BaseFrame.HolderFrame.B_ProgressionFrame
	
	local Profile = Remotes.RequestData:InvokeServer("Profile")
	local Selected = Profile[Role].Selected
	
	local Images = {
		Perks = Remotes.RequestData:InvokeServer("ImagesPerks"),
		Modifiers = Remotes.RequestData:InvokeServer("ImagesModifiers")
	}
	
	Images.Modifiers = Images.Modifiers[Role][Selected]
	Images.Perks = Images.Perks[Role]
	
	local count = 1
	
	for i, v in pairs(Cards:GetChildren()) do
		if (string.find(v.Name, "Card")) then
			v.ItemIcon.Image = Hidden
			v.UIStroke.Color = Color3.new(0, 0, 0)
			v.Position = UDim2.fromScale(0.5, 0.5)
		end
	end
	
	ProgressionFrame.Visible = false
	Cards.Close.Visible = false
	Cards.Visible = true
	Packs.Visible = false
	
	for index, content in pairs(List) do
		task.wait(0.5)
		local Icon = searchIcon(content[1], Images.Perks, Images.Modifiers)
		local Card = Cards["Card" .. tostring(count)]
		local Pos =  Cards["Pos" .. tostring(count)]
		
		count += 1
		
		local tween = game.TweenService:Create(Card, TweenInfo.new(0.5), {Position = UDim2.fromScale(Pos.Position.X.Scale, Pos.Position.Y.Scale)})
		tween:Play()
		
		tween.Completed:Connect(function()
			if (Icon ~= nil) then
				Card.ItemIcon.Image = Icon
				
				local colortween = game.TweenService:Create(Card.UIStroke, TweenInfo.new(0.3), {Color = Rarities[content[2]]})
				colortween:Play()
			end
		end)
	end
	
	Cards.Close.Visible = true
	
end

function searchIcon(Item, Perks, Modifiers)
	
	for i, v in pairs(Perks) do
		
		if (i == Item) then
			return  v
		end
	end
	
	for i, v in pairs(Modifiers) do
		
		if (i == Item) then
			return  v
		end
	end
	
	return "hi"
end

Remotes.RequestPurchase.OnClientInvoke = DisplayPack

return Progression
