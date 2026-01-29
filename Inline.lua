-- UI Library
-- Dark theme UI library with tabs, groupboxes, and search.

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

local Library = {}
Library.__index = Library

-- Accent color
local ACCENT_COLOR = Color3.fromHex("#d177b0")

-- Loader UI (optional)
local function resolveLoaderParent()
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

function Library:CreateLoader(config)
	config = config or {}
	local parent = resolveLoaderParent()
	if not parent then
		return nil
	end

	local internalWeight = math.clamp(tonumber(config.InternalPercent) or 0.1, 0, 1)
	local titleText = config.Title or "Afterglow"
	local initialStatus = config.Status or "Starting..."

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AfterglowLoader"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	if syn and syn.protect_gui then
		pcall(syn.protect_gui, screenGui)
	end

	screenGui.Parent = parent

	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.Size = UDim2.new(0, 420, 0, 110)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 8)
	frameCorner.Parent = frame

	local frameStroke = Instance.new("UIStroke")
	frameStroke.Color = Color3.fromRGB(55, 55, 55)
	frameStroke.Thickness = 1
	frameStroke.Parent = frame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.new(0, 16, 0, 12)
	titleLabel.Size = UDim2.new(1, -32, 0, 18)
	titleLabel.Text = titleText
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Font = Enum.Font.MontserratBold
	titleLabel.TextSize = 13
	titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	titleLabel.Parent = frame

	local statusLabel = Instance.new("TextLabel")
	statusLabel.BackgroundTransparency = 1
	statusLabel.Position = UDim2.new(0, 16, 0, 56)
	statusLabel.Size = UDim2.new(1, -72, 0, 18)
	statusLabel.Text = initialStatus
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Font = Enum.Font.Montserrat
	statusLabel.TextSize = 12
	statusLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
	statusLabel.Parent = frame

	local percentLabel = Instance.new("TextLabel")
	percentLabel.BackgroundTransparency = 1
	percentLabel.Position = UDim2.new(1, -56, 0, 56)
	percentLabel.Size = UDim2.new(0, 40, 0, 18)
	percentLabel.Text = "0%"
	percentLabel.TextXAlignment = Enum.TextXAlignment.Right
	percentLabel.Font = Enum.Font.MontserratBold
	percentLabel.TextSize = 12
	percentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	percentLabel.Parent = frame

	local barBackground = Instance.new("Frame")
	barBackground.Position = UDim2.new(0, 16, 0, 74)
	barBackground.Size = UDim2.new(1, -32, 0, 10)
	barBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	barBackground.BorderSizePixel = 0
	barBackground.Parent = frame

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 4)
	barCorner.Parent = barBackground

	local barFill = Instance.new("Frame")
	barFill.Size = UDim2.new(0, 0, 1, 0)
	barFill.BackgroundColor3 = ACCENT_COLOR
	barFill.BorderSizePixel = 0
	barFill.Parent = barBackground

	local barFillCorner = Instance.new("UICorner")
	barFillCorner.CornerRadius = UDim.new(0, 4)
	barFillCorner.Parent = barFill

	local currentProgress = 0
	local targetProgress = 0
	local internalProgress = 0
	local userProgress = 0
	local boundWindow = nil
	local showOnFinish = true

	local function updateOverall()
		local overall = (internalProgress * internalWeight) + (userProgress * (1 - internalWeight))
		targetProgress = math.clamp(overall, 0, 1)
		percentLabel.Text = tostring(math.floor(targetProgress * 100 + 0.5)) .. "%"
	end

	local heartbeat = RunService.RenderStepped:Connect(function(dt)
		local alpha = math.clamp(dt * 8, 0, 1)
		currentProgress = currentProgress + (targetProgress - currentProgress) * alpha
		barFill.Size = UDim2.new(currentProgress, 0, 1, 0)
	end)

	local loader = {}

	function loader:SetStatus(text)
		statusLabel.Text = text or ""
	end

	function loader:SetInternalProgress(value)
		internalProgress = math.clamp(tonumber(value) or 0, 0, 1)
		updateOverall()
	end

	function loader:SetProgress(value)
		local numeric = tonumber(value) or 0
		if numeric > 1 then
			numeric = numeric / 100
		end
		userProgress = math.clamp(numeric, 0, 1)
		updateOverall()
	end

	function loader:BindWindow(window, showOnDone)
		boundWindow = window
		showOnFinish = (showOnDone ~= false)
	end

	function loader:Destroy()
		if heartbeat then
			heartbeat:Disconnect()
			heartbeat = nil
		end
		if screenGui then
			screenGui:Destroy()
		end
	end

	function loader:Finish()
		if boundWindow and showOnFinish and boundWindow.SetVisible then
			boundWindow:SetVisible(true)
		end
		loader:Destroy()
	end

	updateOverall()
	return loader
end

-- Create a window
function Library:CreateWindow(config)
	config = config or {}
	local windowName = config.Name or "UI Library"
	local windowSize = config.Size or UDim2.new(0, 1100, 0, 650)
	local loader = config.Loader
	if loader == true then
		loader = Library:CreateLoader(config.LoaderConfig or {})
	end
	config.Loader = loader
	local hideUntilReady = config.HideWhileLoading and loader

	if loader and loader.SetStatus then
		loader:SetStatus("Loading UI")
	end
	if loader and loader.SetInternalProgress then
		loader:SetInternalProgress(0)
	end

	local window = {}
	window.Tabs = {}
	window.CurrentTab = nil
	window.AllElements = {}
	window.Flags = {}
	window.FlagSetters = {}
	window.FlagGetters = {}
	window._flagIndex = 0

	local Theme = {
		Accent = ACCENT_COLOR,
		PrimaryBg = Color3.fromRGB(20, 20, 20),
		SecondaryBg = Color3.fromRGB(25, 25, 25),
		TertiaryBg = Color3.fromRGB(30, 30, 30),
		TextPrimary = Color3.fromRGB(200, 200, 200),
		TextSecondary = Color3.fromRGB(160, 160, 160),
	}
	window._accentParts = {}

	local function registerAccentPart(part)
		if not part then
			return
		end
		table.insert(window._accentParts, part)
		part.Color = Theme.Accent
	end

	local function nextFlag(prefix)
		window._flagIndex = window._flagIndex + 1
		return (prefix or "Control") .. "_" .. tostring(window._flagIndex)
	end

	local function registerFlag(flag, getter, setter, defaultValue)
		if not flag or flag == "" then
			return nil
		end
		if window.Flags[flag] == nil then
			window.Flags[flag] = defaultValue
		end
		if getter then
			window.FlagGetters[flag] = getter
		end
		if setter then
			window.FlagSetters[flag] = setter
		end
		return flag
	end

	local function updateFlag(flag, value)
		if not flag then
			return
		end
		window.Flags[flag] = value
	end

	local function getEnumTypeName(enumType)
		if enumType == nil then
			return nil
		end
		local ok, name = pcall(function()
			return enumType.Name
		end)
		if ok and type(name) == "string" and name ~= "" then
			return name
		end
		local asString = tostring(enumType)
		local match = asString:match("^Enum%.(.+)$")
		return match or asString
	end

	local function resolveEnumItem(enumTypeName, itemName)
		if type(enumTypeName) ~= "string" or type(itemName) ~= "string" then
			return nil
		end
		local enumType = Enum[enumTypeName]
		if not enumType then
			return nil
		end
		local ok, items = pcall(function()
			return enumType:GetEnumItems()
		end)
		if not ok then
			return nil
		end
		for _, item in ipairs(items) do
			if item.Name == itemName then
				return item
			end
		end
		return nil
	end

	local function serializeValue(value)
		local valueType = typeof(value)
		if valueType == "Color3" then
			return {__type = "Color3", r = value.R, g = value.G, b = value.B}
		end
		if valueType == "EnumItem" then
			local enumTypeName = getEnumTypeName(value.EnumType) or tostring(value.EnumType)
			return {__type = "EnumItem", enumType = enumTypeName, name = value.Name}
		end
		if valueType == "table" then
			local out = {}
			for k, v in pairs(value) do
				out[k] = serializeValue(v)
			end
			return out
		end
		return value
	end

	local function deserializeValue(value)
		if type(value) ~= "table" then
			return value
		end
		if value.__type == "Color3" then
			return Color3.new(value.r or 0, value.g or 0, value.b or 0)
		end
		if value.__type == "EnumItem" then
			local resolved = resolveEnumItem(value.enumType, value.name)
			if resolved then
				return resolved
			end
			return value
		end
		local out = {}
		for k, v in pairs(value) do
			out[k] = deserializeValue(v)
		end
		return out
	end

	local function replaceColor(root, oldColor, newColor)
		for _, obj in ipairs(root:GetDescendants()) do
			if obj:IsA("UIStroke") then
				if obj.Color == oldColor then
					obj.Color = newColor
				end
			elseif obj:IsA("GuiObject") then
				if obj.BackgroundColor3 == oldColor then
					obj.BackgroundColor3 = newColor
				end
				if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
					if obj.TextColor3 == oldColor then
						obj.TextColor3 = newColor
					end
				end
			end
		end
	end

	local function applyTheme(role, color)
		local oldColor = Theme[role]
		Theme[role] = color
		if role == "Accent" then
			ACCENT_COLOR = color
			for i = #window._accentParts, 1, -1 do
				local part = window._accentParts[i]
				if not part or not part.Parent then
					table.remove(window._accentParts, i)
				elseif part:IsA("BasePart") then
					part.Color = color
				end
			end
		end
		if window.ScreenGui and oldColor then
			replaceColor(window.ScreenGui, oldColor, color)
		end
	end

	local function isKeyMatch(input, key)
		if typeof(key) ~= "EnumItem" then
			return false
		end
		if key.EnumType == Enum.KeyCode then
			return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key
		end
		if key.EnumType == Enum.UserInputType then
			return input.UserInputType == key
		end
		return false
	end

	function window:GetConfig()
		local data = {}
		for flag, getter in pairs(window.FlagGetters) do
			local ok, value = pcall(getter)
			if ok then
				data[flag] = value
			else
				data[flag] = window.Flags[flag]
			end
		end
		return data
	end

	function window:LoadConfig(data)
		if type(data) ~= "table" then
			return
		end
		for flag, value in pairs(data) do
			local setter = window.FlagSetters[flag]
			if setter then
				setter(value)
				window.Flags[flag] = value
			end
		end
	end

	function window:ExportConfig()
		local raw = window:GetConfig()
		local encoded = {}
		for flag, value in pairs(raw) do
			encoded[flag] = serializeValue(value)
		end
		local ok, json = pcall(HttpService.JSONEncode, HttpService, encoded)
		if ok then
			return json
		end
		return nil
	end

	function window:ImportConfig(json)
		if type(json) ~= "string" then
			return false
		end
		local ok, decoded = pcall(HttpService.JSONDecode, HttpService, json)
		if not ok or type(decoded) ~= "table" then
			return false
		end
		local data = {}
		for flag, value in pairs(decoded) do
			data[flag] = deserializeValue(value)
		end
		window:LoadConfig(data)
		return true
	end

	local FileSystem = {
		Root = "Afterglow",
		Themes = "Afterglow/Themes",
		Configs = "Afterglow/Configurations",
	}

	local function canUseFileSystem()
		return type(writefile) == "function"
			and type(readfile) == "function"
			and type(isfile) == "function"
			and type(makefolder) == "function"
			and type(isfolder) == "function"
	end

	local function ensureFolders()
		if not canUseFileSystem() then
			return false
		end
		if not isfolder(FileSystem.Root) then
			makefolder(FileSystem.Root)
		end
		if not isfolder(FileSystem.Themes) then
			makefolder(FileSystem.Themes)
		end
		if not isfolder(FileSystem.Configs) then
			makefolder(FileSystem.Configs)
		end
		return true
	end

	local function sanitizeName(name, fallback)
		local safe = tostring(name or ""):gsub("[^%w%-%_ ]", ""):gsub("%s+", "_")
		if safe == "" then
			return fallback or "default"
		end
		return safe
	end

	function window:ExportTheme()
		local encoded = {}
		for role, value in pairs(Theme) do
			encoded[role] = serializeValue(value)
		end
		local ok, json = pcall(HttpService.JSONEncode, HttpService, encoded)
		if ok then
			return json
		end
		return nil
	end

	function window:ImportTheme(json)
		if type(json) ~= "string" then
			return false
		end
		local ok, decoded = pcall(HttpService.JSONDecode, HttpService, json)
		if not ok or type(decoded) ~= "table" then
			return false
		end
		for role, value in pairs(decoded) do
			if Theme[role] then
				applyTheme(role, deserializeValue(value))
			end
		end
		return true
	end

	function window:SaveConfigFile(name)
		if not ensureFolders() then
			return false
		end
		local json = window:ExportConfig()
		if not json then
			return false
		end
		local fileName = sanitizeName(name, "config") .. ".json"
		local path = FileSystem.Configs .. "/" .. fileName
		writefile(path, json)
		return true, path
	end

	function window:LoadConfigFile(name)
		if not ensureFolders() then
			return false
		end
		local fileName = sanitizeName(name, "config") .. ".json"
		local path = FileSystem.Configs .. "/" .. fileName
		if not isfile(path) then
			return false
		end
		local json = readfile(path)
		return window:ImportConfig(json)
	end

	function window:SaveThemeFile(name)
		if not ensureFolders() then
			return false
		end
		local json = window:ExportTheme()
		if not json then
			return false
		end
		local fileName = sanitizeName(name, "theme") .. ".json"
		local path = FileSystem.Themes .. "/" .. fileName
		writefile(path, json)
		return true, path
	end

	function window:LoadThemeFile(name)
		if not ensureFolders() then
			return false
		end
		local fileName = sanitizeName(name, "theme") .. ".json"
		local path = FileSystem.Themes .. "/" .. fileName
		if not isfile(path) then
			return false
		end
		local json = readfile(path)
		return window:ImportTheme(json)
	end

	local function listFilesInFolder(folder)
		if not ensureFolders() then
			return {}
		end
		if type(listfiles) ~= "function" then
			return {}
		end
		local names = {}
		for _, path in ipairs(listfiles(folder)) do
			if type(path) == "string" then
				if type(isfile) == "function" and not isfile(path) then
					continue
				end
				local normalized = path:gsub("\\", "/")
				local name = normalized:match("([^/]+)%.json$")
				if name then
					table.insert(names, name)
				end
			end
		end
		table.sort(names)
		return names
	end

	function window:ListThemeFiles()
		return listFilesInFolder(FileSystem.Themes)
	end

	function window:ListConfigFiles()
		return listFilesInFolder(FileSystem.Configs)
	end

	function window:SetThemeColor(role, color)
		if not Theme[role] then
			return
		end
		applyTheme(role, color)
	end

	function window:GetTheme()
		return Theme
	end

	-- ScreenGui host
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "UILibrary"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	if RunService:IsStudio() then
		screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	else
		screenGui.Parent = game:GetService("CoreGui")
	end
	window.ScreenGui = screenGui

	-- Main frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = windowSize
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui
	mainFrame.Visible = not hideUntilReady

	if loader and loader.SetInternalProgress then
		loader:SetInternalProgress(0.5)
	end

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 8)
	mainCorner.Parent = mainFrame

	-- Drag handle
	local dragBar = Instance.new("Frame")
	dragBar.Name = "DragBar"
	dragBar.Size = UDim2.new(1, 0, 0, 60)
	dragBar.Position = UDim2.new(0, 0, 0, 0)
	dragBar.BackgroundTransparency = 1
	dragBar.Parent = mainFrame

	-- Search bar
	local searchContainer = Instance.new("Frame")
	searchContainer.Name = "SearchContainer"
	searchContainer.Size = UDim2.new(1, -40, 0, 40)
	searchContainer.Position = UDim2.new(0, 20, 0, 15)
	searchContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	searchContainer.BorderSizePixel = 0
	searchContainer.Parent = mainFrame

	local searchCorner = Instance.new("UICorner")
	searchCorner.CornerRadius = UDim.new(0, 6)
	searchCorner.Parent = searchContainer

	-- Search TextBox
	local searchBox = Instance.new("TextBox")
	searchBox.Name = "SearchBox"
	searchBox.Size = UDim2.new(1, -20, 1, 0)
	searchBox.Position = UDim2.new(0, 15, 0, 0)
	searchBox.BackgroundTransparency = 1
	searchBox.PlaceholderText = "Search"
	searchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
	searchBox.Text = ""
	searchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
	searchBox.TextSize = 14
	searchBox.Font = Enum.Font.Montserrat
	searchBox.TextXAlignment = Enum.TextXAlignment.Center
	searchBox.ClearTextOnFocus = true
	searchBox.Parent = searchContainer

	-- Sidebar (tabs)
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 170, 1, -95)
	sidebar.Position = UDim2.new(0, 20, 0, 65)
	sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	sidebar.BorderSizePixel = 0
	sidebar.Parent = mainFrame

	local sidebarCorner = Instance.new("UICorner")
	sidebarCorner.CornerRadius = UDim.new(0, 6)
	sidebarCorner.Parent = sidebar

	-- Tab list
	local tabContainer = Instance.new("Frame")
	tabContainer.Name = "TabContainer"
	tabContainer.Size = UDim2.new(1, -20, 1, -20)
	tabContainer.Position = UDim2.new(0, 10, 0, 10)
	tabContainer.BackgroundTransparency = 1
	tabContainer.Parent = sidebar

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Padding = UDim.new(0, 8)
	tabLayout.Parent = tabContainer

	-- Content area
	local contentArea = Instance.new("ScrollingFrame")
	contentArea.Name = "ContentArea"
	contentArea.Size = UDim2.new(1, -210, 1, -95)
	contentArea.Position = UDim2.new(0, 200, 0, 65)
	contentArea.BackgroundTransparency = 1
	contentArea.BorderSizePixel = 0
	contentArea.ScrollBarThickness = 6
	contentArea.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
	contentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentArea.Parent = mainFrame

	-- Bottom fade for scrollable content area
	local FADE_HEIGHT = 16
	local contentFade = Instance.new("Frame")
	contentFade.Name = "ContentFade"
	contentFade.Size = UDim2.new(1, -210 - contentArea.ScrollBarThickness, 0, FADE_HEIGHT)
	contentFade.Position = UDim2.new(0, 200, 1, -30 - FADE_HEIGHT)
	contentFade.BackgroundColor3 = Theme.PrimaryBg
	contentFade.BorderSizePixel = 0
	contentFade.ZIndex = 20
	contentFade.Visible = false
	contentFade.Parent = mainFrame

	local contentFadeGradient = Instance.new("UIGradient")
	contentFadeGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0)
	})
	contentFadeGradient.Rotation = 90
	contentFadeGradient.Parent = contentFade

	local function updateContentFade()
		local canvasHeight = contentArea.CanvasSize.Y.Offset
		contentFade.Visible = canvasHeight > contentArea.AbsoluteSize.Y + 1
	end

	contentArea:GetPropertyChangedSignal("CanvasSize"):Connect(updateContentFade)
	contentArea:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateContentFade)
	task.defer(updateContentFade)

	-- Column container for groupboxes
	local gridContainer = Instance.new("Frame")
	gridContainer.Name = "GridContainer"
	gridContainer.Size = UDim2.new(1, 0, 1, 0)
	gridContainer.BackgroundTransparency = 1
	gridContainer.AutomaticSize = Enum.AutomaticSize.Y
	gridContainer.Parent = contentArea

	-- Horizontal layout for columns
	local gridList = Instance.new("UIListLayout")
	gridList.FillDirection = Enum.FillDirection.Horizontal
	gridList.SortOrder = Enum.SortOrder.LayoutOrder
	gridList.Padding = UDim.new(0, 10)
	gridList.Parent = gridContainer

	-- Fixed column count; groupboxes stack vertically in each column
	local NUM_COLUMNS = 3
	local columns = {}
	for i = 1, NUM_COLUMNS do
		local col = Instance.new("Frame")
		col.Name = "Column_" .. i
		col.Size = UDim2.new(0.333, -10, 0, 0)
		col.BackgroundTransparency = 1
		col.AutomaticSize = Enum.AutomaticSize.Y
		col.Parent = gridContainer

		local colLayout = Instance.new("UIListLayout")
		colLayout.FillDirection = Enum.FillDirection.Vertical
		colLayout.SortOrder = Enum.SortOrder.LayoutOrder
		colLayout.Padding = UDim.new(0, 10)
		colLayout.Parent = col

		table.insert(columns, col)
	end

	-- Hover overlay at screen level to avoid clipping
	local hoverOverlay = Instance.new("Frame")
	hoverOverlay.Name = "HoverOverlay"
	hoverOverlay.Size = UDim2.new(0, 0, 0, 0)
	hoverOverlay.Position = UDim2.new(0, 0, 0, 0)
	hoverOverlay.BackgroundTransparency = 1
	hoverOverlay.ZIndex = 1000
	hoverOverlay.Visible = false
	hoverOverlay.Parent = screenGui

	local hoverStroke = Instance.new("UIStroke")
	hoverStroke.Color = ACCENT_COLOR
	hoverStroke.Thickness = 2
	hoverStroke.Transparency = 1
	hoverStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	hoverStroke.Parent = hoverOverlay

	local hoverCorner = Instance.new("UICorner")
	hoverCorner.CornerRadius = UDim.new(0, 6)
	hoverCorner.Parent = hoverOverlay

	local hoverOwner = nil

	window.Visible = not hideUntilReady
	window.ToggleKey = Enum.KeyCode.RightShift
	window.ToggleMode = "Toggle"

	function window:SetVisible(isVisible)
		window.Visible = isVisible and true or false
		mainFrame.Visible = window.Visible
		if not window.Visible then
			hoverOwner = nil
			hoverOverlay.Visible = false
		end
	end

	function window:ToggleVisible()
		window:SetVisible(not window.Visible)
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if isKeyMatch(input, window.ToggleKey) then
			if window.ToggleMode == "Toggle" then
				window:ToggleVisible()
			elseif window.ToggleMode == "Hold" then
				window:SetVisible(true)
			elseif window.ToggleMode == "Always" then
				window:SetVisible(true)
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if window.ToggleMode == "Hold" and isKeyMatch(input, window.ToggleKey) then
			window:SetVisible(false)
		end
	end)

	-- Follow current hover owner each frame
	RunService.Heartbeat:Connect(function()
		if hoverOwner and hoverOwner.Parent then
			local ok, ap = pcall(function() return hoverOwner.AbsolutePosition end)
			local ok2, asz = pcall(function() return hoverOwner.AbsoluteSize end)
			if ok and ok2 then
				-- Pad overlay slightly to match groupbox borders (tighter height)
				hoverOverlay.Position = UDim2.new(0, ap.X - 2, 0, ap.Y)
				hoverOverlay.Size = UDim2.new(0, asz.X + 4, 0, asz.Y + 2)
			end
		end
	end)


	-- Drag handling
	local dragging = false
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	dragBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	dragBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)

	local function applySearch()
		local searchText = searchBox.Text:lower()
		local groupboxMatches = {}

		if window.CurrentTab then
			for _, groupbox in pairs(window.CurrentTab.Groupboxes) do
				groupboxMatches[groupbox] = false
			end
		end

		for _, element in pairs(window.AllElements) do
			if element.Searchable and element.Frame then
				local match = searchText == "" or (element.SearchText and element.SearchText:lower():find(searchText, 1, true))
				element.Frame.Visible = match
				if match and element.Groupbox then
					groupboxMatches[element.Groupbox] = true
				end
			end
		end

		if window.CurrentTab then
			for _, groupbox in pairs(window.CurrentTab.Groupboxes) do
				if groupbox.Frame then
					groupbox.Frame.Visible = searchText == "" or groupboxMatches[groupbox] == true
				end
			end
		end
	end

	-- Search across registered elements
	searchBox:GetPropertyChangedSignal("Text"):Connect(applySearch)

	-- Tab creation
	function window:CreateTab(tabName)
		local tab = {}
		tab.Name = tabName
		tab.Button = nil
		tab.Groupboxes = {}
		tab.Active = false

		-- Create tab button
		local tabBtn = Instance.new("TextButton")
		tabBtn.Name = tabName
		tabBtn.Size = UDim2.new(1, 0, 0, 35)
		tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		tabBtn.Text = tabName
		tabBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
		tabBtn.TextSize = 13
		tabBtn.Font = Enum.Font.Montserrat
		tabBtn.LayoutOrder = #window.Tabs + 1
		tabBtn.Parent = tabContainer

		local tabCorner = Instance.new("UICorner")
		tabCorner.CornerRadius = UDim.new(0, 4)
		tabCorner.Parent = tabBtn

		tab.Button = tabBtn

		-- Tab click handler
		tabBtn.MouseButton1Click:Connect(function()
			window:SelectTab(tab)
		end)

		-- Groupbox creation
		function tab:CreateGroupbox(config)
			config = config or {}
			local groupboxName = config.Name or "Groupbox"

			local groupbox = {}
			groupbox.Name = groupboxName
			groupbox.Elements = {}

			-- Groupbox frame
			local groupboxFrame = Instance.new("Frame")
			groupboxFrame.Name = "Groupbox_" .. groupboxName .. "_" .. #tab.Groupboxes
			groupboxFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			groupboxFrame.BorderSizePixel = 0
			groupboxFrame.LayoutOrder = #tab.Groupboxes + 1
			groupboxFrame.Visible = false
			-- Fill column width; height set after layout
			groupboxFrame.Size = UDim2.new(1, 0, 0, 100)
			-- Parent to column for vertical stacking
			local colIndex = ((#tab.Groupboxes) % NUM_COLUMNS) + 1
			groupboxFrame.Parent = columns[colIndex]

			local groupboxCorner = Instance.new("UICorner")
			groupboxCorner.CornerRadius = UDim.new(0, 6)
			groupboxCorner.Parent = groupboxFrame

			-- Topbar
			local topbar = Instance.new("Frame")
			topbar.Name = "Topbar"
			topbar.Size = UDim2.new(1, 0, 0, 30)
			topbar.Position = UDim2.new(0, 0, 0, 0)
			topbar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			topbar.BorderSizePixel = 0
			topbar.Parent = groupboxFrame

			local topbarCorner = Instance.new("UICorner")
			topbarCorner.CornerRadius = UDim.new(0, 6)
			topbarCorner.Parent = topbar

			-- Corner cover for top bar rounding
			local topbarCover = Instance.new("Frame")
			topbarCover.Name = "CornerCover"
			topbarCover.Size = UDim2.new(1, 0, 0, 6)
			topbarCover.Position = UDim2.new(0, 0, 1, -6)
			topbarCover.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			topbarCover.BorderSizePixel = 0
			topbarCover.Parent = topbar

			local titleLabel = Instance.new("TextLabel")
			titleLabel.Name = "Title"
			titleLabel.Size = UDim2.new(1, -20, 1, 0)
			titleLabel.Position = UDim2.new(0, 10, 0, 0)
			titleLabel.BackgroundTransparency = 1
			titleLabel.Text = groupboxName
			titleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
			titleLabel.TextSize = 13
			titleLabel.Font = Enum.Font.MontserratMedium
			titleLabel.TextXAlignment = Enum.TextXAlignment.Center
			titleLabel.Parent = topbar

			-- Content container with extra top padding for title
			local contentContainer = Instance.new("Frame")
			contentContainer.Name = "ContentContainer"
			contentContainer.Size = UDim2.new(1, -20, 1, -50)
			contentContainer.Position = UDim2.new(0, 10, 0, 40)
			contentContainer.BackgroundTransparency = 1
			contentContainer.AutomaticSize = Enum.AutomaticSize.Y
			contentContainer.Parent = groupboxFrame

			local contentLayout = Instance.new("UIListLayout")
			contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
			contentLayout.Padding = UDim.new(0, 5)
			contentLayout.Parent = contentContainer

			-- Auto-resize based on content
			local function updateSize()
				task.wait(0.05) -- Let layout settle before reading size
				local contentHeight = contentLayout.AbsoluteContentSize.Y
				-- 30 topbar + 10 top gap + content + 10 bottom padding
				local totalHeight = 30 + 10 + contentHeight + 10
				groupboxFrame:SetAttribute("NaturalHeight", totalHeight)

				groupboxFrame.Size = UDim2.new(1, 0, 0, totalHeight)
			end

			contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)

			-- Initial size update
			task.spawn(updateSize)

			-- Hover tint
			groupboxFrame.MouseEnter:Connect(function()
				TweenService:Create(groupboxFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}):Play()
				TweenService:Create(topbar, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(37, 37, 37)}):Play()
				TweenService:Create(topbarCover, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(37, 37, 37)}):Play()
			end)

			groupboxFrame.MouseLeave:Connect(function()
				TweenService:Create(groupboxFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
				TweenService:Create(topbar, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
				TweenService:Create(topbarCover, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
			end)

			groupbox.Frame = groupboxFrame
			groupbox.ContentContainer = contentContainer
			groupbox.ContentLayout = contentLayout

			-- Hover outline using overlay to avoid clipping
			local function createHoverEffect(element, isLabel)
				if isLabel then return end

				local function show()
					hoverOwner = element
					hoverOverlay.Visible = true
					TweenService:Create(hoverStroke, TweenInfo.new(0.15), {Transparency = 0.6}):Play()
				end

				local function hide()
					-- only clear owner if this element currently owns it
					if hoverOwner == element then
						hoverOwner = nil
						TweenService:Create(hoverStroke, TweenInfo.new(0.15), {Transparency = 1}):Play()
						task.delay(0.18, function()
							if not hoverOwner then
								hoverOverlay.Visible = false
							end
						end)
					end
				end

				element.MouseEnter:Connect(show)
				element.MouseLeave:Connect(hide)
				
				-- Click highlight
				element.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						local originalColor = element.BackgroundColor3
						local lighterColor = Color3.new(
							math.min(originalColor.R + 0.05, 1),
							math.min(originalColor.G + 0.05, 1),
							math.min(originalColor.B + 0.05, 1)
						)
						TweenService:Create(element, TweenInfo.new(0.1), {
							BackgroundColor3 = lighterColor
						}):Play()
					end
				end)
				
				element.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						local originalColor = Color3.fromRGB(35, 35, 35)
						if element.Name == "Button" then
							originalColor = Color3.fromRGB(40, 40, 40)
						end
						TweenService:Create(element, TweenInfo.new(0.1), {
							BackgroundColor3 = originalColor
						}):Play()
					end
				end)
			end

			local function bindRightClick(guiObject, handler)
				if not guiObject or not handler then return end
				guiObject.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton2 then
						handler()
					end
				end)
			end

			local function formatKeyLabel(key)
				if typeof(key) == "EnumItem" then
					if key.EnumType == Enum.UserInputType then
						if key == Enum.UserInputType.MouseButton1 then
							return "MB1"
						elseif key == Enum.UserInputType.MouseButton2 then
							return "MB2"
						elseif key == Enum.UserInputType.MouseButton3 then
							return "MB3"
						end
					end
					return key.Name
				end
				return tostring(key)
			end

			local function measureKeyButtonWidth(text, textSize, font, minWidth, maxWidth)
				local bounds = TextService:GetTextSize(text, textSize, font, Vector2.new(200, 50))
				local width = math.ceil(bounds.X + 14)
				return math.clamp(width, minWidth or 40, maxWidth or 120)
			end

			local function isKeyMatch(input, key)
				if typeof(key) ~= "EnumItem" then
					return false
				end
				if key.EnumType == Enum.KeyCode then
					return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key
				end
				if key.EnumType == Enum.UserInputType then
					return input.UserInputType == key
				end
				return false
			end

			local function createKeypickerMenu(anchorButton, getMode, setMode)
				local menu = Instance.new("Frame")
				menu.Name = "KeypickerMenu"
				menu.Size = UDim2.new(0, 120, 0, 90)
				menu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
				menu.BorderSizePixel = 0
				menu.Visible = false
				menu.Active = true
				menu.ZIndex = 1006
				menu.Parent = screenGui

				local menuCorner = Instance.new("UICorner")
				menuCorner.CornerRadius = UDim.new(0, 4)
				menuCorner.Parent = menu

				local menuStroke = Instance.new("UIStroke")
				menuStroke.Color = Color3.fromRGB(55, 55, 55)
				menuStroke.Thickness = 1
				menuStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				menuStroke.Parent = menu

				local padding = Instance.new("UIPadding")
				padding.PaddingTop = UDim.new(0, 6)
				padding.PaddingBottom = UDim.new(0, 6)
				padding.PaddingLeft = UDim.new(0, 6)
				padding.PaddingRight = UDim.new(0, 6)
				padding.Parent = menu

				local layout = Instance.new("UIListLayout")
				layout.SortOrder = Enum.SortOrder.LayoutOrder
				layout.Padding = UDim.new(0, 4)
				layout.Parent = menu

				local buttons = {}
				local function makeButton(label, mode)
					local btn = Instance.new("TextButton")
					btn.Size = UDim2.new(1, 0, 0, 22)
					btn.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
					btn.BorderSizePixel = 0
					btn.Text = label
					btn.TextColor3 = Color3.fromRGB(200, 200, 200)
					btn.TextSize = 11
					btn.Font = Enum.Font.MontserratBold
					btn.ZIndex = menu.ZIndex + 1
					btn.Parent = menu

					local btnCorner = Instance.new("UICorner")
					btnCorner.CornerRadius = UDim.new(0, 3)
					btnCorner.Parent = btn

					btn.MouseButton1Click:Connect(function()
						setMode(mode)
						menu.Visible = false
					end)

					buttons[label] = btn
				end

				makeButton("Hold", "Hold")
				makeButton("Toggle", "Toggle")
				makeButton("Always", "Always")

				local function updateMenuState()
					local mode = getMode()
					for label, btn in pairs(buttons) do
						local active = (label == mode)
						btn.BackgroundColor3 = active and Color3.fromRGB(55, 55, 55) or Color3.fromRGB(38, 38, 38)
						btn.TextColor3 = active and ACCENT_COLOR or Color3.fromRGB(200, 200, 200)
					end
				end

				local function positionMenu()
					local pos = anchorButton.AbsolutePosition
					local size = anchorButton.AbsoluteSize
					local guiSize = screenGui.AbsoluteSize
					local mSize = menu.AbsoluteSize
					local mW = mSize.X > 0 and mSize.X or menu.Size.X.Offset
					local mH = mSize.Y > 0 and mSize.Y or menu.Size.Y.Offset
					local x = math.clamp(pos.X, 6, guiSize.X - mW - 6)
					local y = pos.Y + size.Y + 4
					if y + mH > guiSize.Y - 6 then
						y = pos.Y - mH - 4
					end
					y = math.max(6, y)
					menu.Position = UDim2.new(0, x, 0, y)
				end

				local function showMenu()
					positionMenu()
					updateMenuState()
					menu.Visible = true
				end

				local function hideMenu()
					menu.Visible = false
				end

				local function toggleMenu()
					if menu.Visible then hideMenu() else showMenu() end
				end

				bindRightClick(anchorButton, toggleMenu)
				anchorButton:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
					if menu.Visible then positionMenu() end
				end)
				anchorButton:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					if menu.Visible then positionMenu() end
				end)

				UserInputService.InputBegan:Connect(function(input)
					if not menu.Visible then return end
					if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.MouseButton2 then
						return
					end

					local mousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
					local mPos = menu.AbsolutePosition
					local mSize = menu.AbsoluteSize
					local aPos = anchorButton.AbsolutePosition
					local aSize = anchorButton.AbsoluteSize

					local insideMenu = mousePos.X >= mPos.X and mousePos.X <= mPos.X + mSize.X
						and mousePos.Y >= mPos.Y and mousePos.Y <= mPos.Y + mSize.Y
					local insideAnchor = mousePos.X >= aPos.X and mousePos.X <= aPos.X + aSize.X
						and mousePos.Y >= aPos.Y and mousePos.Y <= aPos.Y + aSize.Y

					if not insideMenu and not insideAnchor then
						hideMenu()
					end
				end)

				return {
					Update = updateMenuState,
					Hide = hideMenu,
					Show = showMenu,
					IsVisible = function() return menu.Visible end
				}
			end

			local function createColorPicker(anchorButton, initialColor, initialAlpha, onChanged)
				local colorClipboard = nil

				local picker = Instance.new("Frame")
				picker.Name = "ColorPicker"
				picker.Size = UDim2.new(0, 230, 0, 255)
				picker.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
				picker.BorderSizePixel = 0
				picker.Visible = false
				picker.ZIndex = 1006
				picker.Parent = screenGui

				local pickerCorner = Instance.new("UICorner")
				pickerCorner.CornerRadius = UDim.new(0, 6)
				pickerCorner.Parent = picker

				local pickerStroke = Instance.new("UIStroke")
				pickerStroke.Color = Color3.fromRGB(50, 50, 50)
				pickerStroke.Thickness = 1
				pickerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				pickerStroke.Parent = picker

				local padding = Instance.new("UIPadding")
				padding.PaddingTop = UDim.new(0, 10)
				padding.PaddingBottom = UDim.new(0, 10)
				padding.PaddingLeft = UDim.new(0, 10)
				padding.PaddingRight = UDim.new(0, 10)
				padding.Parent = picker

				local hue, sat, val = Color3.toHSV(initialColor or Color3.new(1, 0, 1))
				local alpha = initialAlpha ~= nil and initialAlpha or 1

				local SV_SIZE = Vector2.new(200, 200)
				local HUE_W = 12
				local ALPHA_H = 12

				-- Saturation / Value square using image like ref.lua
				local svContainer = Instance.new("Frame")
				svContainer.Size = UDim2.new(0, SV_SIZE.X, 0, SV_SIZE.Y)
				svContainer.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
				svContainer.BorderSizePixel = 0
				svContainer.Active = true
				svContainer.Parent = picker

				local svImage = Instance.new("ImageLabel")
				svImage.Size = UDim2.new(1, 0, 1, 0)
				svImage.BackgroundTransparency = 1
				svImage.Image = "rbxassetid://4155801252" -- sat/value overlay
				svImage.Active = true
				svImage.Parent = svContainer

				local svCursor = Instance.new("ImageLabel")
				svCursor.Size = UDim2.new(0, 12, 0, 12)
				svCursor.AnchorPoint = Vector2.new(0.5, 0.5)
				svCursor.BackgroundTransparency = 1
				svCursor.Image = "http://www.roblox.com/asset/?id=9619665977"
				svCursor.ImageColor3 = Color3.new(1, 1, 1)
				svCursor.ZIndex = 2
				svCursor.Parent = svContainer

				-- Hue bar
				local hueBar = Instance.new("Frame")
				hueBar.Size = UDim2.new(0, HUE_W, 0, SV_SIZE.Y)
				hueBar.Position = UDim2.new(0, SV_SIZE.X + 8, 0, 0)
				hueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				hueBar.BorderSizePixel = 0
				hueBar.Active = true
				hueBar.Parent = picker

				local hueFill = Instance.new("Frame")
				hueFill.Size = UDim2.new(1, 0, 1, 0)
				hueFill.BackgroundTransparency = 0
				hueFill.BorderSizePixel = 0
				hueFill.Active = true
				hueFill.Parent = hueBar

				local hueGrad = Instance.new("UIGradient")
				hueGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
					ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
					ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
					ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
				})
				-- rotate so gradient runs top -> bottom
				hueGrad.Rotation = 90
				hueGrad.Parent = hueFill

				local hueHandle = Instance.new("Frame")
				hueHandle.Size = UDim2.new(1, 4, 0, 4)
				hueHandle.AnchorPoint = Vector2.new(0.5, 0.5)
				hueHandle.Position = UDim2.new(0.5, 0, 0, 0)
				hueHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				hueHandle.BorderSizePixel = 0
				hueHandle.Parent = hueBar
				local hueHandleCorner = Instance.new("UICorner")
				hueHandleCorner.CornerRadius = UDim.new(1, 0)
				hueHandleCorner.Parent = hueHandle

				-- Alpha bar with true checker + color fade
				local alphaBar = Instance.new("Frame")
				alphaBar.Size = UDim2.new(0, SV_SIZE.X, 0, ALPHA_H)
				alphaBar.Position = UDim2.new(0, 0, 0, SV_SIZE.Y + 12)
				alphaBar.BackgroundTransparency = 1
				alphaBar.BorderSizePixel = 0
				alphaBar.Active = true
				alphaBar.Parent = picker

				-- checker background
				local alphaChecker = Instance.new("ImageLabel")
				alphaChecker.Size = UDim2.new(1, 0, 1, 0)
				alphaChecker.BackgroundTransparency = 1
				alphaChecker.Image = "http://www.roblox.com/asset/?id=12978095818"
				alphaChecker.ImageRectOffset = Vector2.new(0, 0)
				alphaChecker.ImageRectSize = Vector2.new(256, 256)
				alphaChecker.TileSize = UDim2.new(0, 16, 0, 16)
				alphaChecker.Parent = alphaBar

				-- color overlay that fades out to transparent (left->right)
				local alphaFill = Instance.new("Frame")
				alphaFill.Size = UDim2.new(1, 0, 1, 0)
				alphaFill.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
				alphaFill.BorderSizePixel = 0
				alphaFill.Parent = alphaBar
				local alphaGrad = Instance.new("UIGradient")
				alphaGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
				})
				alphaGrad.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 1)
				})
				alphaGrad.Rotation = 0
				alphaGrad.Parent = alphaFill

				local alphaHandle = Instance.new("Frame")
				alphaHandle.Size = UDim2.new(0, 10, 1, 4)
				alphaHandle.AnchorPoint = Vector2.new(0.5, 0.5)
				alphaHandle.Position = UDim2.new(alpha, 0, 0.5, 0)
				alphaHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				alphaHandle.BorderSizePixel = 0
				alphaHandle.Parent = alphaBar
				local alphaHandleCorner = Instance.new("UICorner")
				alphaHandleCorner.CornerRadius = UDim.new(1, 0)
				alphaHandleCorner.Parent = alphaHandle

				local currentColor = initialColor or Color3.fromRGB(255, 0, 255)

				local function updateVisuals()
					currentColor = Color3.fromHSV(hue, sat, val)
					svContainer.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
					alphaFill.BackgroundColor3 = currentColor
					alphaHandle.Position = UDim2.new(alpha, 0, 0.5, 0)
					alphaGrad.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 1)
					})

					svCursor.Position = UDim2.new(sat, 0, 1 - val, 0)
					hueHandle.Position = UDim2.new(0.5, 0, hue, 0)

					if onChanged then
						onChanged(currentColor, alpha)
					end
				end

				updateVisuals()

				local draggingSV, draggingHue, draggingAlpha = false, false, false

				local function getMousePos()
					local inset = game:GetService("GuiService"):GetGuiInset()
					return UserInputService:GetMouseLocation() - inset
				end

				local function setSVFromInput(input)
					local inset = game:GetService("GuiService"):GetGuiInset()
					local pos = input and (input.Position - inset) or getMousePos()
					local rel = pos - svContainer.AbsolutePosition
					sat = math.clamp(rel.X / svContainer.AbsoluteSize.X, 0, 1)
					val = 1 - math.clamp(rel.Y / svContainer.AbsoluteSize.Y, 0, 1)
					updateVisuals()
				end

				local function setHueFromInput(input)
					-- Use raw mouse position (no inset correction) to match the more accurate behavior you reported
					local posY = (input and input.Position.Y) or UserInputService:GetMouseLocation().Y
					local relY = posY - hueBar.AbsolutePosition.Y
					hue = math.clamp(relY / hueBar.AbsoluteSize.Y, 0, 1)
					updateVisuals()
				end

				local function setAlphaFromInput(input)
					local inset = game:GetService("GuiService"):GetGuiInset()
					local posX = (input and (input.Position.X - inset.X)) or getMousePos().X
					local relX = posX - alphaBar.AbsolutePosition.X
					alpha = math.clamp(relX / alphaBar.AbsoluteSize.X, 0, 1)
					updateVisuals()
				end

				local function beginSV(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						draggingSV = true
						setSVFromInput(input)
					end
				end

				svContainer.InputBegan:Connect(beginSV)
				svImage.InputBegan:Connect(beginSV)
				svCursor.InputBegan:Connect(beginSV)

				local function beginHue(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						draggingHue = true
						setHueFromInput(input)
					end
				end

				hueBar.InputBegan:Connect(beginHue)
				hueFill.InputBegan:Connect(beginHue)
				hueHandle.InputBegan:Connect(beginHue)

				alphaBar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						draggingAlpha = true
						setAlphaFromInput(input)
					end
				end)

				alphaFill.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						draggingAlpha = true
						setAlphaFromInput(input)
					end
				end)

				alphaChecker.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						draggingAlpha = true
						setAlphaFromInput(input)
					end
				end)

				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						draggingSV, draggingHue, draggingAlpha = false, false, false
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
					if draggingSV then setSVFromInput(input) end
					if draggingHue then setHueFromInput(input) end
					if draggingAlpha then setAlphaFromInput(input) end
				end)

				RunService.Heartbeat:Connect(function()
					if draggingSV then setSVFromInput() end
					-- hue updates on InputChanged to avoid double-position jitter
					if draggingAlpha then setAlphaFromInput() end
				end)

				-- simple context actions on right-click of swatch
				bindRightClick(anchorButton, function()
					if colorClipboard then
						local h, s, v = Color3.toHSV(colorClipboard)
						hue, sat, val = h, s, v
						updateVisuals()
					else
						colorClipboard = currentColor
					end
				end)

				local function showPicker()
					local pos = anchorButton.AbsolutePosition
					local size = anchorButton.AbsoluteSize
					local vp = screenGui.AbsoluteSize
					local pW = picker.AbsoluteSize.X > 0 and picker.AbsoluteSize.X or picker.Size.X.Offset
					local pH = picker.AbsoluteSize.Y > 0 and picker.AbsoluteSize.Y or picker.Size.Y.Offset
					local x = math.clamp(pos.X, 8, vp.X - pW - 8)
					local y = pos.Y + size.Y + 6
					if y + pH > vp.Y - 8 then
						y = pos.Y - pH - 6
					end
					y = math.max(8, y)
					picker.Position = UDim2.new(0, x, 0, y)
					picker.Visible = true
					-- prevent immediate hide when clicking picker controls
					colorClipboard = colorClipboard -- no-op to keep closure up-to-date
				end

				local function hidePicker()
					picker.Visible = false
				end

				UserInputService.InputBegan:Connect(function(input)
					if not picker.Visible then return end
					if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.MouseButton2 then
						return
					end
					local mp = UserInputService:GetMouseLocation() - game:GetService("GuiService"):GetGuiInset()
					local pPos = picker.AbsolutePosition
					local pSize = picker.AbsoluteSize
					local aPos = anchorButton.AbsolutePosition
					local aSize = anchorButton.AbsoluteSize
					local insidePicker = mp.X >= pPos.X and mp.X <= pPos.X + pSize.X
						and mp.Y >= pPos.Y and mp.Y <= pPos.Y + pSize.Y
					local insideAnchor = mp.X >= aPos.X and mp.X <= aPos.X + aSize.X
						and mp.Y >= aPos.Y and mp.Y <= aPos.Y + aSize.Y
					if not insidePicker and not insideAnchor then
						hidePicker()
					end
				end)

				return {
					Show = showPicker,
					Hide = hidePicker,
					IsVisible = function() return picker.Visible end,
					UpdateColor = function(color, alphaValue)
						local h, s, v = Color3.toHSV(color)
						hue, sat, val = h, s, v
						alpha = alphaValue or alpha
						updateVisuals()
					end,
					GetColor = function()
						return currentColor, alpha
					end
				}
			end

			-- Add Viewport Preview
			function groupbox:AddViewportPreview(config)
				config = config or {}
				local height = config.Height or 220
				local rotationEnabled = config.RotationEnabled ~= false
				local autoRotateEnabled = config.AutoRotate ~= false
				local dragRotateEnabled = config.DragRotate ~= false
				local autoRotateSpeed = tonumber(config.AutoRotateSpeed) or 4
				local dragSensitivity = tonumber(config.DragSensitivity) or 0.25
				local pitchLimit = tonumber(config.PitchLimit) or 25
				local allowPitch = config.AllowPitch ~= false
				local autoRotateWhileDragging = config.AutoRotateWhileDragging == true

				local viewport = Instance.new("ViewportFrame")
				viewport.Name = "ViewportPreview"
				viewport.Size = UDim2.new(1, 0, 0, height)
				viewport.BackgroundColor3 = Theme.TertiaryBg
				viewport.BorderSizePixel = 0
				viewport.Ambient = Color3.new(1, 1, 1)
				viewport.LightColor = Color3.new(1, 1, 1)
				viewport.LayoutOrder = #groupbox.Elements + 1
				viewport.Parent = contentContainer

				local viewportCorner = Instance.new("UICorner")
				viewportCorner.CornerRadius = UDim.new(0, 4)
				viewportCorner.Parent = viewport

				local viewportStroke = Instance.new("UIStroke")
				viewportStroke.Color = Color3.fromRGB(55, 55, 55)
				viewportStroke.Thickness = 1
				viewportStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				viewportStroke.Parent = viewport

				local viewportCamera = Instance.new("Camera")
				viewportCamera.Parent = viewport
				viewport.CurrentCamera = viewportCamera

				local worldModel = Instance.new("WorldModel")
				worldModel.Parent = viewport

				local rig = Instance.new("Model")
				rig.Name = "Rig"
				rig.Parent = worldModel

				local hrp = Instance.new("Part")
				hrp.Name = "HumanoidRootPart"
				hrp.Size = Vector3.new(2, 2, 1)
				hrp.Position = Vector3.new(0, 3, 0)
				hrp.Anchored = true
				hrp.Transparency = 1
				hrp.Parent = rig

				local function createRigPart(name, size, position)
					local part = Instance.new("Part")
					part.Name = name
					part.Size = size
					part.Position = position
					part.Material = Enum.Material.SmoothPlastic
					part.Anchored = true
					part.Parent = rig
					registerAccentPart(part)
					return part
				end

				local torso = createRigPart("Torso", Vector3.new(2, 2, 1), Vector3.new(0, 3, 0))
				local torsoMesh = Instance.new("SpecialMesh")
				torsoMesh.MeshType = Enum.MeshType.Brick
				torsoMesh.Parent = torso

				local head = createRigPart("Head", Vector3.new(2, 1, 1), Vector3.new(0, 4.5, 0))
				local headMesh = Instance.new("SpecialMesh")
				headMesh.MeshType = Enum.MeshType.Head
				headMesh.Scale = Vector3.new(1.25, 1.25, 1.25)
				headMesh.Parent = head

				local face = Instance.new("Decal")
				face.Name = "face"
				face.Texture = "rbxasset://textures/face.png"
				face.Parent = head

				local leftArm = createRigPart("Left Arm", Vector3.new(1, 2, 1), Vector3.new(-1.5, 3, 0))
				local leftArmMesh = Instance.new("SpecialMesh")
				leftArmMesh.MeshType = Enum.MeshType.Brick
				leftArmMesh.Parent = leftArm

				local rightArm = createRigPart("Right Arm", Vector3.new(1, 2, 1), Vector3.new(1.5, 3, 0))
				local rightArmMesh = Instance.new("SpecialMesh")
				rightArmMesh.MeshType = Enum.MeshType.Brick
				rightArmMesh.Parent = rightArm

				local leftLeg = createRigPart("Left Leg", Vector3.new(1, 2, 1), Vector3.new(-0.5, 1, 0))
				local leftLegMesh = Instance.new("SpecialMesh")
				leftLegMesh.MeshType = Enum.MeshType.Brick
				leftLegMesh.Parent = leftLeg

				local rightLeg = createRigPart("Right Leg", Vector3.new(1, 2, 1), Vector3.new(0.5, 1, 0))
				local rightLegMesh = Instance.new("SpecialMesh")
				rightLegMesh.MeshType = Enum.MeshType.Brick
				rightLegMesh.Parent = rightLeg

				local pivot = CFrame.new(0, 3, 0)
				local rigParts = {hrp, torso, head, leftArm, rightArm, leftLeg, rightLeg}
				local rigOffsets = {}
				for _, part in ipairs(rigParts) do
					rigOffsets[part] = pivot:ToObjectSpace(part.CFrame)
				end

				local yaw = 0
				local pitch = 0
				local dragging = false
				local lastPos = nil

				local function applyRotation()
					if not allowPitch then
						pitch = 0
					else
						pitch = math.clamp(pitch, -pitchLimit, pitchLimit)
					end
					local rotation = CFrame.Angles(math.rad(pitch), math.rad(yaw), 0)
					local base = pivot * rotation
					for part, offset in pairs(rigOffsets) do
						if part and part.Parent then
							part.CFrame = base * offset
						end
					end
				end

				applyRotation()

				viewportCamera.CFrame = CFrame.new(Vector3.new(4, 3.5, 6), Vector3.new(0, 3, 0))

				table.insert(groupbox.Elements, viewport)

				local inputChangedConn = nil
				local inputEndedConn = nil
				local autoRotateConn = nil

				viewport.InputBegan:Connect(function(input)
					if not rotationEnabled or not dragRotateEnabled then
						return
					end
					if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						lastPos = input.Position
					end
				end)

				inputChangedConn = UserInputService.InputChanged:Connect(function(input)
					if not dragging then
						return
					end
					if input.UserInputType ~= Enum.UserInputType.MouseMovement
						and input.UserInputType ~= Enum.UserInputType.Touch then
						return
					end
					if not rotationEnabled or not dragRotateEnabled then
						return
					end
					if lastPos then
						local delta = input.Position - lastPos
						lastPos = input.Position
						yaw = yaw + (delta.X * dragSensitivity)
						if allowPitch then
							pitch = pitch - (delta.Y * dragSensitivity)
						end
						applyRotation()
					else
						lastPos = input.Position
					end
				end)

				inputEndedConn = UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
						lastPos = nil
					end
				end)

				autoRotateConn = RunService.RenderStepped:Connect(function(dt)
					if not rotationEnabled or not autoRotateEnabled then
						return
					end
					if dragging and not autoRotateWhileDragging then
						return
					end
					yaw = yaw + (autoRotateSpeed * dt)
					if yaw >= 360 or yaw <= -360 then
						yaw = yaw % 360
					end
					applyRotation()
				end)

				viewport.AncestryChanged:Connect(function(_, parent)
					if parent then
						return
					end
					if inputChangedConn then
						inputChangedConn:Disconnect()
						inputChangedConn = nil
					end
					if inputEndedConn then
						inputEndedConn:Disconnect()
						inputEndedConn = nil
					end
					if autoRotateConn then
						autoRotateConn:Disconnect()
						autoRotateConn = nil
					end
				end)

				return {
					Viewport = viewport,
					Rig = rig,
					SetRotationEnabled = function(enabled)
						rotationEnabled = enabled and true or false
						if not rotationEnabled then
							dragging = false
							lastPos = nil
						end
					end,
					SetAutoRotateEnabled = function(enabled)
						autoRotateEnabled = enabled and true or false
					end,
					SetDragEnabled = function(enabled)
						dragRotateEnabled = enabled and true or false
						if not dragRotateEnabled then
							dragging = false
							lastPos = nil
						end
					end,
					SetAutoRotateSpeed = function(speed)
						autoRotateSpeed = tonumber(speed) or autoRotateSpeed
					end,
					SetDragSensitivity = function(sensitivity)
						dragSensitivity = tonumber(sensitivity) or dragSensitivity
					end,
					SetPitchLimit = function(limit)
						pitchLimit = tonumber(limit) or pitchLimit
						applyRotation()
					end,
					SetAllowPitch = function(enabled)
						allowPitch = enabled and true or false
						applyRotation()
					end,
					SetAngles = function(yawDeg, pitchDeg)
						if type(yawDeg) == "number" then
							yaw = yawDeg
						end
						if type(pitchDeg) == "number" then
							pitch = pitchDeg
						end
						applyRotation()
					end,
					GetAngles = function()
						return yaw, pitch
					end,
					GetConfig = function()
						return {
							RotationEnabled = rotationEnabled,
							AutoRotate = autoRotateEnabled,
							DragRotate = dragRotateEnabled,
							AutoRotateSpeed = autoRotateSpeed,
							DragSensitivity = dragSensitivity,
							PitchLimit = pitchLimit,
							AllowPitch = allowPitch
						}
					end
				}
			end

			-- Add Body Part Selector (2D R6)
			function groupbox:AddBodyPartSelector(config)
				config = config or {}
				local height = config.Height or 260
				local defaultSelection = config.Default or "Head"
				local callback = config.Callback or function() end

				local container = Instance.new("Frame")
				container.Name = "BodyPartSelector"
				container.Size = UDim2.new(1, 0, 0, height)
				container.BackgroundColor3 = Theme.TertiaryBg
				container.BorderSizePixel = 0
				container.LayoutOrder = #groupbox.Elements + 1
				container.Parent = contentContainer

				local containerCorner = Instance.new("UICorner")
				containerCorner.CornerRadius = UDim.new(0, 4)
				containerCorner.Parent = container

				local containerStroke = Instance.new("UIStroke")
				containerStroke.Color = Color3.fromRGB(55, 55, 55)
				containerStroke.Thickness = 1
				containerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				containerStroke.Parent = container

				local canvas = Instance.new("Frame")
				canvas.Name = "RigCanvas"
				canvas.BackgroundTransparency = 1
				canvas.Size = UDim2.new(1, -20, 1, -20)
				canvas.AnchorPoint = Vector2.new(0.5, 0.5)
				canvas.Position = UDim2.new(0.5, 0, 0.5, 0)
				canvas.Parent = container

				local normalColor = Color3.fromRGB(55, 55, 55)
				local selectedName = nil
				local parts = {}
				local hits = {}
				local strokes = {}

				local function makePart(name, size, pos)
					local f = Instance.new("Frame")
					f.Name = name
					f.Size = size
					f.Position = pos
					f.BackgroundColor3 = normalColor
					f.BorderSizePixel = 0
					f.Parent = canvas

					local stroke = Instance.new("UIStroke")
					stroke.Color = Theme.Accent
					stroke.Thickness = 1
					stroke.Transparency = 0
					stroke.Enabled = false
					stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					stroke.Parent = f

					local hit = Instance.new("TextButton")
					hit.Name = "Hit"
					hit.Text = ""
					hit.BackgroundTransparency = 1
					hit.BorderSizePixel = 0
					hit.Size = UDim2.fromScale(1, 1)
					hit.Parent = f

					return f, hit, stroke
				end

				local headW, headH = 44, 44
				local torsoW, torsoH = 88, 78
				local armW, armH = 34, 78
				local legH = 86
				local gap = 6
				local headY = 6
				local torsoY = headY + headH + gap
				local legsY = torsoY + torsoH + gap
				local hrpSize = 24
				local hrpY = torsoY + math.floor((torsoH - hrpSize) * 0.4)
				local leftLegX = -torsoW / 2
				local legW = math.floor((torsoW - gap) / 2)
				local rightLegX = leftLegX + legW + gap

				parts["Head"], hits["Head"], strokes["Head"] = makePart("Head", UDim2.new(0, headW, 0, headH), UDim2.new(0.5, -headW / 2, 0, headY))
				parts["Torso"], hits["Torso"], strokes["Torso"] = makePart("Torso", UDim2.new(0, torsoW, 0, torsoH), UDim2.new(0.5, -torsoW / 2, 0, torsoY))
				parts["Left Arm"], hits["Left Arm"], strokes["Left Arm"] = makePart("Left Arm", UDim2.new(0, armW, 0, armH), UDim2.new(0.5, -torsoW / 2 - gap - armW, 0, torsoY))
				parts["Right Arm"], hits["Right Arm"], strokes["Right Arm"] = makePart("Right Arm", UDim2.new(0, armW, 0, armH), UDim2.new(0.5, torsoW / 2 + gap, 0, torsoY))
				parts["Left Leg"], hits["Left Leg"], strokes["Left Leg"] = makePart("Left Leg", UDim2.new(0, legW, 0, legH), UDim2.new(0.5, leftLegX, 0, legsY))
				parts["Right Leg"], hits["Right Leg"], strokes["Right Leg"] = makePart("Right Leg", UDim2.new(0, legW, 0, legH), UDim2.new(0.5, rightLegX, 0, legsY))
				parts["HumanoidRootPart"], hits["HumanoidRootPart"], strokes["HumanoidRootPart"] = makePart("HumanoidRootPart", UDim2.new(0, hrpSize, 0, hrpSize), UDim2.new(0.5, -hrpSize / 2, 0, hrpY))
				if strokes["HumanoidRootPart"] then
					strokes["HumanoidRootPart"].Color = Theme.TertiaryBg
					strokes["HumanoidRootPart"].Thickness = 4
					strokes["HumanoidRootPart"].LineJoinMode = Enum.LineJoinMode.Miter
					strokes["HumanoidRootPart"].Enabled = true
				end

				local function applySelection(name)
					selectedName = name
					for partName, frame in pairs(parts) do
						if partName == "HumanoidRootPart" then
							frame.BackgroundColor3 = (partName == name) and Theme.Accent or normalColor
							if strokes[partName] then
								strokes[partName].Color = Theme.TertiaryBg
								strokes[partName].Enabled = true
							end
						elseif partName == name then
							frame.BackgroundColor3 = Theme.Accent
							if strokes[partName] then
								strokes[partName].Enabled = true
							end
						else
							frame.BackgroundColor3 = normalColor
							if strokes[partName] then
								strokes[partName].Enabled = false
							end
						end
					end
					callback(name)
				end

				for name, hit in pairs(hits) do
					hit.MouseButton1Click:Connect(function()
						applySelection(name)
					end)
				end

				if parts[defaultSelection] then
					applySelection(defaultSelection)
				else
					applySelection("Head")
				end

				table.insert(groupbox.Elements, container)

				return {
					Frame = container,
					SetSelection = function(name)
						if parts[name] then
							applySelection(name)
						end
					end,
					GetSelection = function()
						return selectedName
					end
				}
			end

			-- Add Label
			function groupbox:AddLabel(config)
				local labelText = type(config) == "table" and (config.Text or "Label") or tostring(config or "Label")
				local flag = type(config) == "table" and (config.Flag or nextFlag(groupboxName .. "_Label")) or nextFlag(groupboxName .. "_Label")

				local label = Instance.new("TextLabel")
				label.Name = "Label"
				label.Size = UDim2.new(1, 0, 0, 20)
				label.BackgroundTransparency = 1
				label.Text = labelText
				label.TextColor3 = Color3.fromRGB(200, 200, 200)
				label.TextSize = 12
				label.Font = Enum.Font.Montserrat
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.AutomaticSize = Enum.AutomaticSize.Y
				label.TextWrapped = true
				label.LayoutOrder = #groupbox.Elements + 1
				label.Parent = contentContainer

				table.insert(groupbox.Elements, label)

				-- Add to searchable elements
				table.insert(window.AllElements, {
					Frame = label,
					SearchText = labelText,
					Searchable = true,
					Groupbox = groupbox
				})

				registerFlag(flag, function()
					return label.Text
				end, function(value)
					label.Text = tostring(value or "")
				end, labelText)

				return label
			end

			-- Add Button
			function groupbox:AddButton(config)
				config = config or {}
				local buttonText = config.Text or "Button"
				local callback = config.Callback or function() end
				local flag = config.Flag or nextFlag(groupboxName .. "_Button")

				local button = Instance.new("TextButton")
				button.Name = "Button"
				button.Size = UDim2.new(1, 0, 0, 30)
				button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				button.Text = buttonText
				button.TextColor3 = Color3.fromRGB(200, 200, 200)
				button.TextSize = 12
				button.Font = Enum.Font.Montserrat
				button.LayoutOrder = #groupbox.Elements + 1
				button.Parent = contentContainer

				local buttonCorner = Instance.new("UICorner")
				buttonCorner.CornerRadius = UDim.new(0, 4)
				buttonCorner.Parent = button

				createHoverEffect(button, false)

				local clickCount = 0
				button.MouseButton1Click:Connect(function()
					clickCount = clickCount + 1
					updateFlag(flag, clickCount)
					callback()
				end)

				table.insert(groupbox.Elements, button)

				-- Add to searchable elements
				table.insert(window.AllElements, {
					Frame = button,
					SearchText = buttonText,
					Searchable = true,
					Groupbox = groupbox
				})

				registerFlag(flag, function()
					return clickCount
				end, function(value)
					clickCount = tonumber(value) or 0
					updateFlag(flag, clickCount)
				end, clickCount)

				return button
			end

			-- Add Toggle
			function groupbox:AddToggle(config)
				config = config or {}
				local toggleText = config.Text or "Toggle"
				local defaultValue = config.Default or false
				local callback = config.Callback or function() end
				local flag = config.Flag or nextFlag(groupboxName .. "_Toggle")
				local hasKeypicker = config.Keybind ~= nil
				local defaultKey = config.Keybind or Enum.KeyCode.E
				local hasColorpicker = config.ColorPicker ~= nil and config.ColorPicker ~= false
				local defaultColor = config.ColorPicker or config.ColorDefault or Color3.fromRGB(209, 119, 176)
				local defaultAlpha = config.AlphaDefault or 1
				local colorCallback = config.ColorCallback or function() end

				local toggleFrame = Instance.new("TextButton")
				toggleFrame.Name = "Toggle"
				toggleFrame.Size = UDim2.new(1, 0, 0, 30)
				toggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				toggleFrame.Text = ""
				toggleFrame.LayoutOrder = #groupbox.Elements + 1
				toggleFrame.Parent = contentContainer

				local toggleCorner = Instance.new("UICorner")
				toggleCorner.CornerRadius = UDim.new(0, 4)
				toggleCorner.Parent = toggleFrame

				createHoverEffect(toggleFrame, false)

				local toggleLabel = Instance.new("TextLabel")
				toggleLabel.Size = hasKeypicker and UDim2.new(1, -120, 1, 0) or UDim2.new(1, -50, 1, 0)
				toggleLabel.Position = UDim2.new(0, 10, 0, 0)
				toggleLabel.BackgroundTransparency = 1
				toggleLabel.Text = toggleText
				toggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
				toggleLabel.TextSize = 12
				toggleLabel.Font = Enum.Font.Montserrat
				toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
				toggleLabel.Parent = toggleFrame

				-- Toggle switch at right edge
				local toggleButton = Instance.new("Frame")
				toggleButton.Size = UDim2.new(0, 35, 0, 20)
				toggleButton.Position = UDim2.new(1, -40, 0.5, 0)
				toggleButton.AnchorPoint = Vector2.new(0, 0.5)
				toggleButton.BackgroundColor3 = defaultValue and ACCENT_COLOR or Color3.fromRGB(50, 50, 50)
				toggleButton.BorderSizePixel = 0
				toggleButton.Parent = toggleFrame

				local toggleBtnCorner = Instance.new("UICorner")
				toggleBtnCorner.CornerRadius = UDim.new(1, 0)
				toggleBtnCorner.Parent = toggleButton

				local toggleIndicator = Instance.new("Frame")
				toggleIndicator.Size = UDim2.new(0, 14, 0, 14)
				toggleIndicator.Position = defaultValue and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
				toggleIndicator.AnchorPoint = Vector2.new(0, 0.5)
				toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				toggleIndicator.BorderSizePixel = 0
				toggleIndicator.Parent = toggleButton

				local indicatorCorner = Instance.new("UICorner")
				indicatorCorner.CornerRadius = UDim.new(1, 0)
				indicatorCorner.Parent = toggleIndicator

				local toggled = defaultValue
				local currentMode = "Toggle"
				local menu = nil
				local currentColor = defaultColor
				local currentAlpha = defaultAlpha
				local colorButton = nil
				local colorPopup = nil
				local rightGap = 8
				local basePadding = 5

				local function applyToggleState(value)
					toggled = value
					TweenService:Create(toggleButton, TweenInfo.new(0.2), {
						BackgroundColor3 = toggled and ACCENT_COLOR or Color3.fromRGB(50, 50, 50)
					}):Play()
					TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {
						Position = toggled and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
					}):Play()
					updateFlag(flag, toggled)
					callback(toggled)
				end
				
				-- Keypicker (optional)
				local keyButton = nil
				local currentKey = defaultKey
				local updateKeyButtonLayout = nil
				local listening = false

				local function layoutTrailing()
					local x = basePadding
					-- toggle switch (always present)
					local toggleW = toggleButton.Size.X.Offset
					toggleButton.Position = UDim2.new(1, -(x + toggleW), 0.5, 0)
					x = x + toggleW

					if colorButton then
						x = x + rightGap
						local w = colorButton.Size.X.Offset
						colorButton.Position = UDim2.new(1, -(x + w), 0.5, 0)
						x = x + w
					end

					if keyButton then
						x = x + rightGap
						local w = keyButton.Size.X.Offset
						keyButton.Position = UDim2.new(1, -(x + w), 0.5, 0)
						x = x + w
					end

					toggleLabel.Size = UDim2.new(1, -(x + 10), 1, 0)
				end
				
				if hasKeypicker then
					keyButton = Instance.new("TextButton")
					keyButton.Size = UDim2.new(0, 60, 0, 22)
					keyButton.Position = UDim2.new(1, -110, 0.5, 0)
					keyButton.AnchorPoint = Vector2.new(0, 0.5)
					keyButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
					keyButton.BorderSizePixel = 0
					keyButton.Text = formatKeyLabel(defaultKey)
					keyButton.TextColor3 = Color3.fromRGB(200, 200, 200)
					keyButton.TextSize = 10
					keyButton.Font = Enum.Font.MontserratBold
					keyButton.Parent = toggleFrame

					local keyButtonCorner = Instance.new("UICorner")
					keyButtonCorner.CornerRadius = UDim.new(0, 4)
					keyButtonCorner.Parent = keyButton

					local function updateKeyButtonLayout(text)
						local width = measureKeyButtonWidth(text, keyButton.TextSize, keyButton.Font, 38, 110)
						keyButton.Size = UDim2.new(0, width, 0, 22)
						layoutTrailing()
					end

					updateKeyButtonLayout(keyButton.Text)

					local function setKeybindMode(mode)
						if mode ~= "Hold" and mode ~= "Toggle" and mode ~= "Always" then
							return
						end
						currentMode = mode
						if currentMode == "Always" then
							applyToggleState(true)
						end
						if menu then
							menu.Update()
						end
					end

					menu = createKeypickerMenu(keyButton, function()
						return currentMode
					end, function(mode)
						setKeybindMode(mode)
					end)

					bindRightClick(keyButton, function()
						if menu then
							if menu.IsVisible and menu:IsVisible() then menu.Hide() else menu.Show() end
						end
					end)

					local function setKey(key)
						currentKey = key
						local label = formatKeyLabel(key)
						keyButton.Text = label
						keyButton.TextColor3 = Color3.fromRGB(200, 200, 200)
						updateKeyButtonLayout(label)
					end

					keyButton.MouseButton1Click:Connect(function()
						listening = true
						keyButton.Text = "..."
						keyButton.TextColor3 = ACCENT_COLOR
						updateKeyButtonLayout("...")
					end)

					UserInputService.InputBegan:Connect(function(input, gameProcessed)
						if listening and input.UserInputType == Enum.UserInputType.Keyboard then
							listening = false
							setKey(input.KeyCode)
						elseif listening and (input.UserInputType == Enum.UserInputType.MouseButton1
							or input.UserInputType == Enum.UserInputType.MouseButton2
							or input.UserInputType == Enum.UserInputType.MouseButton3) then
							listening = false
							setKey(input.UserInputType)
						elseif not gameProcessed and hasKeypicker and isKeyMatch(input, currentKey) then
							if currentMode == "Toggle" then
								applyToggleState(not toggled)
							elseif currentMode == "Hold" then
								applyToggleState(true)
							end
						end
					end)

					UserInputService.InputEnded:Connect(function(input, gameProcessed)
						if gameProcessed or not hasKeypicker then
							return
						end
						if currentMode == "Hold" and isKeyMatch(input, currentKey) then
							applyToggleState(false)
						end
					end)

					setKeybindMode(config.KeybindMode or "Toggle")
				end

				if hasColorpicker then
					colorButton = Instance.new("TextButton")
					colorButton.Name = "ColorButton"
					colorButton.Size = UDim2.new(0, 18, 0, 18)
					colorButton.AnchorPoint = Vector2.new(0, 0.5)
					colorButton.BackgroundColor3 = defaultColor
					colorButton.BorderSizePixel = 0
					colorButton.Text = ""
					colorButton.Parent = toggleFrame

					local colorCorner = Instance.new("UICorner")
					colorCorner.CornerRadius = UDim.new(0, 4)
					colorCorner.Parent = colorButton

					local colorStroke = Instance.new("UIStroke")
					colorStroke.Color = Color3.fromRGB(80, 80, 80)
					colorStroke.Thickness = 1
					colorStroke.Parent = colorButton

					colorPopup = createColorPicker(colorButton, defaultColor, defaultAlpha, function(newColor, newAlpha)
						currentColor = newColor
						currentAlpha = newAlpha
						colorButton.BackgroundColor3 = newColor
						colorCallback(newColor, newAlpha)
					end)

					colorButton.MouseButton1Click:Connect(function()
						if colorPopup then
							if colorPopup.IsVisible and colorPopup:IsVisible() and colorPopup.Hide then
								colorPopup.Hide()
							elseif colorPopup.Show then
								colorPopup.Show()
							end
						end
					end)

					colorButton.MouseButton2Click:Connect(function()
						if colorPopup then
							if colorPopup.IsVisible and colorPopup:IsVisible() and colorPopup.Hide then
								colorPopup.Hide()
							elseif colorPopup.Show then
								colorPopup.Show()
							end
						end
					end)
				end

				layoutTrailing()

				toggleFrame.MouseButton1Click:Connect(function()
					if not listening and currentMode ~= "Always" then
						applyToggleState(not toggled)
					end
				end)

				table.insert(groupbox.Elements, toggleFrame)

				-- Add to searchable elements
				table.insert(window.AllElements, {
					Frame = toggleFrame,
					SearchText = toggleText,
					Searchable = true,
					Groupbox = groupbox
				})

				registerFlag(flag, function()
					return toggled
				end, function(value)
					applyToggleState(value and true or false)
				end, toggled)

				return {
					SetValue = function(value)
						toggled = value
						TweenService:Create(toggleButton, TweenInfo.new(0.2), {
							BackgroundColor3 = toggled and ACCENT_COLOR or Color3.fromRGB(50, 50, 50)
						}):Play()
						TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {
							Position = toggled and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
						}):Play()
					end,
					SetKey = hasKeypicker and function(key)
						currentKey = key
						if keyButton then
							local label = formatKeyLabel(key)
							keyButton.Text = label
							local width = measureKeyButtonWidth(label, keyButton.TextSize, keyButton.Font, 38, 110)
							keyButton.Size = UDim2.new(0, width, 0, 22)
							layoutTrailing()
						end
					end or nil,
					SetKeyMode = hasKeypicker and function(mode)
						if mode ~= "Hold" and mode ~= "Toggle" and mode ~= "Always" then
							return
						end
						currentMode = mode
						if currentMode == "Always" then
							applyToggleState(true)
						end
						if menu then
							menu.Update()
						end
					end or nil,
					SetColor = hasColorpicker and function(color, alphaVal)
						currentColor = color or currentColor
						currentAlpha = alphaVal or currentAlpha
						if colorButton then
							colorButton.BackgroundColor3 = currentColor
						end
						if colorPopup and colorPopup.UpdateColor then
							colorPopup.UpdateColor(currentColor, currentAlpha)
						end
						colorCallback(currentColor, currentAlpha)
					end or nil
				}
			end

			-- Add Checkbox
			function groupbox:AddCheckbox(config)
				config = config or {}
				local checkboxText = config.Text or "Checkbox"
				local defaultValue = config.Default or false
				local callback = config.Callback or function() end
				local flag = config.Flag or nextFlag(groupboxName .. "_Checkbox")
				local hasKeypicker = config.Keybind ~= nil
				local defaultKey = config.Keybind or Enum.KeyCode.E
				local hasColorpicker = config.ColorPicker ~= nil and config.ColorPicker ~= false
				local defaultColor = config.ColorPicker or config.ColorDefault or Color3.fromRGB(209, 119, 176)
				local defaultAlpha = config.AlphaDefault or 1
				local colorCallback = config.ColorCallback or function() end

				local checkboxFrame = Instance.new("TextButton")
				checkboxFrame.Name = "Checkbox"
				checkboxFrame.Size = UDim2.new(1, 0, 0, 30)
				checkboxFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				checkboxFrame.Text = ""
				checkboxFrame.LayoutOrder = #groupbox.Elements + 1
				checkboxFrame.Parent = contentContainer

				local checkboxCorner = Instance.new("UICorner")
				checkboxCorner.CornerRadius = UDim.new(0, 4)
				checkboxCorner.Parent = checkboxFrame

				createHoverEffect(checkboxFrame, false)

				local checkboxLabel = Instance.new("TextLabel")
				checkboxLabel.Size = UDim2.new(1, -50, 1, 0)
				checkboxLabel.Position = UDim2.new(0, 10, 0, 0)
				checkboxLabel.BackgroundTransparency = 1
				checkboxLabel.Text = checkboxText
				checkboxLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
				checkboxLabel.TextSize = 12
				checkboxLabel.Font = Enum.Font.Montserrat
				checkboxLabel.TextXAlignment = Enum.TextXAlignment.Left
				checkboxLabel.Parent = checkboxFrame

				-- Checkbox button container - aligned with toggle right edge
				local checkboxButton = Instance.new("Frame")
				checkboxButton.Size = UDim2.new(0, 14, 0, 14)
				checkboxButton.Position = UDim2.new(1, -27, 0.5, 0)
				checkboxButton.AnchorPoint = Vector2.new(0, 0.5)
				checkboxButton.BackgroundTransparency = 1
				checkboxButton.Parent = checkboxFrame

				-- Outline
				local checkboxOutline = Instance.new("Frame")
				checkboxOutline.Size = UDim2.new(1, 0, 1, 0)
				checkboxOutline.BackgroundTransparency = 1
				checkboxOutline.Parent = checkboxButton

				local outlineStroke = Instance.new("UIStroke")
				outlineStroke.Color = Color3.fromRGB(100, 100, 100)
				outlineStroke.Thickness = 1
				outlineStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				outlineStroke.Parent = checkboxOutline

				local outlineCorner = Instance.new("UICorner")
				outlineCorner.CornerRadius = UDim.new(1, 0)
				outlineCorner.Parent = checkboxOutline

				-- Fill (slightly smaller when checked)
				local checkboxFill = Instance.new("Frame")
				checkboxFill.Size = defaultValue and UDim2.new(1, -4, 1, -4) or UDim2.new(0, 0, 0, 0)
				checkboxFill.Position = UDim2.new(0.5, 0, 0.5, 0)
				checkboxFill.AnchorPoint = Vector2.new(0.5, 0.5)
				checkboxFill.BackgroundColor3 = ACCENT_COLOR
				checkboxFill.BorderSizePixel = 0
				checkboxFill.Parent = checkboxButton

				local fillCorner = Instance.new("UICorner")
				fillCorner.CornerRadius = UDim.new(1, 0)
				fillCorner.Parent = checkboxFill

				local checked = defaultValue
				local currentMode = "Toggle"
				local listening = false
				local keyButton = nil
				local currentKey = defaultKey
				local colorButton = nil
				local colorPopup = nil
				local currentColor = defaultColor
				local currentAlpha = defaultAlpha
				local rightGap = 8
				local basePadding = 8
				local updateKeyButtonLayout = nil

				local function layoutTrailing()
					local x = basePadding
					local cbWidth = checkboxButton.Size.X.Offset
					checkboxButton.Position = UDim2.new(1, -(x + cbWidth), 0.5, 0)
					x = x + cbWidth

					if colorButton then
						x = x + rightGap
						local w = colorButton.Size.X.Offset
						colorButton.Position = UDim2.new(1, -(x + w), 0.5, 0)
						x = x + w
					end

					if keyButton then
						x = x + rightGap
						local w = keyButton.Size.X.Offset
						keyButton.Position = UDim2.new(1, -(x + w), 0.5, 0)
						x = x + w
					end

					checkboxLabel.Size = UDim2.new(1, -(x + 10), 1, 0)
				end

				local function setCheckboxState(value, fireCallback)
					checked = value
					if checked then
						TweenService:Create(checkboxFill, TweenInfo.new(0.2), {
							Size = UDim2.new(1, -4, 1, -4)
						}):Play()
						TweenService:Create(outlineStroke, TweenInfo.new(0.2), {
							Color = ACCENT_COLOR
						}):Play()
					else
						TweenService:Create(checkboxFill, TweenInfo.new(0.2), {
							Size = UDim2.new(0, 0, 0, 0)
						}):Play()
						TweenService:Create(outlineStroke, TweenInfo.new(0.2), {
							Color = Color3.fromRGB(100, 100, 100)
						}):Play()
					end
					if fireCallback then
						callback(checked)
					end
					updateFlag(flag, checked)
				end

				if checked then
					outlineStroke.Color = ACCENT_COLOR
				end

				if hasKeypicker then
					keyButton = Instance.new("TextButton")
					keyButton.Size = UDim2.new(0, 60, 0, 22)
					keyButton.Position = UDim2.new(1, -65, 0.5, 0)
					keyButton.AnchorPoint = Vector2.new(0, 0.5)
					keyButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
					keyButton.BorderSizePixel = 0
					keyButton.Text = formatKeyLabel(defaultKey)
					keyButton.TextColor3 = Color3.fromRGB(200, 200, 200)
					keyButton.TextSize = 10
					keyButton.Font = Enum.Font.MontserratBold
					keyButton.Parent = checkboxFrame

					local keyButtonCorner = Instance.new("UICorner")
					keyButtonCorner.CornerRadius = UDim.new(0, 4)
					keyButtonCorner.Parent = keyButton

					updateKeyButtonLayout = function(text)
						local width = measureKeyButtonWidth(text, keyButton.TextSize, keyButton.Font, 38, 110)
						keyButton.Size = UDim2.new(0, width, 0, 22)
						layoutTrailing()
					end

					updateKeyButtonLayout(keyButton.Text)

					local menu = nil

					local function setKeybindMode(mode)
						if mode ~= "Hold" and mode ~= "Toggle" and mode ~= "Always" then
							return
						end
						currentMode = mode
						if currentMode == "Always" then
							setCheckboxState(true, true)
						end
						if menu then
							menu.Update()
						end
					end

					menu = createKeypickerMenu(keyButton, function()
						return currentMode
					end, function(mode)
						setKeybindMode(mode)
					end)

					local function setKey(key)
						currentKey = key
						local label = formatKeyLabel(key)
						keyButton.Text = label
						keyButton.TextColor3 = Color3.fromRGB(200, 200, 200)
						updateKeyButtonLayout(label)
					end

					keyButton.MouseButton1Click:Connect(function()
						listening = true
						keyButton.Text = "..."
						keyButton.TextColor3 = ACCENT_COLOR
						updateKeyButtonLayout("...")
					end)

					UserInputService.InputBegan:Connect(function(input, gameProcessed)
						if listening and input.UserInputType == Enum.UserInputType.Keyboard then
							listening = false
							setKey(input.KeyCode)
						elseif listening and (input.UserInputType == Enum.UserInputType.MouseButton1
							or input.UserInputType == Enum.UserInputType.MouseButton2
							or input.UserInputType == Enum.UserInputType.MouseButton3) then
							listening = false
							setKey(input.UserInputType)
						elseif not gameProcessed and hasKeypicker and isKeyMatch(input, currentKey) then
							if currentMode == "Toggle" then
								setCheckboxState(not checked, true)
							elseif currentMode == "Hold" then
								setCheckboxState(true, true)
							end
						end
					end)

					UserInputService.InputEnded:Connect(function(input, gameProcessed)
						if gameProcessed or not hasKeypicker then
							return
						end
						if currentMode == "Hold" and isKeyMatch(input, currentKey) then
							setCheckboxState(false, true)
						end
					end)

					setKeybindMode(config.KeybindMode or "Toggle")
				end

				if hasColorpicker then
					colorButton = Instance.new("TextButton")
					colorButton.Name = "ColorButton"
					colorButton.Size = UDim2.new(0, 18, 0, 18)
					colorButton.AnchorPoint = Vector2.new(0, 0.5)
					colorButton.BackgroundColor3 = defaultColor
					colorButton.BorderSizePixel = 0
					colorButton.Text = ""
					colorButton.Parent = checkboxFrame

					local colorCorner = Instance.new("UICorner")
					colorCorner.CornerRadius = UDim.new(0, 4)
					colorCorner.Parent = colorButton

					local colorStroke = Instance.new("UIStroke")
					colorStroke.Color = Color3.fromRGB(80, 80, 80)
					colorStroke.Thickness = 1
					colorStroke.Parent = colorButton

					colorPopup = createColorPicker(colorButton, defaultColor, defaultAlpha, function(newColor, newAlpha)
						currentColor = newColor
						currentAlpha = newAlpha
						colorButton.BackgroundColor3 = newColor
						colorCallback(newColor, newAlpha)
					end)

					colorButton.MouseButton1Click:Connect(function()
						if colorPopup then
							if colorPopup.IsVisible and colorPopup:IsVisible() and colorPopup.Hide then
								colorPopup.Hide()
							elseif colorPopup.Show then
								colorPopup.Show()
							end
						end
					end)

					colorButton.MouseButton2Click:Connect(function()
						if colorPopup then
							if colorPopup.IsVisible and colorPopup:IsVisible() and colorPopup.Hide then
								colorPopup.Hide()
							elseif colorPopup.Show then
								colorPopup.Show()
							end
						end
					end)
				end

				layoutTrailing()

				checkboxFrame.MouseButton1Click:Connect(function()
					if not listening and currentMode ~= "Always" then
						setCheckboxState(not checked, true)
					end
				end)

				table.insert(groupbox.Elements, checkboxFrame)

				-- Add to searchable elements
				table.insert(window.AllElements, {
					Frame = checkboxFrame,
					SearchText = checkboxText,
					Searchable = true,
					Groupbox = groupbox
				})

				registerFlag(flag, function()
					return checked
				end, function(value)
					setCheckboxState(value and true or false, false)
				end, checked)

				return {
					SetValue = function(value)
						setCheckboxState(value, false)
					end,
					SetKey = hasKeypicker and function(key)
						currentKey = key
						if keyButton then
							local label = formatKeyLabel(key)
							keyButton.Text = label
							if updateKeyButtonLayout then
								updateKeyButtonLayout(label)
							end
						end
					end or nil,
					SetKeyMode = hasKeypicker and function(mode)
						if mode ~= "Hold" and mode ~= "Toggle" and mode ~= "Always" then
							return
						end
						currentMode = mode
						if currentMode == "Always" then
							setCheckboxState(true, true)
						end
					end or nil,
					SetColor = hasColorpicker and function(color, alphaVal)
						currentColor = color or currentColor
						currentAlpha = alphaVal or currentAlpha
						if colorButton then
							colorButton.BackgroundColor3 = currentColor
						end
						if colorPopup and colorPopup.UpdateColor then
							colorPopup.UpdateColor(currentColor, currentAlpha)
						end
						colorCallback(currentColor, currentAlpha)
					end or nil
				}
			end

			-- Add Slider
			function groupbox:AddSlider(config)
				config = config or {}
				local sliderText = config.Text or "Slider"
				local minValue = config.Min or 0
				local maxValue = config.Max or 100
				local defaultValue = config.Default or minValue
				local increment = config.Increment or 1
				local callback = config.Callback or function() end
				local flag = config.Flag or nextFlag(groupboxName .. "_Slider")

				local sliderFrame = Instance.new("Frame")
				sliderFrame.Name = "Slider"
				sliderFrame.Size = UDim2.new(1, 0, 0, 50)
				sliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				sliderFrame.BorderSizePixel = 0
				sliderFrame.LayoutOrder = #groupbox.Elements + 1
				sliderFrame.Parent = contentContainer

				local sliderCorner = Instance.new("UICorner")
				sliderCorner.CornerRadius = UDim.new(0, 4)
				sliderCorner.Parent = sliderFrame

				createHoverEffect(sliderFrame, false)

				local sliderLabel = Instance.new("TextLabel")
				sliderLabel.Size = UDim2.new(1, -80, 0, 20)
				sliderLabel.Position = UDim2.new(0, 10, 0, 5)
				sliderLabel.BackgroundTransparency = 1
				sliderLabel.Text = sliderText
				sliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
				sliderLabel.TextSize = 12
				sliderLabel.Font = Enum.Font.Montserrat
				sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
				sliderLabel.Parent = sliderFrame

				local valueLabel = Instance.new("TextLabel")
				valueLabel.Size = UDim2.new(0, 60, 0, 20)
				valueLabel.Position = UDim2.new(1, -70, 0, 5)
				valueLabel.BackgroundTransparency = 1
				valueLabel.Text = tostring(defaultValue)
				valueLabel.TextColor3 = ACCENT_COLOR
				valueLabel.TextSize = 12
				valueLabel.Font = Enum.Font.MontserratBold
				valueLabel.TextXAlignment = Enum.TextXAlignment.Right
				valueLabel.Parent = sliderFrame

				-- Slider track
				local sliderTrack = Instance.new("Frame")
				sliderTrack.Size = UDim2.new(1, -20, 0, 4)
				sliderTrack.Position = UDim2.new(0, 10, 1, -15)
				sliderTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				sliderTrack.BorderSizePixel = 0
				sliderTrack.Parent = sliderFrame

				local trackCorner = Instance.new("UICorner")
				trackCorner.CornerRadius = UDim.new(1, 0)
				trackCorner.Parent = sliderTrack

				-- Slider fill
				local sliderFill = Instance.new("Frame")
				sliderFill.Size = UDim2.new(0, 0, 1, 0)
				sliderFill.BackgroundColor3 = ACCENT_COLOR
				sliderFill.BorderSizePixel = 0
				sliderFill.Parent = sliderTrack

				local fillCorner = Instance.new("UICorner")
				fillCorner.CornerRadius = UDim.new(1, 0)
				fillCorner.Parent = sliderFill

				-- Slider button
				local sliderButton = Instance.new("Frame")
				sliderButton.Size = UDim2.new(0, 12, 0, 12)
				sliderButton.AnchorPoint = Vector2.new(0.5, 0.5)
				sliderButton.Position = UDim2.new(0, 0, 0.5, 0)
				sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				sliderButton.BorderSizePixel = 0
				sliderButton.Parent = sliderTrack

				local buttonCorner = Instance.new("UICorner")
				buttonCorner.CornerRadius = UDim.new(1, 0)
				buttonCorner.Parent = sliderButton

				local currentValue = defaultValue
				local dragging = false
				local targetPercent = (defaultValue - minValue) / (maxValue - minValue)
				local currentPercent = targetPercent
				local sliderInitialized = false

				local function updateSlider(value, immediate)
					-- Clamp and round value
					value = math.clamp(value, minValue, maxValue)
					value = math.floor((value - minValue) / increment + 0.5) * increment + minValue
					currentValue = value

					-- Update target position
					targetPercent = (value - minValue) / (maxValue - minValue)
					valueLabel.Text = tostring(value)

					callback(value)
					updateFlag(flag, value)

					if immediate or not sliderInitialized then
						currentPercent = targetPercent
						sliderButton.Position = UDim2.new(currentPercent, 0, 0.5, 0)
						sliderFill.Size = UDim2.new(currentPercent, 0, 1, 0)
						sliderInitialized = true
					end
				end

				-- Lerp animation for smooth movement
				RunService.Heartbeat:Connect(function()
					if math.abs(targetPercent - currentPercent) > 0.001 then
						currentPercent = currentPercent + (targetPercent - currentPercent) * 0.2
						sliderButton.Position = UDim2.new(currentPercent, 0, 0.5, 0)
						sliderFill.Size = UDim2.new(currentPercent, 0, 1, 0)
					else
						currentPercent = targetPercent
					end
				end)

				local function onInput(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or 
					   input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
					end
				end

				local function onInputEnded(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or 
					   input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end

				sliderTrack.InputBegan:Connect(onInput)
				sliderButton.InputBegan:Connect(onInput)

				UserInputService.InputEnded:Connect(onInputEnded)

				UserInputService.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
					                 input.UserInputType == Enum.UserInputType.Touch) then
						local pos = input.Position.X
						local trackPos = sliderTrack.AbsolutePosition.X
						local trackSize = sliderTrack.AbsoluteSize.X
						local percent = math.clamp((pos - trackPos) / trackSize, 0, 1)
						local value = minValue + (maxValue - minValue) * percent
						updateSlider(value)
					end
				end)

				-- Initialize
				updateSlider(defaultValue, true)

				table.insert(groupbox.Elements, sliderFrame)

				-- Add to searchable elements
				table.insert(window.AllElements, {
					Frame = sliderFrame,
					SearchText = sliderText,
					Searchable = true,
					Groupbox = groupbox
				})

				registerFlag(flag, function()
					return currentValue
				end, function(value)
					updateSlider(tonumber(value) or minValue)
				end, currentValue)

				return {
					SetValue = function(value)
						updateSlider(value)
					end
				}
			end

			-- Add TextBox
			function groupbox:AddTextbox(config)
				config = config or {}
				local textboxLabel = config.Text or "Textbox"
				local placeholderText = config.Placeholder or "Enter text..."
				local defaultValue = config.Default or ""
				local callback = config.Callback or function() end
				local flag = config.Flag or nextFlag(groupboxName .. "_Textbox")

				local textboxFrame = Instance.new("Frame")
				textboxFrame.Name = "Textbox"
				textboxFrame.Size = UDim2.new(1, 0, 0, 55)
				textboxFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				textboxFrame.BorderSizePixel = 0
				textboxFrame.LayoutOrder = #groupbox.Elements + 1
				textboxFrame.Parent = contentContainer

				local textboxCorner = Instance.new("UICorner")
				textboxCorner.CornerRadius = UDim.new(0, 4)
				textboxCorner.Parent = textboxFrame

				createHoverEffect(textboxFrame, false)

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, -20, 0, 20)
				label.Position = UDim2.new(0, 10, 0, 5)
				label.BackgroundTransparency = 1
				label.Text = textboxLabel
				label.TextColor3 = Color3.fromRGB(200, 200, 200)
				label.TextSize = 12
				label.Font = Enum.Font.Montserrat
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = textboxFrame

				local textboxInput = Instance.new("TextBox")
				textboxInput.Size = UDim2.new(1, -20, 0, 25)
				textboxInput.Position = UDim2.new(0, 10, 0, 25)
				textboxInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				textboxInput.BorderSizePixel = 0
				textboxInput.Text = defaultValue
				textboxInput.PlaceholderText = placeholderText
				textboxInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
				textboxInput.TextColor3 = Color3.fromRGB(200, 200, 200)
				textboxInput.TextSize = 12
				textboxInput.Font = Enum.Font.Montserrat
				textboxInput.TextXAlignment = Enum.TextXAlignment.Left
				textboxInput.ClearTextOnFocus = false
				textboxInput.Parent = textboxFrame

				local inputCorner = Instance.new("UICorner")
				inputCorner.CornerRadius = UDim.new(0, 4)
				inputCorner.Parent = textboxInput

				local inputPadding = Instance.new("UIPadding")
				inputPadding.PaddingLeft = UDim.new(0, 8)
				inputPadding.PaddingRight = UDim.new(0, 8)
				inputPadding.Parent = textboxInput

				textboxInput.FocusLost:Connect(function(enterPressed)
					callback(textboxInput.Text)
					updateFlag(flag, textboxInput.Text)
				end)

				table.insert(groupbox.Elements, textboxFrame)

				-- Add to searchable elements
				table.insert(window.AllElements, {
					Frame = textboxFrame,
					SearchText = textboxLabel,
					Searchable = true,
					Groupbox = groupbox
				})

				registerFlag(flag, function()
					return textboxInput.Text
				end, function(value)
					textboxInput.Text = tostring(value or "")
					updateFlag(flag, textboxInput.Text)
				end, defaultValue)

				return {
					SetValue = function(value)
						textboxInput.Text = value
						updateFlag(flag, textboxInput.Text)
					end,
					GetValue = function()
						return textboxInput.Text
					end
				}
			end

			-- Add Keypicker
			function groupbox:AddKeypicker(config)
				config = config or {}
				local keypickerText = config.Text or "Keybind"
				local defaultKey = config.Default or Enum.KeyCode.E
				local callback = config.Callback or function() end
				local modeCallback = config.ModeCallback or function() end
				local flag = config.Flag or nextFlag(groupboxName .. "_Keypicker")

				local keypickerFrame = Instance.new("Frame")
				keypickerFrame.Name = "Keypicker"
				keypickerFrame.Size = UDim2.new(1, 0, 0, 30)
				keypickerFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				keypickerFrame.BorderSizePixel = 0
				keypickerFrame.LayoutOrder = #groupbox.Elements + 1
				keypickerFrame.Parent = contentContainer

				local keypickerCorner = Instance.new("UICorner")
				keypickerCorner.CornerRadius = UDim.new(0, 4)
				keypickerCorner.Parent = keypickerFrame

				createHoverEffect(keypickerFrame, false)

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, -80, 1, 0)
				label.Position = UDim2.new(0, 10, 0, 0)
				label.BackgroundTransparency = 1
				label.Text = keypickerText
				label.TextColor3 = Color3.fromRGB(200, 200, 200)
				label.TextSize = 12
				label.Font = Enum.Font.Montserrat
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = keypickerFrame

				local keyButton = Instance.new("TextButton")
				keyButton.Size = UDim2.new(0, 60, 0, 22)
				keyButton.Position = UDim2.new(1, -65, 0.5, 0)
				keyButton.AnchorPoint = Vector2.new(0, 0.5)
				keyButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				keyButton.BorderSizePixel = 0
				keyButton.Text = formatKeyLabel(defaultKey)
				keyButton.TextColor3 = Color3.fromRGB(200, 200, 200)
				keyButton.TextSize = 11
				keyButton.Font = Enum.Font.MontserratBold
				keyButton.Parent = keypickerFrame

				local keyButtonCorner = Instance.new("UICorner")
				keyButtonCorner.CornerRadius = UDim.new(0, 4)
				keyButtonCorner.Parent = keyButton

				local currentKey = defaultKey
				local currentMode = "Toggle"
				local listening = false

				local function updateKeyButtonLayout(text)
					local width = measureKeyButtonWidth(text, keyButton.TextSize, keyButton.Font, 40, 120)
					local rightInset = 5
					local keyGap = 8
					keyButton.Size = UDim2.new(0, width, 0, 22)
					keyButton.Position = UDim2.new(1, -(width + rightInset), 0.5, 0)
					label.Size = UDim2.new(1, -(width + rightInset + keyGap + 10), 1, 0)
				end

				updateKeyButtonLayout(keyButton.Text)

				local function setKey(key)
					currentKey = key
					local labelText = formatKeyLabel(key)
					keyButton.Text = labelText
					keyButton.TextColor3 = Color3.fromRGB(200, 200, 200)
					updateKeyButtonLayout(labelText)
					callback(key, currentMode)
					updateFlag(flag, {Key = currentKey, Mode = currentMode})
				end

				local menu = nil

				local function setMode(mode)
					if mode ~= "Hold" and mode ~= "Toggle" and mode ~= "Always" then
						return
					end
					currentMode = mode
					modeCallback(mode)
					callback(currentKey, currentMode)
					if menu then
						menu.Update()
					end
					updateFlag(flag, {Key = currentKey, Mode = currentMode})
				end

				menu = createKeypickerMenu(keyButton, function()
					return currentMode
				end, function(mode)
					setMode(mode)
				end)

				bindRightClick(keyButton, function()
					if menu then
						if menu.IsVisible and menu:IsVisible() then menu.Hide() else menu.Show() end
					end
				end)

				keyButton.MouseButton1Click:Connect(function()
					listening = true
					keyButton.Text = "..."
					keyButton.TextColor3 = ACCENT_COLOR
					updateKeyButtonLayout("...")
				end)

				UserInputService.InputBegan:Connect(function(input, gameProcessed)
					if listening and input.UserInputType == Enum.UserInputType.Keyboard then
						listening = false
						setKey(input.KeyCode)
						keyButton.TextColor3 = Color3.fromRGB(200, 200, 200)
					elseif listening and (input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.MouseButton2
						or input.UserInputType == Enum.UserInputType.MouseButton3) then
						listening = false
						setKey(input.UserInputType)
					end
				end)

				setMode(config.Mode or "Toggle")

				table.insert(groupbox.Elements, keypickerFrame)

				table.insert(window.AllElements, {
					Frame = keypickerFrame,
					SearchText = keypickerText,
					Searchable = true,
					Groupbox = groupbox
				})

				registerFlag(flag, function()
					return {Key = currentKey, Mode = currentMode}
				end, function(value)
					if type(value) == "table" then
						if value.Key then
							setKey(value.Key)
						end
						if value.Mode then
							setMode(value.Mode)
						end
					end
				end, {Key = currentKey, Mode = currentMode})

				return {
					SetValue = function(key)
						setKey(key)
					end,
					SetMode = function(mode)
						setMode(mode)
					end,
					GetValue = function()
						return currentKey, currentMode
					end
				}
			end

			-- Add Color Picker
			function groupbox:AddColorPicker(config)
				config = config or {}
				local pickerText = config.Text or "Color"
				local defaultColor = config.Default or Color3.fromRGB(209, 119, 176)
				local defaultAlpha = config.AlphaDefault or 1
				local callback = config.Callback or function() end
				local flag = config.Flag or nextFlag(groupboxName .. "_Color")

				local pickerFrame = Instance.new("TextButton")
				pickerFrame.Name = "ColorPicker"
				pickerFrame.Size = UDim2.new(1, 0, 0, 30)
				pickerFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				pickerFrame.Text = ""
				pickerFrame.LayoutOrder = #groupbox.Elements + 1
				pickerFrame.Parent = contentContainer

				local pickerCorner = Instance.new("UICorner")
				pickerCorner.CornerRadius = UDim.new(0, 4)
				pickerCorner.Parent = pickerFrame

				createHoverEffect(pickerFrame, false)

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, -50, 1, 0)
				label.Position = UDim2.new(0, 10, 0, 0)
				label.BackgroundTransparency = 1
				label.Text = pickerText
				label.TextColor3 = Color3.fromRGB(200, 200, 200)
				label.TextSize = 12
				label.Font = Enum.Font.Montserrat
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = pickerFrame

				local colorButton = Instance.new("TextButton")
				colorButton.Name = "ColorButton"
				colorButton.Size = UDim2.new(0, 18, 0, 18)
				colorButton.AnchorPoint = Vector2.new(0, 0.5)
				colorButton.Position = UDim2.new(1, -28, 0.5, 0)
				colorButton.BackgroundColor3 = defaultColor
				colorButton.BorderSizePixel = 0
				colorButton.Text = ""
				colorButton.Parent = pickerFrame

				local colorCorner = Instance.new("UICorner")
				colorCorner.CornerRadius = UDim.new(0, 4)
				colorCorner.Parent = colorButton

				local colorStroke = Instance.new("UIStroke")
				colorStroke.Color = Color3.fromRGB(80, 80, 80)
				colorStroke.Thickness = 1
				colorStroke.Parent = colorButton

				local currentColor = defaultColor
				local currentAlpha = defaultAlpha

				local pickerPopup = createColorPicker(colorButton, defaultColor, defaultAlpha, function(newColor, newAlpha)
					currentColor = newColor
					currentAlpha = newAlpha
					colorButton.BackgroundColor3 = newColor
					callback(newColor, newAlpha)
					updateFlag(flag, {Color = currentColor, Alpha = currentAlpha})
				end)

				local function togglePicker()
					if pickerPopup then
						if pickerPopup.IsVisible and pickerPopup:IsVisible() and pickerPopup.Hide then
							pickerPopup.Hide()
						elseif pickerPopup.Show then
							pickerPopup.Show()
						end
					end
				end

				colorButton.MouseButton1Click:Connect(togglePicker)
				pickerFrame.MouseButton2Click:Connect(togglePicker)

				table.insert(groupbox.Elements, pickerFrame)

				table.insert(window.AllElements, {
					Frame = pickerFrame,
					SearchText = pickerText,
					Searchable = true,
					Groupbox = groupbox
				})

				registerFlag(flag, function()
					return {Color = currentColor, Alpha = currentAlpha}
				end, function(value)
					if type(value) == "table" then
						if value.Color then
							currentColor = value.Color
							colorButton.BackgroundColor3 = currentColor
						end
						if value.Alpha then
							currentAlpha = value.Alpha
						end
						if pickerPopup and pickerPopup.UpdateColor then
							pickerPopup.UpdateColor(currentColor, currentAlpha)
						end
						callback(currentColor, currentAlpha)
						updateFlag(flag, {Color = currentColor, Alpha = currentAlpha})
					end
				end, {Color = currentColor, Alpha = currentAlpha})

				return {
					SetValue = function(color, alpha)
						currentColor = color or currentColor
						currentAlpha = alpha or currentAlpha
						colorButton.BackgroundColor3 = currentColor
						if pickerPopup and pickerPopup.UpdateColor then
							pickerPopup.UpdateColor(currentColor, currentAlpha)
						end
						callback(currentColor, currentAlpha)
						updateFlag(flag, {Color = currentColor, Alpha = currentAlpha})
					end,
					GetValue = function()
						return currentColor, currentAlpha
					end
				}
			end

			-- Add Dropdown
			function groupbox:AddDropdown(config)
				config = config or {}
				local dropdownText = config.Text or "Dropdown"
				local options = config.Options or {"Option 1", "Option 2", "Option 3"}
				local defaultValue = config.Default or (config.Multi and {} or options[1])
				local callback = config.Callback or function() end
				local isMulti = config.Multi or false
				local flag = config.Flag or nextFlag(groupboxName .. "_Dropdown")

				local dropdownFrame = Instance.new("Frame")
				dropdownFrame.Name = "Dropdown"
				dropdownFrame.Size = UDim2.new(1, 0, 0, 55)
				dropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				dropdownFrame.BorderSizePixel = 0
				dropdownFrame.LayoutOrder = #groupbox.Elements + 1
				dropdownFrame.Parent = contentContainer
				dropdownFrame.ClipsDescendants = true

				local dropdownCorner = Instance.new("UICorner")
				dropdownCorner.CornerRadius = UDim.new(0, 4)
				dropdownCorner.Parent = dropdownFrame

				createHoverEffect(dropdownFrame, false)

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, -20, 0, 20)
				label.Position = UDim2.new(0, 10, 0, 5)
				label.BackgroundTransparency = 1
				label.Text = dropdownText
				label.TextColor3 = Color3.fromRGB(200, 200, 200)
				label.TextSize = 12
				label.Font = Enum.Font.Montserrat
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = dropdownFrame

				local dropdownButton = Instance.new("TextButton")
				dropdownButton.Size = UDim2.new(1, -20, 0, 25)
				dropdownButton.Position = UDim2.new(0, 10, 0, 25)
				dropdownButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				dropdownButton.BorderSizePixel = 0
				dropdownButton.Text = ""
				dropdownButton.Parent = dropdownFrame

				local buttonCorner = Instance.new("UICorner")
				buttonCorner.CornerRadius = UDim.new(0, 4)
				buttonCorner.Parent = dropdownButton

				local selectedLabel = Instance.new("TextLabel")
				selectedLabel.Size = UDim2.new(1, -30, 1, 0)
				selectedLabel.Position = UDim2.new(0, 8, 0, 0)
				selectedLabel.BackgroundTransparency = 1
				selectedLabel.Text = isMulti and "None" or defaultValue
				selectedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
				selectedLabel.TextSize = 12
				selectedLabel.Font = Enum.Font.Montserrat
				selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
				selectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
				selectedLabel.Parent = dropdownButton

				local arrow = Instance.new("TextLabel")
				arrow.Size = UDim2.new(0, 20, 1, 0)
				arrow.Position = UDim2.new(1, -20, 0, 0)
				arrow.BackgroundTransparency = 1
				arrow.Text = "+"
				arrow.TextColor3 = Color3.fromRGB(150, 150, 150)
				arrow.TextSize = 14
				arrow.Font = Enum.Font.Montserrat
				arrow.Parent = dropdownButton

				local optionsContainer = Instance.new("Frame")
				optionsContainer.Size = UDim2.new(1, -20, 0, 0)
				optionsContainer.Position = UDim2.new(0, 10, 0, 55)
				optionsContainer.BackgroundTransparency = 1
				optionsContainer.Parent = dropdownFrame

				local optionsLayout = Instance.new("UIListLayout")
				optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
				optionsLayout.Padding = UDim.new(0, 2)
				optionsLayout.Parent = optionsContainer

				local isOpen = false
				local selectedValues = isMulti and (type(defaultValue) == "table" and defaultValue or {}) or {}
				local currentValue = isMulti and selectedValues or defaultValue

				local function hasOption(value)
					for _, option in ipairs(options) do
						if option == value then
							return true
						end
					end
					return false
				end

				local function updateSelectedLabel()
					if isMulti then
						local filtered = {}
						for _, value in ipairs(selectedValues) do
							if hasOption(value) then
								table.insert(filtered, value)
							end
						end
						selectedValues = filtered
						if #selectedValues == 0 then
							selectedLabel.Text = "None"
						elseif #selectedValues == 1 then
							selectedLabel.Text = selectedValues[1]
						else
							selectedLabel.Text = selectedValues[1] .. " (+" .. (#selectedValues - 1) .. ")"
						end
					else
						if not hasOption(currentValue) then
							currentValue = options[1] or ""
						end
						selectedLabel.Text = currentValue or ""
					end
				end

				local function closeDropdown()
					isOpen = false
					TweenService:Create(dropdownFrame, TweenInfo.new(0.2), {
						Size = UDim2.new(1, 0, 0, 55)
					}):Play()
					arrow.Text = "+"
				end

				local function openDropdown()
					isOpen = true
					local optionHeight = 25
					local totalHeight = 55 + (#options * (optionHeight + 2))
					TweenService:Create(dropdownFrame, TweenInfo.new(0.2), {
						Size = UDim2.new(1, 0, 0, totalHeight)
					}):Play()
					arrow.Text = "-"
				end

				dropdownButton.MouseButton1Click:Connect(function()
					if isOpen then
						closeDropdown()
					else
						openDropdown()
					end
				end)

				-- Create option buttons
				for i, option in ipairs(options) do
					local optionButton = Instance.new("TextButton")
					optionButton.Size = UDim2.new(1, 0, 0, 25)
					optionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					optionButton.BorderSizePixel = 0
					optionButton.Text = ""
					optionButton.LayoutOrder = i
					optionButton.Parent = optionsContainer

					local optionCorner = Instance.new("UICorner")
					optionCorner.CornerRadius = UDim.new(0, 4)
					optionCorner.Parent = optionButton

					local optionLabel = Instance.new("TextLabel")
					optionLabel.Size = UDim2.new(1, -10, 1, 0)
					optionLabel.Position = UDim2.new(0, 8, 0, 0)
					optionLabel.BackgroundTransparency = 1
					optionLabel.Text = option
					optionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
					optionLabel.TextSize = 11
					optionLabel.Font = Enum.Font.Montserrat
					optionLabel.TextXAlignment = Enum.TextXAlignment.Left
					optionLabel.Parent = optionButton

					-- Selection indicator for multi-select
					local selectIndicator = nil
					if isMulti then
						selectIndicator = Instance.new("Frame")
						selectIndicator.Name = "SelectIndicator"
						selectIndicator.Size = UDim2.new(0, 4, 0, 0)
						selectIndicator.Position = UDim2.new(0, 0, 0, 0)
						selectIndicator.BackgroundColor3 = ACCENT_COLOR
						selectIndicator.BorderSizePixel = 0
						selectIndicator.ZIndex = optionButton.ZIndex + 1
						selectIndicator.Parent = optionButton
						local indicatorCorner = Instance.new("UICorner")
						indicatorCorner.CornerRadius = UDim.new(0, 4)
						indicatorCorner.Parent = selectIndicator

						for _, val in ipairs(selectedValues) do
							if val == option then
								selectIndicator.Size = UDim2.new(0, 4, 1, 0)
								break
							end
						end
					end

					optionButton.MouseEnter:Connect(function()
						TweenService:Create(optionButton, TweenInfo.new(0.15), {
							BackgroundColor3 = Color3.fromRGB(55, 55, 55)
						}):Play()
					end)

					optionButton.MouseLeave:Connect(function()
						TweenService:Create(optionButton, TweenInfo.new(0.15), {
							BackgroundColor3 = Color3.fromRGB(45, 45, 45)
						}):Play()
					end)

					optionButton.MouseButton1Click:Connect(function()
						if isMulti then
							-- Multi-select logic
							local found = false
							for j, val in ipairs(selectedValues) do
								if val == option then
									table.remove(selectedValues, j)
									found = true
									break
								end
							end

							if not found then
								table.insert(selectedValues, option)
							end

							-- Update selection indicator
							if selectIndicator then
								local targetSize = found and UDim2.new(0, 4, 0, 0) or UDim2.new(0, 4, 1, 0)
								TweenService:Create(selectIndicator, TweenInfo.new(0.18), {
									Size = targetSize
								}):Play()
							end

							updateSelectedLabel()
							callback(selectedValues)
							updateFlag(flag, selectedValues)
						else
							-- Single select logic
							currentValue = option
							selectedLabel.Text = option
							closeDropdown()
							callback(option)
							updateFlag(flag, currentValue)
						end
					end)
				end
				local function rebuildOptions(newOptions)
					options = newOptions or {}
					for _, child in ipairs(optionsContainer:GetChildren()) do
						if not child:IsA("UIListLayout") then
							child:Destroy()
						end
					end

					for i, option in ipairs(options) do
						local optionButton = Instance.new("TextButton")
						optionButton.Size = UDim2.new(1, 0, 0, 25)
						optionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
						optionButton.BorderSizePixel = 0
						optionButton.Text = ""
						optionButton.LayoutOrder = i
						optionButton.Parent = optionsContainer

						local optionCorner = Instance.new("UICorner")
						optionCorner.CornerRadius = UDim.new(0, 4)
						optionCorner.Parent = optionButton

						local optionLabel = Instance.new("TextLabel")
						optionLabel.Size = UDim2.new(1, -10, 1, 0)
						optionLabel.Position = UDim2.new(0, 8, 0, 0)
						optionLabel.BackgroundTransparency = 1
						optionLabel.Text = option
						optionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
						optionLabel.TextSize = 11
						optionLabel.Font = Enum.Font.Montserrat
						optionLabel.TextXAlignment = Enum.TextXAlignment.Left
						optionLabel.Parent = optionButton

						-- Selection indicator for multi-select
						local selectIndicator = nil
						if isMulti then
							selectIndicator = Instance.new("Frame")
							selectIndicator.Name = "SelectIndicator"
							selectIndicator.Size = UDim2.new(0, 4, 0, 0)
							selectIndicator.Position = UDim2.new(0, 0, 0, 0)
							selectIndicator.BackgroundColor3 = ACCENT_COLOR
							selectIndicator.BorderSizePixel = 0
							selectIndicator.ZIndex = optionButton.ZIndex + 1
							selectIndicator.Parent = optionButton
							local indicatorCorner = Instance.new("UICorner")
							indicatorCorner.CornerRadius = UDim.new(0, 4)
							indicatorCorner.Parent = selectIndicator

							for _, val in ipairs(selectedValues) do
								if val == option then
									selectIndicator.Size = UDim2.new(0, 4, 1, 0)
									break
								end
							end
						end

						optionButton.MouseEnter:Connect(function()
							TweenService:Create(optionButton, TweenInfo.new(0.15), {
								BackgroundColor3 = Color3.fromRGB(55, 55, 55)
							}):Play()
						end)

						optionButton.MouseLeave:Connect(function()
							TweenService:Create(optionButton, TweenInfo.new(0.15), {
								BackgroundColor3 = Color3.fromRGB(45, 45, 45)
							}):Play()
						end)

						optionButton.MouseButton1Click:Connect(function()
							if isMulti then
								-- Multi-select logic
								local found = false
								for j, val in ipairs(selectedValues) do
									if val == option then
										table.remove(selectedValues, j)
										found = true
										break
									end
								end

								if not found then
									table.insert(selectedValues, option)
								end

								-- Update selection indicator
								if selectIndicator then
									local targetSize = found and UDim2.new(0, 4, 0, 0) or UDim2.new(0, 4, 1, 0)
									TweenService:Create(selectIndicator, TweenInfo.new(0.18), {
										Size = targetSize
									}):Play()
								end

								updateSelectedLabel()
								callback(selectedValues)
								updateFlag(flag, selectedValues)
							else
								-- Single select logic
								currentValue = option
								selectedLabel.Text = option
								closeDropdown()
								callback(option)
								updateFlag(flag, currentValue)
							end
						end)
					end

					updateSelectedLabel()
				end

				updateSelectedLabel()

				table.insert(groupbox.Elements, dropdownFrame)

				-- Add to searchable elements
				table.insert(window.AllElements, {
					Frame = dropdownFrame,
					SearchText = dropdownText,
					Searchable = true,
					Groupbox = groupbox
				})

				registerFlag(flag, function()
					return isMulti and selectedValues or currentValue
				end, function(value)
					if isMulti then
						selectedValues = type(value) == "table" and value or {}
						updateSelectedLabel()
						updateFlag(flag, selectedValues)
					else
						currentValue = value
						selectedLabel.Text = tostring(value or "")
						updateFlag(flag, currentValue)
					end
				end, isMulti and selectedValues or currentValue)

				return {
					SetValue = function(value)
						if isMulti then
							selectedValues = type(value) == "table" and value or {}
							updateSelectedLabel()
							updateFlag(flag, selectedValues)
						else
							currentValue = value
							selectedLabel.Text = value
							updateFlag(flag, currentValue)
						end
					end,
					SetOptions = function(newOptions, selected)
						if type(newOptions) ~= "table" then
							newOptions = {}
						end
						rebuildOptions(newOptions)
						if selected ~= nil then
							if isMulti then
								selectedValues = type(selected) == "table" and selected or {}
							else
								currentValue = selected
							end
							updateSelectedLabel()
						end
					end
				}
			end

			table.insert(tab.Groupboxes, groupbox)

			return groupbox
		end

		table.insert(window.Tabs, tab)

		return tab
	end

	-- Select Tab function
	function window:SelectTab(tab)
		-- Deselect current tab
		if window.CurrentTab then
			TweenService:Create(window.CurrentTab.Button, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(35, 35, 35),
				TextColor3 = Color3.fromRGB(160, 160, 160)
			}):Play()

			-- Hide current tab groupboxes
			for _, groupbox in pairs(window.CurrentTab.Groupboxes) do
				if groupbox.Frame then
					groupbox.Frame.Visible = false
				end
			end
		end

		-- Select new tab
		window.CurrentTab = tab
		tab.Active = true

		TweenService:Create(tab.Button, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(50, 50, 50),
			TextColor3 = Color3.fromRGB(200, 200, 200)
		}):Play()

		-- Show new tab groupboxes
		for _, groupbox in pairs(tab.Groupboxes) do
			if groupbox.Frame then
				groupbox.Frame.Visible = true
			end
		end

		applySearch()
	end

	-- Destroy function
	function window:Destroy()
		screenGui:Destroy()
	end

	if loader and loader.SetInternalProgress then
		loader:SetInternalProgress(1)
	end
	if loader and loader.SetStatus then
		loader:SetStatus("UI ready")
	end
	if hideUntilReady and loader and loader.BindWindow then
		loader:BindWindow(window, true)
	end

	return window
end

-- ============================================================================
-- EXAMPLE USAGE (replace callbacks with your own logic)
-- ============================================================================

-- Optional loader example
local Loader = Library:CreateLoader({
	Title = "Afterglow",
	InternalPercent = 0.1,
	Status = "Starting..."
})

-- Create Window
local Window = Library:CreateWindow({
	Name = "My UI Library",
	Size = UDim2.new(0, 1100, 0, 650),
	Loader = Loader,
	HideWhileLoading = true
})

-- Create Tab 1
local Tab1 = Window:CreateTab("Main")

-- Create Groupboxes in Tab 1 (3 columns)
local AimbotMain = Tab1:CreateGroupbox({Name = "Aimbot"})
AimbotMain:AddToggle({
	Text = "Enable Aimbot",
	Default = false,
	Keybind = Enum.KeyCode.E,
	KeybindMode = "Hold",
	Callback = function(value)
	end
})
AimbotMain:AddSlider({
	Text = "FOV",
	Min = 30,
	Max = 360,
	Default = 120,
	Increment = 5,
	Callback = function(value)
	end
})
AimbotMain:AddSlider({
	Text = "Smoothness",
	Min = 0,
	Max = 100,
	Default = 20,
	Increment = 1,
	Callback = function(value)
	end
})
AimbotMain:AddSlider({
	Text = "Prediction",
	Min = 0,
	Max = 100,
	Default = 10,
	Increment = 1,
	Callback = function(value)
	end
})

local AimbotChecks = Tab1:CreateGroupbox({Name = "Checks"})
AimbotChecks:AddCheckbox({
	Text = "Team Check",
	Default = true,
	Callback = function(value)
	end
})
AimbotChecks:AddCheckbox({
	Text = "Visibility Check",
	Default = true,
	Callback = function(value)
	end
})
AimbotChecks:AddCheckbox({
	Text = "Alive Check",
	Default = true,
	Callback = function(value)
	end
})
AimbotChecks:AddToggle({
	Text = "Sticky Aim",
	Default = false,
	Callback = function(value)
	end
})

local Visuals = Tab1:CreateGroupbox({Name = "Visuals"})
Visuals:AddToggle({
	Text = "Show FOV Circle",
	Default = true,
	ColorPicker = Color3.fromRGB(120, 200, 255),
	AlphaDefault = 0.75,
	Callback = function(value)
	end
})
Visuals:AddColorPicker({
	Text = "Target Highlight",
	Default = Color3.fromRGB(255, 120, 160),
	Callback = function(color)
	end
})
Visuals:AddDropdown({
	Text = "Target Priority",
	Options = {"Closest", "Lowest Health", "Smallest FOV"},
	Default = "Closest",
	Callback = function(value)
	end
})

local WeaponTuning = Tab1:CreateGroupbox({Name = "Weapon"})
WeaponTuning:AddToggle({
	Text = "Auto Fire",
	Default = false,
	Callback = function(value)
	end
})
WeaponTuning:AddSlider({
	Text = "Fire Rate",
	Min = 1,
	Max = 20,
	Default = 8,
	Increment = 1,
	Callback = function(value)
	end
})
WeaponTuning:AddSlider({
	Text = "Recoil Control",
	Min = 0,
	Max = 100,
	Default = 60,
	Increment = 1,
	Callback = function(value)
	end
})
WeaponTuning:AddSlider({
	Text = "Hit Chance",
	Min = 0,
	Max = 100,
	Default = 85,
	Increment = 1,
	Callback = function(value)
	end
})
WeaponTuning:AddTextbox({
	Text = "Target Player",
	Placeholder = "Optional name...",
	Default = "",
	Callback = function(value)
	end
})
local PreviewSettings = Tab1:CreateGroupbox({Name = "ESP Preview"})
PreviewSettings:AddViewportPreview({
	Height = 240
})
local BodySelectorSettings = Tab1:CreateGroupbox({Name = "Body Part Selector"})
BodySelectorSettings:AddBodyPartSelector({
	Height = 260,
	Default = "Head"
})

-- Create Tab 2 (left blank for now)
local Tab2 = Window:CreateTab("Settings")

local function withFallback(list)
	if #list == 0 then
		return {"None"}
	end
	return list
end

local ThemeListDropdown = nil
local ConfigListDropdown = nil

local function refreshSavedLists()
	local themeNames = withFallback(Window:ListThemeFiles())
	if ThemeListDropdown and ThemeListDropdown.SetOptions then
		ThemeListDropdown.SetOptions(themeNames, themeNames[1])
	end

	local configNames = withFallback(Window:ListConfigFiles())
	if ConfigListDropdown and ConfigListDropdown.SetOptions then
		ConfigListDropdown.SetOptions(configNames, configNames[1])
	end
end

-- Settings: Window toggle key
local WindowSettings = Tab2:CreateGroupbox({Name = "Window"})
WindowSettings:AddKeypicker({
	Text = "Toggle Window",
	Default = Window.ToggleKey,
	Mode = "Toggle",
	Flag = "WindowToggle",
	Callback = function(key, mode)
		Window.ToggleKey = key
		Window.ToggleMode = mode
		if mode == "Always" then
			Window:SetVisible(true)
		end
	end,
	ModeCallback = function(mode)
		Window.ToggleMode = mode
		if mode == "Always" then
			Window:SetVisible(true)
		end
	end
})

-- Settings: Theme colors
local ThemeSettings = Tab2:CreateGroupbox({Name = "Theme"})
local ThemeFileBox = ThemeSettings:AddTextbox({
	Text = "Theme Name",
	Placeholder = "Default",
	Default = "default",
	Flag = "ThemeFileName"
})
ThemeListDropdown = ThemeSettings:AddDropdown({
	Text = "Saved Themes",
	Options = withFallback(Window:ListThemeFiles()),
	Default = "None",
	Flag = "",
	Callback = function(value)
		if value and value ~= "None" then
			Window:LoadThemeFile(value)
		end
	end
})
ThemeSettings:AddColorPicker({
	Text = "Accent",
	Default = Window:GetTheme().Accent,
	Flag = "ThemeAccent",
	Callback = function(color)
		Window:SetThemeColor("Accent", color)
	end
})
ThemeSettings:AddColorPicker({
	Text = "Primary BG",
	Default = Window:GetTheme().PrimaryBg,
	Flag = "ThemePrimaryBg",
	Callback = function(color)
		Window:SetThemeColor("PrimaryBg", color)
	end
})
ThemeSettings:AddColorPicker({
	Text = "Secondary BG",
	Default = Window:GetTheme().SecondaryBg,
	Flag = "ThemeSecondaryBg",
	Callback = function(color)
		Window:SetThemeColor("SecondaryBg", color)
	end
})
ThemeSettings:AddColorPicker({
	Text = "Tertiary BG",
	Default = Window:GetTheme().TertiaryBg,
	Flag = "ThemeTertiaryBg",
	Callback = function(color)
		Window:SetThemeColor("TertiaryBg", color)
	end
})
ThemeSettings:AddColorPicker({
	Text = "Text Primary",
	Default = Window:GetTheme().TextPrimary,
	Flag = "ThemeTextPrimary",
	Callback = function(color)
		Window:SetThemeColor("TextPrimary", color)
	end
})
ThemeSettings:AddColorPicker({
	Text = "Text Secondary",
	Default = Window:GetTheme().TextSecondary,
	Flag = "ThemeTextSecondary",
	Callback = function(color)
		Window:SetThemeColor("TextSecondary", color)
	end
})
ThemeSettings:AddButton({
	Text = "Save Theme",
	Callback = function()
		local name = "default"
		if ThemeFileBox and ThemeFileBox.GetValue then
			name = ThemeFileBox.GetValue()
		end
		Window:SaveThemeFile(name)
		refreshSavedLists()
	end
})
ThemeSettings:AddButton({
	Text = "Load Theme",
	Callback = function()
		local name = "default"
		if ThemeFileBox and ThemeFileBox.GetValue then
			name = ThemeFileBox.GetValue()
		end
		Window:LoadThemeFile(name)
	end
})

-- Settings: Config
local ConfigSettings = Tab2:CreateGroupbox({Name = "Config"})
local ConfigNameBox = ConfigSettings:AddTextbox({
	Text = "Config Name",
	Placeholder = "Default",
	Default = "default",
	Flag = "ConfigFileName"
})
ConfigListDropdown = ConfigSettings:AddDropdown({
	Text = "Saved Configs",
	Options = withFallback(Window:ListConfigFiles()),
	Default = "None",
	Flag = "",
	Callback = function(value)
		if value and value ~= "None" then
			if ConfigNameBox and ConfigNameBox.SetValue then
				ConfigNameBox.SetValue(value)
			end
		end
	end
})
ConfigSettings:AddButton({
	Text = "Save Config",
	Callback = function()
		local name = "default"
		if ConfigNameBox and ConfigNameBox.GetValue then
			name = ConfigNameBox.GetValue()
		end
		Window:SaveConfigFile(name)
		refreshSavedLists()
	end
})
ConfigSettings:AddButton({
	Text = "Load Config",
	Callback = function()
		local name = "default"
		if ConfigNameBox and ConfigNameBox.GetValue then
			name = ConfigNameBox.GetValue()
		end
		Window:LoadConfigFile(name)
	end
})
ConfigSettings:AddButton({
	Text = "Refresh Lists",
	Callback = function()
		refreshSavedLists()
	end
})

refreshSavedLists()

if Loader then
	Loader:SetStatus("Bypassing AC")
	Loader:SetProgress(20)
	task.wait(0.15)
	Loader:SetStatus("Downloading assets")
	Loader:SetProgress(65)
	task.wait(0.15)
	Loader:SetStatus("Syncing settings")
	Loader:SetProgress(100)
	task.wait(0.1)
end

-- Auto-select first tab after everything loads
task.wait(0.1)
if #Window.Tabs > 0 then
	Window:SelectTab(Window.Tabs[1])
end

if Loader then
	Loader:Finish()
end

