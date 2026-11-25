extends Node
## Bot de demostración: juega solo para grabar el video de evidencia.
## Se activa como autoload temporal (tools/record_video.sh) y recorre:
## menú -> nivel 1 (llave, un pincho, puerta) -> nivel 2 (llave, puerta) -> fin.

const TILE := 16.0

var state := "menu"
var t := 0.0
var phase := "key"
var path: Array[Vector2i] = []
var repath := 0.0
var hearts_at_level := GameState.MAX_HEARTS
var _game: Node = null


func _process(delta: float) -> void:
	t += delta
	match state:
		"menu":
			if t > 2.0:
				GameState.reset_run()
				_go_play("res://scenes/game.tscn")
		"play":
			_play(delta)
		"end":
			if t > 3.5:
				get_tree().quit()


func _go_play(scene_path: String) -> void:
	state = "play"
	t = 0.0
	path.clear()
	_game = null
	get_tree().change_scene_to_file(scene_path)


func _play(delta: float) -> void:
	var game := get_tree().get_first_node_in_group("game")
	if game == null:
		var scene := get_tree().current_scene
		if scene and scene.name == "EndScreen":
			state = "end"
			t = 0.0
		return
	if game != _game:
		_game = game
		path.clear()
		phase = "key"
		hearts_at_level = GameState.MAX_HEARTS
		GameState.hearts = GameState.MAX_HEARTS
		t = 0.0
	var player: Player = game.get("player")
	if player == null:
		return
	if phase == "key" and GameState.has_key:
		phase = "spike" if GameState.level_index == 0 else "door"
	elif phase == "spike" and GameState.hearts < hearts_at_level:
		phase = "door"

	repath -= delta
	if repath <= 0.0 or path.is_empty():
		_recompute(game, player)
		repath = 0.35
	if path.is_empty():
		player.joystick_dir = Vector2.ZERO
		return
	var target := _center(path[0])
	var d := target - player.global_position
	if d.length() < 4.0:
		path.pop_front()
		player.joystick_dir = Vector2.ZERO
	else:
		player.joystick_dir = d.normalized()


func _recompute(game: Node, player: Node2D) -> void:
	var target_cell := Vector2i(-1, -1)
	match phase:
		"key":
			var key: Node2D = game.get_node_or_null("key_item")
			if key:
				target_cell = _cell(key.global_position)
		"spike":
			var spike := _first(game, "spike")
			if spike:
				target_cell = _cell(spike.global_position)
		"door":
			var door: Node2D = game.get_node_or_null("door")
			if door:
				target_cell = _cell(door.global_position)
	if target_cell.x < 0:
		path.clear()
		return
	path = _bfs(game.get("map"), _cell(player.global_position), target_cell)


func _first(parent: Node, prefix: String) -> Node2D:
	for child in parent.get_children():
		if String(child.name).begins_with(prefix):
			return child as Node2D
	return null


func _cell(p: Vector2) -> Vector2i:
	return Vector2i(int(floor(p.x / TILE)), int(floor(p.y / TILE)))


func _center(c: Vector2i) -> Vector2:
	return Vector2(c.x * TILE + TILE * 0.5, c.y * TILE + TILE * 0.5)


## BFS sobre la rejilla del mapa: devuelve el camino sin muros hasta el destino.
func _bfs(map: Array, start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	if map.is_empty():
		return out
	var h := map.size()
	var w := String(map[0]).length()
	var prev := {start: start}
	var queue: Array[Vector2i] = [start]
	while not queue.is_empty():
		var cur: Vector2i = queue.pop_front()
		if cur == goal:
			break
		for step in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = cur + step
			if n.x < 0 or n.y < 0 or n.x >= w or n.y >= h:
				continue
			if prev.has(n) or String(map[n.y])[n.x] == "#":
				continue
			prev[n] = cur
			queue.append(n)
	if not prev.has(goal):
		return out
	var c := goal
	while c != start:
		out.push_front(c)
		c = prev[c]
	return out
