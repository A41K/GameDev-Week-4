extends Node2D

@export var level_chunks: Array[PackedScene]
@export var chunk_width: float = 1152.0
@export var spawn_amount: int = 3 
@export var cleanup_distance: float = 2500.0 

var active_chunks: Array[Node2D] = []
var next_spawn_x: float = 0.0

@onready var player: Node2D = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	if not is_instance_valid(player):
		return
		
	if not level_chunks.is_empty():
		var temp_chunk = level_chunks[0].instantiate()
		for child in temp_chunk.get_children():
			if child is TileMapLayer:
				var rect = child.get_used_rect()
				var cell_size = child.tile_set.tile_size.x
				chunk_width = float(rect.size.x * cell_size)
				print("Auto-calculated chunk width: ", chunk_width)
				break
		temp_chunk.queue_free()
		
	var main_tilemap = get_node_or_null("../TileMapLayer")
	if main_tilemap and main_tilemap is TileMapLayer:
		var rect = main_tilemap.get_used_rect()
		if rect.size.x > 0:
			var cell_size = main_tilemap.tile_set.tile_size.x
			next_spawn_x = float(rect.position.x + rect.size.x) * cell_size
			print("Starting endless generation right after main area at X = ", next_spawn_x)
		else:
			next_spawn_x = player.global_position.x - chunk_width
	else:
		next_spawn_x = player.global_position.x - chunk_width
		
	for i in range(spawn_amount + 1):
		spawn_chunk()

func _process(_delta: float) -> void:
	if not is_instance_valid(player):
		return

	while player.global_position.x + (chunk_width * spawn_amount) > next_spawn_x:
		spawn_chunk()

	if active_chunks.size() > 0:
		var oldest_chunk = active_chunks[0]
		if is_instance_valid(oldest_chunk):
			if player.global_position.x - oldest_chunk.global_position.x > cleanup_distance:
				oldest_chunk.queue_free()
				active_chunks.pop_front()
		else:
			active_chunks.pop_front() 

func spawn_chunk() -> void:
	if level_chunks.is_empty():
		push_error("No level chunks assigned to LevelController!")
		return
		
	var random_chunk: PackedScene = level_chunks.pick_random()
	var chunk_instance: Node2D = random_chunk.instantiate() as Node2D
	
	var x_offset: float = 0.0

	for child in chunk_instance.get_children():
		if child is TileMapLayer:
			var rect = child.get_used_rect()
			var cell_size = child.tile_set.tile_size.x
			x_offset = float(rect.position.x * cell_size)
			chunk_width = float(rect.size.x * cell_size)
			break

	chunk_instance.global_position = Vector2(next_spawn_x - x_offset, 0)
	
	add_child(chunk_instance)
	active_chunks.append(chunk_instance)
	
	next_spawn_x += chunk_width
