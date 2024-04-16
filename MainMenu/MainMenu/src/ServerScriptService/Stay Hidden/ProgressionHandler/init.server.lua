local SaveStorage = require(game.ServerScriptService.Handlers["Save Storage"])
local CharacterInfo = require(game.ServerScriptService.Global.CharacterInfo)

local Remotes = game.ReplicatedStorage.Remotes
local PurchaseRequest = Remotes.RequestPurchase

local Cards = require(script.Cards)

function requestPurchase(Player, Role, Type, Identifier)
	
	if (Type == "Pack") then
		local Price = Cards:getPrice(Identifier)
		local canBuy = checkCurrency(Player, Price)
		
		if (canBuy) then
			Cards.create(Player, Identifier, Role)
			withdrawCurrency(Player, Price)
			return "Purchased"
		else
			return "Cancelled"
		end
	end
	
	return "Invalid"
end

function checkCurrency(Player, Price)
	
	local Profile = SaveStorage:get(Player.UserId)
	local Credits = Profile.Account.Credits
	
	return Credits >= Price	
end

function withdrawCurrency(Player, Price)
	
	local Profile = SaveStorage:get(Player.UserId)

	Profile.Account.Credits -= Price
	SaveStorage:update(Player.UserId, Profile)
end

PurchaseRequest.OnServerInvoke = requestPurchase