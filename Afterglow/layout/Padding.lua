-- Padding layout utility for Afterglow UI Library

local Padding = {}

-- Create padding on a frame
function Padding.Set(frame, top, bottom, left, right)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, top or 0)
	padding.PaddingBottom = UDim.new(0, bottom or 0)
	padding.PaddingLeft = UDim.new(0, left or 0)
	padding.PaddingRight = UDim.new(0, right or 0)
	padding.Parent = frame
	return padding
end

-- Set same padding on all sides
function Padding.SetUniform(frame, amount)
	return Padding.Set(frame, amount, amount, amount, amount)
end

-- Remove all padding from frame
function Padding.Remove(frame)
	local padding = frame:FindFirstChild("UIPadding") or frame:FindFirstChildOfClass("UIPadding")
	if padding then
		padding:Destroy()
	end
end

return Padding
