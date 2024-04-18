extends Control

var message_chip_prefab = null

func _ready():
	message_chip_prefab = load('res://Prefabs/LogMessageChip.tscn')

func log_message(message, type):
	var new_chip = message_chip_prefab.instance()
	new_chip.set_message(message, type)
	$ScrollContainer/VBoxContainer.add_child(new_chip)


func _on_LogButton_pressed():
	visible = true

func _on_CloseButton_pressed():
	visible = false

func _on_ConvoManager_convo_started():
	clear_messages()

func _on_Narrator_game_restart():
	clear_messages()

func clear_messages():
	for child in $ScrollContainer/VBoxContainer.get_children():
		$ScrollContainer/VBoxContainer.remove_child(child)
		child.queue_free()
