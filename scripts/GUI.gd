extends MarginContainer

var animated_health_1 = 100
var animated_health_2 = 100

onready var lifebar = [$Lifebar_1/TextureProgress, $Lifebar_2/TextureProgress]
onready var tween = $Tween

# warning-ignore:unused_argument
func _process(delta):
	# Retorna se não precisar ser atualizado
	if not tween.is_active(): return
	
	# Atualiza a cada frame a vida dos jogadores
	lifebar[0].value = animated_health_1
	lifebar[1].value = animated_health_2

# Atualiza o valor barra de vida
func update_health(new_health, player):
	# Altera a vida do respectivo jogador
	if player == 1:
		tween.interpolate_property(self, "animated_health_1", animated_health_1, new_health, 0.5, tween.TRANS_LINEAR, Tween.EASE_IN)
	elif player == 2:
		tween.interpolate_property(self, "animated_health_2", animated_health_2, new_health, 0.5, tween.TRANS_LINEAR, Tween.EASE_IN)
	
	# Começa a animação da vida
	tween.start()


func player_died(index):
	get_tree().quit()