extends KinematicBody

export (Resource) var fire_cube;

onready var MOVE_SPEED = fire_cube.MOVE_SPEED;
onready var JUMP_SPEED = fire_cube.JUMP_SPEED;
onready var DAMAGE = fire_cube.DAMAGE
onready var HEALTH = fire_cube.HEALTH

onready var health = HEALTH;
var health_set = false
onready var health_container = $Damage/Sprite3D
onready var health_bar = $Damage/Viewport/ProgressBar

onready var walking_audio = $Walking_sound

onready var detectbox = $Detectbox
var detected = false
onready var hitbox = $Hitbox
onready var hit_sound = $Explosion/Soundeffect
onready var hit_timer = $Explosion/Timer
onready var hit_exp = $Explosion/Particles

onready var spatial_parent = get_parent()
var player
onready var self_body = $Body

const GRAVITY = -24.8
const MAX_SLOPE_ANGLE = 40
var vel = Vector3()
var dir = Vector3(0, 0, 0)

func _ready():
	if get_tree().get_root().has_node("Main/World/Player"):
		player = get_tree().get_root().get_node("Main/World/Player")
	else:
		player = get_tree().get_root().get_node("World/Player")

	setup_atk()
	detectbox.connect("body_entered", self, "_on_detect")
	detectbox.connect("body_exited", self, "_on_lost")
	
func _on_detect(body):
	if body.has_method("player"):
		detected = true

func _on_lost(body):
	if body.has_method("player"):
		detected = false
		# translation = Vector3(0,0,0)

func _physics_process(delta):
	if detected:
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

func get_cor():
	if detected:
		return get_player_cor() - get_own_cor();
	else:
		return Vector3(0,0,0) - get_own_cor();
	
func move(speed, delta):
	dir = get_player_cor() - get_own_cor();
	dir = dir.normalized()
	update_dir(dir)

	vel.x = dir.x * speed;
	vel.z = dir.z * speed;
	vel.y += delta*GRAVITY
	if is_on_floor():
		vel.y += JUMP_SPEED
		if !walking_audio.playing:
			walking_audio.play()

	vel = move_and_slide(vel,Vector3(0,1,0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func setup_atk():
	hitbox.connect("body_entered", self, "_overlapping");
	hit_sound.connect("finished", self, "_on_sound_finished");
	hit_timer.connect("timeout", self, "_on_timeout")
		
func update_dir(direction):
	direction = Vector2(direction.x, direction.z)
	var rot = direction.angle()
	rotation.y = -rot + 3.14

func bullet_hit(damage):
	health -= damage
	update_health_bar()
	if health < 1:
		explosion()

func death(cause):
	spatial_parent.queue_free()

func update_health_bar():
	if !health_container.visible:
		set_health_bar()
	health_bar.value = health

func set_health_bar():
	health_bar.max_value = HEALTH
	health_container.show()


func check_overlapping():
	var bodies = hitbox.get_overlapping_bodies()
	for body in bodies:
		hit(body)
		return

func _overlapping(body):
	if body.has_method("hit") and body.has_method("player"):
		hit_timer.start()

func hit(body):
	if body.has_method("hit") and body.has_method("player"):
		body.hit(DAMAGE, "E2")

func _on_sound_finished():
	death("")

func _on_timeout():
	explosion()
	check_overlapping()

func explosion():
	health_container.hide()
	hit_sound.play()
	self_body.hide()
	hit_exp.emitting = true
