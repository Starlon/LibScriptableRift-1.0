local MAJOR = "LibScriptablePluginUnit-1.0" 
local MINOR = 24

local PluginUnit = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginUnit then return end

if not PluginUnit.__index then
	PluginUnit.__index = PluginUnit
end

local Detail = Inspect.Unit.Detail
local ScriptEnv = {}
local Detail = Inspect.Unit.Detail

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

local function UnitAFK(unit)
	local details = Detail(unit)
	if details then return details.Afk end
end
ScriptEnv.UnitAFK = UnitAFK

local function UnitCharge(unit)
	local details = Detail(unit)
	if details then return details.Charge end
end
ScriptEnv.UnitCharge = UnitCharge

local function UnitCombo(unit)
	local details = Detail(unit)
	if details then return details.Combo end
end
ScriptEnv.UnitCombo = UnitCombo

local function UnitComboUnit(unit)
	local details = Detail(unit)
	if details then return details.ComboUnit end
end

local function UnitEnergy(unit)
	local details = Detail(unit)
	if details then return details.Energy end
end
ScriptEnv.UnitEnergy = UnitEnergy

local function UnitGuild(unit)
	local details = Detail(unit)
	if details then return details.Guild end
end
ScriptEnv.UnitGuild = UnitGuild

local function UnitHealth(unit)
	local details = Detail(unit)
	if details then return details.Health end
end
ScriptEnv.UnitHealth = UnitHealth

local function UnitHealthCap(unit)
	local details = Detail(unit)
	if details then return details.HealthCap end
end
ScriptEnv.UnitHealthCap = UnitHealthCap

local function UnitHealthMax(unit)
	local details = Detail(unit)
	if details then return details.HealthMax end
end
ScriptEnv.UnitHealthMax = UnitHealthMax

local function UnitLevel(unit)
	local details = Detail(unit)
	if details then return details.Level end
end
ScriptEnv.UnitLevel = UnitLevel

local function UnitMana(unit)
	local details = Detail(unit)
	if details then return details.Mana end
end
ScriptEnv.UnitMana = UnitMana

local function UnitManaMax(unit)
	local details = Detail(unit)
	if details then return details.ManaMax end
end
ScriptEnv.UnitManaMax = UnitManaMax

local function UnitMark(unit)
	local details = Detail(unit)
	if details then return details.Mark end
end
ScriptEnv.UnitMark = UnitMark

local function UnitName(unit)
	local details = Detail(unit)
	if details then return details.name end
end
ScriptEnv.UnitName = UnitName

local function UnitOffline(unit)
	local details = Detail(unit)
	if details then return details.Offline end
end
ScriptEnv.UnitOffline = UnitOffline

local function UnitPlanar(unit)
	local details = Detail(unit)
	if details then return details.Planar end
end
ScriptEnv.UnitPlanar = UnitPlanar

local function UnitPower(unit)
	local details = Detail(unit)
	if details then return details.Power end
end
ScriptEnv.UnitPower = UnitPower

local function UnitPVP(unit)
	local details = Detail(unit)
	if details then return details.PVP end
end
ScriptEnv.UnitPVP = UnitPVP

local function UnitRole(unit)
	local details = Detail(unit)
	if details then return details.Role end
end
ScriptEnv.UnitRole = UnitRole

local function UnitTitlePrefix(unit)
	local details = Detail(unit)
	if details then return details.Prefix end
end
ScriptEnv.UnitTitlePrefix = UnitTitlePrefix

local function UnitTitleSuffix(unit)
	local details = Detail(unit)
	if details then return details.Suffix end
end
ScriptEnv.UnitTitleSuffix = UnitTitleSuffix

local function UnitVitality(unit)
	local details = Detail(unit)
	if details then return details.Vitality end
end
ScriptEnv.UnitVitality = UnitVitality

local function UnitWarfront(unit)
	local details = Detail(unit)
	if details then return details.Warfront end
end
ScriptEnv.UnitWarfront = UnitWarfront
