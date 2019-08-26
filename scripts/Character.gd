extends KinematicBody2D

const GRAVITY = 100000

var velocity = Vector2()
export var jump_velocity = 30000

func _physics_process(delta):
	# Gravidade do jogo
	velocity.y += delta * GRAVITY
	var motion = velocity * delta
	motion = move_and_slide(motion, Vector2(0,-1))

# Se o jogador estiver no chão, aplicar uma força vertical
func jump():
	if is_on_floor():
		velocity.y = -jump_velocity