extends Node2D

signal power_spawned
signal enemy_spawned

signal collected

@export var enemy_scene : PackedScene
@export var power_scene : PackedScene

@export var enemy_group : Node2D
@export var power_group : Node2D
@export var spawn_area : Area2D
@export var enemy_spawn_path : PathFollow2D
@export var enemy_spawn_marker : Marker2D
@export var tower : Tower
@export var player : Player

func _ready() -> void:
	randomize()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

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
	
	# Connect power collected signal
	power.collected.connect(_on_power_collected)

func spawn_enemy() -> void:
	# Instantiate new enemy scene
	var enemy = enemy_scene.instantiate()
	enemy_group.add_child(enemy)
	
	# Randomize spawn position
	enemy_spawn_path.progress_ratio = randf()
	var random_enemy_position = enemy_spawn_marker.global_position
	
	# Set random position and emit enemy spawned signal
	enemy.global_position = random_enemy_position
	enemy_spawned.emit()

func _on_power_spawn_timer_timeout() -> void:
	spawn_power()

func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()

func _on_power_collected() -> void:
	player.power_carried += Globals.power_per_battery
	player.power_carried = clampi(player.power_carried, 0, player.CARRY_CAPACITY)
	collected.emit()

func _on_tower_powered() -> void:
	collected.emit()
