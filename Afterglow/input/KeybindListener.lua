-- Keybind listener for Afterglow UI Library

local KeybindListener = {}
KeybindListener.__index = KeybindListener

local InputService = game:GetService("UserInputService")

-- Create a keybind listener
function KeybindListener.new(key, mode)
	local self = setmetatable({}, KeybindListener)
	self.Key = key  -- Enum.KeyCode or Enum.UserInputType
	self.Mode = mode or "Toggle"  -- "Toggle", "Hold", "Always"
	self.Enabled = true
	self.Pressed = false
	self.Connection = nil
	self.Callbacks = {}
	return self
end

-- Check if input matches the keybind
function KeybindListener:IsKeyMatch(input)
	if typeof(self.Key) ~= "EnumItem" then
		return false
	end
	
	if self.Key.EnumType == Enum.KeyCode then
		return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == self.Key
	end
	
	if self.Key.EnumType == Enum.UserInputType then
		return input.UserInputType == self.Key
	end
	
	return false
end

-- Connect the keybind listener
function KeybindListener:Connect()
	InputService.InputBegan:Connect(function(input, gameProcessed)
		if not self.Enabled or gameProcessed then return end
		
		if self:IsKeyMatch(input) then
			if self.Mode == "Toggle" then
				self.Pressed = not self.Pressed
				self:_FireCallbacks(self.Pressed)
			elseif self.Mode == "Hold" then
				self.Pressed = true
				self:_FireCallbacks(true)
			elseif self.Mode == "Always" then
				self:_FireCallbacks(true)
			end
		end
	end)
	
	InputService.InputEnded:Connect(function(input, gameProcessed)
		if not self.Enabled then return end
		
		if self:IsKeyMatch(input) then
			if self.Mode == "Hold" then
				self.Pressed = false
				self:_FireCallbacks(false)
			end
		end
	end)
end

-- Add a callback
function KeybindListener:OnPress(callback)
	table.insert(self.Callbacks, callback)
end

-- Fire all callbacks
function KeybindListener:_FireCallbacks(state)
	for _, callback in ipairs(self.Callbacks) do
		task.spawn(callback, state)
	end
end

-- Disconnect
function KeybindListener:Disconnect()
	self.Enabled = false
	if self.Connection then
		self.Connection:Disconnect()
	end
end

return KeybindListener
