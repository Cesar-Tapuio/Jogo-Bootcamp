extends Node2D

const ARCO_SCENE := preload("res://entities/arqueiro/arco.tscn")

@onready var animated: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D

func _ready() -> void:
	var arco := ARCO_SCENE.instantiate()
	add_child(arco)
	arco.position = Vector2(8, 0)
	animated.play("idle")

func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	animated.flip_h = player.global_position.x < global_position.x
