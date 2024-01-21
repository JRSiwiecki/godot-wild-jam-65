extends Control

@export var tower : Tower
@export var player : Player
@export var game : Game

@export var carrying_power_label : Label
@export var overloaded_label : Label

@export var tower_power_bar : ProgressBar
@export var tower_health_bar : ProgressBar
@export var tower_shield_bar : ProgressBar

func _ready() -> void:
	update_health_label()
	update_shield_label()
	update_power_label()
	update_carrying_power_label()
	update_overloaded_label()

func update_health_label() -> void:
	tower_health_bar.value = tower.current_health

func update_shield_label() -> void:
	tower_shield_bar.value = tower.shield

func update_power_label() -> void:
	tower_power_bar.value = tower.power
	tower_power_bar.max_value = tower.power_threshold

func update_carrying_power_label() -> void:
	carrying_power_label.text = "Carrying Power: " + str(player.power_carried) + " / " + str(player.CARRY_CAPACITY)

func update_overloaded_label() -> void:
	overloaded_label.text = "Times Overloaded: " + str(tower.overload_count) + " / " + str(tower.overloads_to_win)

func _on_tower_damaged() -> void:
	update_health_label()
	update_shield_label()

# Power collected
func _on_game_collected() -> void:
	update_carrying_power_label()

func _on_tower_powered() -> void:
	update_power_label()
	update_health_label()
	update_shield_label()
	update_overloaded_label()

func _on_tower_drained() -> void:
	update_power_label()
