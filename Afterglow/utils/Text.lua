-- Text utilities for Afterglow UI Library

local Text = {}

local TextService = game:GetService("TextService")

-- Measure text size
function Text.MeasureText(text, textSize, font, maxSize)
	maxSize = maxSize or Vector2.new(200, 50)
	local bounds = TextService:GetTextSize(text, textSize, font, maxSize)
	return bounds
end

-- Truncate text with ellipsis if it exceeds max width
function Text.Truncate(text, maxWidth, textSize, font)
	if text:len() == 0 then
		return text
	end
	
	local ellipsis = "..."
	local bounds = Text.MeasureText(text, textSize, font, Vector2.new(maxWidth, 50))
	
	if bounds.X <= maxWidth then
		return text
	end
	
	local truncated = text
	while truncated:len() > 0 do
		truncated = truncated:sub(1, -2)
		bounds = Text.MeasureText(truncated .. ellipsis, textSize, font, Vector2.new(maxWidth, 50))
		if bounds.X <= maxWidth then
			return truncated .. ellipsis
		end
	end
	
	return ellipsis
end

-- Format key name for display
function Text.FormatKeyName(key)
	if typeof(key) == "EnumItem" then
		if key.EnumType == Enum.KeyCode then
			local name = key.Name
			-- Convert camelCase to Title Case
			name = name:gsub("([a-z])([A-Z])", "%1 %2")
			return name
		end
		return key.Name
	end
	return tostring(key)
end

-- Format number with thousands separator
function Text.FormatNumber(num)
	local formatted = tostring(num)
	formatted = formatted:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	if formatted:sub(1, 1) == "," then
		formatted = formatted:sub(2)
	end
	return formatted
end

return Text
