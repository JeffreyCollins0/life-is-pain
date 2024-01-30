extends Node2D

const unselected_BG_color = Color(0.46, 0.55, 0.68)
const unselected_FG_color = Color(0.33, 0.4, 0.52)
const hovered_BG_color = Color(0.2, 0.6, 0.6)
const unselected_BG_color_mod = Color(0.46, 0.68, 0.54)
const unselected_FG_color_mod = Color(0.33, 0.52, 0.45)
const move_rate = 0.2
const move_threshold = 0.05
export (bool) var debug_nolerp = false # testing only

var focused = false
var selected = false
var is_mod = false
var chip_id = 0
var control = null

var target_pos = Vector2.ZERO
var selected_offset = Vector2(8, 0)
var target_offset = Vector2.ZERO


func _process(delta):
	if(Input.is_action_just_pressed("select") && focused):
		# selected this topic, notify the parent
		get_parent().get_parent().select_card(chip_id)
	
	var target = target_pos + target_offset
	if(debug_nolerp):
		if(position != target):
			position = target
	else:
		if(position.distance_to(target) >= move_threshold):
			position += ((target - position) * move_rate)
		elif(position != target):
			position = target

func init(chip_index, parent):
	chip_id = chip_index
	target_pos = position
	control = parent

func set_display(topic_text, is_mod_card):
	$VBoxContainer/Label.text = topic_text
	is_mod = is_mod_card
	
	# configure card color
	if(is_mod):
		$Background.color = unselected_BG_color_mod
		$TextBacker.color = unselected_FG_color_mod
	else:
		$Background.color = unselected_BG_color
		$TextBacker.color = unselected_FG_color

func set_is_selected(is_selected):
	selected = is_selected
	if(is_selected):
		target_offset = selected_offset
		pass
	else:
		if(is_mod):
			$Background.color = unselected_BG_color_mod
		else:
			$Background.color = unselected_BG_color
		target_offset = Vector2.ZERO

func _on_Background_mouse_entered():
	focused = true
	$Background.color = hovered_BG_color
	
	control.on_chip_hover(chip_id)

func _on_Background_mouse_exited():
	focused = false
	if(is_mod):
		$Background.color = unselected_BG_color_mod
	else:
		$Background.color = unselected_BG_color
