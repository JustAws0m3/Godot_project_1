class_name ThreadSafeQueue

var queue := []
var queue_size := 0
var mutex := Mutex.new()

func push(item):
	mutex.lock()
	queue_size += 1
	queue.push_back(item)
	mutex.unlock()
	
func push_all(items:Array):
	mutex.lock()
	queue_size += items.size()
	for item in items:
		queue.push_back(item)
	mutex.unlock()

func pop():
	mutex.lock()
	queue_size -= 1
	var result = queue.pop_front()
	mutex.unlock()
	return result
	
func pop_all():
	mutex.lock()
	queue_size = 0
	var result = queue
	queue = []
	mutex.unlock()
	return result
	
func size():
	return queue_size
	
func is_empty():
	return queue_size == 0
