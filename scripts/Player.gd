extends CharacterBody2D

@export var speed = 300.0

func _physics_process(delta: float) -> void:
	
	var direction : Vector2 = Input.get_vector("left", "right", "up", "down").normalized()
	velocity = direction * speed
	
	move_and_slide()
