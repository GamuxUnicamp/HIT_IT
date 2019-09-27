extends KinematicBody2D

enum { PAUSE, HIT }

export var index = 1

var combo = []
var health = 100
var attacking = false

var speed = 200
onready var target = position
var velocity = Vector2()

signal health_reduced
signal died

var detector
onready var game = get_parent()

func _ready():
	add_to_group("player")
	
	connect("health_reduced", game.get_node("GUI"), "update_health")
	connect("died", game.get_node("GUI"), "player_died")
	
	# Direção da sprite e posição do detector
	detector = $CollisionDetector
	if index == 1:
		detector.position.x += 175
	elif index == 2:
		detector.position.x -= 175
		$AnimatedSprite.flip_h = true

func _physics_process(delta):
	velocity = (target - position).normalized() * speed
	if (target - position).length() > 5:
		velocity = move_and_slide(velocity)

func input():
	if index == 1:
		if not Input.is_action_just_pressed("punchP1"):
			return
	elif index == 2:
		if not Input.is_action_just_pressed("punchP2"):
			return
	
	# Retornar se o jogador já tiver errado o combo
	if combo == [-1]: return

	# Fazer o personagem pular caso o jogador acerte e receber dano caso erre
	if game.press_time:
		if not game.pressed[index-1]:
			game.pressed[index-1] = true
			combo.append(HIT)
			print(str(index) + ": HIT!")
			move()
		else:
			combo = [-1]
			print(str(index) + ": DOUBLE CLICK!")
	else:
		combo = [-1]
		print(str(index) + ": WRONG TIME!")

# Se o jogador estiver no chão, aplicar uma força vertical
func move():
	if not colliding():
		if index == 1:
			target = position + Vector2(100, 0)
		elif index == 2:
			target = position - Vector2(100, 0)

func colliding():
	var colliding_bodies = detector.get_overlapping_bodies()
	
	if colliding_bodies == []:
		return false
	else:
		return true

func take_damage(damage):
	health -= damage
	emit_signal("health_reduced", health, index)
	if health <= 0:
		emit_signal("died", index)