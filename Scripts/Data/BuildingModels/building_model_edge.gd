class_name BuildingModelEdge

var pos_1: Vector3
var pos_2: Vector3
var pos_3: Vector3
var pos_4: Vector3
var touching: Array[BuildingModelEdge]

func _init(pos_1:Vector3,pos_2:Vector3,pos_3:Vector3,pos_4:Vector3) -> void:
	self.pos_1 = pos_1
	self.pos_2 = pos_2
	self.pos_3 = pos_3
	self.pos_4 = pos_4
	self.touching = []
	
