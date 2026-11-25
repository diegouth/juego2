#!/usr/bin/env python3
"""Genera música y efectos de sonido del juego con síntesis básica
(onda cuadrada, triangular, ruido) y los convierte a OGG con ffmpeg.

Salida: assets/audio/{pickup,damage,door,gameover,music}.ogg
Uso:    python3 tools/gen_audio.py
Licencia del audio generado: CC0 1.0 (autoría del equipo).
"""
import math
import os
import random
import struct
import subprocess
import wave

SR = 22050
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "audio")


def buf(seconds):
    return [0.0] * int(seconds * SR)


def hz(midi):
    return 440.0 * 2.0 ** ((midi - 69) / 12.0)


def tone(b, start, freq, dur, vol=0.25, kind="sq", duty=0.5, decay=6.0):
    n0, n = int(start * SR), int(dur * SR)
    for i in range(n):
        k = n0 + i
        if k >= len(b):
            break
        t = i / SR
        env = math.exp(-decay * t)
        ph = (freq * t) % 1.0
        if kind == "sq":
            s = 1.0 if ph < duty else -1.0
        elif kind == "tri":
            s = 4.0 * abs(ph - 0.5) - 1.0
        elif kind == "sine":
            s = math.sin(2.0 * math.pi * ph)
        else:
            s = 0.0
        b[k] += vol * env * s


def noise(b, start, dur, vol=0.2, decay=14.0, seed=1):
    rnd = random.Random(seed)
    n0, n = int(start * SR), int(dur * SR)
    for i in range(n):
        k = n0 + i
        if k >= len(b):
            break
        b[k] += vol * math.exp(-decay * (i / SR)) * rnd.uniform(-1.0, 1.0)


def save(name, b, peak=0.85):
    scale = peak / max(1e-9, max(abs(v) for v in b))
    frames = b"".join(struct.pack("<h", int(max(-1.0, min(1.0, v * scale)) * 32767)) for v in b)
    wav = os.path.join(OUT, name + ".wav")
    with wave.open(wav, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(frames)
    subprocess.run(
        ["ffmpeg", "-y", "-loglevel", "error", "-i", wav, "-c:a", "libvorbis", "-q:a", "4",
         os.path.join(OUT, name + ".ogg")],
        check=True,
    )
    os.remove(wav)
    print("  audio ->", name + ".ogg")


def sfx_pickup():
    b = buf(0.30)
    tone(b, 0.00, hz(84), 0.09, 0.30, "sq", 0.5, 8)
    tone(b, 0.07, hz(91), 0.16, 0.28, "sq", 0.25, 7)
    return b


def sfx_damage():
    b = buf(0.42)
    tone(b, 0.0, hz(48), 0.30, 0.35, "sq", 0.5, 5)
    tone(b, 0.0, hz(47), 0.30, 0.20, "tri", 0.5, 4)
    noise(b, 0.0, 0.18, 0.30, 18.0, seed=7)
    return b


def sfx_door():
    b = buf(0.70)
    tone(b, 0.0, hz(40), 0.22, 0.35, "tri", 0.5, 6)
    for i, m in enumerate([72, 76, 79, 84]):
        tone(b, 0.16 + i * 0.10, hz(m), 0.16, 0.22, "sq", 0.25, 9)
    return b


def sfx_gameover():
    b = buf(1.30)
    for i, m in enumerate([67, 63, 60, 55]):
        tone(b, i * 0.22, hz(m), 0.42, 0.30, "sq", 0.5, 3.2)
    return b


def music_loop():
    """4 compases de 16 corchetes (8 s) en La menor: Am - F - C - G."""
    step = 0.125
    bars = 4
    b = buf(step * 16 * bars)
    chords = [(57, [69, 72, 76]), (53, [65, 69, 72]), (48, [60, 64, 67]), (55, [67, 71, 74])]
    for bar, (root, chord) in enumerate(chords):
        base = bar * 16 * step
        # Bajos en negras.
        for beat in range(4):
            tone(b, base + beat * 4 * step, hz(root - 12), 0.22, 0.30, "tri", 0.5, 3.0)
        # Arpegio en corcheas con silencios para que respire.
        order = [0, 1, 2, 1, 0, 2, 1, 2, 0, 1, 2, 1, 2, 1, 0, 1]
        for i, idx in enumerate(order):
            if i % 4 == 3:
                continue
            tone(b, base + i * step, hz(chord[idx]), step * 0.95, 0.13, "sq", 0.25, 9)
        # Chispazo de ruido en los contratiempos.
        for i in range(0, 16, 4):
            noise(b, base + i * step + step * 0.5, 0.05, 0.07, 40.0, seed=bar * 16 + i)
    return b


def main():
    os.makedirs(OUT, exist_ok=True)
    print("Generando audio en", OUT)
    save("pickup", sfx_pickup())
    save("damage", sfx_damage())
    save("door", sfx_door())
    save("gameover", sfx_gameover())
    save("music", music_loop(), peak=0.7)


if __name__ == "__main__":
    main()
