extends CharacterBody2D

@export var speed: float = 40.0
@export var gravity: float = 980.0

var direction: int = 1
const MAX_FALL_SPEED = 600.0

@onready var animated: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated.play("andando")
	_criar_area_dano()

func _criar_area_dano() -> void:
	var area := Area2D.new()
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	# Maior que a collision shape para capturar contato por cima também
	shape.size = Vector2(11, 20)
	shape_node.shape = shape
	shape_node.position = Vector2(-0.5, 1)
	area.add_child(shape_node)
	add_child(area)
	area.body_entered.connect(_on_contato_player)

func _on_contato_player(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(1)

func _tem_chao_a_frente() -> bool:
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		global_position + Vector2(direction * 6, 8),
		global_position + Vector2(direction * 6, 22),
		collision_mask
	)
	query.exclude = [get_rid()]
	return not space.intersect_ray(query).is_empty()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y = min(velocity.y + gravity * delta, MAX_FALL_SPEED)

	if is_on_wall() or (is_on_floor() and not _tem_chao_a_frente()):
		direction *= -1
		animated.flip_h = direction < 0

	velocity.x = direction * speed
	move_and_slide()
