extends Node
## Genera las capturas del README instanciando cada pantalla sin ventana aparte.
## Uso: DISPLAY=:0 godot --path . res://tests/shots.tscn

const DIR := "res://docs/screenshots"


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIR))
	await _shot("res://scenes/main_menu.tscn", "01-menu")

	GameState.reset_run()
	await _game_shot("02-nivel-1", 0, false, 3)

	GameState.reset_run()
	await _game_shot("03-nivel-2", 1, true, 2)

	GameState.level_index = 1
	GameState.hearts = 0
	GameState.won = false
	await _shot("res://scenes/end_screen.tscn", "04-game-over")

	await _shot("res://scenes/credits.tscn", "05-creditos")

	print("capturas listas")
	get_tree().quit()


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _shot(path: String, shot_name: String) -> void:
	var inst: Node = load(path).instantiate()
	add_child(inst)
	await _frames(20)
	await _save(shot_name)
	inst.queue_free()
	await _frames(2)


func _game_shot(shot_name: String, level: int, with_key: bool, hearts: int) -> void:
	GameState.level_index = level
	GameState.hearts = hearts
	GameState.has_key = false
	var inst: Node2D = load("res://scenes/game.tscn").instantiate()
	add_child(inst)
	await _frames(6)
	var player: Node2D = inst.get("player")
	if with_key:
		var key: Node2D = inst.get_node_or_null("key_item")
		if player and key:
			player.global_position = key.global_position
			await _frames(6)
	var door: Node2D = inst.get_node_or_null("door")
	if player and door:
		player.global_position = door.global_position + Vector2(-26, 0)
	inst.call("show_hint", "NIVEL %d  ·  BUSCA LA LLAVE" % (level + 1))
	await _frames(20)
	await _save(shot_name)
	inst.queue_free()
	await _frames(2)


func _save(shot_name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png("%s/%s.png" % [DIR, shot_name])
	print("  captura: %s (%dx%d)" % [shot_name, img.get_width(), img.get_height()])
