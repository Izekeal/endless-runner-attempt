class_name Player extends CharacterBody2D

@export var acceleration: = 120 	# 120 originally
@export var max_speed: = 350 		# 350 originally
@export var velocity_backup = 0
@export var friction: = 200
@export var air_friction: = 60
@export var up_gravity: = 250
@export var down_gravity: = 500
@export var jump_force: = 180
@export var unjump_force: = 25
@export var landing_acceleration: = 2250.0
@export var air_jump_speed_reduction: = 1500
@export var coyote_time_amount = 0.1
@export var min_zoom_amount: = 0.7
@export var max_zoom_amount: = 1.5


var target_tilt: = 0.0
var air_jump: = true
var coyote_time: = 0.0
var finish_x: = -1.0

@onready var anchor: Node2D = $Anchor
@onready var sprite_2d: Sprite2D = $Anchor/Sprite2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var ray_cast_forward: RayCast2D = $RayCastForward
@onready var ray_cast_backward: RayCast2D = $RayCastBackward

signal level_finished()
signal update_velocity()

func _ready() -> void:
	camera_2d.zoom = Vector2(max_zoom_amount, max_zoom_amount)
	
# process a single frame of movement (physics)
func _physics_process(delta: float) -> void:
	coyote_time += delta
	
	# DEBUG Only, eventually to be removed
	
	#if Input.is_action_pressed("ui_right"):
		#max_speed += 1
		#
	#if Input.is_action_pressed("ui_left"):
		#max_speed -= 1
		#
	#if Input.is_key_pressed(KEY_K):
		#acceleration += 1
	#
	#if Input.is_key_pressed(KEY_J):
		#acceleration -= 1
	
	check_for_finish_line()
	signal_velocity()
	check_for_collision()
	check_death_plane()
	
	if is_on_floor() or coyote_time <= coyote_time_amount:
		gpu_particles_2d.emitting = true
		air_jump = true
		target_tilt = 0.0
		# accelerate towards max speed, else: use friction to slow down to max speed
		if velocity.x <= max_speed:
			velocity.x = move_toward(velocity.x, max_speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, max_speed, friction * delta)
			
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = -jump_force
	else:
		gpu_particles_2d.emitting = false
		target_tilt = clamp(velocity.y / 4, -30, 30)
		
		#air friction can slow the player down all the way to 0
		velocity.x = move_toward(velocity.x, 0, air_friction * delta)
		
		if Input.is_action_just_pressed("ui_up") and air_jump:
			velocity.y = -jump_force
			velocity.x -= air_jump_speed_reduction * delta
			air_jump = false
			var tween = create_tween()
			tween.tween_property(sprite_2d, "rotation_degrees", 0, 0.4).from(360 + sprite_2d.rotation_degrees)
			
		if Input.is_action_just_released("ui_up"):
			velocity.y = unjump_force
			
		if velocity.y > 0:
			velocity.y += down_gravity * delta
		else:
			velocity.y += up_gravity * delta
	
	var previous_velocity = velocity
	var was_on_floor = is_on_floor()
	
	# Temporarily change velocity.x to zero but then restore the value
	# after move_and_slide().
	# TO-DO: Clean this up
	velocity_backup = velocity.x
	velocity.x = 0
	move_and_slide()
	velocity.x = velocity_backup
	
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	
	if just_left_ledge:
		coyote_time = 0	
	
	if velocity.y == 0 and previous_velocity.y > 5:
		anchor.scale = Vector2(1.5, 0.8)
		velocity.x += landing_acceleration * delta
		
	sprite_2d.rotation_degrees = lerp(sprite_2d.rotation_degrees, target_tilt, 0.2)
	anchor.scale = anchor.scale.lerp(Vector2.ONE, 0.05)
	
	var y_offset_target: float = clamp(ray_cast_2d.get_collision_point().y - global_position.y, -16, 100)
	camera_2d.offset.y = lerp(camera_2d.offset.y, y_offset_target, 0.02)
	
	var x_offset_target: float = clamp(velocity.x, 64, 128)
	camera_2d.offset.x = lerp(camera_2d.offset.x, x_offset_target, 0.02)
	
	var zoom_target_amount: float = clamp(max_zoom_amount - (velocity.x / 150), min_zoom_amount, max_zoom_amount)
	var zoom_target: = Vector2(zoom_target_amount, zoom_target_amount)
	camera_2d.zoom = camera_2d.zoom.lerp(zoom_target, 0.02)


func check_death_plane() -> void:
	if global_position.y > 1000:
		level_finished.emit()
		gpu_particles_2d.set_deferred("emitting", false)

func check_for_finish_line() -> void:
	if global_position.x > finish_x and finish_x != -1:
		level_finished.emit()
		gpu_particles_2d.set_deferred("emitting", false)

func signal_velocity() ->  void:
	update_velocity.emit()

# This checks for a forward collision.
# TO-DO: Determine a method to allow for the player to *bonk* on ceilings
# without triggering a level_finished
# 
# I think I have that figured out by adjusting the size of the raycasts
func check_for_collision():
	if ray_cast_forward.is_colliding():
		var collision = ray_cast_forward.get_collision_point()
		if global_position.x > (collision.x - 20):
			level_finished.emit()
			gpu_particles_2d.set_deferred("emitting", false)
	
	if ray_cast_backward.is_colliding():
		var collision = ray_cast_backward.get_collision_point()
		if global_position.x > (collision.x - 20):
			level_finished.emit()
			gpu_particles_2d.set_deferred("emitting", false)
