-- Default configuration for Afterglow UI Library

local Defaults = {}

-- Window defaults
Defaults.Window = {
	Name = "UI Library",
	Size = UDim2.new(0, 1100, 0, 650),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
}

-- Search defaults
Defaults.Search = {
	Enabled = true,
	Placeholder = "Search",
	CaseSensitive = false,
}

-- Animation defaults
Defaults.Animation = {
	HoverTweenDuration = 0.2,
	TweenInfo = TweenInfo.new(0.2),
}

-- Element defaults
Defaults.Elements = {
	Button = {
		CornerRadius = UDim.new(0, 4),
		ClickableArea = UDim2.new(1, 0, 0, 30),
	},
	Toggle = {
		SwitchWidth = 35,
		SwitchHeight = 20,
		IndicatorSize = 14,
		IndicatorPadding = 3,
	},
	Slider = {
		Height = 30,
		TrackHeight = 4,
		ThumbSize = 12,
	},
	Textbox = {
		Height = 30,
		CornerRadius = UDim.new(0, 4),
	},
	Dropdown = {
		Height = 30,
		MaxVisibleItems = 5,
	},
}

return Defaults
