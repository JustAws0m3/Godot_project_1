extends Node

@export var seed := 0
@export var base_unpacker: Unpacker

var next_queue := ThreadSafeQueue.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	next_queue.push(base_unpacker)
	unpack_all()
	
# Unpack a number of unpackers in different threads
func unpack_all():
	while !next_queue.is_empty():
		var this_queue = next_queue
		next_queue = ThreadSafeQueue.new()
		
		# Unpack everything in the currentt queue
		var this_queue_values = this_queue.pop_all()
		for unpacker in this_queue_values:
			unpacker.seed = seed
			WorkerThreadPool.add_task(do_unpack.bind(unpacker))
			
		# Wait for the next frame to ensure that the tree has been updated
		await get_tree().create_timer(0.0).timeout
		

func do_unpack(unpacker:Unpacker):
	var next_to_unpack = unpacker.unpack()
	next_queue.push_all(next_to_unpack)
	
	
