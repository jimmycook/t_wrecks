extends KinematicBody2D

export var move_speed := 200.0

var jump_sounds = [
	preload("res://assets/hep_1.mp3"),
	preload("res://assets/hep_2.mp3"),
	preload("res://assets/hep_3.mp3")
]

export var jump_height: float
export var jump_time_to_peak: float
export var jump_time_to_descent: float

onready var jump_velocity: float = -1 * ((2.0 * jump_height) / jump_time_to_peak)
onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

onready var jump_force: float = jump_velocity * 0.025

var velocity := Vector2.ZERO 

var jump_timer := 0.0
var is_jumping := false

var buffered_jump = false

func _ready():
	randomize()

func _physics_process(delta):
	velocity.y += get_gravity() * delta
	velocity.x = get_input_velocity() * move_speed
	
	if velocity.x > 0 and $Sprite.flip_h:
		$Sprite.flip_h = false
	elif velocity.x < 0 and !$Sprite.flip_h:
		$Sprite.flip_h = true

	if !is_on_floor():
		$Sprite.play("jump")
	elif abs(velocity.x) > 0:
		$Sprite.play("walk")
	else:
		$Sprite.play("idle")

	if (Input.is_action_just_pressed("ui_jump") or buffered_jump) and is_on_floor():
		jump()
	elif Input.is_action_just_pressed("ui_jump") and jump_timer < 1:
		buffered_jump = true
	elif buffered_jump and !Input.is_action_pressed("ui_jump"):
		buffered_jump = false

	if Input.is_action_pressed("ui_jump") and jump_timer > 0:
		jump_timer -= delta
		if jump_timer > 0: 
			velocity.y += jump_force
	else:
		jump_timer = 0

	velocity = move_and_slide(velocity, Vector2.UP)

func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func get_input_velocity():
	var horizontal := 0.0
		
	if Input.is_action_pressed("ui_left"):
		horizontal -= 1
	if Input.is_action_pressed("ui_right"):
		horizontal += 1
	
	return horizontal

func jump():
	is_jumping = true
	buffered_jump = false
	jump_timer = jump_time_to_peak * 1.15
	velocity.y += jump_velocity

	$SoundEffect.stream = jump_sounds[randi() % jump_sounds.size()]
	$SoundEffect.play()
