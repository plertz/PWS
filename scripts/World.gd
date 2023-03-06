extends Spatial

onready var soundtrack


func _ready():
	if get_tree().get_root().has_node("/root/Main/Audio"):
		soundtrack = get_tree().get_root().get_node("/root/Main/Audio")
		soundtrack.play_random()

