local SkillCheckManager = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("SkillCheck Manager"))
local CreditManager = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Credit Manager"))
local Game_Functions = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Utils"):WaitForChild("Game Functions"))
local AuraManager = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Managers"):WaitForChild("Aura Manager"))
local Game_Values = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Utils"):WaitForChild("Game Values"))
local PlayerUtils = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Utils"):WaitForChild("Player Utils"))

local SaveStorage = require(game.ServerScriptService["Handlers"]:WaitForChild("Save Storage"))
local BindStorage = require(game.ServerScriptService["Handlers"]:WaitForChild("Bind Storage"))

local SpawnLogic = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Setup"):WaitForChild("Spawn Logic"))
local Terrain = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Map"):WaitForChild("TerrainSaveLoad"))
local Setup = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Setup"):WaitForChild("Setup"))

local PartChest = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Interactables"):WaitForChild("PartChest"))
local Extractor = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Interactables"):WaitForChild("Extractor"))
local Collector = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Interactables"):WaitForChild("Collector"))
local Fusebox = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Interactables"):WaitForChild("Fusebox"))
local JunkPile = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Interactables"):WaitForChild("JunkPile"))
local BigDoor = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Interactables"):WaitForChild("BigDoor"))
local Curtain = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Interactables"):WaitForChild("Curtain"))
local Grave = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Interactables"):WaitForChild("Grave"))
local Gap = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Interactables"):WaitForChild("Gap"))
local Exit = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Interactables"):WaitForChild("Exit"))

local InteractionSpeed = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Player"):WaitForChild("InteractionSpeed"))
local ActionSpeed = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Player"):WaitForChild("ActionSpeed"))
local Actions = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Player"):WaitForChild("Actions"))
local Speed = require(game.ServerScriptService["Gameplay Server"]:WaitForChild("Player"):WaitForChild("Speed"))

local GlobalVariables = require(game.ServerScriptService["Global"]:WaitForChild("Global Variables"))
local GlobalUtils = require(game.ServerScriptService["Global"]:WaitForChild("Utils"))

local Remotes = game.ReplicatedStorage.Remotes
local Events = game.ServerStorage.Events

local this = {}

this.Modules = {
	["Actions"] = Actions,
	["ActionSpeed"] = ActionSpeed,
	["AuraManager"] = AuraManager,
	["BigDoor"] = BigDoor,
	["BindStorage"] = BindStorage,
	["Credits"] = CreditManager,
	["Collector"] = Collector,
	["Curtain"] = Curtain,
	["Events"] = Events,
	["Exit"] = Exit,
	["Extractor"] = Extractor,
	["Fusebox"] = Fusebox,
	["Game"] = Game_Functions,
	["Game_Values"] = Game_Values,
	["Gap"] = Gap,
	["GlobalUtils"] = GlobalUtils,
	["GlobalVariables"] = GlobalVariables,
	["Grave"] = Grave,
	["InteractionSpeed"] = InteractionSpeed,
	["JunkPile"] = JunkPile,
	["PlayerUtils"] = PlayerUtils,
	["PartChest"] = PartChest,
	["Remotes"] = Remotes,
	["SaveStorage"] = SaveStorage,
	["Setup"] = Setup,
	["SkillCheckManager"] = SkillCheckManager,
	["SpawnLogic"] = SpawnLogic,
	["Speed"] = Speed,
	["Terrain"] = Terrain,
}

return this
