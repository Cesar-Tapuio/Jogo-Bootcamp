extends Node2D

const SPEED := 180.0
const MAX_DISTANCE := 400.0

var _direction: Vector2 = Vector2.RIGHT
var _start_pos: Vector2
var _excluded_rids: Array[RID] = []

func _ready() -> void:
	_start_pos = global_position
	$CharacterBody2D/AnimatedSprite2D.play("default")

func setup(dir: Vector2) -> void:
	_direction = dir.normalized()
	rotation = _direction.angle()

func _process(delta: float) -> void:
	var step := _direction * SPEED * delta
	var space := get_world_2d().direct_space_state
	var excl: Array[RID] = [$CharacterBody2D.get_rid()]
	excl.append_array(_excluded_rids)
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + step * 2.5
	)
	query.exclude = excl
	var hit := space.intersect_ray(query)

	if not hit.is_empty():
		var collider = hit.get("collider")
		if collider != null and collider.is_in_group("player"):
			if collider.has_method("take_damage"):
				collider.take_damage(1)
			_excluded_rids.append(hit["rid"])
		else:
			queue_free()
			return

	global_position += step

	if global_position.distance_to(_start_pos) > MAX_DISTANCE:
		queue_free()
