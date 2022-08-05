extends Area2D

signal hit_enemy(enemy)
export var movement_speed: float = 300
var _velocity: Vector2


func initialize(direction: Vector2):
	self.position = Globals.player_position
	look_at(get_global_mouse_position())
	rotate(deg2rad(90))
	set_as_toplevel(true)
	_velocity = direction * movement_speed


func _physics_process(delta: float) -> void:
	position += _velocity * delta


func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("Enemy"):
		emit_signal("hit_enemy", body)
		queue_free()


func _on_Timer_timeout() -> void:
	queue_free()
