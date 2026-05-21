extends CharacterBody2D

@export var speed : float = 100.0
@export var gravity : float = 980.0

# Direção inicial (-1 é esquerda)
var direction : int = 1

# Referência ao nó de animação (ajuste o nome se for diferente na sua cena)
@onready var animated_sprite = $AnimatedSprite2D 

func _ready() -> void:
	# Iniciamos a animação quando o inimigo entra na cena
	animated_sprite.play("caminhar")

const MAX_FALL_SPEED = 600.0

func _physics_process(delta: float) -> void:
	# 1. Aplicar Gravidade
	if not is_on_floor():
		velocity.y = min(velocity.y + gravity * delta, MAX_FALL_SPEED)

	# 2. Verificar colisões com paredes
	if is_on_wall():
		direction *= -1
		_update_sprite_direction()
		animated_sprite.play("caminhar")

	# 3. Movimentação

func _update_sprite_direction() -> void:
	# Se a direção for positiva (Direita), não inverte (ou inverte, dependendo da arte)
	# Como o seu está andando de costas, vamos trocar:
	if direction > 0:
		animated_sprite.flip_h = false  # Desliga a inversão quando vai para a direita
	else:
		animated_sprite.flip_h = true   # Liga a inversão quando vai para a esquerda
