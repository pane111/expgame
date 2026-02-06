extends "res://assets/scenes/system/character.gd"

var lastdir: Vector2
@export var inter_range = 30.0
@export var sprintspeed = 2.0
@export var severity = 0.0
@export var bloodstain : PackedScene
@onready var timer = $CoughTimer
@export var csound1: AudioStream
@export var csound2: AudioStream
@export var bloodsound: AudioStream
var handle_input = true : set = _set_input
var can_inter = false
var cur_inter
var speedmult = 1.0
signal input_enabled
func move_char(dir,duration):
	await super.move_char(dir,duration)
	moving=true
func _set_input(val):
	handle_input = val
	input_enabled.emit()

func _ready() -> void:
	handle_input=false
	await anim.animation_finished
	##GameManager.start_dialogue("FirstGuy",load("uid://d4agx60c7xqtr"))
	handle_input=true
	lastdir = Vector2.DOWN
	
func player_sfx(sfx):
	$AudioStreamPlayer2D.stream = sfx
	$AudioStreamPlayer2D.play()
func player_sfx_layer2(sfx):
	$AudioStreamPlayer2D2.stream = sfx
	$AudioStreamPlayer2D2.play()

func cough():
	if handle_input:
		handle_input = false
		velocity = Vector2.ZERO
		anim.speed_scale = 1.0
		anim.animation = "cough"
		player_sfx(csound1)
		await get_tree().create_timer(1).timeout
		var rnd = RandomNumberGenerator.new()
		var coughagain = rnd.randf_range(0,100)
		if coughagain <= severity:
			anim.animation = "cough2"
			player_sfx(csound2)
			var blood = rnd.randf_range(0,100)
			if blood <= severity/2.5 || GameManager.progress >= 100:
				var b = bloodstain.instantiate()
				b.global_position = global_position
				add_sibling(b)
				player_sfx_layer2(bloodsound)
			
			await get_tree().create_timer(2).timeout
			if GameManager.progress >= 100 && coughagain <= 20:
				anim.animation = "death"
				await get_tree().create_timer(5).timeout
				GameManager.trigger_ending("Ending A\n-\nDeath")
				return
		anim.animation = "down_idle"
		handle_input=true
		$CoughTimer.start()
	else:
		$CoughTimer.start()

func _unhandled_input(_event: InputEvent) -> void:
	if !handle_input:
		return
	var inp = Input.get_vector("left","right","up","down")
	
	if Input.is_action_pressed("sprint"):
		if severity < 100:
			speedmult = sprintspeed
	else:
		speedmult = 1.0
		if severity >= 100:
			speedmult = 0.65
	
	if $Detector.is_colliding():
		cur_inter = $Detector.get_collider()
		can_inter=true
	else:
		cur_inter=null
		can_inter=false
	velocity = inp.normalized() * move_speed * speedmult
	anim.speed_scale = speedmult
	if inp.length() > 0:
		lastdir = inp.normalized()
		moving=true
		$Detector.target_position = inp * inter_range
		$DV.set_point_position(0,$Detector.position)
		$DV.set_point_position(1,$Detector.target_position)
		animate(velocity,true,true)
	else:
		moving=false
		animate(lastdir,false,true)
		
	
	if Input.is_action_just_pressed("ok") && can_inter && cur_inter!=null:
		cur_inter.onInteract()
		velocity = Vector2.ZERO
		animate(lastdir,false,true)
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	position = position.clamp(Vector2.ZERO,Vector2(99999,99999))

func _on_cough_timer_timeout() -> void:
	cough()


func _on_c_sprite_frame_changed() -> void:
	if velocity.length() > 0 && anim != null:
		if anim.frame == 0 || anim.frame == 2:
			$Footstep.play()
