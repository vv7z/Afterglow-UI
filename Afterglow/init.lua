-- Afterglow UI Library - Main Entry Point
-- Modular dark theme UI library with tabs, groupboxes, and search.

local Afterglow = {}
Afterglow.__index = Afterglow

-- Import core modules
local Library = require("core.Library")
end

-- Quick start: Create a window
function Afterglow.CreateWindow(config)
	local lib = Library.new()
	return lib:CreateWindow(config)
end

-- Get version
function Afterglow.GetVersion()
	return "1.0.0"
end

-- Get author
function Afterglow.GetAuthor()
	return "vvs"
end

return Afterglow
