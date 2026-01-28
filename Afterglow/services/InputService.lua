-- Wrapper for Roblox UserInputService

local InputService = {}

local _UserInputService = game:GetService("UserInputService")

-- Get mouse location
function InputService.GetMouseLocation()
	return _UserInputService:GetMouseLocation()
end

-- Connect to input began
function InputService.InputBegan(callback)
	return _UserInputService.InputBegan:Connect(callback)
end

-- Connect to input changed
function InputService.InputChanged(callback)
	return _UserInputService.InputChanged:Connect(callback)
end

-- Connect to input ended
function InputService.InputEnded(callback)
	return _UserInputService.InputEnded:Connect(callback)
end

-- Check if input is keyboard
function InputService.IsKeyDown(keyCode)
	return _UserInputService:IsKeyDown(keyCode)
end

return InputService
