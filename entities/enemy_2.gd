extends CharacterBody2D

## Enemy2 - Torre que atira BolaFogo
## S atira quando o player est na forma PASSARO e dentro do alcance.

const BOLA_FOGO_SCENE := preload("res://entities/bola_fogo.tscn")

## Distncia mxima para comear a atirar (em pixels)
@export var shoot_range: float = 350.0
## Intervalo entre tiros (em segundos)
@export var fire_rate: float = 2.0

var _fire_cooldown := 0.0
var _player: CharacterBody2D = null
var _podia_atirar := false

@onready var animated: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	animated.play(&"idle")
	_player = get_tree().get_first_node_in_group("player") as CharacterBody2D


func _physics_process(delta: float) -> void:
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as CharacterBody2D

	if _player == null:
		return

	# Calcula distncia e direo at o player
	var direction := (_player.global_position - global_position).normalized()
	var distance := global_position.distance_to(_player.global_position)

	# Inverte a sprite para olhar na direo do player
	if direction.x != 0:
		animated.flip_h = direction.x > 0

	# Verifica se pode atirar
	var pode_atirar := _pode_atirar(distance)

	if pode_atirar:
		if not _podia_atirar:
			_atirar(direction)
			_fire_cooldown = 0.0
		else:
			_fire_cooldown += delta
			if _fire_cooldown >= fire_rate:
				_atirar(direction)
				_fire_cooldown = 0.0
	else:
		_fire_cooldown = 0.0

	_podia_atirar = pode_atirar


func _pode_atirar(distance: float) -> bool:
	# Fora do alcance
	if distance > shoot_range:
		return false

	# Player precisa estar na forma passaro
	if not _player.has_method(&"trocar_forma"):
		return false

	# Acessa a varivel forma_atual diretamente
	if _player.get(&"forma_atual") != "passaro":
		return false

	return true


func _on_bola_destruida() -> void:
	if not is_instance_valid(_player):
		return
	var distance := global_position.distance_to(_player.global_position)
	if _pode_atirar(distance):
		var direction := (_player.global_position - global_position).normalized()
		call_deferred("_atirar", direction)
		_fire_cooldown = 0.0


func _atirar(direction: Vector2) -> void:
	if not is_inside_tree():
		return

	var bola := BOLA_FOGO_SCENE.instantiate() as CharacterBody2D
	if bola == null:
		return

	# Posiciona a bola na frente do inimigo na direo do player
	var offset := direction * 20.0
	bola.global_position = global_position + offset
	bola.target = _player
	bola.shooter = self
	bola.bola_destruida.connect(_on_bola_destruida)

	get_parent().add_child(bola)
