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
const JUMP_VELOCITY = -220
const JUMP_RATO = -180
const JUMP_CACHORRO = -310

var jump_buffer_time := 0.15
var jump_buffer_counter := 0.0

var forma_atual := "humano"

var health := 3
var max_health := 3
const HUD_SLOTS := 3
const INVINCIBILITY_TIME := 1.5
var _invincible := false
var _invincibility_timer := 0.0
var _heart_rects: Array = []

func _ready() -> void:
	atualizar_estado_visual()
	_create_hud()

func _create_hud() -> void:
	var hud := CanvasLayer.new()
	add_child(hud)
	var container := HBoxContainer.new()
	container.position = Vector2(4, 4)
	hud.add_child(container)
	for i in HUD_SLOTS:
		if i > 0:
			var sep := Control.new()
			sep.custom_minimum_size = Vector2(2, 0)
			container.add_child(sep)
		var heart := ColorRect.new()
		heart.custom_minimum_size = Vector2(8, 8)
		heart.color = Color.RED
		container.add_child(heart)
		_heart_rects.append(heart)

func _update_hud() -> void:
	for i in _heart_rects.size():
		if i >= max_health:
			_heart_rects[i].color = Color(0.1, 0.1, 0.1)
		elif i < health:
			_heart_rects[i].color = Color.RED
		else:
			_heart_rects[i].color = Color(0.25, 0.25, 0.25)

func take_damage(amount: int) -> void:
	if _invincible:
		return
	health = max(health - amount, 0)
	_update_hud()
	if health <= 0:
		get_tree().call_deferred("reload_current_scene")
		return
	_invincible = true
	_invincibility_timer = INVINCIBILITY_TIME

func _physics_process(delta: float) -> void:
	# Invencibilidade pós-dano com efeito de piscar
	if _invincible:
		_invincibility_timer -= delta
		animated.modulate.a = 0.0 if fmod(_invincibility_timer, 0.3) < 0.15 else 1.0
		if _invincibility_timer <= 0.0:
			_invincible = false
			animated.modulate.a = 1.0

	# 1. Gravidade Condicional
	if not is_on_floor():
		if forma_atual != "passaro":
			velocity += get_gravity() * delta
	
	# 2. Lógica do Jump Buffer (CORRIGIDA para pulo único)
	# Alterado para is_action_just_pressed para não pular repetidamente ao segurar
	if Input.is_action_just_pressed("pular"):
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
	if jump_buffer_counter > 0 and is_on_floor() and forma_atual != "passaro":
		if forma_atual == "rato":
			velocity.y = JUMP_RATO
		elif forma_atual == "cachorro":
			velocity.y = JUMP_CACHORRO
		else:
			velocity.y = JUMP_VELOCITY
		
		# Zera o buffer após pular para evitar repetição no próximo frame
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

	max_health = 1 if forma_atual in ["rato", "passaro"] else 3
	health = min(health, max_health)
	_update_hud()

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
			# Restaurado para sua lógica original:
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
