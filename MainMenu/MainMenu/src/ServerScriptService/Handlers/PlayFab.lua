local PlayFabClient = require(game.ServerScriptService.PlayFab:WaitForChild("PlayFabClientApi"))
local PlayFabServer = require(game.ServerScriptService.PlayFab:WaitForChild("PlayFabServerApi"))
local PlayFabAdmin = require(game.ServerScriptService.PlayFab:WaitForChild("PlayFabAdminApi"))

local Players = game:GetService("Players")

local PlayFabIDs = {}
local TitleData = nil
local lastTry = os.time() - 5

local this = {}

function this.addPlayFabID(userId, PlayFabId)
	PlayFabIDs[userId] = PlayFabId
end

function this:getPlayFabID(userId)
	return PlayFabIDs[userId]
end

function this.loginPlayer(userId, userName)
	
	PlayFabServer.LoginWithServerCustomId(
		{
			CreateAccount = true;
			ServerCustomId = userId 
		},
		function(result)
			print("Successfully logged in ")
			this.addPlayFabID(userId, result["PlayFabId"])
			this.setDisplayName(result["PlayFabId"], userName)
		end,

		function(error)
			print("Failed to login", userId..".", error.errorMessage)
			local Player = Players:GetPlayerByUserId(userId)
			Player:Kick("Something went wrong. Please try again!")
		end)
end

function this.setDisplayName(userId, userName)
	PlayFabAdmin.UpdateUserTitleDisplayName(
		{
			PlayFabId = userId;
			DisplayName = userName
		},
		function(result)
			print("Successfully changed Display Name ")
			this.addPlayFabID(userId, result["PlayFabId"])
		end,

		function(error)
			print("Failed to login." .. error.errorMessage)
			this.loginPlayer(userId)
		end)
end

function this:getData(userId, Branch)
	
	local data = nil
	
	PlayFabServer.GetUserData(
		{
			PlayFabId = userId
		},
		function(result)
			if (result["Data"][Branch]) then
				data = result["Data"][Branch]["Value"]
				print("retrieved Data. " .. Branch)
			end
		end,

		function(error)
			print(error.errorMessage)
		end)
	
	return data
end

function this.setData(userId, Branch, json)
	local data = PlayFabServer.UpdateUserData(
		{
			PlayFabId = userId;
			Data = {[Branch] = json};
			Permission = "Public"

		},
		function(result)
		end,

		function(error)
			print("Failed to login " .. error.errorMessage)
		end)
	return data

end 

function this.returnTitleDataKey()
	PlayFabServer.GetTitleData(
		{
			Keys = {}

		},
		function(result)
			TitleData = result.Data
		end,

		function(error)
			print("Failed to login " .. error.errorMessage)
		end)
end 

function this:getTitleData(Key)
	this:returnTitleDataKey()
	return TitleData[Key]
end

return this
