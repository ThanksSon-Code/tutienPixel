extends Area2D

@export var speed: float = 450.0
@export var damage: float = 25.0

var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Tự hủy sau 2.5 giây nếu bay ra ngoài bản đồ
	await get_tree().create_timer(2.5).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		return
	if body.is_in_group("Enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
