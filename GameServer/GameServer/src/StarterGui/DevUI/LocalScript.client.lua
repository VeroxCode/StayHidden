local GameUI = game.Players.LocalPlayer.PlayerGui.GameUI
local Buttons = script.Parent.BaseFrame.Frame.ScrollingFrame

game.UserInputService.InputBegan:Connect(function(InputObject, Processed)
	
	if (InputObject.KeyCode.Value == Enum.KeyCode.O.Value) then
		script.Parent.Enabled = not script.Parent.Enabled
	end
	
end)

Buttons.Players.CheckBox.MouseButton1Click:Connect(function()
	local Players = GameUI.BaseFrame.Players
	
	for i, v in pairs(Players:GetChildren()) do
		if (v.Visible) then
			v.Visible = false
		elseif (v.Name ~= "Empty") then
			v.Visible = true
		end
	end
end)

Buttons.ExtractionProgress.CheckBox.MouseButton1Click:Connect(function()
	local ExtractionProgress = GameUI.BaseFrame.Objective.ExtractionProgress

	ExtractionProgress:SetAttribute("hide", not ExtractionProgress:GetAttribute("hide"))
	ExtractionProgress.Visible = not ExtractionProgress.Visible
end)

Buttons.Inventory.CheckBox.MouseButton1Click:Connect(function()
	local Inventory = GameUI.BaseFrame.Objective.Inventory

	Inventory:SetAttribute("hide", not Inventory:GetAttribute("hide"))
	Inventory.Visible = not Inventory.Visible
end)

Buttons.Ability.CheckBox.MouseButton1Click:Connect(function()
	local Inventory = GameUI.BaseFrame.Loadout.Inventory.Power

	Inventory:SetAttribute("hide", not Inventory:GetAttribute("hide"))
	Inventory.Visible = not Inventory.Visible
end)

Buttons.Perks.CheckBox.MouseButton1Click:Connect(function()
	local Inventory = GameUI.BaseFrame.Loadout.Perks

	Inventory:SetAttribute("hide", not Inventory:GetAttribute("hide"))
	Inventory.Visible = not Inventory.Visible
end)

Buttons.Effects.CheckBox.MouseButton1Click:Connect(function()
	local Inventory = GameUI.BaseFrame.StatusEffects.MainFrame

	Inventory:SetAttribute("hide", not Inventory:GetAttribute("hide"))
	Inventory.Visible = not Inventory.Visible
end)

Buttons["Item/Tracking"].CheckBox.MouseButton1Click:Connect(function()
	local Inventory = GameUI.BaseFrame.Loadout.Inventory.Tracking

	Inventory:SetAttribute("hide", not Inventory:GetAttribute("hide"))
	Inventory.Visible = not Inventory.Visible
end)