import 'package:flutter/material.dart';
import 'joystick_widget.dart';

class CarControlWidget extends StatelessWidget {
  final Function(double x, double y) onJoystickChanged;
  final double currentX;
  final double currentY;

  const CarControlWidget({
    super.key,
    required this.onJoystickChanged,
    required this.currentX,
    required this.currentY,
  });

  String _getDirectionText(double x, double y) {
    if (x.abs() < 0.1 && y.abs() < 0.1) return 'STOP';
    
    String direction = '';
    if (y > 0.3) direction += 'FORWARD';
    else if (y < -0.3) direction += 'BACKWARD';
    
    if (x > 0.3) direction += direction.isEmpty ? 'RIGHT' : ' RIGHT';
    else if (x < -0.3) direction += direction.isEmpty ? 'LEFT' : ' LEFT';
    
    return direction.isEmpty ? 'STOP' : direction;
  }

  Color _getDirectionColor(double x, double y) {
    if (x.abs() < 0.1 && y.abs() < 0.1) return Colors.grey;
    if (y > 0.3) return Colors.green;
    if (y < -0.3) return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Column(
      children: [
        // Title
        Text(
          'Car Controller',
          style: TextStyle(
            fontSize: isLandscape ? 16 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        
        SizedBox(height: isLandscape ? 8 : 16),
        
        // Direction Display
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 12 : 16,
            vertical: isLandscape ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: _getDirectionColor(currentX, currentY).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getDirectionColor(currentX, currentY).withOpacity(0.3),
            ),
          ),
          child: Text(
            _getDirectionText(currentX, currentY),
            style: TextStyle(
              fontSize: isLandscape ? 12 : 16,
              fontWeight: FontWeight.bold,
              color: _getDirectionColor(currentX, currentY),
            ),
          ),
        ),
        
        SizedBox(height: isLandscape ? 12 : 20),
        
        // Joystick
        JoystickWidget(
          size: isLandscape ? 120 : 180,
          onChanged: onJoystickChanged,
          backgroundColor: Colors.indigo,
          knobColor: Colors.indigo[700]!,
          borderColor: Colors.indigo[800]!,
        ),
        
        SizedBox(height: isLandscape ? 8 : 16),
        
        // Coordinates Display
        Container(
          padding: EdgeInsets.all(isLandscape ? 6 : 8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'X: ${currentX.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: isLandscape ? 10 : 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(width: isLandscape ? 8 : 12),
              Text(
                'Y: ${currentY.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: isLandscape ? 10 : 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}