local Player = game.Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local AccountUI = PlayerGui.AccountUI.BaseFrame
local Remotes = game.ReplicatedStorage.Remotes

local Profile = nil
local CurrencyTween = nil

local this = {}

function this:updateAll()
	this:updateRank()
	this:updateLevel()
	this:updateCurrency()
	
	if (CurrencyTween == nil) then
		local Current = AccountUI.CreditsIcon.Amount.Current
		CurrencyTween = Current.Changed:Connect(function(Value)
			AccountUI.CreditsIcon.Amount.Text = Value
		end)
	end
	
end

function this:updateCurrency()
	
	Profile = Remotes.RequestData:InvokeServer("Profile")
	
	local Current = AccountUI.CreditsIcon.Amount.Current
	local OldAmount = Current.Value
	local NewAmount = Profile.Account.Credits
	
	local tween = game.TweenService:Create(Current, TweenInfo.new(1.5), {Value = NewAmount})
	tween:Play()
	
end

function this:updateRank()
	
	Profile = Remotes.RequestData:InvokeServer("Profile")
	local args = string.split(Profile.Account.Rank, "-")
	AccountUI.RankIcon.Bracket.Text = args[1]
	AccountUI.RankIcon.Digit.Text = args[2]
	
end

function this:updateLevel()
	
	Profile = Remotes.RequestData:InvokeServer("Profile")
	AccountUI.LevelIcon.Amount.Text = tostring(Profile.Account.Level)
	
end

return this
