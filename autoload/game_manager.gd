extends Node

## GameManager (Autoload Singleton)
## Gerencia transições entre cenas e estado global do jogo.
## Persiste entre todas as trocas de cena.

var current_scene_path := ""
var transition_in_progress := false

## Duração do fade em segundos (0 = sem fade)
var fade_duration: float = 0.5

## CanvasLayer usado para o fade. Criado dinamicamente.
var _fade_layer: CanvasLayer = null
var _fade_rect: ColorRect = null


func _ready() -> void:
	current_scene_path = get_tree().current_scene.scene_file_path


func change_scene(next_scene: String) -> void:
	"""
	Faz a transição para a cena `next_scene`.
	Se o caminho for igual ao da cena atual, ignora.
	Inclui fade opcional.
	"""
	if transition_in_progress:
		return

	if next_scene == current_scene_path:
		push_warning("GameManager: tentativa de carregar a mesma cena: ", next_scene)
		return

	transition_in_progress = true

	if fade_duration > 0:
		_fade_in()
		await get_tree().create_timer(fade_duration).timeout

	_do_change_scene(next_scene)


func _do_change_scene(next_scene: String) -> void:
	var err := get_tree().change_scene_to_file(next_scene)
	if err != OK:
		push_error("GameManager: erro ao carregar cena ", next_scene, " (código ", err, ")")
		transition_in_progress = false
		return

	current_scene_path = next_scene

	# Se fade_duration > 0, faz o fade out
	if fade_duration > 0:
		# Aguarda um frame para a nova cena ser renderizada
		await get_tree().process_frame
		_fade_out()
		await get_tree().create_timer(fade_duration).timeout

	transition_in_progress = false


# ------------------------------------------------------------------
# Fade (preto)
# ------------------------------------------------------------------
func _fade_in() -> void:
	_create_fade_ui()
	_fade_rect.modulate.a = 0.0
	_animate_fade(0.0, 1.0)


func _fade_out() -> void:
	_create_fade_ui()
	_fade_rect.modulate.a = 1.0
	_animate_fade(1.0, 0.0)
	await get_tree().create_timer(fade_duration).timeout
	_remove_fade_ui()


func _create_fade_ui() -> void:
	if _fade_layer == null:
		_fade_layer = CanvasLayer.new()
		_fade_layer.layer = 128  # Acima de tudo
		add_child(_fade_layer)

		_fade_rect = ColorRect.new()
		_fade_rect.color = Color.BLACK
		_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_fade_layer.add_child(_fade_rect)

		# Ajusta ao viewport
		_fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _remove_fade_ui() -> void:
	if _fade_layer != null:
		_fade_layer.queue_free()
		_fade_layer = null
		_fade_rect = null


func _animate_fade(_from: float, to: float) -> void:
	var tween := create_tween()
	tween.tween_property(_fade_rect, "modulate:a", to, fade_duration)
	# Não usamos await aqui — cada chamada espera o timer separadamente
