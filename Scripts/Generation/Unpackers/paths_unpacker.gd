extends Unpacker

const STATIC_BOX : PackedScene = preload("uid://cx7im3ai1vqkn")
const PATH : PackedScene = preload("uid://bmtu2j0njtlvr")

const RED = preload("uid://8nfabsfre24")
const BLUE = preload("uid://cmmc4juj1a1kd")
const GREEN = preload("uid://di5vgqcoebvue")

#Map paramaters
@export var map_size := Vector3(300,30,200)

#Spawn Paramaters
@export var spawn_dist_min := 15
@export var spawn_dist_max := 304
@export var spawn_bound := 20

#Point paramaters
@export var n_pois := 3
@export var poi_bound = 20
@export_range(0,1.0,0.001) var min_poi_dist_ratio := 0.3
@export_range(0,1.0,0.001) var max_poi_dist_ratio := 0.7

var world_border_positive
var world_border_negative

func _ready():
	world_border_positive = map_size / 2
	world_border_negative = -map_size / 2
	
	var point = place_point(Vector3(0,-10,0),RED)
	point.scale = Vector3(map_size.x,1,map_size.z)
	
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
		world_border_negative.x + rng.randf_range(spawn_dist_min,spawn_dist_max),
		0,
		rng.randf_range(world_border_negative.z + spawn_bound, world_border_positive.z - spawn_bound)
	)
	var spawn_point_b_pos = Vector3(
		world_border_positive.x - rng.randf_range(spawn_dist_min,spawn_dist_max),
		0,
		rng.randf_range(world_border_negative.z + spawn_bound, world_border_positive.z - spawn_bound)
	)
	
	var spawn_point_a = place_point(spawn_point_a_pos,RED)
	var spawn_point_b = place_point(spawn_point_b_pos,BLUE)
	
	return [spawn_point_a,spawn_point_b]

#Gets the maximum positive and negative distances you can travel along a vector from a point without going out of bounds
func calculate_vector_map_bounds(pos:Vector2,vec:Vector2) -> Array[float]:
	#Calculate thbe distance needed to travel from pos along the vector to reach the world border
	var positive_border = Vector2(world_border_positive.x - poi_bound, world_border_positive.z - poi_bound)
	var negative_border = Vector2(world_border_negative.x + poi_bound, world_border_negative.z + poi_bound)
	var dist_to_positive_border = (positive_border - pos) / vec
	var dist_to_negative_border = (-negative_border + pos) / -vec
	
	print(positive_border,negative_border)
	
	print("dist to pos, neg: " + str(dist_to_positive_border) + " " + str(dist_to_negative_border))
	print("double check: " + str(pos + (dist_to_positive_border * vec)) + ", " + str(pos - (dist_to_negative_border * vec)))
	
	#Sort diatances between positive and negative
	var all_values = [dist_to_positive_border.x,dist_to_negative_border.x,dist_to_positive_border.y,dist_to_negative_border.y]
	var positive_values = []
	var negative_values = []
	for x in all_values:
		if x > 0:
			positive_values.append(x)
		elif x < 0:
			negative_values.append(x)
	
	#Return the largest negative and smallest positive
	var smallest_positive = 0 if positive_values.is_empty() else positive_values.min()
	var largest_negative = 0 if negative_values.is_empty() else negative_values.max()
	return [largest_negative,smallest_positive]
	

func generate_poi_vector(rng:RandomNumberGenerator,pos_a:Vector3,pos_b:Vector3) -> Vector3:
	var pos_a_v2 = Vector2(pos_a.x,pos_a.z)
	var pos_b_v2 = Vector2(pos_b.x,pos_b.z)
	
	var dist = rng.randf_range(min_poi_dist_ratio,max_poi_dist_ratio)
	var interm_pos = (pos_a_v2 * dist) + (pos_b_v2 * (1 - dist))
	var interm_vector = (pos_a - pos_b).normalized()
	var perp_interm_vector = Vector2(interm_vector.z,-interm_vector.x)
	var perp_dist_bounds = calculate_vector_map_bounds(interm_pos,perp_interm_vector)
	var added_vector = perp_interm_vector * rng.randf_range(perp_dist_bounds[0],perp_dist_bounds[1])
	var result_vector = interm_pos + added_vector
	print("Placed at " + str(result_vector) + " with min and max " + str(perp_dist_bounds) + " and added vector " + str(added_vector / perp_interm_vector,perp_interm_vector) + " at dist " + str(dist))
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
