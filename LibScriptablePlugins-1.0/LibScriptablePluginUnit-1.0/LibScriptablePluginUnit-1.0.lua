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

-- afk:	Signals that the unit is AFK. Provided only for the player and the player's groupmembers.
local function UnitAFK(unit)
	local details = Detail(unit)
	if details then return details.afk end
end
ScriptEnv.UnitAFK = UnitAFK

local callings = {mage = "Mage", rogue = "Rogue", cleric = "Cleric", warrior = "Warrior"}
-- calling:	The unit's calling. May be "mage", "rogue", "cleric", or "warrior".
local function UnitCalling(unit) 
	local details = Detail(unit)
	if details then return callings[details.calling] end
end
ScriptEnv.UnitCalling = UnitCalling

-- charge:	The unit's charge. Provided only for the player.
local function UnitCharge(unit)
	local details = Detail(unit)
	if details then return details.charge end
end
ScriptEnv.UnitCharge = UnitCharge

--- combo:	The unit's combo points. Provided only for the player.
local function UnitCombo(unit)
	local details = Detail(unit)
	if details then return details.combo end
end
ScriptEnv.UnitCombo = UnitCombo

--- comboUnit:	The Unit ID of the unit that the combo points have been placed on. Provided only for the player.
local function UnitComboUnit(unit)
	local details = Detail(unit)
	if details then return details.comboUnit end
end
ScriptEnv.UnitComboUnit = UnitComboUnit

--- energy:	The unit's energy.
local function UnitEnergy(unit)
	local details = Detail(unit)
	if details then return details.energy end
end
ScriptEnv.UnitEnergy = UnitEnergy

--- guaranteedLoot:	Signals that this unit guarantees loot on death. Shown in the user interface as a diamond above the portrait.
local function UnitGuaranteedLoot(unit)
	local details = Detail(unit)
	if details then return details.guaranteedLoot end
end
ScriptEnv.UnitGuaranteedLoot = UnitGuaranteedLoot

--- guild:	The unit's guild.
local function UnitGuild(unit)
	local details = Detail(unit)
	if details then return details.guild end
end
ScriptEnv.UnitGuild = UnitGuild

--- health:	The unit's health.
local function UnitHealth(unit)
	local details = Detail(unit)
	if details then return details.health end
end
ScriptEnv.UnitHealth = UnitHealth

--- healthCap:	The unit's capped maximum health.
local function UnitHealthCap(unit)
	local details = Detail(unit)
	if details then return details.healthCap end
end
ScriptEnv.UnitHealthCap = UnitHealthCap

--- healthMax:	The unit's maximum health.
local function UnitHealthMax(unit)
	local details = Detail(unit)
	if details then return details.healthMax end
end
ScriptEnv.UnitHealthMax = UnitHealthMax

--- level:	The unit's level. May be "??" if the unit is hostile and very high-level.
local function UnitLevel(unit)
	local details = Detail(unit)
	if details then return details.level end
end
ScriptEnv.UnitLevel = UnitLevel

--- loot:	The Unit ID that has looting rights to this corpse.
local function UnitLoot(unit)
	local details = Detail(unit)
	if details then return details.loot end
end
ScriptEnv.UnitLoot = UnitLoot

--- mana:	The unit's mana.
local function UnitMana(unit)
	local details = Detail(unit)
	if details then return details.mana end
end
ScriptEnv.UnitMana = UnitMana

--- manaMax:	The unit's maximum mana.
local function UnitManaMax(unit)
	local details = Detail(unit)
	if details then return details.manaMax end
end
ScriptEnv.UnitManaMax = UnitManaMax

--- mark:	The mark on this unit.
local function UnitMark(unit)
	local details = Detail(unit)
	if details then return details.mark end
end
ScriptEnv.UnitMark = UnitMark

--- name:	The unit's name.
local function UnitName(unit)
	local details = Detail(unit)
	if details then return details.name end
end
ScriptEnv.UnitName = UnitName

--- nameSecondary:	The unit's secondary name.
local function UnitNameSecondary(unit)
	local details = Detail(unit)
	if details then return details.nameSecondary end
end
ScriptEnv.UnitNameSecondary = UnitNameSecondary

--- offline:	Signals that the unit is offline. Provided only for the player's groupmembers.
local function UnitOffline(unit)
	local details = Detail(unit)
	if details then return details.offline end
end
ScriptEnv.UnitOffline = UnitOffline

--- planar:	The unit's available planar charges. Provided only for the player.
local function UnitPlanar(unit)
	local details = Detail(unit)
	if details then return details.planar end
end
ScriptEnv.UnitPlanar = UnitPlanar

--- player:	Signals that the unit is a player, not an NPC.
local function UnitPlayer(unit)
	local details = Detail(unit)
	if details then return details.player end
end
ScriptEnv.UnitPlayer = UnitPlayer

--- power:	The unit's power.
local function UnitPower(unit)
	local details = Detail(unit)
	if details then return details.power end
end
ScriptEnv.UnitPower = UnitPower

--- pvp:	The unit's PvP flag.
local function UnitPVP(unit)
	local details = Detail(unit)
	if details then return details.pvp end
end
ScriptEnv.UnitPVP = UnitPVP

--- ready:	The unit's readycheck status.
local function UnitReady(unit)
	local details = Detail(unit)
	if details then return details.ready end
end
ScriptEnv.UnitReady = UnitReady

local relations = {hostile = "Hostile", friendly = "Friendly"}
--- relation:	The unit's relation to you. May be "hostile" or "friendly". Neutral targets will not have this member.
local function UnitRelation(unit)
	local details = Detail(unit)
	if details then return relations[details.relation] end
end
ScriptEnv.UnitRelation = UnitRelation

local function UnitHostile(unit)
	local details = Detail(unit)
	if details then return details.relation == "hostile" end
end
ScriptEnv.UnitHostile = UnitHostile

local pc = {r = 123 / 255, g = 171 / 255, b =252 / 255}
local function UnitRelationColor(unit)
	if UnitPlayer(unit) then
		return pc.r, pc.g, pc.b
	else
		if UnitHostile(unit) then
			return 1, 0, 0
		else
			if not UnitRelation(unit) then
				return 1, 1, 0
			else
				return 0, 1, 0
			end
		end
	end
end
ScriptEnv.UnitRelationColor = UnitRelationColor

local roles = {tank = "Tank", heal = "Heals", dps = "DPS", support = "Support"}
--- role:	The unit's role. May be "tank", "heal", "dps", "support", or nil. Provided only for the player and the player's groupmembers.
local function UnitRole(unit)
	local details = Detail(unit)
	if details then return roles[details.role] end
end
ScriptEnv.UnitRole = UnitRole

--- titlePrefix:	The unit's title prefix.
local function UnitTitlePrefix(unit)
	local details = Detail(unit)
	if details then return details.prefix end
end
ScriptEnv.UnitTitlePrefix = UnitTitlePrefix

--- titleSuffix:	The unit's title suffix.
local function UnitTitleSuffix(unit)
	local details = Detail(unit)
	if details then return details.suffix end
end
ScriptEnv.UnitTitleSuffix = UnitTitleSuffix

--- vitality:	The unit's vitality. Provided only for the player.
local function UnitVitality(unit)
	local details = Detail(unit)
	if details then return details.vitality end
end
ScriptEnv.UnitVitality = UnitVitality

--- warfront:	Signals that the unit has temporarily left the group to join a warfront. Provided only for groupmembers.
local function UnitWarfront(unit)
	local details = Detail(unit)
	if details then return details.warfront end
end
ScriptEnv.UnitWarfront = UnitWarfront

