extends Node2D
## Escena de juego: lee el mapa ASCII del nivel, construye el mundo (muros,
## pinchos, llave, puerta, enemigos), monta la HUD y traduce el toque de
## pantalla en un joystick virtual.

const TILE := 16.0
const PLAYER_SCENE := preload("res://scenes/player.tscn")
const SPIKE_SCRIPT := preload("res://scripts/spike.gd")
const KEY_SCRIPT := preload("res://scripts/key_item.gd")
const DOOR_SCRIPT := preload("res://scripts/door.gd")
const ENEMY_SCRIPT := preload("res://scripts/enemy.gd")
const COIN_SCRIPT := preload("res://scripts/coin.gd")
const HUD_SCRIPT := preload("res://scripts/hud.gd")

var map: Array[String] = []
var player: Player
var hud: Control

## Estado del joystick táctil (la HUD lo lee para dibujarlo).
var joystick_origin := Vector2.ZERO
var joystick_dir := Vector2.ZERO
var joystick_active := false

var _advancing := false


func _ready() -> void:
	add_to_group("game")
	_load_map()
	_build_level()
	_build_hud()
	show_hint("NIVEL %d  ·  BUSCA LA LLAVE" % (GameState.level_index + 1))


func _process(_delta: float) -> void:
	if player:
		player.joystick_dir = joystick_dir


# --- Carga y construcción del nivel -----------------------------------------
func _load_map() -> void:
	map.clear()
	var path: String = GameState.LEVEL_FILES[GameState.level_index]
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("No se pudo abrir el nivel: %s" % path)
		return
	for line in file.get_as_text().split("\n"):
		if line.strip_edges() != "" and not line.begins_with(";"):
			map.append(line)


func _build_level() -> void:
	var root := Node2D.new()
	root.name = "Level"
	add_child(root)

	var walls := StaticBody2D.new()
	walls.name = "Walls"
	walls.collision_layer = 1
	walls.collision_mask = 0
	root.add_child(walls)

	var spikes: Array[Vector2i] = []
	for y in map.size():
		var row: String = map[y]
		var x := 0
		while x < row.length():
			var ch := row[x]
			if ch == "#":
				var start := x
				while x < row.length() and row[x] == "#":
					x += 1
				_add_wall(walls, start, y, x - start)
				continue
			match ch:
				"P": _spawn_player(x, y)
				"K": _spawn(KEY_SCRIPT, Vector2(x, y))
				"D": _spawn(DOOR_SCRIPT, Vector2(x, y))
				"^": spikes.append(Vector2i(x, y))
				"E": _spawn_enemy(x, y)
				"C": _spawn(COIN_SCRIPT, Vector2(x, y))
			x += 1
	for cell in spikes:
		_spawn(SPIKE_SCRIPT, Vector2(cell.x, cell.y))


## Un CollisionShape por tramo horizontal de muro (menos cuerpos que por celda).
func _add_wall(body: StaticBody2D, col: int, row: int, length: int) -> void:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(length * TILE, TILE)
	var cs := CollisionShape2D.new()
	cs.shape = shape
	cs.position = Vector2(col * TILE + length * TILE * 0.5, row * TILE + TILE * 0.5)
	body.add_child(cs)


func _spawn_player(col: int, row: int) -> void:
	player = PLAYER_SCENE.instantiate() as Player
	player.position = _cell_center(col, row)
	add_child(player)


func _spawn_enemy(col: int, row: int) -> void:
	var enemy := Area2D.new()
	enemy.set_script(ENEMY_SCRIPT)
	enemy.name = "enemy"
	enemy.position = _cell_center(col, row)
	enemy.set("map", map)
	add_child(enemy)


func _spawn(script: Script, cell: Vector2) -> void:
	var node := Area2D.new()
	node.set_script(script)
	node.name = String(script.resource_path.get_file().get_basename())
	node.position = _cell_center(int(cell.x), int(cell.y))
	add_child(node)


func _cell_center(col: int, row: int) -> Vector2:
	return Vector2(col * TILE + TILE * 0.5, row * TILE + TILE * 0.5)


# --- Dibujo del nivel -------------------------------------------------------
# El mapa se pinta aquí (el nodo raíz dibuja antes que sus hijos, así que el
# jugador, los pinchos y los enemigos quedan siempre por encima).
func _draw() -> void:
	var floor_a := Color("151822")
	var floor_b := Color("191d29")
	var wall_fill := Color("2f3547")
	var wall_top := Color("444d66")
	var wall_edge := Color("222736")
	for y in map.size():
		var row: String = map[y]
		for x in row.length():
			var rect := Rect2(x * TILE, y * TILE, TILE, TILE)
			if row[x] == "#":
				draw_rect(rect, wall_fill)
				draw_rect(Rect2(rect.position, Vector2(TILE, 3)), wall_top)
				draw_rect(rect.grow(-0.5), wall_edge, false, 1.0)
			elif (x + y) % 2 == 0:
				draw_rect(rect, floor_a)
			else:
				draw_rect(rect, floor_b)


# --- HUD, avisos y fin de nivel ---------------------------------------------
func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "HUDLayer"
	add_child(layer)
	hud = Control.new()
	hud.name = "Hud"
	hud.set_script(HUD_SCRIPT)
	layer.add_child(hud)


func show_hint(text: String) -> void:
	if hud and hud.has_method("show_hint"):
		hud.show_hint(text)


## Llamada por la puerta cuando el jugador ya tiene la llave.
func complete_level() -> void:
	if _advancing:
		return
	_advancing = true
	GameState.play_sfx("door")
	GameState.advance_level()
	# Se difiere el cambio de escena: la puerta llama desde body_entered y liberar
	# cuerpos dentro de un callback de fisica genera el error "Removing a
	# CollisionObject node during a physics callback".
	if GameState.level_index < GameState.level_count():
		get_tree().call_deferred("change_scene_to_file", "res://scenes/game.tscn")
	else:
		GameState.won = true
		get_tree().call_deferred("change_scene_to_file", "res://scenes/end_screen.tscn")


# --- Entrada táctil (Android) y teclado -------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			joystick_origin = touch.position
			joystick_active = true
			joystick_dir = Vector2.ZERO
		else:
			joystick_active = false
			joystick_dir = Vector2.ZERO
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		joystick_dir = ((drag.position - joystick_origin) / 42.0).limit_length(1.0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
