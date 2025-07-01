import 'package:flutter/material.dart';

class VolumeSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final Function(double) onChanged;
  final Function(double) onChangeEnd;

  const VolumeSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: isLandscape ? 16 : 18,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: isLandscape ? 16 : 18,
            ),
            overlayShape: RoundSliderOverlayShape(
              overlayRadius: isLandscape ? 24 : 28,
            ),
            activeTrackColor: Colors.blue[600],
            inactiveTrackColor: Colors.grey[300],
            thumbColor: Colors.blue[700],
            overlayColor: Colors.blue.withOpacity(0.2),
            valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
            valueIndicatorColor: Colors.blue[700],
            valueIndicatorTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isLandscape ? 12 : 14,
            ),
            showValueIndicator: ShowValueIndicator.always,
            tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 3),
            activeTickMarkColor: Colors.blue[400],
            inactiveTickMarkColor: Colors.grey[400],
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            label: '${value.toInt()}°',
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ),
      ),
    );
  }
}