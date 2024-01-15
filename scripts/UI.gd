extends Control

@export var tower : Tower

@export var tower_health_label : Label
@export var tower_power_label : Label

func _ready() -> void:
	update_health_label()
	update_power_label()

func _on_tower_damaged() -> void:
	update_health_label()

func update_health_label() -> void:
	tower_health_label.text = "Tower Health: " + str(tower.current_health) + " / " + str(tower.MAX_HEALTH)

func update_power_label() -> void:
	tower_power_label.text = "Tower Power: " + str(tower.power) + " / 100"
