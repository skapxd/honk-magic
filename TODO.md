# Honk Magic - Entregables MVP

Cada entregable es una versión ejecutable del juego con commits semánticos.

---

## Entregable 0: Setup CI/CD
**Objetivo:** Configurar GitHub Actions para compilación automática
**Tag:** `v0.0.1-setup`

### Tareas:
- [x] Crear `.github/workflows/build.yml`
- [x] Crear `export_presets.cfg` con 4 plataformas (Web, Windows, Linux, macOS)
- [ ] Subir a GitHub y verificar que compila
- [ ] Configurar GitHub Pages para la versión Web

### Comportamiento:
- **Push a main**: Compila Web + Deploy a GitHub Pages
- **Push de tag v***: Compila todas las plataformas + Crea Release con zips
- **Pull Request**: Compila todas las plataformas (verificación)

**Criterio de aceptación:** El workflow compila exitosamente y GitHub Pages muestra el juego.

---

## Entregable 1: Sistema Base + Pantalla de Título ✅
**Objetivo:** Juego ejecutable con pantalla de título funcional
**Tag:** `v0.1.0-title`

### Tareas:
- [x] Crear `scripts/visuals/color_palette.gd` (constantes de color)
- [x] Crear `resources/theme/honk_theme.tres` (tema visual base)
- [x] Crear `autoloads/GameManager.gd` (estado global mínimo)
- [x] Crear `scenes/ui/title_screen.tscn` con:
  - Logo "HONK MAGIC" procedural (texto + formas geométricas)
  - Fondo con shader de niebla/partículas
  - Texto "Dibuja una runa para entrar" (placeholder, sin funcionalidad aún)
- [x] Configurar `project.godot`:
  - Autoloads
  - Input actions básicos
  - Resolución 1920x1080, stretch mode canvas_items
  - Escena inicial: title_screen.tscn

**Criterio de aceptación:** Al ejecutar, muestra pantalla de título con estética del juego.

---

## Entregable 2: Menú Principal + Navegación ✅
**Objetivo:** Navegación funcional entre pantallas
**Tag:** `v0.2.0-menu`

### Tareas:
- [x] Crear `scenes/ui/main_menu.tscn` con:
  - Botones: AVENTURA, TUTORIAL, OPCIONES, SALIR
  - Fondo con shader de niebla
  - Transiciones suaves entre botones (hover/focus)
- [x] Crear `scenes/ui/options_menu.tscn` (con selector de idioma y pantalla completa)
- [x] Crear sistema de transiciones entre escenas
- [x] Implementar navegación:
  - Title Screen → (cualquier input) → Main Menu
  - Main Menu → SALIR → Cierra el juego
  - Main Menu → OPCIONES → Options Menu → VOLVER → Main Menu
  - Main Menu → AVENTURA → (siguiente entregable)

**Criterio de aceptación:** Navegación fluida entre pantallas con feedback visual.

---

## Entregable 3: Sistema de Guardado + Selector de Partida ✅
**Objetivo:** Crear/cargar partidas con 3 slots
**Tag:** `v0.3.0-saves`

### Tareas:
- [x] Crear `autoloads/SaveManager.gd`:
  - Guardar/cargar en user://saves/
  - 3 slots de partida
  - Estructura de datos según PLAN.md sección 9.2
- [x] Crear `scenes/ui/save_select.tscn`:
  - 3 slots visuales
  - Mostrar datos de partida existente o "Nueva Partida"
  - Modal para ingresar nombre al crear partida
- [x] Conectar Main Menu → AVENTURA → Save Select

**Criterio de aceptación:** Crear partida, cerrar juego, volver a abrirlo y ver la partida guardada.

---

## Entregable 3.5: Entorno de Debug/Testing
**Objetivo:** Infraestructura de sandbox para desarrollo
**Tag:** `v0.3.5-debug`

### Tareas:
- [x] Agregar botón DEBUG en `main_menu.tscn` (después de OPCIONES)
- [x] Crear `scenes/debug/debug_menu.tscn`:
  - Lista de escenarios de test (botones deshabilitados para futuros)
  - Botón VOLVER al menú principal
  - Estilo visual consistente (turquesa para debug)
- [x] Crear `scenes/debug/test_player.tscn` (estructura básica):
  - Grid de debug para visualizar movimiento
  - Player básico (hexágono)
  - Cámara que sigue al jugador
  - HUD de debug (FPS, posición)
- [x] Agregar traducciones para DEBUG en `translations.csv`

**Criterio de aceptación:** Main Menu → DEBUG → Test Player → ver escena → VOLVER → Main Menu.

### Escenarios y herramientas de debug:
- [x] `map_generator.tscn` - Generador de mapas procedurales (Entregable 6)
- [x] `test_runes.tscn` - Dibujo y reconocimiento de runas (Entregable 7)
- [x] `test_spells.tscn` - Lanzar hechizos y efectos (Entregable 8)
- [x] `test_enemies.tscn` - Combate player vs enemigos (Entregable 9)
- [ ] `test_rts.tscn` - Selección y comandos de unidades
- [ ] `test_capture.tscn` - Captura e invocación

---

## Entregable 4: Sistema RTS + Movimiento ✅
**Objetivo:** Mecánicas de selección y movimiento estilo RTS
**Tag:** `v0.4.0-rts`

### Tareas:
- [x] Crear `scripts/core/selection_manager.gd`:
  - Click izquierdo: seleccionar unidad
  - Arrastrar: caja de selección
  - Indicador visual de selección
- [x] Mejorar Player en `test_player.tscn`:
  - Añadir grupo "selectable"
  - Visual de selección (círculo pulsante)
  - Solo mover si está seleccionado
- [x] Implementar movimiento RTS completo:
  - Click derecho: mover unidades seleccionadas
  - Indicador de destino animado
  - Movimiento en línea recta
- [x] Probar en `test_player.tscn`

**Criterio de aceptación:** Click izquierdo selecciona, caja de selección funciona, click derecho mueve unidad seleccionada.

---

## Entregable 5: Mundo Básico + HUD ✅
**Objetivo:** Escena de gameplay conectada al flujo del juego
**Tag:** `v0.5.0-world`

### Tareas:
- [x] Crear `scenes/gameplay/main_world.tscn`:
  - Fondo simple (shader de niebla)
  - Jugador instanciado
  - Selection Manager integrado
- [x] Crear HUD básico (`scenes/ui/hud.tscn`):
  - HP/MP en esquina superior izquierda
- [x] Conectar Save Select → JUGAR → main_world
- [x] Guardar posición del jugador en SaveManager
- [x] Crear `scripts/entities/player.gd` reutilizable

**Criterio de aceptación:** Flujo completo: Menú → Partida → Gameplay con HUD visible.

---

## Entregable 6: Terreno Procedural ✅
**Objetivo:** Mapa con terreno generado proceduralmente
**Tag:** `v0.6.0-terrain`

### Configuración de Rendering (desde rune-terrain)

**Global** (project.godot):
```ini
[physics]
common/physics_interpolation=true
```
- `physics_interpolation=true`: Movimiento fluido entre frames de física

**Por Nodo** (NO global, para no afectar UI):
```gdscript
# En nodos que requieren pixel-perfect (terreno, player visual)
texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
```

Aplicar `TEXTURE_FILTER_NEAREST` solo a:
- TileMapLayer (terreno)
- Player Visual (Polygon2D)
- Otros elementos de gameplay pixel-art

NO aplicar a:
- HUD (CanvasLayer)
- Menús
- Textos y botones

### Sistema de Dev Tools
- [x] Agregar input action `toggle_dev_tools` → F4
- [x] Crear panel de Dev Tools (similar a Debug HUD pero para herramientas)

### Tareas:
- [x] Aplicar configuración de rendering en project.godot
- [x] Portar sistema de terreno desde `rune-terrain`:
  - `world_generator.gd` → `scripts/core/procedural_terrain.gd`
  - `map_loader.gd` → `scripts/core/map_loader.gd`
- [x] Adaptar paleta de colores:
  - Agua Profunda (#023e8a) → Bloquea movimiento
  - Agua (#0077b6) → Bloquea movimiento
  - Arena (#dda15e) → Transitable
  - Pasto (#2d6a4f) → Transitable
  - Pasto Claro (#40916c) → Transitable
  - Roca (#1b263b) → Bloquea movimiento
- [x] Crear `scripts/core/procedural_terrain.gd`:
  - Generación con FastNoiseLite (Perlin)
  - TileSet procedural con colores
  - Colisiones automáticas para tiles sólidos
  - TEXTURE_FILTER_NEAREST aplicado por nodo
- [x] Crear `scripts/core/map_loader.gd`:
  - Guardar mapas en `res://resources/maps/` (proyecto, trackeable con git)
  - Formato JSON con grid CSV-style
  - Cargar mapas existentes
- [x] Integrar en main_world.tscn:
  - TileMapLayer con terreno
  - Límites de cámara según tamaño del mapa
- [x] Crear Dev Tool: Map Generator (F4)
  - Panel con controles:
    - SpinBox: Seed + botón Random
    - SpinBox: Dimensiones (width/height)
    - Botón: Generar nuevo mapa
    - Botón: Guardar/Cargar mapa
- [x] Crear escena Map Generator accesible desde Debug Menu
  - Vista previa del mapa generado en SubViewport
  - Click en mapas guardados muestra vista previa
  - Exportar como .tscn con atlas, tileset y colisiones preservadas
  - Mapas organizados en carpetas individuales (`resources/maps/nombre_mapa/`)

### Estructura de Carpeta por Mapa
```
resources/maps/
  nombre_mapa/
    map.json       # Datos del mapa (grid, seed, biomas)
    atlas.png      # Textura del tileset (si exportado)
    tileset.tres   # TileSet con colisiones (si exportado)
    scene.tscn     # Escena editable en Godot (si exportado)
```

**Criterio de aceptación:** Jugador camina por terreno procedural, colisiona con muros. Dev Tools permite generar, guardar y exportar mapas editables.

---

## Entregable 7: Sistema de Runas Básico ✅
**Objetivo:** Dibujar runas y reconocerlas
**Tag:** `v0.7.0-runes`

### Tareas:
- [x] Portar `DollarRecognizer.gd` desde `rune-trace`
  - Algoritmo $1 para reconocimiento de gestos
  - 6 runas predefinidas: fuego, agua, viento, tierra, luz, oscuridad
- [x] Crear `scenes/gameplay/rune_canvas.tscn`:
  - Modal centrado con dimmer (CanvasLayer)
  - Lienzo de dibujo (Line2D)
  - Display de runas disponibles (iconos de colores)
  - Feedback de reconocimiento con score
- [x] Implementar modo runa:
  - ESPACIO para activar modo runa
  - Click arrastrar para dibujar
  - Soltar ESPACIO: reconocer runa
  - ESC para cancelar
- [x] Integrar con HUD:
  - Indicador visual "MODO RUNA" en centro superior
  - Desactivar SelectionManager durante modo runa

**Criterio de aceptación:** Dibujar triángulo → reconoce "FUEGO", muestra feedback.

---

## Entregable 8: Lanzar Hechizos ✅
**Objetivo:** Hechizos funcionales con efectos visuales
**Tag:** `v0.8.0-spells`

### Tareas:
- [x] Portar sistema de hechizos desde `rune-spell-cast`
- [x] Crear `scripts/spell_system/spell_caster.gd`
- [x] Crear `scripts/spell_system/spell_resource.gd`
- [x] Crear `scripts/spell_system/projectile.gd`
- [x] Crear `scripts/spell_system/status_effect.gd` y efectos:
  - `burn_effect.gd` - Daño por segundo (Fuego)
  - `wet_effect.gd` - Ralentiza (Agua)
  - `knockback_effect.gd` - Empuje (Viento)
- [x] Crear `scripts/spell_system/status_manager.gd`
- [x] Implementar 6 hechizos nivel 1:
  - FUEGO: Bola de fuego (20 daño, 15 MP)
  - AGUA: Bola de agua + mojado (12 daño, 12 MP)
  - VIENTO: Ráfaga + empuje (8 daño, 10 MP)
  - TIERRA: Muro defensivo (placeholder, 20 MP)
  - LUZ: Curación (30 HP, 25 MP)
  - OSCURIDAD: Captura (placeholder, 30 MP)
- [x] Efectos de partículas para proyectiles e impactos
- [x] Sistema de MP: consumo y regeneración automática
- [x] Integrar con sistema de runas:
  - Dibujar runa → carga hechizo
  - Click izquierdo → lanzar hechizo
  - Click derecho/ESC → cancelar
- [x] Indicador visual de hechizo cargado en HUD

**Criterio de aceptación:** Dibujar runa → cargar hechizo → click para lanzar → efecto visual.

---

## Entregable 9: Enemigos ✅
**Objetivo:** Enemigos con IA básica que atacan al jugador
**Tag:** `v0.9.0-enemies`

### Tareas:
- [x] Crear `scripts/entities/entity_base.gd` (HP, daño, estados)
- [x] Crear `scripts/entities/enemy_base.gd` (IA base para enemigos)
- [x] Crear `scenes/entities/enemy_tank.tscn` (cuadrado + cuernos)
- [x] Crear `scenes/entities/enemy_fast.tscn` (triángulo + estela)
- [x] Crear `scenes/entities/enemy_mage.tscn` (círculo + orbe)
- [x] Implementar IA según PLAN.md sección 9.7:
  - Estados: IDLE → CHASE → ATTACK
  - Detección del jugador
  - Ataques (cuerpo a cuerpo / proyectil)
- [x] Sistema de daño bidireccional (jugador ↔ enemigos)
- [x] Muerte de enemigos con partículas
- [x] Crear `scenes/debug/test_enemies.tscn` para debug

**Criterio de aceptación:** Enemigos persiguen al jugador, lo atacan, mueren con hechizos.

---

## Entregable 10: Aliados
**Objetivo:** Aliados que pelean junto al jugador
**Tag:** `v0.10.0-allies`

### Tareas:
- [ ] Crear `scenes/entities/ally.tscn` (triángulo + espada)
- [ ] Reutilizar Selection Manager del Entregable 4
- [ ] Aliados seleccionables y comandables como el jugador
- [ ] Aliados atacan enemigos automáticamente cuando están cerca
- [ ] Aliados pueden morir

**Criterio de aceptación:** Seleccionar aliados, moverlos con click derecho, atacan enemigos.

---

## Entregable 11: Sistema de Captura
**Objetivo:** Capturar enemigos debilitados
**Tag:** `v0.11.0-capture`

### Tareas:
- [ ] Implementar OSCURIDAD_1 como hechizo de captura
- [ ] Verificar HP < 25% para captura exitosa
- [ ] Monstruos capturados van a "reserva" (datos en SaveManager)
- [ ] Efectos visuales: espiral de captura, flash de éxito/fallo
- [ ] Feedback: "No está lo suficientemente débil" si HP >= 25%

**Criterio de aceptación:** Debilitar enemigo → dibujar ? → captura exitosa → guardado.

---

## Entregable 12: Grimorio + Invocación
**Objetivo:** Ver monstruos capturados e invocarlos
**Tag:** `v0.12.0-grimoire`

### Tareas:
- [ ] Crear `scenes/ui/grimoire.tscn`:
  - Modal overlay (NO pausa el juego)
  - Tab RUNAS: Lista de 6 runas con descripción
  - Tab MONSTRUOS: Lista de monstruos capturados + botón INVOCAR
- [ ] Implementar invocación:
  - Monstruo aparece junto al jugador
  - Cooldown 5 segundos
  - Límite 24 en campo
- [ ] Tecla G para abrir/cerrar

**Criterio de aceptación:** Capturar enemigo → G → Monstruos → INVOCAR → aparece como aliado.

---

## Entregable 13: Pausa + Game Over
**Objetivo:** Menú de pausa y condición de derrota
**Tag:** `v0.13.0-pause`

### Tareas:
- [ ] Crear `scenes/ui/pause_menu.tscn`:
  - Pausa el juego (ESC)
  - Opciones: Continuar, Opciones, Menú Principal
- [ ] Implementar muerte del jugador:
  - HP = 0 → Game Over
  - Pierde monstruos invocados
  - Conserva monstruos en reserva y equipo
- [ ] Crear `scenes/ui/game_over.tscn`
- [ ] Volver al menú principal o reiniciar

**Criterio de aceptación:** ESC pausa, muerte muestra game over, persistencia correcta.

---

## Entregable 14: Tutorial + Pulido
**Objetivo:** Experiencia inicial guiada
**Tag:** `v0.14.0-tutorial`

### Tareas:
- [ ] Crear mapa de tutorial con carteles diegéticos
- [ ] Secuencia guiada:
  1. Movimiento (click derecho)
  2. Modo runa (ESPACIO)
  3. Lanzar hechizo
  4. Combatir enemigo
  5. Capturar e invocar
- [ ] Pulir transiciones y feedback
- [ ] Revisar todos los efectos visuales

**Criterio de aceptación:** Nuevo jugador puede completar tutorial sin confusión.

---

## Entregable 15: MVP Completo
**Objetivo:** Versión jugable completa
**Tag:** `v1.0.0-mvp`

### Tareas:
- [ ] Crear mapa del bosque (primer nivel real)
- [ ] Balance de stats según PLAN.md sección 9.15
- [ ] Testing completo de todos los sistemas
- [ ] Fix de bugs encontrados
- [ ] Optimización básica de rendimiento

**Criterio de aceptación:** Sesión de juego completa de 10-15 minutos sin crashes.

---

## Notas de Desarrollo

### Convenciones de Commits
```
feat: nueva funcionalidad
fix: corrección de bug
refactor: cambio de código sin nueva funcionalidad
docs: documentación
style: formato, sin cambios de lógica
test: agregar tests
chore: mantenimiento
```

### Flujo de Trabajo
1. Crear branch: `git checkout -b entregable-X-descripcion`
2. Implementar tareas del entregable
3. Probar que todo funcione
4. Commit con mensaje semántico
5. Merge a main
6. Tag con versión

### Dependencias entre Entregables
```
1 (Title) ─► 2 (Menu) ─► 3 (Saves) ─► 3.5 (Debug) ─► 4 (RTS)
                                                        │
    ┌───────────────────────────────────────────────────┘
    │
    ▼
 5 (World) ─► 6 (Terrain) ─► 7 (Runes) ─► 8 (Spells)
                                               │
                                               ▼
                                          9 (Enemies)
                                               │
                                               ▼
                                          10 (Allies)
                                               │
                                               ▼
                                         11 (Capture)
                                               │
                                               ▼
                                        12 (Grimoire)
                                               │
                                               ▼
                                          13 (Pause)
                                               │
                                               ▼
                                        14 (Tutorial)
                                               │
                                               ▼
                                           15 (MVP)

Nota: El entorno Debug (3.5) permite desarrollar cada entregable
en aislamiento. Cada test scene se crea cuando se necesita.
```
