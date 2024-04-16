local Modules = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Module Manager")).Modules
local AnimationEvent = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AnimationEvent")
local OnHealthUpdate = game.ServerStorage.Events.Prey:WaitForChild("onHealthUpdate")
local ServerTick = game.ServerStorage.Events.Game:WaitForChild("ServerTick")
local onAttack = game.ServerStorage.Events.Hunter:WaitForChild("onAttack")

local Players = game:GetService("Players")
local Actions = Modules.Actions
local Assets = game.ReplicatedStorage.Assets

local this = {}

local ActionData = {
	RequiredAction = Actions.List.ATTACK,
	RequiresAction = true,
	Role = "Hunter",
	Reach = {
		["XZ"] = 10,
		["Y"] = 6
	}
}

function this:performAction(PlayerID, Target)
	
	if (not Modules.Game:isRunning() or Modules.Game:getMatchTimer() < 1) then
		return
	end
	
	local GamePlayer = Players:GetPlayerByUserId(PlayerID)
	local MatchPlayer = Modules.Game:getMatchPlayer(PlayerID)
	local GameTarget = Players:GetPlayerFromCharacter(Target)
	local MatchTarget = Modules.Game:getMatchPlayer(GameTarget.UserId)
	
	local RootPlayer = GamePlayer.Character:WaitForChild("HumanoidRootPart").CFrame.Position
	local RootTarget = Target:WaitForChild("HumanoidRootPart").CFrame.Position
	
	local DistanceXZ = math.abs(Vector3.new(RootPlayer.X, 0, RootPlayer.Z).Magnitude - Vector3.new(RootTarget.X, 0, RootTarget.Z).Magnitude)
	local DistanceY = math.abs(RootPlayer.Y - RootTarget.Y)
	
	local hurtBoost = MatchTarget.Values:GetAttribute("HurtBoost")
	local recoveryTime = MatchPlayer.Values:GetAttribute("RecoveryTime")
	local hasVulnerability = Modules.Game:hasEffect(MatchTarget, "Vulnerable")
	
	local RawDamage = Modules.Game:getDamage(MatchPlayer)
	RawDamage = if (hasVulnerability) then RawDamage * 1.5 else RawDamage
	
	if (Modules.Game:getRole(MatchTarget) == "Prey" and Modules.Game:getRole(MatchPlayer) == "Hunter") then
		if (Modules.Game:isVulnerable(MatchTarget)) then
			
			if (DistanceXZ <= ActionData.Reach.XZ and DistanceY <= ActionData.Reach.Y) then
				Modules.Game:setVulnerable(MatchTarget, false)
				Modules.Game:setLastAttack(MatchTarget, os.time())
				Modules.Game:applyDamage(GameTarget, RawDamage)
				Modules.Game:applyTimedEffect(MatchTarget, "FreshWound", 25)
				
				Modules.Game:setAnimationAction(MatchPlayer, "Recovery")
				Modules.Speed:removeMultiplier(MatchPlayer, "Attack")
				Modules.Speed:addMultiplier(MatchTarget, "HurtBoost", Modules.Speed.Modifiers.Prey.Hurt, hurtBoost)
				Modules.Speed:addMultiplier(MatchPlayer, "Recovery", Modules.Speed.Modifiers.Hunter.Recovery, recoveryTime)
				Modules.Credits:increaseCredits(PlayerID, (Modules.Game_Values.ScoreEvents.Hunter.PreyAttacked))
				onAttack:Fire(GameTarget)
			end
			
			wait(recoveryTime)
			Modules.Game:setAnimationAction(MatchPlayer, "Run")
			Modules.Game:setAttackKey(MatchPlayer, "Empty")
			Actions:setAction(PlayerID, Actions.List.IDLE)
		end
	end
	return
end


function this:getRequiredActionID()
	return ActionData.RequiredAction
end

function this:getNeededRole()
	return ActionData.Role
end

function this:RequiresAction()
	return ActionData.RequiresAction
end

return this
