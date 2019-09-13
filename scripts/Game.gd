extends Node2D

onready var background_panel = $Background
onready var rythm_signal_panel = $RythmSignal
onready var setback_signal_panel = $SetbackSignal
onready var rythm_sound_node = $SoundNodes/Rythm
onready var setback_sound_node = $SoundNodes/Setback

export var bpm = 80
var game_time = 0

var press_time = false
var p1_pressed = false
var p2_pressed = false

var acertou=[0,0]
var rodada=0

signal lose1
signal lose2
signal half_lose1
signal half_lose2

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
	
	connect("lose1",$Player_1,"take_damage_by_lose")
	connect("lose2",$Player_2,"take_damage_by_lose")
	connect("half_lose1",$Player_1,"take_damage_by_draw")
	connect("half_lose2",$Player_2,"take_damage_by_draw")
func _process(delta):
	game_time += delta # Relógio do jogo
	rythm_update() # Atualiza o ritmo do jogo

func rythm_update():
	# Porcentagem entre uma batida e outra
	var rythm_time = fmod(game_time, 60.0/bpm)/(60.0/bpm)
	
	# Definir o delay da música, para sincronizar com o metrônomo
	if not $SoundNodes/Music.playing and game_time >= 0.5:
		$SoundNodes/Music.play()
	
	# Ligar press_time no tempo e no contratempo
	if rythm_time <= 0.5: # Tempo
		press_time = true
		rodada=1
		rythm_signal_panel.show() # Mostra quadrado branco
		if rythm_sound_node.visible:
			rythm_sound_node.play()
			rythm_sound_node.hide()
	
	elif rodada==1:
		rodada=0
		comparacao()
	elif rythm_time > 0.625 and rythm_time < 0.875: # Contratempo
		press_time = true
		setback_signal_panel.show() # Mostra quadrado azul
		if setback_sound_node.visible:
			setback_sound_node.play()
			setback_sound_node.hide()
	else:
		# Reiniciar objetos para a próxima batida
		press_time = false
		p1_pressed = false
		p2_pressed = false
		rythm_sound_node.show()
		setback_sound_node.show()
		
		
		# Esconder os quadrados quando não for tempo nem contratempo
		rythm_signal_panel.hide()
		setback_signal_panel.hide()
		
		
func comparacao():
	print("comparou")
	if acertou[0]<acertou[1]:
		
		emit_signal("lose1")
		print("lose1")
	elif acertou[1]<acertou[0]:
		emit_signal("lose2")
	elif acertou[0]==0:
		emit_signal("half_lose1")
		emit_signal("half_lose2")
func refresh_acertos(player):
	acertou[player-1]=1