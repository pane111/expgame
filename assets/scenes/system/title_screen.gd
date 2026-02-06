extends Node2D


func _ready() -> void:
	$CanvasLayer/VBoxContainer/PlayBtn.grab_focus()
	OptionsMenu.closed.connect(focus_play)
	AudioManager.force_music(AudioManager.title_music)



func _on_quit_btn_pressed() -> void:
	AudioManager.play_accept()
	get_tree().quit()

func focus_play():
	$CanvasLayer/VBoxContainer/PlayBtn.grab_focus()
func _on_play_btn_pressed() -> void:
	OptionsMenu.close_settings()
	AudioManager.play_accept()
	$CanvasLayer.hide()
	AudioManager.crossfade()
	await get_tree().create_timer(5).timeout
	GameManager.load_new_area(GameManager.start_area,Vector2(140,150))
	
	GameManager.fade_black_out(5)
	self.queue_free()


func _on_options_btn_pressed() -> void:
	AudioManager.play_accept()
	OptionsMenu.open_settings()


func _on_options_btn_focus_entered() -> void:
	AudioManager.play_select()


func _on_play_btn_focus_entered() -> void:
	AudioManager.play_select()


func _on_quit_btn_focus_entered() -> void:
	AudioManager.play_select()
