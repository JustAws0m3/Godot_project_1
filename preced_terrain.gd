@tool
extends MeshInstance3D

@onready var collision_shape_3d: CollisionShape3D = $StaticBody3D/CollisionShape3D

@export var size_x := 64:
	set(new_size):
		size_x = new_size
		update_mesh()

@export var size_y := 64:
	set(new_size):
		size_y = new_size
		update_mesh()

@export var resolution := 32:
	set(new_resolution):
		resolution = new_resolution
		update_mesh()
		
@export var height := 12:
	set(new_height):
		height = new_height
		update_mesh()
		
@export var noise : FastNoiseLite:
	set(new_noise):
		noise = new_noise
		update_mesh()

func get_height(pos:Vector2):
	return noise.get_noise_2dv(pos) * height

func get_normal(pos:Vector2):
	var eps_x = size_x / resolution
	var eps_y = size_y / resolution
	var x = pos.x
	var y = pos.y
	var normal := Vector3(
		(get_height(Vector2(x + eps_x,y)) - get_height(Vector2(x - eps_x,y)) / (2 * eps_x)),
		1.0,
		(get_height(Vector2(x,pos.y + eps_y)) - get_height(Vector2(x,pos.y - eps_y)) / (2 * eps_y))
	)
	return normal.normalized()
	

func update_mesh():
	var plane = PlaneMesh.new()
	plane.subdivide_depth = resolution
	plane.subdivide_width = resolution
	plane.size = Vector2(size_x,size_y)
	
	var plane_arrays := plane.get_mesh_arrays()
	var vertex_arrays: PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_VERTEX]
	var normal_arrays: PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_NORMAL]
	var tangent_arrays: PackedFloat32Array = plane_arrays[ArrayMesh.ARRAY_TANGENT]
	
	#This piece sets the height of the planes
	for i in range(vertex_arrays.size()):
		var vertex := vertex_arrays[i]
		var normal := Vector3.UP
		var tangent := Vector3.RIGHT
		if noise:
			vertex.y = get_height(Vector2(vertex.x,vertex.z))
			normal = get_normal(Vector2(vertex.x,vertex.z))
			tangent = vertex.cross(Vector3.UP)
		vertex_arrays[i] = vertex
		normal_arrays[i] = normal
		for j in range(3):
			tangent_arrays[(4 * i) + j] = tangent[j]
		
	# Process mesh shape
	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,plane_arrays)
	
	# Process collision shape
	var collision_node_name := "./StaticBody3D/CollisionShape3D"
	if has_node(collision_node_name):
		var collision_shape_3d = get_node(collision_node_name) as CollisionShape3D
		var collider_shape = ConcavePolygonShape3D.new()
		collider_shape.set_faces(array_mesh.get_faces())
		collision_shape_3d.shape = collider_shape
	
	mesh = array_mesh
	
