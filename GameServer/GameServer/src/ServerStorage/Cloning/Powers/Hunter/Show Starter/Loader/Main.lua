local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local LoaderPlayer : Player = script.Parent.Parent.Parent
local Events = game.ServerStorage.Events.Hunter
local Power = script.Parent.Parent
local Orb = Power.Orb

local AnimTrack = nil
local Animation = "rbxassetid://16318168262"
local Runner = nil

local this = {}

local Data = {
}

function this:initialize()
	print("initialize " .. LoaderPlayer.Name)
	
	local Player = game.Players:WaitForChild(LoaderPlayer.Name)
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local Role = Modules.Game:getRole(MatchPlayer)

	local SaveState = Modules.SaveStorage:get(Player.UserId)
	local Selected = SaveState[Role].Selected 
	local Perks = SaveState[Role][Selected].LoadOut.Modifiers

	for i, v in pairs(Perks) do
		if (v ~= "") then
			local Modifiers = game.ServerStorage.Modifiers[Role][Selected]
			local Modifier = Modifiers[v]:Clone()
			Modifier.Name = v
			Modifier.Parent = Power.Loader

			local Module = require(Modifier.Module)
			Module:apply()
		end
	end
	
	local Character = workspace[LoaderPlayer.Name]
	
	local Anim = Instance.new("Animation")
	Anim.Name = Animation
	Anim.AnimationId = Animation
	Anim.Parent = script

	AnimTrack = Character.Humanoid:LoadAnimation(Anim)
	
end

function this:performAbility(Player)
	
	if ((Modules.Actions:getAction(Player.UserId) == Modules.Actions.List.IDLE or Modules.Actions:getAction(Player.UserId) == Modules.Actions.List.ABILITY) == false or workspace:FindFirstChild("Orb") ~= nil) then
		return
	end
	
	local MatchPlayer = Modules.Game:getMatchPlayer(Player.UserId)
	local Character = workspace[MatchPlayer.Name]
	
	Modules.Actions:setAction(Player.UserId, Modules.Actions.List.ABILITY)
	Modules.Speed:addMultiplier(MatchPlayer, "Ability", Power:GetAttribute("Slowdown"), Power:GetAttribute("SlowdownDuration"))
	
	AnimTrack:Play(0, 1, 1.55)
	
	local NewOrb = Orb:Clone()
	NewOrb.Parent = workspace
	
	Runner = Events.Parent.Game.ServerTick.Event:Connect(function(delta)
		local LeftHand = Character.LeftHand.CFrame
		NewOrb.CFrame = CFrame.new(Vector3.new(LeftHand.Position.X, LeftHand.Position.Y + 0.5, LeftHand.Position.Z))
	
		AnimTrack.Ended:Connect(function()
			
			if (Runner ~= nil) then
				Runner:Disconnect()
				Runner = nil
			end
			
			local OrbTween = game.TweenService:Create(NewOrb, TweenInfo.new(2), {Size = Power:GetAttribute("OrbRadius")})
			OrbTween:Play()
					
			Modules.Actions:setAction(Player.UserId, Modules.Actions.List.IDLE)
			
			OrbTween.Completed:Connect(function()
				Events.RadiusUpdate:Fire("Deployed")
				NewOrb:SetAttribute("Lifetime", Power:GetAttribute("OrbLifetime"))
				NewOrb:SetAttribute("Deployed", true)
				
			end)
		end)
	end)
end

function adjustOrb(Orb, Position)
	
end

function this:cancelAbility(Player)
end

function this:performSecondary(Player)
end

function this:cancelSecondary(Player)
end

return this
