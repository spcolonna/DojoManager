import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dojo_provider.dart';
import '../../../widgets/dojo_info_card.dart';
import '../../../widgets/dojo_map_marker.dart';
import '../../dojo/dojo_screen.dart';


class DojoHome extends ConsumerStatefulWidget {
  const DojoHome();

  @override
  ConsumerState<DojoHome> createState() => DojoHomeState();
}

class DojoHomeState extends ConsumerState<DojoHome> {
  String? _selectedDojoId;

  // Posiciones de los marcadores en el mapa (fracción de ancho x alto)
  // Ajustá estos valores según donde quieras que aparezca cada escuela
  static const Map<int, Offset> _markerPositions = {
    0: Offset(0.42, 0.28),  // 1ra escuela — zona del dojo superior del mapa
    1: Offset(0.25, 0.65),  // 2da escuela — zona inferior izquierda
    2: Offset(0.70, 0.55),  // 3ra escuela — zona derecha
    3: Offset(0.55, 0.80),  // 4ta escuela — zona inferior
    4: Offset(0.15, 0.40),  // 5ta escuela
  };

  @override
  Widget build(BuildContext context) {
    final dojoAsync     = ref.watch(dojoProvider);
    final studentsAsync = ref.watch(studentsProvider);

    return Stack(
      children: [
        // ── Mapa de fondo ──────────────────────────────────────────────
        Positioned.fill(
          child: Image.asset(
            'assets/images/backgrounds/bg_dashboard_map.png',
            fit: BoxFit.cover,
          ),
        ),

        // Overlay oscuro sutil para que la UI sea legible
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.05),
                  Colors.black.withValues(alpha: 0.30),
                ],
              ),
            ),
          ),
        ),

        // ── Marcadores de dojos ────────────────────────────────────────
        dojoAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (dojo) {
            if (dojo == null) return const SizedBox.shrink();
            final studentCount = studentsAsync.valueOrNull?.length ?? 0;

            return LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                final pos = _markerPositions[0]!;

                return Stack(
                  children: [
                    // Marcador de la escuela del jugador
                    Positioned(
                      left: w * pos.dx - 40,  // centrar el widget de 80px
                      top:  h * pos.dy - 50,  // centrar el widget de 100px
                      child: DojoMapMarker(
                        dojoName: dojo.name,
                        styleId: dojo.styleId,
                        level: dojo.level,
                        studentCount: studentCount,
                        maxStudents: dojo.maxStudentSlots,
                        isSelected: _selectedDojoId == dojo.id,
                        onTap: () => setState(() {
                          _selectedDojoId = _selectedDojoId == dojo.id
                              ? null
                              : dojo.id;
                        }),
                      ),
                    ),

                    // Marcadores fantasma de futuras escuelas
                    ...[1, 2, 3, 4].map((i) {
                      final p = _markerPositions[i]!;
                      return Positioned(
                        left: w * p.dx - 16,
                        top:  h * p.dy - 16,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white38,
                            size: 16,
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            );
          },
        ),

        // ── Info card al seleccionar un dojo ──────────────────────────
        if (_selectedDojoId != null)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: dojoAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (dojo) {
                if (dojo == null || dojo.id != _selectedDojoId) {
                  return const SizedBox.shrink();
                }
                return DojoInfoCard(
                  dojo: dojo,
                  studentCount: studentsAsync.valueOrNull?.length ?? 0,
                  onEnter: () {
                    setState(() => _selectedDojoId = null);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const DojoScreen(),
                    ));
                  },
                  onDismiss: () =>
                      setState(() => _selectedDojoId = null),
                );
              },
            ),
          ),
      ],
    );
  }
}