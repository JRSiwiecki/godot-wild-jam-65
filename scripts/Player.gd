extends CharacterBody2D

class_name Player

@export var animated_sprite : AnimatedSprite2D

@export var speed : float = 1500.0
@export var CARRY_CAPACITY : int = 50

var power_carried : int = 0
var power_types_carried : Array = []

var taking_damage : bool = false
var player_is_dead : bool = false

func _physics_process(_delta: float) -> void:
	var direction : Vector2 = Input.get_vector("left", "right", "up", "down").normalized()
	velocity = direction * speed
	
	play_animation()
	
	if player_is_dead:
		return
	
	move_and_slide()

func play_animation() -> void:
	if player_is_dead:
		animated_sprite.play("death")
	
	elif taking_damage:
		animated_sprite.play("damage")
	
	elif velocity == Vector2.ZERO:
		animated_sprite.play("idle")
	
	else:
		animated_sprite.flip_h = velocity.x <= 0
		animated_sprite.play("run")

func take_damage() -> void:
	taking_damage = true

func death() -> void:
	player_is_dead = true

func add_power_type_carried(power_type : Power.POWER_TYPE) -> void:
	power_types_carried.append(power_type)

func reset_power_types_carried() -> void:
	power_types_carried = []

func _on_animated_sprite_2d_animation_finished() -> void:
	taking_damage = false
