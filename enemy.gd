extends CharacterBody2D

# --- CHỈ SỐ SLIME ---
@export var max_health: float = 40.0
@export var speed: float = 55.0
@export var damage: float = 12.0          # Sát thương cắn trúng người chơi
@export var attack_cooldown: float = 0.8  # Giãn cách mỗi lần cắn (giây)
@export var exp_reward: float = 30.0

# --- CỰ LY & TRẠNG THÁI AI ---
@export var chase_range: float = 280.0    # Khoảng cách tối đa: vượt quá sẽ ngừng đuổi
@export var heal_duration: float = 5.0    # Thời gian hồi đầy máu (giây)

var current_health: float = 40.0
var can_attack: bool = true
var is_attacking: bool = false
var is_aggro: bool = false                # Cờ trạng thái: Đã bị người chơi tấn công hay chưa
var player_in_range: CharacterBody2D = null

@onready var player: Node2D = get_tree().root.find_child("player", true, false)
@onready var hitbox: Area2D = $Hitbox
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	current_health = max_health
	add_to_group("Enemies")

	# Bắt đầu phát hoạt ảnh nhún nhảy mặc định
	if anim:
		anim.animation_finished.connect(_on_animation_finished)
		anim.play("Slime")

	# Kết nối vùng va chạm cắn
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)
		hitbox.body_exited.connect(_on_hitbox_body_exited)

func _physics_process(delta: float) -> void:
	# 1. Nếu đang phát động tác cắn (Slimeatk) thì đứng yên
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# 2. Xử lý logic truy đuổi
	if player and is_aggro:
		var distance_to_player = global_position.distance_to(player.global_position)
		
		# Nếu người chơi chạy ra quá xa -> Hủy truy đuổi
		if distance_to_player > chase_range:
			is_aggro = false
			velocity = Vector2.ZERO
			print("Người chơi đã chạy quá xa! Slime ngừng đuổi.")
		else:
			# Đang trong tầm truy đuổi -> Di chuyển lại gần
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * speed
			
			if anim:
				if direction.x < 0:
					anim.flip_h = true
				elif direction.x > 0:
					anim.flip_h = false
	else:
		# Chưa bị đánh hoặc người chơi đã bỏ chạy quá xa -> Đứng yên
		velocity = Vector2.ZERO
		
		# 3. Tự hồi phục toàn bộ máu trong 5 giây nếu chưa đầy máu
		if current_health < max_health:
			var regen_per_second = max_health / heal_duration
			current_health = clamp(current_health + regen_per_second * delta, 0.0, max_health)

	# Luôn giữ animation "Slime" nhún nhảy khi không bận tung chiêu
	if anim and not is_attacking and anim.animation != "Slime":
		anim.play("Slime")

	move_and_slide()

	# 4. Tấn công khi người chơi đứng trong tầm chạm
	if player_in_range and can_attack:
		_perform_attack()

# Phát hiện Player bước vào vùng chạm
func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("Player") or body.is_in_group("Players") or "player" in body.name.to_lower():
		player_in_range = body as CharacterBody2D

# Player chạy thoát ra ngoài
func _on_hitbox_body_exited(body: Node) -> void:
	if body == player_in_range:
		player_in_range = null

# Thực hiện đòn tấn công
func _perform_attack() -> void:
	can_attack = false
	is_attacking = true
	
	if anim and anim.sprite_frames.has_animation("Slimeatk"):
		anim.play("Slimeatk")
	else:
		_deal_damage()

# Kết thúc animation cắn -> trừ máu và trở lại trạng thái nhún nhảy
func _on_animation_finished() -> void:
	if anim.animation == "Slimeatk":
		_deal_damage()
		is_attacking = false
		if anim.sprite_frames.has_animation("Slime"):
			anim.play("Slime")

# Trừ máu người chơi
func _deal_damage() -> void:
	if player_in_range and player_in_range.has_method("take_damage"):
		player_in_range.take_damage(damage)
		print("Slime cắn Player trừ: ", damage, " HP")
	
	# Đếm thời gian hồi chiêu
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

# Nhận sát thương khi bị người chơi chém hoặc bắn kiếm khí
func take_damage(amount: float) -> void:
	# Kích hoạt trạng thái truy đuổi ngay khi bị người chơi chủ động tấn công
	is_aggro = true
	
	current_health -= amount
	print("Slime bị đánh! Máu còn: ", current_health)
	
	# Nháy đỏ báo hiệu trúng đòn
	modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

	if current_health <= 0:
		die()

func die() -> void:
	print("Slime đã bị tiêu diệt!")
	if player and player.has_method("gain_exp"):
		player.gain_exp(exp_reward)
	queue_free()
