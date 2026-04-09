extends CharacterBody2D

@export var move_speed: float = 180.0


func _physics_process(_delta: float) -> void:
	var input_vector := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)

	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()

	velocity = input_vector * move_speed
	move_and_slide()
