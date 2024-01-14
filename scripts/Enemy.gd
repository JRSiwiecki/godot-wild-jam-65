extends CharacterBody2D

class_name Enemy

signal died

@export var tower : StaticBody2D

@export var speed : float = 250.0

var tower_position : Vector2

func _ready() -> void:
	tower = get_node("/root/Game/Tower")
	tower_position = tower.position

func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	
	var target_position : Vector2 = (tower_position - position).normalized()
	
	if position.distance_to(tower_position) > 5:
		velocity = target_position * speed
		move_and_slide()
	

func death() -> void:
	died.emit()
