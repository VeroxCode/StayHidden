local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local EffectApplied = game.ServerStorage.Events.Game:WaitForChild("EffectApplied")
local EffectExpired = game.ServerStorage.Events.Game:WaitForChild("EffectExpired")
local ServerTick = game.ServerStorage.Events.Game:WaitForChild("ServerTick")
local Players = game:GetService("Players")

ServerTick.Event:Connect(function(delta)
	
	if (game.ReplicatedStorage:FindFirstChild("Match")) then
		local MatchPlayers = game.ReplicatedStorage.Match.Players
	
		for i, Player in pairs(Players:GetPlayers()) do
			if (MatchPlayers:FindFirstChild(Player.Name)) then
				
				local MatchPlayer = MatchPlayers[Player.Name]
				
				for i, v in pairs(Modules.Game:getEffects(MatchPlayer):getChildren()) do
					if (v:GetAttribute("Timer") ~= nil) then
						if (v:GetAttribute("Active")) then
							local newTimer = math.clamp((v:GetAttribute("Timer") - delta), 0, math.huge) 
							v:SetAttribute("Timer", newTimer)
							if (newTimer == 0) then
								v:SetAttribute("Active", false)
								EffectExpired:Fire(Player, v)
							end
						end
					end
				end
			end
		end
	end
end)

function onEffectExpired(Player, Effect)
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local EffectTimer = Modules.Game:getEffect(MatchPlayer, tostring(Effect), "Timer")
	
	if (EffectTimer ~= nil) then
		if (EffectTimer > 0.1) then
			return
		end
	end
	
	if (tostring(Effect) == "Slowdown") then
		Modules.Speed:removeMultiplier(MatchPlayer, "Slowdown")
	end
	
	if (tostring(Effect) == "Swiftness") then
		Modules.Speed:removeMultiplier(MatchPlayer, "Swiftness")
	end
end

function onEffectApplied(Player, Effect)
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	
	if (Effect == "Slowdown") then
		local SlowdownMultiplier = Modules.Game:getEffect(MatchPlayer, "Slowdown", "Value")
		Modules.Speed:addMultiplier(MatchPlayer, "Slowdown", SlowdownMultiplier, 0)
	end
	
	if (Effect == "Swiftness") then
		local SwiftnessMultiplier = Modules.Game:getEffect(MatchPlayer, "Swiftness", "Value")
		
		if (Modules.Speed:getMultiplier(Player.UserId) <= SwiftnessMultiplier) then
			Modules.Speed:addMultiplier(MatchPlayer, "Swiftness", SwiftnessMultiplier, 0)
		end
	end
	
	if (Effect == "Protection") then
		local AuraDuration = Modules.Game:getEffect(MatchPlayer, "Protection", "Timer")
		Modules.Game:setVulnerable(MatchPlayer, false)
		
		for i, v in pairs(Players:GetPlayers()) do
			Modules.AuraManager:createOutline(v, "Player", Player.Name, true, AuraDuration, Color3.new(1, 1, 0), "Protection")
		end
	end
	
end

EffectExpired.Event:Connect(onEffectExpired)
EffectApplied.Event:Connect(onEffectApplied)