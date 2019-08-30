extends KinematicBody2D

const GRAVITY = 500000

var velocity = Vector2()
export var jump_velocity = 80000

onready var game = get_parent()

func _physics_process(delta):
	# Gravidade do jogo
	velocity.y += delta * GRAVITY
	var motion = velocity * delta
	motion = move_and_slide(motion, Vector2(0,-1))

func _input(event):
	# Fazer o personagem pular caso o jogador acerte
	if event.is_action_pressed("ui_accept"):
		if game.press_time:
			if not game.p1_pressed:
				print("HIT!")
				game.p1_pressed = true
				jump()
			else:
				print("NO!")
		else:
			print("NO!")

# Se o jogador estiver no chão, aplicar uma força vertical
func jump():
	if is_on_floor():
		velocity.y = -jump_velocity