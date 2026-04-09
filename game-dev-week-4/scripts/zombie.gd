extends CharacterBody2D

enum State { IDLE, CHASE, ATTACK }

@export var speed: float = 50.0
@export var detection_range: float = 300.0
@export var max_health: int = 3
@export var damage: int = 1
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 2.5

var current_state: State = State.IDLE
var current_health: int
var time_since_last_attack: float = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var player: Node2D = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	add_to_group("enemy")
	current_health = max_health

func _physics_process(delta: float) -> void:
	if current_health <= 0 or not is_instance_valid(player):
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	var distance_to_player = global_position.distance_to(player.global_position)
	time_since_last_attack += delta
	
	# Handle State Machine Updates
	_update_state(distance_to_player)
	_handle_state()
	
	move_and_slide()

func _update_state(distance: float) -> void:
	match current_state:
		State.IDLE:
			if distance <= detection_range:
				current_state = State.CHASE
		State.CHASE:
			if distance <= attack_range:
				current_state = State.ATTACK
			elif distance > detection_range * 1.5: # Lose interest if player gets too far
				current_state = State.IDLE
		State.ATTACK:
			if distance > attack_range:
				current_state = State.CHASE

func _handle_state() -> void:
	match current_state:
		State.IDLE:
			# Stand still
			velocity.x = move_toward(velocity.x, 0, speed)
			
		State.CHASE:
			# Only move if the player is noticeably to the left or right
			var x_diff = player.global_position.x - global_position.x
			if abs(x_diff) > 5.0: 
				var direction = sign(x_diff)
				velocity.x = direction * speed
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
				
		State.ATTACK:
			# Stop moving and attack
			velocity.x = move_toward(velocity.x, 0, speed)
			if time_since_last_attack >= attack_cooldown:
				attack_player()
				time_since_last_attack = 0.0

	move_and_slide()

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Zombie took damage! Health: ", current_health)
	
	if current_health <= 0:
		die()

func attack_player() -> void:
	# Add logic for attacking the player here
	# For example, if the player has a take_damage method:
	if player.has_method("take_damage"):
		player.take_damage(damage)
	print("Zombie attacked player!")

func die() -> void:
	print("Zombie died!")
	queue_free()
