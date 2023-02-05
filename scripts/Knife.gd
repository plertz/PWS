extends Spatial

onready var crosshair = get_node("../../../HUD/Hit_crosshair")

export (Resource) var gun;

# const gun.DAMAGE = 40

# var ammo_in_weapon = 1
# var spare_ammo = 1
# const AMMO_IN_MAG = 1

# const CAN_RELOAD = false
# const CAN_REFILL = false

# const gun.IDLE_ANIM_NAME = "Knife_idle"
# const FIRE_ANIM_NAME = "Knife_fire"
# const RELOADING_ANIM_NAME = ""

var is_weapon_enabled = false

var player_node = null

func _ready():
	pass

func fire_weapon():
	var area = $Area
	var bodies = area.get_overlapping_bodies()

	for body in bodies:
		if body == player_node:
			continue

		if body.has_method("bullet_hit"):
			crosshair.crosshair_show()
			body.bullet_hit(gun.DAMAGE)

func equip_weapon():
	if player_node.animation_manager.current_state == gun.IDLE_ANIM_NAME:
		is_weapon_enabled = true
		return true

	if player_node.animation_manager.current_state == "Idle_unarmed":
		player_node.animation_manager.set_animation("Knife_equip")

	return false

func unequip_weapon():

	if player_node.animation_manager.current_state == gun.IDLE_ANIM_NAME:
		player_node.animation_manager.set_animation("Knife_unequip")

	if player_node.animation_manager.current_state == "Idle_unarmed":
		is_weapon_enabled = false
		return true

	return false

func reload_weapon():
	return false
