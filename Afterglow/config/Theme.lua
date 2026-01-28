-- Theme system for Afterglow UI Library

local Theme = {}
Theme.__index = Theme

local Constants = require("config.Constants")

-- Default theme
Theme.Current = {
	name = "Default Dark",
	colors = Constants.COLORS,
	accent = Constants.ACCENT_COLOR,
}

-- Light theme
Theme.Light = {
	name = "Light",
	colors = {
		PRIMARY_BG = Color3.fromRGB(240, 240, 240),
		SECONDARY_BG = Color3.fromRGB(235, 235, 235),
		TERTIARY_BG = Color3.fromRGB(245, 245, 245),
		HOVER_BG = Color3.fromRGB(230, 230, 230),
		BUTTON_BG = Color3.fromRGB(220, 220, 220),
		TOGGLE_BG = Color3.fromRGB(200, 200, 200),
		PRIMARY_TEXT = Color3.fromRGB(50, 50, 50),
		SECONDARY_TEXT = Color3.fromRGB(100, 100, 100),
		PLACEHOLDER_TEXT = Color3.fromRGB(150, 150, 150),
		STROKE_COLOR = Color3.fromRGB(180, 180, 180),
		SCROLLBAR_COLOR = Color3.fromRGB(200, 200, 200),
	},
	accent = Color3.fromHex("#d177b0"),
}

-- Set the current theme
function Theme:Set(themeName)
	if themeName == "light" then
		self.Current = self.Light
	else
		self.Current = {
			name = "Default Dark",
			colors = Constants.COLORS,
			accent = Constants.ACCENT_COLOR,
		}
	end
end

-- Get color from current theme
function Theme:GetColor(colorName)
	return self.Current.colors[colorName] or Color3.new(1, 1, 1)
end

-- Get accent color
function Theme:GetAccent()
	return self.Current.accent
end

return Theme
