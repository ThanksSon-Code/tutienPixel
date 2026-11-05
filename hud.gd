extends CanvasLayer

# Tham chiếu đúng 3 node chữ thường trong VBoxContainer
@onready var health_bar: ProgressBar = $VBoxContainer/health
@onready var mana_bar: ProgressBar = $VBoxContainer/mana
@onready var exp_bar: ProgressBar = $VBoxContainer/exp

func _ready() -> void:
	# Khởi tạo giá trị ban đầu phòng khi chưa có tín hiệu từ player
	if health_bar:
		health_bar.max_value = 100.0
		health_bar.value = 100.0
	if mana_bar:
		mana_bar.max_value = 50.0
		mana_bar.value = 50.0
	if exp_bar:
		exp_bar.max_value = 100.0
		exp_bar.value = 0.0

func update_health(current: float, maximum: float) -> void:
	if health_bar:
		health_bar.max_value = maximum
		health_bar.value = current

func update_mana(current: float, maximum: float) -> void:
	if mana_bar:
		mana_bar.max_value = maximum
		mana_bar.value = current

func update_exp(current: float, maximum: float) -> void:
	if exp_bar:
		exp_bar.max_value = maximum
		exp_bar.value = current
