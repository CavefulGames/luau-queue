local Queue = require('../src')
local newQueue = Queue.new(1, true)

newQueue:add(function()
	print('hello')
end)

newQueue:add(function() 
	print('world')
end)
