local gt = require("../luau_packages/greentea_luau")
local task = require('../lune_packages/task')

local NumberOptBuildType = gt.build(gt.optional(gt.number()))

local FunctionBuildType = gt.build(gt.anyfn())

local QueueBuildType = gt.build(gt.table({
	taskDelay = NumberOptBuildType:type(),
	autoRun = gt.optional(gt.boolean()),
	isRun = gt.boolean(),
	queue = gt.struct({ [gt.number()] = gt.anyfn() }),
}))

export type Queue = typeof(setmetatable({} :: typeof(QueueBuildType:type()), {} :: QueueImpl))

--[=[
	@class Queue

    Queue
]=]
type QueueImpl = {
	__index: QueueImpl,

	--[=[
        @within Queue

        Create a Queue

        ```luau
        local queue = queue.new()
        ```

        @param taskDelay -- Delay time when repeating
		@param autoRun -- Whether to do it automatically without doing queue:run()
    ]=]
	new: (taskDelay: typeof(NumberOptBuildType:type()), autoRun: typeof(gt.optional(gt.boolean()))) -> Queue,

	--[=[
		@within Queue

		Add a array to run in the queue

		```luau
        queue:add(function() 
			print('world')
		end)
        ```

		@param func -- Function to add
	]=]
	add: (self: Queue, func: typeof(FunctionBuildType:type())) -> (),

	--[=[
		@within Queue

		Execute functions on a array

		```luau
        queue:run()
        ```
	]=]
	run: (self: Queue) -> (),

	--[=[
		@within Queue

		Remove function from array

		```luau
        queue:remove()
        ```

		@param index -- Position of the function in the array
	]=]
	remove: (self: Queue, typeof(NumberOptBuildType:type())) -> (),
}

local Queue = {} :: QueueImpl
Queue.__index = Queue

local function queueIs(value)
	if type(value) == "table" and getmetatable(value) == Queue then
		QueueBuildType:assert(value)

		return true
	end
	return false
end

local QueueType = gt.build(gt.custom(queueIs, "Queue") :: Queue)

function Queue.new(taskDelay, autoRun)
	NumberOptBuildType:assert(taskDelay)
	return setmetatable({
		taskDelay=taskDelay,
		autoRun=autoRun,
		isRun=false,
		queue={},
	}, Queue)
end

function Queue.add(self, func)
	QueueType:assert(self)
	FunctionBuildType:assert(func)
	self.queue[#self.queue + 1] = func

	if self.autoRun then
		self:run()
	end
end

function Queue.remove(self, index)
	QueueType:assert(self)
	NumberOptBuildType:assert(index)
	self.queue[index or #self.queue] = nil
end

function Queue.run(self)
	QueueType:assert(self)

	if self.isRun then
		return
	end

	self.isRun = true

	local function run()
		while #self.queue > 0 do
			(table.remove(self.queue, 1) :: any)()
			
			if self.taskDelay and self.taskDelay ~= 0 then
				task.wait(self.taskDelay)
			end

			self.isRun = false
		end
	end

	if self.autoRun then
		task.defer(run)
	else
		run()
	end	
end

return Queue
