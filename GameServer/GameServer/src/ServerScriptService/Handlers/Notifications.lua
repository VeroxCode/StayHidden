local Global_Variables = require(game.ServerScriptService["Global"]:WaitForChild("Global Variables"))
local HttpService = game:GetService("HttpService")

local this = {}

function this.postNotification(Hook: string, Message: string)
	local WebhookMessage = {
		["content"] = Message
	}

	WebhookMessage = HttpService:JSONEncode(WebhookMessage)
	HttpService:PostAsync(Hook, WebhookMessage)
end

function this.postPlayerNotification(Player: string, Message: string)
	local WebhookMessage = {
		["content"] = "**" .. Player .. "** " .. Message
	}

	WebhookMessage = HttpService:JSONEncode(WebhookMessage)
	HttpService:PostAsync(Global_Variables.WebHooks.Notifications, WebhookMessage)
end

return this
