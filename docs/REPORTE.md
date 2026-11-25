# Reporte final — La Llave del Laberinto `v0.2-alpha`

**Materia:** Desarrollo de Videojuegos
**Integrante:** Diego Alejandro Franco Partida
**Fecha:** 25 / 11 / 2026
**Motor:** Godot 4.7.2 · **Lenguaje:** GDScript
**Formato entregado:** APK para Android (`.apk`, firmado, instalable)

---

## 1. Enlaces

| Elemento | Enlace |
|---|---|
| Repositorio | `https://github.com/diegouth/juego2` |
| Release `v0.2-alpha` con el APK | `https://github.com/diegouth/juego2/releases/tag/v0.2-alpha` |
| PR #1 — núcleo jugable | `https://github.com/diegouth/juego2/pull/1` |
| PR #2 — créditos, pruebas y release | `https://github.com/diegouth/juego2/pull/2` |
| Video general del prototipo | `docs/video/demo.mp4` (en el repo, 3:45) |
| Video individual jugando | `<enlace>` |

## 2. Qué se entregó

| Requisito | Dónde se cumple |
|---|---|
| Menú principal | `scenes/main_menu.tscn` → Jugar / Créditos / Salir |
| Pantalla de fin y reinicio | `scenes/end_screen.tscn` → Reintentar (vuelve al nivel 1) / Menú |
| Movimiento del personaje | `scripts/player.gd` (8 direcciones, teclado y táctil) |
| Recolección de llave | `scripts/key_item.gd` + `GameState.collect_key()` |
| Puerta y cambio de escena | `scripts/door.gd` → `game.gd::complete_level()` (2 niveles) |
| Obstáculos | `scripts/spike.gd` (pinchos) y `scripts/enemy.gd` (patrullas) |
| Daño y vidas (corazones) | `GameState.damage()`, HUD con 3 corazones, invulnerabilidad de 1,2 s |
| Créditos con atribución | `scenes/credits.tscn` (motor, fuente OFL, arte y audio CC0) |
| ≥2 PRs fusionados | PR #1 y PR #2 (ramas `feature/nucleo-jugable` y `feature/creditos-y-release`) |
| Compilación a ejecutable | `tools/build_apk.sh` → `build/llave-del-laberinto-v0.2-alpha.apk` |
| Release con adjunto | tag `v0.2-alpha` + APK adjunto en *Releases* |
| README con capturas e instrucciones | `README.md` (5 capturas en `docs/screenshots/`) |
| Video general e individual | `docs/video/demo.mp4` y el clip individual del integrante |

## 3. Cómo probarlo

```bash
# Instalar en el teléfono (USB con depuración activada)
adb install -r build/llave-del-laberinto-v0.2-alpha.apk
# O copiar el APK al teléfono y abrirlo (permitir "origen desconocido").
```

En el juego: flechas/WASD o arrastrar el dedo (joystick virtual). Recoge la
llave, evita pinchos y enemigos, cruza la puerta, `Esc` vuelve al menú.

## 4. Verificación técnica

- `./tools/test.sh` → 11 comprobaciones automáticas en headless: instanciación
  del nivel, corazones iniciales, presencia de llave/puerta/pinchos, recogida de
  la llave, daño del pincho (3→2), reaparición en el inicio, consumo de la llave
  y avance de nivel. Resultado: **11/11 PASS**.
- Conectividad de niveles verificada por BFS: nivel 1 (inicio→llave 40 pasos,
  llave→puerta 17), nivel 2 (20 y 27). Ningún nivel es inalcanzable.
- APK verificado con `apksigner verify` (firma v2/v3 válida, paquete
  `com.equipo.llavedellaberinto`, `versionName 0.2-alpha`).

## 5. Reparto de trabajo (equipo de 1)

| Integrante | Aportaciones | PRs |
|---|---|---|
| Diego Alejandro Franco Partida | Motor, jugador, niveles, llave/puerta, obstáculos, vidas, HUD, menú, fin de partida, créditos, audio, pruebas, export Android, README y video | #1, #2, #3 |

## 6. Notas y trabajo futuro

- Añadir más niveles y un tercer tipo de obstáculo (proyectiles).
- Guardar récord de tiempo por nivel y mención en la pantalla de fin.
- Publicar también la versión web (export HTML5) para probar sin instalar.
