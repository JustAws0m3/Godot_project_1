extends Unpacker

const STATIC_BOX : PackedScene = preload("uid://cx7im3ai1vqkn")
const PATH : PackedScene = preload("uid://bmtu2j0njtlvr")

const RED = preload("uid://8nfabsfre24")
const BLUE = preload("uid://cmmc4juj1a1kd")
const GREEN = preload("uid://di5vgqcoebvue")
const BLACK = preload("uid://cqnjj0rlirarr")

#Map paramaters
##Determines the size of the map
@export var map_size := Vector3(200,30,150)
##Determines the heights at which the pois will spawn
@export var poi_height_noise := FastNoiseLite.new()

#Spawn Paramaters
## The minimum distance the spawns can be from the back of the map (incluscive)
@export var spawn_dist_min := 15
## The maximum distance the spawns can be from the back of the map (incluscive)
@export var spawn_dist_max := 30
## The maximum distance the spawns can be from the sides of the map
@export var spawn_bound := 20

#Point paramaters
##The number of main pois to generate
@export var n_pois := 3
##The distence main pois must be from the edge of the map
@export var poi_bound = 20
##The minimum distance at which pois will generate from spawn a in relation to distance between the spawns
@export_range(0,1.0,0.001) var min_poi_dist := 0.3
##The maximum distance at which pois will generate from spawn a in relation to distance between the spawns
@export_range(0,1.0,0.001) var max_poi_dist := 0.7
##The variance in how the pois will generate along the axis between spawns
@export_range(0,1.0,0.001) var poi_dist_variance := 0.1
##The minimum distance at which pois will generate on the axis perpendicular to the axis between spawns
@export_range(0,1.0,0.001) var min_poi_hor_dist := 0.1
##The maximum distance at which pois will generate on the axis perpendicular to the axis between spawns
@export_range(0,1.0,0.001) var max_poi_hor_dist := 0.9
##The variance in how the pois will generate along the axis perpendicular to the axis between spawns
@export_range(0,1.0,0.001) var poi_hor_dist_variance := 0.25
##If true, flip the pois horizontally
@export var poi_flip_hor := false
##If true, shufffle the horizontal positions of pois
@export var poi_shuffle_hor := false

#Unrelated point paramaters
##The minimum number of unrelated pois to generate (incluscive)
@export var min_unrelated_poi := 1
##The maximum number of unrelated pois to generate (incluscive)
@export var max_unrelated_poi := 3
##The distence unrelated pois must be from the edge of the map
@export var unrelated_poi_bound := 20
##The distance each unrelated poi must be from other points. If a place can't be found for a point, it won't be placed
@export var unrelated_poi_dist_from_other_points := 30
##The amount of attempts the generator will make at placing unrelated pois before giving up
@export var unrelated_poi_placement_attempts := 300

#Unpacker stuff
##The unpackers to unpack next
@export var next_unpack: Array[Unpacker]

var world_border_positive
var world_border_negative

class BoxDistanceData:
	var box_a: Node3D
	var box_b: Node3D
	var distance: float
	
	func _init(box_a:Node3D,box_b:Node3D,distance:float):
		self.box_a = box_a
		self.box_b = box_b
		self.distance = distance
	
func place_point(pos:Vector3,material:StandardMaterial3D,point_name:String) -> Node3D:
	var point = STATIC_BOX.instantiate() as Node3D
	point.position = pos
	point.name = point_name
	var point_mesh = point.get_node("./MeshInstance3D") as MeshInstance3D
	point_mesh.material_override = material
	if base_node:
		base_node.call_deferred("add_child",point)
	return point
	
	
#Method for placing spawn points
func place_spawns(rng:RandomNumberGenerator) -> Array[Node3D]:	
	var x_offset = rng.randf_range(spawn_dist_min,spawn_dist_max)
	var z_offset = rng.randf_range(world_border_negative.z + spawn_bound, world_border_positive.z - spawn_bound)
	
	var spawn_a_x = world_border_negative.x + x_offset
	var spawn_a_z = z_offset
	var spawn_b_x = world_border_positive.x - x_offset
	var spawn_b_z = -z_offset
	
	var spawn_point_a_pos = Vector3(
		spawn_a_x,
		poi_height_noise.get_noise_2d(spawn_a_x,spawn_a_z) * map_size.y / 2,
		spawn_a_z
	)
	var spawn_point_b_pos = Vector3(
		spawn_b_x,
		poi_height_noise.get_noise_2d(spawn_b_x,spawn_b_z) * map_size.y / 2,
		spawn_b_z
	)
	
	var spawn_point_a = place_point(spawn_point_a_pos,RED,"SpawnA")
	var spawn_point_b = place_point(spawn_point_b_pos,BLUE,"SpawnB")
	
	return [spawn_point_a,spawn_point_b]

#Gets the maximum positive and negative distances you can travel along a vector from a point without going out of bounds
func calculate_vector_map_bounds(pos:Vector2,vec:Vector2) -> Array[float]:
	#Calculate thbe distance needed to travel from pos along the vector to reach the world border
	var positive_border = Vector2(world_border_positive.x - poi_bound, world_border_positive.z - poi_bound)
	var negative_border = Vector2(world_border_negative.x + poi_bound, world_border_negative.z + poi_bound)
	var dist_to_positive_border = (positive_border - pos) / vec
	var dist_to_negative_border = (-negative_border + pos) / -vec
	
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

#Return a uniformily random number between min_v and max_v within the range of base +- variance
func clamped_uniform_randf_range(rng:RandomNumberGenerator,min_v:float,max_v:float,base:float,variance:float):
	return rng.randf_range(max(min_v,base - variance),min(max_v,base + variance))

#Generate a place to put a random poi
func generate_poi_vector(rng:RandomNumberGenerator,pos_a:Vector3,pos_b:Vector3,base_dist:float,hor_base_dist:float) -> Vector3:
	var pos_a_v2 = Vector2(pos_a.x,pos_a.z)
	var pos_b_v2 = Vector2(pos_b.x,pos_b.z)
	
	#Determine the distance to place the poi at from the first spawn point
	var dist = clamped_uniform_randf_range(rng,min_poi_dist,max_poi_dist,base_dist,poi_dist_variance)
	
	#Get the vector parallel to vector between the two spawn points (perp is for perpendicular)
	var interm_pos = (pos_a_v2 * dist) + (pos_b_v2 * (1 - dist))
	var interm_vector = (pos_a - pos_b).normalized()
	var perp_interm_vector = Vector2(interm_vector.z,-interm_vector.x)
	
	#Calculate the horizontal distance along the vector to place the point at
	var perp_dist_bounds = calculate_vector_map_bounds(interm_pos,perp_interm_vector)
	var hor_position_unscaled = clamped_uniform_randf_range(rng,min_poi_hor_dist,max_poi_hor_dist,hor_base_dist,poi_hor_dist_variance)
	var hor_position = (perp_dist_bounds[1] - perp_dist_bounds[0]) * hor_position_unscaled + perp_dist_bounds[0]
	var added_vector = perp_interm_vector * hor_position
	
	#Calculate the distance along the vector to place the point at
	var result_vector = interm_pos + added_vector
	return Vector3(result_vector.x,
	poi_height_noise.get_noise_2d(result_vector.x,result_vector.y) * map_size.y / 2,
	result_vector.y)

#Get evenly spaced numbers between a and b in an array, incluscive
func get_evenly_spaced_numbers(a: float, b: float, n: int) -> Array[float]:
	var result_array: Array[float] = []
	if n <= 0:
		result_array.push_back((a + b) / 2)
		return result_array

	if n == 1:
		result_array.push_back(a)
		result_array.push_back(b)
		return result_array

	var step_size: float = (b - a) / (n - 1)
	for i in range(n):
		result_array.push_back(a + (i * step_size))
	return result_array
	
#Shuffle the array with a specified rng
func custom_shuffle(rng: RandomNumberGenerator, array_to_shuffle: Array) -> void:
	var n = array_to_shuffle.size()
	for i in range(n - 1, 0, -1):
		# Pick a random index from 0 to i
		var j = rng.randi_range(0, i)
		# Swap array_to_shuffle[i] with the element at random index j
		var temp = array_to_shuffle[i]
		array_to_shuffle[i] = array_to_shuffle[j]
		array_to_shuffle[j] = temp

#Generate points for pois
func generate_poi_points(rng:RandomNumberGenerator,spawn_a:Vector3,spawn_b:Vector3) -> Array[Node3D]:
	var result: Array[Node3D] = []
	
	#Determine point base placement
	var poi_dists = get_evenly_spaced_numbers(min_poi_dist,max_poi_dist,n_pois)
	var poi_hor_dists = get_evenly_spaced_numbers(min_poi_hor_dist,max_poi_hor_dist,n_pois)
	
	#Handle horizontal poi paramaters
	if poi_shuffle_hor:
		custom_shuffle(rng,poi_hor_dists)
	elif poi_flip_hor:
		poi_hor_dists.reverse()
	
	#Determine final positions and place the points
	for i in range(n_pois):
		var new_vector = generate_poi_vector(rng,spawn_a,spawn_b,poi_dists[i],poi_hor_dists[i])
		var new_point = place_point(new_vector,GREEN,"Poi")
		result.append(new_point)
	return result;

#Method for asking if placement of an unrelated point is valid
func is_unrelated_poi_placement_valid(proposal:Vector3, points:Array[Node3D]) -> bool:
	for point in points:
		if proposal.distance_to(point.position) <= unrelated_poi_dist_from_other_points:
			return false
	return true

#Generate points unrelated to objectives
func generate_unrelated_poi_points(rng:RandomNumberGenerator, points:Array[Node3D]) -> Array[Node3D]:
	points = points.duplicate()
	var result :Array[Node3D]  = []
	var n_points = rng.randi_range(min_unrelated_poi,max_unrelated_poi)
	for i in range(unrelated_poi_placement_attempts):
		var proposal_x = rng.randf_range(world_border_positive.x - unrelated_poi_bound,world_border_negative.x + unrelated_poi_bound)
		var proposal_z = rng.randf_range(world_border_positive.z - unrelated_poi_bound,world_border_negative.z + unrelated_poi_bound)
		var proposal := Vector3(
			proposal_x,
			poi_height_noise.get_noise_2d(proposal_x,proposal_z) * map_size.y / 2,
			proposal_z
		)
		if is_unrelated_poi_placement_valid(proposal,points):
			var point := place_point(proposal,BLACK,"UnrelatedPoi")
			points.append(point)
			result.append(point)
		if result.size() >= n_pois:
			return result
	return result
			
		

func unpack() -> Array[Unpacker]:
	# Declare basic variables
	world_border_positive = map_size / 2
	world_border_negative = -map_size / 2
	
	var point = place_point(Vector3(0,-30,0),RED,"Bottom")
	point.scale = Vector3(map_size.x,1,map_size.z)
	
	poi_height_noise.seed = seed
	
	# Initialize rng
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	
	# Place Spawns
	var spawns = place_spawns(rng)
	var pois = generate_poi_points(rng,spawns[0].position,spawns[1].position)
	var spawns_and_pois = spawns.duplicate() + pois.duplicate()
	var unrelated = generate_unrelated_poi_points(rng,spawns_and_pois)
	
	return next_unpack
