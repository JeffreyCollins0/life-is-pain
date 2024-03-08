extends Spatial

export (float) var disappear_thres = 0.2
var player = null

func _ready():
	player = get_tree().get_root().get_node('Spatial/Player')
	if(player != null):
		player.connect("moved_threshold_dist", self, "on_player_move")

func on_player_move():
	var player_pos = player.global_translation
	var camera_basis = -(player.get_node("CameraMount").transform.basis.z)
	var basis_pos_diff = (player_pos - global_translation).dot(camera_basis)
	
	if(basis_pos_diff > disappear_thres && visible):
		visible = false
	elif(basis_pos_diff < disappear_thres && !visible):
		visible = true
