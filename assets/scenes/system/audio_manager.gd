extends Control

@onready var mloopt = $MusicLoopTimer
@export var title_music: AudioStream
@export var random_music: AudioStream
@export var loop_times = 1.0
signal fade_complete

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("tab"):
		crossfade(2,0)

func play_accept():
	$Accept.play()
func force_music(m):
	$MusicLayer1.volume_linear=0
	$MusicLayer1.stream = m
	$MusicLayer1.play()
	var tween_in = get_tree().create_tween()
	tween_in.tween_property($MusicLayer1,"volume_linear",1,5)
func play_select():
	$Select.play()
func fade_out(dur = 5.0):
	var tween_out = get_tree().create_tween()
	tween_out.tween_property($MusicLayer1,"volume_linear",0,dur)
	await tween_out.finished
	$MusicLayer1.stop()
	fade_complete.emit()

func crossfade(dur=5.0,wait=15.0):
	var tween_out = get_tree().create_tween()
	tween_out.tween_property($MusicLayer1,"volume_linear",0,dur)
	await tween_out.finished
	if $MusicLayer1.stream == title_music:
		$MusicLayer1.stream = random_music
	await get_tree().create_timer(wait).timeout
	$MusicLayer1.stop()
	$MusicLayer1.play()
	mloopt.wait_time = $MusicLayer1.stream.get_length() * loop_times
	mloopt.start()
	print_debug("Started Music Loop timer, length: " + str(mloopt.wait_time))
	var tween_in = get_tree().create_tween()
	tween_in.tween_property($MusicLayer1,"volume_linear",1,dur)
