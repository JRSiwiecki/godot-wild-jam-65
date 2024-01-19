extends CharacterBody2D

class_name Player

@export var speed : float = 1500.0
@export var CARRY_CAPACITY : int = 50

var power_carried : int = 0
var power_types_carried : Array = []

func _physics_process(_delta: float) -> void:
	var direction : Vector2 = Input.get_vector("left", "right", "up", "down").normalized()
	velocity = direction * speed
	
	move_and_slide()

func add_power_type_carried(power_type : Power.POWER_TYPE) -> void:
	power_types_carried.append(power_type)

func reset_power_types_carried() -> void:
	power_types_carried = []
