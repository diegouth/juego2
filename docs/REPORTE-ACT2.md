# 📄 Reporte — Actividad 2: portafolio de evidencias

**Videojuego:** *La Llave del Laberinto* `v0.3-beta`
**Materia:** Programación Orientada a Objetos — videojuego
**Profesor:** Ivan Rogelio Chenoweth Chenoweth
**Integrante:** Diego Alejandro Franco Partida
**Motor:** Godot 4.7.2 · **Lenguaje:** GDScript (POO con clases y señales)
**Fecha:** noviembre de 2026

---

## 1. Enlaces de entrega

| Elemento | Enlace |
|---|---|
| Repositorio | https://github.com/diegouth/juego2 |
| Release `v0.3-beta` (APK + versión web) | https://github.com/diegouth/juego2/releases/tag/v0.3-beta |
| PR #1 — núcleo jugable | https://github.com/diegouth/juego2/pull/1 |
| PR #2 — créditos, pruebas y release Android | https://github.com/diegouth/juego2/pull/2 |
| PR #3 — video de demo y reporte | https://github.com/diegouth/juego2/pull/3 |
| PR #4 — README y enlaces | https://github.com/diegouth/juego2/pull/4 |
| PR #5 — puntaje, manual y pruebas de beta | https://github.com/diegouth/juego2/pull/5 |
| Manual de usuario | [`docs/MANUAL.md`](MANUAL.md) |
| Reporte de pruebas de beta | [`docs/PRUEBAS-BETA.md`](PRUEBAS-BETA.md) |
| Video general del prototipo | [`docs/video/demo.mp4`](video/demo.mp4) |
| Video individual jugando | [`docs/video/individual-diego.mp4`](video/individual-diego.mp4) |
| Capturas | [`docs/screenshots/`](screenshots) |

## 2. Requisitos de la actividad → dónde se cumplen

| Requisito | Evidencia |
|---|---|
| **Eventos** | Señales de Godot: `hearts_changed`, `key_changed`, `score_changed` (`scripts/game_state.gd`), `body_entered` en llave, moneda, pincho, enemigo y puerta |
| **Comportamientos** | `Player` (movimiento 8 direcciones, invulnerabilidad), `Enemy` (patrulla y rebote en muros), `Door` (abierta/cerrada según la llave), `Coin` (giro y recogida) |
| **Transacciones** | Recoger moneda → `GameState.collect_coin(10)` → suma puntaje → emite `score_changed` → HUD redibuja. Llave (+50) y puerta (+100) usan el mismo canal |
| **Acciones** | Menú: Jugar, Créditos, Salir. Fin de partida: Reintentar, Menú. Créditos: volver |
| **Colisiones** | Muros con `StaticBody2D`; pinchos, enemigos, llave, monedas y puerta con `Area2D` + `CollisionShape2D` |
| **Puntaje** | Marcador `PUNTOS 0000` en la HUD, récord persistente en `user://record.cfg`, puntaje final en la pantalla de fin |
| **Oportunidades / intentos (vidas)** | 3 corazones (`MAX_HEARTS`), daño de 1 por golpe, 1,2 s de invulnerabilidad, reaparición al inicio y *Game Over* a los 0 corazones |
| **Videojuego en versión beta** | Release `v0.3-beta`: `llave-del-laberinto-v0.3-beta.apk` (Android) y `build/web/` (navegador) |
| **Manual de usuario o demo** | [`docs/MANUAL.md`](MANUAL.md) (manual completo) y [`docs/video/demo.mp4`](video/demo.mp4) (demo) |
| **Reporte de pruebas de beta** | [`docs/PRUEBAS-BETA.md`](PRUEBAS-BETA.md) (20 casos, 15 automáticos, 6 defectos con su corrección) |
| **Captura de pantalla del avance** | `docs/screenshots/02-nivel-1.png` (mecánicas + puntaje) |
| **PR revisado por integrante, con tarjetas y código** | PRs #1 a #5: cada uno con descripción, archivos tocados y revisión + merge `--no-ff` |
| **Video o participación en clase** | [`docs/video/demo.mp4`](video/demo.mp4) y [`docs/video/individual-diego.mp4`](video/individual-diego.mp4) |

## 3. Cómo probar la beta (3 minutos)

1. Descarga el APK desde el Release `v0.3-beta` e instálalo en el teléfono
   (permitir "origen desconocido").
2. Abre **Llave del Laberinto** → *Jugar*.
3. Recoge la llave, esquiva pinchos y enemigos, y cruza la puerta dos veces.
4. Mira el marcador: cada moneda suma 10, la llave 50 y la puerta 100.
5. Deja que te quiten los 3 corazones para ver *Game Over*, el puntaje y el récord.

En PC, sin instalar nada compilado:

```bash
git clone https://github.com/diegouth/juego2.git && cd juego2
godot --path .            # con Godot 4.7.x
./tools/test.sh           # 15 comprobaciones automáticas
```

## 4. Diseño orientado a objetos (resumen)

| Clase / script | Responsabilidad | Relación |
|---|---|---|
| `GameState` (autoload) | Estado de la partida: corazones, llave, nivel, puntaje, récord, audio y mapa de teclas | Único punto de verdad; el resto de scripts sólo consultan y emiten/escuchan señales |
| `Player` (`CharacterBody2D`) | Movimiento, colisión con muros, daño e invulnerabilidad | Consume `GameState.damage()` |
| `Coin`, `KeyItem`, `Spike`, `Enemy` (`Area2D`) | Coleccionables y obstáculos; cada uno define su propio `_draw` y su reacción a `body_entered` | Todas reciben al `Player` y delegan el efecto en `GameState` |
| `Door` (`Area2D`) | Puerta que se abre con la llave y pide el cambio de nivel | Llama a `Game.complete_level()` |
| `Game` (`Node2D`) | Construye el nivel desde un mapa ASCII y monta la HUD | Compone todas las clases anteriores |
| `UiKit` (`RefCounted`) | Fábrica de etiquetas, botones e iconos dibujados con `_draw` | Reutilizado por menú, HUD, fin y créditos |

Herencia donde aporta (`CharacterBody2D`, `Area2D`, `Control`), composición para
el resto y **señales** como mecanismo de eventos: ningún objeto de la escena
modifica la HUD directamente.

## 5. Limitaciones conocidas

- Dos niveles (el diseño de niveles finales queda para la siguiente entrega).
- Sin guardado de partida a medias (sólo el récord).
- D-05 (joystick sobre la barra superior) y D-06 (enemigos atascados) abiertos:
  ver [`docs/PRUEBAS-BETA.md`](PRUEBAS-BETA.md).
