extends CharacterBody2D

@export var max_health: float = 50.0
@export var speed: float = 60.0
@export var exp_reward: float = 25.0

var current_health: float = 50.0

@onready var player: Node2D = get_tree().root.find_child("player", true, false)

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	current_health = max_health

func _physics_process(_delta: float) -> void:
	# Quái tự động đi lại gần người chơi
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

# Hàm nhận sát thương (được gọi khi kiếm khí hoặc đòn chém trúng)
func take_damage(amount: float) -> void:
	current_health -= amount
	print("Quái bị chém trúng! Máu còn: ", current_health)
	
	# Hiệu ứng nháy đỏ khi bị trúng đòn
	modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

	# Nếu hết máu thì biến mất và cộng EXP cho Player
	if current_health <= 0:
		die()

func die() -> void:
	print("Quái đã bị tiêu diệt!")
	# Thưởng kinh nghiệm nếu player có hàm nhận EXP
	if player and player.has_method("gain_exp"):
		player.gain_exp(exp_reward)
	queue_free()
