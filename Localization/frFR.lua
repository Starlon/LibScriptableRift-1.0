local MAJOR = "LibScriptableLocale-frFR-1.0"
local MINOR = v1+1
assert(LibStub, MAJOR.." requires LibStub")

local L = LibStub:NewLibrary(MAJOR, MINOR)
if not L then return end

L.L = setmetatable({}, {__index = function(k, v)
	if type(v) ~= "string" then return k end
	return v
end})

