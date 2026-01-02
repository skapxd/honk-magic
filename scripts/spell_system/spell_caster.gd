class_name SpellCaster
extends Node2D

# =============================================================================
# HONK MAGIC - Spell Caster
# =============================================================================
# Maneja el lanzamiento de hechizos basado en runas reconocidas.

signal spell_cast(spell: SpellResource)
signal spell_failed(reason: String)
signal spell_charged(spell: SpellResource)
signal mp_consumed(amount: int)
signal vector_cast_started(spell: SpellResource)

@export var caster: Node2D

# Hechizos por elemento (cargados dinamicamente)
var spells: Dictionary = {}

# Hechizo actualmente cargado (listo para lanzar)
var charged_spell: SpellResource = null

# Vector casting state
var is_vector_casting: bool = false
var vector_start_pos: Vector2 = Vector2.ZERO

# Cooldowns activos
var cooldowns: Dictionary = {}

# MP regeneration
@export var mp_regen_rate: float = 10.0  # MP por segundo
@export var mp_regen_delay: float = 1.0  # Segundos sin castear para regenerar
var time_since_last_cast: float = 0.0
var _mp_regen_accumulator: float = 0.0  # Acumulador para regeneracion fraccionaria


func _ready() -> void:
	_load_default_spells()


func _process(delta: float) -> void:
	# Actualizar cooldowns
	for spell_name in cooldowns.keys():
		cooldowns[spell_name] -= delta
		if cooldowns[spell_name] <= 0:
			cooldowns.erase(spell_name)

	# Regenerar MP del caster
	time_since_last_cast += delta
	if time_since_last_cast >= mp_regen_delay and caster and "mp" in caster:
		# Usar acumulador para manejar regeneracion fraccionaria
		_mp_regen_accumulator += mp_regen_rate * delta
		if _mp_regen_accumulator >= 1.0:
			var regen_amount := int(_mp_regen_accumulator)
			_mp_regen_accumulator -= regen_amount
			caster.mp = mini(caster.mp + regen_amount, caster.max_mp if "max_mp" in caster else 100)


func _load_default_spells() -> void:
	# Cargar hechizos desde recursos
	var spell_paths := {
		"fuego": "res://resources/spells/spell_fuego.tres",
		"agua": "res://resources/spells/spell_agua.tres",
		"viento": "res://resources/spells/spell_viento.tres",
		"tierra": "res://resources/spells/spell_tierra.tres",
		"luz": "res://resources/spells/spell_luz.tres",
		"oscuridad": "res://resources/spells/spell_oscuridad.tres"
	}

	for element in spell_paths:
		var path: String = spell_paths[element]
		if ResourceLoader.exists(path):
			var spell = load(path) as SpellResource
			if spell:
				spells[element] = spell
				print("[SpellCaster] Cargado: %s" % element)
			else:
				push_warning("[SpellCaster] Error cargando: %s" % path)
		else:
			push_warning("[SpellCaster] No existe: %s" % path)


func charge_spell_from_rune(rune_name: String) -> bool:
	"""Carga un hechizo basado en la runa reconocida."""
	print("[SpellCaster] Intentando cargar: %s" % rune_name)

	var spell := get_spell_for_element(rune_name)
	if not spell:
		var reason := "No hay hechizo para: " + rune_name
		print("[SpellCaster] FALLO: %s" % reason)
		spell_failed.emit(reason)
		return false

	# Verificar cooldown
	if cooldowns.has(spell.spell_name):
		var reason := "Hechizo en cooldown"
		print("[SpellCaster] FALLO: %s" % reason)
		spell_failed.emit(reason)
		return false

	# Verificar MP
	if caster and "mp" in caster:
		print("[SpellCaster] MP actual: %d, costo: %d" % [caster.mp, spell.mp_cost])
		if caster.mp < spell.mp_cost:
			var reason := "MP insuficiente (%d/%d)" % [caster.mp, spell.mp_cost]
			print("[SpellCaster] FALLO: %s" % reason)
			spell_failed.emit(reason)
			return false

	charged_spell = spell
	print("[SpellCaster] EXITO: %s cargado" % spell.spell_name)
	spell_charged.emit(spell)
	return true


func cast_at_position(target_pos: Vector2) -> bool:
	"""Lanza el hechizo cargado hacia una posicion."""
	if not charged_spell:
		spell_failed.emit("No hay hechizo cargado")
		return false

	if not caster:
		spell_failed.emit("No hay caster asignado")
		return false

	# Para VECTOR, iniciar el cast (click down)
	if charged_spell.cast_type == SpellResource.CastType.VECTOR:
		if not is_vector_casting:
			# Iniciar vector cast
			is_vector_casting = true
			vector_start_pos = target_pos
			vector_cast_started.emit(charged_spell)
			return false  # No completado aun
		# Si ya estamos en vector mode, esto no deberia llegar aqui
		return false

	# Consumir MP
	if "mp" in caster:
		caster.mp -= charged_spell.mp_cost
		mp_consumed.emit(charged_spell.mp_cost)

	# Reiniciar regeneracion
	time_since_last_cast = 0.0
	_mp_regen_accumulator = 0.0

	# Ejecutar hechizo segun tipo
	match charged_spell.cast_type:
		SpellResource.CastType.PROJECTILE:
			_cast_projectile(target_pos)
		SpellResource.CastType.INSTANT:
			_cast_instant()
		SpellResource.CastType.GROUND:
			_cast_ground(target_pos)

	# Iniciar cooldown
	if charged_spell.cooldown > 0:
		cooldowns[charged_spell.spell_name] = charged_spell.cooldown

	spell_cast.emit(charged_spell)

	# Limpiar hechizo cargado
	charged_spell = null

	return true


func finish_vector_cast(end_pos: Vector2) -> bool:
	"""Finaliza un cast de tipo VECTOR con la posicion final."""
	if not is_vector_casting or not charged_spell:
		return false

	if not caster:
		spell_failed.emit("No hay caster asignado")
		_cancel_vector_cast()
		return false

	# Consumir MP
	if "mp" in caster:
		caster.mp -= charged_spell.mp_cost
		mp_consumed.emit(charged_spell.mp_cost)

	# Reiniciar regeneracion
	time_since_last_cast = 0.0
	_mp_regen_accumulator = 0.0

	# Ejecutar vector cast
	_cast_vector(vector_start_pos, end_pos)

	# Iniciar cooldown
	if charged_spell.cooldown > 0:
		cooldowns[charged_spell.spell_name] = charged_spell.cooldown

	spell_cast.emit(charged_spell)

	# Limpiar estado
	is_vector_casting = false
	vector_start_pos = Vector2.ZERO
	charged_spell = null

	return true


func _cancel_vector_cast() -> void:
	is_vector_casting = false
	vector_start_pos = Vector2.ZERO


func cancel_charge() -> void:
	"""Cancela el hechizo cargado."""
	_cancel_vector_cast()
	charged_spell = null


func get_spell_for_element(element: String) -> SpellResource:
	"""Obtiene el hechizo asociado a un elemento."""
	return spells.get(element, null)


func is_spell_ready(element: String) -> bool:
	"""Verifica si un hechizo esta listo para usar."""
	var spell := get_spell_for_element(element)
	if not spell:
		return false
	if cooldowns.has(spell.spell_name):
		return false
	if caster and "mp" in caster and caster.mp < spell.mp_cost:
		return false
	return true


func get_cooldown_remaining(spell_name: String) -> float:
	return cooldowns.get(spell_name, 0.0)


func _cast_projectile(target_pos: Vector2) -> void:
	if not charged_spell.projectile_scene:
		push_warning("Spell %s has no projectile scene" % charged_spell.spell_name)
		return

	var proj: Projectile = charged_spell.projectile_scene.instantiate()
	get_tree().root.add_child(proj)

	var direction := (target_pos - caster.global_position).normalized()

	proj.global_position = caster.global_position
	proj.setup(caster, direction, charged_spell.projectile_speed, charged_spell.damage)
	proj.knockback_force = charged_spell.knockback_force
	proj.element = charged_spell.element
	proj.effect = charged_spell.status_effect
	proj.modulate = charged_spell.color


func _cast_instant() -> void:
	# Hechizos instantaneos (curacion, buffs)
	if charged_spell.healing > 0 and caster and "hp" in caster:
		caster.hp += int(charged_spell.healing)

		# Particulas de curacion
		_spawn_heal_particles()


func _cast_ground(target_pos: Vector2) -> void:
	if not charged_spell.spawn_scene:
		push_warning("Spell %s has no spawn scene" % charged_spell.spell_name)
		return

	var obj: Node2D = charged_spell.spawn_scene.instantiate()
	get_tree().root.add_child(obj)
	obj.global_position = target_pos

	if "duration" in obj:
		obj.duration = charged_spell.spawn_duration
	if "caster" in obj:
		obj.caster = caster


func _cast_vector(start_pos: Vector2, end_pos: Vector2) -> void:
	if not charged_spell.spawn_scene:
		push_warning("Spell %s has no spawn scene" % charged_spell.spell_name)
		return

	var obj: Node2D = charged_spell.spawn_scene.instantiate()
	get_tree().root.add_child(obj)

	# Llamar setup con las posiciones
	if obj.has_method("setup"):
		obj.setup(start_pos, end_pos)

	if "duration" in obj:
		obj.duration = charged_spell.spawn_duration
	if "caster" in obj:
		obj.caster = caster


func _spawn_heal_particles() -> void:
	var particles := CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.5
	particles.amount = 12
	particles.lifetime = 0.8
	particles.direction = Vector2.UP
	particles.spread = 30.0
	particles.gravity = Vector2(0, -50)
	particles.initial_velocity_min = 30.0
	particles.initial_velocity_max = 60.0
	particles.scale_amount_min = 4.0
	particles.scale_amount_max = 8.0
	particles.color = Color("#ffd60a")  # Amarillo luz

	get_tree().root.add_child(particles)
	particles.global_position = caster.global_position

	var timer := get_tree().create_timer(1.0)
	timer.timeout.connect(particles.queue_free)
