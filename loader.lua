-- Afterglow UI Library - Simple LoadString Loader
-- Usage: local Afterglow = loadstring(game:HttpGet("https://raw.githubusercontent.com/vv7z/Afterglow-UI/main/loader.lua"))()

local GITHUB_URL = "https://raw.githubusercontent.com/vv7z/Afterglow-UI/main"

-- Module cache
local cache = {}

-- Path mapping for requires
local pathMap = {
	["config.Constants"] = "config/Constants",
	["config.Defaults"] = "config/Defaults",
	["config.Theme"] = "config/Theme",
	["services.TweenService"] = "services/TweenService",
	["services.InputService"] = "services/InputService",
	["services.RunService"] = "services/RunService",
	["utils.Signal"] = "utils/Signal",
	["utils.Text"] = "utils/Text",
	["utils.Instances"] = "utils/Instances",
	["utils.Math"] = "utils/Math",
	["utils.Tween"] = "utils/Tween",
	["input.Mouse"] = "input/Mouse",
	["input.Drag"] = "input/Drag",
	["input.KeybindListener"] = "input/KeybindListener",
	["layout.Padding"] = "layout/Padding",
	["layout.ColumnLayout"] = "layout/ColumnLayout",
	["layout.AutoSize"] = "layout/AutoSize",
	["overlay.HoverOverlay"] = "overlay/HoverOverlay",
	["overlay.PopupManager"] = "overlay/PopupManager",
	["overlay.ContextMenu"] = "overlay/ContextMenu",
	["search.SearchIndex"] = "search/SearchIndex",
	["search.SearchFilter"] = "search/SearchFilter",
	["controls.mixins.ClickRipple"] = "controls/mixins/ClickRipple",
	["controls.mixins.ColorPicker"] = "controls/mixins/ColorPicker",
	["controls.mixins.HoverStroke"] = "controls/mixins/HoverStroke",
	["controls.mixins.Keybind"] = "controls/mixins/Keybind",
	["controls.Label"] = "controls/Label",
	["controls.Button"] = "controls/Button",
	["controls.Toggle"] = "controls/Toggle",
	["controls.Checkbox"] = "controls/Checkbox",
	["controls.Slider"] = "controls/Slider",
	["controls.Dropdown"] = "controls/Dropdown",
	["core.Groupbox"] = "core/Groupbox",
	["core.Tab"] = "core/Tab",
	["core.Window"] = "core/Window",
	["core.Library"] = "core/Library",
}

local function loadModule(modulePath)
	if cache[modulePath] then
		return cache[modulePath]
	end
	
	local url = GITHUB_URL .. "/Afterglow/" .. modulePath .. ".lua"
	local success, result = pcall(function()
		return game:HttpGet(url)
	end)
	
	if not success then
		error("Failed to download: " .. modulePath .. "\n" .. tostring(result))
	end
	
	local func, parseErr = loadstring(result, modulePath)
	if not func then
		error("Failed to parse: " .. modulePath .. "\n" .. tostring(parseErr))
	end
	
	-- Create environment with require function
	local env = setmetatable({
		require = function(path)
			-- Handle relative path conversions
			local mappedPath = pathMap[path] or path
			return loadModule(mappedPath)
		end,
		script = {Parent = {Parent = {}}},  -- Fake script object
		game = game,
		getfenv = getfenv,
		setfenv = setfenv,
		print = print,
		warn = warn,
		error = error,
		task = task,
		coroutine = coroutine,
		Instance = Instance,
		Color3 = Color3,
		UDim2 = UDim2,
		UDim = UDim,
		Vector2 = Vector2,
		Enum = Enum,
		TweenInfo = TweenInfo,
		ColorSequence = ColorSequence,
		ColorSequenceKeypoint = ColorSequenceKeypoint,
		NumberSequence = NumberSequence,
		NumberSequenceKeypoint = NumberSequenceKeypoint,
		math = math,
		table = table,
		string = string,
		tostring = tostring,
		tonumber = tonumber,
		typeof = typeof,
		loadstring = loadstring,
	}, {__index = getfenv(0)})
	
	setfenv(func, env)
	local result, moduleErr = pcall(func)
	
	if not result then
		error("Module execution failed: " .. modulePath .. "\n" .. tostring(moduleErr))
	end
	
	cache[modulePath] = moduleErr  -- moduleErr is actually the return value after pcall
	return moduleErr
end

-- Load order matters - dependencies first
local modules = {}

-- Config
modules.Constants = loadModule("config/Constants")
modules.Defaults = loadModule("config/Defaults")
modules.Theme = loadModule("config/Theme")

-- Services  
modules.TweenService = loadModule("services/TweenService")
modules.InputService = loadModule("services/InputService")
modules.RunService = loadModule("services/RunService")

-- Utils
modules.Signal = loadModule("utils/Signal")
modules.Text = loadModule("utils/Text")
modules.Instances = loadModule("utils/Instances")
modules.Math = loadModule("utils/Math")
modules.Tween = loadModule("utils/Tween")

-- Input
modules.Mouse = loadModule("input/Mouse")
modules.Drag = loadModule("input/Drag")
modules.KeybindListener = loadModule("input/KeybindListener")

-- Layout
modules.Padding = loadModule("layout/Padding")
modules.ColumnLayout = loadModule("layout/ColumnLayout")
modules.AutoSize = loadModule("layout/AutoSize")

-- Overlay
modules.HoverOverlay = loadModule("overlay/HoverOverlay")
modules.PopupManager = loadModule("overlay/PopupManager")
modules.ContextMenu = loadModule("overlay/ContextMenu")

-- Search
modules.SearchIndex = loadModule("search/SearchIndex")
modules.SearchFilter = loadModule("search/SearchFilter")

-- Controls - Mixins
modules.ClickRipple = loadModule("controls/mixins/ClickRipple")
modules.ColorPicker = loadModule("controls/mixins/ColorPicker")
modules.HoverStroke = loadModule("controls/mixins/HoverStroke")
modules.Keybind = loadModule("controls/mixins/Keybind")

-- Controls
modules.Label = loadModule("controls/Label")
modules.Button = loadModule("controls/Button")
modules.Toggle = loadModule("controls/Toggle")
modules.Checkbox = loadModule("controls/Checkbox")
modules.Slider = loadModule("controls/Slider")
modules.Dropdown = loadModule("controls/Dropdown")

-- Core
modules.Groupbox = loadModule("core/Groupbox")
modules.Tab = loadModule("core/Tab")
modules.Window = loadModule("core/Window")
modules.Library = loadModule("core/Library")

-- Main init
local Afterglow = loadModule("init")

print("[Afterglow] UI Library loaded successfully!")

return Afterglow
