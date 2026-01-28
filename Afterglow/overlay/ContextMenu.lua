-- Context menu system for Afterglow UI Library

local ContextMenu = {}
ContextMenu.__index = ContextMenu

local InputService = game:GetService("UserInputService")
local Instances = require(script.Parent.Parent.utils.Instances)

-- Create a context menu
function ContextMenu.new(screenGui)
	local self = setmetatable({}, ContextMenu)
	self.ScreenGui = screenGui
	self.Menu = nil
	self.Visible = false
	self:_CreateMenu()
	return self
end

-- Create menu frame
function ContextMenu:_CreateMenu()
	local menu = Instance.new("Frame")
	menu.Name = "ContextMenu"
	menu.Size = UDim2.new(0, 120, 0, 0)
	menu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	menu.BorderSizePixel = 0
	menu.Visible = false
	menu.ZIndex = 1006
	menu.Parent = self.ScreenGui
	
	local menuCorner = Instance.new("UICorner")
	menuCorner.CornerRadius = UDim.new(0, 4)
	menuCorner.Parent = menu
	
	local menuStroke = Instance.new("UIStroke")
	menuStroke.Color = Color3.fromRGB(55, 55, 55)
	menuStroke.Thickness = 1
	menuStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	menuStroke.Parent = menu
	
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingBottom = UDim.new(0, 6)
	padding.PaddingLeft = UDim.new(0, 6)
	padding.PaddingRight = UDim.new(0, 6)
	padding.Parent = menu
	
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 4)
	layout.Parent = menu
	
	self.Menu = menu
	self.Layout = layout
end

-- Add menu item
function ContextMenu:AddItem(label, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 25)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	btn.Text = label
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.TextSize = 12
	btn.Font = Enum.Font.Gotham
	btn.LayoutOrder = #self.Menu:GetChildren()
	btn.Parent = self.Menu
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 3)
	btnCorner.Parent = btn
	
	btn.MouseButton1Click:Connect(function()
		if callback then
			callback()
		end
		self:Hide()
	end)
	
	return btn
end

-- Show menu at position
function ContextMenu:ShowAt(x, y)
	self.Menu.Position = UDim2.new(0, x, 0, y)
	self.Menu.Visible = true
	self.Visible = true
end

-- Hide menu
function ContextMenu:Hide()
	self.Menu.Visible = false
	self.Visible = false
end

-- Bind right-click to element
function ContextMenu:BindRightClick(element)
	element.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			local mousePos = InputService:GetMouseLocation()
			self:ShowAt(mousePos.X, mousePos.Y)
		end
	end)
end

-- Clear all items
function ContextMenu:Clear()
	for _, child in ipairs(self.Menu:GetChildren()) do
		if child ~= self.Layout and child.ClassName == "TextButton" then
			child:Destroy()
		end
	end
end

return ContextMenu
