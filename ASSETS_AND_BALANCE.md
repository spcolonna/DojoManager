# GRAND DOJO — F2P Balance & Progression Design

## 1. TIEMPOS A FAJA NEGRA (por perfil de jugador)

### Supuestos del modelo
- Temporada = 20 semanas, 1 sesión de entrenamiento/día (lun–vier)
- XP total requerido: 7,550 XP por estudiante
- Los 2 estudiantes iniciales progresan en paralelo
- Ambos llegan a negro en el mismo tiempo si se les dedica atención equitativa

### XP semanal estimado por estudiante

| Fuente | XP base | Frecuencia | XP/semana |
|--------|---------|------------|-----------|
| Training days completos (5) | 20 XP | diaria | 100 XP |
| Daily missions (70% completion) | 25 XP | diaria | 87 XP |
| Sparring semanal | 60 XP | 1x/semana | 60 XP |
| Torneo (50% win rate, 1.5 peleas promedio) | 38–62 XP | semanal | 75 XP |
| **Base semanal** | | | **~322 XP/semana** |

---

## 2. CUADRO COMPARATIVO DE TIEMPOS

| Perfil | XP/semana | Semanas a negro | Meses | Gasto USD estimado |
|--------|-----------|-----------------|-------|-------------------|
| **Free Casual** (no completa misiones, 30% victories) | ~160 XP | ~47 semanas | ~11 meses | $0 |
| **Free Regular** (completa misiones, 50% victories) | ~322 XP | ~23 semanas | ~6 meses | $0 |
| **Free Dedicado** (todo completado, 70% victories) | ~430 XP | ~18 semanas | ~4.5 meses | $0 |
| **Pase Mensual** (regular + pase activo) | ~472 XP | ~16 semanas | ~4 meses | ~$20 total |
| **Gasto Bajo** ($10–20 total en GM) | ~370 XP | ~20 semanas | ~5 meses | $10–20 |
| **Gasto Moderado** ($30–60) | ~580 XP | ~13 semanas | ~3 meses | $30–60 |
| **Gasto Alto** ($100+) | ~800 XP | ~9–10 semanas | ~2 meses | $100+ |

**Ratio free:premium ≈ 3:1** — estándar saludable de mercado F2P.
**El XP no se vende directamente** — el premium compra tiempo/conveniencia, no ventaja competitiva.

---

## 3. EL PROBLEMA CENTRAL DEL F2P

> "¿Cómo frenamos la progresión de los free sin que se sienta como un paywall?"

La respuesta es: **no frenamos la progresión — la ralentizamos naturalmente con el diseño.**

Grand Dojo usa tres mecanismos de soft-gate que se sienten orgánicos:

---

## 4. MECANISMOS DE SOFT-GATE (No Pay-to-Win)

### 4.1 — El Tiempo de Dojo (Daily Energy)
El dojo tiene una **capacidad de entrenamiento diario**. Los estudiantes se cansan.
- Cada estudiante tiene un máximo de energía semanal
- Entrenar en exceso genera fatiga que afecta el rendimiento en torneo
- El jugador free **siente** que tiene que elegir: entrenar duro esta semana y bajar el rendimiento el fin de semana, o dosificar
- El jugador premium **puede** pagar para recuperar stamina más rápido (GM → stamina restore)

**¿Se siente como paywall?** No. El free también puede entrenar bien — simplemente tiene que planificar más.

### 4.2 — El Mercado de Fichajes (Quality Gate)
Sin gastar dinero real:
- Los candidatos disponibles están limitados por el **nivel del dojo**
- El dojo sube de nivel con el tiempo (al subir las fajas de los estudiantes)
- El free **siempre tiene acceso a candidatos** — simplemente de menor tier
- El premium puede revelar stats ocultas (1 GM) o acceder antes a candidatos de alto tier

**¿Se siente como paywall?** No. El free puede alcanzar las mismas fajas — solo tarda más en reclutar estudiantes fuertes.

### 4.3 — El Árbol de Habilidades (Depth Gate)
Los nodos Elite requieren **faja mínima** (nivel 7 = faja marrón):
- El free llega a los nodos Elite igual — simplemente después en el tiempo
- No hay nodo del árbol que sea **solo premium**
- El premium puede pagar GM para saltear el requisito de faja, pero no el PH — los PH solo se ganan entrenando

**¿Se siente como paywall?** No. Los nodos Elite son objetivos de largo plazo para todos.

---

## 5. LA "ZANAHORIA Y EL PALO" — DISEÑO DE RETENCIÓN

### Zanahoria (recompensas frecuentes)
- **Diaria:** Misiones diarias → MD + XP (5–10 min de engagement)
- **Semanal:** Torneo → MD + XP + satisfacción competitiva
- **Por milestone:** Subir faja → evento especial, animación, mensaje narrativo
- **Por racha:** 3 victorias seguidas → bonus de XP

### Palo (fricción calculada)
- **Fatiga semanal:** no podés entrenar intenso todos los días sin consecuencias
- **Slots limitados:** con 2 estudiantes y dojo nivel 1, elegir quién compite importa
- **Curva de XP:** niveles 7–9 requieren significativamente más tiempo → los jugadores freemiun están más expuestos a la propuesta del pase en este momento

---

## 6. VENTANA DE CONVERSIÓN ÓPTIMA

La mejor ventana para que un free convierta a pago es:
- **Semanas 6–8:** el jugador ya está enganchado con los torneos y quiere progresar más rápido
- **Al llegar a faja azul/morada (niveles 5–6):** la curva de XP se vuelve notablemente más lenta
- **Después de una derrota en torneo** con un rival claramente más fuerte: el jugador está motivado a mejorar

**Estrategia de conversión:** mostrar la propuesta del Pase de Maestro de forma contextual, no intrusiva:
- No pop-ups en el menú principal
- Sí: al ver los stats de un rival que lo venció ("Entrenó con Sesión Maestra este mes")
- Sí: al bloquear un nodo Elite ("Desbloqueá este nodo ahora con 3 GM o esperá a faja marrón")

---

## 7. PROYECCIÓN DE MONETIZACIÓN (estimaciones conservadoras)

### Distribución típica de usuarios F2P por gasto:
| Segmento | % de usuarios | Gasto promedio | Ingreso por 1,000 users |
|----------|--------------|----------------|------------------------|
| Free (nunca pagan) | 60% | $0 | $0 |
| Micro-spenders | 25% | $5 | $1,250 |
| Mid-spenders | 10% | $20 | $2,000 |
| Whales | 5% | $80 | $4,000 |
| **Total** | | | **~$7,250 / 1k users** |

*Referencia de mercado: juegos F2P de gestión mobile promedian $3–10 ARPU (avg revenue per user)*

---

## 8. ASSETS — DESCRIPCIONES COMPLETAS PARA EL ARTISTA

### PALETA DE COLORES OFICIAL

```
FONDOS:
  bgDeep:     #0A0C12  ← fondo principal (casi negro, tinte pizarra)
  bgSurface:  #141824  ← cards, panels
  bgElevated: #1C2235  ← modales, dialogs elevados
  bgInput:    #242B40  ← campos de texto, sliders

ACENTO PRIMARIO — ORO/HONOR:
  goldPrimary: #C9A84C  ← CTAs, títulos importantes, highlights
  goldLight:   #E8C97A  ← texto de valor, íconos activos
  goldDark:    #8A6D2F  ← bordes sutiles

ACENTO SECUNDARIO — ROJO/COMBATE:
  redAction:   #C0392B  ← combate, daño, alertas
  redLight:    #E74C3C  ← highlights de combate

ESTADOS:
  success:     #27AE60
  warning:     #F39C12
  info:        #2E86C1
  disabled:    #3A3F52

TEXTO:
  primary:     #F0F0F0
  secondary:   #9099B0
  tertiary:    #5C6480
```

---

### LOGO — GRAND DOJO

**Archivo:** `logo_grand_dojo.png` + `.svg`
**Tamaños:** 1024×1024, 512×512, 256×256, 192×192, 72×72

**Descripción:**
Ícono cuadrado con esquinas redondeadas. El símbolo central es un **tatami de competición visto desde arriba**, representado como un cuadrado con doble borde (borde exterior grueso, borde interior delgado), con las líneas de zona del centro visibles (como el tatami real de competición). Dentro del tatami, dos **siluetas muy esquemáticas enfrentadas** — no más que cabeza + torso, suficiente para leer "dos personas en combate". Todo en dos colores: fondo `#141824` (azul-negro), detalles en `#C9A84C` (oro). El nombre "GRAND DOJO" en tipografía con reminiscencias a sellos de tinta orientales, en una línea debajo del símbolo, en oro. El logo debe funcionar en fondo oscuro y en fondo claro (preparar versión invertida).

**Mood:** austero, premium, culturalmente respetuoso. No cartoon. No fantasy. Arte marcial real.

---

### FONDO — SPLASH SCREEN

**Archivo:** `bg_splash.jpg`
**Tamaño:** 1440×3120px (ratio mobile vertical)

**Descripción:**
Fondo casi negro (`#0A0C12`). El elemento principal es una **gran silueta difuminada de un luchador en posición de guardia** — alta, ocupando el 60% del alto de la imagen, centrada horizontalmente, ligeramente desplazada hacia la derecha. La silueta es apenas más oscura que el fondo y con un sutil **glow dorado/ámbar** (`#8A6D2F`) en los bordes, como si hubiera una fuente de luz cálida detrás. En el tercio superior izquierdo, un **enso** (círculo zen de caligrafía japonesa, incompleto al ~80%) muy tenue, en oro muy apagado (30% opacidad). En el fondo, líneas horizontales muy tenues que sugieren tablones de madera de dojo. La imagen debe ser completamente oscura, misteriosa, sin color llamativo. El logo y texto son superpuestos por la app.

**Mood:** "estás a punto de comenzar algo serio". Inspiración: póster de película de artes marciales, opening de anime dark.

---

### FONDO — LOGIN SCREEN

**Archivo:** `bg_login.jpg`
**Tamaño:** 1440×3120px

**Descripción:**
Exterior de un dojo tradicional al **amanecer o atardecer** (luz cálida lateral). Vista desde afuera, levemente en ángulo, mostrando la entrada con su noren (cortina con el nombre del dojo) colgando, una escalera de piedra con musgo que sube hacia la puerta, y árboles de bambú o cerezos difuminados en el fondo. La imagen tiene un **vigneteo fuerte**: los bordes, especialmente el inferior y los laterales, se funden en negro (`#0A0C12`) para que los elementos de UI (campos de login) sean legibles sobre el fondo oscuro. El centro de la imagen es más luminoso — el dojo en sí está iluminado cálidamente. Paleta: negro, marrón oscuro, dorado suave, verde musgo. Sin saturación exagerada.

**Mood:** "el dojo te espera". El jugador está afuera, a punto de entrar. Invitación, no intimidación.

---

### FONDO — DASHBOARD / HOME

**Archivo:** `bg_dashboard.jpg`
**Tamaño:** 1440×3120px

**Descripción:**
Interior del dojo, vista desde una esquina mirando hacia adentro. El **tatami** cubre la mayor parte del suelo — verde oscuro con líneas de división visibles. A los costados, ventanas shoji (papel traslúcido en marco de madera) que dejan pasar una **luz lateral cálida y suave**, creando rayos de polvo en el aire. En la pared del fondo, una tabla vacía (para el nombre de la escuela, que la app superpone) flanqueada por dos postes de bambú. La imagen es significativamente más oscura en los bordes para que la UI sea legible. Sin figuras — el espacio debe sentirse como "el lugar del jugador", listo para llenarse de actividad.

**Mood:** tranquilidad antes de la tormenta. El dojo en silencio, esperando a los estudiantes. Pertenencia.

---

### IMÁGENES DE DOJO — CAROUSEL DE ESTILOS (8 imágenes)

Todas las imágenes del carousel siguen estas especificaciones comunes:
- **Formato:** Horizontal 16:9 (1600×900px mínimo)
- **Estilo:** Ilustración digital semi-realista. Inspiración: concept art de videojuego premium (no fotorrealismo, no cartoon). Iluminación dramática.
- **Composición:** El espacio debe leerse en un vistazo. Primer plano con elemento representativo del estilo, fondo con la atmósfera del dojo.
- **Paleta:** Cada dojo tiene su color dominante (ver tabla en sección de colores), pero todos tienen fondos oscuros con luz puntual cálida.

**C1 — Kung Fu** (`dojo_kung_fu.png`)
Interior de templo chino adaptado como dojo. Columnas de madera lacada en rojo con dragones grabados. En primer plano: un **wooden dummy (muk jong)** — el maniquí de madera del Wing Chun. Humo de incienso visible. Luz filtrándose por ventanas enrejadas. Armas tradicionales colgadas (gùn, qiang). Dominante: rojo, dorado, madera oscura.

**C2 — Karate** (`dojo_karate.png`)
Dojo japonés tradicional austero. Shomen (pared frontal) con el kanji 空手道 pintado en negro sobre blanco. Tatami beige prístino. Ventanas shoji que dejan luz fría y limpia. No hay nada superfluo. Dominante: blanco, beige, madera clara, negro.

**C3 — Taekwondo** (`dojo_taekwondo.png`)
Gimnasio moderno con identidad coreana. Suelo de vinilo bicolor (azul y rojo, mitades del Taeguk). Bolsas de patada (makiwara) y espejos. Bandera de Corea del Sur en la pared. Iluminación LED fría. Dominante: azul, rojo, blanco.

**C4 — Judo** (`dojo_judo.png`)
Tatami de competición azul. Vitrinas con trofeos al fondo. Fotos en blanco y negro de maestros legendarios enmarcadas en la pared. Luz de spot directa sobre el tatami. Dominante: azul, blanco, marcos dorados.

**C5 — Muay Thai** (`dojo_muay_thai.png`)
Gym tailandés abierto, ventiladores de techo. Ring de cuerdas en el centro con esquinas rojas. Bolsas pesadas colgando. Imagen de Buda pequeña en un altar lateral con flores frescas. Luz cálida de tarde. Dominante: rojo, madera desgastada, dorado.

**C6 — BJJ** (`dojo_bjj.png`)
Academia moderna y funcional. Tatami azul oscuro. Árbol de linaje del profesor en la pared. Trofeos de competición. Luz LED blanca. Estética contemporánea, limpia. Dominante: azul, negro, blanco.

**C7 — Boxeo** (`dojo_boxing.png`)
Gym clásico vintage. Ring con cuerdas rojas y azules. Bolsas de distinto tipo. Pósters retro de combates históricos en paredes con pintura descascarada. Piso de madera vieja. Lámparas incandescentes colgantes. Dominante: rojo, cuero marrón, madera oscura.

**C8 — MMA** (`dojo_mma.png`)
Centro moderno con octágono (cage) en el centro. Sectores diferenciados: tatami de grappling, área de bolsas para striking. Pantallas digitales en la pared. Mezclado de equipamiento (guantes de boxeo, gi). Estética industrial. Dominante: negro, gris acero, naranja.

---

### AVATARES DE ESTUDIANTES (MVP: 2 personajes)

**Especificaciones comunes:**
- PNG con transparencia, fondo recortado
- Full body: 800×1600px mínimo
- Portrait (busto): 400×400px
- Estilo: ilustración semi-realista, proporciones heroicas pero no exageradas
- Ropa: gi blanco sin cinto visible (versión base)
- Expresión: seria, determinada. No sonrisa. No elementos "kawaii"

**D1 — Zhang Wei** (`student_zhang_wei_full.png` + `student_zhang_wei_portrait.png`)
Hombre asiático, 22 años. Constitución atlética media-fuerte. Cabello negro corto. Pequeña cicatriz en ceja derecha. Postura de guardia suelta pero lista. Expresión intensa, como si estuviera evaluando al adversario. Gi blanco limpio. Vendas en las manos visibles.

**D2 — Keiko Mori** (`student_keiko_mori_full.png` + `student_keiko_mori_portrait.png`)
Mujer asiática, 22 años. Constitución atlética delgada pero musculosa. Cabello negro en cola baja. Expresión calmada e inteligente — confianza sin arrogancia. Postura neutral, ligeramente de costado. Gi blanco limpio. Cinta en el cabello minimalista.

---

### FAJAS (10 assets)

**Especificaciones:**
- PNG transparente, horizontal, 600×120px
- Textura de tela visible (no rectángulo plano)
- Bordes con nudo de amarre visible en un extremo

| Archivo | Color | Hex | Nota especial |
|---------|-------|-----|---------------|
| `belt_white.png` | Blanca | #F5F5F5, borde #C0C0C0 | La más simple |
| `belt_yellow.png` | Amarilla | #EDCC3A | |
| `belt_orange.png` | Naranja | #E87020 | |
| `belt_green.png` | Verde | #27AE60 | |
| `belt_blue.png` | Azul | #2980B9 | |
| `belt_purple.png` | Morada | #8E44AD | |
| `belt_brown.png` | Marrón | #7B4019 | |
| `belt_red.png` | Roja | #C0392B | |
| `belt_red_black.png` | Roja-Negra | mitad roja / mitad negra | Split horizontal por el centro |
| `belt_black.png` | Negra | #111111 | **Hilo dorado cosido en ambos bordes** — la más premium |

---

### ÍCONOS DE ESTILOS (8 assets)

**Especificaciones:** 256×256px, fondo transparente, line art + fill, legibles a 48px.

| Archivo | Concepto |
|---------|----------|
| `icon_kung_fu.png` | Postura de "wing chun" o mano de tigre (zhuǎ) |
| `icon_karate.png` | Silueta en karate chop (shuto uchi) |
| `icon_taekwondo.png` | Silueta en patada lateral alta (yeop chagi) |
| `icon_judo.png` | Dos siluetas: una ejecutando ippon seoi nage |
| `icon_muay_thai.png` | Postura del wai kru o rodillazo hacia arriba |
| `icon_bjj.png` | Silueta en guardia de suelo (closed guard) |
| `icon_boxing.png` | Guardia clásica de boxeador con jab extendido |
| `icon_mma.png` | Silueta híbrida en medio-guard, octágono de fondo muy sutil |

---

### ÍCONOS DE NAVEGACIÓN (5 assets × 2 estados)

**Especificaciones:** 64×64px, line art, fondo transparente.
- Estado inactivo: `#3A3F52` (gris)
- Estado activo: `#C9A84C` (oro)

| Archivo base | Sección | Concepto |
|-------------|---------|----------|
| `nav_dojo` | Dojo | Perfil de pagoda o techo de dojo simplificado |
| `nav_training` | Entrenar | Puño impactando un saco |
| `nav_tournament` | Torneos | Copa estilizada con laurel mínimo |
| `nav_students` | Estudiantes | Dos siluetas de pie, una más alta que otra |
| `nav_market` | Mercado | Pergamino enrollado o sello de contrato |

---

### ÍCONOS DE ESTRATEGIA (5 assets)

**Especificaciones:** 128×128px, color, fondo transparente. Deben comunicar la estrategia instantáneamente.

| Archivo | Estrategia | Concepto | Color dominante |
|---------|------------|----------|-----------------|
| `strategy_aggressive.png` | Agresivo | Puño hacia adelante con líneas de velocidad | Rojo #C0392B |
| `strategy_defensive.png` | Defensivo | Brazos cruzados en guardia alta, forma de escudo | Azul #2980B9 |
| `strategy_technical.png` | Técnico | Ojo con líneas de análisis, o engranaje/cerebro | Dorado #C9A84C |
| `strategy_grappling.png` | Grappling | Dos siluetas trabadas, uno tirando al otro al suelo | Marrón #7B4019 |
| `strategy_adaptive.png` | Adaptable | Flecha circular (ouroboros mínimo) o camaleón esquemático | Verde #27AE60 |

---

### CURRENCIES (3 assets)

**Especificaciones:** 256×256px, con volumen y profundidad. No flat.

**Moneda de Dojo (MD)** (`currency_md.png`)
Moneda de bronce/cobre con desgaste. Grabado de un techo de dojo en el anverso. Forma hexagonal o circular con muescas (inspirada en monedas antiguas japonesas). Color cobre rojizo con sombras cálidas.

**Gema del Maestro (GM)** (`currency_gm.png`)
Gema facetada, corte de diamante, color ámbar-dorado translúcido. En el centro, un kanji grabado (道 — "el camino") visible como reflejo interior. Brillos dramáticos, efecto cristal de alta gama.

**Punto de Habilidad (PH)** (`currency_ph.png`)
Estrella de cinco puntas con aura de ki/energía alrededor. Color blanco-azul con destellos de luz. Más espiritual que material — transmite "potencial interno". Más simple que las otras dos monedas.

---

### MEJORAS DEL DOJO (7 assets ilustración)

**Especificaciones:** 256×256px, vista isométrica o frontal plana, fondo transparente. Estilo flat con sombra leve.

| Archivo | Objeto |
|---------|--------|
| `upgrade_basic_training_room.png` | Conjunto de pesas + tatami pequeño enrollado |
| `upgrade_expanded_tatami.png` | Rollo de tatami desplegándose |
| `upgrade_cardio_area.png` | Cuerda de saltar + bicicleta estática |
| `upgrade_locker_room.png` | Casillero metálico con puerta abierta |
| `upgrade_martial_library.png` | Estante con libros y pergaminos enrollados |
| `upgrade_sparring_room.png` | Dos maniquíes de entrenamiento enfrentados |
| `upgrade_full_dojo.png` | Miniatura isométrica del dojo completo con jardín |

---

### PUNTOS DE LUCHADOR / FX (arena de pelea)

**Fighter Dot Blue** (`fighter_dot_blue.png`) — 64×64px
Silueta esquemática de luchador top-down (cabeza + hombros, 3 píxeles de detalle). Aura azul (`#2980B9`) pulsante. Sombra pequeña hacia abajo.

**Fighter Dot Red** (`fighter_dot_red.png`) — 64×64px
Igual pero aura roja (`#C0392B`).

**FX Impact** (`fx_impact.png`) — 256×256px
Onda expansiva circular con estallido central. Blanco-amarillo. Para golpe limpio.

**FX Dominant Hit** (`fx_dominant_hit.png`) — 512×512px
Más dramático. Naranja-rojo con partículas. Para golpe dominante.

---

## 9. ESPECIFICACIONES TÉCNICAS PARA EL ARTISTA

- Formato: PNG (transparencia) para todos los assets de UI · JPG para backgrounds
- Resolución: entregar al 2× la medida indicada (para Retina/HDPI)
- Espacio de color: sRGB
- Exportar también SVG para: íconos de navegación, estrategia, currencies
- Prioridad de entrega:
  1. Logo + backgrounds (Splash, Login, Dashboard)
  2. Íconos de navegación + currencies
  3. Imágenes de dojo (carousel)
  4. Avatares de estudiantes
  5. Fajas
  6. Resto (upgrades, FX, estrategia)
