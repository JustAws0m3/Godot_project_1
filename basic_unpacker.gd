extends Unpacker
const STATIC_BOX : PackedScene = preload("uid://cx7im3ai1vqkn")

var MIN_POINTS = 5
var MAX_POINTS = 10
var MAP_SIZE = Vector3(200,30,200)

func _ready() -> void:
	unpack()

func unpack():
	for i in range(randi_range(MIN_POINTS,MAX_POINTS)):
		var new_box = STATIC_BOX.instantiate() as Node3D
		var x = randf_range(-MAP_SIZE.x / 2,MAP_SIZE.x / 2)
		var y = randf_range(-MAP_SIZE.y / 2,MAP_SIZE.y / 2)
		var z = randf_range(-MAP_SIZE.z / 2,MAP_SIZE.z / 2)
		new_box.position = Vector3(x,y,z)
		new_box.scale = Vector3(10,1,10)
		add_child(new_box)
	
