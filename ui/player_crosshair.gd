extends ColorRect

var player: Player = null

const hover_color = Color.ORANGE_RED
const nohover_color = Color.WHITE

func _ready():
	call_deferred("_find_player")

func _find_player():
	player = get_tree().get_first_node_in_group("player")

func _process(_delta):
	if player == null:
		return
	
	modulate = hover_color if player.interact_raycast.is_colliding() else nohover_color
