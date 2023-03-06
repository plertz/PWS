extends RigidBody

export (int) var DAMAGE = 60

const GRENADE_TIME = 2
var grenade_timer = 0

const EXPLOSION_WAIT_TIME = 0.48
var explosion_wait_timer = 0

var rigid_shape
var grenade_mesh
var blast_area
var explosion_particles
var soundeffect

func _ready():
	rigid_shape = $Collision_Shape
	grenade_mesh = $Grenade
	blast_area = $Blast_Area
	explosion_particles = $Explosion
	soundeffect = $Soundeffect

	explosion_particles.emitting = false
	explosion_particles.one_shot = true
	

func _process(delta):

	if grenade_timer < GRENADE_TIME:
		grenade_timer += delta
		return
	else:
		if explosion_wait_timer <= 0:
			explosion_particles.emitting = true
			soundeffect.play()

			grenade_mesh.visible = false
			rigid_shape.disabled = true

			mode = RigidBody.MODE_STATIC

			var bodies = blast_area.get_overlapping_bodies()
			for body in bodies:
				if body.has_method("bullet_hit"):
					body.bullet_hit(DAMAGE)
				elif body.has_method("G_hit"):
					body.G_hit(DAMAGE, "G")


		if explosion_wait_timer < EXPLOSION_WAIT_TIME:
			explosion_wait_timer += delta

			if explosion_wait_timer >= EXPLOSION_WAIT_TIME:
				queue_free()
