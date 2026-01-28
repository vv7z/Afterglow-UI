-- Toggle control for Afterglow UI Library

local Toggle = {}
Toggle.__index = Toggle

local Constants = require("config.Constants")
local TweenService = game:GetService("TweenService")

-- Create a toggle
function Toggle.new(config)
	config = config or {}
	local self = setmetatable({}, Toggle)
	
	self.Text = config.Text or "Toggle"
	self.Value = config.Default or false
	self.Callback = config.Callback or function() end
	self.EnableKeybind = config.Keybind ~= nil
	self.Keybind = config.Keybind
	self.KeybindMode = config.KeybindMode or "Toggle"
	self.EnableColorPicker = config.ColorPicker ~= nil
	self.Color = config.ColorPicker or Color3.fromRGB(209, 119, 176)
	self.Alpha = config.AlphaDefault or 1
	self.ColorCallback = config.ColorCallback or function() end
	self.Frame = nil
	
	self:_CreateFrame()
	return self
end

-- Create the toggle frame
function Toggle:_CreateFrame()
	local toggleFrame = Instance.new("TextButton")
	toggleFrame.Name = "Toggle"
	toggleFrame.Size = UDim2.new(1, 0, 0, 30)
	toggleFrame.BackgroundColor3 = Constants.COLORS.TERTIARY_BG
	toggleFrame.Text = ""
	
	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, Constants.SIZES.SMALL_CORNER_RADIUS)
	toggleCorner.Parent = toggleFrame
	
	-- Hover effect
	toggleFrame.MouseEnter:Connect(function()
		TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = Constants.COLORS.HOVER_BG}):Play()
	end)
	
	toggleFrame.MouseLeave:Connect(function()
		TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = Constants.COLORS.TERTIARY_BG}):Play()
	end)
	
	-- Label
	local toggleLabel = Instance.new("TextLabel")
	toggleLabel.Size = self.EnableKeybind and UDim2.new(1, -120, 1, 0) or UDim2.new(1, -50, 1, 0)
	toggleLabel.Position = UDim2.new(0, 10, 0, 0)
	toggleLabel.BackgroundTransparency = 1
	toggleLabel.Text = self.Text
	toggleLabel.TextColor3 = Constants.COLORS.PRIMARY_TEXT
	toggleLabel.TextSize = Constants.FONT_SIZES.BUTTON
	toggleLabel.Font = Constants.FONTS.DEFAULT
	toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
	toggleLabel.Parent = toggleFrame
	
	-- Toggle switch
	local toggleButton = Instance.new("Frame")
	toggleButton.Size = UDim2.new(0, 35, 0, 20)
	toggleButton.Position = UDim2.new(1, -40, 0.5, 0)
	toggleButton.AnchorPoint = Vector2.new(0, 0.5)
	toggleButton.BackgroundColor3 = self.Value and Constants.ACCENT_COLOR or Constants.COLORS.TOGGLE_BG
	toggleButton.BorderSizePixel = 0
	toggleButton.Parent = toggleFrame
	
	local toggleBtnCorner = Instance.new("UICorner")
	toggleBtnCorner.CornerRadius = UDim.new(1, 0)
	toggleBtnCorner.Parent = toggleButton
	
	local toggleIndicator = Instance.new("Frame")
	toggleIndicator.Size = UDim2.new(0, 14, 0, 14)
	toggleIndicator.Position = self.Value and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
	toggleIndicator.AnchorPoint = Vector2.new(0, 0.5)
	toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	toggleIndicator.BorderSizePixel = 0
	toggleIndicator.Parent = toggleButton
	
	local indicatorCorner = Instance.new("UICorner")
	indicatorCorner.CornerRadius = UDim.new(1, 0)
	indicatorCorner.Parent = toggleIndicator
	
	-- Toggle click handler
	toggleFrame.MouseButton1Click:Connect(function()
		self.Value = not self.Value
		self:_UpdateVisuals(toggleButton, toggleIndicator)
		self.Callback(self.Value)
	end)
	
	self.Frame = toggleFrame
	self.ToggleButton = toggleButton
	self.ToggleIndicator = toggleIndicator
end

-- Update visuals
function Toggle:_UpdateVisuals(toggleButton, toggleIndicator)
	if self.Value then
		TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Constants.ACCENT_COLOR}):Play()
		TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {Position = UDim2.new(1, -17, 0.5, 0)}):Play()
	else
		TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Constants.COLORS.TOGGLE_BG}):Play()
		TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, 0)}):Play()
	end
end

-- Set value
function Toggle:SetValue(value)
	self.Value = value
	self:_UpdateVisuals(self.ToggleButton, self.ToggleIndicator)
	self.Callback(self.Value)
end

-- Get value
function Toggle:GetValue()
	return self.Value
end

return Toggle
