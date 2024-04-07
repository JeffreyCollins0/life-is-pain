extends Spatial

export (float) var move_duration = 0.12
export (Curve) var move_curve

var start_pos
var end_pos
var move_time = 0

func _ready():
	start_pos = get_node('../StartPos')
	end_pos = get_node('../EndPos')

func _process(delta):
	if(move_time > 0):
		move_time -= delta
		
		var move_vec = (end_pos.translation - start_pos.translation)
		self.translation = start_pos.translation + (move_vec * move_curve.interpolate(1 - (move_time / move_duration)) )
		
		if(move_time <= 0):
			visible = false
			self.translation = start_pos.translation

func trigger():
	self.translation = start_pos.translation
	visible = true
	move_time = move_duration
