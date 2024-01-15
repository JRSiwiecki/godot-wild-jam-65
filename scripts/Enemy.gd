extends CharacterBody2D

class_name Enemy

signal died

@export var tower : StaticBody2D

@export var speed : float = 250.0

var tower_position : Vector2

func _ready() -> void:
	tower = get_node("/root/Game/Tower")
	
	if !tower:
		return
	
	tower_position = tower.global_position

func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO
	
	if !tower:
		return
	
	var target_position : Vector2 = (tower_position - global_position).normalized()
	
	if global_position.distance_to(tower_position) > 5:
		velocity = target_position * speed
		move_and_slide()
	

func death() -> void:
	died.emit()
	queue_free()
