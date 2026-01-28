-- Instance creation utilities for Afterglow UI Library

local Instances = {}

-- Create a frame with common properties
function Instances.CreateFrame(properties)
	local frame = Instance.new("Frame")
	
	-- Apply defaults
	frame.BorderSizePixel = 0
	
	-- Apply custom properties
	if properties then
		for key, value in pairs(properties) do
			frame[key] = value
		end
	end
	
	return frame
end

-- Create a text label with common properties
function Instances.CreateLabel(properties)
	local label = Instance.new("TextLabel")
	
	-- Apply defaults
	label.BorderSizePixel = 0
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	
	-- Apply custom properties
	if properties then
		for key, value in pairs(properties) do
			label[key] = value
		end
	end
	
	return label
end

-- Create a text button with common properties
function Instances.CreateButton(properties)
	local button = Instance.new("TextButton")
	
	-- Apply defaults
	button.BorderSizePixel = 0
	button.Font = Enum.Font.Gotham
	button.TextColor3 = Color3.fromRGB(200, 200, 200)
	
	-- Apply custom properties
	if properties then
		for key, value in pairs(properties) do
			button[key] = value
		end
	end
	
	return button
end

-- Create a text box with common properties
function Instances.CreateTextbox(properties)
	local textbox = Instance.new("TextBox")
	
	-- Apply defaults
	textbox.BorderSizePixel = 0
	textbox.Font = Enum.Font.Gotham
	textbox.TextColor3 = Color3.fromRGB(200, 200, 200)
	
	-- Apply custom properties
	if properties then
		for key, value in pairs(properties) do
			textbox[key] = value
		end
	end
	
	return textbox
end

-- Create UICorner
function Instances.CreateCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius or UDim.new(0, 6)
	if parent then
		corner.Parent = parent
	end
	return corner
end

-- Create UIStroke
function Instances.CreateStroke(parent, color, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(55, 55, 55)
	stroke.Thickness = thickness or 1
	stroke.Transparency = transparency or 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	if parent then
		stroke.Parent = parent
	end
	return stroke
end

-- Create UIListLayout
function Instances.CreateListLayout(parent, fillDirection, padding)
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = fillDirection or Enum.FillDirection.Vertical
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = padding or UDim.new(0, 5)
	if parent then
		layout.Parent = parent
	end
	return layout
end

-- Create UIPadding
function Instances.CreatePadding(parent, top, bottom, left, right)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = top or UDim.new(0, 0)
	padding.PaddingBottom = bottom or UDim.new(0, 0)
	padding.PaddingLeft = left or UDim.new(0, 0)
	padding.PaddingRight = right or UDim.new(0, 0)
	if parent then
		padding.Parent = parent
	end
	return padding
end

return Instances
