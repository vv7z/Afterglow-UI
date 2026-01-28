-- Button control for Afterglow UI Library

local Button = {}
Button.__index = Button

local Constants = require(script.Parent.Parent.config.Constants)
local TweenService = game:GetService("TweenService")

-- Create a button
function Button.new(config)
	config = config or {}
	local self = setmetatable({}, Button)
	
	self.Text = config.Text or "Button"
	self.Size = config.Size or UDim2.new(1, 0, 0, 30)
	self.Callback = config.Callback or function() end
	self.Frame = nil
	
	self:_CreateFrame()
	return self
end

-- Create the button frame
function Button:_CreateFrame()
	local button = Instance.new("TextButton")
	button.Name = "Button"
	button.Size = self.Size
	button.BackgroundColor3 = Constants.COLORS.BUTTON_BG
	button.Text = self.Text
	button.TextColor3 = Constants.COLORS.PRIMARY_TEXT
	button.TextSize = Constants.FONT_SIZES.BUTTON
	button.Font = Constants.FONTS.DEFAULT
	
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, Constants.SIZES.SMALL_CORNER_RADIUS)
	buttonCorner.Parent = button
	
	-- Hover effect
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Constants.COLORS.HOVER_BG}):Play()
	end)
	
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Constants.COLORS.BUTTON_BG}):Play()
	end)
	
	-- Click handler
	button.MouseButton1Click:Connect(function()
		self.Callback()
	end)
	
	self.Frame = button
end

-- Set callback
function Button:SetCallback(callback)
	self.Callback = callback
end

-- Set text
function Button:SetText(text)
	self.Text = text
	self.Frame.Text = text
end

return Button
