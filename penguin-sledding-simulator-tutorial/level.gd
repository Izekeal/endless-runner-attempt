extends Node2D

@onready var timer_label: Label = $CanvasLayer/TimerLabel
@onready var max_speed_label: Label = $CanvasLayer/MaxSpeedLabel
@onready var player: Player = $Player
@onready var world_speed = 0
@onready var score = 0
@onready var display_score = 0

# Load all the level segments
# To Do: convert this to a instanced loop with the iterator being
# capital letters
var segments = [
	preload("res://segments/A.tscn"),
	preload("res://segments/B.tscn"),
	preload("res://segments/C.tscn"),
	preload("res://segments/D.tscn"),
	preload("res://segments/E.tscn"),
	preload("res://segments/F.tscn"),
	preload("res://segments/G.tscn"),
	preload("res://segments/H.tscn"),
	preload("res://segments/I.tscn"),
	preload("res://segments/J.tscn"),
	preload("res://segments/K.tscn"),
	preload("res://segments/L.tscn"),
	preload("res://segments/M.tscn")
]

# Time can be used to track when to increase max speed and other "hidden"
# changes to the game.
var time: = 0.0
var is_timer_running = true

func _ready() -> void:
	player.level_finished.connect(finish_level)
	player.update_velocity.connect(update_velocity)
	randomize()
	spawn_instance(0, 0)
	spawn_instance(720,0)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
# TO-DO: clean these all up into separate function calls
func _process(delta: float) -> void:
	if is_timer_running:
		time += delta
		score += .01
		timer_label.text = "%.2f" % score
		max_speed_label.text = "%.2f" % world_speed
		
		# The max game speed is incremented using a timer
		if time > 8:
			player.max_speed += 15
			time = 0
			
		for area in $Areas.get_children():
			area.position.x -= world_speed * delta
			# could move the snow particles here
			# player.gpu_particles_2d.x -= world_speed * delta
			if area.position.x < -1000:
				spawn_instance(area.position.x+1600,0)
				area.queue_free()
		
		# If the player has stopped moving, they lose
		# Create a game over function that has a play again feature
		# As well as as score breakdown screen
		
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().reload_current_scene()

func update_velocity() -> void:
	world_speed = player.velocity.x
	
	# NOTES
	# 350 is a good world speed to begin with
	# 500 is when the game started to feel fast, also the player can now
	# collide with shallower slopes because 500+ speed means the calculations
	# for the raycasting collision now trigger a collision.
	# 500 is also when I would say the game becomes "difficult"
	# Also, the height of the jump starts to feel too "low" at speeds in
	# excess of 500
	
	# Perhaps a +50 max speed increase is a good increment to use
	# As speed increases I can "lower" the min_zoom setting for the camera
	# to accommodate the player a little. Just a smidge each time though so
	# only astute players would pick up on it. And the speed increases
	# indefinitely at the same (random-ish) interval.
	
	# TO-DO: Could clean up that bug with some more code
	# TO-DO: Find the upper limit of speed, when the game completely breaks down
	# Tested: 700, 
	
func spawn_instance(x, y):
	var inst = segments[randi() % len(segments)].instantiate()
	# TO-DO: Figure out how to offset new instances properly.
	# It will likely have something to do with a property of inst. Perhaps
	# size or width or x dimension? With that calculated to a variable I can
	# offset the x value in inst.position = Vector2(x,y) to properly accommodate
	# "areas" of all shapes and sizes
	inst.position = Vector2(x,y)
	$Areas.add_child(inst)
	
func finish_level() -> void:
	player.set_deferred("process_mode", PROCESS_MODE_DISABLED)
	is_timer_running = false
