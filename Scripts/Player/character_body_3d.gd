extends CharacterBody3D

@onready var rotator_y: Node3D = $RotatorY
@onready var rotator_x: Node3D = $RotatorY/RotatorX

#Player Speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 10.0
const JUMP_VELOCITY = 4.5

#Camera Rotation
const CAMERA_ROTATION_FACTOR = -0.01
const CAMERA_ROTATION_X_MAX = 2
const CAMERA_ROTATION_X_MIN = -2

var mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	Input.mouse_mode = mouse_mode

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("Jump") and is_on_floor():
	if Input.is_action_just_pressed("Jump"):
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Forwards", "Backwards")
	var direction_x = input_dir.x * Vector3(cos(rotator_y.rotation.y), 0, -sin(rotator_y.rotation.y))
	var direction_y = input_dir.y * Vector3(sin(rotator_y.rotation.y), 0, cos(rotator_y.rotation.y))
	var direction := (transform.basis * (direction_x + direction_y)).normalized()
	
	# Process speed
	var speed = SPRINT_SPEED if Input.is_action_pressed("Sprint") else WALK_SPEED
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	
	
func _input(event):
	#Handle Rotation
	if event is InputEventMouseMotion:
		var relative_motion = event.relative
		rotator_y.rotate_y(relative_motion.x * CAMERA_ROTATION_FACTOR)
		rotator_x.rotate_x(relative_motion.y * CAMERA_ROTATION_FACTOR)
		rotator_x.rotation.x = clamp(rotator_x.rotation.x,CAMERA_ROTATION_X_MIN,CAMERA_ROTATION_X_MAX)
	#Handle key presses
	if event is InputEventKey and event.pressed:
		if event.is_action_pressed("Debug"):
			if mouse_mode == Input.MOUSE_MODE_CAPTURED:
				mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				mouse_mode = Input.MOUSE_MODE_CAPTURED
			Input.mouse_mode = mouse_mode
		if event.is_action_pressed("Refresh"):
			position = Vector3(0,0,0)
		
