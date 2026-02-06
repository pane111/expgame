@tool
extends EditorPlugin

const MainPanel = preload("res://addons/pjdialogue/pjd.tscn")
var panel_instance

func _enable_plugin() -> void:
	add_autoload_singleton("PJGlobal","res://addons/pjdialogue/pjglobal.gd")


func _disable_plugin() -> void:
	remove_autoload_singleton("PJGlobal")


func _enter_tree() -> void:
	panel_instance = MainPanel.instantiate()
	EditorInterface.get_editor_main_screen().add_child(panel_instance)
	_make_visible(false)


func _exit_tree() -> void:
	if panel_instance:
		panel_instance.queue_free()
	
func _has_main_screen() -> bool:
	return true
	
func _make_visible(visible: bool) -> void:
	if panel_instance:
		panel_instance.visible = visible
	
func _get_plugin_name() -> String:
	return "PJDialogue"
	
func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
