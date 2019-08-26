extends Node2D

onready var background_panel = $Background
onready var signal_panel = $Signal

var rythm_timer = Timer.new()
var rythm_threshold_timer = Timer.new()

var press_time = false

onready var character = $Character

func _ready():
	# Definir e adicionar estilos (cores) para os painéis
	var background_style = StyleBoxFlat.new()
	var signal_style = StyleBoxFlat.new()
	
	background_style.set_bg_color(Color(0,0,0))
	signal_style.set_bg_color(Color(1,1,1))
	
	background_panel.add_stylebox_override("panel", background_style)
	signal_panel.add_stylebox_override("panel", signal_style)
	
	background_panel.update()
	signal_panel.update()
	
	# Definir o ritmo do jogo
	rythm_timer.set_wait_time(0.8)
	rythm_timer.connect("timeout", self, "_on_rythm_timeout")
	add_child(rythm_timer)
	rythm_timer.start()
	
	# Definir o limite de reação do usuário
	rythm_threshold_timer.set_wait_time(0.4)
	rythm_threshold_timer.connect("timeout", self, "_on_threshold_timeout")
	add_child(rythm_threshold_timer)

func _input(event):
	# Fazer o personagem pular caso o jogador acerte
	if event.is_action_pressed("ui_accept"):
		if press_time:
			print("HIT!")
			character.jump()
		else:
			print("NO!")

func _on_rythm_timeout():
	# Exibir o quadrado branco
	signal_panel.show()
	
	# O jogador deve reagir
	press_time = true
	
	# Começar a contagem do ritmo e do limite de reação
	rythm_timer.start()
	rythm_threshold_timer.start()

func _on_threshold_timeout():
	# Esconder o quadrado branco
	signal_panel.hide()
	
	# O jogador não deve mais pressionar
	press_time = false