extends Area2D
## Llave: al tocarla se guarda en GameState y la puerta deja de estar cerrada.

const TILE := 16.0

var collected := false
var _t := 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	var shape := CircleShape2D.new()
	shape.radius = TILE * 0.6
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
	GameState.collect_key()
	hide()
	set_deferred("monitoring", false)


func _draw() -> void:
	var bob := sin(_t * 3.0) * 1.5
	draw_circle(Vector2(0, bob), TILE * 0.55, Color("f2c14e", 0.18))
	UiKit.draw_key(self, Vector2(0, bob), Color("f2c14e"), 1.2)
