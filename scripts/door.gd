extends Area2D
## Puerta: cerrada hasta tener la llave. Con llave, avanza de nivel (o termina
## el juego si era el último).

const TILE := 16.0

var _t := 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	var shape := RectangleShape2D.new()
	shape.size = Vector2(TILE, TILE)
	var cs := CollisionShape2D.new()
	cs.shape = shape
	add_child(cs)
	body_entered.connect(_on_body_entered)
	GameState.key_changed.connect(func(_h: bool) -> void: queue_redraw())


func _process(delta: float) -> void:
	_t += delta
	if not GameState.has_key:
		queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if not (body is Player):
		return
	var game := get_tree().get_first_node_in_group("game")
	if GameState.has_key:
		if game and game.has_method("complete_level"):
			game.complete_level()
	elif game and game.has_method("show_hint"):
		game.show_hint("¡NECESITAS LA LLAVE!")


func _draw() -> void:
	var half := TILE * 0.5
	var locked := not GameState.has_key
	var frame := Color("5a6178")
	var fill := Color("2a3040") if locked else Color("f2c14e", 0.55)
	draw_rect(Rect2(-half, -half, TILE, TILE), fill)
	draw_rect(Rect2(-half, -half, TILE, TILE), frame, false, 1.5)
	if not locked:
		draw_rect(Rect2(-half, -half, TILE, TILE), Color("f2c14e"), false, 1.5)
	# Arco de la puerta.
	draw_arc(Vector2(0, -half + 1), half - 3.0, PI, TAU, 10, frame, 1.5)
	if locked:
		draw_circle(Vector2(0, 1), 2.0, Color("f2c14e"))
		draw_rect(Rect2(-1.0, 1.0, 2.0, 4.0), Color("f2c14e"))
	else:
		var glow := 0.5 + 0.5 * sin(_t * 4.0)
		draw_circle(Vector2(0, 1), 5.0 * glow, Color("f2c14e", 0.35))
