extends CanvasLayer

@onready var health_bar: ProgressBar = $VBoxContainer/HealthBar
@onready var mana_bar: ProgressBar = $VBoxContainer/ManaBar
@onready var exp_bar: ProgressBar = $VBoxContainer/ExpBar

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
