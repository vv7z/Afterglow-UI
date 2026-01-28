-- Dropdown control for Afterglow UI Library

local Dropdown = {}
Dropdown.__index = Dropdown

local Constants = require("config.Constants")
local TweenService = game:GetService("TweenService")

-- Create a dropdown
function Dropdown.new(config)
	config = config or {}
	local self = setmetatable({}, Dropdown)
	
	self.Text = config.Text or "Dropdown"
	self.Options = config.Options or {}
	self.Value = config.Default or (self.Options[1] or "")
	self.MultiSelect = config.Multi or false
	self.SelectedValue = self.MultiSelect and {} or self.Value
	self.Callback = config.Callback or function() end
	self.Frame = nil
	self.MenuOpen = false
	
	self:_CreateFrame()
	return self
end

-- Create the dropdown frame
function Dropdown:_CreateFrame()
	local dropdownFrame = Instance.new("TextButton")
	dropdownFrame.Name = "Dropdown"
	dropdownFrame.Size = UDim2.new(1, 0, 0, 30)
	dropdownFrame.BackgroundColor3 = Constants.COLORS.TERTIARY_BG
	dropdownFrame.Text = ""
	
	local dropdownCorner = Instance.new("UICorner")
	dropdownCorner.CornerRadius = UDim.new(0, Constants.SIZES.SMALL_CORNER_RADIUS)
	dropdownCorner.Parent = dropdownFrame
	
	-- Label
	local dropdownLabel = Instance.new("TextLabel")
	dropdownLabel.Size = UDim2.new(1, -30, 1, 0)
	dropdownLabel.Position = UDim2.new(0, 10, 0, 0)
	dropdownLabel.BackgroundTransparency = 1
	dropdownLabel.Text = self.Text
	dropdownLabel.TextColor3 = Constants.COLORS.PRIMARY_TEXT
	dropdownLabel.TextSize = Constants.FONT_SIZES.BUTTON
	dropdownLabel.Font = Constants.FONTS.DEFAULT
	dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
	dropdownLabel.Parent = dropdownFrame
	
	-- Value label
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 200, 1, 0)
	valueLabel.Position = UDim2.new(0, 10, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = ""
	valueLabel.TextColor3 = Constants.COLORS.SECONDARY_TEXT
	valueLabel.TextSize = Constants.FONT_SIZES.BUTTON
	valueLabel.Font = Constants.FONTS.DEFAULT
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = dropdownFrame
	
	-- Arrow
	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.new(0, 20, 1, 0)
	arrow.Position = UDim2.new(1, -25, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text = "▼"
	arrow.TextColor3 = Constants.COLORS.SECONDARY_TEXT
	arrow.TextSize = 12
	arrow.Parent = dropdownFrame
	
	-- Menu
	local menu = Instance.new("ScrollingFrame")
	menu.Name = "Menu"
	menu.Size = UDim2.new(1, 0, 0, 100)
	menu.Position = UDim2.new(0, 0, 0, 35)
	menu.BackgroundColor3 = Constants.COLORS.TERTIARY_BG
	menu.BorderSizePixel = 0
	menu.Visible = false
	menu.ScrollBarThickness = 4
	menu.ScrollBarImageColor3 = Constants.COLORS.SCROLLBAR_COLOR
	menu.Parent = dropdownFrame
	
	local menuCorner = Instance.new("UICorner")
	menuCorner.CornerRadius = UDim.new(0, Constants.SIZES.SMALL_CORNER_RADIUS)
	menuCorner.Parent = menu
	
	local menuLayout = Instance.new("UIListLayout")
	menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
	menuLayout.Padding = UDim.new(0, 2)
	menuLayout.Parent = menu
	
	-- Populate menu
	for i, option in ipairs(self.Options) do
		local optionBtn = Instance.new("TextButton")
		optionBtn.Size = UDim2.new(1, 0, 0, 25)
		optionBtn.BackgroundColor3 = Constants.COLORS.BUTTON_BG
		optionBtn.Text = option
		optionBtn.TextColor3 = Constants.COLORS.PRIMARY_TEXT
		optionBtn.TextSize = Constants.FONT_SIZES.BUTTON
		optionBtn.Font = Constants.FONTS.DEFAULT
		optionBtn.LayoutOrder = i
		optionBtn.Parent = menu
		
		optionBtn.MouseButton1Click:Connect(function()
			if self.MultiSelect then
				-- Toggle selection
				table.insert(self.SelectedValue, option)
				valueLabel.Text = table.concat(self.SelectedValue, ", ")
			else
				self.SelectedValue = option
				valueLabel.Text = option
			end
			
			self.Callback(self.SelectedValue)
		end)
	end
	
	menu.CanvasSize = UDim2.new(0, 0, 0, menuLayout.AbsoluteContentSize.Y)
	
	-- Toggle menu
	dropdownFrame.MouseButton1Click:Connect(function()
		self.MenuOpen = not self.MenuOpen
		menu.Visible = self.MenuOpen
		
		TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = self.MenuOpen and 180 or 0}):Play()
	end)
	
	self.Frame = dropdownFrame
	self.Menu = menu
	self.ValueLabel = valueLabel
	self.Arrow = arrow
end

-- Set value
function Dropdown:SetValue(value)
	if self.MultiSelect then
		self.SelectedValue = value
		self.ValueLabel.Text = table.concat(value, ", ")
	else
		self.SelectedValue = value
		self.ValueLabel.Text = value
	end
	self.Callback(self.SelectedValue)
end

-- Get value
function Dropdown:GetValue()
	return self.SelectedValue
end

return Dropdown
