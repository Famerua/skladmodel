extends Node3D

var deliver_count = 0
var steps = 0
var timer = 0
var stat_but = false
var box_stack = []
var data_from_file_time = []
var data_from_file_gate = []
@onready var file = 'res://WMS-income-5k.txt'
@onready var log_file = 'res://log.json'
var data_to_save = {'events' : []}
var some_counter = 0
var some_param_for_test = []


var simulation_speed = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
#	for i in range(6):
#		var robot = load("res://agent.tscn").instantiate()
	var f = parse_file(file)
	print(f)
#		self.add_child(robot)
	pass # Replace with function body.


func parse_file(file):
	
	var f = FileAccess.open(file, FileAccess.READ)
#	f.open(file, FileAccess.READ)
	var index = 1
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var line = f.get_line()
		var line_splitted = line.split(' ')
#		print(line.split(' '))
#		data_from_file[get_seconds_from_string(line_splitted[0])] = line_splitted[1]
		data_from_file_time.append(get_seconds_from_string(line_splitted[0]))
		data_from_file_gate.append(line_splitted[1])
#		print(get_seconds_from_string(line_splitted[0]))
#		print(data_from_file)
#	Dictionary
	
		line += " "
#		print(line)
		index += 1
#	print(data_from_file.size())
	print(data_from_file_gate.size())
	return

func get_seconds_from_string(str):
	var str_splitted = str.split(':')
	var result = str_splitted[0].to_int() * 3600 + str_splitted[1].to_int() * 60 + str_splitted[2].to_int()
	return(result)
	pass




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	print(data_to_save)
	if stat_but == true:
		timer += +delta * simulation_speed
	if deliver_count >= 5000:
		get_tree().paused = true
		print('FINISHED')
	get_node("FPS").text = 'FPS: ' + str(Engine.get_frames_per_second())
	get_node("Time").text = 'Time: ' + str(timer)
	get_node("Delivered").text = 'Delivered: ' + str(deliver_count)
	
	var t = int(timer)
#	if t in data_from_file:
#	if !data_from_file_time:
#		return
	if data_from_file_time:
		if data_from_file_time[0] <= t:
			box_stack.append(data_from_file_gate[0])
			data_from_file_time.pop_front()
			data_from_file_gate.pop_front()
			some_counter += 1
#	print(some_counter)
#	print(some_param_for_test.size() - deliver_count)
#		print(box_stack)
func save_data():
	var f_path = log_file
	var f = FileAccess.open(f_path, FileAccess.WRITE)
	var json = JSON.new()
	json.set_data(data_to_save)
#	print(json.stringify(json_form('s')))
	f.store_string(json.stringify(data_to_save))


func _on_timer_timeout():
	print(deliver_count)
	
#	get_node("Steps").text = 'Steps: ' + str(steps)
	pass # Replace with function body.


func _on_button_pressed():
	for i in range((get_node('TextEdit').text).to_int()):
		var robot = load("res://agent.tscn").instantiate()
		self.add_child(robot)
		robot.global_transform.origin.x = i
#		robot.global_transform.origin.z = i
#		robot.get_node("StartingTimer").wait_time = randf_range(0.0, 60.0) / simulation_speed
#		robot.get_node("StartingTimer").start()
		robot.charge = 5600/(get_node('TextEdit').text).to_int() * i
		robot.json_form('AddBot')
	get_node('StepsTimer').start()
	stat_but = true
	pass # Replace with function body.


func _on_v_scroll_bar_value_changed(value):
	for agent in get_tree().get_nodes_in_group('agents'):
		agent.get_node('Timer').wait_time = 1.0 / value
	get_node('VScrollBar/Label').text = str(value)
	get_node('StepsTimer').wait_time = 1.0 / value
	pass # Replace with function body.


func _on_steps_timer_timeout():
	steps += 1
	get_node("Steps").text = 'Steps: ' + str(steps)
	pass # Replace with function body.


func _on_write_pressed():
	save_data()
	pass # Replace with function body.
