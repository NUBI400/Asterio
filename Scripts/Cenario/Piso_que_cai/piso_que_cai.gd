extends CSGBox3D

@onready var pisoquecai = $"."

@onready var collision_shape_3d = $Area3D/CollisionShape3D

@onready var animation_player = $AnimationPlayer

@export var posisaoinicial: float = 0

var pode_descer = true

func _ready():
	collision_shape_3d.shape.size.x = pisoquecai.size.x
	collision_shape_3d.shape.size.y = pisoquecai.size.y
	collision_shape_3d.shape.size.z = pisoquecai.size.z
	collision_shape_3d.position.y = 0.2

func _process(delta):
	position.y = posisaoinicial

func _on_area_3d_area_entered(area):
	if area.is_in_group("Player") and pode_descer:
		pode_descer = false
		await get_tree().create_timer(0.6).timeout
		animation_player.play("caindo")
		await get_tree().create_timer(5).timeout
		animation_player.play("voltar")
		pode_descer = true
