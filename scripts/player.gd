extends CharacterBody2D

@onready var animated: AnimatedSprite2D = $AnimatedSprite2D
@onready var colisor_player: CollisionShape2D = $ColisorPlayer
@onready var colisor_rato: CollisionShape2D = $ColisorRato
@onready var colisor_passaro: CollisionShape2D = $ColisorPassaro
@onready var colisor_cachorro: CollisionShape2D = $ColisorCachorro

const SPEED = 80
const SPEED_CACHORRO = 140
const SPEED_PASSARO = 120
const JUMP_VELOCITY = -220
const JUMP_RATO = -180
const JUMP_CACHORRO = -310

var jump_buffer_time := 0.15
var jump_buffer_counter := 0.0

var forma_atual := "humano"
var _forma_anterior := ""

var health := 3
var max_health := 3
const HUD_SLOTS := 3
const INVINCIBILITY_TIME := 1.5
var _invincible := false
var _invincibility_timer := 0.0
var _heart_rects: Array = []

const TEX_FULL    = preload("res://sprites/heart/heart.png")
const TEX_EMPTY   = preload("res://sprites/heart/background.png")
const TEX_UNAVAIL = preload("res://sprites/heart/border.png")

func _ready() -> void:
	atualizar_estado_visual()
	_create_hud()
	_update_hud()

func _create_hud() -> void:
	var hud := CanvasLayer.new()
	add_child(hud)
	var container := HBoxContainer.new()
	container.add_theme_constant_override("separation", 2)
	container.position = Vector2(4, 4)
	hud.add_child(container)
	for i in HUD_SLOTS:
		var heart := TextureRect.new()
		heart.texture = TEX_FULL
		heart.custom_minimum_size = Vector2(17, 17)
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		container.add_child(heart)
		_heart_rects.append(heart)

func _update_hud() -> void:
	for i in _heart_rects.size():

		if i < health:
			_heart_rects[i].texture = TEX_FULL
		else:
			_heart_rects[i].texture = TEX_EMPTY

func take_damage(amount: int) -> void:
	if _invincible:
		return
	health = max(health - amount, 0)
	_update_hud()
	if health <= 0:
		_invincible = true
		_invincibility_timer = INVINCIBILITY_TIME
		get_tree().call_deferred("reload_current_scene")
		return
	_invincible = true
	_invincibility_timer = INVINCIBILITY_TIME

func _morrer() -> void:
	if _invincible:
		return
	health = 0
	_update_hud()
	_invincible = true
	get_tree().call_deferred("reload_current_scene")

func _physics_process(delta: float) -> void:
	# Morte por líquido
	if not _invincible:
		for zona in get_tree().get_nodes_in_group("liquido"):
			var area := zona as Area2D
			if area != null and area.get_overlapping_bodies().has(self):
				_morrer()
				return

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

	# 2. Lógica do Jump Buffer
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

	# 4. Pulo
	if jump_buffer_counter > 0 and is_on_floor() and forma_atual != "passaro":
		if forma_atual == "rato":
			velocity.y = JUMP_RATO
		elif forma_atual == "cachorro":
			velocity.y = JUMP_CACHORRO
		else:
			velocity.y = JUMP_VELOCITY
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

		if direction:
			velocity.x = direction * velocidade_final
			animated.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, velocidade_final)

	atualizar_estado_visual()
	move_and_slide()

func get_feet_y() -> float:
	var col := _colisor_de(forma_atual)
	var shape := col.shape as RectangleShape2D
	return col.global_position.y + shape.size.y * 0.5

func _colisor_de(forma: String) -> CollisionShape2D:
	match forma:
		"rato":     return colisor_rato
		"passaro":  return colisor_passaro
		"cachorro": return colisor_cachorro
		_:          return colisor_player

func _tem_espaco_para(forma_alvo: String) -> bool:
	var col_atual := _colisor_de(forma_atual)
	var col_alvo := _colisor_de(forma_alvo)
	var shape_alvo := col_alvo.shape as RectangleShape2D
	var floor_y := col_atual.global_position.y + (col_atual.shape as RectangleShape2D).size.y * 0.5
	var topo_alvo := floor_y - shape_alvo.size.y
	var query := PhysicsRayQueryParameters2D.create(
		Vector2(global_position.x, floor_y - 1.0),
		Vector2(global_position.x, topo_alvo),
		collision_mask
	)
	query.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func trocar_forma(nova_forma: String):
	var forma_pretendida: String
	if forma_atual == nova_forma:
		forma_pretendida = "humano"
	else:
		forma_pretendida = nova_forma

	if not _tem_espaco_para(forma_pretendida):
		return

	forma_atual = forma_pretendida

	if forma_atual == "humano" and is_on_floor():
		position.y -= 10

	var old_health := health
	var old_max := max_health
	max_health = 1 if forma_atual in ["rato", "passaro"] else 3
	health = min(health, max_health)
	if health != old_health or max_health > old_max:
		_update_hud()

func atualizar_estado_visual() -> void:
	if forma_atual != _forma_anterior:
		_forma_anterior = forma_atual
		colisor_player.set_deferred("disabled", true)
		colisor_rato.set_deferred("disabled", true)
		colisor_passaro.set_deferred("disabled", true)
		colisor_cachorro.set_deferred("disabled", true)
		match forma_atual:
			"rato":     colisor_rato.set_deferred("disabled", false)
			"passaro":  colisor_passaro.set_deferred("disabled", false)
			"cachorro": colisor_cachorro.set_deferred("disabled", false)
			"humano":   colisor_player.set_deferred("disabled", false)

	var direction = Input.get_axis("esquerda", "direita")
	match forma_atual:
		"rato":
			animated.play("rato_correndo" if direction != 0 else "idle_rato")
			if not is_on_floor(): animated.play("rato_pulando")
		"passaro":
			if velocity.length() > 0: animated.play("voar_passaro")
			elif is_on_floor(): animated.play("idle_passaro")
			else: animated.play("voar_passaro")
		"cachorro":
			animated.play("cao_correndo" if direction != 0 else "idle_cao")
			if not is_on_floor(): animated.play("cao_pulando")
		"humano":
			animated.play("caminhar_player" if direction != 0 else "idle_player")
			if not is_on_floor(): animated.play("pulo_player")
