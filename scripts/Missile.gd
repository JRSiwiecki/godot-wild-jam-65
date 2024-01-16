extends Area2D

class_name Missile

@export var explosion_area : Area2D

@export var missile_speed : float = 300.0

func _physics_process(delta: float) -> void:
	position += transform.x * missile_speed * delta

func explode() -> void:
	for body in explosion_area.get_overlapping_bodies():
		if body is Enemy:
			body.death()

func _on_body_entered(_body: Node2D) -> void:
	explode()
	queue_free()
