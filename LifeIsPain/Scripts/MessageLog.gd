extends Control

var message_chip_prefab = null

func _ready():
	message_chip_prefab = load('res://Prefabs/LogMessageChip.tscn')

func log_message(message, type):
	var new_chip = message_chip_prefab.instance()
	new_chip.set_message(message, type)
	#new_chip.get_node('Label').text = message
	$ScrollContainer/VBoxContainer.add_child(new_chip)

#func update_entries(messages):
#	var length_diff = len(messages) - get_child_count()
#	if(length_diff > 0):
#		for i in range(length_diff):
#
#			pass
#
#	pass


func _on_LogButton_pressed():
	visible = true

func _on_CloseButton_pressed():
	visible = false
