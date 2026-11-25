class_name UiKit
extends RefCounted
## Constructores de interfaz compartidos por menú, HUD, fin de partida y
## créditos: misma fuente pixel, mismos colores y mismo estilo de botón.

const FONT: FontFile = preload("res://assets/fonts/PressStart2P-Regular.ttf")
const INK := Color("f4f1e6")
const GOLD := Color("f2c14e")
const DIM := Color("9aa0b5")
const BG := Color("12141c")
const RED := Color("e5484d")


static func label(text: String, size := 8, color := INK) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", FONT)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return l


static func button(text: String, size := 8) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_override("font", FONT)
	b.add_theme_font_size_override("font_size", size)
	b.add_theme_color_override("font_color", INK)
	b.add_theme_color_override("font_hover_color", BG)
	b.add_theme_color_override("font_focus_color", INK)
	b.add_theme_color_override("font_pressed_color", BG)
	b.custom_minimum_size = Vector2(170, 24)
	b.add_theme_stylebox_override("normal", _box(BG, GOLD))
	b.add_theme_stylebox_override("hover", _box(GOLD, GOLD))
	b.add_theme_stylebox_override("pressed", _box(Color("c79a34"), GOLD))
	b.add_theme_stylebox_override("focus", _box(Color("1b1e29"), INK))
	return b


static func _box(fill: Color, border: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.border_color = border
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(0)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	return sb


## Corazón dibujado con primitivas: dos círculos y un triángulo.
static func draw_heart(canvas: CanvasItem, center: Vector2, filled: bool, scale := 1.0) -> void:
	var col := RED if filled else Color("454758")
	canvas.draw_circle(center + Vector2(-3.0, -2.0) * scale, 3.4 * scale, col)
	canvas.draw_circle(center + Vector2(3.0, -2.0) * scale, 3.4 * scale, col)
	var pts := PackedVector2Array([
		center + Vector2(-6.2, -0.6) * scale,
		center + Vector2(6.2, -0.6) * scale,
		center + Vector2(0.0, 7.5) * scale,
	])
	canvas.draw_colored_polygon(pts, col)


## Llave dibujada con primitivas (la misma forma que el icono del juego).
static func draw_key(canvas: CanvasItem, center: Vector2, color: Color, scale := 1.0) -> void:
	var ring := center + Vector2(-2.0, -2.0) * scale
	canvas.draw_arc(ring, 3.2 * scale, 0.0, TAU, 16, color, 1.6 * scale)
	canvas.draw_line(ring + Vector2(2.3, 2.3) * scale, center + Vector2(6.0, 6.0) * scale, color, 1.6 * scale)
	canvas.draw_line(center + Vector2(3.4, 5.4) * scale, center + Vector2(5.6, 3.2) * scale, color, 1.4 * scale)
