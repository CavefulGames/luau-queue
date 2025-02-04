local Queue = require('../src')
local newQueue = Queue.new(0, true)

newQueue:add(function()
	print('hello')
	require('@lune/task').wait(1)
end)

newQueue:add(function() 
	print('world')
end)

-- newQueue:run()