extends Node

export (int) var conversant_id = 0
export (String) var conversant_name = 'Shady' 

func get_npc_id():
	return conversant_id

func get_npc_name():
	return conversant_name
