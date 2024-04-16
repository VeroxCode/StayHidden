local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Remotes = game.ReplicatedStorage.Remotes
local BaseLine = script.Parent.BaseFrame.BaseLine
local SuccessZone = BaseLine.SuccessZone
local Needle = BaseLine.Needle

local PlayerGui = game.Players.LocalPlayer.PlayerGui
local MobileControls = PlayerGui.MobileControls.Prey
local SCButton = MobileControls.SkillCheck

local Binds = nil
local Profile = nil
local isRunning = false
local MobileInput
local InputRunner
local Runner

local SkillCheck = {}
local Sounds = {
	Notify = script.Notify,
	Success = script.Success,
	Fail = script.Fail
}

function SkillCheck:spawnSkillCheck(Speed, SuccessSize, ID)
	
	if (isRunning) then
		return
	end
	
	isRunning = true
	BaseLine.Parent.Parent.Enabled = true
	
	local RandomPosition = 1 - SuccessZone.Size.X.Scale
	RandomPosition = math.random(30, RandomPosition * 100)
	
	SuccessZone.Size = UDim2.fromScale((1 / 100) * SuccessSize ,5)
	SuccessZone.Position = UDim2.fromScale(RandomPosition / 100, 0.5)
	Needle.Position = UDim2.fromScale(0, 0.5)
	
	if (Binds == nil or Profile == nil) then
		Binds = Remotes.RequestData:InvokeServer("Binds")
		Profile = Remotes.RequestData:InvokeServer("Profile")
		
		Sounds.Notify.Volume = (0.75 / 100) * Profile.Account.Settings["Game Volume"]
		Sounds.Fail.Volume = (1 / 100) * Profile.Account.Settings["Game Volume"]
		Sounds.Success.Volume = (1 / 100) * Profile.Account.Settings["Game Volume"]
	end
	
	Sounds.Notify:Play()
	task.wait(1)
	
	SCButton.Visible = true
	
	InputRunner = UIS.InputBegan:Connect(function(obj)
		
		if (obj.KeyCode.Value ~= Binds.Keyboard.Actions and obj.KeyCode.Value ~= Binds.Controller.Actions) then
			return
		end
		
		pressSkillCheck(ID)
	end)
	
	MobileInput = SCButton.MouseButton1Down:Connect(function()
		pressSkillCheck(ID)
	end)
	
	Runner = RunService.RenderStepped:Connect(function(delta)
		
		local CurrentX = Needle.Position.X.Scale
		Needle.Position = UDim2.fromScale(CurrentX + (Speed * delta), 0.5)
		
		if (CurrentX > SuccessZone.Position.X.Scale + SuccessZone.Size.X.Scale) then
			Needle.Position = UDim2.fromScale(0, 0.5)
			sendResult(false, ID)
			Disconnect()
		end
	end)
	
end

function Disconnect()
	
	if (InputRunner ~= nil) then
		InputRunner:Disconnect()
		InputRunner = nil
	end
	
	if (MobileInput ~= nil) then
		MobileInput:Disconnect()
		MobileInput = nil
	end
	
	if (Runner ~= nil) then
		Runner:Disconnect()
		Runner = nil
	end
	
	task.wait(0.5)
	
	isRunning = false
	SCButton.Visible = false
	BaseLine.Parent.Parent.Enabled = false
	
end

function pressSkillCheck(ID)
	
	local CurrentX = Needle.Position.X.Scale
	local SuccessMin = SuccessZone.Position.X.Scale
	local SuccessMax = SuccessMin + SuccessZone.Size.X.Scale

	if (CurrentX >= SuccessMin and CurrentX <= SuccessMax) then
		sendResult(true, ID)
		Disconnect()
	else
		sendResult(false, ID)
		Disconnect()
	end
	
end

function sendResult(Result, ID)
	
	if (Result) then
		Sounds.Success:Play()
	else
		Sounds.Fail:Play()
	end
	
	Remotes.SkillCheckEvent:FireServer(Result, ID)
end


return SkillCheck
