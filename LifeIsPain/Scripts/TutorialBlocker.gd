extends Spatial

func _ready():
	var convo_manager = get_node('../../UIManager/ConvoManager')
	
	if(convo_manager != null):
		convo_manager.connect("conversant_recovered", self, '_on_conversant_recover')

func _on_conversant_recover(conversant_name):
	if(conversant_name == 'yourself'):
		transform.origin += Vector3.DOWN * 0.25
		visible = false

func _on_UIManager_game_reset():
	# reset state to original
	transform.origin += Vector3.UP * 0.25
	visible = true
