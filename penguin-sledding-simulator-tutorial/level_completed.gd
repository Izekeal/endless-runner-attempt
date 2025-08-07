extends ColorRect

signal retry_pressed()

@onready var retry_button = %RetryButton

func _on_retry_button_pressed():
	retry_pressed.emit()
	
