#!/usr/bin/env python3
"""Genera docs/Reporte-Actividad-2.docx (portafolio de evidencias).

Uso:  /tmp/docxenv/bin/python tools/make_report_docx.py
Requiere python-docx y las capturas en docs/screenshots/.
"""
from pathlib import Path

from docx import Document
from docx.enum.section import WD_SECTION
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Pt, RGBColor

ROOT = Path(__file__).resolve().parent.parent
SHOTS = ROOT / "docs" / "screenshots"
OUT = ROOT / "docs" / "Reporte-Actividad-2.docx"

TOC_ORDER = []          # titulos en el orden en que se crean
TOC_FILE = Path("/tmp/toc_pages.json")

AZUL = RGBColor(0x1B, 0x3A, 0x5C)
GRIS = RGBColor(0x44, 0x4A, 0x52)
VERDE = RGBColor(0x1F, 0x6B, 0x3A)

# ---------------------------------------------------------------- utilidades

def shade(cell, color):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = OxmlElement("w:shd")
    shd.set(qn("w:val"), "clear")
    shd.set(qn("w:color"), "auto")
    shd.set(qn("w:fill"), color)
    tcPr.append(shd)


def shade_par(par, color):
    pPr = par._p.get_or_add_pPr()
    shd = OxmlElement("w:shd")
    shd.set(qn("w:val"), "clear")
    shd.set(qn("w:color"), "auto")
    shd.set(qn("w:fill"), color)
    pPr.append(shd)


def borders(table, color="C8CDD4", size=6):
    tblPr = table._tbl.tblPr
    b = OxmlElement("w:tblBorders")
    for edge in ("top", "left", "bottom", "right", "insideH", "insideV"):
        el = OxmlElement(f"w:{edge}")
        el.set(qn("w:val"), "single")
        el.set(qn("w:sz"), str(size))
        el.set(qn("w:space"), "0")
        el.set(qn("w:color"), color)
        b.append(el)
    tblPr.append(b)


def cell_text(cell, text, bold=False, size=9.5, color=None, mono=False):
    cell.text = ""
    par = cell.paragraphs[0]
    par.paragraph_format.space_before = Pt(1)
    par.paragraph_format.space_after = Pt(1)
    run = par.add_run(text)
    run.bold = bold
    run.font.size = Pt(size)
    if color:
        run.font.color.rgb = color
    if mono:
        run.font.name = "Consolas"


def add_table(doc, headers, rows, widths, header_bg="1B3A5C", zebra=True, spacer=True):
    table = doc.add_table(rows=1, cols=len(headers))
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False
    borders(table)
    for i, h in enumerate(headers):
        c = table.rows[0].cells[i]
        cell_text(c, h, bold=True, size=9.5, color=RGBColor(0xFF, 0xFF, 0xFF))
        shade(c, header_bg)
    for r, row in enumerate(rows):
        cells = table.add_row().cells
        for i, val in enumerate(row):
            cell_text(cells[i], str(val), size=9.5, color=GRIS)
            if zebra and r % 2 == 1:
                shade(cells[i], "F1F4F8")
    # anchos fijos: sin tblLayout fixed, LibreOffice y Word reparten a su gusto
    tblPr = table._tbl.tblPr
    layout = OxmlElement("w:tblLayout")
    layout.set(qn("w:type"), "fixed")
    tblPr.append(layout)
    tblW = OxmlElement("w:tblW")
    tblW.set(qn("w:type"), "dxa")
    tblW.set(qn("w:w"), str(int(sum(widths) * 567)))
    tblPr.append(tblW)
    for i, w in enumerate(widths):
        table.columns[i].width = Cm(w)
    for row in table.rows:
        for i, w in enumerate(widths):
            row.cells[i].width = Cm(w)
    if spacer:
        doc.add_paragraph().paragraph_format.space_after = Pt(2)
    return table


def h1(doc, text):
    TOC_ORDER.append((1, text))
    p = doc.add_heading(text, level=1)
    for r in p.runs:
        r.font.color.rgb = AZUL
        r.font.name = "Calibri"
        r.font.size = Pt(15)
    p.paragraph_format.space_before = Pt(14)
    p.paragraph_format.space_after = Pt(6)
    return p


def h2(doc, text):
    TOC_ORDER.append((2, text))
    p = doc.add_heading(text, level=2)
    for r in p.runs:
        r.font.color.rgb = AZUL
        r.font.size = Pt(12)
    p.paragraph_format.space_before = Pt(10)
    p.paragraph_format.space_after = Pt(4)
    return p


def body(doc, text, size=10.5, space=4, align=None, italic=False):
    p = doc.add_paragraph()
    run = p.add_run(text)
    run.font.size = Pt(size)
    run.italic = italic
    run.font.color.rgb = RGBColor(0x22, 0x26, 0x2B)
    if align:
        p.alignment = align
    p.paragraph_format.space_after = Pt(space)
    return p


def bullets(doc, items, size=10.5):
    for it in items:
        p = doc.add_paragraph(style="List Bullet")
        run = p.add_run(it)
        run.font.size = Pt(size)
        run.font.color.rgb = RGBColor(0x22, 0x26, 0x2B)
        p.paragraph_format.space_after = Pt(2)


def code_block(doc, lines):
    for line in lines:
        p = doc.add_paragraph()
        run = p.add_run(line if line else " ")
        run.font.name = "Consolas"
        run.font.size = Pt(8.5)
        run.font.color.rgb = RGBColor(0x1A, 0x1A, 0x1A)
        p.paragraph_format.space_after = Pt(0)
        p.paragraph_format.space_before = Pt(0)
        shade_par(p, "F2F4F7")


def field(par, instr, placeholder=None):
    run = par.add_run()
    begin = OxmlElement("w:fldChar")
    begin.set(qn("w:fldCharType"), "begin")
    it = OxmlElement("w:instrText")
    it.set(qn("xml:space"), "preserve")
    it.text = instr
    sep = OxmlElement("w:fldChar")
    sep.set(qn("w:fldCharType"), "separate")
    end = OxmlElement("w:fldChar")
    end.set(qn("w:fldCharType"), "end")
    for el in (begin, it, sep):
        run._r.append(el)
    if placeholder:
        t = OxmlElement("w:t")
        t.text = placeholder
        run._r.append(t)
    run._r.append(end)


def add_toc(doc, pages):
    """Indice con puntos guia: titulos de h1/h2 y el numero de pagina de la pasada previa."""
    from docx.enum.text import WD_TAB_ALIGNMENT, WD_TAB_LEADER

    if not pages:
        body(doc, "El índice se numera al generar el documento con tools/make_report_docx.py.",
             italic=True, size=9)
        return
    for nivel, titulo in pages.get("_orden", []):
        if nivel == 1 and titulo.strip().lower() == "contenido":
            continue
        par = doc.add_paragraph()
        pf = par.paragraph_format
        pf.space_before = Pt(6 if nivel == 1 else 0)
        pf.space_after = Pt(1)
        pf.tab_stops.add_tab_stop(Cm(16.2), WD_TAB_ALIGNMENT.RIGHT, WD_TAB_LEADER.DOTS)
        if nivel == 2:
            pf.left_indent = Cm(0.8)
        run = par.add_run(titulo)
        run.bold = nivel == 1
        run.font.size = Pt(10.5 if nivel == 1 else 10)
        run.font.color.rgb = AZUL if nivel == 1 else GRIS
        run2 = par.add_run("\t" + str(pages.get(titulo, "")))
        run2.bold = nivel == 1
        run2.font.size = Pt(10.5 if nivel == 1 else 10)
        run2.font.color.rgb = AZUL if nivel == 1 else GRIS


def picture(doc, name, caption, width=15.2):
    path = SHOTS / name
    if not path.exists():
        body(doc, f"[falta la captura {name}]", italic=True)
        return
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(2)
    p.add_run().add_picture(str(path), width=Cm(width))
    cap = doc.add_paragraph()
    cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = cap.add_run(caption)
    r.font.size = Pt(8.5)
    r.italic = True
    r.font.color.rgb = GRIS
    cap.paragraph_format.space_after = Pt(8)

# ---------------------------------------------------------------- documento

def build():
    doc = Document()

    st = doc.styles["Normal"]
    st.font.name = "Calibri"
    st.font.size = Pt(10.5)
    st.element.rPr.rFonts.set(qn("w:eastAsia"), "Calibri")

    sec = doc.sections[0]
    sec.page_height, sec.page_width = Cm(29.7), Cm(21.0)
    sec.top_margin, sec.bottom_margin = Cm(2.2), Cm(2.0)
    sec.left_margin, sec.right_margin = Cm(2.4), Cm(2.0)

    # encabezado y pie
    head = sec.header.paragraphs[0]
    hr = head.add_run("La Llave del Laberinto  ·  Reporte Actividad 2  ·  v0.3-beta")
    hr.font.size = Pt(8)
    hr.font.color.rgb = GRIS
    head.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    foot = sec.footer.paragraphs[0]
    foot.alignment = WD_ALIGN_PARAGRAPH.CENTER
    fr = foot.add_run("Página ")
    fr.font.size = Pt(8)
    fr.font.color.rgb = GRIS
    field(foot, "PAGE", "1")
    fr2 = foot.add_run(" de ")
    fr2.font.size = Pt(8)
    fr2.font.color.rgb = GRIS
    field(foot, "NUMPAGES", "1")

    # ---- portada
    for _ in range(2):
        doc.add_paragraph()
    t = doc.add_paragraph()
    t.alignment = WD_ALIGN_PARAGRAPH.CENTER
    rt = t.add_run("LA LLAVE\nDEL LABERINTO")
    rt.bold = True
    rt.font.size = Pt(34)
    rt.font.color.rgb = AZUL
    rt.font.name = "Consolas"
    sub = doc.add_paragraph()
    sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
    rs = sub.add_run("Portafolio de evidencias  ·  Actividad 2")
    rs.font.size = Pt(15)
    rs.font.color.rgb = GRIS
    ver = doc.add_paragraph()
    ver.alignment = WD_ALIGN_PARAGRAPH.CENTER
    rv = ver.add_run("versión 0.3-beta")
    rv.font.size = Pt(11)
    rv.italic = True
    rv.font.color.rgb = VERDE

    doc.add_paragraph()
    picture(doc, "02-nivel-1.png", "Nivel 1: llave, monedas, pinchos, enemigos y HUD con puntaje.", 12.6)

    doc.add_paragraph()
    add_table(
        doc,
        ["Dato", "Detalle"],
        [
            ["Materia", "Programación Orientada a Objetos — videojuego"],
            ["Profesor", "Ivan Rogelio Chenoweth Chenoweth"],
            ["Integrante", "Diego Alejandro Franco Partida"],
            ["Motor", "Godot 4.7.2 (renderizador Compatibility)"],
            ["Lenguaje", "GDScript (clases, herencia y señales)"],
            ["Plataformas", "Android 6.0+ (APK) y navegador web (WebGL 2)"],
            ["Repositorio", "github.com/diegouth/juego2"],
            ["Fecha", "noviembre de 2026"],
        ],
        [3.6, 11.6],
        header_bg="1B3A5C",
        spacer=False,
    )

    # ---- índice
    doc.add_page_break()
    h1(doc, "Contenido")
    pages = {}
    if TOC_FILE.exists():
        import json
        pages = json.loads(TOC_FILE.read_text())
    add_toc(doc, pages)

    # ---- 1. resumen
    doc.add_page_break()
    h1(doc, "1. Resumen del proyecto")
    body(doc, "La Llave del Laberinto es un videojuego 2D de laberintos en vista cenital "
              "construido con Godot 4.7.2 y programado en GDScript. Cada nivel es un mapa "
              "cerrado con pinchos, enemigos que patrullan y monedas; el jugador debe recoger "
              "la llave y cruzar la puerta para avanzar, con tres corazones como oportunidades. "
              "La versión de esta entrega (v0.3-beta) incluye menú, dos niveles, sistema de "
              "daño e invulnerabilidad, puntaje persistente y pantalla de créditos.")
    body(doc, "El proyecto está organizado en clases con responsabilidades únicas: el estado "
              "global de la partida vive en un autoload (`GameState`) que expone sus cambios por "
              "medio de señales; los objetos de la escena (jugador, enemigos, monedas, llave, "
              "puerta) no conocen la interfaz gráfica, sólo piden efectos al estado y la HUD se "
              "actualiza al escuchar. Esa separación es la que permitió, en esta iteración, "
              "añadir puntaje y monedas sin reescribir los niveles.")

    h2(doc, "1.1 Enlaces de entrega")
    add_table(
        doc,
        ["Elemento", "Enlace"],
        [
            ["Repositorio", "https://github.com/diegouth/juego2"],
            ["Release v0.3-beta", "https://github.com/diegouth/juego2/releases/tag/v0.3-beta"],
            ["PR #1 — núcleo jugable", "https://github.com/diegouth/juego2/pull/1"],
            ["PR #2 — créditos, pruebas y release Android", "https://github.com/diegouth/juego2/pull/2"],
            ["PR #3 — video de demo y reporte", "https://github.com/diegouth/juego2/pull/3"],
            ["PR #4 — README y enlaces", "https://github.com/diegouth/juego2/pull/4"],
            ["PR #5 — puntaje, manual y pruebas de beta", "https://github.com/diegouth/juego2/pull/5"],
            ["Manual de usuario", "docs/MANUAL.md"],
            ["Reporte de pruebas de beta", "docs/PRUEBAS-BETA.md"],
            ["Video general (demo)", "docs/video/demo.mp4"],
            ["Video individual jugando", "docs/video/individual-diego.mp4"],
        ],
        [6.4, 8.8],
    )

    # ---- 2. requisitos
    h1(doc, "2. Requisitos de la actividad y su evidencia")
    add_table(
        doc,
        ["Requisito", "Dónde se cumple en la beta"],
        [
            ["Eventos", "Señales de Godot: hearts_changed, key_changed y score_changed en "
                        "scripts/game_state.gd; body_entered en llave, moneda, pincho, enemigo y puerta."],
            ["Comportamientos", "Player (movimiento en 8 direcciones, daño e invulnerabilidad), "
                                "Enemy (patrulla y rebote en muros), Door (abierta sólo con llave), "
                                "Coin (giro y recogida)."],
            ["Transacciones", "Recoger moneda → GameState.collect_coin(10) → suma puntaje → emite "
                              "score_changed → la HUD redibuja el marcador. Llave (+50) y puerta (+100) "
                              "usan el mismo canal."],
            ["Acciones", "Menú: Jugar, Créditos y Salir. Fin de partida: Reintentar y Menú. "
                         "Créditos: volver al menú."],
            ["Colisiones", "Muros con StaticBody2D; pinchos, enemigos, llave, monedas y puerta con "
                           "Area2D + CollisionShape2D."],
            ["Puntaje", "Marcador PUNTOS 0000 en la HUD, récord persistente en user://record.cfg y "
                        "puntaje final en la pantalla de fin de partida."],
            ["Oportunidades / intentos", "Tres corazones (MAX_HEARTS), un corazón por golpe, 1,2 s de "
                                        "invulnerabilidad, reaparición al inicio del nivel y Game Over "
                                        "al llegar a cero."],
            ["Videojuego en versión beta", "Release v0.3-beta con APK de Android y versión web exportada."],
            ["Manual de usuario o demo", "docs/MANUAL.md (manual completo, sección 6 de este reporte) y "
                                        "docs/video/demo.mp4."],
            ["Reporte de pruebas de beta", "docs/PRUEBAS-BETA.md y sección 7 de este documento: 20 casos, "
                                          "15 comprobaciones automáticas y 6 defectos con su corrección."],
            ["Captura de pantalla del avance", "Sección 5 de este documento."],
            ["PR revisado por integrante", "Cinco PRs con descripción, archivos tocados y revisión antes "
                                          "del merge --no-ff."],
            ["Video o participación en clase", "docs/video/demo.mp4 (recorrido completo) y "
                                              "docs/video/individual-diego.mp4 (partida del integrante)."],
        ],
        [4.3, 10.9],
    )

    # ---- 3. capturas
    doc.add_page_break()
    h1(doc, "3. Capturas de pantalla")
    body(doc, "Todas las capturas se generan automáticamente con tests/shots.gd, que renderiza cada "
              "escena en una SubViewport a 640×360 y guarda el PNG; así el material del reporte no "
              "depende de capturas manuales.")
    picture(doc, "01-menu.png", "Menú principal: Jugar, Créditos, Salir y el récord de la partida.")
    picture(doc, "02-nivel-1.png", "Nivel 1: monedas, llave, pinchos y enemigos.")
    doc.add_page_break()
    picture(doc, "03-nivel-2.png", "Nivel 2, con la llave ya recogida y la puerta abierta.")
    picture(doc, "04-game-over.png", "Pantalla de fin de partida con puntaje, récord y opciones.")
    picture(doc, "05-creditos.png", "Créditos y licencias de los assets utilizados.")

    # ---- 4. cómo probar
    doc.add_page_break()
    h1(doc, "4. Cómo probar la beta")
    h2(doc, "4.1 Android")
    bullets(doc, [
        "Descargar llave-del-laberinto-v0.3-beta.apk desde la sección Releases.",
        "Permitir la instalación de origen desconocido cuando Android lo solicite.",
        "Abrir la aplicación, pulsar Jugar y arrastrar el dedo en pantalla para mover al personaje.",
    ])
    h2(doc, "4.2 Navegador")
    bullets(doc, [
        "Descargar llave-del-laberinto-v0.3-beta-web.zip y descomprimirlo.",
        "Servir la carpeta con python3 -m http.server 8060 (WebGL necesita un servidor; file:// no basta).",
        "Abrir http://localhost:8060 en Chrome, Firefox o Edge actuales.",
    ])
    h2(doc, "4.3 Desde el código")
    code_block(doc, [
        "git clone https://github.com/diegouth/juego2.git",
        "cd juego2",
        "godot --path .          # con Godot 4.7.x",
        "./tools/test.sh         # 15 comprobaciones automáticas",
    ])

    # ---- 5. diseño OO
    doc.add_page_break()
    h1(doc, "5. Diseño orientado a objetos")
    add_table(
        doc,
        ["Clase / script", "Responsabilidad", "Relación"],
        [
            ["GameState (autoload)", "Estado de la partida: corazones, llave, nivel, puntaje, récord, "
                                     "audio y mapa de teclas.",
             "Único punto de verdad; el resto consulta y escucha sus señales."],
            ["Player (CharacterBody2D)", "Movimiento, colisión con muros, daño e invulnerabilidad.",
             "Consume GameState.damage()."],
            ["Coin, KeyItem, Spike, Enemy (Area2D)", "Coleccionables y obstáculos; cada uno define su "
                                                     "_draw y su reacción a body_entered.",
             "Reciben al Player y delegan el efecto en GameState."],
            ["Door (Area2D)", "Puerta que se abre con la llave y pide el cambio de nivel.",
             "Llama a Game.complete_level()."],
            ["Game (Node2D)", "Construye el nivel desde un mapa ASCII y monta la HUD.",
             "Compone todas las clases anteriores."],
            ["UiKit (RefCounted)", "Fábrica de etiquetas, botones e iconos dibujados con _draw.",
             "Reutilizado por menú, HUD, fin de partida y créditos."],
        ],
        [4.4, 5.6, 5.2],
    )
    body(doc, "Se usa herencia donde aporta (CharacterBody2D, Area2D, Control), composición para el "
              "resto y señales como mecanismo de eventos: ningún objeto de la escena modifica la HUD "
              "directamente. Añadir las monedas consistió en crear una clase nueva y llamar a "
              "GameState.collect_coin(); no hubo que tocar el jugador ni la puerta.")

    # ---- 6. manual
    doc.add_page_break()
    h1(doc, "6. Manual de usuario (resumen)")
    body(doc, "El manual completo está en docs/MANUAL.md; aquí se recogen las secciones esenciales.")
    h2(doc, "6.1 Controles")
    add_table(
        doc,
        ["Acción", "Teclado", "Táctil (Android)"],
        [
            ["Mover al personaje", "Flechas o W A S D", "Arrastrar el dedo: joystick virtual"],
            ["Elegir opción del menú", "Flechas + Enter", "Tocar el botón"],
            ["Volver al menú", "Esc", "Botón Menú en la pantalla de fin"],
        ],
        [5.0, 5.0, 5.2],
    )
    h2(doc, "6.2 Pantallas")
    add_table(
        doc,
        ["Pantalla", "Contenido"],
        [
            ["Menú principal", "Jugar, Créditos, Salir y récord guardado."],
            ["Juego", "Laberinto, corazones, marcador de puntos, icono de llave, número de nivel y avisos."],
            ["Fin de partida", "¡Escapaste! o Game Over, puntaje final, récord, Reintentar y Menú."],
            ["Créditos", "Atribución de motor, fuente, arte y audio con sus licencias."],
        ],
        [4.2, 11.0],
    )
    h2(doc, "6.3 Reglas y puntaje")
    add_table(
        doc,
        ["Elemento", "Efecto", "Puntos"],
        [
            ["Moneda", "Se recoge al tocarla y desaparece", "+10"],
            ["Llave", "Se guarda y abre la puerta", "+50"],
            ["Puerta con llave", "Avanza al siguiente nivel", "+100"],
            ["Pincho o enemigo", "Pierde un corazón (invulnerabilidad de 1,2 s)", "—"],
            ["Sin corazones", "Game Over", "—"],
        ],
        [3.6, 9.8, 1.8],
    )
    body(doc, "El récord se guarda en user://record.cfg y se muestra en el menú y en la pantalla de "
              "fin de partida. El puntaje máximo de una partida completa con los dos niveles actuales "
              "es de 460 puntos (8 monedas, llave y puerta por nivel).", size=10)

    # ---- 7. pruebas
    doc.add_page_break()
    h1(doc, "7. Reporte de pruebas de la beta")
    body(doc, "Ambiente: Arch Linux (kernel 7.3.5), AMD Ryzen con Radeon RX 5600 XT (Mesa 26.3, "
              "OpenGL 4.6), Godot 4.7.2; APK probado en Android 6.0+ (arm64-v8a). Estrategia: pruebas "
              "automáticas de mecánicas (tests/e2e.gd), verificación de alcanzabilidad de cada mapa con "
              "BFS, pruebas manuales de juego y renderizado automático de pantallas.")
    h2(doc, "7.1 Casos de prueba")
    casos = [
        ["CP-01", "Arrancar el juego", "Menú con JUGAR/CRÉDITOS/SALIR y récord", "Correcto", "Pasa"],
        ["CP-02", "Pulsar Jugar", "3 corazones, 0 puntos, nivel 1", "Correcto", "Pasa"],
        ["CP-03", "Movimiento WASD y flechas", "8 direcciones, sin atravesar muros", "Correcto", "Pasa"],
        ["CP-04", "Tocar la llave", "Se guarda y suma 50", "Marcador 0050", "Pasa"],
        ["CP-05", "Tocar una moneda", "Desaparece y suma 10", "De 50 a 60", "Pasa"],
        ["CP-06", "Coleccionables del nivel 1", "8 monedas, 1 llave, 1 puerta", "8 / 1 / 1", "Pasa"],
        ["CP-07", "Pisar un pincho", "Pierde 1 corazón y reaparece", "3 → 2 corazones", "Pasa"],
        ["CP-08", "Segundo golpe inmediato", "No pierde dos corazones seguidos", "Invulnerabilidad", "Pasa"],
        ["CP-09", "Sin corazones", "Game Over con puntaje y récord", "Correcto", "Pasa"],
        ["CP-10", "Puerta con llave", "Pasa al nivel 2 y suma 100", "Nivel 2, llave consumida", "Pasa"],
        ["CP-11", "Puerta sin llave", "No avanza y avisa", "Aviso NECESITAS LA LLAVE", "Pasa"],
        ["CP-12", "Última puerta", "Pantalla ¡Escapaste!", "Correcto", "Pasa"],
        ["CP-13", "Reintentar", "Nivel 1, 3 corazones, 0 puntos", "Correcto", "Pasa"],
        ["CP-14", "Récord", "Se guarda y se muestra en el menú", "user://record.cfg", "Pasa"],
        ["CP-15", "Créditos", "Atribución completa con licencias", "Correcto", "Pasa"],
        ["CP-16", "Joystick táctil", "Arrastrar mueve al personaje", "3 de 3 intentos", "Observación"],
        ["CP-17", "Esc durante el juego", "Vuelve al menú", "Correcto", "Pasa"],
        ["CP-18", "Alcanzabilidad (BFS)", "Todos los objetos accesibles", "10/10 por nivel", "Pasa"],
        ["CP-19", "Arranque en Android", "Instala y abre sin pantalla en blanco", "Correcto", "Pasa"],
        ["CP-20", "Rendimiento", "60 FPS en escritorio", "60 FPS; 30-45 en emulador", "Observación"],
    ]
    add_table(doc, ["ID", "Caso", "Resultado esperado", "Obtenido", "Estado"], casos,
              [1.3, 3.7, 4.2, 3.5, 2.6])

    h2(doc, "7.2 Salida de la suite automática")
    code_block(doc, [
        "== TEST E2E: La Llave del Laberinto ==",
        "  PASS  el nivel instancia al jugador",
        "  PASS  arranca con 3 corazones",
        "  PASS  el nivel 1 contiene una llave",
        "  PASS  el nivel 1 contiene una puerta",
        "  PASS  el nivel 1 contiene pinchos (11)",
        "  PASS  tocar la llave la recoge",
        "  PASS  la llave suma 50 puntos (50)",
        "  PASS  el nivel 1 contiene monedas (8)",
        "  PASS  la moneda suma 10 puntos (60)",
        "  PASS  la moneda recogida desaparece",
        "  PASS  el pincho quita un corazón (3 -> 2)",
        "  PASS  tras el golpe reaparece en el inicio",
        "  PASS  los corazones no bajan de 1 mientras se juega",
        "  PASS  la puerta con llave avanza al nivel 2",
        "  PASS  la llave se consume al cruzar",
        "== RESULTADO: 0 fallo(s) ==",
    ])

    h2(doc, "7.3 Defectos encontrados")
    add_table(
        doc,
        ["ID", "Defecto", "Causa", "Corrección", "Estado"],
        [
            ["D-01", "Aviso de física al cruzar la puerta", "Cambio de escena dentro de body_entered",
             "change_scene_to_file diferido", "Corregido"],
            ["D-02", "Capturas de 2×2 px", "SubViewport reutilizada y liberada",
             "Una SubViewport nueva por captura", "Corregido"],
            ["D-03", "Se contaba 1 moneda en vez de 8", "Godot renombra nodos duplicados",
             "comparar por script, no por nombre", "Corregido"],
            ["D-04", "get_tree().quit() nulo al final del test", "El cambio de escena liberaba el nodo",
             "guardar el SceneTree al inicio", "Corregido"],
            ["D-05", "El joystick ignora arrastres sobre la barra superior", "La HUD consume el evento",
             "filtrar por mouse_filter", "Abierto"],
            ["D-06", "Enemigos atascados en esquinas", "Patrulla lineal sin detección",
             "giro al chocar", "Abierto"],
        ],
        [1.3, 4.2, 3.9, 3.7, 2.3],
    )

    # ---- 8. conclusiones
    h1(doc, "8. Conclusiones y trabajo siguiente")
    body(doc, "La build v0.3-beta es apta para demostración: 15 de 15 comprobaciones automáticas en "
              "verde, 10 de 10 objetos alcanzables en cada nivel y los dos defectos de severidad media "
              "detectados durante la grabación del video ya corregidos. El sistema de puntaje se "
              "integró sin modificar el jugador ni la puerta, lo que confirma que la separación entre "
              "estado, objetos de escena e interfaz funciona como se planeó.")
    body(doc, "Queda pendiente cerrar D-05 y D-06, añadir un tercer nivel con proyectiles y publicar "
              "la versión web en el Release. Con eso el prototipo cubriría el alcance completo de la "
              "entrega final.")

    h1(doc, "9. Créditos de los assets")
    add_table(
        doc,
        ["Asset", "Origen", "Licencia"],
        [
            ["Motor", "Godot Engine 4.7.2", "MIT"],
            ["Fuente", "Press Start 2P (CodeMan38)", "SIL Open Font License 1.1"],
            ["Gráficos", "Dibujados con primitivas en scripts/ui_kit.gd", "CC0"],
            ["Audio", "Sintetizado con tools/gen_audio.py", "CC0"],
        ],
        [3.4, 8.2, 3.6],
    )
    body(doc, "Documento generado con tools/make_report_docx.py a partir de docs/REPORTE-ACT2.md, "
              "docs/MANUAL.md y docs/PRUEBAS-BETA.md.", size=9, italic=True)

    import json
    data = dict(pages) if pages else {}
    data["_orden"] = TOC_ORDER
    TOC_FILE.write_text(json.dumps(data, ensure_ascii=False))

    OUT.parent.mkdir(parents=True, exist_ok=True)
    doc.save(OUT)
    print(f"escrito {OUT} ({OUT.stat().st_size // 1024} KB)")


if __name__ == "__main__":
    build()
