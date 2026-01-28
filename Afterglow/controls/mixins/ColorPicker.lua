-- Color picker mixin for Afterglow UI Library

local ColorPicker = {}
ColorPicker.__index = ColorPicker

local TweenService = game:GetService("TweenService")
local InputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

-- Create a color picker popup
function ColorPicker.Create(screenGui, anchorButton, initialColor, initialAlpha, onChanged)
	local self = setMetatable({}, ColorPicker)
	
	self.ScreenGui = screenGui
	self.AnchorButton = anchorButton
	self.Color = initialColor or Color3.new(1, 0, 1)
	self.Alpha = initialAlpha or 1
	self.OnChanged = onChanged or function() end
	
	self:_CreatePicker()
	return self
end

-- Create the picker UI
function ColorPicker:_CreatePicker()
	local picker = Instance.new("Frame")
	picker.Name = "ColorPicker"
	picker.Size = UDim2.new(0, 230, 0, 255)
	picker.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	picker.BorderSizePixel = 0
	picker.Visible = false
	picker.ZIndex = 1006
	picker.Parent = self.ScreenGui
	
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
	
	self.Picker = picker
end

-- Show picker
function ColorPicker:Show()
	self.Picker.Visible = true
	self:_PositionPicker()
end

-- Hide picker
function ColorPicker:Hide()
	self.Picker.Visible = false
end

-- Position picker relative to anchor button
function ColorPicker:_PositionPicker()
	local anchorPos = self.AnchorButton.AbsolutePosition
	local anchorSize = self.AnchorButton.AbsoluteSize
	local inset = GuiService:GetGuiInset()
	
	local x = anchorPos.X
	local y = anchorPos.Y + anchorSize.Y + 5
	
	self.Picker.Position = UDim2.new(0, x, 0, y)
end

-- Set color
function ColorPicker:SetColor(color)
	self.Color = color
	self.OnChanged(color, self.Alpha)
end

-- Set alpha
function ColorPicker:SetAlpha(alpha)
	self.Alpha = math.clamp(alpha, 0, 1)
	self.OnChanged(self.Color, self.Alpha)
end

-- Get color
function ColorPicker:GetColor()
	return self.Color
end

-- Get alpha
function ColorPicker:GetAlpha()
	return self.Alpha
end

return ColorPicker
