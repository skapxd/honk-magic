class_name MapLoader
extends RefCounted

# =============================================================================
# HONK MAGIC - Map Loader
# =============================================================================
# Guarda y carga mapas en res://resources/maps/ (trackeable con git)
# Cada mapa tiene su propia carpeta con todos sus recursos.
# Formato JSON con grid CSV-style para eficiencia.

const MAPS_DIR := "res://resources/maps/"
const DEFAULT_MAP := "default_map"


static func get_map_folder(map_name: String) -> String:
	"""Retorna la carpeta del mapa"""
	var safe_name := map_name.replace(" ", "_").replace(".json", "")
	return MAPS_DIR + safe_name + "/"


static func get_map_path(map_name: String) -> String:
	"""Retorna el path al archivo map.json del mapa"""
	return get_map_folder(map_name) + "map.json"


static func _ensure_map_folder(map_name: String) -> bool:
	"""Crea la carpeta del mapa si no existe"""
	var folder := get_map_folder(map_name)
	if not DirAccess.dir_exists_absolute(folder):
		var err := DirAccess.make_dir_recursive_absolute(folder)
		if err != OK:
			push_error("MapLoader: No se pudo crear carpeta: ", folder)
			return false
	return true


static func save_map(terrain: ProceduralTerrain, map_name: String = DEFAULT_MAP) -> bool:
	"""Guarda el mapa actual a un archivo JSON en el proyecto"""
	var rect := terrain.get_used_rect()
	if rect.size == Vector2i.ZERO:
		push_error("MapLoader: No hay terreno para guardar")
		return false

	# Asegurar que existe la carpeta del mapa
	if not _ensure_map_folder(map_name):
		return false

	# Crear grid de datos (CSV-style)
	var grid_rows: Array = []
	for y in range(rect.position.y, rect.end.y):
		var row_values: Array = []
		for x in range(rect.position.x, rect.end.x):
			var coords := Vector2i(x, y)
			if terrain.get_cell_source_id(coords) != -1:
				var atlas_coords := terrain.get_cell_atlas_coords(coords)
				row_values.append(str(atlas_coords.x))
			else:
				row_values.append("-1")
		grid_rows.append(",".join(row_values))

	var data := {
		"version": "1.0",
		"generator": "HonkMagic",
		"name": map_name,
		"seed": terrain.get_current_seed(),
		"tile_size": terrain.tile_size,
		"width": rect.size.x,
		"height": rect.size.y,
		"origin_x": rect.position.x,
		"origin_y": rect.position.y,
		"biomas": _serialize_biomas(terrain.get_biomas_config()),
		"grid": grid_rows
	}

	var path := get_map_path(map_name)

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("MapLoader: No se pudo abrir archivo para escribir: ", path)
		push_error("Error: ", FileAccess.get_open_error())
		return false

	file.store_string(JSON.stringify(data, "\t"))
	file.close()

	print("MapLoader: Mapa guardado en ", path)
	return true


static func load_map(terrain: ProceduralTerrain, map_name: String = DEFAULT_MAP) -> bool:
	"""Carga un mapa desde archivo JSON"""
	var path := get_map_path(map_name)

	if not FileAccess.file_exists(path):
		print("MapLoader: Archivo no existe: ", path)
		return false

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("MapLoader: No se pudo abrir archivo: ", path)
		return false

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(json_text)
	if error != OK:
		push_error("MapLoader: Error parseando JSON: ", json.get_error_message())
		return false

	var data: Dictionary = json.data

	# Restaurar configuracion
	terrain.tile_size = int(data.get("tile_size", 32))
	terrain.map_width = int(data.get("width", 80))
	terrain.map_height = int(data.get("height", 60))

	# Reconstruir biomas
	var biomas := {}
	if data.has("biomas"):
		for k in data["biomas"]:
			biomas[int(k)] = _deserialize_bioma(data["biomas"][k])
		# Actualizar biomas en el terrain (si es necesario)

	# Recrear tileset
	terrain._setup_tileset()

	# Cargar grid
	terrain.clear()
	var origin_x := int(data.get("origin_x", 0))
	var origin_y := int(data.get("origin_y", 0))
	var grid: Array = data.get("grid", [])

	for y_offset in range(grid.size()):
		var row_string: String = grid[y_offset]
		var cell_values := row_string.split(",")

		for x_offset in range(cell_values.size()):
			var biome_id := int(cell_values[x_offset])
			if biome_id != -1:
				var coords := Vector2i(origin_x + x_offset, origin_y + y_offset)
				terrain.set_cell(coords, 0, Vector2i(biome_id, 0))

	print("MapLoader: Mapa cargado desde ", path)
	terrain.terrain_generated.emit(terrain.map_width, terrain.map_height)
	return true


static func list_maps() -> Array[String]:
	"""Lista todos los mapas disponibles (carpetas con map.json)"""
	var maps: Array[String] = []
	var dir := DirAccess.open(MAPS_DIR)

	if dir == null:
		return maps

	dir.list_dir_begin()
	var folder_name := dir.get_next()

	while folder_name != "":
		# Buscar carpetas que contengan map.json
		if dir.current_is_dir() and folder_name != "." and folder_name != "..":
			var map_json_path := MAPS_DIR + folder_name + "/map.json"
			if FileAccess.file_exists(map_json_path):
				maps.append(folder_name)
		folder_name = dir.get_next()

	dir.list_dir_end()
	return maps


static func map_exists(map_name: String) -> bool:
	return FileAccess.file_exists(get_map_path(map_name))


static func export_as_scene(terrain: ProceduralTerrain, map_name: String) -> bool:
	"""Exporta el mapa como una escena .tscn editable en Godot con colisiones"""
	var rect := terrain.get_used_rect()
	if rect.size == Vector2i.ZERO:
		push_error("MapLoader: No hay terreno para exportar")
		return false

	# Asegurar que existe la carpeta del mapa
	if not _ensure_map_folder(map_name):
		return false

	var folder := get_map_folder(map_name)
	var safe_name := map_name.replace(" ", "_")
	var biomas := terrain.get_biomas_config()
	var tile_size := terrain.tile_size

	# 1. Guardar la textura del atlas como PNG
	var texture_path := folder + "atlas.png"
	var original_tileset := terrain.tile_set
	if original_tileset == null or original_tileset.get_source_count() == 0:
		push_error("MapLoader: TileSet sin fuentes")
		return false

	var original_source := original_tileset.get_source(0) as TileSetAtlasSource
	if original_source == null or original_source.texture == null:
		push_error("MapLoader: TileSet sin textura")
		return false

	# Guardar imagen del atlas
	var atlas_image := original_source.texture.get_image()
	var save_png_result := atlas_image.save_png(texture_path)
	if save_png_result != OK:
		push_error("MapLoader: No se pudo guardar textura: ", save_png_result)
		return false

	print("MapLoader: Textura guardada en ", texture_path)

	# 2. Crear nuevo TileSet con la textura guardada
	var new_tileset := TileSet.new()
	new_tileset.tile_size = Vector2i(tile_size, tile_size)
	new_tileset.add_physics_layer(0)

	# Cargar la textura desde el archivo guardado
	var saved_texture := load(texture_path) as Texture2D
	if saved_texture == null:
		# Si no se puede cargar, crear desde imagen
		saved_texture = ImageTexture.create_from_image(atlas_image)

	# Crear atlas source
	var new_source := TileSetAtlasSource.new()
	new_source.texture = saved_texture
	new_source.texture_region_size = Vector2i(tile_size, tile_size)
	new_source.separation = Vector2i(2, 0)  # Mismo valor que en ProceduralTerrain
	new_tileset.add_source(new_source)

	# Crear tiles con colisiones
	var i := 0
	for id in biomas:
		var coords := Vector2i(i, 0)
		new_source.create_tile(coords)

		if biomas[id]["solid"]:
			var data := new_source.get_tile_data(coords, 0)
			if data:
				var half := tile_size / 2.0
				var collision_rect := PackedVector2Array([
					Vector2(-half, -half),
					Vector2(half, -half),
					Vector2(half, half),
					Vector2(-half, half)
				])
				data.add_collision_polygon(0)
				data.set_collision_polygon_points(0, 0, collision_rect)
		i += 1

	# 3. Guardar TileSet
	var tileset_path := folder + "tileset.tres"
	var tileset_save_result := ResourceSaver.save(new_tileset, tileset_path)
	if tileset_save_result != OK:
		push_error("MapLoader: No se pudo guardar TileSet: ", tileset_save_result)
		return false

	print("MapLoader: TileSet guardado en ", tileset_path)

	# 4. Crear escena con TileMapLayer
	var scene_path := folder + "scene.tscn"

	var exported_tilemap := TileMapLayer.new()
	exported_tilemap.name = safe_name
	exported_tilemap.tile_set = new_tileset
	exported_tilemap.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	# Copiar todas las celdas
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			var coords := Vector2i(x, y)
			var source_id := terrain.get_cell_source_id(coords)
			if source_id != -1:
				var atlas_coords := terrain.get_cell_atlas_coords(coords)
				exported_tilemap.set_cell(coords, source_id, atlas_coords)

	# Crear y guardar escena
	var packed_scene := PackedScene.new()
	var pack_result := packed_scene.pack(exported_tilemap)
	if pack_result != OK:
		push_error("MapLoader: No se pudo empaquetar escena")
		exported_tilemap.queue_free()
		return false

	var save_result := ResourceSaver.save(packed_scene, scene_path)
	exported_tilemap.queue_free()

	if save_result != OK:
		push_error("MapLoader: No se pudo guardar escena: ", save_result)
		return false

	print("MapLoader: Escena exportada a ", scene_path)
	return true


static func _serialize_biomas(biomas: Dictionary) -> Dictionary:
	var serialized := {}
	for id in biomas:
		var b: Dictionary = biomas[id].duplicate()
		if b.has("color") and b["color"] is Color:
			b["color"] = (b["color"] as Color).to_html(false)
		serialized[str(id)] = b
	return serialized


static func _deserialize_bioma(bioma_data: Dictionary) -> Dictionary:
	var result := bioma_data.duplicate()
	if result.has("color") and result["color"] is String:
		result["color"] = Color(result["color"])
	return result
