-- Afterglow UI Library - Smart LoadString Loader
-- Usage: local Afterglow = loadstring(game:HttpGet("https://raw.githubusercontent.com/vv7z/Afterglow-UI/main/loader.lua"))()
-- This loader automatically reads the manifest to discover all modules without hardcoding

local GITHUB_URL = "https://raw.githubusercontent.com/vv7z/Afterglow-UI/main"

-- Module cache
local cache = {}

-- Manifest cache
local manifest = nil

-- Load and parse the manifest
local function loadManifest()
	if manifest then return manifest end
	
	local manifestUrl = GITHUB_URL .. "/Afterglow/manifest.json"
	local success, result = pcall(function()
		return game:HttpGet(manifestUrl)
	end)
	
	if not success then
		error("Failed to load manifest from GitHub: " .. tostring(result))
	end
	
	-- Simple JSON parser for manifest
	manifest = {}
	manifest.modules = {}
	manifest.loadOrder = {}
	
	-- Extract loadOrder array from JSON (more reliable)
	local inLoadOrder = false
	local lastQuote = 1
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
		return cache[cacheKey]
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
			-- Convert dot notation to file path
			local modulePath = pathMap[path] or dotsToPath(path)
			return loadModule(modulePath, pathMap)
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
	
	cache[cacheKey] = moduleErr  -- moduleErr is actually the return value after pcall
	return moduleErr
end

-- Load all modules from manifest
local function initializeLoader()
	print("[Afterglow] Loading manifest...")
	local manifestData = loadManifest()
	local pathMap = buildPathMap()
	
	print("[Afterglow] Loading " .. #manifestData.loadOrder .. " modules in order...")
	
	-- Use the load order from manifest
	for i, modulePath in ipairs(manifestData.loadOrder) do
		if modulePath ~= "init" then  -- Skip init, load it last
			local success, result = pcall(function()
				return loadModule(modulePath, pathMap)
			end)
			
			if success then
				print(string.format("[Afterglow] ✓ Loaded %d/%d: %s", i, #manifestData.loadOrder - 1, modulePath))
			else
				error(string.format("[Afterglow] ✗ Failed to load %s: %s", modulePath, tostring(result)))
			end
		end
	end
	
	-- Load init last
	print("[Afterglow] Loading main library...")
	local Afterglow = loadModule("init", pathMap)
	
	print("[Afterglow] ✓ All modules loaded successfully!")
	return Afterglow
end

-- Initialize and return the library
local Afterglow = initializeLoader()

return Afterglow
