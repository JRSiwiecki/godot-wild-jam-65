extends CharacterBody2D

class_name Enemy

signal died

@export var tower : StaticBody2D
@export var animated_sprite : AnimatedSprite2D

@export var speed : float = 250.0

enum DEATH_METHODS { EXPLODED, LASERED, NONE }

var tower_position : Vector2
var is_dead : bool = false

func _ready() -> void:
	tower = get_node("/root/Game/Tower")
	
	if !tower:
		return
	
	tower_position = tower.global_position

func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO
	
	if !tower or is_dead:
		return
	
	var target_position : Vector2 = (tower_position - global_position).normalized()
	
	if global_position.distance_to(tower_position) > 5:
		velocity = target_position * speed
		
		animated_sprite.play("run")
		animated_sprite.flip_h = velocity.x <= 0
		
		move_and_slide()
		
	

func play_animation(death_method : DEATH_METHODS) -> void:
	match death_method:
		DEATH_METHODS.EXPLODED:
			animated_sprite.play("explode")
		DEATH_METHODS.LASERED:
			animated_sprite.play("laser")

func death(death_method : DEATH_METHODS) -> void:
	is_dead = true
	play_animation(death_method)
	await get_tree().create_timer(1.1).timeout
	died.emit()
	queue_free()
