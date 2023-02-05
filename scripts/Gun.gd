extends Spatial

onready var crosshair = get_node("../../../HUD/Hit_crosshair")

# const gun.DAMAGE = 4

export (Resource) var gun;

# var ammo_in_weapon = 50
# var spare_ammo = 100
# const AMMO_IN_MAG = 50

# const CAN_RELOAD = true
# const CAN_REFILL = true

# const IDLE_ANIM_NAME = "Rifle_idle"
# const FIRE_ANIM_NAME = "Rifle_fire"
# const RELOADING_ANIM_NAME = "Rifle_reload"
# const GUN_EQUIP = "Rifle_equip"
# const GUN_UNEQUIP = "Rifle_unequip"

var is_weapon_enabled = false

var player_node = null

func _ready():
	pass

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

		player_node.animation_manager.set_animation(gun.RELOADING_ANIM_NAME)

		return true

	return false
