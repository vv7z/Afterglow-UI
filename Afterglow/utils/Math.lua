-- Math utilities for Afterglow UI Library

local Math = {}

-- Clamp a value between min and max
function Math.Clamp(value, min, max)
	return math.max(min, math.min(max, value))
end

-- Linearly interpolate between two values
function Math.Lerp(a, b, t)
	return a + (b - a) * t
end

-- Map a value from one range to another
function Math.Map(value, inMin, inMax, outMin, outMax)
	local normalized = (value - inMin) / (inMax - inMin)
	return outMin + normalized * (outMax - outMin)
end

-- Ease in and out (smooth step)
function Math.SmoothStep(t)
	t = Math.Clamp(t, 0, 1)
	return t * t * (3 - 2 * t)
end

-- Distance between two points
function Math.Distance(v1, v2)
	local dx = v1.X - v2.X
	local dy = v1.Y - v2.Y
	return math.sqrt(dx * dx + dy * dy)
end

-- Check if point is inside rectangle
function Math.PointInRect(point, rectPos, rectSize)
	local x = point.X
	local y = point.Y
	return x >= rectPos.X and x <= rectPos.X + rectSize.X and
	       y >= rectPos.Y and y <= rectPos.Y + rectSize.Y
end

return Math
