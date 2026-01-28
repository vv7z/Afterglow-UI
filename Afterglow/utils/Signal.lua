-- Signal/Event system for Afterglow UI Library

local Signal = {}
Signal.__index = Signal

-- Create a new signal
function Signal.new()
	local self = setmetatable({}, Signal)
	self._connections = {}
	return self
end

-- Connect a function to the signal
function Signal:Connect(callback)
	assert(typeof(callback) == "function", "Callback must be a function")
	
	local connection = {
		Connected = true,
		_callback = callback,
		_signal = self,
	}
	
	function connection:Disconnect()
		self.Connected = false
		for i, conn in ipairs(self._signal._connections) do
			if conn == self then
				table.remove(self._signal._connections, i)
				break
			end
		end
	end
	
	table.insert(self._connections, connection)
	return connection
end

-- Fire the signal with arguments
function Signal:Fire(...)
	for _, connection in ipairs(self._connections) do
		if connection.Connected then
			task.spawn(connection._callback, ...)
		end
	end
end

-- Wait for signal to fire
function Signal:Wait()
	local thread = coroutine.running()
	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		task.spawn(thread, ...)
	end)
	return coroutine.yield()
end

return Signal
