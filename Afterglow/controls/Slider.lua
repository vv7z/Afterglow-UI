-- Slider control for Afterglow UI Library

local Slider = {}
Slider.__index = Slider

local Constants = require("config.Constants")
local InputService = game:GetService("UserInputService")

-- Create a slider
function Slider.new(config)
	config = config or {}
	local self = setmetatable({}, Slider)
	
	self.Text = config.Text or "Slider"
	self.Min = config.Min or 0
	self.Max = config.Max or 100
	self.Value = config.Default or 50
	self.Increment = config.Increment or 1
	self.Callback = config.Callback or function() end
	self.Frame = nil
	self.Dragging = false
	
	self:_CreateFrame()
	return self
end

-- Create the slider frame
function Slider:_CreateFrame()
	local sliderFrame = Instance.new("Frame")
	sliderFrame.Name = "Slider"
	sliderFrame.Size = UDim2.new(1, 0, 0, 50)
	sliderFrame.BackgroundTransparency = 1
	
	-- Label
	local sliderLabel = Instance.new("TextLabel")
	sliderLabel.Size = UDim2.new(0.5, 0, 0, 20)
	sliderLabel.Position = UDim2.new(0, 0, 0, 0)
	sliderLabel.BackgroundTransparency = 1
	sliderLabel.Text = self.Text
	sliderLabel.TextColor3 = Constants.COLORS.PRIMARY_TEXT
	sliderLabel.TextSize = Constants.FONT_SIZES.BUTTON
	sliderLabel.Font = Constants.FONTS.DEFAULT
	sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
	sliderLabel.Parent = sliderFrame
	
	-- Value label
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0.5, 0, 0, 20)
	valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(self.Value)
	valueLabel.TextColor3 = Constants.COLORS.SECONDARY_TEXT
	valueLabel.TextSize = Constants.FONT_SIZES.BUTTON
	valueLabel.Font = Constants.FONTS.DEFAULT
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = sliderFrame
	
	-- Track background
	local trackBackground = Instance.new("Frame")
	trackBackground.Size = UDim2.new(1, 0, 0, 4)
	trackBackground.Position = UDim2.new(0, 0, 0, 25)
	trackBackground.BackgroundColor3 = Constants.COLORS.BUTTON_BG
	trackBackground.BorderSizePixel = 0
	trackBackground.Parent = sliderFrame
	
	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = trackBackground
	
	-- Track fill
	local trackFill = Instance.new("Frame")
	trackFill.Size = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), 0, 1, 0)
	trackFill.BackgroundColor3 = Constants.ACCENT_COLOR
	trackFill.BorderSizePixel = 0
	trackFill.Parent = trackBackground
	
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = trackFill
	
	-- Thumb
	local thumb = Instance.new("Frame")
	thumb.Size = UDim2.new(0, 12, 0, 20)
	thumb.Position = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), -6, 0, 15)
	thumb.BackgroundColor3 = Constants.ACCENT_COLOR
	thumb.BorderSizePixel = 0
	thumb.Parent = sliderFrame
	
	local thumbCorner = Instance.new("UICorner")
	thumbCorner.CornerRadius = UDim.new(0, 3)
	thumbCorner.Parent = thumb
	
	-- Input handling
	trackBackground.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.Dragging = true
			self:_UpdateFromInput()
		end
	end)
	
	InputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.Dragging = false
		end
	end)
	
	InputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and self.Dragging then
			self:_UpdateFromInput(trackBackground, trackFill, thumb, valueLabel)
		end
	end)
	
	self.Frame = sliderFrame
	self.TrackBackground = trackBackground
	self.TrackFill = trackFill
	self.Thumb = thumb
	self.ValueLabel = valueLabel
end

-- Update value from mouse input
function Slider:_UpdateFromInput(trackBg, trackFill, thumb, valueLabel)
	if not self.Dragging then return end
	
	trackBg = trackBg or self.TrackBackground
	trackFill = trackFill or self.TrackFill
	thumb = thumb or self.Thumb
	valueLabel = valueLabel or self.ValueLabel
	
	local mousePos = InputService:GetMouseLocation()
	local inset = game:GetService("GuiService"):GetGuiInset()
	mousePos = mousePos - inset
	
	local trackPos = trackBg.AbsolutePosition.X
	local trackSize = trackBg.AbsoluteSize.X
	local relativeX = math.clamp(mousePos.X - trackPos, 0, trackSize)
	local normalized = relativeX / trackSize
	
	self.Value = math.round((self.Min + normalized * (self.Max - self.Min)) / self.Increment) * self.Increment
	self.Value = math.clamp(self.Value, self.Min, self.Max)
	
	trackFill.Size = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), 0, 1, 0)
	thumb.Position = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), -6, 0, 15)
	valueLabel.Text = tostring(self.Value)
	
	self.Callback(self.Value)
end

-- Set value
function Slider:SetValue(value)
	self.Value = math.clamp(value, self.Min, self.Max)
	self.TrackFill.Size = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), 0, 1, 0)
	self.Thumb.Position = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), -6, 0, 15)
	self.ValueLabel.Text = tostring(self.Value)
	self.Callback(self.Value)
end

-- Get value
function Slider:GetValue()
	return self.Value
end

return Slider
