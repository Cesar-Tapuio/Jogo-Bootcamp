extends Node2D

signal ativada

const RAIO_INTERACAO := 22.0

var _ativada := false

@onready var animated: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated.stop()
	animated.frame = 0

func _process(_delta: float) -> void:
	if _ativada:
		return
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var dist := global_position.distance_to(players[0].global_position)
	if dist <= RAIO_INTERACAO and Input.is_action_just_pressed("interagir"):
		_ativar()

func _ativar() -> void:
	_ativada = true
	animated.play("virar alavanca")
	await get_tree().create_timer(3.0 / 5.0).timeout
	animated.stop()
	animated.frame = 2
	ativada.emit()
	var scene := get_tree().current_scene
	var exit := scene.get_node_or_null("LevelExit")
	if exit:
		exit.set_deferred("monitoring", true)
	var passagem := scene.get_node_or_null("passagem")
	if passagem:
		passagem.queue_free()
