class_name ProceduralTerrain
extends TileMapLayer

# =============================================================================
# HONK MAGIC - Procedural Terrain Generator
# =============================================================================
# Genera terreno procedural usando FastNoiseLite.
# Basado en rune-terrain, adaptado con color_palette.gd

signal terrain_generated(width: int, height: int)

@export_group("Dimensiones")
@export var map_width: int = 80
@export var map_height: int = 60
@export var tile_size: int = 32

@export_group("Algoritmo")
@export var noise_frequency: float = 0.04
@export var noise_seed: int = 0
@export var use_random_seed: bool = true

# Biomas usando colores de HonkPalette
var biomas: Dictionary = {
	0: {"name": "Agua Profunda", "color": Color("#023e8a"), "solid": true},
	1: {"name": "Agua", "color": Color("#0077b6"), "solid": true},
	2: {"name": "Arena", "color": Color("#dda15e"), "solid": false},
	3: {"name": "Pasto", "color": Color("#2d6a4f"), "solid": false},
	4: {"name": "Pasto Claro", "color": Color("#40916c"), "solid": false},
	5: {"name": "Roca", "color": Color("#1b263b"), "solid": true},
}

var _current_seed: int = 0


func _ready() -> void:
	# Aplicar filtro nearest para pixel-perfect
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func generate(custom_seed: int = -1) -> void:
	"""Genera un nuevo mapa con el seed especificado o aleatorio"""
	if custom_seed >= 0:
		_current_seed = custom_seed
	elif use_random_seed:
		randomize()
		_current_seed = randi()
	else:
		_current_seed = noise_seed

	_setup_tileset()
	_generate_terrain()
	terrain_generated.emit(map_width, map_height)


func get_current_seed() -> int:
	return _current_seed


func get_map_bounds() -> Rect2:
	"""Retorna los limites del mapa en pixeles"""
	return Rect2(0, 0, map_width * tile_size, map_height * tile_size)


func _setup_tileset() -> void:
	const ATLAS_SEPARATION = 2
	var ts := TileSet.new()
	ts.tile_size = Vector2i(tile_size, tile_size)
	ts.add_physics_layer(0)

	# Crear imagen para el atlas
	var img_width := (tile_size + ATLAS_SEPARATION) * biomas.size()
	var img := Image.create(img_width, tile_size, false, Image.FORMAT_RGBA8)

	var i := 0
	for id in biomas:
		var base_color: Color = biomas[id]["color"]
		var start_x := i * (tile_size + ATLAS_SEPARATION)

		# Generar textura con variacion de color
		for x in range(tile_size):
			for y in range(tile_size):
				var variation := randf_range(-0.05, 0.05)
				var final_color := Color(
					clampf(base_color.r + variation, 0, 1),
					clampf(base_color.g + variation, 0, 1),
					clampf(base_color.b + variation, 0, 1),
					1.0
				)
				img.set_pixel(start_x + x, y, final_color)
		i += 1

	# Configurar atlas source
	var source := TileSetAtlasSource.new()
	source.texture = ImageTexture.create_from_image(img)
	source.texture_region_size = Vector2i(tile_size, tile_size)
	source.separation = Vector2i(ATLAS_SEPARATION, 0)
	ts.add_source(source)

	# Crear tiles y fisicas
	i = 0
	for id in biomas:
		var coords := Vector2i(i, 0)
		source.create_tile(coords)

		if biomas[id]["solid"]:
			var data := source.get_tile_data(coords, 0)
			if data:
				var rect := PackedVector2Array([
					Vector2(-tile_size / 2.0, -tile_size / 2.0),
					Vector2(tile_size / 2.0, -tile_size / 2.0),
					Vector2(tile_size / 2.0, tile_size / 2.0),
					Vector2(-tile_size / 2.0, tile_size / 2.0)
				])
				data.add_collision_polygon(0)
				data.set_collision_polygon_points(0, 0, rect)
		i += 1

	self.tile_set = ts


func _generate_terrain() -> void:
	clear()

	var noise := FastNoiseLite.new()
	noise.seed = _current_seed
	noise.frequency = noise_frequency
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_octaves = 4

	for x in range(map_width):
		for y in range(map_height):
			var v := noise.get_noise_2d(x, y)
			var tile_id := _get_biome_from_noise(v)
			set_cell(Vector2i(x, y), 0, Vector2i(tile_id, 0))


func _get_biome_from_noise(value: float) -> int:
	# Mapear valor de ruido (-1 a 1) a bioma
	if value < -0.3:
		return 0  # Agua Profunda
	elif value < -0.1:
		return 1  # Agua
	elif value < 0.0:
		return 2  # Arena
	elif value < 0.3:
		return 3  # Pasto
	elif value < 0.5:
		return 4  # Pasto Claro
	else:
		return 5  # Roca


func get_biomas_config() -> Dictionary:
	return biomas.duplicate(true)


func find_spawn_position() -> Vector2:
	"""Encuentra una posicion valida para spawn (no solida)"""
	var center := Vector2i(map_width / 2, map_height / 2)
	var search_radius := 10

	for r in range(search_radius):
		for dx in range(-r, r + 1):
			for dy in range(-r, r + 1):
				var check_pos := center + Vector2i(dx, dy)
				if _is_valid_spawn(check_pos):
					return Vector2(check_pos.x * tile_size + tile_size / 2,
								   check_pos.y * tile_size + tile_size / 2)

	# Fallback al centro
	return Vector2(center.x * tile_size, center.y * tile_size)


func _is_valid_spawn(tile_pos: Vector2i) -> bool:
	if tile_pos.x < 0 or tile_pos.x >= map_width:
		return false
	if tile_pos.y < 0 or tile_pos.y >= map_height:
		return false

	var atlas_coords := get_cell_atlas_coords(tile_pos)
	if atlas_coords == Vector2i(-1, -1):
		return false

	var biome_id := atlas_coords.x
	return not biomas.get(biome_id, {}).get("solid", true)
