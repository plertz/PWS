extends Area

var player;

func _ready():
	player = get_node("../../Player")
	connect("body_entered", self, "handle")

func handle(body):
	if body.has_method("death"):
		body.death("fall")

