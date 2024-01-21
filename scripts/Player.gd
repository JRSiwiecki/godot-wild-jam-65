extends CharacterBody2D

class_name Player

@export var animated_sprite : AnimatedSprite2D

@export var speed : float = 1500.0
@export var CARRY_CAPACITY : int = 50

var power_carried : int = 0
var power_types_carried : Array = []

func _physics_process(_delta: float) -> void:
	var direction : Vector2 = Input.get_vector("left", "right", "up", "down").normalized()
	velocity = direction * speed
	
	if velocity == Vector2.ZERO:
		animated_sprite.play("idle")
	
	else:
		animated_sprite.play("run")
		animated_sprite.flip_h = velocity.x <= 0
	
	move_and_slide()

func add_power_type_carried(power_type : Power.POWER_TYPE) -> void:
	power_types_carried.append(power_type)

func reset_power_types_carried() -> void:
	power_types_carried = []
