-- Afterglow UI Library Loader
-- Supports both local and remote loading via GitHub

local Loader = {}
Loader.__index = Loader

local GITHUB_BASE_URL = "https://raw.githubusercontent.com/vv7z/Afterglow-UI/main"
local USE_REMOTE = true  -- Set to false to load locally

-- List of modules to load (in order)
local MODULES = {
	-- Config
	"config/Constants",
	"config/Defaults", 
	"config/Theme",
	
	-- Services
	"services/TweenService",
	"services/InputService",
	"services/RunService",
	
	-- Utils
	"utils/Signal",
	"utils/Text",
	"utils/Instances",
	"utils/Math",
	"utils/Tween",
	
	-- Input
	"input/Mouse",
	"input/Drag",
	"input/KeybindListener",
	
	-- Layout
	"layout/Padding",
	"layout/ColumnLayout",
	"layout/AutoSize",
	
	-- Overlay
	"overlay/HoverOverlay",
	"overlay/PopupManager",
	"overlay/ContextMenu",
	
	-- Search
	"search/SearchIndex",
	"search/SearchFilter",
	
	-- Controls - Mixins
	"controls/mixins/ClickRipple",
	"controls/mixins/ColorPicker",
	"controls/mixins/HoverStroke",
	"controls/mixins/Keybind",
	
	-- Controls
	"controls/Label",
	"controls/Button",
	"controls/Toggle",
	"controls/Checkbox",
	"controls/Slider",
	"controls/Dropdown",
	
	-- Core
	"core/Groupbox",
	"core/Tab",
	"core/Window",
	"core/Library",
}

-- Cache for loaded modules
local _moduleCache = {}

-- Load a module from remote source
function Loader:_LoadRemote(modulePath)
	if _moduleCache[modulePath] then
		return _moduleCache[modulePath]
	end
	
	local url = GITHUB_BASE_URL .. "/Afterglow/" .. modulePath .. ".lua"
	local success, result = pcall(function()
		return game:HttpGet(url)
	end)
	
	if not success then
		error("Failed to load remote module: " .. modulePath .. "\nError: " .. tostring(result))
	end
	
	-- Execute the module code
	local moduleFunc, err = loadstring(result, modulePath)
	if not moduleFunc then
		error("Failed to parse module: " .. modulePath .. "\nError: " .. tostring(err))
	end
	
	-- Create a fake script object for require() calls within the module
	local fakeScript = {}
	fakeScript.Parent = {Name = "Afterglow"}
	
	-- Override require to handle local requires
	local originalRequire = require
	function fakeScript.require(path)
		return Loader:_RequireModule(path)
	end
	
	-- Execute module in safe environment
	local env = setmetatable({
		require = function(path)
			return Loader:_RequireModule(path)
		end,
		script = fakeScript,
	}, {__index = getfenv(0)})
	
	setfenv(moduleFunc, env)
	local result = moduleFunc()
	
	_moduleCache[modulePath] = result
	return result
end

-- Load a module from local source (for testing)
function Loader:_LoadLocal(modulePath)
	if _moduleCache[modulePath] then
		return _moduleCache[modulePath]
	end
	
	-- Try to find the module in the workspace
	local parts = modulePath:split("/")
	local current = script.Parent  -- Assuming loader is in root Afterglow folder
	
	for _, part in ipairs(parts) do
		current = current:FindFirstChild(part)
		if not current then
			error("Failed to find local module: " .. modulePath)
		end
	end
	
	if current:IsA("ModuleScript") then
		local result = require(current)
		_moduleCache[modulePath] = result
		return result
	else
		error("Module not a ModuleScript: " .. modulePath)
	end
end

-- Require a module with path mapping
function Loader:_RequireModule(path)
	-- Handle relative paths like "script.Parent.Parent"
	if path:find("script%.Parent") then
		-- This is a relative path, execute it in the current context
		return loadstring("return " .. path)()
	end
	
	-- Handle absolute paths from Afterglow
	if path:find("^Afterglow") then
		path = path:gsub("^Afterglow%.?", ""):gsub("%.", "/")
		return Loader:_LoadModule(path)
	end
	
	-- Otherwise load the module
	return Loader:_LoadModule(path)
end

-- Core module loading function
function Loader:_LoadModule(modulePath)
	if USE_REMOTE then
		return self:_LoadRemote(modulePath)
	else
		return self:_LoadLocal(modulePath)
	end
end

-- Load all modules
function Loader:LoadAll()
	local modules = {}
	
	print("[Afterglow] Loading " .. #MODULES .. " modules...")
	
	for i, modulePath in ipairs(MODULES) do
		local success, result = pcall(function()
			return self:_LoadModule(modulePath)
		end)
		
		if success then
			modules[modulePath] = result
			print(string.format("[Afterglow] ✓ Loaded %d/%d: %s", i, #MODULES, modulePath))
		else
			print(string.format("[Afterglow] ✗ Failed to load %s: %s", modulePath, tostring(result)))
			error("Module load failed: " .. modulePath)
		end
	end
	
	print("[Afterglow] ✓ All modules loaded successfully!")
	return modules
end

-- Load a specific module
function Loader:Load(modulePath)
	return self:_LoadModule(modulePath)
end

-- Clear cache
function Loader:ClearCache()
	_moduleCache = {}
end

-- Create and return the Afterglow library
function Loader:Initialize()
	self:LoadAll()
	
	-- Load and return the main library
	local Afterglow = self:_LoadModule("init")
	return Afterglow
end

-- Public API
return Loader:Initialize()
