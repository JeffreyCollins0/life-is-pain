extends Node2D

#var UI_state = 'walk' # walk/talk/cust/fail/win/title
var current_UI = null

func _ready():
	pass # Replace with function body.

#func _process(delta):
#	pass

func change_state(new_state):
	#UI_state = new_state # add in checks later
	pass

func _on_DebugConvoButton_pressed():
	change_state('talk')
	$ConvoManager.start_convo()
	$DebugConvoButton.visible = false
	$DebugCustButton.visible = false


func _on_DebugCustButton_pressed():
	change_state('cust')
	$DeckManager.start_cust()
	$DebugConvoButton.visible = false
	$DebugCustButton.visible = false


func _on_DeckManager_cust_ended():
	change_state('walk')
	$DebugConvoButton.visible = true
	$DebugCustButton.visible = true


func _on_ConvoManager_convo_ended():
	change_state('walk')
	$DebugConvoButton.visible = true
	$DebugCustButton.visible = true
