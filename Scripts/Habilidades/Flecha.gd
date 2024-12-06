extends CharacterBody3D

var player : CharacterBody3D = null
@onready var collision = $Collision
@onready var ray_cast_3d = $RayCast3D

@export var speed : int = -25

func _physics_process(delta):
	var foward_direction: Vector3 = global_transform.basis.z.normalized()
	global_translate(foward_direction * speed * delta)

	move_and_slide()
func _on_tempodevida_timeout():
	queue_free()




