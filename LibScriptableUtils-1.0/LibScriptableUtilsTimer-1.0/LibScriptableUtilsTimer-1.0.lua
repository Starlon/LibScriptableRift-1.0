-- This file is Copyright (c) 2007-2010, Ace3 Development Team
-- All rights reserved.
local name, addon = ...
local MAJOR = "LibScriptableUtilsTimer-1.0" 
local MINOR = 24
assert(LibStub, MAJOR.." requires LibStub") 
local LibTimer = LibStub:NewLibrary(MAJOR, MINOR)
if not LibTimer then return end
local LibError = LibStub("LibScriptableUtilsError-1.0")
assert(LibError, MAJOR .. " requires LibScriptableUtilsError-1.0")
local GetTime = Inspect.Time.Frame
local pool = setmetatable({}, {__mode = "k"})

local objects = {}
local cache = {}
local storage = {}
local update
local OnFinish
local tconcat = table.concat
local tinsert = table.insert

if not LibTimer.__index then
	LibTimer.__index = LibTimer
end

--[[
   xpcall safecall implementation from AceTimer-3.0
]]
local xpcall = xpcall

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function CreateDispatcher(argCount)
	local code = [[
	local xpcall, eh = ...  -- our arguments are received as unnamed values in "..." since we don't have a proper function declaration
	local method, ARGS
	local function call() return method(ARGS) end

	local function dispatch(func, ...)
		method = func
		if not method then return end
		ARGS = ...
		return xpcall(call, eh)
	end

	return dispatch
	]]

	local ARGS = {}
	for i = 1, argCount do ARGS[i] = "arg"..i end
	code = code:gsub("ARGS", tconcat(ARGS, ", "))
	return assert(loadstring(code, "safecall Dispatcher["..argCount.."]"))(xpcall, errorhandler)
end

local Dispatchers = setmetatable({}, {
	__index=function(self, argCount)
		local dispatcher = CreateDispatcher(argCount)
		rawset(self, argCount, dispatcher)
		return dispatcher
	end
})
Dispatchers[0] = function(func)
	return xpcall(func, errorhandler)
end

local function safecall(func, ...)
	return Dispatchers[select('#', ...)](func, ...)
end


--- Create a new LibTimer object
-- @usage LibScriptableTimer:New(name, duration, repeating, callback, data, errorLevel, durationLimit)
-- @param name A name for this timer object
-- @param duration The timer's duration in milliseconds.
-- @param repeating Whether to repeat the timer or not
-- @param callback Function to call when the timer has expired
-- @param data Data to pass to the callback
-- @param errorLevel Error verbosity level
-- @return A new LibScriptableTimer object
function LibTimer:New(name, duration, repeating, callback, data, errorLevel)
	assert(type(name) == "string", "Timer objects require a name.")

	duration = type(duration) == "number" and duration or 0
	
	local obj = next(pool)

	if obj then
		pool[obj] = nil
	else
		obj = {}
	end

	setmetatable(obj, self)
	
	obj.error = LibError:New(MAJOR .. ": " .. name, errorLevel)
	
	obj.name = name
	obj.duration = duration / 1000
	
	obj.repeating = repeating
	obj.callback = callback or function() obj.error:Print("No callback", 2) end
	obj.data = data
	obj.errorLevel = errorLevel
	
	tinsert(objects, obj)
	
	return obj	
	
end


--- Delete a LibTimer object
-- @usage object:Del()
-- @return Nothing
function LibTimer:Del()
	local timer = self
	pool[timer] = true
	timer:Stop()
	timer.error:Del()
	del(timer.timer)
end

--- Start a timer.
-- @usage object:Start([duration], [data])
-- @param duration The duration in milliseconds. This is optional. The timer's initialized duration will be replaced by this value.
-- @param data Replace the timer's data that will be sent through the callback with this value.
-- @param func Replace the timer's callback function
function LibTimer:Start(duration, data, func)
	if type(duration) == "number" then
		self.duration = duration / 1000
	end
		
	if self.duration == 0 then return end
	
	self.startTime = GetTime()
	self.active = true
		
	self.data = data or self.data
	if type(func) == "function" then self.callback = func end
		
end

-- Set the timer's refresh rate. This also stops the timer.
-- @usage :Set(100)
-- @param duration The duration in milliseconds. If no duration is passed, then refresh rate is set to zero.
-- @return NOthing
function LibTimer:Set(duration)
	self.duration = (duration or 0) / 1000
	self:Stop()
end

-- Does LibScriptable need this? Mind's fuzzy atm. lol Leaving here in case it dawns on me.
-- state variables to prevent timers canceled during callbacks from being returned
-- from the pool until OnFinished finishes.
local in_OnFinished
local canceled_in_OnFinished

--- Stop a timer
-- @usage object:Stop()
-- @return True if the timer was stopped
function LibTimer:Stop()
	self.active = false
end

--- Return the timer's remaining duration
-- @usage object:TimeElapsed()
-- @return The remaining duration
function LibTimer:TimeElapsed()
	if type(self.startTime) ~= "number" then return 0 end
	return GetTime() - self.startTime
end

local function update()
	local time = GetTime()
	for k, self in pairs(objects) do
		if time - self.startTime > self.duration then
			if self.safecall and false then 
				safecall(self.callback, type(self.data) == "table" and unpack(self.data) or self.data)
			else
				self.callback(self.data)
			end
			self.error:Print(("Elapsed - %f"):format(self:TimeElapsed()), 3)
			
		end
	end
end

-- Our update event. This triggers every single frame.
tinsert(Event.System.Update.Begin, {update, "LibScriptableUtilsTimer_1_0", "refresh"})
