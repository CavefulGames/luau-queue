# Queue
파라미터를 사용할수있는 자료구조!

## 특징
- 자료구조인대 파라미터를 사용할수있습니다!
- 비동기 , 동기 지정을 할수 있습니다!

## 사용 예시
```lua
local Queue = require('../src')
local newQueue = Queue.new(0.5)

newQueue:add(function()
	print('hello')
end)

newQueue:add(function() 
	print('world')
end)

newQueue:run()
```
