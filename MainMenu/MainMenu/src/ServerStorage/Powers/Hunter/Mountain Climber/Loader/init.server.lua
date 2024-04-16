local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local ServerTick = game.ServerStorage.Events.Game:WaitForChild("ServerTick")
local Events = game.ServerStorage.Events

local Tracker = script.Parent.Tracking
local Main = require(script.Main)
local Power = script.Parent

local LoaderPlayer = script.Parent.Parent
local DisplayTrap = script.Parent.Trap

local IgnoredSurfaces = {"Floor", "BasePlate"}
local LastCount = 0

function RunServerTick(delta)
	
	local Player = game.Players:WaitForChild(LoaderPlayer.Name)
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local Character = workspace:WaitForChild(LoaderPlayer.Name)
	local Interactables = workspace.Map.Interactables
	local RootPart = Character.HumanoidRootPart
	
	local MaxTraps = Power:GetAttribute("MaxTraps")
	local Traps = Power:GetAttribute("Traps")
	
	local TrackingCooldown = Tracker:GetAttribute("Cooldown")
	TrackingCooldown = math.clamp(TrackingCooldown - delta, 0, 999)
	Tracker:SetAttribute("Cooldown", TrackingCooldown)
	Modules.Game:setAbilityValue(MatchPlayer, "TrackingCooldown", TrackingCooldown)
	
	if (LastCount ~= Traps) then
		Modules.Game:setAbilityValue(MatchPlayer, "Amount", math.clamp(Traps, 0, MaxTraps))
		LastCount = Traps
	end
	
	if (workspace:FindFirstChild("DisplayTrap") == nil) then
		local CloneTrap = DisplayTrap:Clone()
		CloneTrap.Name = "DisplayTrap"
		CloneTrap.Parent = workspace

		local Weld = Instance.new("Weld")
		Weld.Name = "TrapWeld"
		Weld.Parent = Character

		Weld.Part0 = RootPart
		Weld.Part1 = CloneTrap
		Weld.C1 = CFrame.new(0, 4.5, 0)
		
		CloneTrap.Visibility.Parent = Player.Backpack.BasePlayer
	end
	
	local Params = OverlapParams.new()
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.FilterDescendantsInstances = {Character, workspace.DisplayTrap.Light}
	local PartsInside = workspace:GetPartsInPart(workspace.DisplayTrap, Params)
	
	if (Interactables:FindFirstChild("Traps") ~= nil) then
		for i, v in pairs(Interactables:WaitForChild("Traps"):GetChildren()) do
			local DisplayPos = workspace.DisplayTrap.Position
			local TrapPos = v.Position

			local DistX = math.abs(DisplayPos.X - TrapPos.X)
			local DistZ = math.abs(DisplayPos.Z - TrapPos.Z)

			if (DistX < 5 and DistZ < 5) then
				Power:SetAttribute("AllowPlacement", false)
				return
			end
		end
	end
	
	Power:SetAttribute("AllowPlacement", #PartsInside < 1)
	
end

function MouseClickEvent(Player, Key, Down)
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local Role = Modules.Game:getRole(MatchPlayer)
	
	if (Role == "Prey" or Player.Name ~= LoaderPlayer.Name) then
		return
	end
	
	if (Key == 2) then
		if (Down) then
			Main:performAbility(Player)
		else
			Main:cancelAbility(Player)
		end
	end
end

function InputClickEvent(Player, Key, Down)
	
	local Binds = Modules.BindStorage:get(Player.UserId)
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local Role = Modules.Game:getRole(MatchPlayer)

	if (Role == "Prey" or Player.Name ~= LoaderPlayer.Name) then
		return
	end

	if (Binds) then

		local Secondary = {Binds.Controller.SecondaryAbility, Binds.Keyboard.SecondaryAbility} 
		
		if (Key.Value == Enum.KeyCode.ButtonL2.Value) then
			if (Down) then
				Main:performAbility(Player)
			else
				Main:cancelAbility(Player)
			end
		end

		if (table.find(Secondary, Key.Value)) then
			if (Down) then
				Main:performSecondary(Player)
			else
				Main:cancelSecondary(Player)
			end
		end
	end
end

function MobileInputEvent(Player, Action, Down)
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local Role = Modules.Game:getRole(MatchPlayer)

	if (Role == "Prey" or Player.Name ~= LoaderPlayer.Name) then
		return
	end

	if (Action == "Power") then
		if (Down) then
			Main:performAbility(Player)
		else
			Main:cancelAbility(Player)
		end
	end
	
	if (Action == "Secondary") then
		if (Down) then
			Main:performSecondary(Player)
		else
			Main:cancelSecondary(Player)
		end
	end
	
end

Events.Game.ServerTick.Event:Connect(RunServerTick)
Events.onMouseClick.Event:Connect(MouseClickEvent)
Events.onInputClick.Event:Connect(InputClickEvent)
Events.onMobileInput.Event:Connect(MobileInputEvent)