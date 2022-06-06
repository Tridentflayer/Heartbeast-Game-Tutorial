extends Node2D

const GrassEffect = preload("res://Effects/GrassEffect.tscn")

func create_grass_effect():
	# instances the grass effect
	var grassEffect = GrassEffect.instance()
	# Gets the world scene as a variable
	var world = get_tree().current_scene
	# adds an instance of the grass effect
	world.add_child(grassEffect)
	# sets the position of the grass effect to the position of the grass that triggers this script
	grassEffect.global_position = global_position
	
func _on_Hurtbox_area_entered(area):
		create_grass_effect()
		queue_free()
