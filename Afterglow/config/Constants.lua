-- Constants for Afterglow UI Library
-- Theme colors and configuration constants

local Constants = {}

-- Accent color used throughout the UI
Constants.ACCENT_COLOR = Color3.fromHex("#d177b0")

-- Color palette
Constants.COLORS = {
	-- Background colors
	PRIMARY_BG = Color3.fromRGB(20, 20, 20),     -- Main window background
	SECONDARY_BG = Color3.fromRGB(25, 25, 25),   -- Sidebar background
	TERTIARY_BG = Color3.fromRGB(30, 30, 30),    -- Groupbox & element background
	HOVER_BG = Color3.fromRGB(32, 32, 32),       -- Hover state background
	BUTTON_BG = Color3.fromRGB(40, 40, 40),      -- Button background
	TOGGLE_BG = Color3.fromRGB(50, 50, 50),      -- Toggle inactive background
	
	-- Text colors
	PRIMARY_TEXT = Color3.fromRGB(200, 200, 200),     -- Main text
	SECONDARY_TEXT = Color3.fromRGB(160, 160, 160),   -- Secondary text
	PLACEHOLDER_TEXT = Color3.fromRGB(120, 120, 120), -- Placeholder text
	
	-- UI elements
	STROKE_COLOR = Color3.fromRGB(55, 55, 55),        -- Border/stroke color
	SCROLLBAR_COLOR = Color3.fromRGB(60, 60, 60),     -- Scrollbar color
}

-- Size constants
Constants.SIZES = {
	WINDOW_WIDTH = 1100,
	WINDOW_HEIGHT = 650,
	CORNER_RADIUS = 8,
	SMALL_CORNER_RADIUS = 4,
	DRAG_BAR_HEIGHT = 60,
	SEARCH_BAR_HEIGHT = 40,
	TAB_BUTTON_HEIGHT = 35,
	ELEMENT_HEIGHT = 30,
	LABEL_HEIGHT = 20,
	SIDEBAR_WIDTH = 170,
	SCROLLBAR_THICKNESS = 6,
	DEFAULT_PADDING = 10,
	SMALL_PADDING = 5,
	COLUMN_COUNT = 3,
}

-- Font constants
Constants.FONTS = {
	DEFAULT = Enum.Font.Gotham,
	MEDIUM = Enum.Font.GothamMedium,
	BOLD = Enum.Font.GothamBold,
}

-- Font sizes
Constants.FONT_SIZES = {
	TITLE = 13,
	LABEL = 12,
	BUTTON = 12,
	SMALL = 11,
}

-- Z-Index layers
Constants.Z_INDEX = {
	DEFAULT = 1,
	HOVER_OVERLAY = 1000,
	POPUP = 1006,
}

return Constants
