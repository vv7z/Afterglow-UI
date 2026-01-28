# Afterglow UI Library

A modular, dark-themed UI library for Roblox with tabs, groupboxes, and advanced search functionality.

## Features

- 🎨 **Dark Theme** - Beautiful, modern dark UI design
- 🔍 **Search System** - Filter controls by name in real-time
- 📑 **Tabs & Groupboxes** - Organize controls in logical sections
- 🎯 **Multiple Controls** - Buttons, Toggles, Sliders, Dropdowns, and more
- ⌨️ **Keybind Support** - Bind actions to keyboard keys
- 🎪 **Smooth Animations** - Polished hover effects and transitions
- 📦 **Modular Architecture** - All code split into logical, reusable modules
- 🔗 **Remote Loading** - Load directly from GitHub via loadstring

## Quick Start

### Method 1: Load from GitHub (Recommended)

```lua
local Afterglow = loadstring(game:HttpGet("https://raw.githubusercontent.com/vv7z/Afterglow-UI/main/loader.lua"))()

local Window = Afterglow.CreateWindow({
    Name = "My UI",
    Size = UDim2.new(0, 1100, 0, 650)
})

local Tab = Window:CreateTab("Main")
local Groupbox = Tab:CreateGroupbox({Name = "Controls"})

Groupbox:AddButton({
    Text = "Click Me!",
    Callback = function()
        print("Clicked!")
    end
})
```

### Method 2: Local Installation

1. Clone or download the repository
2. Place the `Afterglow` folder in your project
3. Require the init.lua file:

```lua
local Afterglow = require(game.ServerScriptService.Afterglow)
```

## Project Structure

```
Afterglow/
├── init.lua                 # Main entry point
├── config/                  # Configuration
│   ├── Constants.lua       # Color and size constants
│   ├── Defaults.lua        # Default configurations
│   └── Theme.lua           # Theme management
├── core/                    # Core UI components
│   ├── Library.lua         # Main library
│   ├── Window.lua          # Window container
│   ├── Tab.lua             # Tab component
│   └── Groupbox.lua        # Groupbox container
├── controls/               # UI controls
│   ├── Button.lua
│   ├── Toggle.lua
│   ├── Checkbox.lua
│   ├── Slider.lua
│   ├── Label.lua
│   ├── Dropdown.lua
│   └── mixins/             # Control add-ons
│       ├── ClickRipple.lua
│       ├── ColorPicker.lua
│       ├── HoverStroke.lua
│       └── Keybind.lua
├── input/                   # Input handling
│   ├── Mouse.lua
│   ├── Drag.lua
│   └── KeybindListener.lua
├── layout/                  # Layout utilities
│   ├── Padding.lua
│   ├── ColumnLayout.lua
│   └── AutoSize.lua
├── overlay/                 # Overlay components
│   ├── HoverOverlay.lua
│   ├── PopupManager.lua
│   └── ContextMenu.lua
├── search/                  # Search functionality
│   ├── SearchIndex.lua
│   └── SearchFilter.lua
├── services/                # Service wrappers
│   ├── TweenService.lua
│   ├── InputService.lua
│   └── RunService.lua
└── utils/                   # Utility functions
    ├── Signal.lua          # Custom signal/event system
    ├── Text.lua            # Text utilities
    ├── Instances.lua       # Instance creation helpers
    ├── Math.lua            # Math utilities
    └── Tween.lua           # Tweening utilities
```

## API Reference

### Library

```lua
local Library = Afterglow.new()
local Window = Library:CreateWindow(config)
```

### Window

```lua
local Tab = Window:CreateTab("Tab Name")
Window:SelectTab(tab)
Window:Destroy()
```

### Tab

```lua
local Groupbox = Tab:CreateGroupbox({Name = "Groupbox Title"})
```

### Groupbox

```lua
-- Add elements
Groupbox:AddLabel("Text")
Groupbox:AddButton({Text = "Button", Callback = function() end})
Groupbox:AddToggle({Text = "Toggle", Default = false, Callback = function(v) end})
Groupbox:AddCheckbox({Text = "Checkbox", Default = false, Callback = function(v) end})
Groupbox:AddSlider({Text = "Slider", Min = 0, Max = 100, Default = 50, Callback = function(v) end})
Groupbox:AddDropdown({Text = "Dropdown", Options = {}, Callback = function(v) end})
```

## Control Properties

### Button
```lua
{
    Text = "Button Text",
    Callback = function() end
}
```

### Toggle
```lua
{
    Text = "Toggle Text",
    Default = false,
    Callback = function(value) end,
    Keybind = Enum.KeyCode.E,          -- Optional
    KeybindMode = "Toggle",             -- Optional: "Toggle", "Hold", "Always"
    ColorPicker = Color3.new(1,0,0),   -- Optional
    AlphaDefault = 0.8                  -- Optional
}
```

### Slider
```lua
{
    Text = "Slider Text",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 5,
    Callback = function(value) end
}
```

### Dropdown
```lua
{
    Text = "Dropdown Text",
    Options = {"Option 1", "Option 2", "Option 3"},
    Default = "Option 1",
    Multi = false,  -- Enable multi-select
    Callback = function(value) end
}
```

## Loaders

### Main Loader (loader.lua)
The main loader that downloads and loads all modules from GitHub.

Usage:
```lua
local Afterglow = loadstring(game:HttpGet("https://raw.githubusercontent.com/vv7z/Afterglow-UI/main/loader.lua"))()
```

### Afterglow-Loader.lua
Advanced loader with module caching and error handling.

## Configuration

Customize the library by modifying:

- **Colors**: `config/Constants.lua` - COLORS table
- **Sizes**: `config/Constants.lua` - SIZES table
- **Fonts**: `config/Constants.lua` - FONTS table
- **Defaults**: `config/Defaults.lua` - Window and element defaults
- **Theme**: `config/Theme.lua` - Theme management

## Examples

See `example.lua` for a complete example with all features demonstrated.

## Features Roadmap

- [ ] Multiselect Dropdown
- [ ] Color Picker with advanced options
- [ ] Rich Text Support
- [ ] Tabbed dropdowns (sub-menus)
- [ ] Hotkey recording
- [ ] Theme customization UI
- [ ] Performance metrics
- [ ] Widget templates

## License

Made by vvs for the Roblox community.

## Support

For issues and feature requests, please visit:
https://github.com/vv7z/Afterglow-UI

---

**Version**: 1.0.0  
**Status**: Active Development
