local task = require('@lune/task')
local gt = require('../lune_packages/greentea')

local QueueBuildType = gt.build(gt.table({
	taskDelay = gt.number(),
	queue = gt.table({
		[gt.number()] = gt.any(),
	})
}))

local NumberBuild = gt.build(gt.number())

local FunctionBuild = gt.build(gt.anyfn())

export type Queue = typeof(setmetatable({} :: typeof(QueueBuildType:type()), {} :: QueueImpl))

type QueueImpl = {
	__index: QueueImpl,
	new: (taskDelay: number) -> (Queue),
	add: (self: Queue, func: () -> ()) -> (),
	run: (self: Queue) -> (),
	remove: (self: Queue, index: number) -> (),
}

local Queue = {} :: QueueImpl
Queue.__index = Queue

function queueIs(value)
	if type(value) == "table" and getmetatable(value) == Queue then
		QueueBuildType:assert(value)

		return true
	end
	return false
end

local QueueType = gt.build(gt.custom(queueIs, "Directory") :: Queue)

function Queue.new(taskDelay)
	NumberBuild:assert(taskDelay)
	return setmetatable({
		taskDelay=taskDelay,
		queue = {},
	}, Queue)
end

function Queue.add(self, func)
	QueueType:assert(self)
	FunctionBuild:assert(func)
	self.queue[#self.queue + 1] = func
end

function Queue.remove(self, index)
	QueueType:assert(self)
	NumberBuild:assert(index)
	self.queue[index] = nil
end

function Queue.run(self)
	QueueType:assert(self)
	for i=1, #self.queue do
		task.wait(self.taskDelay)
		self.queue[i]()
	end
end

return Queue
