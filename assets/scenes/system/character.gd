extends CharacterBody2D

@export var move_speed = 10.0
@onready var anim = $CSprite
@export var moving=false
signal move_completed
func _physics_process(delta: float) -> void:
	if moving:
		move_and_slide()

func move_char(dir,duration):
	var t = get_tree().create_timer(duration)
	velocity = dir.normalized() * move_speed
	moving=true
	animate(velocity,true,true)
	await t.timeout
	velocity = Vector2.ZERO
	animate(dir,false,true)
	moving = false
	move_completed.emit()
	
	
func animate(dir: Vector2, move = false, setanim = false):
	var a_name = "down"
	
	if dir != null:
		var dir_angle = rad_to_deg(dir.angle())
		if dir_angle > -136 && dir_angle <= -45:
			a_name="up"
		elif dir_angle > -45 && dir_angle <= 45:
			a_name="right"
		elif dir_angle > 45 && dir_angle <= 136:
			a_name="down"
		else:
			a_name="left"
	
	if move:
		a_name += "_move"
	else:
		a_name += "_idle"
		
	if setanim:
		anim.animation = a_name
		anim.play()
