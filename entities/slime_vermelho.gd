extends CharacterBody2D

@export var speed: float = 40.0
@export var gravity: float = 980.0

var direction: int = 1
const MAX_FALL_SPEED = 600.0

@onready var animated: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated.play("andando")

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

	for player in get_tree().get_nodes_in_group("player"):
		var p := player as Node2D
		if p == null:
			continue
		var diff_x := p.global_position.x - global_position.x
		var diff_y := p.global_position.y - (global_position.y + 8.0)
		if abs(diff_x) < 15.0 and abs(diff_y) < 14.0:
			p.take_damage(1)
