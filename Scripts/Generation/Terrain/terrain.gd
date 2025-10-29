extends Node

@export var chunck_size := 64
@export var resolution := 64
@export var noise : FastNoiseLite

const PRECED_TERRAIN = preload("uid://dvthq2uk78b2m")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for x in range(-2,2):
		for y in range(-2,2):
			generate_chunck(Vector2(x,y))
	pass # Replace with function body.

func generate_chunck(chunck:Vector2):
	var x_offset := chunck.x * chunck_size
	var y_offset := chunck.y * chunck_size
	
	#Instantiate the chunck and set size and position
	var new_chunck = PRECED_TERRAIN.instantiate() as MeshInstance3D
	new_chunck.size_x = chunck_size
	new_chunck.size_y = chunck_size
	new_chunck.resolution = resolution
	new_chunck.position = Vector3(x_offset,-64,y_offset)
	
	#Offset the terrain of the chunck
	var noise_instance := noise.duplicate()
	noise_instance.offset = Vector3(x_offset,y_offset,0)
	new_chunck.noise = noise_instance
	
	
	add_child(new_chunck)
