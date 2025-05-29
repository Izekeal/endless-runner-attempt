extends Node2D

# velocity.x needs to be cast to this script somehow.
# name it world_speed or something, and then pass it into _process here
@onready var timer_label: Label = $CanvasLayer/TimerLabel
@onready var player: Player = $Player
@onready var world_speed = 0

var segments = [
	preload("res://segments/A.tscn"),
	preload("res://segments/B.tscn"),
	preload("res://segments/C.tscn")
]
var time: = 0.0
var is_timer_running = true

func _ready() -> void:
	player.level_finished.connect(finish_level)
	player.update_velocity.connect(update_velocity)
	randomize()
	spawn_instance(0, 0)
	spawn_instance(720,0)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_timer_running:
		time += delta
		timer_label.text = "%.2f" % world_speed
		for area in $Areas.get_children():
			area.position.x -= world_speed * delta
			if area.position.x < -1024:
				spawn_instance(area.position.x+2048,0)
				area.queue_free()
		
		# If the player has stopped moving, they lose
		# Create a game over function that has a play again feature
		# As well as as score breakdown screen
		
		# world_speed never drops below a threshold even when the player is
		# colliding with something. That is because forward collision is not
		# set up yet.
		#if time > 2:
		#	if player.position:
		#		finish_level()
		
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().reload_current_scene()

func update_velocity() -> void:
	world_speed = player.velocity.x
	
func spawn_instance(x, y):
	var inst = segments[randi() % len(segments)].instantiate()
	inst.position = Vector2(x,y)
	$Areas.add_child(inst)
	
func finish_level() -> void:
	player.set_deferred("process_mode", PROCESS_MODE_DISABLED)
	is_timer_running = false
