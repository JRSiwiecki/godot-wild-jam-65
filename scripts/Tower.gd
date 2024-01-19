extends StaticBody2D

class_name Tower

signal damaged
signal powered
signal drained
signal overloaded

@export var aoe_attack_area : Area2D
@export var aoe_attack_timer : Timer

@export var laser_attack_area : Area2D
@export var laser_attack_timer : Timer
@export var laser_attack_raycast : RayCast2D
@export var laser_attack_line : Line2D

@export var missile_scene : PackedScene
@export var missile_attack_timer : Timer

@export var reduced_cooldown_timer : Timer

@export var no_power_timer : Timer

@export var max_health : int = 100
@export var max_shield : int = 50
@export var health_regen : int = 25
@export var shield_regen : int = 25
@export var damage_per_enemy : int = 25
@export var power_drain : int = 1
@export var power_threshold: int = 125
@export var power_threshold_increase : int = 50
@export var overloads_to_win : int = 3

@export var weapon_cooldown_ratio : float  = 2.0
@export var aoe_attack_base_cooldown : float = 3.0
@export var laser_attack_base_cooldown : float = 1.5
@export var missile_attack_base_cooldown : float = 2.0

@onready var closest_enemy : Node2D = null

enum POWER_LEVELS { NO_POWER = 0, LOW_POWER = 25, 
					MID_POWER = 50, HIGH_POWER = 75, 
					OVERLOAD_POWER = 100}

var current_health : int = max_health
var shield : int = 0
var power : int = 25
var overload_count : int = 0

# Attack variables
var can_aoe_attack : bool = true
var can_laser_attack : bool = true
var can_missile_attack : bool = true

func _ready() -> void:
	reset_weapon_cooldowns()

func _process(_delta: float) -> void:
	closest_enemy = find_closest_enemy()
	
	if can_aoe_attack and power >= POWER_LEVELS.LOW_POWER:
		aoe_attack()
	
	if can_laser_attack and (power >= POWER_LEVELS.MID_POWER or overload_count >= 1):
		laser_attack()
	
	if can_missile_attack and (power >= POWER_LEVELS.HIGH_POWER or overload_count >= 2):
		missile_attack()

func regenerate_health() -> void:
	current_health += health_regen
	current_health = clampi(current_health, 0, max_health)

func regenerate_shield() -> void:
	shield += shield_regen
	shield = clampi(shield, 0, max_shield)

func reduce_weapon_cooldowns() -> void:
	# Don't reduce cooldowns if they are already lowered
	if !reduced_cooldown_timer.is_stopped():
		return
	
	aoe_attack_timer.wait_time = aoe_attack_base_cooldown / weapon_cooldown_ratio
	laser_attack_timer.wait_time = laser_attack_base_cooldown / weapon_cooldown_ratio
	missile_attack_timer.wait_time = missile_attack_base_cooldown / weapon_cooldown_ratio
	
	reduced_cooldown_timer.start()

func reset_weapon_cooldowns() -> void:
	aoe_attack_timer.wait_time = aoe_attack_base_cooldown
	laser_attack_timer.wait_time = laser_attack_base_cooldown
	missile_attack_timer.wait_time = missile_attack_base_cooldown

func aoe_attack() -> void:
	# Attack all enemies in area
	for body in aoe_attack_area.get_overlapping_bodies():
		if body is Enemy:
			body.death()
	
	# Reset AOE attack
	aoe_attack_timer.start()
	can_aoe_attack = false

func laser_attack() -> void:
	# No enemy found
	if !closest_enemy:
		return
	
	# Draw the laser beam
	laser_attack_line.points = [global_position, closest_enemy.global_position]
	
	# Attack enemy with laser
	laser_attack_raycast.target_position = closest_enemy.global_position
	
	var enemy_being_attacked : Object = laser_attack_raycast.get_collider()
	
	if enemy_being_attacked and enemy_being_attacked.has_method("death"):
		enemy_being_attacked.death()
	
	# Reset laser attack
	laser_attack_timer.start()
	can_laser_attack = false

func missile_attack() -> void:
	# No enemy found
	if !closest_enemy:
		return
	
	# Fire missile
	var missile : Missile = missile_scene.instantiate()
	owner.add_child(missile)
	missile.target = closest_enemy
	
	missile_attack_timer.start()
	can_missile_attack = false

func find_closest_enemy() -> Node2D:
	# Find all enemies in laser range
	var enemies : Array = []
	
	for body in laser_attack_area.get_overlapping_bodies():
		if body is Enemy:
			enemies.append(body)
	
	var shortest_distance : float = 100000.0
	for enemy in enemies:
		var distance : float = global_position.distance_to(enemy.global_position)
		
		if distance < shortest_distance:
			shortest_distance = distance
			closest_enemy = enemy
	
	return closest_enemy

func overload() -> void:
	print("overload")
	power_threshold += power_threshold_increase
	power = POWER_LEVELS.LOW_POWER
	overload_count += 1
	overloaded.emit()
	
	if overload_count >= overloads_to_win:
		print("winner")
		tower_death()

func tower_death() -> void:
	queue_free()
	get_tree().quit()

func _on_damage_area_body_entered(body: Node2D) -> void:
	if body is Enemy:
		
		# Use shield first
		var leftover_damage : int = damage_per_enemy
		if shield >= 0:
			leftover_damage = damage_per_enemy - shield
			leftover_damage = clampi(leftover_damage, 0, leftover_damage)
			
			shield -= damage_per_enemy
			shield = max(shield, 0)
		
		current_health -= leftover_damage
		
		if current_health <= 0:
			tower_death()
		
		body.death()
		damaged.emit()

func _on_power_deposit_area_body_entered(body: Node2D) -> void:
	if body is Player and body.power_carried > 0:
		power += body.power_carried
		body.power_carried = 0
		
		if power >= power_threshold:
			overload()
		
		# POWER, HEALTH, SHIELD, SPEED
		for power_type in body.power_types_carried:
			match power_type:
				Power.POWER_TYPE.HEALTH:
					regenerate_health()
				Power.POWER_TYPE.SHIELD:
					regenerate_shield()
				Power.POWER_TYPE.SPEED:
					reduce_weapon_cooldowns()
		
		body.reset_power_types_carried()
		no_power_timer.stop()
		powered.emit()

func _on_aoe_attack_timer_timeout() -> void:
	can_aoe_attack = true


func _on_laser_attack_timer_timeout() -> void:
	can_laser_attack = true


func _on_missile_attack_timer_timeout() -> void:
	can_missile_attack = true


func _on_no_power_timer_timeout() -> void:
	tower_death()


func _on_drain_power_timer_timeout() -> void:
	power = max(power - power_drain, 0)
	
	if power <= 0 and no_power_timer.is_stopped():
		no_power_timer.start()
	
	drained.emit()


func _on_reduced_cooldown_timer_timeout() -> void:
	reset_weapon_cooldowns()
