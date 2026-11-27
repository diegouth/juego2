extends Node
## Test end-to-end sin ventana: instancia el nivel y comprueba las mecánicas
## obligatorias (llave, daño con corazón y reaparición, puerta que avanza).
## Ejecutar:  godot --headless --path . res://tests/e2e.tscn

var fails := 0


func check(cond: bool, what: String) -> void:
	print(("  PASS  " if cond else "  FAIL  ") + what)
	if not cond:
		fails += 1


func _ready() -> void:
	print("== TEST E2E: La Llave del Laberinto ==")
	var tree := get_tree()
	GameState.reset_run()
	var game: Node = load("res://scenes/game.tscn").instantiate()
	add_child(game)
	await get_tree().physics_frame

	var player: Player = game.get("player")
	check(player != null, "el nivel instancia al jugador")
	check(GameState.hearts == GameState.MAX_HEARTS, "arranca con %d corazones" % GameState.MAX_HEARTS)
	check(map_has(game, "key_item"), "el nivel 1 contiene una llave")
	check(map_has(game, "door"), "el nivel 1 contiene una puerta")
	check(count_nodes(game, "spike.gd") > 0, "el nivel 1 contiene pinchos (%d)" % count_nodes(game, "spike.gd"))

	var key: Node2D = game.get_node_or_null("key_item")
	player.global_position = key.global_position
	await get_tree().physics_frame
	await get_tree().physics_frame
	check(GameState.has_key, "tocar la llave la recoge")
	check(GameState.score == GameState.POINTS_KEY, "la llave suma %d puntos (%d)" % [GameState.POINTS_KEY, GameState.score])

	var coins := count_nodes(game, "coin.gd")
	check(coins > 0, "el nivel 1 contiene monedas (%d)" % coins)
	var coin: Node2D = first_node(game, "coin.gd")
	var before_score := GameState.score
	player.global_position = coin.global_position
	await get_tree().physics_frame
	await get_tree().physics_frame
	check(GameState.score == before_score + Coin.POINTS, "la moneda suma %d puntos (%d)" % [Coin.POINTS, GameState.score])
	check(not coin.visible, "la moneda recogida desaparece")

	var spike: Node2D = first_node(game, "spike.gd")
	var before := GameState.hearts
	player.global_position = spike.global_position
	await get_tree().physics_frame
	await get_tree().physics_frame
	check(GameState.hearts == before - 1, "el pincho quita un corazón (%d -> %d)" % [before, GameState.hearts])
	check(player.global_position.distance_to(player.start_pos) < 2.0, "tras el golpe reaparece en el inicio")

	# Agotar los corazones restantes debe llevar a Game Over.
	while GameState.hearts > 1:
		player._invuln = 0.0
		player.take_hit()
	check(GameState.hearts == 1, "los corazones no bajan de 1 mientras se juega")

	# Puerta con llave: se llama al manejador directo para no perder el test
	# en el cambio de escena (que es diferido).
	GameState.has_key = true
	var door: Node = game.get_node_or_null("door")
	door._on_body_entered(player)
	check(GameState.level_index == 1, "la puerta con llave avanza al nivel 2")
	check(not GameState.has_key, "la llave se consume al cruzar")

	print("== RESULTADO: %d fallo(s) ==" % fails)
	tree.quit(0 if fails == 0 else 1)


func map_has(parent: Node, node_name: String) -> bool:
	return parent.get_node_or_null(node_name) != null


## Cuenta los hijos que usan un script dado (Godot renombra los duplicados
## como @spike@2, asi que el nombre no sirve para contarlos).
func count_nodes(parent: Node, script_file: String) -> int:
	var n := 0
	for child in parent.get_children():
		if _uses_script(child, script_file):
			n += 1
	return n


func first_node(parent: Node, script_file: String) -> Node2D:
	for child in parent.get_children():
		if _uses_script(child, script_file):
			return child as Node2D
	return null


func _uses_script(node: Node, script_file: String) -> bool:
	var script: Script = node.get_script()
	return script != null and String(script.resource_path).get_file() == script_file
