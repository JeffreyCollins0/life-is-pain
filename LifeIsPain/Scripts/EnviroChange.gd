extends Spatial

# Base class for all environmental effects upon conversant recovery

export (String) var associated_conversant

func _ready():
	var convo_manager = get_node('../../UIManager/ConvoManager')
	
	if(convo_manager != null):
		convo_manager.connect("conversant_recovered", self, '_on_conversant_recover')

func _on_conversant_recover(conversant_name):
	pass
