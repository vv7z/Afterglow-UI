-- Groupbox for Afterglow UI Library

local Groupbox = {}
Groupbox.__index = Groupbox

local Constants = require("config.Constants")
local Defaults = require("config.Defaults")
local TweenService = game:GetService("TweenService")
local Instances = require("utils.Instances")

-- Create a groupbox
function Groupbox.new(config)
	config = config or {}
	local self = setmetatable({}, Groupbox)
	
	self.Name = config.Name or "Groupbox"
	self.Elements = {}
	self.Frame = nil
	self.ContentContainer = nil
	self.ContentLayout = nil
	
	self:_CreateFrame()
	return self
end

-- Create the groupbox frame
function Groupbox:_CreateFrame()
	-- Main groupbox frame
	local groupboxFrame = Instance.new("Frame")
	groupboxFrame.Name = "Groupbox_" .. self.Name
	groupboxFrame.BackgroundColor3 = Constants.COLORS.TERTIARY_BG
	groupboxFrame.BorderSizePixel = 0
	groupboxFrame.Size = UDim2.new(1, 0, 0, 100)
	
	local groupboxCorner = Instance.new("UICorner")
	groupboxCorner.CornerRadius = UDim.new(0, Constants.SIZES.CORNER_RADIUS)
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
	topbarCorner.CornerRadius = UDim.new(0, Constants.SIZES.CORNER_RADIUS)
	topbarCorner.Parent = topbar
	
	-- Corner cover for rounding
	local topbarCover = Instance.new("Frame")
	topbarCover.Name = "CornerCover"
	topbarCover.Size = UDim2.new(1, 0, 0, 6)
	topbarCover.Position = UDim2.new(0, 0, 1, -6)
	topbarCover.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	topbarCover.BorderSizePixel = 0
	topbarCover.Parent = topbar
	
	-- Title label
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -20, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = self.Name
	titleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	titleLabel.TextSize = Constants.FONT_SIZES.TITLE
	titleLabel.Font = Constants.FONTS.MEDIUM
	titleLabel.TextXAlignment = Enum.TextXAlignment.Center
	titleLabel.Parent = topbar
	
	-- Content container
	local contentContainer = Instance.new("Frame")
	contentContainer.Name = "ContentContainer"
	contentContainer.Size = UDim2.new(1, -20, 1, -50)
	contentContainer.Position = UDim2.new(0, 10, 0, 40)
	contentContainer.BackgroundTransparency = 1
	contentContainer.AutomaticSize = Enum.AutomaticSize.Y
	contentContainer.Parent = groupboxFrame
	
	local contentLayout = Instance.new("UIListLayout")
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Padding = UDim.new(0, Constants.SIZES.SMALL_PADDING)
	contentLayout.Parent = contentContainer
	
	-- Auto-resize based on content
	local function updateSize()
		task.wait(0.05)
		local contentHeight = contentLayout.AbsoluteContentSize.Y
		local totalHeight = 30 + 10 + contentHeight + 10
		groupboxFrame.Size = UDim2.new(1, 0, 0, totalHeight)
	end
	
	contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)
	task.spawn(updateSize)
	
	-- Hover effects
	groupboxFrame.MouseEnter:Connect(function()
		TweenService:Create(groupboxFrame, TweenInfo.new(0.2), {BackgroundColor3 = Constants.COLORS.HOVER_BG}):Play()
		TweenService:Create(topbar, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(37, 37, 37)}):Play()
		TweenService:Create(topbarCover, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(37, 37, 37)}):Play()
	end)
	
	groupboxFrame.MouseLeave:Connect(function()
		TweenService:Create(groupboxFrame, TweenInfo.new(0.2), {BackgroundColor3 = Constants.COLORS.TERTIARY_BG}):Play()
		TweenService:Create(topbar, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
		TweenService:Create(topbarCover, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
	end)
	
	self.Frame = groupboxFrame
	self.ContentContainer = contentContainer
	self.ContentLayout = contentLayout
end

-- Add element to groupbox
function Groupbox:AddElement(element)
	if not element.Frame then return end
	
	element.Frame.Parent = self.ContentContainer
	element.Frame.LayoutOrder = #self.Elements + 1
	
	table.insert(self.Elements, element)
	return element
end

return Groupbox
