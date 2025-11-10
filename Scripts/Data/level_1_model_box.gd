extends Node3D
class_name Level1ModelBox

const STATIC_BOX : PackedScene = preload("uid://cx7im3ai1vqkn")
const GREEN = preload("uid://di5vgqcoebvue")

@export var generate_box: bool

var positive_point : Vector3
var negative_point : Vector3
var points : Array[Vector3]
var edges : Array[Level1ModelEdge]


func _init() -> void:
	positive_point = self.position + (self.scale / 2)
	negative_point = self.position - (self.scale / 2)

	points = [
		negative_point,
		Vector3(negative_point.x,negative_point.y,positive_point.z),
		Vector3(negative_point.x,positive_point.y,negative_point.z),
		Vector3(negative_point.x,positive_point.y,positive_point.z),
		Vector3(positive_point.x,negative_point.y,negative_point.z),
		Vector3(positive_point.x,negative_point.y,positive_point.z),
		Vector3(positive_point.x,positive_point.y,negative_point.z),
		negative_point
	]

	edges = [
		Level1ModelEdge.new(points[0],points[1],points[2],points[3]),
		Level1ModelEdge.new(points[4],points[5],points[6],points[7]),
		Level1ModelEdge.new(points[0],points[1],points[4],points[5]),
		Level1ModelEdge.new(points[2],points[3],points[6],points[7]),
		Level1ModelEdge.new(points[0],points[2],points[4],points[6]),
		Level1ModelEdge.new(points[1],points[3],points[5],points[7]),
	]

func _enter_tree() -> void:
	if generate_box:
		place_point(Vector3.ZERO,GREEN,"Blockout")

func place_point(pos:Vector3,material:StandardMaterial3D,point_name:String) -> Node3D:
	var point = STATIC_BOX.instantiate() as Node3D
	point.position = pos
	point.name = point_name
	var point_mesh = point.get_node("./MeshInstance3D") as MeshInstance3D
	point_mesh.material_override = material
	add_child(point)
	return point
