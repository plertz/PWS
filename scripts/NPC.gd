extends KinematicBody

var talking = false

onready var sub = $Sub
onready var text_field = $Sub/text_rect/text
onready var timer = $Text_timer

export (String) var text = ["Hello there strange", "welcome"]
export (float) var delay_time_s = 0.1
var lines = 0;
var text_length = [];
var letter_pt = 0
var line_pt = 0;
var current_text = ""

func _ready():
	print(timer)
	timer.connect("timeout", self, "print_text")
	timer.one_shot = false;
	timer.wait_time = delay_time_s;

func talk():
	if sub.visible:
		sub.hide()
		talking = false
	else:
		sub.show()
		make_text_map()
		talking = true
		timer.start()

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
		if line_pt == lines - 1:
			timer.stop()
			return
		line_pt += 1;
		letter_pt = 0;
		current_text = ""
		print_char()
