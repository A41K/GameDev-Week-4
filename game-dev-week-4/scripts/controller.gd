extends Node2D

@export var level_chunks: Array[PackedScene]
@export var chunk_width: float = 1152.0
@export var spawn_amount: int = 3 

var active_chunks: Dictionary = {}
var chunk_layouts: Dictionary = {}
var start_x: float = 0.0

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
			start_x = float(rect.position.x + rect.size.x) * cell_size
			print("Starting endless generation right after main area at X = ", start_x)
		else:
			start_x = player.global_position.x - chunk_width
	else:
		start_x = player.global_position.x - chunk_width
		
	update_chunks()

func _process(_delta: float) -> void:
	if not is_instance_valid(player):
		return
	update_chunks()

func update_chunks() -> void:
	if level_chunks.is_empty():
		return
		
	var player_chunk_index = floor((player.global_position.x - start_x) / chunk_width)
	
	var desired_chunks = []
	for i in range(-spawn_amount, spawn_amount + 1):
		desired_chunks.append(int(player_chunk_index) + i)
		
	# Unload far away chunks
	var keys_to_remove = []
	for chunk_idx in active_chunks.keys():
		if not chunk_idx in desired_chunks:
			if is_instance_valid(active_chunks[chunk_idx]):
				active_chunks[chunk_idx].queue_free()
			keys_to_remove.append(chunk_idx)
			
	for k in keys_to_remove:
		active_chunks.erase(k)
		
	# Load needed chunks
	for chunk_idx in desired_chunks:
		# Don't spawn chunks from before the start point
		if chunk_idx < 0:
			continue
			
		if not active_chunks.has(chunk_idx):
			spawn_chunk(chunk_idx)

func spawn_chunk(chunk_idx: int) -> void:
	if not chunk_layouts.has(chunk_idx):
		# Assign a random layout index for this chunk so it's persistent
		chunk_layouts[chunk_idx] = randi() % level_chunks.size()
		
	var layout_idx = chunk_layouts[chunk_idx]
	var chunk_scene: PackedScene = level_chunks[layout_idx]
	var chunk_instance: Node2D = chunk_scene.instantiate() as Node2D
	
	var x_offset: float = 0.0

	for child in chunk_instance.get_children():
		if child is TileMapLayer:
			var rect = child.get_used_rect()
			var cell_size = child.tile_set.tile_size.x
			x_offset = float(rect.position.x * cell_size)
			# Only update chunk width if this is the first chunk or we need correction
			if chunk_width == 0:
				chunk_width = float(rect.size.x * cell_size)
			break

	chunk_instance.global_position = Vector2(start_x + (chunk_idx * chunk_width) - x_offset, 0)
	
	add_child(chunk_instance)
	active_chunks[chunk_idx] = chunk_instance
