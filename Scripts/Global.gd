extends Node

var chaves = 0

func _ready():
	chaves = 0
	

func  _physics_process(delta):
	if chaves == 2:
		get_tree().change_scene_to_file("res://Cenas/Vitoria.tscn")
