-- Hover overlay system for Afterglow UI Library

local HoverOverlay = {}
HoverOverlay.__index = HoverOverlay

local TweenService = game:GetService("TweenService")

-- Create a hover overlay
function HoverOverlay.new(screenGui, accentColor)
	local self = setmetatable({}, HoverOverlay)
	
	self.ScreenGui = screenGui
	self.AccentColor = accentColor or Color3.fromHex("#d177b0")
	self.Frame = nil
	self.Owner = nil
	
	self:_CreateOverlay()
	return self
end

-- Create the overlay frame
function HoverOverlay:_CreateOverlay()
	local hoverOverlay = Instance.new("Frame")
	hoverOverlay.Name = "HoverOverlay"
	hoverOverlay.Size = UDim2.new(0, 0, 0, 0)
	hoverOverlay.Position = UDim2.new(0, 0, 0, 0)
	hoverOverlay.BackgroundTransparency = 1
	hoverOverlay.ZIndex = 1000
	hoverOverlay.Visible = false
	hoverOverlay.Parent = self.ScreenGui
	
	local hoverStroke = Instance.new("UIStroke")
	hoverStroke.Color = self.AccentColor
	hoverStroke.Thickness = 2
	hoverStroke.Transparency = 1
	hoverStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	hoverStroke.Parent = hoverOverlay
	
	local hoverCorner = Instance.new("UICorner")
	hoverCorner.CornerRadius = UDim.new(0, 6)
	hoverCorner.Parent = hoverOverlay
	
	self.Frame = hoverOverlay
	self.Stroke = hoverStroke
end

-- Show overlay for element
function HoverOverlay:Show(element)
	if not element or not element.Parent then return end
	
	self.Owner = element
	self.Frame.Visible = true
	
	local ok, ap = pcall(function() return element.AbsolutePosition end)
	local ok2, asz = pcall(function() return element.AbsoluteSize end)
	
	if ok and ok2 then
		self.Frame.Position = UDim2.new(0, ap.X - 2, 0, ap.Y - 1)
		self.Frame.Size = UDim2.new(0, asz.X + 4, 0, asz.Y + 2)
	end
	
	TweenService:Create(self.Stroke, TweenInfo.new(0.15), {Transparency = 0.6}):Play()
end

-- Hide overlay
function HoverOverlay:Hide()
	TweenService:Create(self.Stroke, TweenInfo.new(0.15), {Transparency = 1}):Play()
	
	self.Frame.Visible = false
	self.Owner = nil
end

-- Update overlay position (call during Heartbeat)
function HoverOverlay:Update()
	if self.Owner and self.Owner.Parent then
		local ok, ap = pcall(function() return self.Owner.AbsolutePosition end)
		local ok2, asz = pcall(function() return self.Owner.AbsoluteSize end)
		
		if ok and ok2 then
			self.Frame.Position = UDim2.new(0, ap.X - 2, 0, ap.Y - 1)
			self.Frame.Size = UDim2.new(0, asz.X + 4, 0, asz.Y + 2)
		end
	end
end

return HoverOverlay
