local debug = false
--[===[@debug@
debug = true
--@end-debug@]===]

local LibDriver = LibStub("LibScriptableLCDDriver-1.0")

table.insert(Command.Slash.Register("lcd4rift"), {function (commandLineParameters)
	local display = LibDriver:New(environment, environment, "display_startip", _G.LCD4Rift.config, 2)
	display:Show()
end, "LibScriptable_1_0", "Slash command"})

