local MAJOR = "LibScriptableLocale-1.0"
local MINOR = 20
assert(LibStub, MAJOR.." requires LibStub")

local LibLocale = LibStub:NewLibrary(MAJOR, MINOR)
if not LibLocale then return end


if GetLocale() == "deDE" then
	LibLocale.L = assert(LibStub("LibScriptableLocale-deDE-1.0")).L

elseif GetLocale() == "esES" then
	LibLocale.L = LibStub("LibScriptableLocale-esES-1.0")

elseif GetLocale() == "esMX" then
	LibLocale.L = LibStub("LibScriptableLocale-enUS-1.0")

elseif GetLocale() == "frFR" then
	LibLocale.L = LibStub("LibScriptableLocale-enUS-1.0")

elseif GetLocale() == "koKR" then
	LibLocale.L = LibStub("LibScriptableLocale-enUS-1.0")

elseif GetLocale() == "ruRU" then
	LibLocale.L = LibStub("LibScriptableLocale-enUS-1.0")

elseif GetLocale() == "zhCN" then
	LibLocale.L = LibStub("LibScriptableLocale-enUS-1.0")

elseif GetLocale() == "zhTW" then
	LibLocale.L = LibStub("LibScriptableLocale-enUS-1.0")

else
	LibLocale.L = LibStub("LibScriptableLocale-enUS-1.0")
end
