extends Area2D

@onready var checkpoint_label: Label = get_node_or_null("Label")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if checkpoint_label:
		checkpoint_label.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if checkpoint_label:
			checkpoint_label.visible = true
		GameController.set_respawn_point(global_position)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and checkpoint_label:
		checkpoint_label.visible = false
