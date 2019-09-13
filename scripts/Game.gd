extends Node2D

onready var background_panel = $Background
onready var rythm_signal_panel = $RythmSignal
onready var setback_signal_panel = $SetbackSignal
onready var rythm_sound_node = $SoundNodes/Rythm
onready var setback_sound_node = $SoundNodes/Setback

export var bpm = 80
var game_time = 0

var press_time = false
var pressed = [false,false]

onready var p = [$Player_1, $Player_2]

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

func _process(delta):
	game_time += delta # Relógio do jogo
	rythm_update() # Atualiza o ritmo do jogo
	
	# Definir o delay da música, para sincronizar com o metrônomo
	if not $SoundNodes/Music.playing and game_time >= 0.5:
		$SoundNodes/Music.play()

func _input(event):
	# Se não for um botão apertado, retornar
	if not event is InputEventKey: return
	
	# Checa se os jogadores pressionaram um botão
	p[0].input()
	p[1].input()

func rythm_update():
	# Porcentagem entre uma batida e outra
	var rythm_time = fmod(game_time, 60.0/bpm)/(60.0/bpm)
	
	# Ligar press_time no tempo e no contratempo
	if rythm_time <= 0.5: # Tempo
		press_time = true
		rythm_signal_panel.show() # Mostra quadrado branco
		if rythm_sound_node.visible:
			rythm_sound_node.play()
			rythm_sound_node.hide()
			
	elif rythm_time > 0.625 and rythm_time < 0.875: # Contratempo
		press_time = true
		setback_signal_panel.show() # Mostra quadrado azul
		if setback_sound_node.visible:
			setback_sound_node.play()
			setback_sound_node.hide()
	else:
		# Reiniciar objetos para a próxima batida
		press_time = false
		pressed = [false, false]
		rythm_sound_node.show()
		setback_sound_node.show()
		
		# Esconder os quadrados quando não for tempo nem contratempo
		rythm_signal_panel.hide()
		setback_signal_panel.hide()