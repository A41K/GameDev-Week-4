extends TextureProgressBar

var player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Add a small delay to ensure the player has loaded into the "player" group
	await get_tree().process_frame 
	
	player = get_tree().get_first_node_in_group("player")
	if player:
		# Update max value and the current value initially
		max_value = player.max_health
		value = player.current_health
		# Connect to the signal to only update when health changes
		player.health_changed.connect(_on_player_health_changed)

func _on_player_health_changed(current_health: int, max_health: int) -> void:
	max_value = max_health
	value = current_health
