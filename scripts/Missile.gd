extends Area2D

class_name Missile

@export var explosion_area : Area2D
@export var life_timer : Timer

@export var missile_speed : float = 2000.0

var target : Node2D
var direction : Vector2

func _physics_process(delta: float) -> void:
	# Check if target is still valid
	if !is_instance_valid(target):
		explode()
	
	if !direction:
		direction = (target.global_position - global_position).normalized()
		look_at(target.global_position)
	
	global_position += direction * missile_speed * delta
	

func explode() -> void:
	for body in explosion_area.get_overlapping_bodies():
		if body is Enemy:
			body.death()
	
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Tower:
		return
	
	explode()


func _on_life_timer_timeout() -> void:
	explode()
