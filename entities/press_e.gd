extends Node2D

@export var raio: float = 35.0

@onready var animated: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	visible = false

func _process(_delta: float) -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		visible = false
		return
	var perto := global_position.distance_to(players[0].global_position) <= raio
	if perto and not visible:
		visible = true
		animated.play("animation")
	elif not perto and visible:
		visible = false
		animated.stop()
