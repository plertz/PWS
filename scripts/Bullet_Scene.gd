extends Spatial

var crosshair 
var BULLET_SPEED = 70
var BULLET_DAMAGE = 15

const KILL_TIMER = 4
var timer = 0

var hit_something = false

func _collided(body):
	if hit_something == false:
		if body.has_method("bullet_hit"):
			body.bullet_hit(BULLET_DAMAGE)
			crosshair.crosshair_show()

	hit_something = true
	queue_free()

func _ready():
	$Area.connect("body_entered", self, "_collided")
	
	if  get_tree().root.get_children()[1].name == "World":
		crosshair = get_node("../../World/Player/HUD/Hit_crosshair") 
	else:
		crosshair = get_node("../../Main/World/Player/HUD/Hit_crosshair")
	


func _physics_process(delta):
	var forward_dir = global_transform.basis.z.normalized()
	global_translate(forward_dir * BULLET_SPEED * delta)

	timer += delta
	if timer >= KILL_TIMER:
		queue_free()
