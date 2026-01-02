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

## Entregable 4: Mundo Básico + Jugador
**Objetivo:** Escena de gameplay con jugador movible (RTS style)
**Tag:** `v0.4.0-player`

### Tareas:
- [ ] Crear `scripts/visuals/procedural_shape.gd` (formas geométricas)
- [ ] Crear `scenes/entities/player.tscn`:
  - Hexágono procedural con vara flotante
  - Estados: idle, move
- [ ] Crear `scripts/entities/player.gd`:
  - Movimiento RTS: click derecho para moverse
  - Pathfinding básico (o línea recta inicial)
- [ ] Crear `scenes/gameplay/main_world.tscn`:
  - Fondo simple (color sólido o shader básico)
  - Jugador instanciado
  - Cámara que sigue al jugador
- [ ] Crear HUD básico (`scenes/ui/hud.tscn`):
  - HP/MP en esquina superior izquierda
- [ ] Conectar Save Select → JUGAR → main_world

**Criterio de aceptación:** Mover jugador con click derecho, cámara lo sigue, HUD visible.

---

## Entregable 5: Terreno Procedural
**Objetivo:** Mapa con terreno generado proceduralmente
**Tag:** `v0.5.0-terrain`

### Tareas:
- [ ] Portar sistema de terreno desde `rune-terrain`
- [ ] Adaptar paleta de colores (color_palette.gd)
- [ ] Crear `scripts/core/procedural_terrain.gd`
- [ ] Integrar en main_world.tscn:
  - TileMapLayer con terreno generado
  - Colisiones con muros
  - Agua no transitable
- [ ] Crear herramienta dev: `scenes/dev_tools/map_generator.tscn`
  - Botón generar, slider seed
  - Botón exportar a .tscn

**Criterio de aceptación:** Jugador camina por terreno procedural, colisiona con muros.

---

## Entregable 6: Sistema de Runas Básico
**Objetivo:** Dibujar runas y reconocerlas
**Tag:** `v0.6.0-runes`

### Tareas:
- [ ] Portar `DollarRecognizer.gd` desde `rune-trace`
- [ ] Crear `scenes/gameplay/rune_canvas.tscn`:
  - Modal centrado con dimmer
  - Lienzo de dibujo (Line2D)
  - Display de runas disponibles
  - Feedback de reconocimiento
- [ ] Implementar modo runa:
  - ESPACIO para entrar/salir
  - Click arrastrar para dibujar
  - Al soltar ESPACIO: reconocer runa
- [ ] Integrar con HUD:
  - Indicador visual de "modo runa activo"

**Criterio de aceptación:** Dibujar triángulo → reconoce "FUEGO", muestra feedback.

---

## Entregable 7: Lanzar Hechizos
**Objetivo:** Hechizos funcionales con efectos visuales
**Tag:** `v0.7.0-spells`

### Tareas:
- [ ] Portar sistema de hechizos desde `rune-spell-cast`
- [ ] Crear `scripts/spell_system/spell_caster.gd`
- [ ] Crear `scripts/spell_system/spell_resource.gd`
- [ ] Implementar 6 hechizos nivel 1:
  - FUEGO_1: Bola de fuego + quemadura
  - AGUA_1: Bola de agua + mojado
  - VIENTO_1: Ráfaga + empuje
  - TIERRA_1: Muro defensivo
  - LUZ_1: Curación
  - OSCURIDAD_1: Captura (placeholder)
- [ ] Efectos de partículas para cada elemento
- [ ] Sistema de MP: consumo y regeneración

**Criterio de aceptación:** Dibujar runa → cargar hechizo → click para lanzar → efecto visual.

---

## Entregable 8: Enemigos
**Objetivo:** Enemigos con IA básica que atacan al jugador
**Tag:** `v0.8.0-enemies`

### Tareas:
- [ ] Crear `scripts/entities/entity_base.gd` (HP, daño, estados)
- [ ] Crear `scenes/entities/enemy_tank.tscn` (cuadrado + cuernos)
- [ ] Crear `scenes/entities/enemy_fast.tscn` (triángulo + estela)
- [ ] Crear `scenes/entities/enemy_mage.tscn` (círculo + orbe)
- [ ] Implementar IA según PLAN.md sección 9.7:
  - Estados: IDLE → CHASE → ATTACK
  - Detección del jugador
  - Ataques (cuerpo a cuerpo / proyectil)
- [ ] Sistema de daño bidireccional (jugador ↔ enemigos)
- [ ] Muerte de enemigos con partículas

**Criterio de aceptación:** Enemigos persiguen al jugador, lo atacan, mueren con hechizos.

---

## Entregable 9: Aliados + Sistema RTS
**Objetivo:** Comandar aliados con selección RTS
**Tag:** `v0.9.0-allies`

### Tareas:
- [ ] Portar sistema de selección desde `rune-rts-selection`
- [ ] Crear `scripts/core/selection_manager.gd`
- [ ] Crear `scenes/entities/ally.tscn` (triángulo + espada)
- [ ] Implementar selección:
  - Click izquierdo: seleccionar unidad
  - Click + arrastrar: caja de selección
  - Click derecho: mover unidades seleccionadas
- [ ] Aliados atacan enemigos automáticamente cuando están cerca
- [ ] Aliados pueden morir

**Criterio de aceptación:** Seleccionar aliados, moverlos con click derecho, atacan enemigos.

---

## Entregable 10: Sistema de Captura
**Objetivo:** Capturar enemigos debilitados
**Tag:** `v0.10.0-capture`

### Tareas:
- [ ] Implementar OSCURIDAD_1 como hechizo de captura
- [ ] Verificar HP < 25% para captura exitosa
- [ ] Monstruos capturados van a "reserva" (datos en SaveManager)
- [ ] Efectos visuales: espiral de captura, flash de éxito/fallo
- [ ] Feedback: "No está lo suficientemente débil" si HP >= 25%

**Criterio de aceptación:** Debilitar enemigo → dibujar ? → captura exitosa → guardado.

---

## Entregable 11: Grimorio + Invocación
**Objetivo:** Ver monstruos capturados e invocarlos
**Tag:** `v0.11.0-grimoire`

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

## Entregable 12: Pausa + Game Over
**Objetivo:** Menú de pausa y condición de derrota
**Tag:** `v0.12.0-pause`

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

## Entregable 13: Tutorial + Pulido
**Objetivo:** Experiencia inicial guiada
**Tag:** `v0.13.0-tutorial`

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

## Entregable 14: MVP Completo
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
1 (Title) ─┐
           ├─► 2 (Menu) ─┐
           │             ├─► 3 (Saves) ─► 4 (Player) ─► 5 (Terrain)
           │             │                    │
           │             │                    ▼
           │             │              6 (Runes) ─► 7 (Spells)
           │             │                              │
           │             │                              ▼
           │             │                         8 (Enemies)
           │             │                              │
           │             │                              ▼
           │             │                         9 (Allies)
           │             │                              │
           │             │                              ▼
           │             │                        10 (Capture)
           │             │                              │
           │             │                              ▼
           │             │                       11 (Grimoire)
           │             │                              │
           │             └────────────────────────────► │
                                                        ▼
                                                   12 (Pause)
                                                        │
                                                        ▼
                                                   13 (Tutorial)
                                                        │
                                                        ▼
                                                    14 (MVP)
```
