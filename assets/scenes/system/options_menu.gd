extends CanvasLayer

var settingsopen = false
signal closed
func _unhandled_input(event: InputEvent) -> void:
	if GameManager.player == null || GameManager.player.handle_input==false: return
	if Input.is_action_just_pressed("escape"):
		AudioManager.play_select()
		if settingsopen: close_settings()
		else: open_settings()


func open_settings():
	$Control/OptionPanel.show()
	$Control/OptionPanel/VBoxContainer/CloseOpt.grab_focus()
	settingsopen=true
func close_settings():
	$Control/OptionPanel.hide()
	settingsopen=false
	closed.emit()
func set_status(txt):
	$Control/OptionPanel/VBoxContainer/Status.text="(DEBUG) " + txt
func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(0,value)


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(2,value)


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(1,value)
	AudioManager.play_select()


func _on_close_opt_pressed() -> void:
	AudioManager.play_accept()
	close_settings()
