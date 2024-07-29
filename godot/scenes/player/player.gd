extends CharacterBody3D


var input_dir := Vector2.ZERO

var current_speed = 0.0

@export var walk_speed := 5.0
@export var run_speed := 8.0
@export var crouch_speed := 3.0
@export var acceleration_speed := 2.0

@export var jump_velocity := 4.5

var mouse_rel := Vector2.ZERO
@export var mouse_sensitivity := 0.1


@onready var head := $Head


func _ready() -> void:
	current_speed = walk_speed
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Handle move type
	if Input.is_action_pressed("sprint"):
		current_speed = run_speed
	elif Input.is_action_pressed("crouch"):
		current_speed = crouch_speed
	else:
		current_speed = walk_speed
	
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	# Handle camera
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and is_on_floor():
		velocity.x = lerp(velocity.x, direction.x * -current_speed, delta * acceleration_speed)
		velocity.z = lerp(velocity.z, direction.z * -current_speed, delta * acceleration_speed)
	elif is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, delta * acceleration_speed)
		velocity.z = lerp(velocity.z, 0.0, delta * acceleration_speed)

	move_and_slide()
