extends KinematicBody2D

const GRAVITY = 500000
var velocity = Vector2()
export var jump_velocity = 80000
var health=100
var health_reduced_in_mistake=10

onready var game = get_parent()

signal health_reduced
signal died

func _ready():
	connect("health_reduced",game.get_node("GUI"), "take_damage")
	connect("died",game.get_node("GUI"),"player_died")
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
				if(health!=0):
					if health!=health_reduced_in_mistake:
						health=health-health_reduced_in_mistake
						emit_signal("health_reduced",health)
					else:
						emit_signal("died")
		else:
			print("NO!")
			if(health!=0):
				if health!=health_reduced_in_mistake:
					health=health-health_reduced_in_mistake
					emit_signal("health_reduced",health)
				else:
					emit_signal("died")
# Se o jogador estiver no chão, aplicar uma força vertical
func jump():
	if is_on_floor():
		velocity.y = -jump_velocity