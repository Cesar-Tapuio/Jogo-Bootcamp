extends Area2D

@export var tamanho: Vector2 = Vector2(16, 16)

func _ready() -> void:
	($CollisionShape2D.shape as RectangleShape2D).size = tamanho
