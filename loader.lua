-- Afterglow UI Library - Simple LoadString Loader
-- Usage: local Afterglow = loadstring(game:HttpGet("https://raw.githubusercontent.com/vv7z/Afterglow-UI/main/loader.lua"))()

local GITHUB_URL = "https://raw.githubusercontent.com/vv7z/Afterglow-UI/main"

local function loadModule(modulePath)
	local url = GITHUB_URL .. "/Afterglow/" .. modulePath .. ".lua"
	local success, result = pcall(function()
		return game:HttpGet(url)
	end)
	
	if not success then
		error("Failed to download: " .. modulePath)
	end
	
	local func = loadstring(result, modulePath)
	if not func then
		error("Failed to parse: " .. modulePath)
	end
	
	return func()
end

-- Module cache
local cache = {}

-- Create a require function for modules
local function require(modulePath)
	if cache[modulePath] then
		return cache[modulePath]
	end
	
	-- Map relative requires
	if modulePath:sub(1, 6) == "script" then
		return nil  -- Skip script references
	end
	
	-- Load from cache first
	local result = loadModule(modulePath)
	cache[modulePath] = result
	return result
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
