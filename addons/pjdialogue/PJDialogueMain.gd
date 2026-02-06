@tool
extends Control

@export var cur_cont = "res://addons/pjdialogue/dialogue_cont.json"
@export var testdias = false

var dicts = {}


func _ready() -> void:
	if testdias:
		var testdia = {
			"name" : "TestDialogue",
			"content" : "Line 1\nLine 2\nLine 3\nLine 4\nLine 5"
		}
		var testjson = JSON.stringify(testdia)
		
		var testdia2 = {
			"name" : "AnotherTestDialogue",
			"content" : "Abcadawdawd\nawdawdawdaw\nLwadawdsdghtrg"
		}
		var testjson2 = JSON.stringify(testdia2)
		
		
		
		print_debug(testjson)
		var contfile = FileAccess.open(cur_cont,FileAccess.READ_WRITE)
		contfile.store_line(testjson)
		contfile.store_line(testjson2)
		contfile.close()
	dicts.clear()
	var dialoguefile = FileAccess.open(cur_cont,FileAccess.READ)
	while dialoguefile.get_position() < dialoguefile.get_length():
		var jsonstring = dialoguefile.get_line()
		var json = JSON.new()
		var parse_result = json.parse(jsonstring)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", jsonstring, " at line ", json.get_error_line())
			continue
		var data = json.data
		
		print_debug("Added dialogue: " + data["name"])
		
		var dataname = data["name"]
		dicts[dataname] = data
	dialoguefile.close()
	
	load_list()
		
		
	
	

func editdialogue(index):
	print_debug("Editing text: " + dicts[index]["name"])
	$UI/NameEdit.text = dicts[index]["name"]
	$UI/TextEdit.text = dicts[index]["content"]

func load_list():
	if dicts.is_empty():
		print_debug("Dicts empty")
		return
	for b in $UI/DiaContainer.get_children():
		b.queue_free()
	var index = ""
	for item in dicts:
		var nb = Button.new()
		nb.text = dicts[item]["name"]
		index = dicts[item]["name"]
		nb.pressed.connect(editdialogue.bind(index))
		$UI/DiaContainer.add_child(nb)

func _on_save_btn_pressed() -> void:
	var dname = $UI/NameEdit.text
	dicts[dname] = {
		"name" : dname,
		"content" : $UI/TextEdit.text
	}
	var contfile = FileAccess.open(cur_cont,FileAccess.WRITE)
	for item in dicts:
		var js = JSON.stringify(dicts[item])
		contfile.store_line(js)
	contfile.close()
	load_list()
	
	
