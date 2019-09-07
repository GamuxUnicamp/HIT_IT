extends MarginContainer
onready var lifebar=$Lifebar1/TextureProgress
onready var tween=$Tween

var animated_health=100

func _process(delta):
	var round_value=round(animated_health)
	lifebar.value=round_value

func take_damage(health):#funcao tem como parametro vida atual
	update_health(health)
	
func update_health(new_bar_value):#atualiza o valor barra de vida
	
	tween.interpolate_property(self,"animated_health",animated_health,new_bar_value,0.5,tween.TRANS_LINEAR,Tween.EASE_IN)
	if not tween.is_active():
		tween.start()
func player_died():
	var start_color=Color(1.0,1.0,1.0,1.0)
	var end_color=Color(1.0,1.0,1.0,0.0)
	tween.interpolate_property(self,"modulate",start_color,end_color,0.7,Tween.TRANS_LINEAR,Tween.EASE_IN)
	get_tree().quit()