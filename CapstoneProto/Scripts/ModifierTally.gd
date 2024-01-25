extends Node2D

# fill with array instances of format [index, modifier, duration]
var active_modifiers = []
var modifier_index = 0

func modifier_tick():
	for i in range(len(active_modifiers)):
		var mod = active_modifiers[i]
		mod[2] -= 1
		if(mod[2] <= 0):
			print('removing a +'+str(mod[1])+' modifier at position '+str(i))
			active_modifiers.remove(i)
			i -= 1

func add_modifier(amount, duration = 1):
	active_modifiers.append([modifier_index, amount, duration])
	modifier_index += 1
	return modifier_index

func get_net_modifier():
	var total = 0
	for mod in active_modifiers:
		total += mod[1]
	return total
