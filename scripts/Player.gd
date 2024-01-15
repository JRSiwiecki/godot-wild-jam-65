extends CharacterBody2D

class_name Player

@export var speed : float = 1500.0
@export var CARRY_CAPACITY : int = 50

var power_carried : int = 0

func _physics_process(_delta: float) -> void:
	var direction : Vector2 = Input.get_vector("left", "right", "up", "down").normalized()
	velocity = direction * speed
	
	move_and_slide()
