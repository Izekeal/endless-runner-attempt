extends Node2D

@onready var timer_label: Label = $CanvasLayer/TimerLabel
@onready var player: Player = $Player
@onready var world_speed = 0

var segments = [
	preload("res://segments/A.tscn"),
	preload("res://segments/B.tscn"),
	preload("res://segments/C.tscn"),
	preload("res://segments/D.tscn"),
	preload("res://segments/E.tscn")
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
