-- Column layout utility for Afterglow UI Library

local ColumnLayout = {}

-- Create columns inside a container
function ColumnLayout.CreateColumns(container, columnCount, padding)
	columnCount = columnCount or 3
	padding = padding or 10
	
	local columns = {}
	
	-- Create grid layout
	local gridList = Instance.new("UIListLayout")
	gridList.FillDirection = Enum.FillDirection.Horizontal
	gridList.SortOrder = Enum.SortOrder.LayoutOrder
	gridList.Padding = UDim.new(0, padding)
	gridList.Parent = container
	
	-- Create individual columns
	for i = 1, columnCount do
		local col = Instance.new("Frame")
		col.Name = "Column_" .. i
		col.Size = UDim2.new(1 / columnCount, -padding/columnCount, 0, 0)
		col.BackgroundTransparency = 1
		col.AutomaticSize = Enum.AutomaticSize.Y
		col.LayoutOrder = i
		col.Parent = container
		
		local colLayout = Instance.new("UIListLayout")
		colLayout.FillDirection = Enum.FillDirection.Vertical
		colLayout.SortOrder = Enum.SortOrder.LayoutOrder
		colLayout.Padding = UDim.new(0, padding)
		colLayout.Parent = col
		
		table.insert(columns, col)
	end
	
	return columns
end

-- Get the least populated column
function ColumnLayout.GetLeastPopulatedColumn(columns)
	local minColumn = columns[1]
	local minCount = #minColumn:GetChildren()
	
	for _, col in ipairs(columns) do
		local count = 0
		for _, child in ipairs(col:GetChildren()) do
			if child.Name ~= "UIListLayout" then
				count = count + 1
			end
		end
		
		if count < minCount then
			minColumn = col
			minCount = count
		end
	end
	
	return minColumn
end

return ColumnLayout
