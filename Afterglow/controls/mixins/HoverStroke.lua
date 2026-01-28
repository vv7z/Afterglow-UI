-- Hover stroke mixin for Afterglow UI Library

local HoverStroke = {}

-- Add hover stroke effect to element
function HoverStroke.Create(element, color, thickness)
	color = color or Color3.fromRGB(55, 55, 55)
	thickness = thickness or 1
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = element
	
	local hoverConnection
	hoverConnection = element.MouseEnter:Connect(function()
		stroke.Transparency = 0.6
	end)
	
	element.MouseLeave:Connect(function()
		stroke.Transparency = 1
	end)
	
	return stroke
end

return HoverStroke
