extends Node2D

var scene: Node2D
var forward: Script = preload("res://addons/Kinematics/Forward_kinematics.gd")
var follow: Script = preload("res://addons/Kinematics/IK_follower.gd")
var fabrik: Script = preload("res://addons/Kinematics/FABRIK.gd")

var line = Line2D.new()
onready var vectr1 = Vector2(0,0) #$"/root/main/TileMap/space_home".get_global_position() #Vector2(0,0)
func _ready():
	#print(get_node("/root/main/players/spark").position, "DDD")
	scene = fabrik.new()
	add_child(scene)
	scene.default_pos = vectr1 #$"/root/main/TileMap/space_home".position
	
	var ip = IP
	print(ip.get_local_addresses())
	line.name = "line"
	line.default_color = Color.skyblue
	line.points = [vectr1,Vector2(300,-900)]
	add_child(line)


#func _on_Forward_pressed():
#	scene.queue_free()
#	yield(get_tree(), "idle_frame")
#	scene = forward.new()
#	add_child(scene)


#func _on_Follow_pressed():
#	scene.queue_free()
#	yield(get_tree(), "idle_frame")
#	scene = follow.new()
#	add_child(scene)


#func _on_FABRIK_pressed():
#	scene.queue_free()
#	yield(get_tree(), "idle_frame")
#	scene = fabrik.new()
#	add_child(scene)
