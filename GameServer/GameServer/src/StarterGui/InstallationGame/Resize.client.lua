local InstallGame = require(script.Parent.InstallGame)
local RunService = game:GetService("RunService")
local ParentFrame = script.Parent.Frame
local FrameExit = ParentFrame.Folder.Exit
local UI = script.Parent

local HardTable = {
	[1] = {0, 0},
	[2] = {0, 1},
	[3] = {0, 2},
	[4] = {1, 0},
	[5] = {1, 1},
	[6] = {1, 2},
	[7] = {2, 0},
	[8] = {2, 1},
	[9] = {2, 2},
}

function set_positions()
	if (not InstallGame:isInitialized()) then
		return
	end

	ParentFrame.Size = UDim2.new(0, (450 / 1920 * workspace.CurrentCamera.ViewportSize.X), 0, (450 / 1080 * workspace.CurrentCamera.ViewportSize.Y)) 
	--ParentFrame.Position = UDim2.new(0, (workspace.CurrentCamera.ViewportSize.X / 2) - (ParentFrame.Size.X.Offset / 2), 0, (workspace.CurrentCamera.ViewportSize.Y / 2) - (ParentFrame.Size.Y.Offset / 2))
	ParentFrame.UIGridLayout.CellSize = UDim2.new(0, (150 / 1920 * workspace.CurrentCamera.ViewportSize.X), 0, (150 / 1080 * workspace.CurrentCamera.ViewportSize.Y))
	UI.Enabled = true
	
	for count = 1, 9 do
		local Field = ParentFrame[count]
		local row = math.clamp(math.floor((count - 1) / 3), 0, 2)
		local pos = math.clamp(math.floor(count / 3), 0, 2)
		
		if (count <= 9) then
			--row = 3
		end
		
		if (count <= 6) then
			--row = 2
		end
		
		if (count <= 3) then
			--row = 1
		end
		
		local ParentFrameSizeX = ParentFrame.Size.X.Offset
		local ParentFrameSizeY = ParentFrame.Size.Y.Offset
		
		local AbsolutX = workspace.CurrentCamera.ViewportSize.X
		local AbsolutY = workspace.CurrentCamera.ViewportSize.Y
		
		local SizeX = 150 / 1920 * AbsolutX
		local SizeY = 150 / 1080 * AbsolutY
		
		local PosX = (ParentFrame.Position.X.Offset) + ((HardTable[count][2]) * SizeX)
		local PosY = (ParentFrame.Position.Y.Offset) + ((HardTable[count][1]) * SizeY)
		
		local ExitSizeX = (250 / 1920 * workspace.CurrentCamera.ViewportSize.X)
		local ExitSizeY = (50 / 1080 * workspace.CurrentCamera.ViewportSize.Y)
		
		--FrameExit.Size = UDim2.new(0, ExitSizeX, 0, ExitSizeY)
		--FrameExit.Position = UDim2.new(0, ((AbsolutX / 2) - (ExitSizeX / 2)), 0 , AbsolutY - (ExitSizeY * 4)) 
		Field.Size = UDim2.new(0, SizeX, 0, SizeY) 
		Field.Position = UDim2.new(0, PosX, 0, PosY)
		Field.Visible = true
	end

end

function exit_down()
	InstallGame:abort()
end

FrameExit.MouseButton1Down:Connect(exit_down)
RunService.Heartbeat:Connect(set_positions)

