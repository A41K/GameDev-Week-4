extends CharacterBody2D

enum State { IDLE, CHASE, ATTACK }

@export var speed: float = 50.0
@export var detection_range: float = 300.0
@export var max_health: int = 3
@export var damage: int = 1
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 1.5

var current_state: State = State.IDLE
var current_health: int
var time_since_last_attack: float = 0.0

var knockback_velocity: Vector2 = Vector2.ZERO

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var player: Node2D = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	add_to_group("enemy")
	current_health = max_health
	z_index = 5 # Ensure zombie draws on top of newer level chunks

func _physics_process(delta: float) -> void:
	if current_health <= 0 or not is_instance_valid(player):
		return
		
	if not is_on_floor():
		velocity.y += gravity * delta

	var distance_to_player = global_position.distance_to(player.global_position)
	time_since_last_attack += delta
	
	_update_state(distance_to_player)
	_handle_state()

func _update_state(distance: float) -> void:
	match current_state:
		State.IDLE:
			if distance <= detection_range:
				current_state = State.CHASE
		State.CHASE:
			if distance <= attack_range:
				current_state = State.ATTACK
			elif distance > detection_range * 1.5: 
				current_state = State.IDLE
		State.ATTACK:
			if distance > attack_range:
				current_state = State.CHASE

func _handle_state() -> void:
	match current_state:
		State.IDLE:
			velocity.x = move_toward(velocity.x, 0, speed)
			
		State.CHASE:
			var x_diff = player.global_position.x - global_position.x
			if abs(x_diff) > 5.0: 
				var direction = sign(x_diff)
				velocity.x = direction * speed
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
				
		State.ATTACK:
			velocity.x = move_toward(velocity.x, 0, speed)
			if time_since_last_attack >= attack_cooldown:
				attack_player()
				time_since_last_attack = 0.0

	if knockback_velocity.x != 0:
		velocity.x = knockback_velocity.x
		knockback_velocity.x = move_toward(knockback_velocity.x, 0, 1500 * get_physics_process_delta_time())

	move_and_slide()

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	current_health -= amount
	print("Zombie took damage! Health: ", current_health)
	
	if knockback != Vector2.ZERO:
		knockback_velocity = knockback
		velocity = knockback
		
	current_state = State.IDLE 
	time_since_last_attack = 0.0
	
	if current_health <= 0:
		die()

func attack_player() -> void:
	if player.has_method("take_damage"):
		var direction_vector = (player.global_position - global_position).normalized()
		var knockback_force = Vector2(direction_vector.x * 250.0, -200.0)
		player.take_damage(damage, knockback_force)
	print("Zombie attacked player!")

func die() -> void:
	print("Zombie died!")
	GameController.coin_collected(1)
	queue_free()
