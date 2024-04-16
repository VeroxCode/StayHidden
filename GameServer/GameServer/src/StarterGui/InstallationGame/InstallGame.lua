local AbortInstallation = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AbortInstallation")
local CycleComplete = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CycleComplete")
local InstallationUI = game.Players.LocalPlayer.PlayerGui.InstallationGame
local LocalPlayer = game.Players.LocalPlayer

local last = 0

local ParentFrame = InstallationUI.Frame
local Prefabs = InstallationUI.Prefabs

local Colors = {
	Inactive = Color3.new(0.239216, 0.239216, 0.239216),
	Active = Color3.new(0, 1, 0.368627)
}

local this = {}

function this:spawn(Extractor)
	
	if (ParentFrame:GetAttribute("initialized")) then
		return
	end
	
	this:create_nodes()
	this:activateRandom()
	ParentFrame:SetAttribute("initialized", true)
	InstallationUI.Enabled = true
	setMouseLock(false)
	
end

function this:despawn()

	InstallationUI.Enabled = false
	this:resetAll()
	
	task.wait(0.25)
	setMouseLock(true)

end

function this:abort()
	
	if (this:getExtractorID() <= 0) then
		return
	end
	
	AbortInstallation:FireServer(this:getExtractorID())
	this:despawn()
	
end

function setMouseLock(bool)
	local BasePlayer = LocalPlayer.Backpack.BasePlayer
	BasePlayer:SetAttribute("MouseLock", bool)
end

function this:create_nodes()
	for i, v in pairs(ParentFrame:GetChildren()) do
		if (v:GetAttribute("init")) then continue end
		
		if (v:isA("TextButton")) then
			v.BackgroundColor3 = Colors.Inactive
			v.Parent = ParentFrame
			v:SetAttribute("init", true)
			v.MouseButton1Click:Connect(function()
				
				local time = tick()
				if (math.abs(time - last) < 0.1) then
					return
				end
				
				last = time
				CycleComplete:FireServer(this:getExtractorID(), (tonumber(v.Name) == ParentFrame:GetAttribute("Active")), time)
				this:activateRandom()
			end)
		end
	end
end

function this:activateRandom()
	
	this:resetAll()
	local random = math.random(1, 9)
	local GameFrame = ParentFrame[random]
	
	if (random == ParentFrame:GetAttribute("Active")) then
		this:activateRandom()
		return
	end
	
	GameFrame.BackgroundColor3 = Colors.Active
	ParentFrame:SetAttribute("Active", random)
	
end

function this:resetAll()

	for count = 1, 9 do
		local GameFrame = ParentFrame[count]
		GameFrame.BackgroundColor3 = Colors.Inactive
	end
	ParentFrame:SetAttribute("Active", 0)
	ParentFrame:SetAttribute("Extractor", 0)
	ParentFrame:SetAttribute("initialized", false)
end

function this:getExtractorID()
	local MatchPlayer = game.ReplicatedStorage.Match.Players[LocalPlayer.Name]
	local ExtractorID = MatchPlayer:GetAttribute("Extractor")
	return ExtractorID
end

function this:isInitialized()
	return ParentFrame:GetAttribute("initialized")
end

return this
