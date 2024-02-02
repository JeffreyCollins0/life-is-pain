extends Node2D

#var UI_state = 'walk' # walk/talk/cust/fail/win/title
#var current_UI = null
var setup_done = false

func _ready():
	pass

func _process(delta):
	if(!setup_done):
		$ConvoManager.end_convo()
		$DeckManager.end_cust()
		$DebugConvoButton.visible = false
		setup_done = true

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


func _on_Player_convo_available(conversant):
	$DebugConvoButton.visible = true

func _on_Player_convo_unavailable():
	$DebugConvoButton.visible = false
