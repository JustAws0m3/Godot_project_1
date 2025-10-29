extends Unpacker

const STATIC_BOX : PackedScene = preload("uid://cx7im3ai1vqkn")
const PATH : PackedScene = preload("uid://bmtu2j0njtlvr")

const RED = preload("uid://8nfabsfre24")
const BLUE = preload("uid://cmmc4juj1a1kd")
const GREEN = preload("uid://di5vgqcoebvue")

#Map paramaters
@export var MAP_SIZE := Vector3(300,30,150)

#Spawn Paramaters
@export var SPAWN_DIST_MIN := 15
@export var SPAWN_DIST_MAX := 30
@export var SPAWN_BOUND := 20

#Point paramaters
@export var N_POINTS := 3

var WORLD_BORDER_POSITIVE = MAP_SIZE / 2
var WORLD_BORDER_NEGATIVE = -MAP_SIZE / 2

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
	point_mesh = point.get_node("./MeshInstance3D") as MeshInstance3D
	point_mesh.material_override = material
	return point
	
	
#Method for placing spawn points
func place_spawns(rng:RandomNumberGenerator) -> Array[Node3D]:	
	var spawn_point_a_pos = Vector3(
		WORLD_BORDER_NEGATIVE.x + rng.randf_range(SPAWN_DIST_MIN,SPAWN_DIST_MAX),
		0,
		rng.randf_range(WORLD_BORDER_NEGATIVE.z + SPAWN_BOUND, WORLD_BORDER_POSITIVE.z - SPAWN_BOUND)
	)
	var spawn_point_b_pos = Vector3(
		WORLD_BORDER_POSITIVE.x - rng.randf_range(SPAWN_DIST_MIN,SPAWN_DIST_MAX),
		0,
		rng.randf_range(WORLD_BORDER_NEGATIVE.z + SPAWN_BOUND, WORLD_BORDER_POSITIVE.z - SPAWN_BOUND)
	)
	
	var spawn_point_a = place_point(spawn_point_a_pos,RED)
	var spawn_point_b = place_point(spawn_point_b_pos,BLUE)

func place_points() -> Array[Node3D]:
	var points = []
		
	return points

func unpack() -> Array[Unpacker]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	
	# Place Spawns
	place_spawns(rng)
	
	return []
