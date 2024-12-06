extends RigidBody3D

@onready var recarga = $Recarga
var recarregando = false
var pode_atirar = false
@onready var area_de_ativacao = $AreaDeAtivacao

@export var player: CharacterBody3D

const FLECHA = preload("res://Cenas/flecha.tscn")
@onready var spawn = $Spawn

func _process(delta):
	if pode_atirar:
		look_at(player.position)
		if recarregando == false :
			var flecha = FLECHA.instantiate()
			flecha.player = player
			get_tree().get_root().add_child(flecha)
			flecha.global_transform = spawn.global_transform  
			recarregando = true
			recarga.start()


func _on_recarga_timeout():
	recarregando = false


func _on_area_de_ativacao_area_entered(area):
	if area.is_in_group("Player"):
		pode_atirar = true


func _on_area_de_ativacao_area_exited(area):
	if area.is_in_group("Player"):
			pode_atirar = false
