local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Players = game.Players
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Remotes = game.ReplicatedStorage.Remotes

local ReleaseInput = {
	Enum.UserInputType.MouseButton1,
	Enum.UserInputType.Touch,
}

local ToBind = {
	Keyboard = "",
	Controller = ""
}

local toSave = {}

local ActiveSlider = nil

local this = {}

function this:prepareSettings()
	this:prepareBinds()
end

function this:clearActions()
	ToBind = {
		Keyboard = "",
		Controller = ""
	}
end

function this:clearBinds()
	
	local Options = LocalPlayer.PlayerGui.Options.BaseFrame
	local BindList = Options.Screen.Controls.Binds
	
	for i, v in pairs(BindList:GetChildren()) do
		if (v:isA("Frame")) then
			v:Destroy()
		end
	end
	
end

function this:showSettings(General, Controls, Match)
	local Options = LocalPlayer.PlayerGui:WaitForChild("Options").BaseFrame
	Options.Screen.General.Visible = General
	Options.Screen.Controls.Visible = Controls
	Options.Screen.Match.Visible = Match
end

function this:prepareBinds()
	
	this:clearBinds()
	
	local Binds = Remotes.RequestData:InvokeServer("Binds")
	local Options = LocalPlayer.PlayerGui.Options.BaseFrame
	local BindList = Options.Screen.Controls.Binds
	local Prefab = Options.Screen.Controls.BindPrefab
	
	for action, key in pairs(Binds.Keyboard) do
		if (BindList:FindFirstChild(action) == nil) then
			local Clone = Prefab:Clone()
			Clone.Name = action
			Clone.Action.Text = action
			Clone.Keyboard.KeyName.Text = searchKeyName(Binds["Keyboard"][action])
			Clone.Gamepad.Image = getKeyIcon(Binds["Controller"][action])
			Clone.Visible = true
			Clone.Parent = BindList
			
			Clone.Keyboard.MouseButton1Click:Connect(function()
				prepareBinding("Keyboard", Clone.Keyboard, action)
			end)
			
			Clone.Gamepad.MouseButton1Click:Connect(function()
				prepareBinding("Controller", Clone.Gamepad, action)
			end)
		end
	end
end

function this:prepareGeneral()
	
	local Profile = Remotes.RequestData:InvokeServer("Profile")
	local Settings = Profile.Account.Settings
	local Options = LocalPlayer.PlayerGui.Options.BaseFrame
	local SettingList = Options.Screen.General.List
	
	for key, value in pairs(Settings) do
		
		if (SettingList:FindFirstChild(key) == nil) then continue end
		
		local CurrentSetting = SettingList:FindFirstChild(key)
		
		if (type(value) == "boolean") then
			setToggleValue(CurrentSetting, value)
			
			CurrentSetting.Box.Toggle.MouseButton1Click:Connect(function()
				setToggleValue(CurrentSetting, not CurrentSetting:GetAttribute("Value"))
			end)
			
		end
		
		if (type(value) == "number") then
			setSliderValue(CurrentSetting, value)
			
			CurrentSetting.Slider.Progress.DragPoint.MouseButton1Down:Connect(function()
				if (ActiveSlider ~= nil) then
					return
				end
				
				ActiveSlider = RunService.RenderStepped:Connect(function(delta)
					setSliderValue(CurrentSetting, nil)
				end)
			end)
		end
	end
end

function this:SaveSettings()
	Remotes.updateSettings:InvokeServer(toSave)
	toSave = {}
end

function setToggleValue(CurrentSetting, Value)
	CurrentSetting.Box.Toggle.TextTransparency = if (Value) then 0 else 1
	CurrentSetting:SetAttribute("Value", Value)
end

function setSliderValue(CurrentSetting, Value)
	
	local min, max = CurrentSetting:GetAttribute("Min"), CurrentSetting:GetAttribute("Max")
	
	if (Value == nil) then
		local NewSize = ((Mouse.X - CurrentSetting.Slider.AbsolutePosition.X) / CurrentSetting.Slider.AbsoluteSize.X)
		NewSize = math.clamp(NewSize, 0, 1)
		Value = min + NewSize * (max - min)
		
		
		CurrentSetting.Slider.Progress.Size = UDim2.fromScale(NewSize, 1)
		CurrentSetting.Slider.SliderValue.Text = tostring(math.round(Value))
		CurrentSetting.Slider.Progress.DragPoint.Position = UDim2.fromScale(1, 0.5)
		CurrentSetting.Slider.SliderValue.Text = tostring(math.round(Value))
		CurrentSetting:SetAttribute("Value", math.round(Value))
	else
		local ScaleValue = (Value - min) / (max - min)
		ScaleValue = math.clamp(ScaleValue, 0, 1)
		
		CurrentSetting.Slider.Progress.Size = UDim2.fromScale(ScaleValue, 1)
		CurrentSetting.Slider.SliderValue.Text = tostring(math.round(Value))
		CurrentSetting.Slider.Progress.DragPoint.Position = UDim2.fromScale(1, 0.5)
		CurrentSetting.Slider.SliderValue.Text = tostring(math.round(Value))
		CurrentSetting:SetAttribute("Value", math.round(Value))
	end
end

function bindKey(Input)
	
	local InputType = Input.UserInputType.Name
	
	if (string.find(InputType, "Keyboard")) then
		if (ToBind.Keyboard == "") then
			return
		end
		
		updateBind("Keyboard", ToBind.Keyboard, Input.KeyCode.Value)
		ToBind.Keyboard = ""
	end
	
	if (string.find(InputType, "Controller")) then
		if (ToBind.Controller == "") then
			return
		end

		updateBind("Controller", ToBind.Controller, Input.KeyCode.Value)
		ToBind.Controller = ""
	end
	
end

function updateBind(InputType, Action, Key)
	
	if (InputType == "Controller") then
		Remotes.updateBind:InvokeServer("Controller", ToBind.Controller, Key)
	end
	
	if (InputType == "Keyboard") then
		Remotes.updateBind:InvokeServer("Keyboard", ToBind.Keyboard, Key)
	end
	
	local Options = LocalPlayer.PlayerGui.Options.BaseFrame
	local BindList = Options.Screen.Controls.Binds
	
	if (InputType ~= "Keyboard") then
		BindList[Action][InputType].Image = getKeyIcon(Key)
		BindList[Action][InputType].Parent["Wait_Controller"].Visible = false
		BindList[Action][InputType].Parent["Wait_Keyboard"].Visible = false
	else
		BindList[Action][InputType].KeyName.Visible = true
		BindList[Action][InputType].KeyName.Text = searchKeyName(Key)
		BindList[Action][InputType].Image = "rbxassetid://16326358135"
		BindList[Action][InputType].Parent["Wait_Controller"].Visible = false
		BindList[Action][InputType].Parent["Wait_Keyboard"].Visible = false
	end
	
	
end

function prepareBinding(InputType, InputButton, Action)
	
	if (ToBind[InputType] ~= "") then
		return
	end
	
	ToBind[InputType] = Action
	InputButton.Parent[`Wait_{InputType}`].Visible = true
	
	if (InputType == "Keyboard") then
		InputButton.KeyName.Visible = false
	end
	
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

function onInputEnd(Input)
	
	local Options = LocalPlayer.PlayerGui.Options.BaseFrame
	local SettingList = Options.Screen.General.List
	
	if (not Options.Parent.Enabled) then
		return
	end
	
	if (table.find(ReleaseInput, Input.UserInputType)) then
		if (ActiveSlider ~= nil) then
			ActiveSlider:Disconnect()
			ActiveSlider = nil
		end
	end
	
	if (Input.KeyCode == Enum.KeyCode.ButtonA) then
		if (ActiveSlider ~= nil) then
			ActiveSlider:Disconnect()
			ActiveSlider = nil
		end
	end

	for i, v in pairs(SettingList:GetChildren()) do
		if (not v:isA("Frame")) then continue end
		toSave[v.Name] = {}
		toSave[v.Name] = v:GetAttribute("Value")
	end
	
end

UserInputService.InputEnded:Connect(onInputEnd)
UserInputService.InputBegan:Connect(bindKey)

return this
