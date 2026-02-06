extends Node2D

@onready var dialogue = $UI/Dialogue
@onready var texts = [$UI/Dialogue/Text1,$UI/Dialogue/Text2, $UI/Dialogue/Text3]
var player
@onready var dchar = $UI/Dialogue/DialogueBG/DialogueChar
@onready var txtpanel = $UI/TextPanel
@onready var signtxt = $UI/TextPanel/SignText
@export var progress = 0.0
@export var increment = 1.0
@export var initial_coughtimer = 110.0
@export var coughtimer_reduction = 1.0
@export var clicksound: AudioStream
@export var playerScn: PackedScene
@export var title_screen: PackedScene
@export var start_area: PackedScene
@onready var main_cam = $MainCam
signal ok
signal dialogue_ended
var prevtext
var activetween
var cur_area
signal fade_complete

func _ready() -> void:
	dialogue.modulate = Color.TRANSPARENT
	txtpanel.modulate = Color.TRANSPARENT
	for t in texts:
		t.visible_characters=0
	
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ok"):
		ok.emit()
		if activetween != null:
			activetween.pause()
			activetween.custom_step(200)


func ui_sfx(sfx):
	$UI/UI_SFX.stream = sfx
	$UI/UI_SFX.play()
	

func fade_black(dur=1.0):
	var tween = get_tree().create_tween()
	tween.tween_property($UI/BlackFade,"self_modulate",Color(0,0,0,1),dur)
	await tween.finished
	fade_complete.emit()
	
func fade_black_out(dur=1.0):
	var tween = get_tree().create_tween()
	tween.tween_property($UI/BlackFade,"self_modulate",Color(0,0,0,0),dur)
	await tween.finished
	fade_complete.emit()

func display_text(txt):
	activetween=null
	player.handle_input = false
	signtxt.visible_characters=0
	signtxt.text = txt
	var tween = get_tree().create_tween()
	tween.tween_property(txtpanel,"modulate",Color.WHITE,0.4)
	await tween.finished
	var tween2 = get_tree().create_tween()
	$ClickingTimer.start()
	tween2.tween_property(signtxt,"visible_characters", txt.length(), 0.02*txt.length())
	activetween=tween2
	await tween2.finished
	$ClickingTimer.stop()
	$UI/UI_SFX.stop()
	activetween=null
	await ok
	var tween3 = get_tree().create_tween()
	tween3.tween_property(txtpanel,"modulate",Color.TRANSPARENT,0.4)
	await tween3.finished
	player.handle_input=true

func start_dialogue(d, portrait = null):
	dchar.modulate = Color.BLACK
	if portrait != null:
		dchar.show()
		var newstyle = StyleBoxTexture.new()
		newstyle.texture = portrait
		dchar.add_theme_stylebox_override("panel",newstyle)
	else:
		dchar.hide()
	player.handle_input = false
	
	
	
	for t in texts:
		t.visible_characters=0
	var dia = PJGlobal.get_dialogue(d)
	if dia == null:
		print_debug("Error loading dialogue")
		return
	print_debug("Loaded "+dia["name"])
	var content = dia["content"].split("\n")
	dialogue.show()
	var tween = get_tree().create_tween()
	tween.tween_property(dialogue,"modulate",Color.WHITE,0.4)
	await tween.finished
	tween = get_tree().create_tween()
	tween.tween_property(dchar,"modulate",Color.WHITE,1.2)
	await tween.finished
	var index = 0
	while index < content.size():
		var curtext = index%3
		texts[curtext].text = content[index]
		texts[curtext].visible_characters = 0
		texts[curtext].modulate = Color.WHITE
		tween = get_tree().create_tween()
		if !prevtext == null:
			tween.tween_property(prevtext,"modulate",Color.TRANSPARENT,0.4)
			await tween.finished
		tween = get_tree().create_tween()
		activetween=tween
		$ClickingTimer.start()
		tween.tween_property(texts[curtext],"visible_characters",texts[curtext].text.length(),0.07 * texts[curtext].text.length())
		prevtext = texts[curtext]
		await tween.finished
		$ClickingTimer.stop()
		$UI/UI_SFX.stop()
		activetween=null
		await ok
		index = index+1
	
	tween = get_tree().create_tween()
	tween.tween_property(dialogue,"modulate",Color.TRANSPARENT,0.4)
	await tween.finished
	prevtext = null
	await get_tree().create_timer(0.2).timeout
	player.handle_input=true
	dialogue_ended.emit()

func trigger_ending(txt):
	$UI/BlackFade/EndingText.text = txt
	fade_black(3)
	AudioManager.fade_out(3)
	await get_tree().create_timer(5).timeout
	$UI/BlackFade/EndingText.show()
	await get_tree().create_timer(5).timeout
	$UI/BlackFade/EndingText.hide()
	main_cam.reparent(self)
	main_cam.position=Vector2.ZERO
	player.queue_free()
	cur_area.queue_free()
	player=null
	cur_area=null
	var ts = title_screen.instantiate()
	add_child(ts)
	

func _on_increment_progress_timeout() -> void:
	if player == null: return
	if player.handle_input == false: return
	progress += increment * player.speedmult
	
	var ctime = initial_coughtimer-(progress*coughtimer_reduction)
	if ctime < 11: ctime=11
	if progress >= 100:
		progress = 100
		$IncrementProgress.stop()
		player.speedmult=0.65
		ctime = 10
	else:
		if progress > 1 && roundi(progress) % 25 == 0:
			print_debug("Progress divisible by 25: " + str(progress))
			if !player.handle_input:
				await player.input_enabled
			player.cough()
			player.timer.stop()
			player.timer.start()
	player.timer.wait_time = ctime
	player.severity = progress
	OptionsMenu.set_status("Status: " + str(round(progress)))
	$UI/ProgressBar.value = progress
func spawn_player(pos = Vector2.ZERO):
	player = playerScn.instantiate()
	add_child(player)
	main_cam.reparent(player)
	player.global_position = pos
	player.timer.wait_time = initial_coughtimer
	player.timer.start()
	progress=0
	$IncrementProgress.start()


func _on_clicking_timer_timeout() -> void:
	ui_sfx(clicksound)


func load_new_area(area,pos=Vector2.ZERO):
	if area == null: return
	if player==null: spawn_player(pos)
	
	var new_area = area.instantiate()
	if cur_area != null: cur_area.queue_free()
	add_child(new_area)
	cur_area=new_area
