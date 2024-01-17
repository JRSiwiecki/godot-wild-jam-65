extends StaticBody2D

class_name Tower

signal damaged
signal powered
signal drained

@export var aoe_attack_area : Area2D
@export var aoe_attack_timer : Timer

@export var laser_attack_area : Area2D
@export var laser_attack_timer : Timer
@export var laser_attack_raycast : RayCast2D

@export var missile_scene : PackedScene
@export var missile_attack_timer : Timer

@export var no_power_timer : Timer

@export var max_health : int = 100
@export var damage_per_enemy : int = 25
@export var power_drain : int = 1


enum POWER_LEVELS { NO_POWER = 0, LOW_POWER = 25, 
					MID_POWER = 50, HIGH_POWER = 75, 
					OVERLOAD_POWER = 100}

var current_health : int = max_health
var power : int = 25
var health_regen : int = 25

# Attack variables
var can_aoe_attack : bool = true
var can_laser_attack : bool = true
var can_missile_attack : bool = true
var can_spiral_attack : bool = true

func _process(_delta: float) -> void:
	if can_aoe_attack and power >= POWER_LEVELS.NO_POWER:
		aoe_attack()
	
	if can_laser_attack and power >= POWER_LEVELS.LOW_POWER:
		laser_attack()
	
	if can_missile_attack and power >= POWER_LEVELS.MID_POWER:
		missile_attack()
	
	if can_spiral_attack and power >= POWER_LEVELS.HIGH_POWER:
		spiral_attack()

func regenerate_health() -> void:
	current_health += health_regen
	current_health = clampi(current_health, 0, max_health)

func aoe_attack() -> void:
	# Attack all enemies in area
	for body in aoe_attack_area.get_overlapping_bodies():
		if body is Enemy:
			body.death()
	
	# Reset AOE attack
	aoe_attack_timer.start()
	can_aoe_attack = false

func laser_attack() -> void:
	# Find closest enemy
	var closest_enemy : Node2D = find_closest_enemy()
	
	# No enemy found
	if !closest_enemy:
		return
	
	# Attack enemy with laser
	laser_attack_raycast.target_position = closest_enemy.global_position
	var enemy_being_attacked : Object = laser_attack_raycast.get_collider()
	
	if enemy_being_attacked and enemy_being_attacked.has_method("death"):
		enemy_being_attacked.death()
	
	# Reset laser attack
	laser_attack_timer.start()
	can_laser_attack = false

func missile_attack() -> void:
	# Find closest enemy
	var closest_enemy : Node2D = find_closest_enemy()
	
	# No enemy found
	if !closest_enemy:
		return
	
	# Fire missile
	var missile : Missile = missile_scene.instantiate()
	owner.add_child(missile)
	missile.target = closest_enemy
	
	missile_attack_timer.start()
	can_missile_attack = false

func spiral_attack() -> void:
	pass

func find_closest_enemy() -> Node2D:
	# Find all enemies in laser range
	var enemies : Array = []
	
	for body in laser_attack_area.get_overlapping_bodies():
		if body is Enemy:
			enemies.append(body)
	
	var closest_enemy = null
	var shortest_distance : float = 100000.0
	for enemy in enemies:
		var distance : float = global_position.distance_to(enemy.global_position)
		
		if distance < shortest_distance:
			shortest_distance = distance
			closest_enemy = enemy
	
	return closest_enemy

func _on_damage_area_body_entered(body: Node2D) -> void:
	if body is Enemy:
		current_health -= damage_per_enemy
		
		if current_health <= 0:
			queue_free()
			get_tree().quit()
		
		body.death()
		damaged.emit()

func _on_power_deposit_area_body_entered(body: Node2D) -> void:
	if body is Player and body.power_carried > 0:
		power += body.power_carried
		body.power_carried = 0
		no_power_timer.stop()
		powered.emit()

func _on_aoe_attack_timer_timeout() -> void:
	can_aoe_attack = true


func _on_laser_attack_timer_timeout() -> void:
	can_laser_attack = true


func _on_missile_attack_timer_timeout() -> void:
	can_missile_attack = true


func _on_no_power_timer_timeout() -> void:
	queue_free()
	get_tree().quit()


func _on_drain_power_timer_timeout() -> void:
	power = max(power - power_drain, 0)
	
	if power <= 0:
		no_power_timer.start()
	
	drained.emit()
