extends Node2D

signal power_spawned
signal enemy_spawned

@export var enemy_scene : PackedScene
@export var power_scene : PackedScene

@export var enemy_group : Node2D
@export var power_group : Node2D
@export var spawn_area : Area2D

@export var tower : Tower

func _ready() -> void:
	randomize()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _on_power_spawn_timer_timeout() -> void:
	spawn_power()

func spawn_power() -> void:
	# Instantiate new power scene
	var power = power_scene.instantiate()
	power_group.add_child(power)
	
	# Calculate a random position within the spawn area's bounds
	var spawn_rect = spawn_area.get_viewport_rect()
	var random_x = randf_range(-spawn_rect.size.x, spawn_rect.size.x)
	var random_y = randf_range(-spawn_rect.size.y, spawn_rect.size.y)
	var random_power_position = Vector2(random_x, random_y)

	# Set random position and emit power spawned signal
	power.position = random_power_position
	power_spawned.emit()

func spawn_enemy() -> void:
	pass
