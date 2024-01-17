extends Area2D

class_name Power

signal collected(power_type : Power.POWER_TYPE)

@export var sprite : Sprite2D

@export var power_texture : Texture2D
@export var health_texture : Texture2D
@export var shield_texture : Texture2D
@export var speed_texture : Texture2D

@onready var player : Player = get_node("/root/Game/Player")

enum POWER_TYPE { POWER, HEALTH, SHIELD, SPEED } 

var power_type : POWER_TYPE

func _ready() -> void:
	set_random_power_type()
	change_sprite_texture()

func set_random_power_type() -> void:
	var choice = randf()
	
	# 50% chance for normal power
	# ~17% chance for health, shield, and speed each
	if choice <= 0.5:
		power_type = POWER_TYPE.POWER
	elif choice <= 0.67:
		power_type = POWER_TYPE.HEALTH
	elif choice <= 0.83:
		power_type = POWER_TYPE.SHIELD
	else:
		power_type = POWER_TYPE.SPEED

func change_sprite_texture() -> void:
	match power_type:
		POWER_TYPE.POWER:
			sprite.texture = power_texture
		POWER_TYPE.HEALTH:
			sprite.texture = health_texture
		POWER_TYPE.SHIELD:
			sprite.texture = shield_texture
		POWER_TYPE.SPEED:
			sprite.texture = speed_texture

func _on_body_entered(body: Node2D) -> void:
	if body is Player and player.power_carried < player.CARRY_CAPACITY:
		collected.emit(power_type)
		queue_free()
	
	if body is Tower:
		queue_free()
