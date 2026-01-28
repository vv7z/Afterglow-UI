-- Popup manager for Afterglow UI Library

local PopupManager = {}
PopupManager.__index = PopupManager

local InputService = game:GetService("UserInputService")

-- Create a popup manager
function PopupManager.new(screenGui)
	local self = setmetatable({}, PopupManager)
	self.ScreenGui = screenGui
	self.OpenPopups = {}
	self:_ConnectCloseHandlers()
	return self
end

-- Register a popup
function PopupManager:Register(popup)
	table.insert(self.OpenPopups, popup)
end

-- Unregister a popup
function PopupManager:Unregister(popup)
	for i, p in ipairs(self.OpenPopups) do
		if p == popup then
			table.remove(self.OpenPopups, i)
			break
		end
	end
end

-- Close all popups
function PopupManager:CloseAll()
	for _, popup in ipairs(self.OpenPopups) do
		if popup.Visible then
			popup.Visible = false
		end
	end
	self.OpenPopups = {}
end

-- Close popups except specified ones
function PopupManager:CloseOthers(exceptPopup)
	for _, popup in ipairs(self.OpenPopups) do
		if popup ~= exceptPopup and popup.Visible then
			popup.Visible = false
		end
	end
end

-- Connect escape key to close popups
function PopupManager:_ConnectCloseHandlers()
	InputService.InputBegan:Connect(function(input, gameProcessed)
		if input.KeyCode == Enum.KeyCode.Escape then
			self:CloseAll()
		end
	end)
	
	-- Also close on click outside
	InputService.InputBegan:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			-- Check if click was outside any popup
			local clickedPopup = false
			for _, popup in ipairs(self.OpenPopups) do
				if popup.Visible then
					local mousePos = InputService:GetMouseLocation()
					local objPos = popup.AbsolutePosition
					local objSize = popup.AbsoluteSize
					
					if mousePos.X >= objPos.X and mousePos.X <= objPos.X + objSize.X and
					   mousePos.Y >= objPos.Y and mousePos.Y <= objPos.Y + objSize.Y then
						clickedPopup = true
						break
					end
				end
			end
			
			if not clickedPopup then
				self:CloseAll()
			end
		end
	end)
end

-- Show popup anchored to element
function PopupManager:ShowPopupAt(popup, anchorElement, offsetX, offsetY)
	offsetX = offsetX or 0
	offsetY = offsetY or 0
	
	self:CloseOthers(popup)
	popup.Visible = true
	self:Register(popup)
	
	local anchorPos = anchorElement.AbsolutePosition
	local anchorSize = anchorElement.AbsoluteSize
	
	popup.Position = UDim2.new(0, anchorPos.X + offsetX, 0, anchorPos.Y + anchorSize.Y + offsetY)
end

return PopupManager
