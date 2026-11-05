extends Node2D

# Nạp sẵn scene Slime
@export var enemy_scene: PackedScene = preload("res://enemy.tscn")

# Cấu hình cự ly sinh quái quanh Player (px)
@export var min_spawn_distance: float = 260.0  # Khoảng cách tối thiểu (ngoài tầm nhìn/màn hình)
@export var max_spawn_distance: float = 400.0  # Khoảng cách tối đa
@export var max_enemies: int = 15              # Giới hạn số quái tối đa cùng lúc trên map

@onready var spawn_timer: Timer = $SpawnTimer
@onready var player: Node2D = get_tree().root.find_child("player", true, false)

func _ready() -> void:
	if spawn_timer:
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout() -> void:
	if not player or not enemy_scene:
		return

	# Đếm số lượng quái hiện tại thuộc nhóm Enemies trên toàn bản đồ
	var current_enemies = get_tree().get_nodes_in_group("Enemies").size()
	if current_enemies >= max_enemies:
		return

	_spawn_single_enemy()

func _spawn_single_enemy() -> void:
	var enemy_instance = enemy_scene.instantiate()
	
	# Chọn một góc ngẫu nhiên 360 độ (0 -> TAU radian)
	var random_angle = randf() * TAU
	# Chọn một khoảng cách ngẫu nhiên từ min đến max
	var random_distance = randf_range(min_spawn_distance, max_spawn_distance)
	
	# Tính toạ độ offset quanh Player
	var spawn_offset = Vector2(cos(random_angle), sin(random_angle)) * random_distance
	enemy_instance.global_position = player.global_position + spawn_offset
	
	# Thêm quái vào scene chính (get_parent là world)
	get_parent().add_child(enemy_instance)
	print("Đã sinh 1 Slime tại: ", enemy_instance.global_position)
