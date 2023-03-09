extends KinematicBody

signal menu_open;
signal menu_close;

onready var weapon_audio = $Rotation_Helper/Player_sound_system
onready var walking_audio = $Rotation_Helper/Walking_sound
onready var scream_audio = $Rotation_Helper/Scream_sound

onready var NPC = { 
	"ray": $Rotation_Helper/NPC_point/Ray_Cast,
	"NPC_menu": $HUD/NPC_menu,
	"body": null,
	"talking": false
}

const MAX_HEALTH = 100
var health = MAX_HEALTH
onready var health_bar = $HUD/Health_bar

onready var death_screen = $HUD/Death_screen
onready var death_label = $HUD/Death_screen/VBoxContainer/Label
onready var death_container = $HUD/Death_screen/VBoxContainer
onready var death_button = $HUD/Death_screen/VBoxContainer/Button
var death_text = {
	"lava": "Someone tried to swim in lava!!! STUPID",
	"fall": "Try to prove the world isn't flat now!!",
	"E1" : "Someone got smashed to death!!! STUPID",
	"E2": "HaHaHa!!! Blown up by a cube",
	"G" : "Someone blew up...... a bit STUPID"
}

var freeze = false;

const GRAVITY = -24.8
var vel = Vector3()
const MAX_SPEED = 20
const JUMP_SPEED = 18
const ACCEL= 4.5

const MAX_SPRINT_SPEED = 30
const SPRINT_ACCEL = 18
var is_sprinting = false

var dir = Vector3()

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper

var MOUSE_SENSITIVITY = 0.05
var mouse_scroll_value = 0
const MOUSE_SENSITIVITY_SCROLL_WHEEL = 0.08

var JOYPAD_SENSITIVITY = 2
const JOYPAD_DEADZONE = 0.15

var animation_manager

var current_weapon_name = "UNARMED"
var weapons = {"UNARMED":null, "KNIFE":null, "PISTOL":null, "RIFLE":null}
const WEAPON_NUMBER_TO_NAME = {0:"UNARMED", 1:"KNIFE", 2:"PISTOL", 3:"RIFLE"}
const WEAPON_NAME_TO_NUMBER = {"UNARMED":0, "KNIFE":1, "PISTOL":2, "RIFLE":3}
var changing_weapon = false
var changing_weapon_name = "UNARMED"
var reloading_weapon = false
onready var weapon_display = {
	"UNARMED" : $HUD/Weapons/Unarmed,
	"KNIFE" : $HUD/Weapons/Knife,
	"PISTOL" : $HUD/Weapons/Pistol,
	"RIFLE" : $HUD/Weapons/Rifle
}

onready var grenade_display = get_node("HUD/Weapons/Grenade/num")

var grenade_amounts = {"Grenade":3, "Sticky Grenade":2}
var current_grenade = "Grenade"
var grenade_scene = preload("res://scenes/Grenade.tscn")
# var sticky_grenade_scene = preload("res://scenes/Sticky_Grenade.tscn")
const GRENADE_THROW_FORCE = 50

func _ready():
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper

	animation_manager = $Rotation_Helper/Model/Animation_Player
	animation_manager.callback_function = funcref(self, "fire_bullet")

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	weapons["KNIFE"] = $Rotation_Helper/Gun_Fire_Points/Knife_Point
	weapons["PISTOL"] = $Rotation_Helper/Gun_Fire_Points/Pistol_Point
	weapons["RIFLE"] = $Rotation_Helper/Gun_Fire_Points/Rifle_Point

	var gun_aim_point_pos = $Rotation_Helper/Gun_Aim_Point.global_transform.origin

	for weapon in weapons:
		var weapon_node = weapons[weapon]
		if weapon_node != null:
			weapon_node.player_node = self
			weapon_node.look_at(gun_aim_point_pos, Vector3(0, 1, 0))
			weapon_node.rotate_object_local(Vector3(0, 1, 0), deg2rad(180))

	current_weapon_name = "UNARMED"
	changing_weapon_name = "UNARMED"

	death_button.connect("pressed", self, "respawn")

	setup_health_bar()
	setup_weapon_display()
	update_grenade_display()

	# unique_name_in_owner = true;
	# set_owner(get_tree().get_root())


func _physics_process(_delta):
	if !freeze:
		process_input(_delta)
		process_movement(_delta)
		process_view_input(_delta)
		process_NPC(_delta)
		
		process_changing_weapons(_delta)
		process_reloading(_delta)
	
	process_intterupts(_delta)


func process_input(_delta):

	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("move_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("move_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("move_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_movement_vector.x = 1

	dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
	dir += cam_xform.basis.x.normalized() * input_movement_vector.x

	if is_on_floor():
		if Input.is_action_just_pressed("move_jump"):
			vel.y = JUMP_SPEED

	if Input.is_action_pressed("move_sprint"):
		is_sprinting = true
	else:
		is_sprinting = false

	var weapon_change_number = WEAPON_NAME_TO_NUMBER[current_weapon_name]
	
	if Input.is_key_pressed(KEY_1):
		weapon_change_number = 0
	if Input.is_key_pressed(KEY_2):
		weapon_change_number = 1
	if Input.is_key_pressed(KEY_3):
		weapon_change_number = 2
	if Input.is_key_pressed(KEY_4):
		weapon_change_number = 3
	
	if Input.is_action_just_pressed("shift_weapon_positive"):
		weapon_change_number += 1
	if Input.is_action_just_pressed("shift_weapon_negative"):
		weapon_change_number -= 1
	
	weapon_change_number = clamp(weapon_change_number, 0, WEAPON_NUMBER_TO_NAME.size()-1)
	
	if changing_weapon == false:
		if reloading_weapon == false:
			if WEAPON_NUMBER_TO_NAME[weapon_change_number] != current_weapon_name:
				switch_weapon_display(current_weapon_name, WEAPON_NUMBER_TO_NAME[weapon_change_number] )
				changing_weapon_name = WEAPON_NUMBER_TO_NAME[weapon_change_number]
				changing_weapon = true
				mouse_scroll_value = weapon_change_number

	if reloading_weapon == false:
		if changing_weapon == false:
			if Input.is_action_just_pressed("reload"):
				var current_weapon = weapons[current_weapon_name]
				if current_weapon != null:
					if current_weapon.gun.CAN_RELOAD == true:
						var current_anim_state = animation_manager.current_state
						var is_reloading = false
						for weapon in weapons:
							var weapon_node = weapons[weapon]
							if weapon_node != null:
								if current_anim_state == weapon_node.gun.RELOADING_ANIM_NAME:
									is_reloading = true
						if is_reloading == false:
							reloading_weapon = true

	if Input.is_action_pressed("fire"):
		if reloading_weapon == false:
			if changing_weapon == false:
				var current_weapon = weapons[current_weapon_name]
				if current_weapon != null:
					if current_weapon.gun.ammo_in_weapon > 0:
						if animation_manager.current_state == current_weapon.gun.IDLE_ANIM_NAME:
							animation_manager.set_animation(current_weapon.gun.FIRE_ANIM_NAME)
							fire_bullet();
							if current_weapon_name == "KNIFE":
								weapon_audio.play_audio("knife")
							elif current_weapon_name == "RIFLE":
								weapon_audio.play_audio("rifle_shot")
							else:
								weapon_audio.play_audio("pistol_shot")
					else:
						reloading_weapon = true
	
	# if Input.is_action_just_pressed("change_grenade"):
	# 	if current_grenade == "Grenade":
	# 		current_grenade = "Sticky Grenade"
	# 	elif current_grenade == "Sticky Grenade":
	# 		current_grenade = "Grenade"
	
	if Input.is_action_just_pressed("fire_grenade"):
		if grenade_amounts[current_grenade] > 0:
			grenade_amounts[current_grenade] -= 1
			update_grenade_display()
	
			var grenade_clone = grenade_scene.instance()
			# if (current_grenade == "Grenade"):
			# 	grenade_clone = grenade_scene.instance()
			# elif (current_grenade == "Sticky Grenade"):
			# 	grenade_clone = sticky_grenade_scene.instance()
			# 	# Sticky grenades will stick to the player if we do not pass ourselves
			# 	grenade_clone.player_body = self
	
			get_tree().root.add_child(grenade_clone)
			grenade_clone.global_transform = $Rotation_Helper/Grenade_Toss_Pos.global_transform
			grenade_clone.apply_impulse(Vector3(0,0,0), grenade_clone.global_transform.basis.z * GRENADE_THROW_FORCE)


func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta*GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	if is_sprinting:
		target *= MAX_SPRINT_SPEED
	else:
		target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		if is_sprinting:
			accel = SPRINT_ACCEL
		else:
			accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel*delta)
	vel.x = hvel.x
	vel.z = hvel.z
	play_walking_sound(dir)
	vel = move_and_slide(vel,Vector3(0,1,0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func process_view_input(_delta):

	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return

	var joypad_vec = Vector2()
	if Input.get_connected_joypads().size() > 0:

		if OS.get_name() == "Windows":
			joypad_vec = Vector2(Input.get_joy_axis(0, 2), Input.get_joy_axis(0, 3))
		elif OS.get_name() == "X11":
			joypad_vec = Vector2(Input.get_joy_axis(0, 2), Input.get_joy_axis(0, 3))
		elif OS.get_name() == "OSX":
			joypad_vec = Vector2(Input.get_joy_axis(0, 3), Input.get_joy_axis(0, 4))

		if joypad_vec.length() < JOYPAD_DEADZONE:
			joypad_vec = Vector2(0, 0)
		else:
			joypad_vec = joypad_vec.normalized() * ((joypad_vec.length() - JOYPAD_DEADZONE) / (1 - JOYPAD_DEADZONE))

		rotation_helper.rotate_x(deg2rad(joypad_vec.y * JOYPAD_SENSITIVITY))

		rotate_y(deg2rad(joypad_vec.x * JOYPAD_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot

func process_changing_weapons(_delta):
	if changing_weapon == true:

		var weapon_unequipped = false
		var current_weapon = weapons[current_weapon_name]

		if current_weapon == null:
			weapon_unequipped = true
		else:
			if current_weapon.is_weapon_enabled == true:
				weapon_unequipped = current_weapon.unequip_weapon()
			else:
				weapon_unequipped = true

		if weapon_unequipped == true:

			var weapon_equiped = false
			var weapon_to_equip = weapons[changing_weapon_name]

			if weapon_to_equip == null:
				weapon_equiped = true
			else:
				if weapon_to_equip.is_weapon_enabled == false:
					weapon_equiped = weapon_to_equip.equip_weapon()
				else:
					weapon_equiped = true

			if weapon_equiped == true:
				changing_weapon = false
				current_weapon_name = changing_weapon_name
				changing_weapon_name = ""

func process_reloading(_delta):
	if reloading_weapon == true:
		var current_weapon = weapons[current_weapon_name]
		if current_weapon != null:
			current_weapon.reload_weapon()
		reloading_weapon = false

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and !freeze:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
	
	if event is InputEventMouseButton and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN:
			if event.button_index == BUTTON_WHEEL_UP:
				mouse_scroll_value += MOUSE_SENSITIVITY_SCROLL_WHEEL
			elif event.button_index == BUTTON_WHEEL_DOWN:
				mouse_scroll_value -= MOUSE_SENSITIVITY_SCROLL_WHEEL
	
			mouse_scroll_value = clamp(mouse_scroll_value, 0, WEAPON_NUMBER_TO_NAME.size()-1)
	
			if changing_weapon == false:
				if reloading_weapon == false:
					var round_mouse_scroll_value = int(round(mouse_scroll_value))
					if WEAPON_NUMBER_TO_NAME[round_mouse_scroll_value] != current_weapon_name:
						switch_weapon_display(current_weapon_name, WEAPON_NUMBER_TO_NAME[round_mouse_scroll_value] )
						changing_weapon_name = WEAPON_NUMBER_TO_NAME[round_mouse_scroll_value]
						changing_weapon = true
						mouse_scroll_value = round_mouse_scroll_value

func process_intterupts(_delta):	
	if Input.is_action_just_pressed("ui_cancel"):

		if NPC.body != null and NPC.body.has_method("talk") and freeze and NPC.talking:
			NPC.NPC_menu.show()
			NPC.talking = false;
			# NPC.body.talk()
			NPC.body.leave()
			freeze = false

		elif Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			emit_signal("menu_close")
			freeze = false;
			
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			emit_signal("menu_open")
			freeze = true;
	
	if Input.is_action_just_pressed("interact"):
		if NPC.body != null and NPC.body.has_method("talk") and NPC.NPC_menu.visible:
			NPC.NPC_menu.hide()
			NPC.talking = true;
			NPC.body.talk()
			freeze = true;
		elif NPC.body != null and NPC.body.has_method("talk") and freeze and NPC.talking:
			if !NPC.body.next():
				NPC.NPC_menu.show()
				NPC.talking = false;
				NPC.body.leave()
				freeze = false
			

func process_NPC(_delta):

	NPC.ray.force_raycast_update()

	if NPC.ray.is_colliding():
		var body = NPC.ray.get_collider()

		if body == null:
			pass
		elif body.has_method("talk") and NPC.talking == false:
			NPC.body = body;
			NPC.NPC_menu.show()
		else:
			NPC.NPC_menu.hide();	
	else:
		NPC.NPC_menu.hide();

func setup_weapon_display():
	weapon_display["KNIFE"].hide()
	weapon_display["PISTOL"].hide()
	weapon_display["RIFLE"].hide()
	weapon_display["UNARMED"].show()
	

func switch_weapon_display(dis_prev, dis_new):
	weapon_display[dis_prev].hide()
	weapon_display[dis_new].show()

func update_grenade_display():
	grenade_display.text = str(grenade_amounts["Grenade"])

func refill_grenade():
	grenade_amounts["Grenade"] = 3
	update_grenade_display()

func play_walking_sound(direction):
	if direction.x == 0 and direction.y == 0:
		walking_audio.stop()
	else:
		if !walking_audio.playing and is_on_floor():
			walking_audio.play()

func refill_health():
	health = MAX_HEALTH
	update_health_bar()

func setup_health_bar():
	health_bar.max_value = MAX_HEALTH

func update_health_bar():
	health_bar.value = health

func refill_ammo():
	weapons["PISTOL"].refill_ammo()
	weapons["RIFLE"].refill_ammo()
	refill_grenade()


func death(cause):
	death_label.text = death_text[cause]
	death_screen.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func respawn():
	translation = get_node("../Player_spawn").translation;
	refill_health()
	refill_ammo()
	death_screen.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func fire_bullet():
	if changing_weapon == true:
		return

	weapons[current_weapon_name].fire_weapon()

# func add_health(additional_health):
# 	health += additional_health
# 	health = clamp(health, 0, MAX_HEALTH)

# func add_ammo(additional_ammo):
# 	if (current_weapon_name != "UNARMED"):
# 		if (weapons[current_weapon_name].gun.CAN_REFILL == true):
# 			weapons[current_weapon_name].gun.spare_ammo += weapons[current_weapon_name].gun.AMMO_IN_MAG * additional_ammo

# func add_grenade(additional_grenade):
# 	grenade_amounts[current_grenade] += additional_grenade
# 	grenade_amounts[current_grenade] = clamp(grenade_amounts[current_grenade], 0, 4)

# player identifier
func player():
	return

func G_hit(damage, msg):
	hit(damage, msg)


func hit(damage, msg):
	health -= damage
	scream_audio.play_scream()
	update_health_bar()
	if health < 1:
		death(msg)

