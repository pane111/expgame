extends "res://assets/scenes/system/character.gd"

@export var default_anim = "down_idle"
@export var dia_name = "TestDialogue"
@export var c_portrait : Texture2D
enum movement_types {IDLE,RANDOM,SEQUENCE}
@export var type = movement_types.IDLE
@export var min_move_timer = 1.0
@export var max_move_timer = 6.0
@export var move_duration = 0.5
const directions = [Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT,Vector2.UP]
var paused = false
var rng
func _ready() -> void:
	anim.animation = default_anim
	anim.play()
	rng = RandomNumberGenerator.new()
	reset_move_timer()


func onInteract():
	print_debug("Interacted")
	paused = true
	GameManager.start_dialogue(dia_name, c_portrait)
	await GameManager.dialogue_ended
	paused=false
	reset_move_timer()

func reset_move_timer():
	$MovementTimer.wait_time = rng.randf_range(min_move_timer,max_move_timer)
	$MovementTimer.start()

func _on_movement_timer_timeout() -> void:
	if type != movement_types.RANDOM || paused: return
	var dir = directions.pick_random()
	move_char(dir,move_duration)
	await move_completed
	reset_move_timer()
	
