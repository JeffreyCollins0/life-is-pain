extends Area

export (String) var tutorial_title = 'MissingNo.'
export (int) var start_index = -1
export (int) var end_index = -1
var seen_already = false

func _on_Area_body_entered(body):
	if(body.is_in_group("Player") && !seen_already):
		$Panel.init(tutorial_title, start_index, end_index)
		$Panel.visible = true
		seen_already = true
		body.lock_player_movement()
		get_node('../../UIManager').lock_buttons()
		
		yield($Panel, "modal_ended")
		
		body.unlock_player_movement()
		get_node('../../UIManager').unlock_buttons()

func _on_UIManager_game_reset():
	seen_already = false
