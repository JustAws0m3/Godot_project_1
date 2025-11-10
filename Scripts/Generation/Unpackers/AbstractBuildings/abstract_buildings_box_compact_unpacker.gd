extends Unpacker

@export var models: Array[AbstractRoomTemplate]

func unpack() -> Array[Unpacker]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	
	return []
