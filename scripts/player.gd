extends CharacterBody2D

@onready var animated: AnimatedSprite2D = $AnimatedSprite2D
@onready var colisor_player: CollisionShape2D = $ColisorPlayer
@onready var colisor_rato: CollisionShape2D = $ColisorRato
@onready var colisor_passaro: CollisionShape2D = $ColisorPassaro
@onready var colisor_cachorro: CollisionShape2D = $ColisorCachorro
@onready var colisor_peixe: CollisionShape2D = $ColisorPeixe 

const SPEED = 80
const SPEED_CACHORRO = 140
const SPEED_PEIXE = 30 
const SPEED_PASSARO = 120
const JUMP_VELOCITY = -280
const JUMP_RATO = -180

var jump_buffer_time := 0.15 
var jump_buffer_counter := 0.0

var forma_atual := "humano"

func _physics_process(delta: float) -> void:
	# 1. Gravidade Condicional
	if not is_on_floor():
		if forma_atual != "passaro":
			velocity += get_gravity() * delta
	
	# 2. Lógica do Jump Buffer (Modificada para pulo contínuo)
	# Se estiver segurando o botão, o buffer fica sempre cheio
	if Input.is_action_pressed("pular"):
		jump_buffer_counter = jump_buffer_time
	else:
		jump_buffer_counter -= delta

	# 3. Troca de Formas
	if Input.is_action_just_pressed("transformar_rato"):
		trocar_forma("rato")
	if Input.is_action_just_pressed("transformar_passaro"):
		trocar_forma("passaro")
	if Input.is_action_just_pressed("transformar_cachorro"):
		trocar_forma("cachorro")
	if Input.is_action_just_pressed("transformar_peixe"):
		trocar_forma("peixe")

	# 4. Pulo
	# O personagem pula se o buffer for > 0 (clicou ou está segurando) e encostou no chão
	if jump_buffer_counter > 0 and is_on_floor() and forma_atual != "passaro":
		if forma_atual == "rato":
			velocity.y = JUMP_RATO
		else:
			velocity.y = JUMP_VELOCITY
		
		# Se você NÃO estiver segurando o botão, zeramos o buffer. 
		# Se estiver segurando, o item 2 vai encher ele de novo no próximo frame.
		if not Input.is_action_pressed("pular"):
			jump_buffer_counter = 0

	# 5. Movimentação
	if forma_atual == "passaro":
		var direction_v = Input.get_axis("cima", "baixo")
		var direction_h = Input.get_axis("esquerda", "direita")
		velocity.x = direction_h * SPEED_PASSARO
		velocity.y = direction_v * SPEED_PASSARO
		if direction_h != 0:
			animated.flip_h = direction_h < 0
	else:
		var direction := Input.get_axis("esquerda", "direita")
		var velocidade_final = SPEED
		if forma_atual == "cachorro": velocidade_final = SPEED_CACHORRO
		elif forma_atual == "peixe": velocidade_final = SPEED_PEIXE
		
		if direction:
			velocity.x = direction * velocidade_final
			animated.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, velocidade_final)
	
	atualizar_estado_visual()
	move_and_slide()

func trocar_forma(nova_forma: String):
	if forma_atual == nova_forma:
		forma_atual = "humano"
	else:
		forma_atual = nova_forma
	
	if forma_atual == "humano" and is_on_floor():
		position.y -= 10 

func atualizar_estado_visual() -> void:
	var direction = Input.get_axis("esquerda", "direita")
	colisor_player.set_deferred("disabled", true)
	colisor_rato.set_deferred("disabled", true)
	colisor_passaro.set_deferred("disabled", true)
	colisor_cachorro.set_deferred("disabled", true)
	colisor_peixe.set_deferred("disabled", true)
	
	match forma_atual:
		"rato":
			colisor_rato.set_deferred("disabled", false)
			animated.play("rato_correndo" if direction != 0 else "idle_rato")
			if not is_on_floor(): animated.play("rato_pulando")
		"passaro":
			colisor_passaro.set_deferred("disabled", false)
			if velocity.length() > 0: animated.play("voar_passaro")
			elif is_on_floor(): animated.play("idle_passaro")
			else: animated.play("voar_passaro")
		"cachorro":
			colisor_cachorro.set_deferred("disabled", false)
			animated.play("cao_correndo" if direction != 0 else "idle_cao")
			if not is_on_floor(): animated.play("cao_pulando")
		"peixe":
			colisor_peixe.set_deferred("disabled", false)
			animated.play("peixe_debatendo")
		"humano":
			colisor_player.set_deferred("disabled", false)
			animated.play("caminhar_player" if direction != 0 else "idle_player")
			if not is_on_floor(): animated.play("pulo_player")
