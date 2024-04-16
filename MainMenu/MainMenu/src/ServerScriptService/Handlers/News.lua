local PlayFabServer = require(game.ServerScriptService.PlayFab:WaitForChild("PlayFabServerApi"))

local NewsData

local this = {}

function this:retrieveNews()
	PlayFabServer.GetTitleNews(
		{
			Count = 5
		},
	
		function(result)	
			NewsData = result
		end,
		
		function(error)
			print(error)
		end)
end

function this:getNews()
	this:retrieveNews()
	return NewsData
end

function this:displayNews(Player)
	this:retrieveNews()
	
	local PlayerGUI = Player:WaitForChild("PlayerGui")
	local NewsUI = PlayerGUI:WaitForChild("News")
	
	for count = #NewsData.News, 1, -1 do
		
		local NewsPrefab = NewsUI.BaseFrame.Prefab:Clone()
		NewsPrefab.Name = count
		NewsPrefab.Parent = NewsUI.BaseFrame.ScrollingFrame
		NewsPrefab.Visible = true
		
		NewsPrefab.Title.Label.Text = NewsData.News[count]["Title"]
		NewsPrefab.Body.Label.Text = NewsData.News[count]["Body"]
		
	end
	
end

return this
