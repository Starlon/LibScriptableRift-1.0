local MAJOR = "LibScriptableWidgetText-1.0"
local MINOR = 18

assert(LibStub, MAJOR.." requires LibStub")
local WidgetText = LibStub:NewLibrary(MAJOR, MINOR)
if not WidgetText then return end

local WidgetPlugin = LibStub:NewLibrary("LibScriptableWidgetTextPlugin-1.0", 1)

local LibProperty = LibStub("LibScriptableUtilsProperty-1.0", true)
assert(LibProperty, MAJOR .. " requires LibScriptableUtilsProperty-1.0")
local LibTimer = LibStub("LibScriptableUtilsTimer-1.0", true)
assert(LibTimer, MAJOR .. " requires LibScriptableUtilsTimer-1.0")
local LibError = LibStub("LibScriptableUtilsError-1.0", true)
assert(LibError, MAJOR .. " requires LibScriptableUtilsError-1.0")
local LibWidget = LibStub("LibScriptableWidget-1.0", true)
assert(LibWidget, MAJOR .. " requires LibScriptableWidget-1.0")
local PluginUtils = LibStub("LibScriptablePluginUtils-1.0", true)
assert(PluginUtils, MAJOR .. " requires LibScriptablePluginUtils-1.0")
local LibBuffer = LibStub("LibScriptableUtilsBuffer-1.0", true)
assert(LibBuffer, MAJOR .. " requires LibScriptableUtilsBuffer-1.0")

local PINGPONGWAIT = 2

WidgetText.ALIGN_LEFT, WidgetText.ALIGN_CENTER, WidgetText.ALIGN_RIGHT, WidgetText.ALIGN_MARQUEE, WidgetText.ALIGN_AUTOMATIC, WidgetText.ALIGN_PINGPONG = 1, 2, 3, 4, 5, 6
local alignmentList = {"Left", "Center", "Right", "Marquee", "Automatic", "Pingpong"}
local alignmentDict = {Left = 1, Center = 2, Right = 3, Marquee = 4, Automatic = 5, Pingpong = 6}

WidgetText.alignmentList = alignmentList
WidgetText.alignmentDict = alignmentDict

WidgetText.SCROLL_RIGHT, WidgetText.SCROLL_LEFT = 1, 2
local directionList = {"Right", "Left"}
local directionDict = {Right = 1, Left = 2}

WidgetText.directionList = directionList
WidgetText.directionDict = directionDict

local map = {value = "Value", prefix = "Prefix", postfix = "Postfix", precision = "Precision", align = "Alignment", update = "Update", speed = "Scroll Speed", direction ="Direction", cols = "Columns"}

local widgetType = {text = true, rc = true}

WidgetPlugin.New = function(environment)
	environment.ALIGN_LEFT, environment.ALIGN_CENTER, environment.ALIGN_RIGHT, environment.ALIGN_MARQUEE, environment.ALIGN_AUTOMATIC, environment.ALIGN_PINGPONG = 1, 2, 3, 4, 5, 6
	environment.SCROLL_RIGHT, environment.SCROLL_LEFT = 1, 2
end

local textUpdate, scrollUpdate
local pool = setmetatable({}, {__mode = "k"})

if not WidgetText.__index then
	WidgetText.__index = WidgetText
end

local new, del
do
	local pool = setmetatable({}, {__mode = "k"})
	function new()
		local tbl = next(pool)
		if tbl then
			pool[tbl] = nil
		else
			tbl = {}
		end

		return tbl
	end
	function del(tbl)
		for k, v in pairs(tbl) do
			if type(v) == "table" then
				del(v)
			end
		end
		pool[tbl] = true
	end
end

local safe = {}
local function copy(src)
    local dst = new()
	safe[src] = true
    if type(src) == "table" then
        for k, v in pairs(src) do
            if type(v) == "table" then
				v = copy(v)
			end
			dst[k] = v
        end
    end
    return dst
end

WidgetText.defaults = {
	value = '',
	prefix = '',
	postfix = '',
	precision = 0xbabe,
	align = WidgetText.ALIGN_LEFT,
	speed = 0,
	repeating = true,
	direction = WidgetText.SCROLL_RIGHT,
	update = 0,
	cols = 40,
	background = {0, 0, 0, 0}
}

--- Create a new LibScriptableWidgetText object
-- @usage WidgetText:New(visitor, name, config, row, col, layer, errorLevel, callback, timer)
-- @param visitor An LibScriptableCore-1.0 object. There's also a visitor pointer in the script environment provided by LibCore, so you can create new widgets at runtime.
-- @param config This widget's settings
-- @param row This widget's row
-- @param col This widget's column
-- @param layer This widget's layer
-- @param errorLevel The self.errorLevel for this object
-- @param callback Your draw function. The widget is passed as first parameter and data is passed as 2nd.
-- @param timer An optional timer object. This should have a :Start() and :Stop()
-- @return A new LibScriptableWidgetText object
function WidgetText:New(visitor, name, config, row, col, layer, errorLevel, callback, timer)
	assert(name, "WidgetText requires a name.")
	assert(config, "Please provide the marquee with a config")
	assert(config.value, name .. ": Please provide the marquee with a script value")

	local obj = next(pool)

	if obj then
		pool[obj] = nil
		obj.__index = WidgetText
	else
		obj = {}
		obj.options = {}
	end

	setmetatable(obj, self)

	obj.widget = LibWidget:New(obj, visitor, name, config, row, col, layer, widgetType, errorLevel)

	obj.error = LibError:New(MAJOR .. " : " .. name, errorLevel)

	obj.config = config
	obj.callback = callback
	obj.data = data
	obj.timer = timer

	if not timer then
		self.localTimer = true
	end

	obj:Init(config)

	return obj
end

--- Initialize this widget
-- @usage :Init()
-- @return Nothing
function WidgetText:Init(config)
	local name = self.name
	local visitor = self.visitor
	local obj = self
	local errorLevel = self.errorLevel
	local config = config or self.config
	self.config = config
	
	if obj.widget then obj.widget:Del() end
	obj.widget = LibWidget:New(self, self.visitor, self.name, self.config, self.row, self.col, self.layer, widgetType, self.errorLevel)

	if obj.error then obj.error:Del() end
	obj.error = LibError:New(MAJOR .. " : "	.. self.name, self.errorLevel)

	obj.visitor = visitor
	obj.errorLevel = errorLevel or 3

	if obj.value then obj.value:Del() end
	obj.value = LibProperty:New(obj, visitor, name .. " string", config.value, "", config.unit, errorLevel) -- text of marquee
	
	if obj.prefix then obj.prefix:Del() end
	obj.prefix = LibProperty:New(obj, visitor, name .. " prefix", config.prefix, "", config.unit, errorLevel) -- label on the left side
	
	if obj.postfix then obj.postfix:Del() end
	obj.postfix = LibProperty:New(obj, visitor, name .. " postfix", config.postfix, "", config.unit, errorLevel) -- label on right side

	if obj.color then obj.color:Del() end
	obj.color = LibProperty:New(obj, visitor,	name .. " color", config.color, "", config.unit, errorLevel) -- widget's color
	
	obj.precision = config.precision or self.defaults.precision -- number of digits after the decimal point
	obj.align = config.align or self.defaults.align -- alignment: left, center, right, marquee, automatic, pingpong
	obj.update = config.update or self.defaults.update -- update interval
	obj.repeating = config.repeating or self.defaults.repeating -- Whether to use repeating timers
	obj.speed = config.speed or self.defaults.speed -- marquee scrolling speed
	obj.direction = config.direction or self.defaults.direction -- marquee direction
	obj.cols = config.cols or self.defaults.cols -- number of colums in marquee
	obj.bold = config.bold
	obj.offset = 0 -- increment by pixel
	obj.string = "" -- formatted value
	obj.dontRtrim = config.dontRtrim
	obj.background = config.background or copy(self.defaults.background)
	obj.frame = config.frame
	
	if obj.direction == self.SCROLL_LEFT then
		obj.scroll = obj.cols -- marquee starting point
	else
		obj.scroll = 0
	end

    -- /* Init pingpong scroller. start scrolling left (wrong way) to get a delay */
    if (obj.align == self.ALIGN_PINGPONG) then
        obj.direction = self.SCROLL_LEFT;
        obj.delay = PINGPONGWAIT;
    end

	assert(type(obj.update) == "number", "You must provide a text widget with a refresh rate: update")

	if config.update and config.update > 0 then
		obj.timer = obj.timer or LibTimer:New("WidgetText.timer " .. obj.widget.name, obj.update or WidgetText.defaults.update, obj.repeating or WidgetText.defaults.repeating, textUpdate, obj, obj.errorLevel)
	end
	
	if (obj.speed > 0) then
		obj.textTimer = config.textTimer or LibTimer:New("WidgetText.textTimer " .. obj.widget.name, obj.speed, obj.repeating, textScroll, obj, obj.errorLevel)
	end
end

--- Delete a LibScriptableWidgetText object
-- @usage :Del()
-- @return Nothing
function WidgetText:Del()
	local marq = self
	marq:Stop()
	if marq.widget then
		marq.widget:Del()
	end
	if marq.value then
		marq.value:Del()
	end
	if marq.prefix then
		marq.prefix:Del()
	end
	if marq.postfix then
		marq.postfix:Del()
	end
	if marq.timer and marq.localTimer then
		marq.timer:Del()
	end
	if marq.textTimer and marq.localTimer then
		marq.textTimer:Del()
	end
	if marq.error then
		marq.error:Del()
	end
	if marq.color then
		marq.color:Del()
	end
	pool[marq] = true
end

--[[
function WidgetText.IntersectUpdate(texts)
	local frame = GetMouseFocus()
	if frame and frame ~= UIParent and frame ~= WorldFrame then
		for k, widget in pairs(texts) do
			if widget.config.intersect then
				if environment.Intersect(frame, widget.frame, widget.config.intersectxPad1 or widget.config.intersectPad or 0, widget.config.intersectyPad1 or widget.config.intersectPad or 0, widget.config.intersectxPad2 or widget.config.intersectPad or 0, widget.config.intersectyPad2 or widget.config.intersectPad or 0) then
					widget.hidden = true
					widget.frame:Hide()
				elseif not environment.Intersect(frame, widget.frame, widget.config.intersectxPad1 or widget.config.intersectPad or 0, widget.config.intersectyPad1 or widget.config.intersectPad or 0, widget.config.intersectxPad2 or widget.config.intersectPad or 0, widget.config.intersectyPad2 or widget.config.intersectPad or 0) and widget.hidden then
					widget.hidden = false
					widget.frame:Show()
				end
			end
		end
	end
end
]]

WidgetText.IntersectUpdate = LibWidget.IntersectUpdate

--- Start a LibScriptableWidgetText object
-- @usage :Start()
-- @return Nothing
function WidgetText:Start()
	if self.active then return end
	self.error:Print("WidgetText:Start")
	self.oldBuffer = nil
	self:Update()
	if self.timer then
		self.timer:Start()
	end
	if self.textTimer then
		self.textTimer:Start()
	end
	self.active = true
end

--- Stop a LibScriptableWidgetText object
-- @usage :Stop()
-- @return Nothing
function WidgetText:Stop()
	self.error:Print("WidgetText:Stop")
	if self.timer then
		self.timer:Stop()
	end
	if self.textTimer then
		self.textTimer:Stop()
	end
	self.oldBuffer = false
	self.active = false
end

--- Update data. This will be called by this widget's timer, or else call it yourself.
-- @usage :Update()
-- @return Nothing
function WidgetText:Update()
	textUpdate(self)
	if self.speed > 0 then
		textScroll(self)
	end
end

--- Executes the widget's draw function -- the callback parameter
-- @name LibScriptableWidgetText.Draw
-- @param text The text to print.
-- @return Nothing
function WidgetText:Draw()
	if type(self.callback) == "function" then
		self:callback(self.data)
	end
end

local function rtrim(text)
	local pos = 0

	for i = 1, strlen(text) do
		if text:sub(i, i) ~= ' ' then
			pos = i
		end
	end

	if pos == 0 then
		return strtrim(text)
	else
		return text:sub(1, pos) .. strtrim(text:sub(pos + 1))
	end
end


function textScroll(self)
	if not self.prefix or not self.postfix then return end

	self.count = (self.count or 0) + 1
	local pre = self.prefix:P2S()
	local post = self.postfix:P2S()

	local str = self.string .. " "

	local num, len, width, pad = 0, strlen(str), self.cols - strlen(pre) - strlen(post), 0

	local srcPtr, dstPtr = 0, 0

	local src = LibBuffer:New(MAJOR .. ": " .. self.widget.name .. "._src", 0, " ", self.errorLevel)
	local dst = LibBuffer:New(MAJOR .. ": " .. self.widget.name .. "._dst ", self.cols, " ", self.errorLevel)

	src:Resize(0)
	dst:Resize(self.cols)

    if width < 0 then
        width = 0
	end

	if self.align == self.ALIGN_LEFT then
		pad = 0
	elseif self.align == self.ALIGN_CENTER then
		pad = (width - len) / 2
		if pad < 0 then
			pad = 0
		end
	elseif self.align == self.ALIGN_RIGHT then
		pad = width - len
		if pad < 0 then
			pad = 0
		end
	elseif self.align == self.ALIGN_AUTOMATIC then
		if len <= width then
			pad = 0
		end
	elseif self.align == self.ALIGN_MARQUEE then
		pad = self.scroll
		if self.direction == self.SCROLL_LEFT then
			self.scroll = self.scroll - 1
			if self.scroll < 0 then
				self.scroll = self.cols
			end

		else
			self.scroll = self.scroll + 1
			if self.scroll > self.cols then
				self.scroll = 0
			end
		end
	elseif self.align == self.ALIGN_PINGPONG then
		if len <= width then
			pad = self.scroll
			if self.direction == self.SCROLL_RIGHT then
				self.scroll = self.scroll + 1
				if self.scroll >= width - len then
					self.direction = self.SCROLL_LEFT
				end
			else
				self.scroll = self.scroll - 1
				if self.scroll < 0 then
					self.direction = self.SCROLL_RIGHT
				end
			end
		else
			pad = 0
		end
	else
		pad = 0
		self.error:Print("No alignment specified")
	end
	
    dstPtr = 0;
    local num = 0;

    -- /* process prefix */
    src:FromString(pre)
    while (num < self.cols) do
        if (srcPtr >= src:Size()) then
            break
		end
		if dstPtr >= self.cols then
			break
		end
		dst:Replace(dstPtr, src.buffer[srcPtr]) --PluginUtils:replaceText(dst, dstPtr, src, srcPtr)
		dstPtr = dstPtr + 1
		srcPtr = srcPtr + 1
        num = num + 1
    end

    src:FromString(str)
    srcPtr = 0;

	local offset = pad

    if(offset < 0) then
        offset = 0;
	end

	-- pad beginning
	while pad > 0 and num <= self.cols do
		dst:Replace(dstPtr, " ")
		dstPtr = dstPtr + 1
		num = num + 1
		pad = pad - 1
	end

    --/* copy content */
    while (num < self.cols) do
		if dstPtr >= self.cols then
			break
		end
        if (srcPtr >= src:Size()) then
            break;
		end
		local offset = pad
		if offset < 0 then offset = 0 end
		dst:Replace(dstPtr, src.buffer[srcPtr])
		dstPtr = dstPtr + 1
		srcPtr = srcPtr + 1
        num = num + 1
    end

    len = src:Size()

	-- pad end
    while (num < self.cols - len) do
		if dstPtr >= self.cols then
			break
		end
		dst:Replace(dstPtr, " ")
		dstPtr = dstPtr + 1
        num = num + 1;
    end

    srcPtr = 0;
    src:FromString(post)

    --/* process postfix */
    while (num < self.cols) do
		if dstPtr >= self.cols then
			break
		end
        if (srcPtr >= src:Size()) then
            break;
		end
		dst:Replace(dstPtr, src.buffer[srcPtr])
		dstPtr = dstPtr + 1
		srcPtr = srcPtr + 1
        num = num + 1
    end

	if self.dontRtrim then
		self.buffer = dst:AsString()
	else
		self.buffer = rtrim(dst:AsString())
	end

	if self.buffer ~= self.oldBuffer then
		self:Draw()
		self.oldBuffer = self.buffer
	end

	dst:Del()
	src:Del()
end


function textUpdate(self)
	assert(self.value, self.name .. ": WidgetText has no value")
	if not self.prefix then return self.error:Print("WidgetText needs a prefix")end
	if not self.postfix then return self.error:Print("WidgetText needs a postfix") end
	if not self.color then return self.error:Print("WidgetText needs a color") end

	self._update = 1
	self.visitor.environment.self = self
	self._update = self._update + self.prefix:Eval()
	self._update = self._update + self.postfix:Eval()
	self.value:Eval()
	self.color:Eval()
	self.visitor.environment.self = nil

    -- /* str or number? */
    if (self.precision == 0xBABE) then
        str = self.value:P2S();
    else
		--[[
        local number = self.value:P2N();
        local width = self.cols - strlen(self.prefix:P2S()) - strlen(self.postfix:P2S());
        local precision = self.precision;
        --/* print zero bytes so we can specify NULL as target  */
        --/* and get the length of the resulting str */
		local text = ("%.*f"):format(precision, number)
		local size = strlen(text)
        --/* number does not fit into field width: try to reduce precision */
        if (width < 0) then
            width = 0;
		end
        if (size > width and precision > 0) then
            local delta = size - width;
            if (delta > precision) then
                delta = precision;
			end
            precision = precision - delta;
            size = size - delta;
            --/* zero precision: omit decimal point, too */
            if (precision == 0) then
                size = size - 1
			end
        end
        ---/* number still doesn't fit: display '*****'  */
        if (size > width) then
            str.resize(width);
            for i = 0, width do
                str[i] = '*';
			end
        else
            str = text
        end
		]]
    end

    if str == "" or str ~= self.string then
        self._update = self._update + 1;
        self.string = str;
    end

    --/* something has changed and should be updated */
    if (self._update > 0) then
		--[[
        /* if there's a marquee scroller active, it has its own */
        /* update callback timer, so we do nothing here; otherwise */
        /* we simply call this scroll callback directly */
		]]
        if (self.align ~= self.ALIGN_MARQUEE and self.align ~= self.ALIGN_AUTOMATIC and self.align ~= self.ALIGN_PINGPONG) then
            textScroll(self)
			return false
        end

    end

	return true
end

local strataNameList = {
	"TOOLTIP", "FULLSCREEN_DIALOG", "FULLSCREEN", "DIALOG", "HIGH", "MEDIUM", "LOW", "BACKGROUND"
}

local strataLocaleList = {
	"Tooltip", "Fullscreen Dialog", "Fullscreen", "Dialog", "High", "Medium", "Low", "Background"
}

--- Get an Ace3 option table. Plug this into a group type's args.
-- @param db The database table
-- @param callback Provide this if you want to execute the callback once an option is changed
-- @param data Some data to pass when executing the callback
-- @return An Ace3 options table -- `name.args = options`.
function WidgetText:GetOptions(db, callback, data)
		local defaults = WidgetText.defaults
		local options = {
			enable = {
				name = "Enable",
				desc = "Enable text widget",
				type = "toggle",
				get = function() return db.enabled end,
				set = function(info, v) 
					db.enabled = v;
					db["enabledDirty"] = true 
					if type(callback) == "function" then
						callback(data)
					end
				end,
				order = 1
			},
			precision = {
				name = "Precision",
				type = "input",
				pattern = "%d",
				get = function()
					return tostring(db.precision or WidgetText.defaults.precision)
				end,
				set = function(info, v)
					db.precision = tonumber(v)
					db["precisionDirty"] = true
					if type(callback) == "function" then
						callback(data)
					end
				end,
				order = 2
			},
			align = {
				name = "Alignment",
				type = "select",
				values = alignmentList,
				get = function()
					return db.align or WidgetText.defaults.align
				end,
				set = function(info, v)
					db.align = v
					db["alignDirty"] = true
					if type(callback) == "function" then
						callback(data)
					end
				end,
				order = 3
			},
			update = {
				name = "Update",
				type = "input",
				pattern = "%d",
				get = function()
					return tostring(db.update or WidgetText.defaults.update)
				end,
				set = function(info, v)
					db.update = tonumber(v)
					db["updateDirty"] = true
					if type(callback) == "function" then
						callback(data)
					end
				end,
				order = 4
			},
			speed = {
				name = "Scroll Speed",
				type = "input",
				pattern = "%d",
				get = function()
					return tostring(db.speed or WidgetText.defaults.speed)
				end,
				set = function(info, v)
					db.speed = tonumber(v)
					db["speedDirty"] = true
					if type(callback) == "function" then
						callback(data)
					end
				end,
				order = 5
			},
			direction = {
				name = "Direction",
				type = "select",
				values = directionList,
				get = function()
					return tostring(db.direction or WidgetText.defaults.direction)
				end,
				set = function(info, v)
					db.direction = tonumber(v)
					db["directionDirty"] = true
					if type(callback) == "function" then
						callback(data)
					end
				end,
				order = 6
			},
			cols = {
				name = "Columns",
				type = "input",
				pattern = "%d",
				get = function()
					return tostring(db.cols or WidgetText.defaults.cols)
				end,
				set = function(info, v)
					db.cols = tonumber(v)
					db["colsDirty"] = true
					if type(callback) == "function" then
						callback(data)
					end
				end,
				order = 7
			},
			bold = {
				name = "Bold",
				type = "toggle",
				get = function()
					return db.bold or WidgetText.defaults.bold
				end,
				set = function(info, val)
					db.bold = val
					db["boldDirty"] = true
					if type(callback) == "function" then
						callback(data)
					end
				end,
				order = 9
			},
			background = {
				name = "Background Color",
				desc = "This will be the widget's backdrop.",
				type = "color",
				hasAlpha = true,
				get = function() return unpack(db.background or WidgetText.defaults.background) end,
				set = function(info, r, g, b, a)
					if type(db.background) ~= "table" then db.background = {} return end
					db.background[1] = r
					db.background[2] = g
					db.background[3] = b
					db.background[4] = a
					db["backgroundDirty"] = true
					if type(callback) == "function" then
						callback(data)
					end
				end,
				order = 11
			},
			value = {
				name = "Value",
				desc = "Enter this widget's Lua script",
				type = "input",
				width = "full",
				multiline = true,
				get = function()
					return db.value
				end,
				set = function(info, v)
					db.value = v
					db["valueDirty"] = true
					if type(callback) == "function" then
						callback(data)
					end
				end,
				order = 11
			},
			prefix = {
				name = "Prefix",
				desc = "Enter this widget's prefix script",
				type = "input",
				width = "full",
				multiline = true,
				get = function()
					return db.prefix
				end,
				set = function(info, v)
					db.prefix = v
					db["prefixDirty"] = true
					if type(callback) == "function" then
						callback(data)
					end
				end,
				order = 12
			},
			postfix = {
				name = "Postfix",
				desc = "Enter this widget's postfix script",
				type = "input",
				width = "full",
				multiline = true,
				get = function()
					return db.postfix
				end,
				set = function(info, v)
					db.postfix = v
					db["postfixDirty"] = true
					if type(callback) == "function" then
						callback(data)
					end
				end,
				order = 13
			},
			color = {
				name = "Color",
				desc = "Enter this widget's color script",
				type = "input",
				width = "full",
				multiline = true,
				get = function()
					return db.color
				end,
				set = function(info, v)
					db.color = v
					db["colorDirty"] = true
					if type(callback) == "function" then
						callback(data)
					end
				end,
				order = 14
			},

		}
	options.widget = LibWidget:GetOptions(db, callback, data)
	return options
end
