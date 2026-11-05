extends Area2D

@export var speed: float = 450.0
@export var damage: float = 25.0

var direction: Vector2 = Vector2.ZERO

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if anim:
		# Tắt vòng lặp để không lặp lại hình 1
		anim.sprite_frames.set_animation_loop("fly", false)
		anim.animation_finished.connect(_on_animation_finished)
		anim.play("fly")
	
	# Kết nối cả body_entered (nếu quái là CharacterBody2D) và area_entered (nếu quái dùng Area2D)
	body_entered.connect(_on_hit)
	area_entered.connect(_on_hit)
	
	# Tự hủy sau 2.5 giây
	await get_tree().create_timer(2.5).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		position += direction * speed * delta

func _on_animation_finished() -> void:
	if anim.animation == "fly":
		anim.stop()
		anim.frame = 3 # Giữ ở hình thứ 4

# Hàm xử lý trúng mục tiêu dùng chung cho cả body và area
func _on_hit(target: Node) -> void:
	# Bỏ qua nếu trúng bản thân người chơi
	if target.is_in_group("Player") or target.name == "player":
		return

	# Tìm đối tượng quái (xét chính target hoặc node cha của nó)
	var enemy_node: Node = null
	if target.is_in_group("Enemies"):
		enemy_node = target
	elif target.get_parent() and target.get_parent().is_in_group("Enemies"):
		enemy_node = target.get_parent()

	# Nếu phát hiện mục tiêu thuộc nhóm Enemies
	if enemy_node:
		print("Kiếm khí trúng mục tiêu: ", enemy_node.name)
		if enemy_node.has_method("take_damage"):
			enemy_node.take_damage(damage)
		
		# Vô hiệu hóa va chạm ngay lập tức để tránh trúng 2 lần rồi biến mất
		set_deferred("monitoring", false)
		queue_free()
