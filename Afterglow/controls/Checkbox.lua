-- Checkbox control for Afterglow UI Library

local Checkbox = {}
Checkbox.__index = Checkbox

local Constants = require(script.Parent.Parent.config.Constants)
local TweenService = game:GetService("TweenService")

-- Create a checkbox
function Checkbox.new(config)
	config = config or {}
	local self = setmetatable({}, Checkbox)
	
	self.Text = config.Text or "Checkbox"
	self.Value = config.Default or false
	self.Callback = config.Callback or function() end
	self.EnableKeybind = config.Keybind ~= nil
	self.Keybind = config.Keybind
	self.KeybindMode = config.KeybindMode or "Toggle"
	self.Frame = nil
	
	self:_CreateFrame()
	return self
end

-- Create the checkbox frame
function Checkbox:_CreateFrame()
	local checkboxFrame = Instance.new("TextButton")
	checkboxFrame.Name = "Checkbox"
	checkboxFrame.Size = UDim2.new(1, 0, 0, 30)
	checkboxFrame.BackgroundColor3 = Constants.COLORS.TERTIARY_BG
	checkboxFrame.Text = ""
	
	local checkboxCorner = Instance.new("UICorner")
	checkboxCorner.CornerRadius = UDim.new(0, Constants.SIZES.SMALL_CORNER_RADIUS)
	checkboxCorner.Parent = checkboxFrame
	
	-- Hover effect
	checkboxFrame.MouseEnter:Connect(function()
		TweenService:Create(checkboxFrame, TweenInfo.new(0.2), {BackgroundColor3 = Constants.COLORS.HOVER_BG}):Play()
	end)
	
	checkboxFrame.MouseLeave:Connect(function()
		TweenService:Create(checkboxFrame, TweenInfo.new(0.2), {BackgroundColor3 = Constants.COLORS.TERTIARY_BG}):Play()
	end)
	
	-- Checkbox label
	local checkboxLabel = Instance.new("TextLabel")
	checkboxLabel.Size = UDim2.new(1, -50, 1, 0)
	checkboxLabel.Position = UDim2.new(0, 10, 0, 0)
	checkboxLabel.BackgroundTransparency = 1
	checkboxLabel.Text = self.Text
	checkboxLabel.TextColor3 = Constants.COLORS.PRIMARY_TEXT
	checkboxLabel.TextSize = Constants.FONT_SIZES.BUTTON
	checkboxLabel.Font = Constants.FONTS.DEFAULT
	checkboxLabel.TextXAlignment = Enum.TextXAlignment.Left
	checkboxLabel.Parent = checkboxFrame
	
	-- Checkbox box
	local checkboxBox = Instance.new("Frame")
	checkboxBox.Size = UDim2.new(0, 18, 0, 18)
	checkboxBox.Position = UDim2.new(1, -25, 0.5, -9)
	checkboxBox.BackgroundColor3 = Constants.COLORS.BUTTON_BG
	checkboxBox.BorderSizePixel = 0
	checkboxBox.Parent = checkboxFrame
	
	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = UDim.new(0, 3)
	boxCorner.Parent = checkboxBox
	
	-- Checkmark
	local checkmark = Instance.new("TextLabel")
	checkmark.Size = UDim2.new(1, 0, 1, 0)
	checkmark.BackgroundTransparency = 1
	checkmark.Text = "✓"
	checkmark.TextColor3 = Constants.ACCENT_COLOR
	checkmark.TextSize = 14
	checkmark.Font = Constants.FONTS.MEDIUM
	checkmark.Visible = self.Value
	checkmark.Parent = checkboxBox
	
	-- Click handler
	checkboxFrame.MouseButton1Click:Connect(function()
		self.Value = not self.Value
		checkmark.Visible = self.Value
		
		if self.Value then
			TweenService:Create(checkboxBox, TweenInfo.new(0.2), {BackgroundColor3 = Constants.ACCENT_COLOR}):Play()
			checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			TweenService:Create(checkboxBox, TweenInfo.new(0.2), {BackgroundColor3 = Constants.COLORS.BUTTON_BG}):Play()
			checkmark.TextColor3 = Constants.ACCENT_COLOR
		end
		
		self.Callback(self.Value)
	end)
	
	self.Frame = checkboxFrame
	self.Checkmark = checkmark
	self.Box = checkboxBox
end

-- Set value
function Checkbox:SetValue(value)
	self.Value = value
	self.Checkmark.Visible = value
	self.Callback(self.Value)
end

-- Get value
function Checkbox:GetValue()
	return self.Value
end

return Checkbox
