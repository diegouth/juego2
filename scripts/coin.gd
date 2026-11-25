class_name Coin
extends Area2D
## Moneda: coleccionable de puntaje (la "transaccion" del juego).
## Hereda de Area2D igual que la llave, pero no cambia el estado de la puerta:
## solo suma puntos y alimenta el marcador de la HUD.

const TILE := 16.0
const POINTS := 10

var collected := false
var _t := 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	var shape := CircleShape2D.new()
	shape.radius = TILE * 0.5
	var cs := CollisionShape2D.new()
	cs.shape = shape
	add_child(cs)
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if collected or not (body is Player):
		return
	collected = true
	GameState.collect_coin(POINTS)
	set_deferred("monitoring", false)
	hide()


func _draw() -> void:
	# Giro: se comprime en X para dar sensacion de moneda girando.
	var spin := absf(cos(_t * 2.6))
	var bob := sin(_t * 3.4) * 1.2
	var radius := TILE * 0.36 * (0.35 + 0.65 * spin)
	draw_circle(Vector2(0, bob), radius + 2.0, Color(UiKit.GOLD, 0.12))
	draw_circle(Vector2(0, bob), radius, UiKit.GOLD)
	draw_arc(Vector2(0, bob), radius * 0.6, 0.0, TAU, 12, Color("c79a34"), 1.0)
