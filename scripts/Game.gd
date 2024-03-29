extends Node2D

class_name Game

signal power_spawned
signal enemy_spawned
signal enemy_killed
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
@export var power_spawn_timer : Timer
@export var enemy_spawn_timer : Timer

var enemies_killed : int

func _ready() -> void:
	randomize()
	
	# Starting power
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
	
	# Connect power collected signal
	power.collected.connect(_on_power_collected, power.power_type)

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
	
	# Connect enemy death signal
	enemy.died.connect(_on_enemy_killed)

func _on_power_spawn_timer_timeout() -> void:
	spawn_power()

func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()

func _on_power_collected(power_type : Power.POWER_TYPE) -> void:
	# Use normal battery power for normal battery
	# Use special battery power for any other battery
	if power_type == Power.POWER_TYPE.POWER:
		player.power_carried += Globals.power_per_normal_battery
	else:
		player.power_carried += Globals.power_per_special_battery
	
	player.add_power_type_carried(power_type)
	player.power_carried = clampi(player.power_carried, 0, player.CARRY_CAPACITY)
	collected.emit()

func _on_enemy_killed() -> void:
	enemies_killed += 1
	enemy_killed.emit()

func _on_tower_powered() -> void:
	collected.emit()

func _on_tower_overloaded() -> void:
	power_spawn_timer.stop()
	power_spawn_timer.wait_time -= 0.25
	power_spawn_timer.start()
	
	enemy_spawn_timer.stop()
	enemy_spawn_timer.wait_time -= 0.10
	enemy_spawn_timer.start()
