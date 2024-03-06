extends Spatial

func _ready():
	var convo_manager = get_node('../../UIManager/ConvoManager')
	
	if(convo_manager != null):
		convo_manager.connect("conversant_recovered", self, '_on_conversant_recover')
	
	#_on_conversant_recover('yourself')

func _on_conversant_recover(conversant_name):
	if(conversant_name == 'yourself'):
		transform.origin += Vector3.DOWN * 0.25
		visible = false
