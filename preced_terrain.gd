@tool
extends MeshInstance3D

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
		

func update_mesh():
	var plane = PlaneMesh.new()
	plane.subdivide_depth = resolution
	plane.subdivide_width = resolution
	plane.size = Vector2(size_x,size_y)
	
	var plane_arrays := plane.get_mesh_arrays()
	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,plane_arrays)
	mesh = array_mesh
	
