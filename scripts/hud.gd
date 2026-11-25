extends Control
## HUD del juego: corazones, indicador de llave, número de nivel, aviso de
## texto y dibujo del joystick táctil.

var _level_label: Label
var _hint: Label
var _hint_time := 0.0
var _pulse := 0.0
var _game: Node


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	GameState.hearts_changed.connect(func(_v: int) -> void: queue_redraw())
	GameState.key_changed.connect(func(_h: bool) -> void: queue_redraw())

	_level_label = UiKit.label("NIVEL %d/%d" % [GameState.level_index + 1, GameState.level_count()], 8, UiKit.DIM)
	_level_label.position = Vector2(470, 8)
	_level_label.size = Vector2(158, 12)
	_level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_level_label)

	_hint = UiKit.label("", 8, UiKit.GOLD)
	_hint.position = Vector2(0, 318)
	_hint.size = Vector2(640, 20)
	_hint.visible = false
	add_child(_hint)

	var help := UiKit.label("FLECHAS / WASD  ·  ESC = MENÚ", 6, Color("5f677f"))
	help.position = Vector2(0, 340)
	help.size = Vector2(640, 12)
	add_child(help)


func show_hint(text: String) -> void:
	_hint.text = text
	_hint.visible = true
	_hint_time = 2.2


func _process(delta: float) -> void:
	_pulse += delta
	if _hint_time > 0.0:
		_hint_time = maxf(_hint_time - delta, 0.0)
		_hint.modulate.a = clampf(_hint_time / 0.6, 0.0, 1.0)
		if _hint_time == 0.0:
			_hint.visible = false
	if _game == null:
		_game = get_tree().get_first_node_in_group("game")
	queue_redraw()


func _draw() -> void:
	# Barras superior e inferior para que la HUD se lea sobre el mapa.
	draw_rect(Rect2(0, 0, 640, 26), Color(0.03, 0.04, 0.07, 0.72))
	draw_rect(Rect2(0, 330, 640, 30), Color(0.03, 0.04, 0.07, 0.72))
	# Corazones.
	for i in GameState.MAX_HEARTS:
		UiKit.draw_heart(self, Vector2(20 + i * 20, 18), i < GameState.hearts, 1.1)
	# Llave recogida.
	var key_on := GameState.has_key
	UiKit.draw_key(self, Vector2(96, 16), UiKit.GOLD if key_on else Color("454758"), 1.2)
	if key_on:
		draw_arc(Vector2(96, 16), 11.0, 0.0, TAU, 20, Color(UiKit.GOLD, 0.15 + 0.15 * sin(_pulse * 4.0)), 1.5)
	# Joystick táctil.
	if _game and _game.get("joystick_active"):
		var origin: Vector2 = _game.get("joystick_origin")
		var dir: Vector2 = _game.get("joystick_dir")
		draw_circle(origin, 34.0, Color(1, 1, 1, 0.06))
		draw_arc(origin, 34.0, 0.0, TAU, 32, Color(1, 1, 1, 0.18), 2.0)
		draw_circle(origin + dir * 34.0, 14.0, Color(UiKit.GOLD, 0.55))
