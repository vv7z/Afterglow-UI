-- Afterglow UI Library - Example Script
-- ======================================
-- This example demonstrates all features of the Afterglow UI Library

-- Load the library
local Afterglow = loadstring(game:HttpGet("https://raw.githubusercontent.com/vv7z/Afterglow-UI/main/loader.lua"))()

print("[Example] Afterglow UI Library " .. Afterglow.GetVersion() .. " loaded!")

-- Create the main window
local Window = Afterglow.CreateWindow({
	Name = "Afterglow Example UI",
	Size = UDim2.new(0, 1100, 0, 650)
})

-- ============================================================================
-- TAB 1: BASIC CONTROLS
-- ============================================================================

local Tab1 = Window:CreateTab("Main")

-- Groupbox: Basics
local GroupboxBasics = Tab1:CreateGroupbox({Name = "Basic Controls"})

GroupboxBasics:AddLabel("Core UI Elements")
GroupboxBasics:AddButton({
	Text = "Click Me!",
	Callback = function()
		print("[Example] Button clicked!")
	end
})

GroupboxBasics:AddToggle({
	Text = "Enable Feature",
	Default = false,
	Callback = function(value)
		print("[Example] Toggle:", value)
	end
})

GroupboxBasics:AddCheckbox({
	Text = "Show Details",
	Default = false,
	Callback = function(value)
		print("[Example] Checkbox:", value)
	end
})

-- Groupbox: Sliders
local GroupboxSliders = Tab1:CreateGroupbox({Name = "Sliders"})

GroupboxSliders:AddLabel("Adjust Values")
GroupboxSliders:AddSlider({
	Text = "Volume",
	Min = 0,
	Max = 100,
	Default = 50,
	Increment = 5,
	Callback = function(value)
		print("[Example] Volume:", value)
	end
})

GroupboxSliders:AddSlider({
	Text = "Brightness",
	Min = 0,
	Max = 200,
	Default = 100,
	Increment = 10,
	Callback = function(value)
		print("[Example] Brightness:", value)
	end
})

-- Groupbox: Dropdowns
local GroupboxDropdown = Tab1:CreateGroupbox({Name = "Selection"})

GroupboxDropdown:AddLabel("Choose Options")
GroupboxDropdown:AddDropdown({
	Text = "Game Mode",
	Options = {"Casual", "Competitive", "Creative", "Sandbox"},
	Default = "Casual",
	Callback = function(value)
		print("[Example] Game Mode:", value)
	end
})

GroupboxDropdown:AddDropdown({
	Text = "Difficulty",
	Options = {"Easy", "Normal", "Hard", "Impossible"},
	Default = "Normal",
	Callback = function(value)
		print("[Example] Difficulty:", value)
	end
})

-- ============================================================================
-- TAB 2: ADVANCED FEATURES
-- ============================================================================

local Tab2 = Window:CreateTab("Advanced")

-- Groupbox: Advanced Settings
local GroupboxAdvanced = Tab2:CreateGroupbox({Name = "Advanced Settings"})

GroupboxAdvanced:AddLabel("Toggle with Keybind")
GroupboxAdvanced:AddToggle({
	Text = "Speed Boost",
	Default = false,
	Keybind = Enum.KeyCode.Q,
	KeybindMode = "Toggle",
	Callback = function(value)
		print("[Example] Speed Boost:", value)
	end
})

GroupboxAdvanced:AddToggle({
	Text = "Flight Mode",
	Default = false,
	Keybind = Enum.KeyCode.Space,
	KeybindMode = "Hold",
	Callback = function(value)
		print("[Example] Flight Mode:", value)
	end
})

-- Groupbox: Color Settings
local GroupboxColors = Tab2:CreateGroupbox({Name = "Color Settings"})

GroupboxColors:AddLabel("Customize Colors")
GroupboxColors:AddButton({
	Text = "Primary Color",
	Callback = function()
		print("[Example] Primary Color picked")
	end
})

GroupboxColors:AddButton({
	Text = "Secondary Color",
	Callback = function()
		print("[Example] Secondary Color picked")
	end
})

-- Groupbox: Performance
local GroupboxPerformance = Tab2:CreateGroupbox({Name = "Performance"})

GroupboxPerformance:AddLabel("Optimize Performance")
GroupboxPerformance:AddSlider({
	Text = "Draw Distance",
	Min = 100,
	Max = 1000,
	Default = 500,
	Increment = 50,
	Callback = function(value)
		print("[Example] Draw Distance:", value)
	end
})

GroupboxPerformance:AddSlider({
	Text = "FPS Limit",
	Min = 30,
	Max = 240,
	Default = 60,
	Increment = 10,
	Callback = function(value)
		print("[Example] FPS Limit:", value)
	end
})

GroupboxPerformance:AddCheckbox({
	Text = "Enable V-Sync",
	Default = true,
	Callback = function(value)
		print("[Example] V-Sync:", value)
	end
})

-- ============================================================================
-- TAB 3: SETTINGS
-- ============================================================================

local Tab3 = Window:CreateTab("Settings")

-- Groupbox: General Settings
local GroupboxGeneral = Tab3:CreateGroupbox({Name = "General"})

GroupboxGeneral:AddLabel("Application Settings")
GroupboxGeneral:AddToggle({
	Text = "Notifications",
	Default = true,
	Callback = function(value)
		print("[Example] Notifications:", value)
	end
})

GroupboxGeneral:AddDropdown({
	Text = "Language",
	Options = {"English", "Spanish", "French", "German", "Japanese"},
	Default = "English",
	Callback = function(value)
		print("[Example] Language:", value)
	end
})

GroupboxGeneral:AddSlider({
	Text = "UI Scale",
	Min = 0.5,
	Max = 2,
	Default = 1,
	Increment = 0.1,
	Callback = function(value)
		print("[Example] UI Scale:", value)
	end
})

-- Groupbox: Display Settings
local GroupboxDisplay = Tab3:CreateGroupbox({Name = "Display"})

GroupboxDisplay:AddLabel("Visual Preferences")
GroupboxDisplay:AddDropdown({
	Text = "Theme",
	Options = {"Dark", "Light", "Custom"},
	Default = "Dark",
	Callback = function(value)
		print("[Example] Theme:", value)
	end
})

GroupboxDisplay:AddCheckbox({
	Text = "Animations",
	Default = true,
	Callback = function(value)
		print("[Example] Animations:", value)
	end
})

GroupboxDisplay:AddCheckbox({
	Text = "Transparency",
	Default = false,
	Callback = function(value)
		print("[Example] Transparency:", value)
	end
})

-- ============================================================================
-- AUTO-SELECT FIRST TAB
-- ============================================================================

task.wait(0.1)
if #Window.Tabs > 0 then
	Window:SelectTab(Window.Tabs[1])
	print("[Example] Window ready! Use the search bar to filter elements.")
end

print("[Example] UI loaded with " .. #Window.Tabs .. " tabs!")
