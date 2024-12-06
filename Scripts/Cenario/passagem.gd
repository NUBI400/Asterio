extends CSGBox3D

@onready var teleporte = $"."

@onready var collision_shape_3d = $Area3D/CollisionShape3D



func _ready():
	collision_shape_3d.shape.size.x = teleporte.size.x
	collision_shape_3d.shape.size.y = teleporte.size.y
	collision_shape_3d.shape.size.z = teleporte.size.z
