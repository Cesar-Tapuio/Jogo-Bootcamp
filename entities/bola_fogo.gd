extends CharacterBody2D

## BolaFogo
## Projétil perseguidor que segue o player (homing).

const SPEED := 300.0
const LIFETIME := 5.0

# Mudamos de Node para Node2D para garantir que tenha 'global_position'
signal bola_destruida

var target: Node2D = null
var shooter: Node2D = null
var _age := 0.0

@onready var animated: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_area: Area2D = $DamageArea

func _ready() -> void:
	if target == null:
		target = get_tree().get_first_node_in_group("player") as Node2D

	if animated.sprite_frames.has_animation("default"):
		animated.play("default")

	damage_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.get("forma_atual") == "passaro":
		if body.has_method("take_damage"):
			body.take_damage(1)
		_destruir()

func _destruir() -> void:
	bola_destruida.emit()
	queue_free()

func _physics_process(delta: float) -> void:
	_age += delta
	if _age >= LIFETIME:
		_destruir()
		return

	if is_instance_valid(target) and target.get("forma_atual") != "passaro":
		queue_free()
		return

	if is_instance_valid(target) and target.is_inside_tree():
		var direction := (target.global_position - global_position).normalized()
		velocity = direction * SPEED
		animated.flip_h = velocity.x < 0

	global_position += velocity * delta
