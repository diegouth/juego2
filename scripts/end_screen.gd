extends Control
## Pantalla de fin: victoria (se cruzó la última puerta) o Game Over.
## Ofrece reintentar desde el nivel 1 o volver al menú.

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var won := GameState.won
	var title := UiKit.label("¡ESCAPASTE!" if won else "GAME OVER", 20, UiKit.GOLD if won else UiKit.RED)
	title.position = Vector2(0, 86)
	title.size = Vector2(640, 28)
	add_child(title)

	var msg := UiKit.label(
		"CRUZASTE LAS %d PUERTAS CON LA LLAVE" % GameState.level_count() if won
		else "TE QUEDASTE SIN CORAZONES",
		6, UiKit.DIM)
	msg.position = Vector2(0, 124)
	msg.size = Vector2(640, 12)
	add_child(msg)

	var level := UiKit.label("LLEGASTE AL NIVEL %d" % mini(GameState.level_index + 1, GameState.level_count()), 8, UiKit.INK)
	level.position = Vector2(0, 150)
	level.size = Vector2(640, 14)
	add_child(level)

	# Marcador final: se guarda el record en user://record.cfg.
	var is_record := GameState.commit_record()
	var marcador := UiKit.label("PUNTOS %04d" % GameState.score, 8, UiKit.GOLD)
	marcador.position = Vector2(0, 168)
	marcador.size = Vector2(640, 12)
	add_child(marcador)

	var record := UiKit.label(
		"NUEVO RECORD" if is_record else "RECORD %04d" % GameState.best_score,
		6, UiKit.GOLD if is_record else UiKit.DIM)
	record.position = Vector2(0, 186)
	record.size = Vector2(640, 12)
	add_child(record)

	var box := VBoxContainer.new()
	box.position = Vector2(235, 226)
	box.custom_minimum_size = Vector2(170, 0)
	box.add_theme_constant_override("separation", 8)
	add_child(box)

	var retry := UiKit.button("REINTENTAR")
	retry.pressed.connect(func() -> void:
		GameState.reset_run()
		get_tree().change_scene_to_file("res://scenes/game.tscn"))
	box.add_child(retry)

	var menu := UiKit.button("MENÚ")
	menu.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	box.add_child(menu)
	retry.grab_focus()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), UiKit.BG)
	for i in GameState.MAX_HEARTS:
		UiKit.draw_heart(self, Vector2(320 - (GameState.MAX_HEARTS - 1) * 14 + i * 28, 212), i < GameState.hearts, 1.4)
