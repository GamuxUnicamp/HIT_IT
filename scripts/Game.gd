extends Node2D

onready var background_panel = $Background
onready var rythm_signal_panel = $RythmSignal
onready var setback_signal_panel = $SetbackSignal

var rythm_timer = Timer.new()
var rythm_threshold_timer = Timer.new()
var rythm_setback_delay_timer = Timer.new()
var rythm_setback_timer = Timer.new()

var press_time = false

onready var character = $Character

func _ready():
	# Definir e adicionar estilos (cores) para os painéis
	var background_style = StyleBoxFlat.new()
	var rythm_signal_style = StyleBoxFlat.new()
	var setback_signal_style = StyleBoxFlat.new()
	
	background_style.set_bg_color(Color(0,0,0))
	rythm_signal_style.set_bg_color(Color(1,1,1))
	setback_signal_style.set_bg_color(Color(0,0,.75))
	
	background_panel.add_stylebox_override("panel", background_style)
	rythm_signal_panel.add_stylebox_override("panel", rythm_signal_style)
	setback_signal_panel.add_stylebox_override("panel", setback_signal_style)
	
	background_panel.update()
	rythm_signal_panel.update()
	setback_signal_panel.update()
	
	# Definir o ritmo do jogo
	rythm_timer.set_wait_time(0.8)
	rythm_timer.connect("timeout", self, "_on_rythm_timeout")
	add_child(rythm_timer)
	rythm_timer.start()
	
	# Definir o limite de reação do usuário
	rythm_threshold_timer.set_wait_time(0.4)
	rythm_threshold_timer.connect("timeout", self, "_on_threshold_timeout")
	add_child(rythm_threshold_timer)
	
	# Definir o delay do contratempo
	rythm_setback_delay_timer.set_wait_time(0.1)
	rythm_setback_delay_timer.connect("timeout", self, "_on_setback_delay_timeout")
	add_child(rythm_setback_delay_timer)
	
	# Definir o contratempo
	rythm_setback_timer.set_wait_time(0.2)
	rythm_setback_timer.connect("timeout", self, "_on_setback_timeout")
	add_child(rythm_setback_timer)

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
	rythm_signal_panel.show()
	
	# O jogador deve reagir
	press_time = true
	
	# Começar a contagem do ritmo e do limite de reação
	rythm_timer.start()
	rythm_threshold_timer.start()

func _on_threshold_timeout():
	print('chamou')
	# Esconder o quadrado branco
	rythm_signal_panel.hide()
	
	# O jogador não deve mais pressionar
	press_time = false
	
	rythm_setback_delay_timer.start()

func _on_setback_delay_timeout():
	# Mostrar o quadrado azul
	setback_signal_panel.show()
	
	# Iniciar o tempo de resposta do contratempo
	rythm_setback_timer.start()
	press_time = true

func _on_setback_timeout():
	# Esconder o quadrado azul
	setback_signal_panel.hide()
	
	# O jogador não deve mais pressionar
	press_time = false