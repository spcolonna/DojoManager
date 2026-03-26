import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/animations/app_animations.dart';

/// Marcador animado de dojo sobre el mapa.
/// Muestra un pulso expansivo + ícono de casa + nombre al tocar.
class DojoMapMarker extends StatefulWidget {
  final String dojoName;
  final String styleId;
  final int level;
  final int studentCount;
  final int maxStudents;
  final VoidCallback onTap;
  final bool isSelected;

  const DojoMapMarker({
    super.key,
    required this.dojoName,
    required this.styleId,
    required this.level,
    required this.studentCount,
    required this.maxStudents,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<DojoMapMarker> createState() => _DojoMapMarkerState();
}

class _DojoMapMarkerState extends State<DojoMapMarker>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _selectController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;
  late Animation<double> _selectScale;

  @override
  void initState() {
    super.initState();

    // Pulso continuo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _pulseScale = Tween<double>(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _pulseOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    // Escala al seleccionar
    _selectController = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );

    _selectScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _selectController, curve: Curves.elasticOut),
    );

    if (widget.isSelected) _selectController.forward();
  }

  @override
  void didUpdateWidget(DojoMapMarker old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _selectController.forward();
    } else if (!widget.isSelected && old.isSelected) {
      _selectController.reverse();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _selectController.dispose();
    super.dispose();
  }

  Color get _markerColor =>
      AppColors.colorByStyle[widget.styleId] ?? AppColors.goldPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _selectScale,
        child: SizedBox(
          width: 80,
          height: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícono con pulso
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Anillo de pulso exterior
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) => Transform.scale(
                        scale: _pulseScale.value,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _markerColor
                                  .withOpacity(_pulseOpacity.value),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Segundo anillo con delay
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) {
                        final delayed =
                            (_pulseController.value + 0.4) % 1.0;
                        final scale = 1.0 + delayed * 1.2;
                        final opacity = (1.0 - delayed) * 0.4;
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _markerColor.withOpacity(opacity),
                                width: 1.5,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Ícono principal
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? _markerColor
                            : _markerColor.withOpacity(0.85),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _markerColor.withOpacity(0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.home_work_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          Text(
                            'Lv${widget.level}',
                            style: GoogleFonts.rajdhani(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Nombre del dojo
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.isSelected
                        ? _markerColor
                        : _markerColor.withOpacity(0.4),
                    width: widget.isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  widget.dojoName,
                  style: GoogleFonts.rajdhani(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: widget.isSelected
                        ? _markerColor
                        : Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}