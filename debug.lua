
local LibTimer = LibStub("LibScriptableUtilsTimer-1.0")
local LibCore = LibStub("LibScriptableLCDCoreLite-1.0")
local LibDriver = LibStub("LibScriptableLCDDriver-1.0")

local environment = {}



--[[
local function debug()
do return end
	local unit = GetMouseoverUnit()
	print(unit or "None")
end

LibTimer:New("debug", 1000, false, debug):Start()
]]

local context = UI.CreateContext("HUD")
bar = UI.CreateFrame("Text", "Text", context)
bar:SetVisible(true)
local name = Inspect.Unit.Detail("player").name
bar:SetText(name)
bar:SetPoint("CENTER", UIParent, "CENTER")

table.insert(Command.Slash.Register("debug"), {function (commandLineParameters)
	local display = LibDriver:New(environment, environment, "display_startip", _G.LCD4Rift.config, 2)
	display:Show()
end, "LibScriptable_1_0", "Slash command"})

LibCore:New(_G, "debug", 3)
