extends Area2D
class_name bullet

var speed:Vector2
func _physics_process(delta: float) -> void:
	position += speed * delta

func _on_body_entered(body:PhysicsBody2D):
	if body.is_in_group("enemy"):
		body.queue_free()
		queue_free()
