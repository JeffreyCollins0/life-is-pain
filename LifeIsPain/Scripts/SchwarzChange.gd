extends EnviroChange

var nodes_to_add = []

var objects_to_add = []
var objects_to_remove = []

func _ready():
	var convo_manager = get_node('../UIManager/ConvoManager')
	if(convo_manager != null):
		convo_manager.connect("conversant_recovered", self, '_on_conversant_recover')
	
	for node_name in nodes_to_add:
		var node = get_node(node_name)
		if(node != null):
			objects_to_add.append(node)
	
	var children = get_children()
	for child in children:
		if(!objects_to_add.has(child)):
			objects_to_remove.append(child)

func _on_conversant_recover(conversant_name):
	if(conversant_name == associated_conversant):
		for obj_rem in objects_to_remove:
			obj_rem.transform.origin += Vector3.DOWN * 0.25
			obj_rem.visible = false
		
		for obj_rem in objects_to_add:
			obj_rem.transform.origin += Vector3.UP * 0.25
			obj_rem.visible = true

func _on_UIManager_game_reset():
	# reset state to original
	for obj_rem in objects_to_remove:
		obj_rem.transform.origin += Vector3.UP * 0.25
		obj_rem.visible = true
	
	for obj_rem in objects_to_add:
		obj_rem.transform.origin += Vector3.DOWN * 0.25
		obj_rem.visible = false
