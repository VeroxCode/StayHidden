local UserInputService = game.UserInputService
local Player = game.Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local Mouse = Player:GetMouse()
local Remotes = game.ReplicatedStorage.Remotes

local Main = PlayerGui:WaitForChild("Main").BaseFrame
local Prey = PlayerGui:WaitForChild("Prey").BaseFrame
local Hunter = PlayerGui:WaitForChild("Hunter").BaseFrame
local News = PlayerGui:WaitForChild("News").BaseFrame
local Options = PlayerGui:WaitForChild("Options").BaseFrame
local Credits = PlayerGui:WaitForChild("Credits").BaseFrame
local AccountUI = PlayerGui:WaitForChild("AccountUI").BaseFrame
local ServerBrowser = PlayerGui:WaitForChild("ServerBrowser").BaseFrame

local Modules = {
	["Matchmaking"] = require(script.Matchmaking);
	["Progression"] = require(script.Progression);
	["AccountUI"] = require(script.AccountUI);
	["Friends"] = require(script.FriendList);
	["Loadout"] = require(script.Loadout);
	["Settings"] = require(script.Settings);
	["Utils"] = require(script.Utils)
}

local Scenes = {Main.Parent, Prey.Parent, Hunter.Parent, News.Parent, Options.Parent, AccountUI.Parent, ServerBrowser.Parent, Credits.Parent}
local Roles = {"Hunter", "Prey"}

function initialize()
	for index, scene in pairs(Scenes) do
		for index2, element in pairs(scene:GetDescendants()) do
			if (element:isA("ImageButton") or element:isA("TextButton")) then
				element.MouseButton1Click:Connect(function()
					onButtonPress(element, scene)
				end)
			end
		end
	end
	
	Modules.Friends:createFriendlist()
	Modules.Friends:addToPartyList(Player.UserId)
	
end

function onUpdate()
	Hunter.HolderFrame.B_LoadoutFrame.Caption.Position = UDim2.fromOffset(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
	Hunter.HolderFrame.B_SelectionFrame.Caption.Position = UDim2.fromOffset(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
	Prey.HolderFrame.B_LoadoutFrame.Caption.Position = UDim2.fromOffset(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
	Prey.HolderFrame.B_SelectionFrame.Caption.Position = UDim2.fromOffset(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
end

function onButtonPress(Button: ImageButton|TextButton, Scene: ScreenGui)
	
	local ButtonName = Button.Name
	local SceneName = Scene.Name
	
	if (ButtonName == "PlayHunter" or ButtonName == "PlayPrey") then
		
		local Role = string.gsub(ButtonName, "Play", "")

		Modules.Utils:closeScenes(Player)
		Modules.AccountUI:updateAll()
		PlayerGui.AccountUI.Enabled = true
		PlayerGui[Role].Enabled = true
		
		Modules.Loadout:clearPerks(Role)
		Modules.Loadout:clearModifiers(Role)
		Modules.Loadout:showLoadout(Role, false, false)
		
		Modules.Loadout:getData()
		Modules.Loadout:buildLoadout(Role)
		
		if (Role == "Hunter") then
			local Profile = Remotes.RequestData:InvokeServer("Profile")
			local Selected = Profile[Role].Selected

			Modules.Utils:setMenuTheme(Player, string.gsub(Selected, " ", ""))
		else
			Modules.Utils:setMenuTheme(Player, "Main")
		end
		
	end
	
	if (ButtonName == "Options") then
		Modules.Settings:prepareSettings()
		Modules.Settings:prepareGeneral()
	end
	
	if (SceneName == "Options") then
		if (table.find({"General", "Controls"}, ButtonName)) then
			Modules.Settings:showSettings((ButtonName == "General"), (ButtonName == "Controls"))
		end
	end
	
	if (PlayerGui:FindFirstChild(ButtonName) ~= nil and SceneName == "Main") then
		Modules.Utils:closeScenes(Player)
		PlayerGui[ButtonName].Enabled = true
	end
	
	if (ButtonName == "Back") then
		Modules.Utils:closeScenes(Player)
		Modules.Matchmaking:disconnectRefresh()
		PlayerGui["Main"].Enabled = true
		Main.Separator.FriendList.Visible = false
		Modules.Settings:clearActions()
	end
	
	if (ButtonName == "Loadout") then
		Modules.Utils:closeRoleMenus(Player)
		
		Modules.Loadout:clearPerks(SceneName)
		Modules.Loadout:clearModifiers(SceneName)
		Modules.Loadout:showLoadout(SceneName, false, false)

		Modules.Loadout:getData()
		Modules.Loadout:buildLoadout(SceneName)
		
		PlayerGui[SceneName].BaseFrame.HolderFrame.B_LoadoutFrame.Visible = true
	end
	
	if (ButtonName == "Selection") then
		Modules.Utils:closeRoleMenus(Player)
		PlayerGui[SceneName].BaseFrame.HolderFrame.B_SelectionFrame.Visible = true
	end
	
	if (ButtonName == "Progression") then
		Modules.Utils:closeRoleMenus(Player)
		Modules.AccountUI:updateAll()
		PlayerGui[SceneName].BaseFrame.HolderFrame.B_ProgressionFrame.Visible = true
		PlayerGui[SceneName].BaseFrame.HolderFrame.B_ProgressionFrame.Packs.Visible = false
		
		PlayerGui[SceneName].BaseFrame.HolderFrame.B_ProgressionFrame.Packs_BTN.Visible = true
		PlayerGui[SceneName].BaseFrame.HolderFrame.B_ProgressionFrame.Challenges_BTN.Visible = true
	end
	
	if (ButtonName == "Packs_BTN") then
		Modules.Progression:LoadLevelAndExp(SceneName)
		PlayerGui[SceneName].BaseFrame.HolderFrame.B_ProgressionFrame.Packs.Visible = true
		PlayerGui[SceneName].BaseFrame.HolderFrame.B_ProgressionFrame.Packs_BTN.Visible = false
		PlayerGui[SceneName].BaseFrame.HolderFrame.B_ProgressionFrame.Challenges_BTN.Visible = false
	end
	
	if (ButtonName == "Customization") then
		Modules.Utils:closeRoleMenus(Player)
		--PlayerGui[SceneName].BaseFrame.HolderFrame.B_SelectionFrame.Visible = true
	end
	
	if (table.find(Roles, SceneName)) then
		Modules.Loadout:handleButtonCall(Button, SceneName)
	end
	
	if (string.find(ButtonName, "Slot") and SceneName == "Main") then
		if (Button:GetAttribute("PlayerID") == 0) then
			Modules.Friends:createFriendlist()
			Main.Separator.FriendList.Visible = true
		end
	end
	
	if (ButtonName == "Ready") then
		if (SceneName == "Prey") then
			Modules.Utils:closeScenes(Player)
			Modules.Matchmaking:constructServerlist()
			Modules.Matchmaking:startAutoRefresh()
			ServerBrowser.Parent.Enabled = true
		else
			Button.Connecting.Visible = true
			Remotes.JoinServerPool:FireServer()
		end
		
	end
	
	if (ButtonName == "LeaveParty" and SceneName == "Main") then
		Modules.Friends:clearPartySlots()
		Modules.Friends:addToPartyList(Player.UserId)
		Modules.Friends.leaveParty()
	end
	
	if (string.find(ButtonName, "Pack_")) then
		local Role = SceneName
		local Type = string.gsub(ButtonName, "Pack_", "")
		
		Modules.Progression:BuyCards(Role, Type)
	end
	
	if (ButtonName == "Close" and table.find(Roles, SceneName)) then
		local Cards = PlayerGui[SceneName].BaseFrame.HolderFrame.B_CardFrame
		local Packs = PlayerGui[SceneName].BaseFrame.HolderFrame.B_ProgressionFrame.Packs
		local ProgressionFrame = PlayerGui[SceneName].BaseFrame.HolderFrame.B_ProgressionFrame
		
		ProgressionFrame.Visible = true
		Cards.Visible = false
		Packs.Visible = true
		
		Modules.Progression:LoadLevelAndExp(SceneName)
	end
	
	if (ButtonName == "Credits" and SceneName == "Main") then
		Modules.Utils:closeScenes(Player)
		Credits.Parent.Enabled = true
	end
	
end

game:GetService("RunService").RenderStepped:Connect(onUpdate)

initialize()

