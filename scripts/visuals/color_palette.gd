class_name HonkPalette
extends RefCounted

# =============================================================================
# HONK MAGIC - Paleta de Colores Unificada
# =============================================================================

# -----------------------------------------------------------------------------
# Fondo y Ambiente
# -----------------------------------------------------------------------------
const FONDO_PROFUNDO := Color("#0f0f1a")  # Casi negro azulado
const FONDO_MEDIO := Color("#1a1a2e")     # Azul noche
const FONDO_CLARO := Color("#16213e")     # Azul profundo

# -----------------------------------------------------------------------------
# Elementos (Sistema Mágico)
# -----------------------------------------------------------------------------
const FUEGO := Color("#ff6b35")           # Naranja intenso
const FUEGO_GLOW := Color("#ff9f1c")      # Amarillo fuego

const AGUA := Color("#00b4d8")            # Azul cristalino
const AGUA_GLOW := Color("#90e0ef")       # Cian claro

const VIENTO := Color("#70e000")          # Verde lima
const VIENTO_GLOW := Color("#ccff33")     # Verde brillante

const TIERRA := Color("#bc6c25")          # Marrón cálido
const TIERRA_GLOW := Color("#dda15e")     # Arena

const LUZ := Color("#ffd60a")             # Amarillo dorado
const LUZ_GLOW := Color("#fff8e7")        # Blanco cálido

const OSCURIDAD := Color("#7b2cbf")       # Violeta profundo
const OSCURIDAD_GLOW := Color("#c77dff")  # Lavanda

# -----------------------------------------------------------------------------
# UI y Entidades
# -----------------------------------------------------------------------------
const PROTAGONISTA := Color("#e0e0e0")    # Blanco hueso
const ALIADO := Color("#4cc9f0")          # Cian aliado
const ENEMIGO := Color("#ef233c")         # Rojo enemigo
const NEUTRAL := Color("#adb5bd")         # Gris neutro

const UI_BORDE := Color("#fca311")        # Dorado
const UI_FONDO := Color("#14213d99")      # Azul oscuro semi-transparente
const UI_TEXTO := Color("#e5e5e5")        # Blanco suave
const UI_ACENTO := Color("#00f5d4")       # Turquesa

# -----------------------------------------------------------------------------
# Terreno
# -----------------------------------------------------------------------------
const PISO_BASE := Color("#2d6a4f")       # Verde bosque
const PISO_CLARO := Color("#40916c")      # Verde medio
const MURO := Color("#1b263b")            # Azul grisáceo
const AGUA_TERRENO := Color("#023e8a")    # Azul profundo
const HIELO := Color("#a2d2ff")           # Azul hielo

# -----------------------------------------------------------------------------
# Partículas y Efectos
# -----------------------------------------------------------------------------
const PARTICULA_FUEGO_1 := Color("#D2691E")     # Naranja quemado
const PARTICULA_FUEGO_2 := Color("#8B0000")     # Rojo oscuro
const PARTICULA_AGUA_1 := Color("#1E90FF")      # Azul dodger
const PARTICULA_AGUA_2 := Color("#00BFFF")      # Cian claro
const PARTICULA_VIENTO_1 := Color("#F5F5F5")    # Blanco humo
const PARTICULA_VIENTO_2 := Color("#A9A9A9")    # Gris oscuro
const PARTICULA_TIERRA_1 := Color("#8B7355")    # Marrón tierra
const PARTICULA_TIERRA_2 := Color("#D2B48C")    # Beige arena
const PARTICULA_LUZ_1 := Color("#FFD700")       # Dorado
const PARTICULA_LUZ_2 := Color("#FFFACD")       # Limón claro
const PARTICULA_OSCURIDAD_1 := Color("#4B0082") # Índigo
const PARTICULA_OSCURIDAD_2 := Color("#2F2F2F") # Gris muy oscuro
const PARTICULA_CURACION_1 := Color("#00FF7F")  # Verde primavera
const PARTICULA_CURACION_2 := Color("#FFFACD")  # Amarillo claro
const PARTICULA_ERROR := Color("#FF0000")       # Rojo puro

# -----------------------------------------------------------------------------
# Utilidades
# -----------------------------------------------------------------------------

## Obtiene el color principal de un elemento por nombre
static func get_element_color(element: String) -> Color:
	match element.to_lower():
		"fuego", "fire": return FUEGO
		"agua", "water": return AGUA
		"viento", "wind": return VIENTO
		"tierra", "earth": return TIERRA
		"luz", "light": return LUZ
		"oscuridad", "darkness": return OSCURIDAD
		_: return NEUTRAL

## Obtiene el color glow de un elemento por nombre
static func get_element_glow(element: String) -> Color:
	match element.to_lower():
		"fuego", "fire": return FUEGO_GLOW
		"agua", "water": return AGUA_GLOW
		"viento", "wind": return VIENTO_GLOW
		"tierra", "earth": return TIERRA_GLOW
		"luz", "light": return LUZ_GLOW
		"oscuridad", "darkness": return OSCURIDAD_GLOW
		_: return NEUTRAL

## Obtiene los colores de partículas de un elemento
static func get_particle_colors(element: String) -> Array[Color]:
	match element.to_lower():
		"fuego", "fire": return [PARTICULA_FUEGO_1, PARTICULA_FUEGO_2]
		"agua", "water": return [PARTICULA_AGUA_1, PARTICULA_AGUA_2]
		"viento", "wind": return [PARTICULA_VIENTO_1, PARTICULA_VIENTO_2]
		"tierra", "earth": return [PARTICULA_TIERRA_1, PARTICULA_TIERRA_2]
		"luz", "light": return [PARTICULA_LUZ_1, PARTICULA_LUZ_2]
		"oscuridad", "darkness": return [PARTICULA_OSCURIDAD_1, PARTICULA_OSCURIDAD_2]
		"curacion", "heal": return [PARTICULA_CURACION_1, PARTICULA_CURACION_2]
		_: return [NEUTRAL, NEUTRAL]
