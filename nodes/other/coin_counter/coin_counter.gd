extends Label

var coins: int = 0

var tween: Tween = null

func add_coins(amount: int):
	set_coins(coins + amount)

func set_coins(new_coins: int):
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_method(_display_callback, coins, new_coins, 1)
	coins = new_coins

func _display_callback(value: int):
	text = str(value)
