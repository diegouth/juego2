extends Control
## Menú principal: título, botones Jugar / Créditos / Salir y pie de versión.

var _t := 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var title := UiKit.label("LA LLAVE", 24, UiKit.GOLD)
	title.position = Vector2(0, 54)
	title.size = Vector2(640, 30)
	add_child(title)

	var subtitle := UiKit.label("DEL LABERINTO", 16, UiKit.INK)
	subtitle.position = Vector2(0, 92)
	subtitle.size = Vector2(640, 24)
	add_child(subtitle)

	var tagline := UiKit.label("RECOGE LA LLAVE  ·  EVITA LOS PINCHOS", 6, UiKit.DIM)
	tagline.position = Vector2(0, 126)
	tagline.size = Vector2(640, 12)
	add_child(tagline)

	var box := VBoxContainer.new()
	box.position = Vector2(235, 160)
	box.custom_minimum_size = Vector2(170, 0)
	box.add_theme_constant_override("separation", 8)
	add_child(box)

	var play := UiKit.button("JUGAR")
	play.pressed.connect(_on_play)
	box.add_child(play)

	var credits := UiKit.button("CRÉDITOS")
	credits.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/credits.tscn"))
	box.add_child(credits)

	var quit := UiKit.button("SALIR")
	quit.pressed.connect(func() -> void: get_tree().quit())
	box.add_child(quit)

	play.grab_focus()

	var footer := UiKit.label("v0.2-ALPHA  ·  GODOT 4", 6, Color("5f677f"))
	footer.position = Vector2(0, 336)
	footer.size = Vector2(640, 12)
	add_child(footer)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _on_play() -> void:
	GameState.reset_run()
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), UiKit.BG)
	# Rejilla de fondo + llave flotante decorativa.
	for x in range(0, 640, 32):
		draw_line(Vector2(x, 0), Vector2(x, 360), Color(1, 1, 1, 0.025))
	for y in range(0, 360, 32):
		draw_line(Vector2(0, y), Vector2(640, y), Color(1, 1, 1, 0.025))
	UiKit.draw_key(self, Vector2(320, 30 + sin(_t * 1.6) * 2.0), Color(UiKit.GOLD, 0.85), 2.2)
