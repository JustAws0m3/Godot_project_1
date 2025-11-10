extends Unpacker

@export var models: Array[AbstractRoomTemplate]

#Steps
#1: Place main room
#2: Place 1-2 hallways from main room (in different directions)
#3: Attatch stairways to hallways and add hallways above hallways
#4: Attatch smaller rooms to hallways and main room (Maybe even create another large room off of hallways or large room)

func unpack() -> Array[Unpacker]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	
	return []
