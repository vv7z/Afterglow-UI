-- Label control for Afterglow UI Library

local Label = {}
Label.__index = Label

local Constants = require("config.Constants")

-- Create a label
function Label.new(config)
	config = config or {}
	local self = setmetatable({}, Label)
	
	self.Text = config.Text or "Label"
	self.Size = config.Size or UDim2.new(1, 0, 0, 20)
	self.Frame = nil
	
	self:_CreateFrame()
	return self
end

-- Create the label frame
function Label:_CreateFrame()
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = self.Size
	label.BackgroundTransparency = 1
	label.Text = self.Text
	label.TextColor3 = Constants.COLORS.PRIMARY_TEXT
	label.TextSize = Constants.FONT_SIZES.LABEL
	label.Font = Constants.FONTS.DEFAULT
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.TextWrapped = true
	
	self.Frame = label
end

-- Set text
function Label:SetText(text)
	self.Text = text
	self.Frame.Text = text
end

-- Get text
function Label:GetText()
	return self.Text
end

return Label
