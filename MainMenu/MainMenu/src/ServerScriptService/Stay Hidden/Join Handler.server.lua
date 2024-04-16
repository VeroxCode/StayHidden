local Global_Variables = require(game.ServerScriptService["Global"]:WaitForChild("Global Variables"))
local Notifications = require(game.ServerScriptService.Handlers:WaitForChild("Notifications"))
local SaveStorage = require(game.ServerScriptService.Handlers:WaitForChild("Save Storage"))
local PlayFab = require(game.ServerScriptService.Handlers:WaitForChild("PlayFab"))
local News = require(game.ServerScriptService.Handlers:WaitForChild("News"))
local json = require(game.ServerScriptService.PlayFab:WaitForChild("json"))
local Utils = require(game.ServerScriptService.Global.Utils)

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

workspace:GetAttributeChangedSignal("LoggedIn"):Connect(function(Value)
		
	task.wait(5)
		
	for i, Player in pairs(game.Players:GetPlayers()) do
		
		if (workspace:GetAttribute("BanCheck")) then
			return
		end
		
		checkForMaintenance(Player)
		checkForBans(Player)
	end
end)

function onJoin(Player)
	
	for i, v in pairs(game.ReplicatedStorage.Modifiers:GetDescendants()) do
		if (v:isA("ModuleScript")) then
			v:Destroy()
		end
	end

	for i, v in pairs(game.ReplicatedStorage.Perks:GetDescendants()) do
		if (v:isA("Script")) then
			v.Config.Parent = v.Parent
			v.Parent.Config.Name = v.Name
			v:Destroy()
		end
	end
	
	News:displayNews(Player)
	task.wait(7)
	workspace:WaitForChild(Player.Name).HumanoidRootPart.Anchored = true
	
end

function checkForBans(Player: Player)
	
	if (workspace:GetAttribute("BanCheck") == true) then
		return
	end
	
	workspace:SetAttribute("BanCheck", true)

	local id = PlayFab:getPlayFabID(Player.UserId)
	local BanTable = PlayFab:getData(id, "PlayerBan")
	local DefaultTable = Global_Variables.BanTable
	
	local BanUI = Player.PlayerGui:WaitForChild("Ban")
	local PlayerGUI = Player:WaitForChild("PlayerGui")

	if (BanTable == nil) then
		print("Missing Ban Data")
		PlayFab.setData(id, "PlayerBan", json.encode(DefaultTable))
		return
	else
		BanTable = json.decode(BanTable)
	end

	local BanReason = BanTable["reason"]
	local BanExpiration = os.date("*t", BanTable["expiration"])
	local ExpirationMessage = `\n{BanExpiration["day"]}.{BanExpiration["month"]}.{BanExpiration["year"]} \n{BanExpiration["hour"]}:{BanExpiration["min"]}`
	
	
	if (BanTable["isBanned"]) then
		if (BanTable["expiration"] ~= 0 and BanTable["expiration"] > os.time()) then
			BanUI.BaseFrame.Prefab.Body.Label.Text = `Reason: {BanReason} \nBanned Until: {ExpirationMessage}`
			BanUI.Enabled = true
			
			PlayerGUI.Main.Enabled = false
			PlayerGUI.Main:Destroy()
		end
			
		if (BanTable["expiration"] == 0) then
			BanUI.BaseFrame.Prefab.Body.Label.Text = `Reason: {BanReason} \nYour Ban is Permanent.`
			BanUI.Enabled = true
			
			PlayerGUI.Main.Enabled = false
			PlayerGUI.Main:Destroy()
			
		end
	end

end

function checkForMaintenance(Player)

	local id = PlayFab:getPlayFabID(Player.UserId)
	local BanTable = PlayFab:getData(id, "PlayerBan")
	
	local PlayerGUI = Player:WaitForChild("PlayerGui")
	local MaintenanceUI = PlayerGUI:WaitForChild("Maintenance")

	local Maintenance = PlayFab:getTitleData("Maintenance")
	
	if (Utils:isTester(Player)) then
		--PlayerGUI:WaitForChild("Main"):WaitForChild("BaseFrame"):WaitForChild("Quick").Visible = true
		return
	end
	
	if (Maintenance == "true") then
		MaintenanceUI.Enabled = true
		
		for i, v in pairs(PlayerGUI:GetChildren()) do
			if (v.Name ~= "Maintenance") then
				v.Enabled = false
				v:Destroy()
			end
		end
	end
end


Players.PlayerAdded:Connect(onJoin)