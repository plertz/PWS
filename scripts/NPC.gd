extends KinematicBody

var talking = false

onready var sub = $Sub
onready var text_field = $Sub/text_rect/text
onready var timer = $Text_timer

export (Array, String) var text = []
export (float) var delay_time_s = 0.1
var lines = 0;
var text_length = [];
var letter_pt = 0
var line_pt = 0;
var current_text = ""

onready var spatial_parent = get_parent()
var player

func _ready():
	if get_tree().get_root().has_node("Main/World/Player"):
		player = get_tree().get_root().get_node("Main/World/Player")
	else:
		player = get_tree().get_root().get_node("World/Player")

	timer.connect("timeout", self, "print_text")
	timer.one_shot = false;
	timer.wait_time = delay_time_s;

func get_player_cor():
	var player_cor = player.translation
	player_cor.y = 0
	print(player_cor)
	return player_cor

func get_own_cor():
	var par_cor = spatial_parent.translation;
	var own_cor = par_cor + translation;
	own_cor.y = 0
	return own_cor

func turn(direction):
	direction = direction.normalized()
	direction = Vector2(direction.x, direction.z)
	var rot = direction.angle()
	rotation.y = -rot - (0.5 * 3.14)

func talk():
	turn(get_player_cor() - get_own_cor())
	if sub.visible:
		sub.hide()
		talking = false
	else:
		sub.show()
		make_text_map()
		talking = true
		timer.start()

func leave():
	sub.hide()
	talking = false
	clear()

func next():
	if line_pt == lines - 1:
		timer.stop()
		return false
	line_pt += 1;
	letter_pt = 0;
	current_text = ""
	print_char()
	timer.start()
	return true

func make_text_map():
	lines = text.size()

	for j in text:
		text_length.append(j.length())

func print_char():
	current_text += text[line_pt].substr(letter_pt, 1)
	text_field.text = current_text
	letter_pt += 1

func print_text():
	if letter_pt < text_length[line_pt]:
		print_char()
	else:
		timer.stop()
		return


func clear():
	current_text =""
	text_field.text = current_text
	line_pt = 0
	letter_pt = 0
