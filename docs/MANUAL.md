# 📖 Manual de usuario — *La Llave del Laberinto*

Versión del documento: `v0.3-beta` · Motor: Godot 4.7.2 · Idioma: español

## 1. Qué es el juego

*La Llave del Laberinto* es un juego 2D de laberintos en vista cenital. Cada
nivel es un mapa cerrado con pinchos, enemigos que patrullan y monedas.
El objetivo es siempre el mismo: **recoger la llave, esquivar los obstáculos y
cruzar la puerta** para pasar al siguiente laberinto. Tienes **3 corazones**;
si los pierdes todos, la partida termina en *Game Over*.

## 2. Requisitos

| Plataforma | Requisitos |
|---|---|
| Android | Android 6.0 (API 23) o superior, `arm64-v8a` o `x86_64`, ~60 MB libres |
| PC (desde el código) | Godot 4.7.x, Linux/Windows/macOS, 4 GB de RAM |
| PC (versión web) | Navegador con WebGL 2 (Chrome, Firefox, Edge actuales) |

## 3. Instalación

### 3.1 Android (formato entregado)

1. Descarga `llave-del-laberinto-v0.2-alpha.apk` desde la sección **Releases**
   del repositorio.
2. Abre el archivo en el teléfono. Android pedirá permitir *"instalar apps de
   origen desconocido"*: es normal, el APK está firmado con clave de depuración.
3. Toca **Instalar** y abre **Llave del Laberinto**.
4. Con el teléfono conectado por USB también puedes usar:
   `adb install -r build/llave-del-laberinto-v0.2-alpha.apk`.

### 3.2 PC desde el código

```bash
git clone https://github.com/diegouth/juego2.git
cd juego2
godot --path .        # o abre project.godot desde el editor de Godot 4.x
```

## 4. Controles

| Acción | Teclado | Táctil (Android) |
|---|---|---|
| Mover al personaje | Flechas o `W` `A` `S` `D` | Arrastra el dedo desde cualquier punto: aparece un joystick virtual |
| Elegir opción del menú | Flechas + `Enter` | Toca el botón |
| Volver al menú desde el juego | `Esc` | Botón *Menú* en la pantalla de fin |

El personaje se mueve en 8 direcciones y no atraviesa muros.

## 5. Pantallas

| Pantalla | Qué encuentras |
|---|---|
| **Menú principal** | *Jugar*, *Créditos*, *Salir*. Muestra el récord guardado. |
| **Juego** | El laberinto, la HUD con corazones, marcador de puntos, icono de llave, número de nivel y avisos de texto. |
| **Fin de partida** | *¡Escapaste!* o *Game Over*, puntaje final, récord y botones *Reintentar* / *Menú*. |
| **Créditos** | Atribución de motor, fuente, arte y audio, con sus licencias. |

## 6. Reglas y puntaje

| Elemento | Efecto | Puntos |
|---|---|---|
| Moneda (círculo dorado) | Se recoge al tocarla y desaparece | **+10** |
| Llave | Se guarda; la puerta se abre | **+50** |
| Puerta cruzada con la llave | Avanza de nivel | **+100** |
| Pincho o enemigo | Pierdes 1 corazón (invulnerabilidad de 1,2 s) | — |
| Sin corazones | *Game Over* | — |

- El marcador arranca en `0000` en cada partida y se muestra arriba a la
  izquierda de la HUD.
- El **récord** se guarda en `user://record.cfg` (en Android, dentro del
  almacenamiento privado de la app) y se compara en la pantalla de fin.
- Puntaje máximo de una partida completa con los dos niveles actuales:
  `8 monedas × 10 + 50 llave + 100 puerta` por nivel = **460 puntos**.

## 7. Cómo se gana y cómo se pierde

- **Ganas** cuando cruzas la puerta del último nivel con la llave en la mano.
- **Pierdes** cuando el contador de corazones llega a 0; el personaje reaparece
  al inicio del nivel tras cada golpe, pero los corazones no se recuperan.
- La puerta permanece cerrada (y avisa con un texto) si intentas cruzarla sin
  la llave.

## 8. Problemas frecuentes

| Síntoma | Causa y solución |
|---|---|
| Android: "aplicación no instalada" | Ya existe otra versión con la misma firma; desinstala la anterior o instala con `adb install -r` |
| No se oye la música | El APK usa audio sintetizado; sube el volumen multimedia. En escritorio prueba `--audio-driver Dummy` sólo para depurar |
| El joystick táctil no responde | Arrastra desde una zona libre de la pantalla (no sobre un botón) |
| Va lento en el emulador | Activa aceleración por hardware en el AVD |
| No aparece la opción de instalar | Habilita *Fuentes desconocidas* para la app de archivos en Ajustes → Seguridad |

## 9. Créditos de los assets

| Asset | Origen | Licencia |
|---|---|---|
| Motor | Godot Engine 4.7.2 | MIT |
| Fuente | Press Start 2P (CodeMan38) | SIL Open Font License 1.1 |
| Gráficos | Dibujados con primitivas en GDScript (`scripts/ui_kit.gd`) | CC0 |
| Audio | Sintetizado con `tools/gen_audio.py` | CC0 |

El detalle completo está en la pantalla **Créditos** del juego y en
[`README.md`](../README.md).
