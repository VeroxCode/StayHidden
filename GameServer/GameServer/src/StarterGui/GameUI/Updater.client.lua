local NotificationSpawnEvent = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SpawnNotification")
local SpawnProgressEvent = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SpawnProgress")
local SpawnPromptEvent = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SpawnPrompt")
local PowerUpdateEvent = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PowerUpdate")

local Assets = game.ReplicatedStorage.Assets
local Gameplay = require(game.ReplicatedStorage.Prefabs["Client Functions"])

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = game.Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local ClientEvents = Backpack:WaitForChild("Events")

local BaseFrame = script.Parent.BaseFrame
local InventoryPerks = BaseFrame.Loadout.Perks
local TrackingUI = BaseFrame.Loadout.Inventory.Tracking
local Notification = BaseFrame.Notification
local PlayersFolder = BaseFrame.Players
local Objective = BaseFrame.Objective
local IProgress = BaseFrame.IProgress
local Prompt = BaseFrame.Prompt

local ExtractionProgress = Objective.ExtractionProgress
local Battery = Objective.Inventory.Battery

local SerumColorON = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0.498039, 0, 0)), ColorSequenceKeypoint.new(1, Color3.new(1, 0.117647, 0.117647))})
local SerumColorOFF = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0.00784314, 0.494118, 0)), ColorSequenceKeypoint.new(1, Color3.new(0.352941, 1, 0.254902))})

local DisplayTime = {
	Prompt = 0.0,
	Progress = 0.0
}

function onJoin(Player)
	
	local LocalMatchPlayer = Gameplay:getMatchPlayer(LocalPlayer.UserId)
	local MatchPlayers = game.ReplicatedStorage.Match.Players

	repeat task.wait()
	until MatchPlayers:FindFirstChild(Player.Name) ~= nil

	if (PlayersFolder:FindFirstChild(Player.Name) ~= nil) then
		return
	end

	for i, UIPlayer in pairs(PlayersFolder:GetChildren()) do
		if (UIPlayer.Name == "Empty") then

			if (Gameplay:isHunter(Player.UserId)) then
				return
			end

			local ThumbType = Enum.ThumbnailType.HeadShot
			local ThumbSize = Enum.ThumbnailSize.Size100x100
			local Icon = Players:GetUserThumbnailAsync(Player.UserId, ThumbType, ThumbSize)

			UIPlayer.Name = Player.Name
			UIPlayer.NameLabel.Text = Player.Name
			UIPlayer.ImageLabel.Image = Icon
			UIPlayer.Visible = true
			break	
		end
	end

end

function onLeave(Player)

	for i, UIPlayer in pairs(PlayersFolder:GetChildren()) do
		if (UIPlayer.Name == Player.Name) then
			UIPlayer.Name = "Empty"
			UIPlayer.Visible = false
		end
	end

end

function onUpdate(delta)
	
	if (not Gameplay:isRunning()) then
		return
	end
	
	local LocalMatchPlayer = Gameplay:getMatchPlayer(LocalPlayer.UserId)
	local Role = Gameplay:getRole(LocalMatchPlayer)
	
	local LocalPrompt = LocalMatchPlayer.Prompt
	local LocalProgress = LocalMatchPlayer.Progress
	local LocalNotification = LocalMatchPlayer.Notification
	local Interaction = LocalMatchPlayer:GetAttribute("Interaction")
	local Action = LocalMatchPlayer:GetAttribute("Action")
	
	if (Role == "Hunter") then
		updateTracking(LocalMatchPlayer)
	else
		updateBattery(LocalMatchPlayer)
		updateItem(LocalMatchPlayer)
	end
	
	updatePlayers()
	updatePerks(LocalMatchPlayer)
	updateObjective(LocalMatchPlayer)
	updateAbility(LocalMatchPlayer)
	updateProgress(LocalProgress)
	updatePrompt(LocalPrompt)

	if ((DisplayTime.Prompt > 0 and Interaction > -1 and Action < 2) and not UserInputService.TouchEnabled) then
		DisplayTime.Prompt -= delta
	else
		Prompt.Input_Keyboard.Visible = false
		Prompt.Input_Gamepad.Visible = false
		Prompt.Action.Visible = false
	end

	if (DisplayTime.Progress > 0) then
		DisplayTime.Progress -= delta
		IProgress.ProgressBar.Visible = true
		IProgress.Action.Visible = true
	else
		IProgress.ProgressBar.Visible = false
		IProgress.Action.Visible = false
	end
	
end

function updatePlayers()

	local LocalMatchPlayer = Gameplay:getMatchPlayer(LocalPlayer.UserId)
	local CurrentRole = Gameplay:getRole(LocalMatchPlayer)
	local MatchPlayers = Gameplay:getMatchPlayers()

	if (Gameplay:isHunter(LocalPlayer.UserId)) then
		for i, UIPlayer in pairs(PlayersFolder:GetChildren()) do
			UIPlayer.Health.Visible = false
			UIPlayer.NameLabel.Position = UDim2.new(0.6, 0, 0.5, 0)
		end
		return
	end

	for i, Player in pairs(Players:GetPlayers()) do
		onJoin(Player)
	end

	for i, MatchPlayer in pairs(MatchPlayers) do
		updateHealth(MatchPlayer)
	end
end

function updateObjective(LocalMatchPlayer)
	
	local AbsolutX = LocalPlayer.PlayerGui.GameUI.AbsoluteSize.X
	local AbsolutY = LocalPlayer.PlayerGui.GameUI.AbsoluteSize.Y
	
	local Extracted = Gameplay:getExtractionProgress()
	local Extractions = Gameplay:getMaxExtractions()
	local CanEscape = Gameplay:canEscape()
	
	local Role = Gameplay:getRole(LocalMatchPlayer)
	local Parts = Gameplay:getParts(LocalMatchPlayer)
	local HasSerum = Gameplay:HasSerum(LocalMatchPlayer)
	
	local Progress = ExtractionProgress.Progress.Size.X.Scale
	local NewProgress = 1 / Extractions * Extracted
	local PremadeText = `{Extracted}/{Extractions} Serums Extracted`
	local newSize = UDim2.new(NewProgress, 0, 1, 0)
	
	if (not ExtractionProgress:GetAttribute("hide")) then
		ExtractionProgress.Visible = true
	end
	
	if (Progress ~= NewProgress and ExtractionProgress.Progress.Size.X.Scale ~= newSize.X.Scale) then
		local info = TweenInfo.new(0.1)
		local goal = {Size = newSize}
		local tween = TweenService:Create(ExtractionProgress.Progress, info, goal)
		
		tween:Play()
	end
	
	if (Role == "Prey") then
		local SerumUI = Objective.Inventory.Serum
		local PartsUI = Objective.Inventory.Parts
		
		PartsUI.Amount.Text = `x{Parts}`
		
		if (not Objective.Inventory:GetAttribute("hide")) then
			SerumUI.Visible = true
			PartsUI.Visible = true
		end
		
		if (HasSerum) then
			SerumUI.UIStroke.YES.Enabled = true
			SerumUI.UIStroke.NO.Enabled = false
		else
			SerumUI.UIStroke.YES.Enabled = false
			SerumUI.UIStroke.NO.Enabled = true
		end
		
	else
		local SerumUI = Objective.Inventory.Serum
		local PartsUI = Objective.Inventory.Parts
		local PowerUI = BaseFrame.Loadout.Inventory.Power
		
		SerumUI.Visible = false
		PartsUI.Visible = false
		PowerUI.Visible = true
		
		PowerUI.Amount.Visible = PowerUI:GetAttribute("PowerAmount") > 0
		PowerUI.Amount.Text = tostring(PowerUI:GetAttribute("PowerAmount"))
		
	end
	
	if (CanEscape) then
		if (Role == "Hunter") then
			ExtractionProgress.Objective.Text = "Prevent your Prey from escaping!"
			ExtractionProgress.Transparency = 1
			ExtractionProgress.Progress.Transparency = 1
		else
			ExtractionProgress.Objective.Text = "Find an Exit Door to escape!"
			ExtractionProgress.Transparency = 1
			ExtractionProgress.Progress.Transparency = 1
		end
	else
		ExtractionProgress.Objective.Text = PremadeText
		ExtractionProgress.Transparency = 0
		ExtractionProgress.Progress.Transparency = 0
	end
end

function updateHealth(MatchPlayer)
	
	local AbsolutX = LocalPlayer.PlayerGui.GameUI.AbsoluteSize.X
	local AbsolutY = LocalPlayer.PlayerGui.GameUI.AbsoluteSize.Y
	
	local Role = Gameplay:getRole(MatchPlayer)
	
	if (Role == "Prey") then
		local MaxHealth = Gameplay:getMaxHealth(MatchPlayer)
		local Health = Gameplay:getHealth(MatchPlayer)
		local Main = PlayersFolder[MatchPlayer.Name]
		local Progress = Main.Health.Progress
		local Needle = Main.Health.Needle
		
		local ProgressWidth = (1 / 100) * Health
		local NeedlePos = (1 / 100) * MaxHealth
		
		Needle.Visible = (MaxHealth < 100)
		
		if (Progress.Size.X.Scale == ProgressWidth) then
			return
		end
		
		local tweenInfo = TweenInfo.new(0.2)
		local tweenGoal = {Size = UDim2.new(ProgressWidth, 0, 1, 0)}
		local tween = TweenService:Create(Progress, tweenInfo, tweenGoal)

		tween:Play()
		
		local ntweenInfo = TweenInfo.new(0.2)
		local ntweenGoal = {Position = UDim2.new(NeedlePos, 0, 0.5, 0)}
		local ntween = TweenService:Create(Needle, tweenInfo, ntweenGoal)

		ntween:Play()
	end
	
end

function updateIProgress()
	
	local Progress = IProgress.Progress.Value
	local MaxProgress = IProgress.MaxProgress.Value
	local ProgressWidth = 1 / MaxProgress * Progress
	
	local CurrLength = IProgress.ProgressBar.Progress.Size.X.Scale
	
	if (CurrLength == ProgressWidth) then
		return
	end
	
	local tweenInfo = TweenInfo.new(0.1)
	local tweenGoal = {Size = UDim2.new(ProgressWidth, 0, 1, 0)}
	local tween = TweenService:Create(IProgress.ProgressBar.Progress, tweenInfo, tweenGoal)
	
	tween:Play()
	
end

function updateBattery(LocalMatchPlayer)
	
	local MaxBattery = Gameplay:getMaxBattery(LocalMatchPlayer)
	local VBattery = Gameplay:getBattery(LocalMatchPlayer)
	local Role = Gameplay:getRole(LocalMatchPlayer)
	
	if (not Objective.Inventory:GetAttribute("hide")) then
		Battery.Frame.Visible = true
	end
	
	local ProgressHeight = 1 / MaxBattery * VBattery
	
	local tweenInfo = TweenInfo.new(0.1)
	local tweenGoal = {Size = UDim2.new(1, 0, ProgressHeight, 0)}
	local tween = TweenService:Create(Battery.Frame.Progress, tweenInfo, tweenGoal)

	tween:Play()
	
end

function updateAbility(LocalMatchPlayer)
	
	local AbilityMaxCooldown = Gameplay:getPowerLocally(LocalMatchPlayer, "MaxCooldown")
	local AbilityCooldown = Gameplay:getPowerLocally(LocalMatchPlayer, "Cooldown")
	local AbilityAmount = Gameplay:getPowerLocally(LocalMatchPlayer, "Amount")
	
	local PowerUI = BaseFrame.Loadout.Inventory.Power
	
	if (not BaseFrame.Loadout.Inventory.Power:GetAttribute("hide")) then
		BaseFrame.Loadout.Inventory.Power.Visible = true
	end
	
	local Left = PowerUI.Left.Circle
	local Right = PowerUI.Right.Circle
	local Amount = PowerUI.Amount
	local CircleProgress = math.clamp((360 / AbilityMaxCooldown) * AbilityCooldown, 0, 360)
	
	Right.UIGradient.Rotation = math.clamp(CircleProgress, 0, 180)
	Left.UIGradient.Rotation = math.clamp(CircleProgress, 180, 360)
	Amount.Text = tostring(AbilityAmount)
	
	Right.Visible = (AbilityMaxCooldown > 0 and AbilityCooldown > 0)
	Left.Visible = (AbilityMaxCooldown > 0 and AbilityCooldown > 0)
	Amount.Visible = (AbilityAmount > 0)
	
end

function updateTracking(LocalMatchPlayer)
	
	local Role = Gameplay:getRole(LocalMatchPlayer)
	local AbilityMaxCooldown = Gameplay:getPowerLocally(LocalMatchPlayer, "TrackingMaxCooldown")
	local AbilityCooldown = Gameplay:getPowerLocally(LocalMatchPlayer, "TrackingCooldown")
	
	local Left = TrackingUI.Left.Circle
	local Right = TrackingUI.Right.Circle
	local CircleProgress = math.clamp((360 / AbilityMaxCooldown * AbilityCooldown), 0, 360)
	
	if (not TrackingUI:GetAttribute("hide")) then
		TrackingUI.Visible = (AbilityMaxCooldown > 0)
	end
	
	Right.Visible = (AbilityMaxCooldown > 0 and AbilityCooldown > 0)
	Left.Visible = (AbilityMaxCooldown > 0 and AbilityCooldown > 0)

	Right.UIGradient.Rotation = math.clamp(CircleProgress, 0, 180)
	Left.UIGradient.Rotation = math.clamp(CircleProgress, 180, 360)
end

function updateItem(LocalMatchPlayer)

	local Role = Gameplay:getRole(LocalMatchPlayer)
	local Item = Gameplay:getItem(LocalMatchPlayer)
	
	if (not TrackingUI:GetAttribute("hide")) then
		TrackingUI.Visible = Gameplay:HasItem(LocalMatchPlayer)
	end
	
	if (not Gameplay:HasItem(LocalMatchPlayer)) then
		return
	end
	
	TrackingUI.Right.Visible = false
	TrackingUI.Left.Visible = false
	TrackingUI.Shade.Visible = false
	TrackingUI.Middle.Image = Assets.Icons.Item[Item].Texture
	TrackingUI.Middle.BackgroundColor3 = Color3.new(0,0,0)
end

function onNotificationSpawn(NotifyRole, Message)
	
	local MatchPlayers = game.ReplicatedStorage.Match.Players
	local MatchPlayer = MatchPlayers[LocalPlayer.Name]
	local Role = MatchPlayer:GetAttribute("Role")
	
	if (Role ~= NotifyRole or Notification:FindFirstChild("Current") ~= nil) then
		return
	end
	
	local NotificationClone = Notification.MessageFrame:Clone()
	NotificationClone.Name = "Current"
	NotificationClone.Parent = Notification
	NotificationClone.Message.Text = Message
	NotificationClone.Visible = true
	
	local NotificationTween = TweenService:Create(NotificationClone, TweenInfo.new(3.5), {BackgroundTransparency = 1})
	NotificationTween:Play()
	
	NotificationTween.Completed:Connect(function()
		NotificationClone:Destroy()
	end)
	
end

function updatePrompt(LocalPrompt)
	
	local InteractionTimer = Gameplay:getMatchPlayer(LocalPlayer.UserId):GetAttribute("InteractionTimer")
	local Interaction = Gameplay:getMatchPlayer(LocalPlayer.UserId):GetAttribute("Interaction")
	local lastUpdate = LocalPrompt:GetAttribute("lastUpdate") or 0
	local ActionName = LocalPrompt:GetAttribute("Action") or "ABORT"
	local Keys = LocalPrompt:GetAttribute("Keys") or "KEY|KEY"
	
	local isGamepad = UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1
	local args = string.split(Keys, "|")
	
	if (ActionName == "ABORT" or (InteractionTimer <= 0 or Interaction < 1)) then
		DisplayTime.Prompt = 0.0
		return
	end
	
	if (isGamepad) then
		Prompt.Input_Gamepad.Image = getKeyIcon(tonumber(args[1]))
		Prompt.Input_Keyboard.Visible = false
		Prompt.Input_Gamepad.Visible = true
	else
		Prompt.Input_Keyboard.Input.Text = searchKeyName(tonumber(args[2]))
		Prompt.Input_Keyboard.Visible = true
		Prompt.Input_Gamepad.Visible = false
	end
	
	Prompt.Action.Text = ActionName
	Prompt.Action.Visible = true
	DisplayTime.Prompt = 0.5 + ((LocalPlayer:GetNetworkPing() * 100) * 1.25)
	
end

function searchKeyName(KeyValue)
	local KeyCodes = Enum.KeyCode:GetEnumItems()

	for i, v in pairs(KeyCodes) do
		if (v.Value == KeyValue) then
			return v.Name
		end
	end

end

function searchKeyCode(KeyValue)
	local KeyCodes = Enum.KeyCode:GetEnumItems()

	for i, v in pairs(KeyCodes) do
		if (v.Value == KeyValue) then
			return v
		end
	end

end

function getKeyIcon(KeyValue)
	local KeyCode = searchKeyCode(KeyValue)
	return UserInputService:GetImageForKeyCode(KeyCode)
end

function updateProgress(LocalProgress)
	
	local LocalMatchPlayer = Gameplay:getMatchPlayer(LocalPlayer.UserId)
	local lastUpdate = LocalProgress:GetAttribute("lastUpdate") or 0
	
	local MaxProgress = LocalProgress:GetAttribute("Maximum") or 0
	local Progress = LocalProgress:GetAttribute("Current") or 0
	local Action = LocalProgress:GetAttribute("Action") or "ABORT"
	
	if (Action == "ABORT") then
		DisplayTime.Progress = 0.0
		return
	end
	
	IProgress.Action.Text = Action
	IProgress.Progress.Value = Progress
	IProgress.MaxProgress.Value = MaxProgress
	DisplayTime.Progress = 0.3 + ((LocalPlayer:GetNetworkPing() * 100) * 1.25)

	updateIProgress()
	
end

function updatePerks(LocalMatchPlayer)
	
	local Perks = LocalMatchPlayer:WaitForChild("Perks")
	
	if (not BaseFrame.Loadout.Perks:GetAttribute("hide")) then
		BaseFrame.Loadout.Perks.Visible = true
	end
	
	for count = 1, 3 do
		local Slot = Perks[`Slot{tostring(count)}`]
		local Cooldown = math.clamp(Slot:GetAttribute("Cooldown"), 0, math.huge) 
		local Duration = math.clamp(Slot:GetAttribute("Duration"), 0, math.huge)
		local MaxCooldown = math.clamp(Slot:GetAttribute("MaxCooldown"), 0, math.huge)
		local MaxDuration = math.clamp(Slot:GetAttribute("MaxDuration"), 0, math.huge)
		
		if (MaxCooldown == 0 and MaxDuration == 0) then
			continue
		end
		
		local UISlot = InventoryPerks[`Slot{tostring(count)}`]
		local UICooldown = UISlot.PerkImage.Cooldown
		local UIDuration = UISlot.PerkImage.Duration
		
		local GoalCooldown = {Size = UDim2.fromScale(1, 1 / MaxCooldown * Cooldown)}
		local GoalDuration = {Size = UDim2.fromScale(1, 1 / MaxDuration * Duration)}
		
		if (UICooldown:GetAttribute("Max") ~= MaxCooldown or UICooldown:GetAttribute("Current") ~= Cooldown) then
			local tween = TweenService:Create(UICooldown, TweenInfo.new(0.2), GoalCooldown)
			tween:Play()
		end
		
		if (UIDuration:GetAttribute("Max") ~= MaxCooldown or UIDuration:GetAttribute("Current") ~= Cooldown) then
			local tween = TweenService:Create(UIDuration, TweenInfo.new(0.2), GoalDuration)
			tween:Play()
		end
		
		UICooldown:SetAttribute("Max", MaxCooldown)
		UICooldown:SetAttribute("Current", Cooldown)
		
		UIDuration:SetAttribute("Max", MaxDuration)
		UIDuration:SetAttribute("Current", Duration)
		
	end
	
end

function onPowerUpdate(Attribute, Value)
	
	local Assets = game.ReplicatedStorage.Assets
	local Icons = Assets.Icons
	
	if (Attribute == "Icon") then
		if (Icons.Power:FindFirstChild(Value) ~= nil) then
			local PowerAsset : Decal = Icons.Power[Value]
			BaseFrame.Loadout.Inventory.Power.Middle.Image = PowerAsset.Texture
		end
		return
	end
	
	if (Attribute == "Perks") then
		for slot, perk in pairs(Value) do
			if (Icons.Perk:FindFirstChild(perk) ~= nil) then
				local Icon : Decal = Icons.Perk[perk]
				InventoryPerks[slot].PerkImage.Image = Icon.Texture
			end
		end
	end
end

ClientEvents.ClientTick.Event:Connect(onUpdate)
PowerUpdateEvent.OnClientEvent:Connect(onPowerUpdate)
NotificationSpawnEvent.OnClientEvent:Connect(onNotificationSpawn)

game.Players.PlayerAdded:Connect(onJoin)
game.Players.PlayerRemoving:Connect(onLeave)
