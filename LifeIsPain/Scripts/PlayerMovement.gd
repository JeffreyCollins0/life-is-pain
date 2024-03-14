extends KinematicBody

export (float) var move_speed = 1.1
export (int) var slide_angle_checks = 4
export (float) var slide_angle_tolerance = 80.0
const signs = [1, -1] # check for sliding in both directions
const move_update_threshold = 0.24 # for updating overworld opacity changes

var basis_up = -Vector3.AXIS_Z
var basis_right = Vector3.AXIS_X
var facing = -basis_right
var moving = false
var can_move = false

signal convo_available(conversant)
signal convo_unavailable
signal moved_threshold_dist
var saved_nearest = -1
var saved_conversants = []
var saved_position = Vector3.ZERO

func _ready():
	basis_up = -$CameraMount.transform.basis.z
	basis_right = $CameraMount.transform.basis.x

func _process(delta):
	if(!can_move):
		if(moving):
			sprite_update(Vector3.ZERO)
		
		return
	
	var d_pos = Vector3.ZERO
	var input_result = Vector2.ZERO
	
	# move inputs
	if(Input.is_action_pressed("move_left")):
		input_result.x -= 1.0
	if(Input.is_action_pressed("move_right")):
		input_result.x += 1.0
	
	if(Input.is_action_pressed("move_up")):
		input_result.y += 1.0
	if(Input.is_action_pressed("move_down")):
		input_result.y -= 1.0
	
	input_result = input_result.normalized()
	
	if(input_result != Vector2.ZERO):
		# convert the input vector into a movement vector
		d_pos = ((basis_right * input_result.x) + (basis_up * input_result.y)) * (move_speed * delta)
		
		var test_dpos = Vector3.AXIS_X
		if(test_move(transform, d_pos)):
			# slide checks
			for i in range(slide_angle_checks):
				for sign_mult in signs:
					test_dpos = d_pos.rotated(Vector3.UP, ((slide_angle_tolerance / slide_angle_checks)*i*sign_mult) )
					if(!test_move(transform, test_dpos)):
						move_and_collide(test_dpos)
						sprite_update(d_pos)
						update_nearest_npc()
		else:
			# move normally
			move_and_collide(d_pos)
			sprite_update(d_pos)
			update_nearest_npc()
		
		# for notifying movement-based environment updates
		if((global_translation - saved_position).length() > move_update_threshold):
			emit_signal("moved_threshold_dist")
			saved_position = global_translation
		
	elif(moving):
		sprite_update(Vector3.ZERO)

func get_angle_band(dir):
	# DL, DR, UL, UR
	#var angle_band = 0
	var angle_band = ''
	
	#if(dir.z > 0):
	if(dir.dot(basis_up) > 0):
		# up-facing
		#angle_band += 2
		angle_band += 'U'
	else:
		angle_band += 'D'
	
	#if(dir.x > 0):
	if(dir.dot(basis_right) > 0):
		# right-facing
		#angle_band += 1
		angle_band += 'R'
	else:
		angle_band += 'L'
	
	return angle_band

func sprite_update(dir):
	var angle_band = 'DL'
	
	if(dir == Vector3.ZERO):
		moving = false
		angle_band = get_angle_band(facing)
		$AnimatedSprite3D.animation = ('stand'+angle_band)
	elif(!moving || dir != facing):
		moving = true
		facing = dir
		angle_band = get_angle_band(dir)
		$AnimatedSprite3D.animation = ('walk'+angle_band)

func update_nearest_npc():
	if(len(saved_conversants) <= 0 && saved_nearest != -1):
		emit_signal("convo_unavailable")
		saved_nearest = -1
		return
	
	var nearest = -1
	var nearest_name = 'MissingNo.'
	var shortest_dist = INF
	for npc in saved_conversants:
		var npc_dist = transform.origin.distance_squared_to(npc[1])
		if(npc_dist < shortest_dist):
			shortest_dist = npc_dist
			nearest = npc[0]
			nearest_name = npc[2]
	
	if(nearest != -1 && nearest != saved_nearest):
		saved_nearest = nearest
		emit_signal("convo_available", nearest_name)

func lock_player_movement():
	can_move = false

func unlock_player_movement():
	can_move = true

func _on_TalkableArea_body_entered(body):
	if(!body.is_in_group('NPC')):
		return
	
	saved_conversants.append([body.get_npc_id(), body.transform.origin, body.get_npc_name()])
	update_nearest_npc()

func _on_TalkableArea_body_exited(body):
	if(!body.is_in_group('NPC')):
		return
	
	var remove_index = -1
	for i in range(len(saved_conversants)):
		if(saved_conversants[i][0] == body.get_npc_id()):
			remove_index = i
			break
	saved_conversants.pop_at(remove_index)
	update_nearest_npc()
