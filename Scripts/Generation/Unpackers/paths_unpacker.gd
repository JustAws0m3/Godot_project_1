extends Unpacker

const STATIC_BOX : PackedScene = preload("uid://cx7im3ai1vqkn")
const PATH : PackedScene = preload("uid://bmtu2j0njtlvr")

const RED = preload("uid://8nfabsfre24")
const BLUE = preload("uid://cmmc4juj1a1kd")
const GREEN = preload("uid://di5vgqcoebvue")

#Map paramaters
@export var map_size := Vector3(300,30,150)

#Spawn Paramaters
@export var spawn_dist_min := 15
@export var spawn_dist_max := 30
@export var spawn_bound := 20

#Point paramaters
@export var n_pois := 3
@export var poi_bound = 20
@export var min_poi_dist_ratio := 0.3
@export var max_poi_dist_ratio := 0.7

var WORLD_BORDER_POSITIVE = map_size / 2
var WORLD_BORDER_NEGATIVE = -map_size / 2

func _ready():
	unpack()

class BoxDistanceData:
	var box_a: Node3D
	var box_b: Node3D
	var distance: float
	
	func _init(box_a:Node3D,box_b:Node3D,distance:float):
		self.box_a = box_a
		self.box_b = box_b
		self.distance = distance

func create_path(data:BoxDistanceData):
	var path = PATH.instantiate() as Path3D
	path.curve.add_point(data.box_a.position)
	path.curve.add_point(data.box_b.position)
	add_child(path)
	
func place_point(pos:Vector3,material:StandardMaterial3D) -> Node3D:
	var point = STATIC_BOX.instantiate() as Node3D
	point.position = pos
	var point_mesh = point.get_node("./MeshInstance3D") as MeshInstance3D
	point_mesh.material_override = material
	add_child(point)
	return point
	
	
#Method for placing spawn points
func place_spawns(rng:RandomNumberGenerator) -> Array[Node3D]:	
	var spawn_point_a_pos = Vector3(
		WORLD_BORDER_NEGATIVE.x + rng.randf_range(spawn_dist_min,spawn_dist_max),
		0,
		rng.randf_range(WORLD_BORDER_NEGATIVE.z + spawn_bound, WORLD_BORDER_POSITIVE.z - spawn_bound)
	)
	var spawn_point_b_pos = Vector3(
		WORLD_BORDER_POSITIVE.x - rng.randf_range(spawn_dist_min,spawn_dist_max),
		0,
		rng.randf_range(WORLD_BORDER_NEGATIVE.z + spawn_bound, WORLD_BORDER_POSITIVE.z - spawn_bound)
	)
	
	var spawn_point_a = place_point(spawn_point_a_pos,RED)
	var spawn_point_b = place_point(spawn_point_b_pos,BLUE)
	
	return [spawn_point_a,spawn_point_b]

#Gets the maximum positive and negative distances you can travel along a vector from a point without going out of bounds
func calculate_vector_map_bounds(pos:Vector2,vec:Vector2) -> Array[float]:
	var x_pos = ((WORLD_BORDER_POSITIVE.x - poi_bound) - pos.x) / vec.x
	var x_neg = ((WORLD_BORDER_NEGATIVE.x + poi_bound) - pos.x) / vec.x
	var y_pos = ((WORLD_BORDER_POSITIVE.y - poi_bound) - pos.y) / vec.y
	var y_neg = ((WORLD_BORDER_NEGATIVE.y + poi_bound) - pos.y) / vec.y
	return [min(x_pos,y_pos),max(x_neg,y_neg)]
	

func generate_poi_vector(rng:RandomNumberGenerator,pos_a:Vector3,pos_b:Vector3) -> Vector3:
	var pos_a_v2 = Vector2(pos_a.x,pos_a.z)
	var pos_b_v2 = Vector2(pos_b.x,pos_b.z)
	
	var dist = rng.randf_range(min_poi_dist_ratio,max_poi_dist_ratio)
	var interm_pos = (pos_a_v2 * dist) + (pos_b_v2 * (1 - dist))
	var interm_vector = (pos_a - pos_b).normalized()
	var perp_interm_vector = Vector2(interm_vector.y,-interm_vector.x)
	var perp_dist_bounds = calculate_vector_map_bounds(interm_pos,perp_interm_vector)
	var result_vector = interm_pos + (perp_interm_vector * rng.randf_range(perp_dist_bounds[1],perp_dist_bounds[0]))
	return Vector3(result_vector.x,0,result_vector.y)
	
	
func generate_poi_points(rng:RandomNumberGenerator,spawn_a:Vector3,spawn_b:Vector3) -> Array[Node3D]:
	var result: Array[Node3D] = []
	for i in range(n_pois):
		var new_vector = generate_poi_vector(rng,spawn_a,spawn_b)
		var new_point = place_point(new_vector,GREEN)
		result.append(new_point)
	return result;
	

func unpack() -> Array[Unpacker]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	
	# Place Spawns
	var spawns = place_spawns(rng)
	var pois = generate_poi_points(rng,spawns[0].position,spawns[1].position)
	
	return []
