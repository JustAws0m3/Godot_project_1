extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_terrain()
	pass # Replace with function body.

func generate_terrain():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_color(Color(1, 0, 0))
	st.set_uv(Vector2(0,0))
	st.add_vertex(Vector3(0, 0, 0))
	st.add_vertex(Vector3(0, -3, 0))
	st.add_vertex(Vector3(0, -3, -3))
	
	var arrm = st.commit()
	var m = MeshInstance3D.new()
	m.mesh = arrm
	add_child(m)
	print("Generated Terrain")
