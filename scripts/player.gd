class_name Player
extends CharacterBody2D
## Jugador: movimiento en 8 direcciones (teclado o joystick táctil), daño con
## invulnerabilidad temporal y reaparición en el punto de inicio del nivel.

const SPEED := 115.0
const RADIUS := 5.0
const INVULNERABLE_TIME := 1.2

var start_pos := Vector2.ZERO
## Lo escribe la escena de juego cuando hay un dedo en pantalla.
var joystick_dir := Vector2.ZERO

var _invuln := 0.0
var _anim := 0.0
var _facing := Vector2.DOWN
var _hit_locked := false


func _ready() -> void:
	collision_layer = 1
	collision_mask = 1
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var shape := CircleShape2D.new()
	shape.radius = RADIUS
	var cs := CollisionShape2D.new()
	cs.shape = shape
	add_child(cs)
	start_pos = global_position


func _physics_process(delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir == Vector2.ZERO and joystick_dir.length() > 0.25:
		dir = joystick_dir.normalized() * minf(joystick_dir.length(), 1.0)
	velocity = dir * SPEED
	if dir != Vector2.ZERO:
		_facing = dir.normalized()
	move_and_slide()
	_invuln = maxf(_invuln - delta, 0.0)
	_anim += delta
	queue_redraw()


## Un toque de pincho o enemigo: pierde un corazón y vuelve al inicio.
func take_hit() -> void:
	if _invuln > 0.0 or _hit_locked:
		return
	_hit_locked = true
	_invuln = INVULNERABLE_TIME
	var dead := GameState.damage(1)
	if dead:
		GameState.won = false
		get_tree().call_deferred("change_scene_to_file", "res://scenes/end_screen.tscn")
	else:
		global_position = start_pos
		_hit_locked = false


func _draw() -> void:
	# Parpadeo mientras es invulnerable.
	if _invuln > 0.0 and int(_anim * 14.0) % 2 == 0:
		return
	draw_rect(Rect2(-5, -6, 10, 11), Color("7fd1ae"))
	draw_rect(Rect2(-5, 3, 10, 3), Color("3c8f72"))
	draw_rect(Rect2(-6, -8, 12, 3), Color("f2c14e"))  # sombrero
	var eye := Vector2(_facing.x * 1.6, _facing.y * 1.2 + 1.0)
	draw_rect(Rect2(-2.6 + eye.x, -2.4 + eye.y, 1.6, 1.6), Color("12141c"))
	draw_rect(Rect2(1.0 + eye.x, -2.4 + eye.y, 1.6, 1.6), Color("12141c"))
