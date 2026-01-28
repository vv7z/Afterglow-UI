-- Click ripple mixin for Afterglow UI Library

local ClickRipple = {}

-- Create click ripple effect
function ClickRipple.Create(element, accentColor)
	accentColor = accentColor or Color3.fromHex("#d177b0")
	
	element.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			-- Create ripple frame
			local ripple = Instance.new("Frame")
			ripple.Name = "Ripple"
			ripple.Size = UDim2.new(0, 0, 0, 0)
			ripple.AnchorPoint = Vector2.new(0.5, 0.5)
			ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
			ripple.BackgroundColor3 = accentColor
			ripple.BackgroundTransparency = 0.7
			ripple.BorderSizePixel = 0
			ripple.ZIndex = element.ZIndex + 1
			ripple.Parent = element
			
			local rippleCorner = Instance.new("UICorner")
			rippleCorner.CornerRadius = UDim.new(1, 0)
			rippleCorner.Parent = ripple
			
			-- Animate ripple
			local maxSize = math.max(element.AbsoluteSize.X, element.AbsoluteSize.Y) * 2
			local tween = game:GetService("TweenService"):Create(
				ripple,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 1}
			)
			
			tween:Play()
			tween.Completed:Connect(function()
				ripple:Destroy()
			end)
		end
	end)
end

return ClickRipple
