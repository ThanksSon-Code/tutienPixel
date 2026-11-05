extends CanvasLayer

# Tham chiếu các thanh ProgressBar
@onready var health_bar: ProgressBar = $VBoxContainer/health
@onready var mana_bar: ProgressBar = $VBoxContainer/mana
@onready var exp_bar: ProgressBar = $VBoxContainer/exp

# Tham chiếu các nhãn chữ hiển thị chỉ số
@onready var hp_text: Label = $VBoxContainer/health/hp_text
@onready var mana_text: Label = $VBoxContainer/mana/mana_text
@onready var exp_text: Label = $VBoxContainer/exp/exp_text

func _ready() -> void:
	# Khởi tạo giá trị mặc định cho Máu
	if health_bar:
		health_bar.max_value = 100.0
		health_bar.value = 100.0
	if hp_text:
		hp_text.text = "100/100"
		
	# Khởi tạo giá trị mặc định cho Mana
	if mana_bar:
		mana_bar.max_value = 50.0
		mana_bar.value = 50.0
	if mana_text:
		mana_text.text = "50/50"
		
	# Khởi tạo giá trị mặc định cho EXP
	if exp_bar:
		exp_bar.max_value = 100.0
		exp_bar.value = 0.0
	if exp_text:
		exp_text.text = "0/100"

# Cập nhật thanh Máu và số Máu
func update_health(current: float, maximum: float) -> void:
	if health_bar:
		health_bar.max_value = maximum
		health_bar.value = current
	if hp_text:
		hp_text.text = str(int(current)) + "/" + str(int(maximum))

# Cập nhật thanh Mana và số Mana
func update_mana(current: float, maximum: float) -> void:
	if mana_bar:
		mana_bar.max_value = maximum
		mana_bar.value = current
	if mana_text:
		mana_text.text = str(int(current)) + "/" + str(int(maximum))

# Cập nhật thanh EXP và số EXP
func update_exp(current: float, maximum: float) -> void:
	if exp_bar:
		exp_bar.max_value = maximum
		exp_bar.value = current
	if exp_text:
		exp_text.text = str(int(current)) + "/" + str(int(maximum))
