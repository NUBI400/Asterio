extends CharacterBody3D



func _on_area_3d_area_entered(area):
	if area.is_in_group("Player"):
		Global.chaves += 1
		queue_free()