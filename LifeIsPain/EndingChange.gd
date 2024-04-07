extends EnviroChange

var npcs_recovered = [false, false, false, false, false, false]

func _on_conversant_recover(conversant_name):
	var conv_id = index_conversant_name(conversant_name)
	if(conv_id == -1):
		return
	
	if(!npcs_recovered[conv_id]):
		npcs_recovered[conv_id] = true
	
	# check for all recovered
	var check_flag = true
	for npc_status in npcs_recovered:
		check_flag = (check_flag && npc_status)
	
	if(check_flag):
		# enable the ending cutscene
		$Area4.monitoring = true
		$Area4/AnimatedSprite3D.visible = true

func _on_UIManager_game_reset():
	# reset state to original
	npcs_recovered = [false, false, false, false, false, false]
	$Area4.monitoring = false
	$Area4/AnimatedSprite3D.visible = false

func index_conversant_name(name):
	if(name == 'Shady'):
		return 0
	if(name == 'Beanie'):
		return 1
	if(name == 'Schwarz'):
		return 2
	if(name == 'Plagueis'):
		return 3
	if(name == 'Florald'):
		return 4
	if(name == 'Lifter'):
		return 5
	
	return -1
