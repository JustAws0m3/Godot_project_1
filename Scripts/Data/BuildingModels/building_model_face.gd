class_name BuildingModelFace

var offset: Vector3
var vectorx: Vector3
var vectory: Vector3
var points: Array[Vector2]
var world_points: Array[Vector3]
var touching: Array[BuildingModelFace]

func _init(offset:Vector3,vectorx:Vector3,vectory:Vector3,points:Array[Vector2]) -> void:
	if vectorx.dot(vectory) != 0:
		push_error("Vectors must be perpendicular")
	
	self.offset = offset
	self.vectorx = vectorx.normalized().abs()
	self.vectory = vectory.normalized().abs()
	self.points = points
	self.touching = []
	self.world_points = calculate_world_points()
	
	
	
func calculate_world_points() -> Array[Vector3]:
	var result = []
	for point in points:
		result.append(Vector3(
			offset.x + vectorx.x * point.x + vectory.x * point.y,
			offset.y + vectorx.y * point.x + vectory.y * point.y,
			offset.z + vectorx.z * point.x + vectory.z * point.y
		))
	return result
	
