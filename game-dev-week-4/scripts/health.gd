extends TextureProgressBar

var player = null

func _ready() -> void:
	await get_tree().process_frame 
	
	player = get_tree().get_first_node_in_group("player")
	if player:
		max_value = player.max_health
		value = player.current_health
		player.health_changed.connect(_on_player_health_changed)

func _on_player_health_changed(current_health: int, max_health: int) -> void:
	max_value = max_health
	value = current_health
