extends Node2D

export var bpm = 80

var combo_count = 1
var executed = [false, false, false, false]
var game_time = 0.0
var press_time = false
var pressed = [false,false]
var step = 0

onready var background_panel = $Background
onready var rythm_signal_panel = $RythmSignal
onready var setback_signal_panel = $SetbackSignal
onready var rythm_sound_node = $SoundNodes/Rythm
onready var setback_sound_node = $SoundNodes/Setback
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
	rythm_check() # Atualiza o ritmo do jogo
	
	# Definir o delay da música, para sincronizar com o metrônomo
	if not $SoundNodes/Music.playing and game_time > 0.0:
		$SoundNodes/Music.play()

func _input(event):
	# Se não for um botão apertado, retornar
	if not event is InputEventKey: return
	
	# Checa se os jogadores pressionaram um botão
	p[0].input()
	p[1].input()

func rythm_check():
	# Porcentagem entre uma batida e outra
	var rythm_time = fmod(game_time, 60.0/bpm)/(60.0/bpm)
	
	if rythm_time <= 0.5: # Tempo
		step = 0
	elif rythm_time <= 0.625: # Miss
		step = 1
	elif rythm_time < 0.875: # Contratempo
		step = 2
	elif rythm_time <= 1.0: # Miss
		step = 3
	
	if executed[step]: return
	rythm_update(step)

func rythm_update(step):
	match step:
		0: # Tempo
			combo_count += 1
			press_time = true
			rythm_signal_panel.show() # Mostra quadrado branco
			if rythm_sound_node.visible:
				rythm_sound_node.play()
				rythm_sound_node.hide()
				
			executed = [true, false, false, false]
			
		1: # Fail
			# Marcar pausa, se necessário
			for i in range(2):
				if p[i].combo != [-1] and not pressed[i]:
					p[i].combo.append(p[i].PAUSE)
			
			# Reiniciar objetos para a próxima batida
			press_time = false
			pressed = [false, false]
			rythm_sound_node.show()
			setback_sound_node.show()
			
			# Esconder os quadrados quando não for tempo nem contratempo
			rythm_signal_panel.hide()
			setback_signal_panel.hide()
			
			executed = [true, true, false, false]
				
		2: # Contratempo
			press_time = true
			setback_signal_panel.show() # Mostra quadrado azul
			if setback_sound_node.visible:
				setback_sound_node.play()
				setback_sound_node.hide()
			
			executed = [true, true, true, false]
				
		3: # Fail
			# Marcar pausa, se necessário
			for i in range(2):
				if p[i].combo != [-1] and not pressed[i]:
					p[i].combo.append(p[i].PAUSE)
			
			# Contabilizar os combos de ambos jogadores
			check_combos()
			
			# Reiniciar objetos para a próxima batida
			press_time = false
			pressed = [false, false]
			rythm_sound_node.show()
			setback_sound_node.show()
			
			# Esconder os quadrados quando não for tempo nem contratempo
			rythm_signal_panel.hide()
			setback_signal_panel.hide()
			
			executed = [false, true, true, true]

func check_combos():
	# Combo break
	for i in range(2):
		if p[i].combo != [-1] and p[i].combo.size() > 2:
			# Contar quantos pauses seguidos
			var pause_count = 0
			for j in range(0, p[i].combo.size(), 2): # Checa apenas o tempo (índices pares)
				if p[i].combo[j] == p[i].PAUSE:
					pause_count += 1
					if pause_count > 2:
						p[i].combo = [-1]
						print(str(i+1) + ": COMBO BREAK!")
						break
	
	if combo_count == 6:
		combo_count = 1
		
		print("Combo 1: " + str(p[0].combo))
		print("Combo 2: " + str(p[1].combo))
		
		p[0].combo = []
		p[1].combo = []