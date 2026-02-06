extends Node

var dialogue_file = "res://addons/pjdialogue/dialogue_cont.json"
var dicts = {}

func get_dialogue(d_name):
	var dialoguefile = FileAccess.open(dialogue_file,FileAccess.READ)
	while dialoguefile.get_position() < dialoguefile.get_length():
		var jsonstring = dialoguefile.get_line()
		var json = JSON.new()
		var parse_result = json.parse(jsonstring)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", jsonstring, " at line ", json.get_error_line())
			continue
		var data = json.data
		
		var dataname = data["name"]
		dicts[dataname] = data
	dialoguefile.close()
	return dicts[d_name]
