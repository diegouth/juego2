extends Node
## Autoload "GameState": estado de la partida que sobrevive al cambio de escena
## (corazones, llave, nivel actual), mapa de teclas y reproductores de audio.

signal hearts_changed(value: int)
signal key_changed(has_key: bool)
signal score_changed(value: int)

const MAX_HEARTS := 3
const LEVEL_FILES: Array[String] = [
	"res://levels/level_1.txt",
	"res://levels/level_2.txt",
]
const SFX_NAMES: Array[String] = ["pickup", "damage", "door", "gameover"]
const POINTS_KEY := 50
const POINTS_LEVEL := 100
const SAVE_PATH := "user://record.cfg"

var hearts := MAX_HEARTS
var has_key := false
var level_index := 0
var won := false
var score := 0
var best_score := 0

var _sfx: Dictionary = {}
var _music: AudioStreamPlayer


func _ready() -> void:
	_setup_input()
	_setup_audio()
	_start_music()
	_load_record()


# --- Entrada -----------------------------------------------------------------
# Las acciones se crean en código para que funcione igual con teclado
# (flechas + WASD) y en pantalla táctil, sin depender del editor.
func _setup_input() -> void:
	var bindings := {
		"move_left": [KEY_LEFT, KEY_A],
		"move_right": [KEY_RIGHT, KEY_D],
		"move_up": [KEY_UP, KEY_W],
		"move_down": [KEY_DOWN, KEY_S],
	}
	for action: String in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action, 0.2)
		for code: int in bindings[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = code
			InputMap.action_add_event(action, ev)


# --- Audio -------------------------------------------------------------------
func _setup_audio() -> void:
	for sfx_name: String in SFX_NAMES:
		var player := AudioStreamPlayer.new()
		var path := "res://assets/audio/%s.ogg" % sfx_name
		if ResourceLoader.exists(path):
			player.stream = load(path)
		player.volume_db = -6.0
		add_child(player)
		_sfx[sfx_name] = player
	_music = AudioStreamPlayer.new()
	_music.name = "Music"
	if ResourceLoader.exists("res://assets/audio/music.ogg"):
		_music.stream = load("res://assets/audio/music.ogg")
		if _music.stream is AudioStreamOggVorbis:
			(_music.stream as AudioStreamOggVorbis).loop = true
	_music.volume_db = -14.0
	add_child(_music)


func _start_music() -> void:
	if _music and _music.stream and not _music.playing:
		_music.play()


func play_sfx(sfx_name: String) -> void:
	var player: AudioStreamPlayer = _sfx.get(sfx_name)
	if player and player.stream:
		player.play()


# --- Estado de la partida ----------------------------------------------------
func reset_run() -> void:
	hearts = MAX_HEARTS
	has_key = false
	level_index = 0
	won = false
	score = 0
	hearts_changed.emit(hearts)
	key_changed.emit(has_key)
	score_changed.emit(score)


# --- Puntaje (transacciones del jugador) -------------------------------------
## Suma puntos y actualiza el marcador de la HUD.
func add_score(points: int) -> void:
	score = maxi(score + points, 0)
	score_changed.emit(score)


## Moneda recogida: suma sus puntos y reproduce el sonido de recogida.
func collect_coin(points: int) -> void:
	add_score(points)
	play_sfx("pickup")


## Guarda el record si la partida lo supera. Devuelve true si es record nuevo.
func commit_record() -> bool:
	var is_record := score > best_score
	if is_record:
		best_score = score
		_save_record()
	return is_record


func _load_record() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		best_score = int(cfg.get_value("marcador", "record", 0))


func _save_record() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("marcador", "record", best_score)
	cfg.save(SAVE_PATH)


## Devuelve true cuando el jugador se queda sin corazones.
func damage(amount := 1) -> bool:
	hearts = maxi(hearts - amount, 0)
	hearts_changed.emit(hearts)
	play_sfx("damage")
	return hearts == 0


func collect_key() -> void:
	if has_key:
		return
	has_key = true
	key_changed.emit(has_key)
	add_score(POINTS_KEY)
	play_sfx("pickup")


func advance_level() -> void:
	add_score(POINTS_LEVEL)
	level_index += 1
	has_key = false
	key_changed.emit(has_key)


func level_count() -> int:
	return LEVEL_FILES.size()


func is_last_level() -> bool:
	return level_index >= LEVEL_FILES.size() - 1
