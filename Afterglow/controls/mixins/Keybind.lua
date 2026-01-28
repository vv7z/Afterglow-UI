-- Keybind mixin for Afterglow UI Library

local Keybind = {}
Keybind.__index = Keybind

local TweenService = game:GetService("TweenService")
local InputService = game:GetService("UserInputService")

-- Create keybind UI
function Keybind.Create(screenGui, config)
	local self = setmetatable({}, Keybind)
	
	self.ScreenGui = screenGui
	self.Key = config.Key or Enum.KeyCode.E
	self.Mode = config.Mode or "Toggle"
	self.OnKeyChanged = config.OnKeyChanged or function() end
	self.OnModeChanged = config.OnModeChanged or function() end
	self.Button = nil
	
	self:_CreateUI()
	return self
end

-- Create the keybind UI
function Keybind:_CreateUI()
	local button = Instance.new("TextButton")
	button.Name = "KeybindButton"
	button.Size = UDim2.new(0, 80, 0, 25)
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	button.Text = self:_FormatKeyName(self.Key)
	button.TextColor3 = Color3.fromRGB(200, 200, 200)
	button.TextSize = 11
	button.Font = Enum.Font.Gotham
	
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 4)
	buttonCorner.Parent = button
	
	-- Click to rebind
	button.MouseButton1Click:Connect(function()
		button.Text = "Press key..."
		button.TextColor3 = Color3.fromRGB(255, 200, 100)
		
		local connection
		connection = InputService.InputBegan:Connect(function(input, gameProcessed)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				self.Key = input.KeyCode
				button.Text = self:_FormatKeyName(self.Key)
				button.TextColor3 = Color3.fromRGB(200, 200, 200)
				self.OnKeyChanged(self.Key)
				connection:Disconnect()
			end
		end)
	end)
	
	self.Button = button
end

-- Format key name for display
function Keybind:_FormatKeyName(key)
	if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
		return key.Name:gsub("([a-z])([A-Z])", "%1 %2")
	end
	return tostring(key)
end

-- Set key
function Keybind:SetKey(key)
	self.Key = key
	self.Button.Text = self:_FormatKeyName(key)
	self.OnKeyChanged(key)
end

-- Get key
function Keybind:GetKey()
	return self.Key
end

-- Set mode
function Keybind:SetMode(mode)
	self.Mode = mode
	self.OnModeChanged(mode)
end

-- Get mode
function Keybind:GetMode()
	return self.Mode
end

return Keybind
