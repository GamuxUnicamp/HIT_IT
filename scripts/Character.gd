extends KinematicBody2D

const GRAVITY = 500000
export var jump_velocity = 80000
var velocity = Vector2()

export var index = 1
var health = 100
var mistake_damage = 10

signal health_reduced
signal died

onready var game = get_parent()

func _ready():
	connect("health_reduced", game.get_node("GUI"), "update_health")
	connect("died", game.get_node("GUI"), "player_died")
	
	# Se for o jogador 2, inverter sua sprite
	if index == 2: $AnimatedSprite.flip_h = true

func _physics_process(delta):
	# Gravidade do jogo
	velocity.y += delta * GRAVITY
	var motion = velocity * delta
	motion = move_and_slide(motion, Vector2(0,-1))

func input():
	# Sai da função se não apertar uma tecla relevante
	if index == 1:
		if not (Input.is_action_just_pressed("punchP1") or Input.is_action_just_pressed("kickP1") or Input.is_action_just_pressed("espP1")):
			return
	elif index == 2:
		if not (Input.is_action_just_pressed("punchP2") or Input.is_action_just_pressed("kickP2") or Input.is_action_just_pressed("espP2")):
			return

	# Fazer o personagem pular caso o jogador acerte e receber dano caso erre
	if game.press_time:
		if not game.pressed[index-1]:
			print(str(index) + ": HIT!")
			game.pressed[index-1] = true
			jump()
		else:
			print(str(index) + ": NO!")
			take_damage()
	else:
		print(str(index) + ": NO!")
		take_damage()

# Se o jogador estiver no chão, aplicar uma força vertical
func jump():
	if is_on_floor():
		velocity.y = -jump_velocity

func take_damage():
	health -= mistake_damage
	emit_signal("health_reduced", health, index)
	if health <= 0:
		emit_signal("died", index)