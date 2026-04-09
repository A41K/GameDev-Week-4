extends Node

var total_coins: int = 0
var saved_coins: int = 0
var respawn_position: Vector2
var has_respawn_point: bool = false

func save_coins():
	saved_coins = total_coins

func reset_coins():
	total_coins = saved_coins
	# Emit signal if we need UI to update when reset occurs
	EventController.emit_signal("coin_collected", total_coins)

func coin_collected(value: int):
	total_coins += value
	EventController.emit_signal("coin_collected", total_coins)

func set_respawn_point(position: Vector2) -> void:
	respawn_position = position
	has_respawn_point = true

func get_respawn_point(default_position: Vector2) -> Vector2:
	if has_respawn_point:
		return respawn_position
	return default_position

func clear_respawn_point() -> void:
	has_respawn_point = false
