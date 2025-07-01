import 'package:flutter/material.dart';

class CarControlWidget extends StatelessWidget {
  final void Function(String action) onAction;

  const CarControlWidget({
    super.key,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final screenSize = MediaQuery.of(context).size;

    if (isLandscape) {
      // Landscape - D-Pad dengan ukuran yang disesuaikan
      final buttonSize = (screenSize.height * 0.15).clamp(30.0, 50.0);
      final iconSize = (buttonSize * 0.5).clamp(16.0, 24.0);
      final spacing = (buttonSize * 0.3).clamp(8.0, 16.0);

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // MAJU
            ElevatedButton(
              onPressed: () => onAction('forward'),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: EdgeInsets.all(buttonSize * 0.3),
                backgroundColor: Colors.green,
                minimumSize: Size(buttonSize, buttonSize),
              ),
              child: Icon(
                Icons.arrow_upward,
                color: Colors.white,
                size: iconSize,
              ),
            ),
            SizedBox(height: spacing),
            // Baris tengah: KIRI, STOP, KANAN
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => onAction('left'),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.all(buttonSize * 0.3),
                    backgroundColor: Colors.orange,
                    minimumSize: Size(buttonSize, buttonSize),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
                SizedBox(width: spacing),
                ElevatedButton(
                  onPressed: () => onAction('stop'),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.all(buttonSize * 0.3),
                    backgroundColor: Colors.red,
                    minimumSize: Size(buttonSize, buttonSize),
                  ),
                  child: Icon(
                    Icons.stop,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
                SizedBox(width: spacing),
                ElevatedButton(
                  onPressed: () => onAction('right'),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.all(buttonSize * 0.3),
                    backgroundColor: Colors.orange,
                    minimumSize: Size(buttonSize, buttonSize),
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing),
            // MUNDUR
            ElevatedButton(
              onPressed: () => onAction('back'),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: EdgeInsets.all(buttonSize * 0.3),
                backgroundColor: Colors.blue,
                minimumSize: Size(buttonSize, buttonSize),
              ),
              child: Icon(
                Icons.arrow_downward,
                color: Colors.white,
                size: iconSize,
              ),
            ),
          ],
        ),
      );
    } else {
      // Portrait - Layout vertikal
      final buttonSize = (screenSize.width * 0.15).clamp(40.0, 60.0);
      final iconSize = (buttonSize * 0.5).clamp(20.0, 30.0);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Car Controller',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 16),
          // MAJU
          ElevatedButton(
            onPressed: () => onAction('forward'),
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.all(buttonSize * 0.3),
              backgroundColor: Colors.green,
              minimumSize: Size(buttonSize, buttonSize),
            ),
            child: Icon(
              Icons.arrow_upward,
              color: Colors.white,
              size: iconSize,
            ),
          ),
          const SizedBox(height: 12),
          // Baris tengah: KIRI, STOP, KANAN
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => onAction('left'),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: EdgeInsets.all(buttonSize * 0.3),
                  backgroundColor: Colors.orange,
                  minimumSize: Size(buttonSize, buttonSize),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
              ElevatedButton(
                onPressed: () => onAction('stop'),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: EdgeInsets.all(buttonSize * 0.3),
                  backgroundColor: Colors.red,
                  minimumSize: Size(buttonSize, buttonSize),
                ),
                child: Icon(
                  Icons.stop,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
              ElevatedButton(
                onPressed: () => onAction('right'),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: EdgeInsets.all(buttonSize * 0.3),
                  backgroundColor: Colors.orange,
                  minimumSize: Size(buttonSize, buttonSize),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // MUNDUR
          ElevatedButton(
            onPressed: () => onAction('back'),
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.all(buttonSize * 0.3),
              backgroundColor: Colors.blue,
              minimumSize: Size(buttonSize, buttonSize),
            ),
            child: Icon(
              Icons.arrow_downward,
              color: Colors.white,
              size: iconSize,
            ),
          ),
        ],
      );
    }
  }
}

// Usage example
// CarControlWidget(
//   onAction: _sendCarAction,
// ),