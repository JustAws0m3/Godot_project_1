extends Unpacker

@export var models: Array[AbstractRoomTemplate]
@export var area_min := 100.0
@export var area_max := 1000.0

# Variable to store the accumulated weights of the models
var models_max_waights = calculate_models_max_weights()

func calculate_models_max_weights():
	var result = []
	var current_weight = 0.0
	for model in models:
		current_weight += model.weight
		result.append(current_weight)
	return result
	
func pick_template(weight:float):
	for i in range(len(models_max_waights)):
		if weight < models_max_waights[i]:
			return models[i]

func pick_next_template(rng:RandomNumberGenerator) -> AbstractRoomTemplate:
	var chosen_weight = rng.randf_range(0,models_max_waights[-1])
	var template_to_pick = pick_next_template(chosen_weight) as AbstractRoomTemplate
	return template_to_pick

func unpack() -> Array[Unpacker]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	
	var final_area = rng.randf_range(area_min,area_max)
	return []
