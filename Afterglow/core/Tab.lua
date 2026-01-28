-- Tab for Afterglow UI Library

local Tab = {}
Tab.__index = Tab

local Constants = require("config.Constants")
local Groupbox = require("core.Groupbox")
local TweenService = game:GetService("TweenService")

-- Create a tab
function Tab.new(config)
	config = config or {}
	local self = setmetatable({}, Tab)
	
	self.Name = config.Name or "Tab"
	self.Button = nil
	self.Groupboxes = {}
	self.Active = false
	
	return self
end

-- Set button
function Tab:SetButton(button)
	self.Button = button
end

-- Add groupbox to tab
function Tab:AddGroupbox(groupbox)
	table.insert(self.Groupboxes, groupbox)
	return groupbox
end

-- Get groupboxes
function Tab:GetGroupboxes()
	return self.Groupboxes
end

-- Hide all groupboxes
function Tab:HideGroupboxes()
	for _, groupbox in ipairs(self.Groupboxes) do
		if groupbox.Frame then
			groupbox.Frame.Visible = false
		end
	end
	self.Active = false
end

-- Show all groupboxes
function Tab:ShowGroupboxes()
	for _, groupbox in ipairs(self.Groupboxes) do
		if groupbox.Frame then
			groupbox.Frame.Visible = true
		end
	end
	self.Active = true
end

return Tab
