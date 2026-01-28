-- Search index for Afterglow UI Library

local SearchIndex = {}
SearchIndex.__index = SearchIndex

-- Create a search index
function SearchIndex.new()
	local self = setmetatable({}, SearchIndex)
	self.Elements = {}  -- {searchText, frame, groupbox}
	self.Results = {}
	return self
end

-- Register an element for search
function SearchIndex:Register(element, searchText, frame, groupbox)
	table.insert(self.Elements, {
		SearchText = searchText,
		Frame = frame,
		Groupbox = groupbox,
		Element = element,
	})
end

-- Clear all registered elements
function SearchIndex:Clear()
	self.Elements = {}
	self.Results = {}
end

-- Search for elements matching query
function SearchIndex:Search(query, caseSensitive)
	self.Results = {}
	
	if query == "" then
		-- No search, show all
		for _, item in ipairs(self.Elements) do
			table.insert(self.Results, item)
		end
		return self.Results
	end
	
	local searchQuery = caseSensitive and query or query:lower()
	
	for _, item in ipairs(self.Elements) do
		local searchText = caseSensitive and item.SearchText or item.SearchText:lower()
		
		if searchText:find(searchQuery, 1, true) then
			table.insert(self.Results, item)
		end
	end
	
	return self.Results
end

-- Get results
function SearchIndex:GetResults()
	return self.Results
end

return SearchIndex
