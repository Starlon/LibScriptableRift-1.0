local MAJOR = "LibScriptablePluginSimpleMeter-1.0"
local MINOR = 24
local PluginSimpleMeter = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginSimpleMeter then return end

local _G = _G

local ScriptEnv = {}

-- Populate an environment with this plugin's fields
-- @usage :New(environment)
-- @parma environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment, and the plugin object as second return
function PluginSimpleMeter:New(environment)

	for k, v in pairs(ScriptEnv) do
		environment[k] = v
	end	

	return environment
end


-- Credits go to Jor. This comes from SimpleMeter's BuildCopyText method for encounters.
-- Friendly and hostile checks are performed internally. 
-- Provide 'mode' and 'expand'. 
-- 'mode' is the report requested. DPS, Damage done, healing done, damage taken, heal taken, and dps otherwise. 
-- And 'expand' is the list. 
-- 'self' points to the current encounter.
-- 'top5' looks at the top 5 units.
-- 'all' will look at everything.
-- mode: dps, dmg, hps, heal, dtk, htk
-- expand: all, self, top5
local mode, expand = "dps", "top5"

-- Credits go to Jor. This comes from SimpleMeter's BuildCopyText method for encounters.
-- Friendly and hostile checks are performed internally. 
-- Provide 'mode' and 'expand'. 
-- 'mode' is the report requested. DPS, Damage done, healing done, damage taken, heal taken, and dps otherwise. 
-- And 'expand' is the list. 
-- 'self' points to the current encounter.
-- 'top5' looks at the top 5 units.
-- 'all' will look at everything.
-- mode: dps, dmg, hps, heal, dtk, htk
-- expand: all, self, top5
local mode, expand = "dps", "top5"

function SimpleMeter(unit, mode, expand)

    local SimpleMeter = _G.SimpleMeter
    if SimpleMeter then
        local encounterIndex = SimpleMeter.state.encounterIndex
        local encounter = SimpleMeter.state.encounters[encounterIndex]
        local unitid = Inspect.Unit.Lookup(unit)
        local total, count = 0, 0
        local timeText,totalText, unitText = "", "", ""
    
        local function grab(side, mode, expand)
            local list, copyFrom = {}, {}
            if side == "ally" then
                copyFrom = encounter.allies
            else
                copyFrom = encounter.enemies
            end
    
            if #copyFrom == 0 then return "" end
    
            for _, v in pairs(copyFrom) do
                table.insert(list, v)
            end
    
            encounter:Sort(list, mode)
    
      	    local time = encounter:GetCombatTime()
            timeText = "Time: " .. SimpleMeter.Util.FormatTime(time)
    
            if side == "ally" then
                totalText = totalText .. " Ally"
            elseif side == "enemy" then
                totalText = totalText .. " Enemy"
            end
            totalText = totalText .. " " .. SimpleMeter.Modes[mode].desc .. ": "
    
            for _, id in pairs(list) do
                for k, v in pairs(encounter.units) do
                    if k == unitid then
                        local unit = encounter.units[unitid]
                        local v = 0
            	        if mode == "dps" then
                            v = unit.damage / time
                        elseif mode == "dmg" then
                            v = unit.damage
                        elseif v == "heal" then
                            v =  unit.heal / time
    		        elseif v == "gtk" then
                            v = unit.damageTaken
                        elseif v == "htk" then
                            v = unit.healTaken
                        else
                            v = unit.damage / time
                        end
                        if (expand == "all" and v > 0)
                           or (expand == "top5" and count < 5)
                           or (expand == "self" and id == SimpleMeter.state.playerId) then
                                unitText = unitText .. "  " .. unit.name .. " :" .. SimpleMeter.Util.FormatNumber(v)
                                count = count + 1
                                break
                        end
                        total = total + v
                    end
    		end
            end
    	end
    
        if encounter then
            local details = Inspect.Unit.Detail(unit)
            if details and details.relation == "friendly" then
                grab("ally", mode, expand)
            elseif details and details.relation == "hostile" then
                grab("enemy", mode, expand)
            else
                grab("ally", mode, expand)
            end
    
            local text = timeText .. totalText .. SimpleMeter.Util.FormatNumber(total) .. unitText
            if text ~= "0" then 
    	        return text
    	    end
            return "<SimpleMeter>"
        end
        return "<SimpleMeter>"
    end
end
ScriptEnv.SimpleMeter = SimpleMeter
