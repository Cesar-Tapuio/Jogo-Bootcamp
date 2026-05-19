extends Node2D

@export var speed_follow: float = 35.0
@export var speed_attack: float = 75.0
@export var follow_dist: float = 55.0

var _player: Node2D = null
var _bob_time := 0.0

@onready var animated: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated.play("voar")
	await get_tree().process_frame
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0]

func _is_passaro() -> bool:
	return _player != null and _player.get("forma_atual") == "passaro"

func _process(delta: float) -> void:
	if _player == null:
		return

	_bob_time += delta
	var to_player: Vector2 = _player.global_position - global_position
	var dist := to_player.length()
	var dir := to_player.normalized() if dist > 0.1 else Vector2.ZERO

	if _is_passaro():
		animated.modulate = Color(1.0, 0.35, 0.35)
		position += dir * speed_attack * delta
		if dist < 10.0 and _player.has_method("take_damage"):
			_player.take_damage(1)
	else:
		animated.modulate = Color(1.0, 1.0, 1.0)
		if dist > follow_dist + 8.0:
			position += dir * speed_follow * delta
		elif dist < follow_dist - 8.0:
			position -= dir * (speed_follow * 0.5) * delta
		else:
			position.y += sin(_bob_time * 3.0) * 12.0 * delta

	animated.flip_h = to_player.x > 0
