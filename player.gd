extends CharacterBody2D

# --- CHỈ SỐ NHÂN VẬT ---
@export var speed: float = 160.0
@export var max_health: float = 100.0
@export var max_mana: float = 50.0
@export var max_exp: float = 100.0

@export var shoot_mana_cost: float = 10.0
@export var melee_mana_cost: float = 0.0     # Chém thường (để 0.0 nếu không tốn mana)
@export var mana_regen_rate: float = 5.0     # Tự hồi phục 5 điểm Mana mỗi giây
@export var melee_damage: float = 35.0       # Sát thương đòn chém thường

var current_health: float = 100.0
var current_mana: float = 50.0
var current_exp: float = 0.0

# Nạp sẵn scene kiếm khí
const SWORD_BEAM_SCENE = preload("res://sword_beam.tscn")

# Tham chiếu tới vùng va chạm cận chiến
@onready var melee_hitbox: Area2D = $MeleeHitbox
@onready var melee_collision: CollisionShape2D = $MeleeHitbox/CollisionShape2D

# Node con và tham chiếu giao diện
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hud: CanvasLayer = get_tree().root.find_child("HUD", true, false)

var is_attacking: bool = false


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	add_to_group("Player")
	if anim:
		anim.animation_finished.connect(_on_animation_finished)
	
	# Mặc định tắt vùng va chạm chém khi vừa vào game
	if melee_collision:
		melee_collision.set_deferred("disabled", true)

	# Bắt sự kiện khi vùng chém quét trúng vật thể
	if melee_hitbox:
		melee_hitbox.body_entered.connect(_on_melee_hitbox_body_entered)
	
	_cap_nhat_toan_bo_hud()

func _physics_process(delta: float) -> void:
	# 1. Tự động hồi phục Mana theo thời gian nếu chưa đầy
	if current_mana < max_mana:
		current_mana += mana_regen_rate * delta
		current_mana = clamp(current_mana, 0.0, max_mana)
		if hud:
			hud.update_mana(current_mana, max_mana)

	# 2. Xử lý di chuyển WASD / Phím mũi tên (chỉ khi không đang tung chiêu)
	var direction := Vector2.ZERO
	if not is_attacking:
		if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"): direction.x -= 1.0
		if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"): direction.x += 1.0
		if Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"): direction.y -= 1.0
		if Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"): direction.y += 1.0

	if direction != Vector2.ZERO:
		velocity = direction.normalized() * speed
		if anim and not is_attacking:
			anim.play("walk")
			if direction.x < 0:
				anim.flip_h = true
			elif direction.x > 0:
				anim.flip_h = false
	else:
		velocity = Vector2.ZERO
		if anim and not is_attacking:
			anim.play("idle")

	move_and_slide()

# --- BẮT PHÍM TUNG CHIÊU & TEST CHỈ SỐ ---
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		# CHUỘT TRÁI: Chém cận chiến (Melee)
		if event.button_index == MOUSE_BUTTON_LEFT and not is_attacking:
			_perform_melee()

		# CHUỘT PHẢI: Bắn kiếm khí tầm xa
		elif event.button_index == MOUSE_BUTTON_RIGHT and not is_attacking:
			if current_mana >= shoot_mana_cost:
				_shoot_sword_beam()

	# Phím test tăng giảm chỉ số trực quan
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_H:
			take_damage(20.0)      # Phím H: Trừ 20 HP
		elif event.keycode == KEY_J:
			heal(20.0)             # Phím J: Hồi 20 HP
		elif event.keycode == KEY_K:
			use_mana(15.0)         # Phím K: Trừ 15 Mana
		elif event.keycode == KEY_L:
			restore_mana(15.0)     # Phím L: Hồi 15 Mana

# --- ĐÒN CHÉM CẬN CHIẾN (CHUỘT TRÁI) ---
func _perform_melee() -> void:
	is_attacking = true
	velocity = Vector2.ZERO
	
	# Hướng mặt theo con trỏ chuột
	var mouse_pos = get_global_mouse_position()
	var attack_direction = (mouse_pos - global_position).normalized()
	
	if anim:
		anim.flip_h = (attack_direction.x < 0)
		anim.play("melee")

	# Xoay vùng chém theo hướng chuột và bật va chạm
	if melee_hitbox:
		melee_hitbox.rotation = attack_direction.angle()
	if melee_collision:
		melee_collision.set_deferred("disabled", false)

# --- ĐÒN BẮN KIẾM KHÍ TẦM XA (CHUỘT PHẢI) ---
func _shoot_sword_beam() -> void:
	is_attacking = true
	velocity = Vector2.ZERO
	
	# Trừ mana và cập nhật HUD
	current_mana -= shoot_mana_cost
	if hud:
		hud.update_mana(current_mana, max_mana)

	# Lấy hướng trỏ chuột và lật mặt nhân vật
	var mouse_pos = get_global_mouse_position()
	var attack_direction = (mouse_pos - global_position).normalized()
	
	if anim:
		anim.flip_h = (attack_direction.x < 0)
		anim.play("shoot")

	# Tạo thực thể kiếm khí bay về phía con trỏ chuột
	var beam = SWORD_BEAM_SCENE.instantiate()
	beam.global_position = global_position + (attack_direction * 12.0)
	beam.direction = attack_direction
	beam.rotation = attack_direction.angle()
	
	get_parent().add_child(beam)

# Xử lý khi hoàn tất animation chém hoặc bắn
func _on_animation_finished() -> void:
	if anim.animation == "melee" or anim.animation == "shoot":
		is_attacking = false
		# Tắt vùng va chạm cận chiến sau khi vung kiếm xong
		if melee_collision:
			melee_collision.set_deferred("disabled", true)

# Xử lý khi kiếm chạm trúng quái
func _on_melee_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		print("Chém cận chiến trúng: ", body.name)
		if body.has_method("take_damage"):
			body.take_damage(melee_damage)

# --- HỆ THỐNG QUẢN LÝ MÁU, MANA, EXP & HUD ---
func _cap_nhat_toan_bo_hud() -> void:
	if hud:
		hud.update_health(current_health, max_health)
		hud.update_mana(current_mana, max_mana)
		hud.update_exp(current_exp, max_exp)

func take_damage(amount: float) -> void:
	current_health = clamp(current_health - amount, 0.0, max_health)
	if hud:
		hud.update_health(current_health, max_health)

func heal(amount: float) -> void:
	current_health = clamp(current_health + amount, 0.0, max_health)
	if hud:
		hud.update_health(current_health, max_health)

func use_mana(amount: float) -> void:
	current_mana = clamp(current_mana - amount, 0.0, max_mana)
	if hud:
		hud.update_mana(current_mana, max_mana)

func restore_mana(amount: float) -> void:
	current_mana = clamp(current_mana + amount, 0.0, max_mana)
	if hud:
		hud.update_mana(current_mana, max_mana)

func gain_exp(amount: float) -> void:
	current_exp += amount
	print("Nhận EXP: +", amount, " (Tổng: ", current_exp, "/", max_exp, ")")
	if hud:
		hud.update_exp(current_exp, max_exp)
