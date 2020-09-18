extends Node2D
# Forwards and Backwards Kinematics
# Based on EgoMoose - FABRIK (Inverse kinematics)

class Segment:
	var start:Vector2
	var end:Vector2
	var length:float
	var total_length:float
	var angle:float
	var parent: Segment
	var child: Segment
	var start_segment: Segment	#Only end segment use it to trigger forward IK
	func _init(_start:Vector2, _length:float, _angle:float):
		start = _start
		length = _length
		angle = _angle
		calculate_end()
	#Backwards
	func update_backwards()->void:
		update_angle_backwards()
		if parent != null:
			parent.update_backwards() # go down to next parent
	func update_angle_backwards()->void:
		angle = (start-end).angle()
		calculate_start()
	func calculate_start():
		start = Vector2(end.x + cos(angle)*length, end.y + sin(angle)*length)
		update_parent_end()
	func update_parent_end()->void:
		if parent != null:
			parent.end = start

	#Forwards
	func update_forwards()->void:
		update_angle_forwards()
		if child != null:
			child.update_forwards()
	func update_angle_forwards()->void:
		angle = (end-start).angle()
		calculate_end()
	func calculate_end():
		end = Vector2(start.x + cos(angle)*length, start.y + sin(angle)*length)
		update_child_start()
	func update_child_start()->void:
		if child != null:
			child.start = end
	
	#Goal is too far
	func stretch(_angle:float)->void:
		end = Vector2(start.x + cos(_angle)*length, start.y + sin(_angle)*length)
		if child != null:
			child.start = end
			child.stretch(_angle)
	#Start FABRIK - for end point
	func start_fixed_ik(base:Vector2, goal:Vector2)->void:
#		#Snap to stretched if too far
#		var _len:float = (goal-base).length()
#		if _len >= total_length:
#			var _angle:float = (goal-base).angle()
#			start_segment.stretch(_angle)
#			return
		var margin:float = 0.5
		var error:float = 1
		for i in range(3):
			end = goal
			update_backwards()
			start_segment.start = base
			start_segment.update_forwards()
			error = (goal-end).length()
			if error < margin:
				return

var segments: Array         # used for drawing lines
var segment_count:int = 30
var base_segment: Segment	#first segment - fixed
var tentacle: Segment		#end segment
onready var default_pos:Vector2 = Vector2(200,0) #get_viewport_rect().size * Vector2(0.5, 0.1)
var default_length:float = 10
var default_angle:float = -90
var total_length: float = 0

func _ready()->void:
	base_segment = Segment.new(default_pos, default_length, default_angle)	#end segment
	total_length += base_segment.length
	segments.append(base_segment)           # used for drawing lines
	var current: Segment = base_segment     # for iterration in for loop
	for i in range(segment_count):
		var seg:Segment = Segment.new(current.end, default_length, default_angle)   #new segment
		current.child = seg        # add new segment as parent
		seg.parent = current
		current = seg               # next current will be new segment
		segments.append(seg)        # used for drawing lines
		total_length += seg.length
	tentacle = current				#save base segment
	tentacle.total_length = total_length
	tentacle.start_segment = base_segment

func _process(delta)->void:
	#print($"/root/main/players/spark".position)
	#print(get_local_mouse_position())
	tentacle.start_fixed_ik(default_pos,$"/root/main/TileMap/spark/spark_body".global_position)
	update()    #call draw call

func _draw()->void:
	var color: Color = Color(1,1,1)
	var width:float = 8
	for seg in segments:
		var start:Vector2 = seg.start
		var end: Vector2 = seg.end
		draw_line(start, end, color, width)

#func _unhandled_input(event):
#	if event.is_action_pressed("mb_left"):
#		default_pos = get_local_mouse_position()
