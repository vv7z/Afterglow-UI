-- Search filter application for Afterglow UI Library

local SearchFilter = {}

-- Apply search results (show/hide elements and groupboxes)
function SearchFilter.ApplySearch(searchText, allElements, currentTabGroupboxes)
	local groupboxMatches = {}
	
	-- Initialize groupbox matches
	if currentTabGroupboxes then
		for _, groupbox in pairs(currentTabGroupboxes) do
			groupboxMatches[groupbox] = false
		end
	end
	
	-- Update element visibility
	for _, element in pairs(allElements) do
		if element.Searchable and element.Frame then
			local match = searchText == "" or (element.SearchText and element.SearchText:lower():find(searchText:lower(), 1, true))
			element.Frame.Visible = match
			
			-- Mark groupbox as having matches
			if match and element.Groupbox then
				groupboxMatches[element.Groupbox] = true
			end
		end
	end
	
	-- Update groupbox visibility
	if currentTabGroupboxes then
		for _, groupbox in pairs(currentTabGroupboxes) do
			if groupbox.Frame then
				groupbox.Frame.Visible = searchText == "" or groupboxMatches[groupbox] == true
			end
		end
	end
end

-- Get filtered results
function SearchFilter.GetMatches(searchText, elements, caseSensitive)
	local matches = {}
	local query = caseSensitive and searchText or searchText:lower()
	
	for _, element in ipairs(elements) do
		if element.SearchText then
			local text = caseSensitive and element.SearchText or element.SearchText:lower()
			if text:find(query, 1, true) then
				table.insert(matches, element)
			end
		end
	end
	
	return matches
end

return SearchFilter
