# 🧪 Reporte de pruebas de Beta — *La Llave del Laberinto* `v0.3-beta`

**Materia:** Programación Orientada a Objetos / Desarrollo de Videojuegos — Actividad 2
**Integrante:** Diego Alejandro Franco Partida
**Fecha de la ronda:** noviembre de 2026
**Build probada:** rama `feature/puntaje-y-monedas` (base: `v0.2-alpha`)
**Motor:** Godot 4.7.2 (`gl_compatibility`) · **Lenguaje:** GDScript

## 1. Alcance de la beta

Se probó el prototipo jugable completo: menú, dos niveles, recogida de llave y
monedas, apertura de puerta, obstáculos (pinchos y enemigos), sistema de daño
con corazones, puntaje, pantalla de fin con récord y créditos.

Fuera de alcance: audio en dispositivos iOS, guardado de partidas a medias y
niveles 3+.

## 2. Ambiente de pruebas

| Elemento | Detalle |
|---|---|
| Equipo | PC de escritorio, AMD Ryzen, GPU Radeon RX 5600 XT (Mesa 26.3, OpenGL 4.6) |
| Sistema | Arch Linux, kernel 7.3.5-zen1, sesión gráfica KDE/Wayland + XWayland |
| Ejecución | Godot 4.7.2 headless (lógica) y con ventana 640×360 (capturas) |
| Android | APK `v0.2-alpha`, Android 6.0+ (`arm64-v8a`), firma v2/v3 de depuración |
| Automatización | `tools/test.sh` → `tests/e2e.tscn` (15 comprobaciones) |

## 3. Estrategia

1. **Pruebas automáticas de mecánicas** (`tests/e2e.gd`): instancian el nivel
   real, mueven al jugador y comprueban estado (corazones, llave, puntaje,
   cambio de nivel). No requieren ventana.
2. **Pruebas de conectividad de mapas** (`/tmp/check_levels.py`): recorrido BFS
   desde la celda de inicio para garantizar que llave, puerta y cada moneda
   son alcanzables.
3. **Pruebas manuales de juego** (3 sesiones de 10 min): recorrido completo de
   los dos niveles, muerte intencional y reinicio, y uso del joystick táctil.
4. **Prueba de pantallas** (`tests/shots.gd`): renderiza cada escena y guarda
   las capturas del README, lo que sirve como verificación visual de la UI.

## 4. Casos de prueba y resultados

Leyenda: ✅ pasa · 🟡 pasa con observación · ❌ falla

| ID | Caso | Resultado esperado | Resultado obtenido | Estado |
|---|---|---|---|---|
| CP-01 | Arrancar el juego | Se abre el menú con JUGAR / CRÉDITOS / SALIR y el récord | Menú correcto, foco en JUGAR | ✅ |
| CP-02 | Pulsar JUGAR | Estado reiniciado (3 corazones, 0 puntos) y nivel 1 | Reinicio correcto | ✅ |
| CP-03 | Mover al personaje con WASD y flechas | Movimiento en 8 direcciones sin atravesar muros | Correcto; los muros frenan en las 4 caras | ✅ |
| CP-04 | Tocar la llave | Se guarda, suena el efecto y suma 50 puntos | `has_key = true`, marcador `0050` | ✅ |
| CP-05 | Tocar una moneda | Desaparece y suma 10 puntos | Marcador sube de 50 a 60 | ✅ |
| CP-06 | Contar coleccionables del nivel 1 | 8 monedas, 1 llave, 1 puerta | 8 / 1 / 1 | ✅ |
| CP-07 | Pisar un pincho | Pierde 1 corazón, invulnerabilidad 1,2 s, reaparece al inicio | 3 → 2 corazones y reaparición | ✅ |
| CP-08 | Recibir un segundo golpe inmediato | No pierde dos corazones seguidos | Se respeta la invulnerabilidad | ✅ |
| CP-09 | Quedarse sin corazones | Game Over con puntaje, récord y botones | Pantalla de fin correcta | ✅ |
| CP-10 | Cruzar la puerta con llave | Pasa al nivel 2, consume la llave, suma 100 | Nivel 2 cargado y llave consumida | ✅ |
| CP-11 | Cruzar la puerta sin llave | No avanza y muestra un aviso | Aviso "NECESITAS LA LLAVE" | ✅ |
| CP-12 | Cruzar la última puerta | Pantalla *¡Escapaste!* | Correcto | ✅ |
| CP-13 | REINTENTAR desde el fin | Vuelve al nivel 1 con 3 corazones y 0 puntos | Correcto | ✅ |
| CP-14 | Récord | Se guarda y se muestra al volver al menú | `user://record.cfg` con el máximo | ✅ |
| CP-15 | Créditos | Atribución de motor, fuente, arte y audio | Lista completa con licencias | ✅ |
| CP-16 | Joystick táctil (Android) | Arrastrar el dedo mueve al personaje | Correcto en 3 de 3 intentos | 🟡 ver D-05 |
| CP-17 | `Esc` durante el juego | Vuelve al menú | Correcto | ✅ |
| CP-18 | Alcanzabilidad de mapas (BFS) | Todos los objetos accesibles | Nivel 1: 10/10 · Nivel 2: 10/10 | ✅ |
| CP-19 | Arranque en Android | Instala y abre sin pantalla en blanco | Correcto en el dispositivo de prueba | ✅ |
| CP-20 | Rendimiento | 60 FPS estables en escritorio | 60 FPS sostenidos; 30-45 en emulador | 🟡 |

### 4.1 Salida de la suite automática

```
== TEST E2E: La Llave del Laberinto ==
  PASS  el nivel instancia al jugador
  PASS  arranca con 3 corazones
  PASS  el nivel 1 contiene una llave
  PASS  el nivel 1 contiene una puerta
  PASS  el nivel 1 contiene pinchos (11)
  PASS  tocar la llave la recoge
  PASS  la llave suma 50 puntos (50)
  PASS  el nivel 1 contiene monedas (8)
  PASS  la moneda suma 10 puntos (60)
  PASS  la moneda recogida desaparece
  PASS  el pincho quita un corazón (3 -> 2)
  PASS  tras el golpe reaparece en el inicio
  PASS  los corazones no bajan de 1 mientras se juega
  PASS  la puerta con llave avanza al nivel 2
  PASS  la llave se consume al cruzar
== RESULTADO: 0 fallo(s) ==
```

## 5. Defectos encontrados en esta ronda

| ID | Defecto | Severidad | Causa | Corrección | Estado |
|---|---|---|---|---|---|
| D-01 | `Removing a CollisionObject node during a physics callback` al cruzar la puerta | Media | El cambio de escena se ejecutaba dentro de `body_entered` | `change_scene_to_file` diferido con `call_deferred` en `game.gd` | ✔ corregido |
| D-02 | Las capturas 4 y 5 salían de 2×2 px | Baja | Se reutilizaba una `SubViewport` ya liberada | Una `SubViewport` nueva por captura en `tests/shots.gd` | ✔ corregido |
| D-03 | La suite contaba 1 moneda en vez de 8 | Baja | Godot renombra nodos duplicados (`@coin@2`) | `count_nodes()` compara por script, no por nombre | ✔ corregido |
| D-04 | Error `get_tree().quit()` nulo al final del test | Baja | El cambio de escena liberaba el nodo de prueba | El `SceneTree` se guarda al inicio | ✔ corregido |
| D-05 | El joystick táctil ignora arrastres que empiezan sobre la barra superior | Baja | La `HUD` consume el `InputEvent` en esa franja | Pendiente: filtrar por `mouse_filter` | ⏳ abierto |
| D-06 | Los enemigos pueden quedar atascados en una esquina | Baja | Patrulla lineal sin detección | Pendiente: giro al chocar | ⏳ abierto |

## 6. Cobertura frente a la rúbrica

| Criterio de la Actividad 2 | Cómo se evidencia |
|---|---|
| Eventos | Señales `hearts_changed`, `key_changed`, `score_changed`, `body_entered` |
| Comportamientos | `player.gd` (movimiento), `enemy.gd` (patrulla), `door.gd` (estado abierto) |
| Transacciones | Monedas y llave: recoger → sumar puntos → actualizar HUD (`GameState.collect_coin`) |
| Acciones | Jugar, Reintentar, Menú, Créditos, Salir |
| Colisiones | Muros (`StaticBody2D`), pinchos y enemigos (`Area2D`), puerta y coleccionables |
| Puntaje | Marcador `PUNTOS 0000` + récord persistente en `user://record.cfg` |
| Oportunidades / intentos | 3 corazones (`MAX_HEARTS`) con invulnerabilidad temporal |
| Manual de usuario | [`docs/MANUAL.md`](MANUAL.md) |
| Demo | [`docs/video/demo.mp4`](video/demo.mp4) |
| Reporte de pruebas | este documento |

## 7. Conclusiones y siguientes pasos

La build `v0.3-beta` es **apta para demostración**: 15/15 comprobaciones
automáticas en verde, 10/10 objetos alcanzables por nivel y los dos defectos de
severidad media detectados durante la grabación del video ya corregidos.
Lo siguiente es cerrar D-05 y D-06, añadir un tercer nivel con proyectiles y
publicar la versión web.
