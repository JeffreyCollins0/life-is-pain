extends Node2D

var focused = false
var selected = false
var chip_id = 0

const unselected_BG_color = Color(0, 0, 0)
const hovered_BG_color = Color(0.2, 0.6, 0.6)
const selected_BG_color = Color(0, 0.4, 0.4)

func _process(delta):
	if(Input.is_action_just_pressed("select") && focused):
		# selected this topic, notify the parent
		get_parent().get_parent().select_topic(chip_id)

func init(chip_index):
	chip_id = chip_index

func set_display(topic_text, uses):
	$Topic.text = topic_text
	if(uses > 0):
		$Uses.text = 'x' + str(uses)
	else:
		$Uses.text = 'cd' + str(1 - uses)

func set_is_selected(is_selected):
	selected = is_selected
	if(is_selected):
		$Background.color = selected_BG_color
	else:
		$Background.color = unselected_BG_color

func _on_Background_mouse_entered():
	focused = true
	$Background.color = hovered_BG_color

func _on_Background_mouse_exited():
	focused = false
	if(selected):
		$Background.color = selected_BG_color
	else:
		$Background.color = unselected_BG_color
