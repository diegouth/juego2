extends Area2D
## Pincho: quita un corazón y devuelve al jugador al punto de inicio del nivel.

var tile := 16.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	var shape := RectangleShape2D.new()
	shape.size = Vector2(tile * 0.8, tile * 0.6)
	var cs := CollisionShape2D.new()
	cs.shape = shape
	cs.position = Vector2(0, tile * 0.2)
	add_child(cs)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		(body as Player).take_hit()


func _draw() -> void:
	var w := tile * 0.32
	for i in 3:
		var x := -tile * 0.32 + i * w
		var pts := PackedVector2Array([
			Vector2(x, tile * 0.4),
			Vector2(x + w, tile * 0.4),
			Vector2(x + w * 0.5, -tile * 0.25),
		])
		draw_colored_polygon(pts, Color("c8ccd8"))
		draw_polyline(pts, Color("6b7080"), 1.0)
