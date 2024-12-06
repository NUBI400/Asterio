extends CharacterBody3D

@export var speed = 16
var accel = 10

@onready var nav : NavigationAgent3D = $NavigationAgent3D
@export var Player : CharacterBody3D 

@onready var sprite = $Sprite
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	
	var direction = Vector3()
	
	nav.target_position = Player.global_position
	
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
	if Global.chaves == 0:
		speed = 20
	if Global.chaves == 1:
		speed = 30
	if Global.chaves == 2:
		speed = 40
	
	
	velocity = velocity.lerp(direction * speed, accel * delta)
	
	look_at(Player.position)
	
	gravidade(delta)
	
	move_and_slide()


func gravidade(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
