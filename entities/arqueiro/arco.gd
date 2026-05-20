extends Node2D

const FLECHA_SCENE := preload("res://entities/arqueiro/flecha.tscn")
const FIRE_RATE := 1.0

var _base_pos: Vector2
var _fire_timer := 0.0

@onready var animated: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D

func _ready() -> void:
	await get_tree().process_frame
	_base_pos = global_position
	animated.stop()
	animated.frame = 0

func _process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	var dx := player.global_position.x - _base_pos.x
	var dy := player.global_position.y - _base_pos.y

	global_position.x = _base_pos.x - 15.0 if dx < 0 else _base_pos.x

	var apontando_player: bool = abs(dx) >= abs(dy)
	if apontando_player:
		var dir := player.global_position - global_position
		rotation = dir.angle()
	else:
		rotation = PI if dx < 0 else 0.0

	_fire_timer += delta
	if _fire_timer >= FIRE_RATE and apontando_player:
		_fire_timer = 0.0
		_atirar()

func _atirar() -> void:
	animated.play("Atirar")
	var flecha := FLECHA_SCENE.instantiate() as Node2D
	get_parent().add_child(flecha)
	flecha.global_position = global_position
	flecha.setup(Vector2.from_angle(rotation))
	await get_tree().create_timer(3.0 / 5.0).timeout
	animated.stop()
	animated.frame = 0
