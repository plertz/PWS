extends KinematicBody

# export (Resource) var golem

onready var MOVE_SPEED = 10
onready var ATTACK_SPEED = 1
onready var DAMAGE = 5
onready var HEALTH = 90

onready var health = HEALTH;
var health_set = false
onready var health_container = $Damage/Sprite3D
onready var health_bar = $Damage/Viewport/ProgressBar

onready var walking_audio = $Rotation_Helper/Walking_sound

onready var detectbox = $Rotation_Helper/Detectbox
var detected = false
var wandering = false
onready var hitbox = $Rotation_Helper/Hitbox/Area
onready var atk_timer = $Rotation_Helper/Hitbox/Hit_timer

onready var death_anim = $Rotation_Helper/Death/Particles
onready var death_timer = $Rotation_Helper/Death/Timer
var dead = false

onready var rotate_helper = $Rotation_Helper
onready var spatial_parent = get_parent()
onready var spawn_area = get_node("../Spawn_area")

var player
onready var animation_player = $AnimationPlayer
onready var golem_body = $Rotation_Helper/Armature

const GRAVITY = -24.8
const MAX_SLOPE_ANGLE = 40
var vel = Vector3()
var dir = Vector3(0, 0, 0)
var rot_xform;

func _ready():
	if get_tree().get_root().has_node("Main/World/Player"):
		player = get_tree().get_root().get_node("Main/World/Player")
	else:
		player = get_tree().get_root().get_node("World/Player")

	setup_hitbox()
	setup_spawn()
	detectbox.connect("body_entered", self, "_on_detect")
	detectbox.connect("body_exited", self, "_on_lost")
	animation_player.play("idle")

	death_timer.connect("timeout", self, "_on_death_timeout")

	
func _on_detect(body):
	if body.has_method("player"):
		detected = true
		wandering = true
		walking_audio.play()
		animation_player.play("Walk")

func _on_lost(body):
	if body.has_method("player"):
		detected = false
		check_spawn()

func _physics_process(delta):
	if detected or wandering:
		move(MOVE_SPEED, delta)

func get_player_cor():
	var player_cor = player.translation
	player_cor.y = 0
	return player_cor

func get_spawn_area_cor():
	var spawn_cor = spatial_parent.translation
	spawn_cor.y = 0
	return spawn_cor

func get_own_cor():
	var par_cor = spatial_parent.translation;
	var own_cor = par_cor + translation;
	own_cor.y = 0
	return own_cor

func get_cor():
	if detected:
		return get_player_cor() - get_own_cor();
	else:
		return get_spawn_area_cor() - get_own_cor();
	
func move(speed, delta):
	dir = get_cor()
	dir = dir.normalized()
	update_dir(dir)

	vel.x = dir.x * speed;
	vel.z = dir.z * speed;
	vel.y += delta*GRAVITY
	vel = move_and_slide(vel,Vector3(0,1,0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
		
func update_dir(direction):
	direction = Vector2(direction.x, direction.z)
	var rotation = direction.angle()
	rotate_helper.rotation.z = -rotation

func bullet_hit(damage):
	health -= damage
	update_health_bar()
	if health < 1:
		death("")

func death(cause):
	dead = true
	health_container.hide()
	golem_body.hide()
	death_anim.emitting = true;
	death_timer.start()

func _on_death_timeout():
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

func setup_spawn():
	spawn_area.connect("body_entered", self, "_on_spawn_enter")

func check_spawn():
	var bodies = spawn_area.get_overlapping_bodies()
	for body in bodies:
		if body == self:
			wandering = false;
			walking_audio.stop()
			animation_player.play("idle")

func _on_spawn_enter(body):
	if body == self:
		wandering = false
		walking_audio.stop()
		animation_player.play("idle")

func check_overlapping():
	var bodies = hitbox.get_overlapping_bodies()
	for body in bodies:
		hit(body)
		return

func _overlapping(body):
	hit(body)

func hit(body):
	if body.has_method("hit") and body.has_method("player"):
		if dead:
			return
		atk_timer.start()
		body.hit(DAMAGE, "E1")

# Identifier
func golem():
	return
