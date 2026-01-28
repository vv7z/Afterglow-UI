-- Wrapper for Roblox RunService

local RunService = {}

local _RunService = game:GetService("RunService")

-- Connect to Heartbeat
function RunService.Heartbeat(callback)
	return _RunService.Heartbeat:Connect(callback)
end

-- Connect to RenderStepped
function RunService.RenderStepped(callback)
	return _RunService.RenderStepped:Connect(callback)
end

-- Check if running in Studio
function RunService.IsStudio()
	return _RunService:IsStudio()
end

-- Check if running on client
function RunService.IsClient()
	return _RunService:IsClient()
end

return RunService
