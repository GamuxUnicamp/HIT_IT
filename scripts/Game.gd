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
	game_time += delta
	rythm_update()

func rythm_update():
	var rythm_time = fmod(game_time, 60.0/bpm)/(60.0/bpm)
	
	# Ligar press_time no tempo e no contratempo
	if rythm_time <= 0.5:
		press_time = true
		rythm_signal_panel.show()
		if not rythm_sound_node.playing:
			rythm_sound_node.play()
	elif rythm_time > 0.625 and rythm_time < 0.875:
		press_time = true
		setback_signal_panel.show()
		if not setback_sound_node.playing:
			setback_sound_node.play()
	else:
		press_time = false
		p1_pressed = false
		p2_pressed = false
		rythm_signal_panel.hide()
		setback_signal_panel.hide()