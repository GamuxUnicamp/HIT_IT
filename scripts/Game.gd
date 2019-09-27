extends Node2D

export var bpm = 80

var combo_count = 1
var executed = [false, false, false, false]
var game_time = 0.0
var press_time = false
var pressed = [false,false]
var step = 0
var count_draw = 0

onready var background_panel = $Background
onready var rythm_signal_panel = $RythmSignal
onready var setback_signal_panel = $SetbackSignal
onready var rythm_sound_node = $SoundNodes/Rythm
onready var setback_sound_node = $SoundNodes/Setback
onready var p = [$Player_1, $Player_2]
onready var timer = $Timer

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
	
	# Define quem começa atacando
	randomize()
	p[floor(rand_range(0,2))].attacking = true

func _process(delta):
	game_time += delta # Relógio do jogo
	rythm_check() # Atualiza o ritmo do jogo
	
	# Definir o delay da música, para sincronizar com o metrônomo
	if not $SoundNodes/Music.playing:
		if p[0].health < p[1].health:
			print("Vencedor: Jogador 2")
		elif p[0].health > p[1].health:
			print("Vencedor: Jogador 1")
		else:
			print("Empate!")
		
		get_tree().quit()
		self.set_process(false)

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
					if pause_count >= 2:
						p[i].combo = [-1]
						print(str(i+1) + ": COMBO BREAK!")
						break
				else:
					pause_count = 0
	
	if combo_count == 6:
		combo_count = 1
		
		print("Combo 1: " + str(p[0].combo))
		print("Combo 2: " + str(p[1].combo))
		
		check_damage(p[0].combo, p[1].combo)
		
		p[0].combo = []
		p[1].combo = []

func check_damage(p1_combo, p2_combo):
	var attacking
	var defending
	var att_points
	var def_points
	
	if p[0].attacking:
		attacking = 0
		defending = 1
		att_points = combo_damage(p1_combo)
		def_points = combo_damage(p2_combo)
	else:
		attacking = 1
		defending = 0
		att_points = combo_damage(p2_combo)
		def_points = combo_damage(p1_combo)
	
	if att_points > def_points:
		if p[attacking].colliding():
			p[defending].take_damage(att_points)
			print("Player " + str(attacking+1) + " attacked! (" + str(att_points) + " damage)")
	
	else:
		count_draw += 1
		if not count_draw > 2:
			return
	
	p[attacking].attacking = false
	p[defending].attacking = true
	count_draw = 0

func combo_damage(full_combo):
	if full_combo == [-1]:
		return 0
	
	var rythm_combo = []
	for i in range(0,len(full_combo), 2):
		rythm_combo.append(full_combo[i])
	
	var count_setback = 0
	for i in range(1,len(full_combo), 2):
		if full_combo[i] == p[0].HIT:
			count_setback += 1
	
	match rythm_combo:
		[0,1,0,1,0]:
			return 2 * (1 + count_setback*0.25)
		
		[1,0,1,0,1]:
			return 3 * (1 + count_setback*0.25)
		
		[0,1,1,1,1], [1,1,1,1,0]:
			return 4 * (1 + count_setback*0.25)
		
		[1, 1, 1, 1, 1]:
			return 5 * (1 + count_setback*0.25)
		
		[0,1,0,1,1], [0,1,1,0,1], [1,0,1,1,0], [1,1,0,1,0]:
			return 6 * (1 + count_setback*0.25)
		
		[1,1,0,1,1]:
			return 10 * (1 + count_setback*0.25)
		
		[0,1,1,1,0]:
			return 11 * (1 + count_setback*0.25)
		
		[1,0,1,1,1], [1,1,1,0,1]:
			return 12 * (1 + count_setback*0.25)