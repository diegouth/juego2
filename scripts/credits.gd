extends Control
## Créditos: atribución de motor, tipografía, gráficos y audio.

const LINES := """[center][color=#f2c14e]CRÉDITOS[/color][/center]

[b]LA LLAVE DEL LABERINTO[/b]  ·  v0.2-alpha
Prototipo jugable 2D. Proyecto de desarrollo de videojuegos.

[color=#f2c14e]EQUIPO[/color]
Diego Alejandro Franco Partida
Programación, diseño de niveles, arte, sonido y pruebas.

[color=#f2c14e]MOTOR[/color]
Godot Engine 4.7.2 — MIT License
© Godot Engine contributors — godotengine.org

[color=#f2c14e]TIPOGRAFÍA[/color]
"Press Start 2P" — © 2012 The Press Start 2P Project Authors
(cody@zone38.net), con Reserved Font Name "Press Start 2P".
Licencia SIL Open Font License 1.1.
Texto completo en assets/fonts/OFL.txt.

[color=#f2c14e]GRÁFICOS[/color]
Personaje, muros, pinchos, llave, puerta y enemigo dibujados
por código con CanvasItem (sin sprites externos).
Autoría del equipo · CC0 1.0.

[color=#f2c14e]MÚSICA Y EFECTOS[/color]
Sintetizados con el script tools/gen_audio.py incluido en el
repositorio (ondas cuadradas y ruido filtrado).
Autoría del equipo · CC0 1.0.

[color=#f2c14e]HERRAMIENTAS[/color]
Godot 4 · Git y GitHub (ramas y Pull Requests)
FFmpeg (conversión a OGG) · Arch Linux
"""


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var panel := ScrollContainer.new()
	panel.position = Vector2(60, 40)
	panel.size = Vector2(520, 250)
	panel.add_theme_constant_override("scrollbar_width", 8)
	panel.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(panel)

	var text := RichTextLabel.new()
	text.bbcode_enabled = true
	text.fit_content = true
	text.scroll_active = false
	text.custom_minimum_size = Vector2(500, 0)
	text.add_theme_font_override("normal_font", UiKit.FONT)
	text.add_theme_font_override("bold_font", UiKit.FONT)
	text.add_theme_font_size_override("normal_font_size", 6)
	text.add_theme_font_size_override("bold_font_size", 7)
	text.add_theme_constant_override("line_separation", 6)
	text.add_theme_color_override("default_color", UiKit.INK)
	text.text = LINES
	panel.add_child(text)

	var back := UiKit.button("VOLVER")
	back.position = Vector2(235, 306)
	back.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	add_child(back)
	back.grab_focus()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), UiKit.BG)
