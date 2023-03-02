extends Node3D


# Called when the node enters the scene tree for the first time.
@export var online = true 



@export var load_color = Color(0, 0.71764707565308, 0)
@export var deliver_color = Color(0.76470589637756, 0, 0)
@export var charge_color = Color(0, 0, 0.73725491762161)

var clear_map = []
var map = []
var my_pos = [0,0]

var loaded = false
var want_to_charge = false



var start = true

var current_target = '../target1'
var want_to_take_box_number = 0
var spt = true #self position trail

var timer_step = 1
var charge = 5600
var max_charge = 5600
var closest_charger = 'charger6'

var looking_at = Vector3(-1,0,1)
var one_step_destination = [0,0]

var direction = Vector3(1,0,0)
var current_state = 'wait'
var id = 'placeholderID'


var stop_cost = 1
var rotate_cost = 1
var start_cost = 5
var move_cost = 1
var timers = []

func _ready():
	for i in range(10):
		clear_map.append([0,0,0,0,0,0,0,0,0,0,0])
	map = clear_map.duplicate(true)
#	map[0][1] = 1
#	gen_weight(vec2pos(get_node("../loading_point").global_transform.origin),10)
	my_pos = vec2pos(self.global_transform.origin)
#	print(vec2pos(get_node("../target1").global_transform.origin))

	gen_weight(vec2pos(get_node("../loading_point").global_transform.origin),10)
	get_node("Timer").wait_time = timer_step
	self.id = 'ant' + str(get_tree().get_nodes_in_group('agents').size())
	get_node("MeshInstance3D").set_surface_override_material(0, get_node("MeshInstance3D").get_surface_override_material(0).duplicate())

	timers.append(get_node('RotationTimer'))
	timers.append(get_node('MoveTimer'))
	timers.append(get_node('LoadingTimer'))
	timers.append(get_node('UnloadingTimer'))
	timers.append(get_node('ChargingTimer'))
	for timer in timers:
		timer.wait_time = timer.wait_time / get_parent().simulation_speed


	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if get_node("LoadingTimer").time_left or get_node("UnloadingTimer").time_left or get_node("ChargingTimer").time_left or get_node("StartingTimer").time_left:
		return
	_on_timer_timeout()
	if get_node("LoadingTimer").time_left or get_node("UnloadingTimer").time_left or get_node("ChargingTimer").time_left or get_node("StartingTimer").time_left:
		return
	looking_at = Vector3(1,0,0).rotated(Vector3(0,1,0), get_node("MeshInstance3D").rotation.y)
	var to_target = pos2vec(one_step_destination) - self.global_transform.origin

	var rot = -sign(to_target.cross(looking_at).y)
	
	if (abs(to_target.cross(looking_at).y) > 0.005 or to_target.angle_to(looking_at) > 0.1) and !get_node("RotationTimer").time_left:
		json_form('rotate')
		get_node("RotationTimer").start()

	elif !get_node("RotationTimer").time_left and !get_node("MoveTimer").time_left:
#		if abs(to_target.cross(looking_at).y) > 0.001:

#			get_node("MeshInstance3D").rotate_y(-to_target.cross(looking_at).y)
		if get_parent().box_stack:
			json_form('move')
			get_node("MoveTimer").start()
#			self.global_transform.origin += looking_at.normalized() * delta


	
	
func go():
	my_pos = vec2pos(self.global_transform.origin)
	my_pos = [round(my_pos[0]), round(my_pos[1])]
	var new_pos = my_pos.duplicate(true)
	
	
#	charge -= 1 * 1
	for agent in get_tree().get_nodes_in_group('agents'):
		var agent_pos = [round(vec2pos(agent.global_transform.origin)[0]), round(vec2pos(agent.global_transform.origin)[1])]
		var agent_looking_pos = [round(vec2pos(agent.global_transform.origin + agent.looking_at.normalized())[0]), round(vec2pos(agent.global_transform.origin + agent.looking_at.normalized())[1])]
		if agent.name != self.name and agent_pos[0] < 10 and agent_pos[1] < 11:
			map[agent_pos[0]][agent_pos[1]] -= 44
#			if agent.current_state == 'move' and agent_looking_pos[0] < 10 and agent_looking_pos[1] < 11:
#				map[agent_looking_pos[0]][agent_looking_pos[1]] -= 44
		elif agent.name == self.name:
			map[agent_pos[0]][agent_pos[1]] -= 33

	var current_weight = get_weight(my_pos)
#	for i in range(-1,2,1): #### ДЛЯ ДИАГОНАЛЬНОГО ПЕРЕМЕЩЕНИЯ
#		for j in range(-1,2,1):
#			if (my_pos[0] + i) > 9 or (my_pos[1] + j) > 9 or (my_pos[0] + i) < 0 or (my_pos[1] + j) < 0:
#				pass
#			else:

#				if get_weight([my_pos[0] + i, my_pos[1] + j]) > current_weight:
#					current_weight = get_weight([my_pos[0] + i, my_pos[1] + j])
#					new_pos = [my_pos[0] + i, my_pos[1] + j]
	for i in range(-1,2,1):
		var j = 0
		if (my_pos[0] + i) > 9 or (my_pos[1] + j) > 10 or (my_pos[0] + i) < 0 or (my_pos[1] + j) < 0:
			pass
		else:

			if get_weight([my_pos[0] + i, my_pos[1] + j]) > current_weight:
				current_weight = get_weight([my_pos[0] + i, my_pos[1] + j])
				new_pos = [my_pos[0] + i, my_pos[1] + j]
	for j in range(-1,2,1):
		var i = 0
		if (my_pos[0] + i) > 9 or (my_pos[1] + j) > 10 or (my_pos[0] + i) < 0 or (my_pos[1] + j) < 0:
			pass
		else:

			if get_weight([my_pos[0] + i, my_pos[1] + j]) > current_weight:
				current_weight = get_weight([my_pos[0] + i, my_pos[1] + j])
				new_pos = [my_pos[0] + i, my_pos[1] + j]
	for agent in get_tree().get_nodes_in_group('agents'):
		var agent_pos = [round(vec2pos(agent.global_transform.origin)[0]), round(vec2pos(agent.global_transform.origin)[1])]
		var agent_looking_pos = [round(vec2pos(agent.global_transform.origin + agent.looking_at.normalized())[0]), round(vec2pos(agent.global_transform.origin + agent.looking_at.normalized())[1])]
		if agent.name != self.name:
			map[agent_pos[0]][agent_pos[1]] += 44
#			if agent.current_state == 'move' and agent_looking_pos[0] < 10 and agent_looking_pos[1] < 11:
#				map[agent_looking_pos[0]][agent_looking_pos[1]] += 44
		elif agent.name == self.name:
			map[agent_pos[0]][agent_pos[1]] += 33

#	my_pos = new_pos.duplicate(true) ######эти вде строки для пошагового
#	self.global_transform.origin = pos2vec(my_pos)

	one_step_destination = new_pos
#	for agent in get_tree().get_nodes_in_group('agents'):
#		if agent != self:
#			agent.map[pos2vec(self.global_transform.origin)[0]][pos2vec(self.global_transform.origin)[1]] += 22
	


func create_map_for_target(target_pos):
	for i in range(-1,2,1):
		for j in range(-1,2,1):
			if (target_pos[0] + i) > 9 or (target_pos[1] + j) > 10 or (target_pos[0] - i) < 0 or (target_pos[1] - j) < 0:
				pass
	pass
#функция меры Неймана*
func gen_weight(p,w):
	map[p[0]][p[1]] = w
	for i in range(10):
		for j in range(11):
			map[i][j] = w - abs(p[0] - i) - abs(p[1] - j)
	pass
	
#рекурсивная функция 
func gen_weight_old(p,w):
#	map = clear_map.duplicate(true)
	map[p[0]][p[1]] = w

	if w == 1:
		return
#	for i in range(-1,2,1): #### ДЛЯ ДИАГОНАЛЬНОГО ПЕРЕМЕЩЕНИЯ
#		for j in range(-1,2,1):
#			if (p[0] + i) > 9 or (p[1] + j) > 9 or (p[0] - i) < 0 or (p[1] - j) < 0:
#				pass
#			else:
#				if map[p[0] + i][p[1] + j] < w-1:
#					map[p[0] + i][p[1] + j] = w-1
#					gen_weight([p[0] + i,p[1] + j], w-1)
	for i in range(-1,2,1):
		var j = 0
		i *= +sign(Vector3(0,0,1).cross(looking_at).y)
		if (p[0] + i) > 9 or (p[1] + j) > 10 or (p[0] + i) < 0 or (p[1] + j) < 0:
			pass
		else:
			if map[p[0] + i][p[1] + j] < w-1:
				map[p[0] + i][p[1] + j] = w-1
				gen_weight([p[0] + i,p[1] + j], w-1)
	for j in range(-1,2,1):
		var i = 0
		j *= +sign(Vector3(0,0,1).cross(looking_at).y)
		if (p[0] + i) > 9 or (p[1] + j) > 10 or (p[0] + i) < 0 or (p[1] + j) < 0:
			pass
		else:
			if map[p[0] + i][p[1] + j] < w-1:
				map[p[0] + i][p[1] + j] = w-1
				gen_weight([p[0] + i,p[1] + j], w-1)

func vec2pos(vec):
	return ([vec.x, vec.z])
func pos2vec(pos):
	return(Vector3(pos[0],0,pos[1]))

func get_weight(pos):
	return (map[pos[0]][pos[1]])





func json_form(command):
	var result = {}
	result['x'] = self.global_transform.origin.x
	result['z'] = self.global_transform.origin.z
	result['command'] = command
	result['current_state'] = current_state
	if current_state == 'move' and command != 'move':
		charge -= stop_cost
	if current_state != 'move' and command == 'move':
		charge -= start_cost
	current_state = command
	result['charge'] = charge
	result['id'] = id
	result['isLoaded'] = loaded
	result['timestamp'] = get_parent().timer
	get_parent().data_to_save['events'].append(result)
	print(charge)
	return(result)



func _on_timer_timeout():
#	return
#	map = clear_map.duplicate(true)

#	if start:
#		gen_weight(vec2pos(get_node("../loading_point").global_transform.origin),10)
#		start = false
#		print(map)
	
#	if !loaded:
#		gen_weight(vec2pos(get_node("../loading_point").global_transform.origin),10)
#	else:
#		gen_weight(vec2pos(get_node("../target").global_transform.origin),10)


#	for agent in get_tree().get_nodes_in_group('agents'):
###		if (agent != self):
###			print(pos2vec(agent.global_transform.origin))
###			map[pos2vec(agent.global_transform.origin)[0]][pos2vec(agent.global_transform.origin)[1]] -= 22
#		if agent != self:
#			agent.map[pos2vec(agent.global_transform.origin)[0]][pos2vec(agent.global_transform.origin)[1]] -= 22
#	gen_weight(vec2pos(get_node("../loading_point").global_transform.origin),10)
#	print(map)
#	for agent in get_tree().get_nodes_in_group('agents'):
#		var c = 0
#		if agent.charge > 800:
#			c += 1
#		if c > 2:
#			get_node('StartingTimer').start(60)

	
	if (online and get_parent().box_stack) or loaded:
		go()
		
	if get_parent().box_stack or get_parent().data_from_file_gate:
		pass
	else:
		if !self.loaded:
			self.queue_free()
		
		
		
	if self.charge < 800 and want_to_charge == false:
		map = clear_map.duplicate(true)
		for charger in get_tree().get_nodes_in_group('chargers'):
			if charger.occuped == false:
				if ((charger.global_transform.origin - self.global_transform.origin).length() < (get_node('../' + str(closest_charger)).global_transform.origin - self.global_transform.origin).length()):
					closest_charger = charger.name
		gen_weight(vec2pos(get_node('../' + str(closest_charger)).global_transform.origin),20)
		get_node('../' + str(closest_charger)).occuped = true
		print(closest_charger)
		get_node("MeshInstance3D").get_surface_override_material(0).albedo_color = charge_color
		want_to_charge = true
	
	if (self.global_transform.origin - get_node('../' + str(closest_charger)).global_transform.origin).length() < 0.1 and self.want_to_charge:
		json_form('Charge')
		get_node('ChargingTimer').start()
		self.charge = self.max_charge
		self.want_to_charge = false


		

#	if self.charge < 0 and !self.loaded:
#		closest_charger = 'charger1'
#		for charger in get_tree().get_nodes_in_group('chargers'):
#			if ((charger.global_transform.origin - self.global_transform.origin).length() < (get_node('../' + str(closest_charger)).global_transform.origin - self.global_transform.origin).length()):
#				closest_charger = charger.name
##		self.charge = self.max_charge
#		map = clear_map.duplicate(true)
##		self.loaded = false
#		gen_weight(vec2pos(get_node('../' + str(closest_charger)).global_transform.origin),20)
#		get_node("MeshInstance3D").get_surface_override_material(0).albedo_color = charge_color
#
#	if closest_charger != 'no_need_charge':
#		if (self.global_transform.origin - get_node('../' + str(closest_charger)).global_transform.origin).length() < 0.1:
#			self.charge = self.max_charge
#			map = clear_map.duplicate(true)
#			self.loaded = false
#			gen_weight(vec2pos(get_node("../loading_point").global_transform.origin),20)
#			get_node("MeshInstance3D").get_surface_override_material(0).albedo_color = load_color

	if (self.global_transform.origin - get_node("../loading_point").global_transform.origin).length() < 0.1 and !self.loaded:
		get_node("LoadingTimer").start()
		json_form('Load cargo')
		map = clear_map.duplicate(true)
		self.loaded = true
#		var choose = randi_range(1,20)
		current_target = '../target' + get_parent().box_stack[0]
		get_parent().some_param_for_test.append(get_parent().box_stack[0])
		get_parent().box_stack.pop_front()
		gen_weight(vec2pos(get_node(current_target).global_transform.origin),20)
		get_node("MeshInstance3D").get_surface_override_material(0).albedo_color = deliver_color
		

	if (self.global_transform.origin - get_node(current_target).global_transform.origin).length() < 0.1 and self.loaded:
		get_node("UnloadingTimer").start()
		json_form('Unload cargo')
		map = clear_map.duplicate(true)
		self.loaded = false
		gen_weight(vec2pos(get_node("../loading_point").global_transform.origin),20)
		get_node("MeshInstance3D").get_surface_override_material(0).albedo_color = load_color
		get_parent().deliver_count += 1
#		print(get_parent().deliver_count)
	pass # Replace with function body.


func _on_rotation_timer_timeout():
#	print('------')
#	print(my_pos)
#	print(one_step_destination)
#	print(to_target)
#	go()
	looking_at = Vector3(1,0,0).rotated(Vector3(0,1,0), get_node("MeshInstance3D").rotation.y)
	var to_target = pos2vec(one_step_destination) - self.global_transform.origin
#	print(to_target)
	var rot = -sign(to_target.cross(looking_at).y)
	get_node('MeshInstance3D').rotate_y(PI/2/4 * rot)
	
	charge -= rotate_cost / 4
	pass # Replace with function body.


func _on_move_timer_timeout():
#	print('------')
#	print(my_pos)
#	print(one_step_destination)
#	print(map)
	
	charge -= move_cost
	self.global_transform.origin += looking_at.normalized()
	pass # Replace with function body.


func _on_loading_timer_timeout():
	pass # Replace with function body.


func _on_unloading_timer_timeout():
	pass # Replace with function body.


func _on_charging_timer_timeout():
	get_node('../' + str(closest_charger)).occuped = false
	if self.loaded:
		get_node("MeshInstance3D").get_surface_override_material(0).albedo_color = deliver_color
		map = clear_map.duplicate(true)
		gen_weight(vec2pos(get_node(current_target).global_transform.origin),20)
	else:
		get_node("MeshInstance3D").get_surface_override_material(0).albedo_color = load_color
		gen_weight(vec2pos(get_node("../loading_point").global_transform.origin),20)
	pass # Replace with function body.
