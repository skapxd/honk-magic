class_name SpellResource
extends Resource

# =============================================================================
# HONK MAGIC - Spell Resource
# =============================================================================
# Define las propiedades de un hechizo.

@export_group("General")
@export var spell_name: String = "New Spell"
@export var element: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var color: Color = Color.WHITE

@export_group("Costos")
@export var mp_cost: int = 10
@export var cooldown: float = 0.5

@export_group("Stats")
@export var damage: float = 0.0
@export var healing: float = 0.0
@export var knockback_force: float = 0.0

enum CastType { PROJECTILE, INSTANT, GROUND, VECTOR }
@export var cast_type: CastType = CastType.PROJECTILE

@export_group("Projectile Settings")
@export var projectile_speed: float = 400.0
@export var projectile_scene: PackedScene

@export_group("Spawn Settings")
@export var spawn_scene: PackedScene
@export var spawn_duration: float = 5.0

@export_group("Effects")
@export var status_effect: StatusEffect


func get_description() -> String:
	return description if description != "" else "Un hechizo de %s." % element
