-- Tween utilities for Afterglow UI Library

local Tween = {}

local TweenService = game:GetService("TweenService")

-- Standard tween durations
Tween.DURATION = {
	INSTANT = 0,
	QUICK = 0.1,
	FAST = 0.15,
	NORMAL = 0.2,
	SLOW = 0.3,
	SMOOTH = 0.5,
}

-- Create a standard tween info
function Tween.CreateInfo(duration, easingStyle, easingDirection)
	duration = duration or Tween.DURATION.NORMAL
	easingStyle = easingStyle or Enum.EasingStyle.Quad
	easingDirection = easingDirection or Enum.EasingDirection.InOut
	return TweenInfo.new(duration, easingStyle, easingDirection)
end

-- Tween property change
function Tween.Property(object, duration, property, targetValue, callback)
	local info = Tween.CreateInfo(duration)
	local tween = TweenService:Create(object, info, {[property] = targetValue})
	
	if callback then
		tween.Completed:Connect(callback)
	end
	
	tween:Play()
	return tween
end

-- Tween multiple properties
function Tween.Properties(object, duration, propertyTable, callback)
	local info = Tween.CreateInfo(duration)
	local tween = TweenService:Create(object, info, propertyTable)
	
	if callback then
		tween.Completed:Connect(callback)
	end
	
	tween:Play()
	return tween
end

-- Fade in
function Tween.FadeIn(object, duration)
	duration = duration or Tween.DURATION.NORMAL
	return Tween.Property(object, duration, "BackgroundTransparency", 0)
end

-- Fade out
function Tween.FadeOut(object, duration)
	duration = duration or Tween.DURATION.NORMAL
	return Tween.Property(object, duration, "BackgroundTransparency", 1)
end

-- Color tween
function Tween.Color(object, duration, targetColor)
	duration = duration or Tween.DURATION.NORMAL
	return Tween.Property(object, duration, "BackgroundColor3", targetColor)
end

return Tween
