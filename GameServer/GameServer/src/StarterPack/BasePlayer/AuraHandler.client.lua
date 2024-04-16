local AlertEvent = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AlertEvent")
local AuraEvent = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AuraEvent")
local Prefabs = game.ReplicatedStorage.Prefabs

local Remotes = game.ReplicatedStorage.Remotes
local Profile = nil

local AuraObjects = {
	--["BigDoors"] = "Door",
	--["Gaps"] = "SlideObject"
}

AlertEvent.OnClientEvent:Connect(function(Type, Identifier)
	
	if (game.ReplicatedStorage:FindFirstChild("Match") == nil or workspace:FindFirstChild("Map") == nil) then
		return
	end
	
	local PWorkspace = game.Workspace
	local Interactables = workspace:FindFirstChild("Map").Interactables
	
	if (Type == "Player") then
		if (PWorkspace:FindFirstChild(Identifier) ~= nil) then
			local Parent = PWorkspace:FindFirstChild(Identifier)
			
			if (Parent:FindFirstChild("Alert") ~= nil) then
				return
			end
			
			createAlert(Parent)
		end
	end

	if (Interactables:FindFirstChild(Type)) then
		if (Interactables[Type]:FindFirstChild(Identifier) ~= nil) then
			local Parent = Interactables[Type]:FindFirstChild(Identifier)

			if (AuraObjects[Type] ~= nil) then
				local AuraObject = AuraObjects[Type]
				Parent = Parent[AuraObject]
			end

			if (Parent:FindFirstChild("Alert") ~= nil) then
				return
			end

			createAlert(Parent)
		end
	end
	
end)

AuraEvent.OnClientEvent:Connect(function(Action, Type, Identifier, Restricted, TimeLimit, Color, BorderColor, Name, isOutline)
	
	if (game.ReplicatedStorage:FindFirstChild("Match") == nil or workspace:FindFirstChild("Map") == nil) then
		return
	end
	
	local PWorkspace = game.Workspace
	local Interactables = workspace:FindFirstChild("Map").Interactables
	
	if (Action == "Create") then
		if (Type == "Player") then
			if (PWorkspace:FindFirstChild(Identifier) ~= nil) then
				local Parent = PWorkspace:FindFirstChild(Identifier)
				
				if (not Parent:FindFirstChild(Name)) then
					if (not isOutline) then
						createAura(Parent, Restricted, TimeLimit, Color, BorderColor, Name)
					else
						createOutline(Parent, Restricted, TimeLimit, Color, BorderColor, Name)
					end
				end
			end
		end
	
		if (Interactables:FindFirstChild(Type)) then
			if (Interactables[Type]:FindFirstChild(Identifier) ~= nil) then
				local Parent = Interactables[Type]:FindFirstChild(Identifier)
				
				if (AuraObjects[Type] ~= nil) then
					local AuraObject = AuraObjects[Type]
					Parent = Parent[AuraObject]
				end
			
				if (not Parent:FindFirstChild(Name)) then
					createAura(Parent, Restricted, TimeLimit, Color, BorderColor, Name)
				end
			end
		end
	end
	
	if (Action == "Remove") then
		if (Type == "Player") then
			if (PWorkspace:FindFirstChild(Identifier) ~= nil) then
				local Parent = PWorkspace:FindFirstChild(Identifier)

				if (Parent:FindFirstChild(Name)) then
					removeAura(Parent, Name)
				end
			end
		end

		if (Interactables:FindFirstChild(Type)) then
			if (Interactables[Type]:FindFirstChild(Identifier) ~= nil) then
				local Parent = Interactables[Type]:FindFirstChild(Identifier)
				
				if (AuraObjects[Type] ~= nil) then
					local AuraObject = AuraObjects[Type]
					Parent = Parent[AuraObject]
				end

				if (Parent:FindFirstChild(Name)) then
					removeAura(Parent, Name)
				end
			end
		end
	end
	
end)

function createAura(Parent, Restricted, TimeLimit, Color, BorderColor, Name)
	
	if (Restricted) then
		local Aura = Prefabs:WaitForChild("AuraRestricted"):Clone()
		local Timer = require(Aura.Timer)
		Aura:SetAttribute("Timer", TimeLimit)
		
		Aura.Name = Name
		Aura.Enabled = true
		Aura.Parent = Parent
		Aura.FillColor = Color
		Aura.OutlineColor = BorderColor
	else
		local Aura = Prefabs:WaitForChild("AuraUnrestricted"):Clone()
		
		Aura.Name = Name
		Aura.Enabled = true
		Aura.Parent = Parent
		Aura.FillColor = Color
		Aura.OutlineColor = BorderColor
	end
end

function createOutline(Parent, Restricted, TimeLimit, Color, BorderColor, Name)

	if (Restricted) then
		local Aura = Prefabs:WaitForChild("OutlineRestricted"):Clone()
		local Timer = require(Aura.Timer)
		Aura:SetAttribute("Timer", TimeLimit)

		Aura.Name = Name
		Aura.Enabled = true
		Aura.Parent = Parent
		Aura.FillColor = Color
		Aura.OutlineColor = BorderColor
	else
		local Aura = Prefabs:WaitForChild("OutlineUnrestricted"):Clone()

		Aura.Name = Name
		Aura.Enabled = true
		Aura.Parent = Parent
		Aura.FillColor = Color
		Aura.OutlineColor = BorderColor
	end
end

function createAlert(Parent)

	local Alert = Prefabs:WaitForChild("Alert"):Clone()
	local Timer = require(Alert.Timer)
	
	Alert.Name = "Alert"
	Alert.Enabled = true
	Alert.Parent = Parent
	
	if (Profile == nil) then
		Profile = Remotes.RequestData:InvokeServer("Profile")
	end
	
	local AlertSound = script.Alert
	AlertSound.Volume = (7 / 100) * Profile.Account.Settings["Game Volume"]
	AlertSound:Play()
	
	local tween = game.TweenService:Create(Alert.ImageLabel, TweenInfo.new(1.2), {BackgroundTransparency = 0.7, ImageTransparency = 0.25})
	tween:Play()
	
end

function removeAura(Parent, Name)
	
	if (Parent:FindFirstChild(Name)) then
		local Aura = Parent:FindFirstChild(Name)
		
		if (Aura:isA("Highlight")) then
			Aura:Destroy()
		end
	end
	
end
