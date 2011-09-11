local MAJOR = "LibScriptablePluginUnit-1.0" 
local MINOR = 24

local PluginUnit = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginUnit then return end

if not PluginUnit.__index then
	PluginUnit.__index = PluginUnit
end

local Detail = Inspect.Unit.Detail
local ScriptEnv = {}

--- Populate an environment with this plugin's fields
-- @usage :New(environment) 
-- @parma environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment
function PluginUnit:New(environment)
	for k, v in pairs(ScriptEnv) do
		environment[k] = v
	end
	return environment
end
