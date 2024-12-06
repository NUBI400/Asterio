extends CharacterBody3D

# Player nodes
@onready var camera_3d = $Nek/Head/Eyes/Camera3D
@onready var nek = $Nek
@onready var eyes = $Nek/Head/Eyes
@onready var head = $Nek/Head
@onready var standing_collision_shape = $Standing_collision_shape
@onready var crouching_collision_shape = $Crouching_collision_shape

@onready var animation_player = $Nek/Head/Eyes/AnimationPlayer
@onready var corpo = $Corpo
@onready var area3dcolision = $Area3D/CollisionShape3D


#raycasts
@onready var ray_cast_3d = $RayCast3D



# Estados visual
#const PLAYER_AGACHADO = preload("res://Player/playerAGACHADO.tres")
#const PLAYER_EMPE = preload("res://Player/playerEMPE.tres")
#
#const PLAYER_AGACHADO_AREA = preload("res://Player/player_agachado_area.tres")
#const PLAYER_EMPE_AREA = preload("res://Player/player_empe_area.tres")



#Speed vars
var current_speed = 50.0
@export var walking_speed = 50.0
@export var sprinting_speed = 120.0
@export var crouching_speed = 20.0
@export var flying_speed = 200.0


#States
var walking = false
var sprinting = false
var crouching = false
var free_looking = false
var sliding = false
var voando = false

var morte = false

#Jump vars
@export var jump_velocity = 7.0

#Icaro asas vars
var podevoar = true
@export var icaro_velocity = 0.22
var tempo_acabar = true
var tempo_voando = 0.0
@export var tempo_voando_max = 4.0
@export var asas_recarga_tempo = 6.0



#wall jump vars
const FLOOR = 0
const WALL = 1
const AIR = 2
var current_state := AIR



#Slide vars
var slide_timer = 0.0
@export var slide_timer_max = 1.0
var slide_vector = Vector2.ZERO
@export var slide_speed = 60.0


#Head boobing vars
var head_bobbing_sprinting_speed = 22.0
var head_bobbing_walking_speed = 14.0
var head_bobbing_crouching_speed= 10.0

var head_bobbing_sprinting_intensity = 0.2
var head_bobbing_walking_intensity  = 0.1
var head_bobbing_crouching_intensity = 0.05

var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0


#Movement vars
const accel = 90
const FRICTION = 0.85
var crouching_depth = -0.5
var lerp_speed = 10.0
var air_lerp_speed = 3
var free_look_tilt_amount = 8
var last_velocity = Vector3.ZERO

var input_dir = Vector2.ZERO

#Input vars
@export var mouse_sens = 0.4
var direction = Vector3.ZERO


var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	head.rotation.x = 0
	#standing_collision_shape.disabled = false
	#crouching_collision_shape.disabled = true
	#corpo.mesh = PLAYER_EMPE
	#corpo.position.y = 1
	#area3dcolision.shape = PLAYER_EMPE_AREA
	#area3dcolision.position.y = 1
	#standing_collision_shape.disabled = false
	#crouching_collision_shape.disabled = true


func _physics_process(delta):
	if morte == false:
		input_dir = Input.get_vector("Esquerda", "Direita", "Cima", "Baixo")
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x += direction.x * current_speed * delta
			velocity.z += direction.z * current_speed * delta
		
		#movementos
		movement(delta)
		Crouch_and_slide(delta)
		jump(direction)
		Asas_de_icaro(delta)
		free_look(delta)
		
		
		
		gravidade(delta)
		move_and_slide()
		update_state()
		velocity.x *= FRICTION
		velocity.z *= FRICTION
	
	



func _input(event):
#Mouse looking logic
	if event is InputEventMouseMotion:
		if free_looking:
			nek.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			nek.rotation.y = clamp(nek.rotation.y,deg_to_rad(-120),deg_to_rad(120))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			head.rotate_x(deg_to_rad(-event.relative.y* mouse_sens))	
			head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(90))


func movement(delta):
	
	if is_on_floor():
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*lerp_speed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*air_lerp_speed)
	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized()
		current_speed = (slide_timer + 0.1) * slide_speed
		if direction:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
			
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			velocity.z = move_toward(velocity.z, 0, current_speed)


func gravidade(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta


func jump(dir):
	# Handle jump.
	
	if Input.is_action_just_pressed("jump"):
		if current_state == FLOOR:
			velocity.y = jump_velocity
			sliding = false
			animation_player.play("Jump")
	
	#Handle Landing
	if is_on_floor(): 
		if last_velocity.y < -10.0:
			animation_player.play("Roll")
		elif  last_velocity.y < -4.0:
			animation_player.play("Landing")

func Asas_de_icaro(delta):
	
	if is_on_floor():
		tempo_voando = tempo_voando_max
		current_speed = lerp(current_speed,walking_speed, delta*lerp_speed)
		if voando:
				voando = false
				podevoar = false
				await get_tree().create_timer(asas_recarga_tempo).timeout
				podevoar = true
	
	if Input.is_action_pressed("icaro"):
		if not is_on_floor() and podevoar == true:
			voando = true
			velocity.y += icaro_velocity 
			current_speed = lerp(current_speed,flying_speed, delta*lerp_speed)
			
			tempo_voando -= delta
			print(tempo_voando)
			if tempo_voando <= 0:
				voando = false
				podevoar = false
				await get_tree().create_timer(asas_recarga_tempo).timeout
				podevoar = true
				current_speed = lerp(current_speed,walking_speed, delta*lerp_speed)



func Crouch_and_slide(delta):
	if Input.is_action_pressed("Crouch") or sliding:
		current_speed = lerp(current_speed,crouching_speed, delta*lerp_speed)
		head.position.y =lerp( head.position.y, 0.0 + crouching_depth, delta * lerp_speed)
		#standing_collision_shape.disabled = true
		#crouching_collision_shape.disabled = false
		#corpo.mesh = PLAYER_AGACHADO
		#corpo.position.y = 0.8
		#area3dcolision.shape = PLAYER_AGACHADO_AREA
		#area3dcolision.position.y = 0.8
		#standing_collision_shape.disabled = true
		#crouching_collision_shape.disabled = false
		
		if sprinting and input_dir != Vector2.ZERO and current_state == FLOOR:
			sliding = true
			slide_timer = slide_timer_max
			slide_vector = input_dir
			free_looking = true
		
		walking = false
		sprinting = false
		crouching = true
	
	elif !ray_cast_3d.is_colliding():
	#Standing
		head.position.y =lerp( head.position.y, 0.0 , delta * lerp_speed)
		#standing_collision_shape.disabled = false
		#crouching_collision_shape.disabled = true
		#corpo.mesh = PLAYER_EMPE
		#corpo.position.y = 1
		#area3dcolision.shape = PLAYER_EMPE_AREA
		#area3dcolision.position.y = 1
		#standing_collision_shape.disabled = false
		#crouching_collision_shape.disabled = true
	
	#Sprinting
		if Input.is_action_pressed("Sprint"):
			current_speed =  lerp(current_speed,sprinting_speed, delta*lerp_speed)
			walking = false
			sprinting = true
			crouching = false
	#Walking
		else:
			current_speed =lerp(current_speed, walking_speed, delta*lerp_speed)
			walking = true
			sprinting = false
			crouching = false
	
	
	#Handle sliding
	if sliding:
		slide_timer -= delta
		print(slide_timer)
		if slide_timer <= 0:
			sliding = false
			free_looking = false
			current_speed =lerp(current_speed, crouching_speed, delta*lerp_speed)
	
	
	# Handle headbob
	if sprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed*delta
	elif walking:
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed*delta
	elif crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed*delta
			
	
	
	if is_on_floor() && !sliding && input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2)+ 0.5
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y*(head_bobbing_current_intensity /2.0), delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x*(head_bobbing_current_intensity), delta*lerp_speed)
		
	else:
		eyes.position.y = lerp(eyes.position.y,0.0, delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta*lerp_speed)


func free_look(delta):
	if Input.is_action_pressed("free_look") or sliding:
		free_looking = true
		
		if sliding: #slide animation
			eyes.rotation.z =lerp(eyes.rotation.z, -deg_to_rad(7.0),delta *lerp_speed)
		else:
			eyes.rotation.z = deg_to_rad(nek.rotation.y * free_look_tilt_amount)
	else:
		free_looking = false
		nek.rotation.y = lerp(nek.rotation.y ,0.0, delta * lerp_speed)	
		eyes.rotation.z  = lerp(eyes.rotation.y ,0.0, delta * lerp_speed)	


func update_state():
	if is_on_wall_only():
		current_state = WALL
	elif is_on_floor():
		current_state = FLOOR
	else:
		current_state = AIR


func renaceu():
	position.y = 1.338
	position.x = 175.949
	position.z = 175.949
	head.rotation.x = 0


func morreu():
	morte = true
	velocity.y = 0
	velocity.x = 0
	velocity.z = 0
	corpo.visible = false

func voltou_vida():
	morte = false
	corpo.visible = true


func _on_area_3d_area_entered(area):
	
	if area.is_in_group("CHAVE"):
		renaceu()

	if area.is_in_group("voltar"):
		position.x = -400
		
	if area.is_in_group("Minotauro"):
		get_tree().quit()
	
	
	#if area.is_in_group("espinhos"):
		#renaceu()
	
	#if area.is_in_group("flecha"):
		#morreu()
