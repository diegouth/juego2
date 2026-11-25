extends Area2D
## Enemigo que patrulla en línea recta: al chocar con un muro del mapa gira.
## Tocar al jugador quita un corazón.

const TILE := 16.0
const SPEED := 42.0
const RADIUS := 6.0

var map: Array[String] = []
var dir := Vector2.RIGHT
var _t := 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	var shape := CircleShape2D.new()
	shape.radius = RADIUS
	var cs := CollisionShape2D.new()
	cs.shape = shape
	add_child(cs)


func _physics_process(delta: float) -> void:
	_t += delta
	var step := dir * SPEED * delta
	if _is_wall(global_position + dir * (RADIUS + 2.0)):
		dir = -dir
	else:
		global_position += step
	for body in get_overlapping_bodies():
		if body is Player:
			(body as Player).take_hit()
	queue_redraw()


func _is_wall(p: Vector2) -> bool:
	if map.is_empty():
		return false
	var cx := int(floor(p.x / TILE))
	var cy := int(floor(p.y / TILE))
	if cy < 0 or cy >= map.size():
		return true
	var row: String = map[cy]
	if cx < 0 or cx >= row.length():
		return true
	return row[cx] == "#"


func _draw() -> void:
	var wobble := sin(_t * 6.0) * 0.8
	draw_circle(Vector2(0, wobble), RADIUS, Color("e07a5f"))
	draw_circle(Vector2(0, wobble), RADIUS, Color("8f3f2b"), false, 1.0)
	draw_rect(Rect2(-3.2, -2.0 + wobble, 2.0, 2.0), Color("12141c"))
	draw_rect(Rect2(1.2, -2.0 + wobble, 2.0, 2.0), Color("12141c"))
