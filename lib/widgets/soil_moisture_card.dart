import 'package:flutter/material.dart';

class SoilMoistureCard extends StatelessWidget {
  final double moistureValue;
  final bool isConnected;

  const SoilMoistureCard({
    super.key,
    required this.moistureValue,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    // Determine moisture level and color
    String moistureLevel;
    Color moistureColor;
    IconData moistureIcon;
    
    if (moistureValue >= 70) {
      moistureLevel = 'Very Wet';
      moistureColor = Colors.blue[700]!;
      moistureIcon = Icons.water_drop;
    } else if (moistureValue >= 50) {
      moistureLevel = 'Moist';
      moistureColor = Colors.green[700]!;
      moistureIcon = Icons.opacity;
    } else if (moistureValue >= 30) {
      moistureLevel = 'Dry';
      moistureColor = Colors.orange[700]!;
      moistureIcon = Icons.grass;
    } else {
      moistureLevel = 'Very Dry';
      moistureColor = Colors.red[700]!;
      moistureIcon = Icons.warning;
    }

    return Container(
      width: isLandscape ? 100 : double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(isLandscape ? 12 : 16),
        border: Border.all(color: Colors.teal[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(isLandscape ? 8 : 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Soil Moisture
          Container(
            padding: EdgeInsets.symmetric(
              vertical: isLandscape ? 4 : 6,
              horizontal: isLandscape ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: Colors.teal[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.eco_rounded,
                  color: Colors.teal[700],
                  size: isLandscape ? 12 : 16,
                ),
                SizedBox(width: isLandscape ? 4 : 6),
                Text(
                  isLandscape ? 'SOIL' : 'SOIL MOISTURE',
                  style: TextStyle(
                    fontSize: isLandscape ? 8 : 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: isLandscape ? 8 : 12),
          
          // Moisture Icon and Value
          Icon(
            moistureIcon,
            color: moistureColor,
            size: isLandscape ? 20 : 32,
          ),
          
          SizedBox(height: isLandscape ? 4 : 6),
          
          // Moisture Value
          Text(
            '${moistureValue.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: isLandscape ? 16 : 20,
              fontWeight: FontWeight.bold,
              color: moistureColor,
            ),
          ),
          
          SizedBox(height: isLandscape ? 2 : 4),
          
          // Moisture Level
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 6 : 8,
              vertical: isLandscape ? 2 : 3,
            ),
            decoration: BoxDecoration(
              color: moistureColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: moistureColor.withOpacity(0.3), width: 0.5),
            ),
            child: Text(
              moistureLevel,
              style: TextStyle(
                fontSize: isLandscape ? 7 : 9,
                fontWeight: FontWeight.bold,
                color: moistureColor,
              ),
            ),
          ),
          
          SizedBox(height: isLandscape ? 6 : 8),
          
          // Moisture Bar
          Container(
            width: double.infinity,
            height: isLandscape ? 4 : 6,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (moistureValue / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: moistureColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          
          SizedBox(height: isLandscape ? 4 : 6),
          
          // Status Text
          Text(
            isConnected ? 'Live Data' : 'Offline',
            style: TextStyle(
              fontSize: isLandscape ? 6 : 8,
              color: isConnected ? Colors.green[600] : Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}