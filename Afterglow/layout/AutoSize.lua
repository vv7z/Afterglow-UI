-- Auto-sizing utilities for Afterglow UI Library

local AutoSize = {}

-- Enable auto-sizing on container based on layout content
function AutoSize.EnableOnContainer(container)
	container.AutomaticSize = Enum.AutomaticSize.Y
	
	local layout = container:FindFirstChildOfClass("UIListLayout")
	if layout then
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			-- Layout handles the sizing automatically
		end)
	end
end

-- Auto-size text label to fit content
function AutoSize.FitTextLabel(label, maxWidth)
	label.TextWrapped = true
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.Size = UDim2.new(0, maxWidth or 200, 0, 0)
end

-- Auto-size frame based on children layout
function AutoSize.FitToContent(frame)
	frame.AutomaticSize = Enum.AutomaticSize.Y
end

-- Update size after content changes
function AutoSize.Update(container, delayTime)
	delayTime = delayTime or 0.05
	task.wait(delayTime)
	
	local layout = container:FindFirstChildOfClass("UIListLayout")
	if layout then
		container.Size = UDim2.new(container.Size.X.Scale, container.Size.X.Offset, 0, layout.AbsoluteContentSize.Y)
	end
end

return AutoSize
