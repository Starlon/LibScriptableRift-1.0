local debug = false
--[===[@debug@
debug = true
--@end-debug@]===]

local LibDriverCharacter = LibStub("LibScriptableLCDDriverCharacter-1.0")
local environment = {}

table.insert(Command.Slash.Register("lcd4rift"), {function (commandLineParameters)
	local display = LibDriverCharacter:New(environment, environment, "display_character", _G.LCD4Rift.config, 2)
	display:Show()
end, "LibScriptable_1_0", "Slash command"})

