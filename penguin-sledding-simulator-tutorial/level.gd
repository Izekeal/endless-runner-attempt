extends Node2D

# velocity.x needs to be cast to this script somehow.
# name it world_speed or something, and then pass it into _process here
@onready var timer_label: Label = $CanvasLayer/TimerLabel
@onready var player: Player = $Player
@onready var world_speed = 0

var time: = 0.0
var is_timer_running = true

func _ready() -> void:
	player.level_finished.connect(finish_level)
	player.update_velocity.connect(update_velocity)
	randomize()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_timer_running:
		time += delta
		timer_label.text = "%.2f" % time
		#areas move left by velocity.x * delta or w/e
		#player.move_and_slide()
		for area in $Areas.get_children():
			area.position.x -= world_speed * delta
		
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().reload_current_scene()

func update_velocity() -> void:
	world_speed = player.velocity.x
	
func finish_level() -> void:
	player.set_deferred("process_mode", PROCESS_MODE_DISABLED)
	is_timer_running = false
