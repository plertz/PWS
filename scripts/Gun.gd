extends Spatial

onready var crosshair = get_node("../../../HUD/Hit_crosshair")
export (Resource) var gun;
export (Resource) var wp_range;

var SPARE_AMMO = 0;

var is_weapon_enabled = false
var player_node = null

onready var weapon_display_src = "../../../HUD/Weapons/" + gun.NAME + "/VBoxContainer/Ammo"
onready var weapon_display_ammo = get_node(weapon_display_src)

onready var raycast = $Ray_Cast

func _ready():
	update_weapon_display()
	setup_range()
	SPARE_AMMO = gun.spare_ammo

func setup_range():
	raycast.cast_to.z = wp_range.wp_range;

# func setup_weapon_display():
# 	weapon_display_ammo.text = str(gun.ammo_in_weapon) + "/" + str(gun.spare_ammo)

func update_weapon_display():
	weapon_display_ammo.text = str(gun.ammo_in_weapon) + "/" + str(gun.spare_ammo)

func fire_weapon():
	var ray = $Ray_Cast
	ray.force_raycast_update()

	if ray.is_colliding():
		var body = ray.get_collider()

		if body == player_node:
			pass
		elif body.has_method("bullet_hit"):
			body.bullet_hit(gun.DAMAGE)
			crosshair.crosshair_show()
	
	gun.ammo_in_weapon -= 1
	update_weapon_display()

func equip_weapon():
	if player_node.animation_manager.current_state == gun.IDLE_ANIM_NAME:
		is_weapon_enabled = true
		return true

	if player_node.animation_manager.current_state == "Idle_unarmed":
		player_node.animation_manager.set_animation(gun.GUN_EQUIP)

	return false

func unequip_weapon():

	if player_node.animation_manager.current_state == gun.IDLE_ANIM_NAME:
		if player_node.animation_manager.current_state != gun.GUN_UNEQUIP:
			player_node.animation_manager.set_animation(gun.GUN_UNEQUIP)

	if player_node.animation_manager.current_state == "Idle_unarmed":
		is_weapon_enabled = false
		return true

	return false


func reload_weapon():
	var can_reload = false

	if player_node.animation_manager.current_state == gun.IDLE_ANIM_NAME:
		can_reload = true

	if gun.spare_ammo <= 0 or gun.ammo_in_weapon == gun.AMMO_IN_MAG:
		can_reload = false

	if can_reload == true:
		var ammo_needed = gun.AMMO_IN_MAG - gun.ammo_in_weapon

		if gun.spare_ammo >= ammo_needed:
			gun.spare_ammo -= ammo_needed
			gun.ammo_in_weapon = gun.AMMO_IN_MAG
		else:
			gun.ammo_in_weapon += gun.spare_ammo
			gun.spare_ammo = 0

		update_weapon_display()
		player_node.animation_manager.set_animation(gun.RELOADING_ANIM_NAME)

		return true

	return false

func refill_ammo():
	gun.ammo_in_weapon = gun.AMMO_IN_MAG
	gun.spare_ammo = SPARE_AMMO
	update_weapon_display()
