extends KinematicBody

export (float) var MOVE_SPEED = 5;
export (float) var ATTACK_SPEED = 1;
export (int) var DAMAGE = 3
export (int) var HEALTH = 90

var health = HEALTH;
var health_set = false
onready var health_container = $Damage/Sprite3D
onready var health_bar = $Damage/Viewport/ProgressBar

onready var hitbox = $Hitbox/Area
onready var atk_timer = $Hitbox/Hit_timer

onready var rotate_helper = $Rotation_Helper
onready var raycast = $Rotation_Helper/raycast
onready var spatial_parent = get_parent()
var player


var DEG_RAY = 22.5
var RAY_LEN = 100
var rays = []

const GRAVITY = -24.8
const MAX_SLOPE_ANGLE = 40
var vel =Vector3()
var dir = Vector3(0, 0, 0)
var rot_xform;

var wandering = true

func _ready():
	# setup_raycat()
	# print(rotate_helper)
	if get_tree().get_root().has_node("Main/World/Player"):
		player = get_tree().get_root().get_node("Main/World/Player")
	else:
		player = get_tree().get_root().get_node("World/Player")

	setup_hitbox()
	
	
func _physics_process(delta):
# 	update_raycast()
# 	rot_xform = rotate_helper.rotation

	move(MOVE_SPEED, delta)

func get_player_cor():
	var player_cor = player.translation
	player_cor.y = 0
	return player_cor

func get_own_cor():
	var par_cor = spatial_parent.translation;
	var own_cor = par_cor + translation;
	own_cor.y = 0
	return own_cor
	
func move(speed, delta):
	dir = get_player_cor() - get_own_cor();
	dir = dir.normalized()
	update_dir(dir)

	vel.x = dir.x * speed;
	vel.z = dir.z * speed;
	vel.y += delta*GRAVITY
	vel = move_and_slide(vel,Vector3(0,1,0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

# func setup_raycat():
# 	for child in raycast.get_children() :
# 		rays.append(child)
# 		child.cast_to = Vector3(RAY_LEN, 0, 0)


# func update_raycast():
# 	for ray in rays:
# 		ray.force_raycast_update()
# 		if(ray.is_colliding()):
# 			update_dir(ray.rotation.z)
# 			print("ray hit")
		
func update_dir(direction):
	direction = Vector2(direction.x, direction.z)
	# var rotation = direction.angle() / (2 *3.14) * 360
	var rotation = direction.angle()
	rotate_helper.rotation.z = -rotation

func bullet_hit(damage):
	health -= damage
	update_health_bar()
	if health < 1:
		death("")

func death(cause):
	spatial_parent.queue_free()

func update_health_bar():
	if !health_container.visible:
		set_health_bar()
	health_bar.value = health

func set_health_bar():
	health_bar.max_value = HEALTH
	health_container.show()

func setup_hitbox():
	hitbox.connect("body_entered", self, "_overlapping");
	atk_timer.wait_time = ATTACK_SPEED;
	atk_timer.one_shot = true;
	atk_timer.connect("timeout", self, "check_overlapping")

func check_overlapping():
	var bodies = hitbox.get_overlapping_bodies()
	for body in bodies:
		hit(body)
		return

func _overlapping(body):
	hit(body)

func hit(body):
	if body.has_method("hit") and body.has_method("player"):
		atk_timer.start()
		body.hit(DAMAGE, "E1")
