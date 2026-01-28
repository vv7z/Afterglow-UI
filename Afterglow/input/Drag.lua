-- Drag handling for Afterglow UI Library

local Drag = {}
Drag.__index = Drag

local InputService = game:GetService("UserInputService")

-- Create a draggable element
function Drag.new(gui)
	local self = setmetatable({}, Drag)
	self.Gui = gui
	self.Dragging = false
	self.DragStart = nil
	self.StartPos = nil
	self.DragInput = nil
	return self
end

-- Start dragging
function Drag:BeginDrag(input)
	self.Dragging = true
	self.DragStart = input.Position
	self.StartPos = self.Gui.Position
	
	input.Changed:Connect(function()
		if input.UserInputState == Enum.UserInputState.End then
			self.Dragging = false
		end
	end)
end

-- Update position during drag
function Drag:Update(input)
	if not self.Dragging or not self.DragStart or not self.StartPos then return end
	
	local delta = input.Position - self.DragStart
	self.Gui.Position = UDim2.new(
		self.StartPos.X.Scale,
		self.StartPos.X.Offset + delta.X,
		self.StartPos.Y.Scale,
		self.StartPos.Y.Offset + delta.Y
	)
end

-- Connect drag handle
function Drag:ConnectHandle(dragHandle)
	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:BeginDrag(input)
		end
	end)
	
	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			self.DragInput = input
		end
	end)
	
	InputService.InputChanged:Connect(function(input)
		if input == self.DragInput and self.Dragging then
			self:Update(input)
		end
	end)
end

return Drag
