extends Node2D

var control

func _ready():
	control = get_parent()

func _on_ItemList_item_selected(index):
	control.select_topic(index)
