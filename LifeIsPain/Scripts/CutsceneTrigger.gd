extends Area

signal custcene_activated
var seen_already = false

func _on_Area_body_entered(body):
	if(body.is_in_group("Player") && !seen_already):
		var narrator = get_tree().get_root().get_node('Spatial/UIManager/Narrator')
		narrator.invoke_narration()
		
		seen_already = true
		body.lock_player_movement()
		emit_signal("custcene_activated")

func _on_UIManager_game_reset():
	seen_already = false
