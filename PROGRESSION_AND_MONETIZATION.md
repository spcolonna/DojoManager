# GRAND DOJO — Análisis de Progresión y Balance F2P

## 1. TIEMPOS ESTIMADOS A FAJA NEGRA

**XP total requerido: 7,550 XP por estudiante**

### Ingresos semanales base (por estudiante)

| Fuente | XP/semana | Notas |
|---|---|---|
| Entrenamiento (5 días) | 100 XP | 20 XP × 5 días |
| Misiones diarias (70% completadas) | 87 XP | 25 XP × 3.5 días promedio |
| Sparring semanal | 60 XP | 1 sesión por semana |
| Torneos (50% win rate, 1.5 peleas) | 75 XP | promedio |
| **TOTAL base** | **322 XP/semana** | |

---

### Cuadro comparativo de perfiles

| Perfil | Descripción | XP/semana | Semanas | Meses |
|---|---|---|---|---|
| 🆓 Free casual | No completa misiones, < 40% victorias | ~160 XP | ~47 | **~11 meses** |
| 🆓 Free regular | Completa misiones, 50% victorias | ~322 XP | ~23 | **~6 meses** |
| 🆓 Free dedicado | Grindea todo, >70% victorias | ~430 XP | ~18 | **~4.5 meses** |
| 💳 Pase Mensual regular | Pase activo, 50% victorias | ~472 XP | ~16 | **~4 meses** |
| 💳 Gasto bajo (~$15 total) | Pase 1 mes + pack pequeño | ~370 XP | ~20 | **~5 meses** |
| 💳 Gasto moderado (~$40 total) | Pase 2 meses + pack medio | ~580 XP | ~13 | **~3 meses** |
| 💳 Gasto alto ($100+) | Pase anual + packs GM | ~800 XP | ~9–10 | **~2 meses** |

**Ratio free:premium máximo = 11 meses / 2 meses = 5.5x**
**Ratio free regular:pago moderado = 6 meses / 3 meses = 2x** ← el más relevante

---

## 2. LA MECÁNICA "SOFT GATE" — CÓMO FRENAMOS SIN PAY-TO-WIN

### El problema a resolver:
El juego debe tener ingresos, pero si el dinero compra ventajas directas (más XP, mejor stats) el juego se percibe como injusto y pierde jugadores free → pierde el ecosistema → pierde el revenue.

### La solución: Gates de Tiempo, no de Habilidad

Los pagos en Grand Dojo compran **velocidad** y **conveniencia**, no stats superiores que un free player no pueda alcanzar con tiempo.

#### Mecanismo 1: Límite de Actividad Semanal (TIME GATE)

- Solo hay **5 días de entrenamiento por semana** y **1-2 torneos por semana**
- No se puede "comprar" más días de entrenamiento ni más torneos base
- El Pase desbloquea 1 torneo especial extra — es conveniente, no excluyente
- **Resultado:** hay un cap natural de XP/semana de ~900 XP incluso pagando mucho

#### Mecanismo 2: El PH NO se compra (FAIR GATE)

- Los Puntos de Habilidad (árbol de habilidades) SOLO se ganan entrenando
- No existe en la tienda ningún paquete de PH
- Un jugador free que grindea 6 meses tiene el mismo árbol que uno que pagó por llegar antes
- **Resultado:** la profundidad estratégica del árbol es completamente equitativa

#### Mecanismo 3: Los torneos segmentan por FAJA (LEVEL GATE)

- Un whale que llega a faja azul en 3 meses no compite contra un free de faja azul de 6 meses
- Compiten en la misma división (faja azul) con stats comparables
- La diferencia: el whale llegó antes, no que sea imbatible
- **Resultado:** cada torneo es competitivo independientemente del gasto

#### Mecanismo 4: Las mejoras del Dojo tienen TIEMPO DE CONSTRUCCIÓN (WAIT GATE)

- Cuando comprás una mejora del dojo con MD, tarda X horas en completarse
- Podés gastar GM para acelerar (ShopConfig.skipConstructionCostGM = 2 GM)
- Sin acelerar, el jugador free eventualmente llega igual
- **Resultado:** el GM compra tiempo, no acceso exclusivo

---

## 3. TABLA DE WAIT GATES POR MEJORA

| Mejora | Costo MD | Tiempo de construcción | GM para acelerar |
|---|---|---|---|
| Sala de Entrenamiento Básica | 100 MD | 1 hora | 1 GM |
| Tatami Ampliado | 250 MD | 4 horas | 1 GM |
| Área de Cardio | 300 MD | 6 horas | 2 GM |
| Vestuario | 500 MD | 12 horas | 2 GM |
| Biblioteca Marcial | 400 MD | 8 horas | 2 GM |
| Sala de Sparring | 600 MD | 18 horas | 3 GM |
| Dojo Completo | 1,500 MD | 48 horas | 5 GM |

*El tiempo de construcción es el principal mecanismo de monetización pasiva sin ser pay-to-win. El jugador puede ignorarlo completamente — solo esperando llega igual.*

---

## 4. PROYECCIÓN DE REVENUE F2P BENCHMARK

Datos de la industria (mobile F2P casual/mid-core):
- ~2-3% de los usuarios activos son "payers"
- ARPU mensual saludable: $1.5–$3 por usuario activo
- LTV de suscriptor mensual: ~3-4 meses de retención

### Escenario conservador con 10,000 usuarios activos mensuales:

| Tipo | % usuarios | Gasto promedio/mes | Revenue/mes |
|---|---|---|---|
| Free (no pagan) | 97% | $0 | $0 |
| Micro-payers ($0.99–$4.99) | 2% | ~$2.50 | $500 |
| Mid-tier ($5–$20) | 0.8% | ~$12 | $960 |
| Whales ($20+) | 0.2% | ~$35 | $700 |
| Pase mensual | 1.5% | $4.99 | $748 |
| **TOTAL** | | | **~$2,908/mes** |

*Con escala a 50,000 usuarios activos → ~$14,500/mes*

---

## 5. SEMANAS 1–4: CURVA DE ENGAGEMENT DISEÑADA

| Semana | Evento clave | Objetivo del diseño |
|---|---|---|
| 1 | Tutorial completo, primer torneo | Anclar el loop semanal |
| 2 | Primera mejora del dojo disponible | Introducir el gasto de MD |
| 3 | Primera vez que alguien de la Liga los supera | Motivar mejora |
| 4 | Primera oferta de reclutamiento de un estudiante B | Introducir el mercado |
| 6 | Pop-up de oferta del Pase de Maestro (contextual) | Primer pitch de monetización |
| 8 | Copa Inter-Estilos desbloqueada | Nuevo contenido, retención |
| 12 | Final de primera mitad de temporada | Resumen, proyección de final |
| 20 | Fin de temporada 1 | Ascensos, descensos, mercado grande |

### Regla de oro: el primer pitch de monetización ocurre en semana 6, no antes.
Mostrar la tienda antes de que el jugador sienta el "techo" del free play genera rechazo. En semana 6 el jugador ya ama el juego y puede sentir genuinamente el valor del Pase.

---

## 6. DEFINICIÓN DE "NO PAY-TO-WIN" PARA GRAND DOJO

**Un jugador FREE puede:**
- Llegar a Faja Negra (en ~6 meses con dedicación)
- Completar el árbol de habilidades de sus estudiantes
- Ganar torneos de Liga y Copa si tiene buena estrategia
- Ascender de división y llegar a División 1
- Reclutar estudiantes de hasta faja marrón con grindeo

**Un jugador PREMIUM puede:**
- Llegar a Faja Negra antes (en ~2-3 meses)
- Tener más estudiantes disponibles (slot extra)
- Acceder a torneos especiales con mejor reward
- Abrir nuevas escuelas antes

**Un jugador PREMIUM NO puede:**
- Tener stats permanentemente superiores a los de un free player en el mismo nivel
- Desbloquear nodos del árbol de habilidades que el free player no pueda desbloquear
- Ganar automáticamente por pagar más

---

## 7. RESUMEN ASSETS PARA ARTISTA (PRIORITARIO)

### Prioridad ALTA (bloquea desarrollo de onboarding)

#### A1 — Logo "Grand Dojo"
Dimensiones: 1024×1024px + SVG
Concepto: Ícono cuadrado con tatami visto desde arriba. Dos siluetas esquemáticas enfrentadas en el centro. Bordes con ornamento japonés sutil. Colores: fondo #141824 oscuro, detalles en oro #C9A84C. Wordmark "GRAND DOJO" con tipografía que evoca sellos de tinta oriental — pesada, legible, con carácter. Sin gradientes. Sin efectos brillantes. Austeridad elegante.

#### B1 — Background del Splash
Dimensiones: 1440×3200px (PNG o JPG)
Concepto: Fondo casi negro (#0A0C12). En el centro/fondo, silueta difuminada de un luchador en guardia — casi invisible, como una sombra. Sobre eso, líneas muy tenues que simulan tablones de madera de dojo japonés vistas desde arriba. En el tercio superior, un enso (círculo de tinta zen) incompleto en oro muy apagado (#8A6D2F, opacidad 25%). Resultado: oscuro, misterioso, elegante. Sin texto — lo agrega la app.

#### B3 — Background del Dashboard / Home
Dimensiones: 1440×3200px
Concepto: Interior de un dojo visto en perspectiva frontal levísima. Tatami verde oscuro como textura base. Líneas de división del tatami visibles pero sutiles. Ventanas shoji en el borde superior dejando filtrar luz cálida suave. Ambiente sereno de entrenamiento. Colores oscuros — no debe competir con la UI que va encima. Casi toda la UI está sobre el fondo con sus propias cards de color #141824/#1C2235.

#### C1 a C8 — Imágenes de Dojo por Estilo (para el carousel)
Dimensiones: 1280×720px cada una (16:9, recortable)
Formato: Ilustración semi-realista con iluminación dramática. Oscuro con luz cálida puntual.

| ID | Estilo | Qué mostrar |
|---|---|---|
| C1 | Kung Fu | Templo chino: columnas rojas lacadas, armas colgadas, maniquí de madera, incienso |
| C2 | Karate | Dojo japonés austero: tatami beige, shomen con kanji, ventanas shoji, muy limpio |
| C3 | Taekwondo | Gym moderno coreano: suelo azul/rojo, espejos, bandera, punching bags en fila |
| C4 | Judo | Sala de tatami azul: fotos de maestros en BN, vitrina de trofeos, funcional |
| C5 | Muay Thai | Gym tailandés abierto: ring de cuerdas, bolsas colgantes, imagen de Buda, ventiladores |
| C6 | BJJ | Academia moderna: tatami azul oscuro, afiches de técnicas, LED blanca, árbol de linaje |
| C7 | Boxeo | Gym clásico vintage: ring, speed bag, heavy bag, afiches retro, madera desgastada |
| C8 | MMA | Centro moderno: octágono/cage, tatami por zonas, pantallas digitales, equipamiento mixto |

### Prioridad MEDIA (bloquea desarrollo de personajes e inicio)

#### D1 — Estudiante Zhang Wei (hombre, 22 años)
Full body: 800×1600px + portrait 400×400px
Concepto: Joven asiático atlético. Cabello negro corto, expresión intensa y enfocada — no sonríe. Gi blanco, sin cinto visible (versión base). Postura de guardia relajada pero preparada. Pequeña cicatriz en la ceja opcional. Estilo semi-realista, sin elementos cartoon.

#### D2 — Estudiante Keiko Mori (mujer, 22 años)
Full body: 800×1600px + portrait 400×400px
Concepto: Joven asiática delgada pero atlética. Cabello negro en cola baja. Expresión calmada e inteligente. Gi blanco. Brazos levemente cruzados — confianza. Sin elementos kawaii. Seria y competitiva.

### Prioridad BAJA (se puede temporalmente usar placeholders de color sólido)

- E: Fajas (10 colores)
- F: Íconos de estilos (8)
- G: Íconos de navegación (5, con estado activo/inactivo)
- H: Íconos de estrategia (5)
- I: Currencies (3)
- J: Nodos del árbol (3 estados)
- K: Mejoras del dojo (7)
- L: Efectos de pelea (4)

---

## 8. PALETA DE COLORES — REFERENCIA PARA EL ARTISTA

```
FONDOS:
  Fondo profundo:    #0A0C12  ← base de toda la app
  Superficie:        #141824  ← cards y panels
  Elevado:           #1C2235  ← modales, cards destacadas
  Input:             #242B40  ← campos de texto

ACENTO PRIMARIO — ORO/HONOR:
  Oro principal:     #C9A84C  ← CTAs, títulos importantes
  Oro claro:         #E8C97A  ← highlights
  Oro oscuro:        #8A6D2F  ← bordes sutiles

ACENTO SECUNDARIO — ROJO/COMBATE:
  Rojo acción:       #C0392B  ← combate, daño, alerta
  Rojo claro:        #E74C3C  ← highlights de combate

TEXTO:
  Primario:          #F0F0F0
  Secundario:        #9099B0
  Terciario:         #5C6480

TIPOGRAFÍAS:
  Títulos/UI Honor:  Cinzel Decorative (Google Fonts — gratis)
  Stats/Cuerpo:      Rajdhani (Google Fonts — gratis)
```
