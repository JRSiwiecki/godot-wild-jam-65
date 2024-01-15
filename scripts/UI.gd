extends Control

@export var tower : Tower
@export var player : Player

@export var tower_health_label : Label
@export var tower_power_label : Label
@export var carrying_power_label : Label

func _ready() -> void:
	update_health_label()
	update_power_label()
	update_carrying_power_label()

func update_health_label() -> void:
	tower_health_label.text = "Tower Health: " + str(tower.current_health) + " / " + str(tower.MAX_HEALTH)

func update_power_label() -> void:
	tower_power_label.text = "Tower Power: " + str(tower.power) + " / 100"

func update_carrying_power_label() -> void:
	carrying_power_label.text = "Carrying Power: " + str(player.power_carried) + " / " + str(player.CARRY_CAPACITY)

func _on_tower_damaged() -> void:
	update_health_label()

# Power collected
func _on_game_collected() -> void:
	update_carrying_power_label()

func _on_tower_powered() -> void:
	update_power_label()
