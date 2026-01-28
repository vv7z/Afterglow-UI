-- Wrapper for Roblox TweenService

local TweenService = {}

local _TweenService = game:GetService("TweenService")

-- Create a tween
function TweenService.Create(object, tweenInfo, propertyTable)
	return _TweenService:Create(object, tweenInfo, propertyTable)
end

-- Cancel a tween
function TweenService.Cancel(tween)
	_TweenService:Cancel(tween)
end

return TweenService
