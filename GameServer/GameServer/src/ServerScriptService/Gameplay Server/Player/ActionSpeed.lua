local GameFS = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Utils"):WaitForChild("Game Functions"))

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Events = game.ServerStorage.Events

local List = {}
local Runner = nil

local this = {}

function this:getMultiplier(PlayerId)

	local Player = Players:GetPlayerByUserId(PlayerId)
	local MatchPlayer = game.ReplicatedStorage.Match.Players[Player.Name]

	if (Player ~= nil) then
		return MatchPlayer.Values:GetAttribute("SpeedMultiplier")
	end
end

function this:startRunner()
	
	if (Runner ~= nil) then
		return
	end
	
	Runner = Events.Game.ServerTick.Event:Connect(function(delta)
		
		local MatchPlayers = GameFS:getMatchPlayers()
		
		for index, MatchPlayer in pairs(MatchPlayers) do
			local Role = GameFS:getRole(MatchPlayer)
			local defaultSpeed = 1.0
			
			tickTimers(MatchPlayer, List[MatchPlayer.Name].Speeds, List[MatchPlayer.Name].Multipliers, delta)
			
			local calcSpeed = calcSpeed(defaultSpeed, List[MatchPlayer.Name].Speeds)
			local calcMultiplier = getFinalMultiplier(List[MatchPlayer.Name].Multipliers)
			local finalSpeed = calcFinalSpeed(calcSpeed, List[MatchPlayer.Name].Multipliers)
			
			MatchPlayer.Values:SetAttribute("ActionSpeed", finalSpeed)
		end
	end)
end

function tickTimers(MatchPlayer, Speeds, Multipliers, delta)
	
	if (Speeds == nil or Multipliers == nil) then
		return
	end
	
	local Speeds = Speeds.Restricted
	local Multipliers = Multipliers.Restricted

	for name, data in pairs(Speeds) do
		data.Length -= delta
		
		if (data.Length <= 0) then
			List[MatchPlayer.Name].Speeds.Restricted[name] = nil
		else
			List[MatchPlayer.Name].Speeds.Restricted[name] = data
		end
	end
	
	for name, data in pairs(Multipliers) do
		data.Length -= delta

		if (data.Length <= 0) then
			List[MatchPlayer.Name].Multipliers.Restricted[name] = nil
		else
			List[MatchPlayer.Name].Multipliers.Restricted[name] = data
		end
	end
	
end

function calcSpeed(defaultSpeed, Speeds)
	
	local Restricted = Speeds.Restricted
	local Unrestricted = Speeds.Unrestricted
	
	for name, data in pairs(Unrestricted) do
		defaultSpeed += data.Value
	end
	
	for name, data in pairs(Restricted) do
		if (data.Length > 0) then
			defaultSpeed += data.Value
		end
	end
	
	return defaultSpeed
end

function getFinalMultiplier(Multipliers)
	
	local finalMultiplier = 1
	local Restricted = Multipliers.Restricted
	local Unrestricted = Multipliers.Unrestricted

	for name, data in pairs(Unrestricted) do
		finalMultiplier += data.Value

		if (data.Value == 0) then
			return 0
		end

	end

	for name, data in pairs(Restricted) do
		if (data.Length > 0) then
			finalMultiplier += data.Value

			if (data.Value == 0) then
				return 0
			end

		end
	end

	return finalMultiplier
end

function calcFinalSpeed(calcSpeed, Multipliers)
	
	local finalMultiplier = 1
	local Restricted = Multipliers.Restricted
	local Unrestricted = Multipliers.Unrestricted

	for name, data in pairs(Unrestricted) do
		finalMultiplier += data.Value
		
		if (data.Value == 0) then
			return 0
		end
		
	end

	for name, data in pairs(Restricted) do
		if (data.Length > 0) then
			finalMultiplier += data.Value
			
			if (data.Value == 0) then
				return 0
			end
			
		end
	end

	return (calcSpeed * finalMultiplier)
end

function this:addToList(Name)
	List[Name] = {
		Speeds = {
			Restricted = {};
			Unrestricted = {};
		};
		Multipliers = {
			Restricted = {};
			Unrestricted = {};
		};
	}
end

function this:addSpeed(MatchPlayer, EffectName, Amount, Time)
	
	if (List[MatchPlayer.Name] ~= nil) then
		local NewEntry = {
			Value = Amount;
			Length = Time;
		}
		
		if (Time > 0) then
			List[MatchPlayer.Name]["Speeds"]["Restricted"][EffectName] = NewEntry
		else
			List[MatchPlayer.Name]["Speeds"]["Unrestricted"][EffectName] = NewEntry
		end
	end
	
end

function this:removeSpeed(MatchPlayer, EffectName)
	if (List[MatchPlayer.Name] ~= nil) then
		if (List[MatchPlayer.Name]["Speeds"]["Unrestricted"][EffectName] ~= nil) then
			List[MatchPlayer.Name]["Speeds"]["Unrestricted"][EffectName] = nil
		end
	end
end

function this:addMultiplier(MatchPlayer, EffectName, Amount, Time)
	
	if (List[MatchPlayer.Name] ~= nil) then
		local NewEntry = {
			Value = Amount;
			Length = Time;
		}

		if (Time > 0) then
			List[MatchPlayer.Name]["Multipliers"]["Restricted"][EffectName] = NewEntry
		else
			List[MatchPlayer.Name]["Multipliers"]["Unrestricted"][EffectName] = NewEntry
		end
	end

end

function this:removeMultiplier(MatchPlayer, EffectName)
	if (List[MatchPlayer.Name] ~= nil) then
		if (List[MatchPlayer.Name]["Multipliers"]["Unrestricted"][EffectName] ~= nil) then
			List[MatchPlayer.Name]["Multipliers"]["Unrestricted"][EffectName] = nil
		end
	end
end

return this
