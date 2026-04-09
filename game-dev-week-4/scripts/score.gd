extends Control

func _ready() -> void:
	EventController.coin_collected.connect(_on_coin_collected)
	_update_label(GameController.total_coins)

func _on_coin_collected(value: int) -> void:
	_update_label(value)

func _update_label(value: int) -> void:
	var text_val = str(value)
	
	if has_node("Label"):
		$Label.text = text_val
	else:
		for child in get_children():
			if child is Label:
				child.text = text_val
				break
