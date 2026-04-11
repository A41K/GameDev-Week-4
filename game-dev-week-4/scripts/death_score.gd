extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = "Score: " + str(GameController.total_coins)
	add_theme_color_override("font_color", Color.GOLD)
