extends AudioStreamPlayer

func _ready():
	play()
	connect("finished", self, "_delete")

func _delete():
	queue_free()
