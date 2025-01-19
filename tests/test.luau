local Queue = require('../src')
local newQueue = Queue.new(0.5)
newQueue:add(function()
	print('hello')
end)

newQueue:add(function() 
	print('world')
end)

newQueue:run()