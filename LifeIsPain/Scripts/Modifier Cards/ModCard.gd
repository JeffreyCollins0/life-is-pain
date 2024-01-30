extends Node
class_name ModCard

var mod_index = -1

signal effect_ended

func init(parent, modifier_index):
	pass

func on_played():
	return false

func on_turn_update(topic, did_joke_land):
	# called as a new joke is told, and before the previous data is overwritten
	return false

func get_modifier_id():
	return mod_index
