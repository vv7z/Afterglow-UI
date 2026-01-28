-- Afterglow UI Library - Demo Loader
-- Usage: local Afterglow = loadstring(game:HttpGet("https://raw.githubusercontent.com/vv7z/Afterglow-UI/main/loader.lua"))()
-- This loader reads the manifest, shows a themed loading UI, and opens a demo window

local GITHUB_URL = "https://raw.githubusercontent.com/vv7z/Afterglow-UI/main"
local DEBUG = false  -- Console output is reserved for errors only

-- Loader UI (simple, theme-aligned)
local RunService = game:GetService("RunService")

local LOADER_THEME = {
	ACCENT = Color3.fromHex("#d177b0"),
	PRIMARY_BG = Color3.fromRGB(20, 20, 20),
	TERTIARY_BG = Color3.fromRGB(30, 30, 30),
	STROKE = Color3.fromRGB(55, 55, 55),
	TEXT_PRIMARY = Color3.fromRGB(200, 200, 200),
	TEXT_SECONDARY = Color3.fromRGB(160, 160, 160),
}

local function resolveGuiParent()
	if typeof(gethui) == "function" then
		local ok, ui = pcall(gethui)
		if ok and ui then
			return ui
		end
	end

	local okCore, coreGui = pcall(function()
		return game:GetService("CoreGui")
	end)
	if okCore and coreGui then
		return coreGui
	end

	local okPlayers, players = pcall(function()
		return game:GetService("Players")
	end)
	if okPlayers and players and players.LocalPlayer then
		return players.LocalPlayer:WaitForChild("PlayerGui")
	end

	return nil
end

local function createLoaderUi()
	local guiParent = resolveGuiParent()
	if not guiParent then
		return nil
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AfterglowLoader"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	if syn and syn.protect_gui then
		pcall(syn.protect_gui, screenGui)
	end

	screenGui.Parent = guiParent

	local container = Instance.new("Frame")
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = UDim2.new(0.5, 0, 0.5, 0)
	container.Size = UDim2.new(0, 420, 0, 140)
	container.BackgroundColor3 = LOADER_THEME.PRIMARY_BG
	container.BorderSizePixel = 0
	container.Parent = screenGui

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 8)
	containerCorner.Parent = container

	local containerStroke = Instance.new("UIStroke")
	containerStroke.Color = LOADER_THEME.STROKE
	containerStroke.Thickness = 1
	containerStroke.Parent = container

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.new(0, 16, 0, 12)
	titleLabel.Size = UDim2.new(1, -32, 0, 18)
	titleLabel.Text = "Afterglow UI"
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 13
	titleLabel.TextColor3 = LOADER_THEME.TEXT_PRIMARY
	titleLabel.Parent = container

	local statusLabel = Instance.new("TextLabel")
	statusLabel.BackgroundTransparency = 1
	statusLabel.Position = UDim2.new(0, 16, 0, 40)
	statusLabel.Size = UDim2.new(1, -32, 0, 18)
	statusLabel.Text = "Starting..."
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextSize = 12
	statusLabel.TextColor3 = LOADER_THEME.TEXT_SECONDARY
	statusLabel.Parent = container

	local barBackground = Instance.new("Frame")
	barBackground.Position = UDim2.new(0, 16, 0, 82)
	barBackground.Size = UDim2.new(1, -32, 0, 10)
	barBackground.BackgroundColor3 = LOADER_THEME.TERTIARY_BG
	barBackground.BorderSizePixel = 0
	barBackground.Parent = container

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 4)
	barCorner.Parent = barBackground

	local barFill = Instance.new("Frame")
	barFill.Size = UDim2.new(0, 0, 1, 0)
	barFill.BackgroundColor3 = LOADER_THEME.ACCENT
	barFill.BorderSizePixel = 0
	barFill.Parent = barBackground

	local barFillCorner = Instance.new("UICorner")
	barFillCorner.CornerRadius = UDim.new(0, 4)
	barFillCorner.Parent = barFill

	local currentProgress = 0
	local targetProgress = 0

	local function lerp(a, b, t)
		return a + (b - a) * t
	end

	local heartbeat = RunService.RenderStepped:Connect(function(dt)
		local alpha = math.clamp(dt * 8, 0, 1)
		currentProgress = lerp(currentProgress, targetProgress, alpha)
		barFill.Size = UDim2.new(currentProgress, 0, 1, 0)
	end)

	return {
		setStatus = function(_, text)
			statusLabel.Text = text or ""
			statusLabel.TextColor3 = LOADER_THEME.TEXT_SECONDARY
		end,
		setError = function(_, text)
			statusLabel.Text = text or ""
			statusLabel.TextColor3 = LOADER_THEME.ACCENT
		end,
		setProgress = function(_, value)
			targetProgress = math.clamp(value or 0, 0, 1)
		end,
		destroy = function()
			if heartbeat then
				heartbeat:Disconnect()
				heartbeat = nil
			end
			if screenGui then
				screenGui:Destroy()
			end
		end
	}
end

local loaderUi = createLoaderUi()
local totalSteps = 1
local completedSteps = 0

local function setTask(text)
	if loaderUi then
		loaderUi:setStatus(text)
	end
end

local function setTotalSteps(count)
	totalSteps = math.max(count or 1, 1)
	if loaderUi then
		loaderUi:setProgress(completedSteps / totalSteps)
	end
end

local function advanceStep()
	completedSteps = completedSteps + 1
	if loaderUi then
		loaderUi:setProgress(completedSteps / totalSteps)
	end
end

-- Debug logging function (errors only)
local function debugLog(level, message)
	if level ~= "ERROR" then return end
	if loaderUi and loaderUi.setError then
		loaderUi:setError(message)
	end
	local timestamp = os.date("%H:%M:%S")
	local prefix = "[Afterglow:ERROR] (" .. timestamp .. ")"
	warn(prefix .. " " .. message)
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
	setTask("Fetching manifest")
	debugLog("INFO", "Attempting to fetch manifest from: " .. manifestUrl)
	local success, result = pcall(function()
		return game:HttpGet(manifestUrl)
	end)
	
	if not success then
		debugLog("ERROR", "Failed to load manifest from GitHub: " .. tostring(result))
		error("Failed to load manifest from GitHub: " .. tostring(result))
	end
	
	setTask("Parsing manifest")
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

local function createDemoUi(Afterglow, pathMap)
	local Label = loadModule("controls/Label", pathMap)
	local Button = loadModule("controls/Button", pathMap)
	local Toggle = loadModule("controls/Toggle", pathMap)
	local Slider = loadModule("controls/Slider", pathMap)
	local Dropdown = loadModule("controls/Dropdown", pathMap)

	local window = Afterglow.CreateWindow({
		Name = "Afterglow Demo",
		Size = UDim2.new(0, 900, 0, 540)
	})

	local tab = window:CreateTab("Demo")
	local groupbox = tab:CreateGroupbox({Name = "Quick Start"})

	groupbox:AddElement(Label.new({
		Text = "Afterglow loaded successfully."
	}))

	groupbox:AddElement(Button.new({
		Text = "Print Hello",
		Callback = function()
			print("[Afterglow Demo] Button clicked")
		end
	}))

	groupbox:AddElement(Toggle.new({
		Text = "Enable Glow",
		Default = false,
		Callback = function(value)
			print("[Afterglow Demo] Glow:", value)
		end
	}))

	groupbox:AddElement(Slider.new({
		Text = "Intensity",
		Min = 0,
		Max = 100,
		Default = 60,
		Increment = 5,
		Callback = function(value)
			print("[Afterglow Demo] Intensity:", value)
		end
	}))

	groupbox:AddElement(Dropdown.new({
		Text = "Mode",
		Options = {"Standard", "Neon", "Minimal"},
		Default = "Standard",
		Callback = function(value)
			print("[Afterglow Demo] Mode:", value)
		end
	}))

	task.wait(0.1)
	if window.Tabs and #window.Tabs > 0 then
		window:SelectTab(window.Tabs[1])
	end

	return window
end

local function patchPopupManager(pathMap)
	local ok, popupManager = pcall(function()
		return loadModule("overlay/PopupManager", pathMap)
	end)
	if not ok or type(popupManager) ~= "table" or not popupManager._ConnectCloseHandlers then
		return
	end

	popupManager._ConnectCloseHandlers = function(self)
		local inputService = game:GetService("UserInputService")

		inputService.InputBegan:Connect(function(input, gameProcessed)
			if input.KeyCode == Enum.KeyCode.Escape then
				self:CloseAll()
			end
		end)

		inputService.InputBegan:Connect(function(input, gameProcessed)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				-- Check if click was outside any popup
				local clickedPopup = false
				for _, popup in ipairs(self.OpenPopups) do
					if popup.Visible then
						local mousePos = inputService:GetMouseLocation()
						local objPos = popup.AbsolutePosition
						local objSize = popup.AbsoluteSize

						if mousePos.X >= objPos.X and mousePos.X <= objPos.X + objSize.X and
						   mousePos.Y >= objPos.Y and mousePos.Y <= objPos.Y + objSize.Y then
							clickedPopup = true
							break
						end
					end
				end

				if not clickedPopup then
					self:CloseAll()
				end
			end
		end)
	end
end

-- Load all modules from manifest
local function initializeLoader()
	local manifestData = nil
	local success, manifestErr = pcall(function()
		manifestData = loadManifest()
	end)
	
	if not success then
		debugLog("ERROR", "Critical: Failed to load manifest - " .. tostring(manifestErr))
		error(tostring(manifestErr))
	end

	setTotalSteps(#manifestData.loadOrder + 2)
	advanceStep()
	
	local pathMap = buildPathMap()
	
	-- Use the load order from manifest
	for _, modulePath in ipairs(manifestData.loadOrder) do
		if modulePath ~= "init" then  -- Skip init, load it last
			setTask("Loading " .. modulePath)
			local moduleStartTime = tick()
			local success, result = pcall(function()
				return loadModule(modulePath, pathMap)
			end)
			
			local loadTime = math.round((tick() - moduleStartTime) * 1000)
			if success then
				advanceStep()
			else
				debugLog("ERROR", string.format("[Loader] Failed to load %s (%dms)", modulePath, loadTime))
				debugLog("ERROR", "Module load error details: " .. tostring(result))
				error(string.format("[Afterglow] Failed to load %s: %s", modulePath, tostring(result)))
			end
		end
	end

	-- Load init last
	setTask("Loading init")
	local Afterglow = loadModule("init", pathMap)
	advanceStep()

	patchPopupManager(pathMap)

	setTask("Building demo UI")
	local demoSuccess, demoErr = pcall(function()
		createDemoUi(Afterglow, pathMap)
	end)
	if not demoSuccess then
		debugLog("ERROR", "Demo UI failed to load: " .. tostring(demoErr))
		error("Demo UI failed to load: " .. tostring(demoErr))
	end
	advanceStep()

	setTask("Done")
	if loaderUi then
		loaderUi:setProgress(1)
		task.wait(0.2)
		loaderUi:destroy()
		loaderUi = nil
	end
	
	return Afterglow
end

-- Initialize and return the library
local Afterglow = initializeLoader()

return Afterglow



