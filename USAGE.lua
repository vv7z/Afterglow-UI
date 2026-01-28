-- Afterglow UI Library - Usage Guide
-- ===================================

-- LOADING THE LIBRARY
-- ===================

-- Method 1: Simple LoadString (Recommended for most users)
local Afterglow = loadstring(game:HttpGet("https://raw.githubusercontent.com/vv7z/Afterglow-UI/main/loader.lua"))()

-- Method 2: From local files (if you have the Afterglow folder in your project)
local Afterglow = require(game.ServerScriptService.Afterglow)

-- BASIC USAGE
-- ===========

-- Create a library
local Library = Afterglow.new()

-- Create a window (or use the shortcut)
local Window = Afterglow.CreateWindow({
	Name = "My Custom UI",
	Size = UDim2.new(0, 1100, 0, 650)
})

-- Create tabs
local MainTab = Window:CreateTab("Main")
local SettingsTab = Window:CreateTab("Settings")

-- Create groupboxes
local BasicGroupbox = MainTab:CreateGroupbox({Name = "Basic Controls"})
local AdvancedGroupbox = MainTab:CreateGroupbox({Name = "Advanced"})

-- Add elements to groupbox
BasicGroupbox:AddLabel("This is a label")
BasicGroupbox:AddButton({
	Text = "Click Me!",
	Callback = function()
		print("Button clicked!")
	end
})

BasicGroupbox:AddToggle({
	Text = "Enable Feature",
	Default = false,
	Keybind = Enum.KeyCode.E,
	Callback = function(value)
		print("Toggle:", value)
	end
})

BasicGroupbox:AddCheckbox({
	Text = "Show Info",
	Default = false,
	Callback = function(value)
		print("Checkbox:", value)
	end
})

BasicGroupbox:AddSlider({
	Text = "Volume",
	Min = 0,
	Max = 100,
	Default = 50,
	Increment = 5,
	Callback = function(value)
		print("Volume:", value)
	end
})

BasicGroupbox:AddDropdown({
	Text = "Select Option",
	Options = {"Option 1", "Option 2", "Option 3"},
	Default = "Option 1",
	Callback = function(value)
		print("Selected:", value)
	end
})

-- WINDOW METHODS
-- ==============
-- Window:CreateTab(tabName) - Create a new tab
-- Window:SelectTab(tab) - Switch to a tab
-- Window:Destroy() - Destroy the window

-- TAB METHODS
-- ===========
-- Tab:CreateGroupbox(config) - Create a groupbox
-- Tab:GetGroupboxes() - Get all groupboxes
-- Tab:HideGroupboxes() - Hide all groupbox
-- Tab:ShowGroupboxes() - Show all groupboxes

-- GROUPBOX METHODS
-- ================
-- Groupbox:AddElement(element) - Add an element
-- Groupbox:AddLabel(text)
-- Groupbox:AddButton(config)
-- Groupbox:AddToggle(config)
-- Groupbox:AddCheckbox(config)
-- Groupbox:AddSlider(config)
-- Groupbox:AddDropdown(config)

-- SEARCH FUNCTIONALITY
-- ====================
-- The search bar at the top of the window allows filtering elements by name
-- Elements must have SearchText property to be searchable

-- KEYBIND SYSTEM
-- ==============
-- Add Keybind to a Toggle or Checkbox:
-- {
--     Keybind = Enum.KeyCode.F,
--     KeybindMode = "Toggle" | "Hold" | "Always"
-- }

-- THEMES
-- ======
-- Afterglow uses a dark theme by default
-- You can customize colors in config/Constants.lua

-- FILE STRUCTURE
-- ==============
-- Afterglow/
--   ├── init.lua - Main entry point
--   ├── config/ - Configuration and theme
--   ├── core/ - Core UI components (Window, Tab, Groupbox, Library)
--   ├── controls/ - UI control elements (Button, Toggle, etc.)
--   ├── input/ - Input handling (Mouse, Drag, Keybind)
--   ├── layout/ - Layout utilities
--   ├── overlay/ - Overlay components (HoverOverlay, PopupManager)
--   ├── search/ - Search functionality
--   ├── services/ - Service wrappers
--   └── utils/ - Utility functions

-- VERSION INFO
-- ============
print("[Afterglow]", Afterglow.GetVersion())
print("[Afterglow] Author:", Afterglow.GetAuthor())

-- TROUBLESHOOTING
-- ===============
-- 1. If modules fail to load, check your internet connection
-- 2. Ensure the GitHub URL is correct
-- 3. Check the console for specific module loading errors
-- 4. Clear cache with: Afterglow.ClearCache() if needed

return "Afterglow UI Library - Usage Guide"
