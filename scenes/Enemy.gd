extends CharacterBody2D

@export var tower : StaticBody2D

@export var speed : float = 250.0

var tower_position
var target_position

func _ready() -> void:
	tower = get_node("/root/Game/Tower")
	tower_position = tower.position

func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	
	target_position = (tower_position - position).normalized()
	
	if position.distance_to(tower_position) > 3:
		velocity = target_position * speed
		move_and_slide()
	
