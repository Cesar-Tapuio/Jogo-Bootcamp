extends Area2D

## LevelExit
## Trigger de saída de fase. Conecte ao final de cada level.
## O jogador entra na área → GameManager carrega a próxima cena.
##
## Uso:
##   1. Instancie esta cena no final de cada mapa
##   2. Configure `next_scene_path` no Inspector
##   3. Adicione uma CollisionShape2D como filha

@export var next_scene_path: String = ""
@export var next_scene_uid: String = ""  # Alternativa: uid (ex: "uid://xxxx")

## Se true, o player precisa pressionar um botão para sair
@export var requires_input: bool = false

var _player_inside := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if next_scene_path.is_empty() and next_scene_uid.is_empty():
		push_error("LevelExit: next_scene_path ou next_scene_uid não configurado em ", name)


func _process(_delta: float) -> void:
	if requires_input and _player_inside:
		if Input.is_action_just_pressed("pular"):
			_trigger_transition()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		if not requires_input:
			_trigger_transition()


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = false


func _trigger_transition() -> void:
	# Desativa para evitar múltiplos disparos
	set_process(false)
	set_deferred("monitoring", false)

	var target := next_scene_path
	if next_scene_uid:
		target = next_scene_uid

	GameManager.change_scene(target)
