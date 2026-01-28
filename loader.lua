-- Afterglow UI Library - Smart LoadString Loader
-- Usage: local Afterglow = loadstring(game:HttpGet("https://raw.githubusercontent.com/vv7z/Afterglow-UI/main/loader.lua"))()
-- This loader automatically reads the manifest to discover all modules without hardcoding

local GITHUB_URL = "https://raw.githubusercontent.com/vv7z/Afterglow-UI/main"
local DEBUG = true  -- Set to false to disable debug logging

-- Debug logging function
local function debugLog(level, message)
	if not DEBUG then return end
	local timestamp = os.date("%H:%M:%S")
	local prefix = "[Afterglow:" .. level .. "]" .. " (" .. timestamp .. ")"
	if level == "ERROR" then
		warn(prefix .. " " .. message)
	elseif level == "WARN" then
		warn(prefix .. " " .. message)
	else
		print(prefix .. " " .. message)
	end
end

-- Module cache
local cache = {}

-- Manifest cache
local manifest = nil

-- Load and parse the manifest
local function loadManifest()
	if manifest then 
		debugLog("DEBUG", "Using cached manifest")
		return manifest 
	end
	
	local manifestUrl = GITHUB_URL .. "/Afterglow/manifest.json"
	debugLog("INFO", "Attempting to fetch manifest from: " .. manifestUrl)
	local success, result = pcall(function()
		return game:HttpGet(manifestUrl)
	end)
	
	if not success then
		debugLog("ERROR", "Failed to load manifest from GitHub: " .. tostring(result))
		error("Failed to load manifest from GitHub: " .. tostring(result))
	end
	
	debugLog("INFO", "Manifest fetched successfully (" .. #result .. " bytes)")
	
	-- Simple JSON parser for manifest
	debugLog("DEBUG", "Parsing manifest JSON...")
	manifest = {}
	manifest.modules = {}
	manifest.loadOrder = {}
	
	-- Extract loadOrder array from JSON (more reliable)
	local inLoadOrder = false
	local lastQuote = 1
	local parseStartTime = tick()
	for i = 1, #result do
		if result:sub(i, i + 8) == "loadOrder" then
			inLoadOrder = true
		end
		if inLoadOrder and result:sub(i, i) == "[" then
			-- Found the start of loadOrder array
			local j = i + 1
			while j < #result do
				local char = result:sub(j, j)
				if char == '"' then
					local start = j + 1
					j = j + 1
					while j < #result and result:sub(j, j) ~= '"' do
						j = j + 1
					end
					table.insert(manifest.loadOrder, result:sub(start, j - 1))
				elseif char == "]" then
					break
				end
				j = j + 1
			end
			break
		end
	end
	
	-- Fallback: extract all quoted strings if loadOrder parsing fails
	if #manifest.loadOrder == 0 then
		debugLog("WARN", "Primary JSON parsing failed, attempting fallback method...")
		for modulePath in result:gmatch('"([^"]+)"') do
			if not modulePath:find("version") and modulePath ~= "modules" and modulePath ~= "loadOrder" then
				table.insert(manifest.loadOrder, modulePath)
			end
		end
	end
	
	-- Build modules list from loadOrder
	for _, path in ipairs(manifest.loadOrder) do
		manifest.modules[path] = true
	end
	
	debugLog("INFO", "Manifest parsed successfully: " .. #manifest.loadOrder .. " modules loaded in " .. tostring(math.round((tick() - parseStartTime) * 1000)) .. "ms")
	return manifest
end

-- Convert module path to dot notation for require()
local function pathToDots(filePath)
	return filePath:gsub("/", ".")
end

-- Convert dot notation back to file path
local function dotsToPath(moduleName)
	return moduleName:gsub("%.", "/")
end

-- Build path map from manifest
local function buildPathMap()
	local manifestData = loadManifest()
	local pathMap = {}
	
	for _, modulePath in ipairs(manifestData.loadOrder) do
		local dotPath = pathToDots(modulePath)
		pathMap[dotPath] = modulePath
	end
	
	return pathMap
end

-- Load a single module from GitHub
local function loadModule(modulePath, pathMap)
	-- Check cache first
	local cacheKey = modulePath
	if cache[cacheKey] then
		debugLog("DEBUG", "Using cached module: " .. modulePath)
		return cache[cacheKey]
	end
	
	local url = GITHUB_URL .. "/Afterglow/" .. modulePath .. ".lua"
	debugLog("DEBUG", "Fetching module from: " .. url)
	local success, result = pcall(function()
		return game:HttpGet(url)
	end)
	
	if not success then
		debugLog("ERROR", "Failed to download module: " .. modulePath)
		debugLog("ERROR", "HTTP Error: " .. tostring(result))
		error("Failed to download: " .. modulePath .. "\n" .. tostring(result))
	end
	
	debugLog("DEBUG", "Module " .. modulePath .. " downloaded (" .. #result .. " bytes)")
	
	local func, parseErr = loadstring(result, modulePath)
	if not func then
		debugLog("ERROR", "Failed to parse module: " .. modulePath)
		debugLog("ERROR", "Parse Error: " .. tostring(parseErr))
		error("Failed to parse: " .. modulePath .. "\n" .. tostring(parseErr))
	end
	
	debugLog("DEBUG", "Module " .. modulePath .. " parsed successfully")
	
	-- Create environment with require function
	local env = setmetatable({
		require = function(path)
			-- Convert dot notation to file path
			local modulePath = pathMap[path] or dotsToPath(path)
			debugLog("DEBUG", "require() called: request='" .. path .. "' -> loading '" .. modulePath .. "'")
			local success, result = pcall(function()
				return loadModule(modulePath, pathMap)
			end)
			if not success then
				debugLog("ERROR", "require() failed for '" .. path .. "': " .. tostring(result))
				error("require() failed for '" .. path .. "': " .. tostring(result))
			end
			return result
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
	debugLog("DEBUG", "Executing module: " .. modulePath)
	local result, moduleErr = pcall(func)
	
	if not result then
		debugLog("ERROR", "Module execution failed: " .. modulePath)
		debugLog("ERROR", "Execution Error: " .. tostring(moduleErr))
		error("Module execution failed: " .. modulePath .. "\n" .. tostring(moduleErr))
	end
	
	debugLog("DEBUG", "Module " .. modulePath .. " executed successfully")
	cache[cacheKey] = moduleErr  -- moduleErr is actually the return value after pcall
	return moduleErr
end

-- Load all modules from manifest
local function initializeLoader()
	debugLog("INFO", "=== Afterglow Loader Initialization Starting ===")
	debugLog("INFO", "GitHub Base URL: " .. GITHUB_URL)
	
	local overallStartTime = tick()
	local manifestData = nil
	local success, manifestErr = pcall(function()
		manifestData = loadManifest()
	end)
	
	if not success then
		debugLog("ERROR", "Critical: Failed to load manifest - " .. tostring(manifestErr))
		error(tostring(manifestErr))
	end
	
	local pathMap = buildPathMap()
	debugLog("INFO", "Path map built with " .. table.getn(pathMap) .. " entries")
	
	debugLog("INFO", "Starting load sequence for " .. #manifestData.loadOrder .. " modules...")
	
	-- Use the load order from manifest
	local loadedCount = 0
	for i, modulePath in ipairs(manifestData.loadOrder) do
		if modulePath ~= "init" then  -- Skip init, load it last
			local moduleStartTime = tick()
			local success, result = pcall(function()
				return loadModule(modulePath, pathMap)
			end)
			
			local loadTime = math.round((tick() - moduleStartTime) * 1000)
			if success then
				loadedCount = loadedCount + 1
				debugLog("INFO", string.format("✓ [%d/%d] Loaded %s (%dms)", loadedCount, #manifestData.loadOrder - 1, modulePath, loadTime))
			else
				debugLog("ERROR", string.format("✗ [%d/%d] Failed to load %s (%dms)", i, #manifestData.loadOrder, modulePath, loadTime))
				debugLog("ERROR", "Module load error details: " .. tostring(result))
				error(string.format("[Afterglow] ✗ Failed to load %s: %s", modulePath, tostring(result)))
			end
		end
	end

	-- Load init last
	debugLog("INFO", "Loading main library (init.lua)...")
	local initStartTime = tick()
	local Afterglow = loadModule("init", pathMap)
	local initLoadTime = math.round((tick() - initStartTime) * 1000)
	
	local totalTime = math.round((tick() - overallStartTime) * 1000)
	debugLog("INFO", "✓ Init loaded successfully (" .. initLoadTime .. "ms)")
	debugLog("INFO", "=== All modules loaded successfully in " .. totalTime .. "ms ===")
	
	return Afterglow
end

-- Initialize and return the library
local Afterglow = initializeLoader()

return Afterglow
