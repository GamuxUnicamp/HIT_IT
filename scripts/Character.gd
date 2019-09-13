extends KinematicBody2D

const GRAVITY = 500000
var velocity = Vector2()
export var jump_velocity = 80000
var health=100
var health_reduced_in_mistake=10

<<<<<<< Updated upstream
onready var game = get_parent()
=======
export var index = 1
var health = 100
var mistake_damage = 10
var draw_damage=5
var lose_damage=10
>>>>>>> Stashed changes

signal health_reduced
signal died
signal acertou

func _ready():
<<<<<<< Updated upstream
	connect("health_reduced",game.get_node("GUI"), "take_damage")
	connect("died",game.get_node("GUI"),"player_died")
=======
	connect("health_reduced", game.get_node("GUI"), "update_health")
	connect("died", game.get_node("GUI"), "player_died")
	connect("acertou",game,"refresh_acertos")
	# Se for o jogador 2, inverter sua sprite
	if index == 2: $AnimatedSprite.flip_h = true

>>>>>>> Stashed changes
func _physics_process(delta):
	# Gravidade do jogo
	velocity.y += delta * GRAVITY
	var motion = velocity * delta
	motion = move_and_slide(motion, Vector2(0,-1))

<<<<<<< Updated upstream
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
=======


		
	
	
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
			emit_signal("acertou",index)
			jump()
		else:
			print(str(index) + ": NO!")
			take_damage_by_mistake()
	else:
		print(str(index) + ": NO!")
		take_damage_by_mistake()

# Se o jogador estiver no chão, aplicar uma força vertical
func jump():
	if is_on_floor():
		velocity.y = -jump_velocity

func take_damage_by_mistake():
	health -= mistake_damage
	emit_signal("health_reduced", health, index)
	if health <= 0:
		emit_signal("died", index)

func take_damage_by_lose():
	health -= lose_damage
	emit_signal("health_reduced", health, index)
	if health <= 0:
		emit_signal("died", index)

func take_damage_by_draw():
	health -= draw_damage
	emit_signal("health_reduced", health, index)
	if health <= 0:
		emit_signal("died", index)
>>>>>>> Stashed changes
