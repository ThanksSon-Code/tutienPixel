extends CharacterBody2D

@export var speed: float = 160.0
@export var max_health: float = 100.0
@export var max_mana: float = 50.0
@export var max_exp: float = 100.0

var current_health: float = 100.0
var current_mana: float = 50.0
var current_exp: float = 0.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# 1. KHAI BÁO THAM CHIẾU HUD Ở ĐÂY (Đầu script)
@onready var hud: CanvasLayer = get_tree().root.find_child("HUD", true, false)

var is_attacking: bool = false

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	
	if anim:
		anim.animation_finished.connect(_on_animation_finished)
	
	# 2. GỌI HÀM CẬP NHẬT HUD BAN ĐẦU KHI VỪA VÀO GAME
	_cap_nhat_toan_bo_hud()

func _physics_process(_delta: float) -> void:
	# Bấm chuột phải để chém melee
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and not is_attacking:
		_perform_melee()

	# Di chuyển WASD / Phím mũi tên
	var direction := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"): direction.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"): direction.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"): direction.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"): direction.y += 1.0

	if direction != Vector2.ZERO:
		velocity = direction.normalized() * speed
		if not is_attacking and anim:
			if direction.x < 0:
				anim.flip_h = true
			elif direction.x > 0:
				anim.flip_h = false
	else:
		velocity = Vector2.ZERO

	if not is_attacking and anim:
		if direction != Vector2.ZERO:
			anim.play("walk")
		else:
			anim.play("idle")

	move_and_slide()

# --- CHIÊU THỨC & ANIMATION ---
func _perform_melee() -> void:
	is_attacking = true
	if anim:
		anim.play("melee")

func _on_animation_finished() -> void:
	if anim.animation == "melee":
		is_attacking = false

# --- 3. ĐỊNH NGHĨA HÀM CẬP NHẬT TOÀN BỘ HUD (Ở cuối script) ---
func _cap_nhat_toan_bo_hud() -> void:
	if hud:
		hud.update_health(current_health, max_health)
		hud.update_mana(current_mana, max_mana)
		hud.update_exp(current_exp, max_exp)

# Hàm nhận sát thương (tự trừ máu và cập nhật thẳng lên HUD)
func take_damage(amount: float) -> void:
	current_health -= amount
	current_health = clamp(current_health, 0.0, max_health)
	if hud:
		hud.update_health(current_health, max_health)
