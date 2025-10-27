extends Unpacker
const STATIC_BOX : PackedScene = preload("uid://cx7im3ai1vqkn")
const PATH = preload("uid://bmtu2j0njtlvr")

var MIN_POINTS = 5
var MAX_POINTS = 10
var MAP_SIZE = Vector3(500,30,500)
var MIN_PATHS = 30
var MAX_PATHS = 50

class BoxDistanceData:
	var box_a: Node3D
	var box_b: Node3D
	var distance: float
	
	func _init(box_a:Node3D,box_b:Node3D,distance:float):
		self.box_a = box_a
		self.box_b = box_b
		self.distance = distance

func _ready() -> void:
	unpack()
	
func create_box() -> Node3D:
	var new_box = STATIC_BOX.instantiate() as Node3D
	var x = randf_range(-MAP_SIZE.x / 2,MAP_SIZE.x / 2)
	var y = randf_range(-MAP_SIZE.y / 2,MAP_SIZE.y / 2)
	var z = randf_range(-MAP_SIZE.z / 2,MAP_SIZE.z / 2)
	new_box.position = Vector3(x,y,z)
	new_box.scale = Vector3(10,1,10)
	add_child(new_box)
	return new_box
	
func get_box_distances(boxes:Array) -> Array[BoxDistanceData]:
	var result : Array[BoxDistanceData] = []
	
	for i in range(len(boxes)):
		var box_i = boxes[i]
		for j in range(i+1,len(boxes)):
			var box_j = boxes[j]
			var dist = box_i.position.distance_to(box_j.position)
			result.append(BoxDistanceData.new(box_i,box_j,dist))
	return result
			

func create_path(data:BoxDistanceData):
	var path = PATH.instantiate() as Path3D
	path.curve.add_point(data.box_a.position)
	path.curve.add_point(data.box_b.position)
	

func sort_boxes_by_distance(a:BoxDistanceData,b:BoxDistanceData):
	return a.distance < b.distance
		
func create_all_paths(boxes:Array):
	var box_distances = get_box_distances(boxes)
	box_distances.sort_custom(sort_boxes_by_distance)
	var n_paths = randi_range(min(MIN_PATHS,len(box_distances)),min(MAX_PATHS,len(box_distances)))
	for i in range(n_paths):
		create_path(box_distances[i])
	

func unpack() -> Array[Unpacker]:
	var boxes = []
	for i in range(randi_range(MIN_POINTS,MAX_POINTS)):
		boxes.append(create_box())
	create_all_paths(boxes)
	
	return []
	
