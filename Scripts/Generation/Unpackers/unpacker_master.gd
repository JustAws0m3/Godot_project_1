extends Node

@export var seed := 0
@export var base_unpacker: Unpacker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	unpack_all([base_unpacker])
	
# Unpack a number of unpackers in different threads
func unpack_all(unpackers: Array[Unpacker]):
	for unpacker in unpackers:
		unpacker.seed = seed
		WorkerThreadPool.add_task(do_unpack.bind(unpacker))
		

func do_unpack(unpacker:Unpacker):
	var next_to_unpack = unpacker.unpack()
	
	# Wait for the next frame to ensure that the tree has been updated
	await get_tree().create_timer(0.0).timeout
	
	unpack_all(next_to_unpack)
