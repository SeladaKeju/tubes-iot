import 'package:flutter/material.dart';
import 'dart:math';

class JoystickWidget extends StatefulWidget {
  final Function(double x, double y) onChanged;
  final double size;
  final Color backgroundColor;
  final Color knobColor;
  final Color borderColor;

  const JoystickWidget({
    super.key,
    required this.onChanged,
    this.size = 200.0,
    this.backgroundColor = Colors.grey,
    this.knobColor = Colors.blue,
    this.borderColor = Colors.black,
  });

  @override
  State<JoystickWidget> createState() => _JoystickWidgetState();
}

class _JoystickWidgetState extends State<JoystickWidget> {
  double _knobX = 0.0;
  double _knobY = 0.0;
  bool _isDragging = false;

  void _updateKnobPosition(Offset localPosition) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final offset = localPosition - center;
    final distance = offset.distance;
    final maxDistance = (widget.size / 2) - 30; // 30 is half of knob size

    if (distance <= maxDistance) {
      _knobX = offset.dx;
      _knobY = offset.dy;
    } else {
      final angle = atan2(offset.dy, offset.dx);
      _knobX = cos(angle) * maxDistance;
      _knobY = sin(angle) * maxDistance;
    }

    // Normalize values to -1.0 to 1.0 range
    final normalizedX = _knobX / maxDistance;
    final normalizedY = -_knobY / maxDistance; // Invert Y for intuitive control

    setState(() {});
    widget.onChanged(normalizedX, normalizedY);
  }

  // TIDAK RESET - TETAP DI POSISI TERAKHIR
  void _stopDragging() {
    setState(() {
      _isDragging = false;
      // TIDAK reset _knobX dan _knobY
    });
    // TIDAK panggil widget.onChanged(0.0, 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.backgroundColor.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(color: widget.borderColor, width: 3),
      ),
      child: GestureDetector(
        onPanStart: (details) {
          _isDragging = true;
          _updateKnobPosition(details.localPosition);
        },
        onPanUpdate: (details) {
          if (_isDragging) {
            _updateKnobPosition(details.localPosition);
          }
        },
        // TIDAK RESET SAAT DILEPAS
        onPanEnd: (details) {
          _stopDragging(); // Hanya stop dragging, TIDAK reset posisi
        },
        onTapUp: (details) {
          // Tap untuk pindah posisi tanpa reset
          _updateKnobPosition(details.localPosition);
        },
        child: Stack(
          children: [
            // Center lines for reference
            Positioned(
              left: widget.size / 2 - 1,
              top: 20,
              child: Container(
                width: 2,
                height: widget.size - 40,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
            Positioned(
              left: 20,
              top: widget.size / 2 - 1,
              child: Container(
                width: widget.size - 40,
                height: 2,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
            // Knob
            Positioned(
              left: (widget.size / 2) + _knobX - 30,
              top: (widget.size / 2) + _knobY - 30,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: widget.knobColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.control_camera,
                    color: Colors.white,
                    size: _isDragging ? 28 : 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}