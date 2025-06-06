class_name Heart extends Area2D

func _on_body_entered(body: Node2D) -> void:
	Events.heart_collected.emit()
	queue_free()
