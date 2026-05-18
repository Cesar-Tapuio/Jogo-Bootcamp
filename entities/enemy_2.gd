extends CharacterBody2D

@onready var animated: AnimatedSprite2D = $AnimatedSprite2D
# Certifique-se de que o Player esteja em um grupo chamado "player" 
# ou mude a lógica para buscar pelo nome do nó.
@onready var player = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	# Ativa a animação idle e deixa ela rodando
	animated.play("idle")

func _physics_process(_delta: float) -> void:
	if player:
		# Calcula a direção em relação ao player
		var direction = (player.global_position - global_position).normalized()
		
		
		# Inverte a sprite para olhar para o lado certo
		if direction.x != 0:
			animated.flip_h = direction.x > 0
			
		move_and_slide()
