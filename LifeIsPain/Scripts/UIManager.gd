extends Node2D

var setup_done = false
var saved_conversant = 'MissingNo.'

signal game_reset

func _process(delta):
	if(!setup_done):
		$ConvoManager.end_convo()
		$DeckManager.end_cust()
		$DebugConvoButton.visible = false
		setup_done = true

# allow for conversing via button input
func _input(event):
	if(event.is_action_pressed("converse")):
		if($DebugConvoButton.visible):
			_on_DebugConvoButton_pressed()
		elif($RestoreButton.visible):
			_on_RestoreButton_pressed()

func _on_DebugConvoButton_pressed():
	$ConvoManager.start_convo(saved_conversant)
	$DebugConvoButton.visible = false
	$RestoreButton.visible = false
	$DebugCustButton.visible = false

func _on_DebugCustButton_pressed():
	$DeckManager.start_cust()
	$DebugConvoButton.visible = false
	$RestoreButton.visible = false
	$DebugCustButton.visible = false

func _on_RestoreButton_pressed():
	$ConvoManager.add_stress(-100)
	get_node('../Player/RecoverEffect').trigger()

func _on_DeckManager_cust_ended():
	$DebugCustButton.visible = true

func _on_ConvoManager_convo_ended():
	$DebugCustButton.visible = true

func _on_Player_convo_available(conversant):
	if(conversant == 'Plushie'):
		$RestoreButton.visible = true
	else:
		$DebugConvoButton.visible = true
		saved_conversant = conversant

func _on_Player_convo_unavailable():
	$DebugConvoButton.visible = false
	$RestoreButton.visible = false
	saved_conversant = 'MissingNo.'


func _on_Narrator_game_restart():
	emit_signal("game_reset")
	
	# reset tutorial are fading
	get_node('../Environment/MeshInstance9').visible = true
