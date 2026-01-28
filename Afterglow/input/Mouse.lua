-- Mouse utilities for Afterglow UI Library

local Mouse = {}

-- Get current mouse position
function Mouse.GetPosition()
	local UserInputService = game:GetService("UserInputService")
	local GuiService = game:GetService("GuiService")
	local mouseLocation = UserInputService:GetMouseLocation()
	local inset = GuiService:GetGuiInset()
	return mouseLocation - inset
end

-- Get mouse relative to object
function Mouse.GetPositionRelative(guiObject)
	local mousePos = Mouse.GetPosition()
	local objPos = guiObject.AbsolutePosition
	return mousePos - objPos
end

-- Check if mouse is over object
function Mouse.IsOver(guiObject)
	local mousePos = Mouse.GetPosition()
	local objPos = guiObject.AbsolutePosition
	local objSize = guiObject.AbsoluteSize
	
	return mousePos.X >= objPos.X and mousePos.X <= objPos.X + objSize.X and
	       mousePos.Y >= objPos.Y and mousePos.Y <= objPos.Y + objSize.Y
end

return Mouse
