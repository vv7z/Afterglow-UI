-- Main Library for Afterglow UI Framework

local Library = {}
Library.__index = Library

local Window = require("core.Window")
local Tab = require("core.Tab")
local Groupbox = require("core.Groupbox")

-- Label = require(script.Parent.Parent.controls.Label)
-- Button = require(script.Parent.Parent.controls.Button)
-- Toggle = require(script.Parent.Parent.controls.Toggle)
-- Checkbox = require(script.Parent.Parent.controls.Checkbox)
-- Slider = require(script.Parent.Parent.controls.Slider)
-- Dropdown = require(script.Parent.Parent.controls.Dropdown)

-- Create a new library instance
function Library.new(config)
	local self = setmetatable({}, Library)
	self.Windows = {}
	return self
end

-- Create a window
function Library:CreateWindow(config)
	local window = Window.new(config)
	table.insert(self.Windows, window)
	return window
end

-- Create a default window if none exists
function Library:GetOrCreateWindow(config)
	if #self.Windows > 0 then
		return self.Windows[1]
	end
	return self:CreateWindow(config)
end

-- Destroy all windows
function Library:DestroyAll()
	for _, window in ipairs(self.Windows) do
		window:Destroy()
	end
	self.Windows = {}
end

-- Destroy specific window
function Library:Destroy(window)
	for i, w in ipairs(self.Windows) do
		if w == window then
			w:Destroy()
			table.remove(self.Windows, i)
			break
		end
	end
end

return Library
