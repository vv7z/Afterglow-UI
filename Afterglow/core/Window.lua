-- Window for Afterglow UI Library

local Window = {}
Window.__index = Window

local Constants = require("config.Constants")
local Defaults = require("config.Defaults")
local Tab = require("core.Tab")
local Groupbox = require("core.Groupbox")
local Drag = require("input.Drag")
local SearchFilter = require("search.SearchFilter")
local ColumnLayout = require("layout.ColumnLayout")
local HoverOverlay = require("overlay.HoverOverlay")
local PopupManager = require("overlay.PopupManager")
local RunService = require("services.RunService")
local TweenService = game:GetService("TweenService")

-- Create a window
function Window.new(config)
	config = config or {}
	local self = setmetatable({}, Window)
	
	self.Name = config.Name or Defaults.Window.Name
	self.Size = config.Size or Defaults.Window.Size
	self.Tabs = {}
	self.CurrentTab = nil
	self.AllElements = {}
	self.ScreenGui = nil
	self.MainFrame = nil
	self.SearchBox = nil
	self.Columns = {}
	self.HoverOverlay = nil
	self.PopupManager = nil
	self.Drag = nil
	
	self:_CreateWindow()
	return self
end

-- Create the window GUI
function Window:_CreateWindow()
	-- ScreenGui host
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "UILibrary_" .. self.Name
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	if RunService.IsStudio() then
		screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	else
		screenGui.Parent = game:GetService("CoreGui")
	end
	
	self.ScreenGui = screenGui
	
	-- Main frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = self.Size
	mainFrame.Position = Defaults.Window.Position
	mainFrame.AnchorPoint = Defaults.Window.AnchorPoint
	mainFrame.BackgroundColor3 = Constants.COLORS.PRIMARY_BG
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui
	
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, Constants.SIZES.CORNER_RADIUS)
	mainCorner.Parent = mainFrame
	
	self.MainFrame = mainFrame
	
	-- Drag bar
	local dragBar = Instance.new("Frame")
	dragBar.Name = "DragBar"
	dragBar.Size = UDim2.new(1, 0, 0, Constants.SIZES.DRAG_BAR_HEIGHT)
	dragBar.Position = UDim2.new(0, 0, 0, 0)
	dragBar.BackgroundTransparency = 1
	dragBar.Parent = mainFrame
	
	-- Setup dragging
	local dragSystem = Drag.new(mainFrame)
	dragSystem:ConnectHandle(dragBar)
	self.Drag = dragSystem
	
	-- Search bar
	local searchContainer = Instance.new("Frame")
	searchContainer.Name = "SearchContainer"
	searchContainer.Size = UDim2.new(1, -40, 0, Constants.SIZES.SEARCH_BAR_HEIGHT)
	searchContainer.Position = UDim2.new(0, 20, 0, 15)
	searchContainer.BackgroundColor3 = Constants.COLORS.SECONDARY_BG
	searchContainer.BorderSizePixel = 0
	searchContainer.Parent = mainFrame
	
	local searchCorner = Instance.new("UICorner")
	searchCorner.CornerRadius = UDim.new(0, Constants.SIZES.SMALL_CORNER_RADIUS)
	searchCorner.Parent = searchContainer
	
	-- Search TextBox
	local searchBox = Instance.new("TextBox")
	searchBox.Name = "SearchBox"
	searchBox.Size = UDim2.new(1, -20, 1, 0)
	searchBox.Position = UDim2.new(0, 15, 0, 0)
	searchBox.BackgroundTransparency = 1
	searchBox.PlaceholderText = Defaults.Search.Placeholder
	searchBox.PlaceholderColor3 = Constants.COLORS.PLACEHOLDER_TEXT
	searchBox.Text = ""
	searchBox.TextColor3 = Constants.COLORS.PRIMARY_TEXT
	searchBox.TextSize = Constants.FONT_SIZES.BUTTON
	searchBox.Font = Constants.FONTS.DEFAULT
	searchBox.TextXAlignment = Enum.TextXAlignment.Center
	searchBox.ClearTextOnFocus = true
	searchBox.Parent = searchContainer
	
	self.SearchBox = searchBox
	
	-- Sidebar (tabs)
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, Constants.SIZES.SIDEBAR_WIDTH, 1, -95)
	sidebar.Position = UDim2.new(0, 20, 0, 65)
	sidebar.BackgroundColor3 = Constants.COLORS.SECONDARY_BG
	sidebar.BorderSizePixel = 0
	sidebar.Parent = mainFrame
	
	local sidebarCorner = Instance.new("UICorner")
	sidebarCorner.CornerRadius = UDim.new(0, Constants.SIZES.SMALL_CORNER_RADIUS)
	sidebarCorner.Parent = sidebar
	
	-- Tab container
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
	contentArea.ScrollBarThickness = Constants.SIZES.SCROLLBAR_THICKNESS
	contentArea.ScrollBarImageColor3 = Constants.COLORS.SCROLLBAR_COLOR
	contentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentArea.Parent = mainFrame
	
	-- Grid container for columns
	local gridContainer = Instance.new("Frame")
	gridContainer.Name = "GridContainer"
	gridContainer.Size = UDim2.new(1, 0, 1, 0)
	gridContainer.BackgroundTransparency = 1
	gridContainer.AutomaticSize = Enum.AutomaticSize.Y
	gridContainer.Parent = contentArea
	
	-- Create columns
	local columns = ColumnLayout.CreateColumns(gridContainer, Constants.SIZES.COLUMN_COUNT, Constants.SIZES.DEFAULT_PADDING)
	self.Columns = columns
	
	-- Hover overlay
	local hoverOverlay = HoverOverlay.new(screenGui, Constants.ACCENT_COLOR)
	RunService.Heartbeat(function()
		hoverOverlay:Update()
	end)
	self.HoverOverlay = hoverOverlay
	
	-- Popup manager
	self.PopupManager = PopupManager.new(screenGui)
	
	-- Search handler
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		self:_ApplySearch()
	end)
	
	self.TabContainer = tabContainer
	self.ContentArea = contentArea
end

-- Create a tab
function Window:CreateTab(tabName)
	local tab = Tab.new({Name = tabName})
	
	-- Create tab button
	local tabBtn = Instance.new("TextButton")
	tabBtn.Name = tabName
	tabBtn.Size = UDim2.new(1, 0, 0, Constants.SIZES.TAB_BUTTON_HEIGHT)
	tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	tabBtn.Text = tabName
	tabBtn.TextColor3 = Constants.COLORS.SECONDARY_TEXT
	tabBtn.TextSize = Constants.FONT_SIZES.BUTTON
	tabBtn.Font = Constants.FONTS.DEFAULT
	tabBtn.LayoutOrder = #self.Tabs + 1
	tabBtn.Parent = self.TabContainer
	
	local tabCorner = Instance.new("UICorner")
	tabCorner.CornerRadius = UDim.new(0, Constants.SIZES.SMALL_CORNER_RADIUS)
	tabCorner.Parent = tabBtn
	
	tab:SetButton(tabBtn)
	
	-- Tab click handler
	tabBtn.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end)
	
	table.insert(self.Tabs, tab)
	
	-- Create groupbox method on tab
	function tab:CreateGroupbox(config)
		return self:_CreateGroupboxInternal(config)
	end
	
	-- Store reference to parent window for groupbox creation
	tab._window = self
	
	function tab:_CreateGroupboxInternal(config)
		config = config or {}
		local groupbox = Groupbox.new({Name = config.Name or "Groupbox"})
		
		-- Determine column
		local colIndex = ((#self.Groupboxes) % Constants.SIZES.COLUMN_COUNT) + 1
		groupbox.Frame.Parent = self._window.Columns[colIndex]
		groupbox.Frame.LayoutOrder = #self.Groupboxes + 1
		groupbox.Frame.Visible = false
		
		self:AddGroupbox(groupbox)
		return groupbox
	end
	
	function tab:AddGroupbox(groupbox)
		table.insert(self.Groupboxes, groupbox)
	end
	
	return tab
end

-- Select a tab
function Window:SelectTab(tab)
	-- Deselect current tab
	if self.CurrentTab then
		TweenService:Create(self.CurrentTab.Button, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(35, 35, 35),
			TextColor3 = Constants.COLORS.SECONDARY_TEXT
		}):Play()
		
		self.CurrentTab:HideGroupboxes()
	end
	
	-- Select new tab
	self.CurrentTab = tab
	tab.Active = true
	
	TweenService:Create(tab.Button, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		TextColor3 = Constants.COLORS.PRIMARY_TEXT
	}):Play()
	
	tab:ShowGroupboxes()
	self:_ApplySearch()
end

-- Apply search filter
function Window:_ApplySearch()
	local searchText = self.SearchBox.Text:lower()
	SearchFilter.ApplySearch(searchText, self.AllElements, self.CurrentTab and self.CurrentTab.Groupboxes or {})
end

-- Destroy window
function Window:Destroy()
	self.ScreenGui:Destroy()
end

return Window
