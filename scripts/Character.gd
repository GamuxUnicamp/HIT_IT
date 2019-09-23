extends KinematicBody2D

enum { PAUSE, PUNCH, KICK, SPECIAL }

export var index = 1

var combo = []
var health = 100
var mistake_damage = 10

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
	var move
	if index == 1:
		if Input.is_action_just_pressed("punchP1"):
			move = PUNCH
		elif Input.is_action_just_pressed("kickP1"):
			move = KICK
		
		# Sai da função se não apertar uma tecla relevante
		else: return
	elif index == 2:
		if Input.is_action_just_pressed("punchP2"):
			move = PUNCH
		elif Input.is_action_just_pressed("kickP2"):
			move = KICK
		
		# Sai da função se não apertar uma tecla relevante
		else: return
	else: return
	
	# Retornar se o jogador já tiver errado o combo
	if combo == [-1]: return

	# Fazer o personagem pular caso o jogador acerte e receber dano caso erre
	if game.press_time:
		if not game.pressed[index-1]:
			game.pressed[index-1] = true
			combo.append(move)
			print(str(index) + ": HIT!")
			attack(move)
		else:
			combo = [-1]
			print(str(index) + ": DOUBLE CLICK!")
	else:
		combo = [-1]
		print(str(index) + ": WRONG TIME!")

# Se o jogador estiver no chão, aplicar uma força vertical
func attack(move):
	var colliding_bodies = detector.get_overlapping_bodies()
	
	if colliding_bodies == []:
		if index == 1:
			target = position + Vector2(100, 0)
		elif index == 2:
			target = position - Vector2(100, 0)
	else:
		for body in colliding_bodies:
			if body.is_in_group("player"):
				body.take_damage()

func take_damage():
	health -= mistake_damage
	emit_signal("health_reduced", health, index)
	if health <= 0:
		emit_signal("died", index)