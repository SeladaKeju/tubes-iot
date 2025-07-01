import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import '../widgets/volume_slider.dart';
import '../widgets/car_control_widget.dart';
import '../widgets/soil_moisture_card.dart';

class ControllerPage extends StatefulWidget {
  const ControllerPage({super.key});

  @override
  State<ControllerPage> createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Servo control values
  double currentPositionRight = 90.0;
  double targetPositionRight = 90.0;
  bool isMovingRight = false;

  double currentPositionLeft = 90.0;
  double targetPositionLeft = 90.0;
  bool isMovingLeft = false;

  // Soil moisture value
  double soilMoisture = 0.0;

  // Connection status
  bool _isConnected = false;

  // Listeners
  StreamSubscription? _servoRightListener;
  StreamSubscription? _servoLeftListener;
  StreamSubscription? _connectionListener;
  StreamSubscription? _soilMoistureListener;
  Timer? _updateTimerRight;
  Timer? _updateTimerLeft;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _setupRealtimeListeners();
  }

  @override
  void dispose() {
    _servoRightListener?.cancel();
    _servoLeftListener?.cancel();
    _connectionListener?.cancel();
    _soilMoistureListener?.cancel();
    _updateTimerRight?.cancel();
    _updateTimerLeft?.cancel();
    super.dispose();
  }

  Future<void> _initializeDatabase() async {
    if (_hasInitialized) return;

    try {
      await _database.child('servo_right').set({
        'position': 90,
        'timestamp': ServerValue.timestamp,
      });

      await _database.child('servo_left').set({
        'position': 90,
        'timestamp': ServerValue.timestamp,
      });

      if (mounted) {
        setState(() {
          _isConnected = true;
          _hasInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
      }
    }
  }

  void _setupRealtimeListeners() {
    _connectionListener = _database.child('.info/connected').onValue.listen((event) {
      final connected = event.snapshot.value as bool? ?? false;
      if (mounted && _isConnected != connected) {
        setState(() {
          _isConnected = connected;
        });
      }
    });

    _servoRightListener = _database.child('servo_right').onValue.listen((event) {
      if (event.snapshot.exists && mounted) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final position = (data['position'] ?? 90).toDouble();

        if (position != currentPositionRight) {
          setState(() {
            currentPositionRight = position;
          });
        }
      }
    });

    _servoLeftListener = _database.child('servo_left').onValue.listen((event) {
      if (event.snapshot.exists && mounted) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final position = (data['position'] ?? 90).toDouble();

        if (position != currentPositionLeft) {
          setState(() {
            currentPositionLeft = position;
          });
        }
      }
    });

    // Soil Moisture Listener - Updated path to /soil_moisture/value
    _soilMoistureListener = _database.child('soil_moisture/value').onValue.listen((event) {
      if (event.snapshot.exists && mounted) {
        final data = event.snapshot.value;
        double moisture = 0.0;
        
        // Handle different data types
        if (data is num) {
          moisture = data.toDouble();
        } else if (data is String) {
          moisture = double.tryParse(data) ?? 0.0;
        }

        if (moisture != soilMoisture) {
          setState(() {
            soilMoisture = moisture;
          });
        }
      }
    });
  }

  void _moveServoRight(double position) {
    _updateTimerRight?.cancel();

    if (mounted) {
      setState(() {
        targetPositionRight = position;
        isMovingRight = true;
      });
    }

    _updateTimerRight = Timer(const Duration(milliseconds: 50), () {
      _sendToFirebaseRight(position);
    });
  }

  Future<void> _sendToFirebaseRight(double position) async {
    try {
      await _database.child('servo_right').update({
        'position': position.toInt(),
        'timestamp': ServerValue.timestamp,
      });

      Timer(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            isMovingRight = false;
          });
        }
      });
    } catch (error) {
      _showMessage('Servo Kanan Error: $error', Colors.red);
      if (mounted) {
        setState(() {
          isMovingRight = false;
        });
      }
    }
  }

  void _moveServoLeft(double position) {
    _updateTimerLeft?.cancel();

    if (mounted) {
      setState(() {
        targetPositionLeft = position;
        isMovingLeft = true;
      });
    }

    _updateTimerLeft = Timer(const Duration(milliseconds: 50), () {
      _sendToFirebaseLeft(position);
    });
  }

  Future<void> _sendToFirebaseLeft(double position) async {
    try {
      await _database.child('servo_left').update({
        'position': position.toInt(),
        'timestamp': ServerValue.timestamp,
      });

      Timer(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            isMovingLeft = false;
          });
        }
      });
    } catch (error) {
      _showMessage('Servo Kiri Error: $error', Colors.red);
      if (mounted) {
        setState(() {
          isMovingLeft = false;
        });
      }
    }
  }

  void _sendCarAction(String action) {
    _database.child('motor_action').set(action);
  }

  void _resetServos() {
    setState(() {
      targetPositionRight = 90.0;
      currentPositionRight = 90.0;
      targetPositionLeft = 90.0;
      currentPositionLeft = 90.0;
    });

    _moveServoRight(90.0);
    _moveServoLeft(90.0);
    _showMessage('Servos reset to 90°', Colors.green);
  }

  void _showMessage(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildServoController({
    required String title,
    required String range,
    required Color color,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
    required Function(double) onChangeEnd,
  }) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      padding: EdgeInsets.all(isLandscape ? 12 : 8),
      decoration: isLandscape ? BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title dengan indicator status
          Row(
            children: [
              // Status indicator
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isLandscape 
                    ? (title.contains('Kanan') 
                        ? (isMovingRight ? Colors.green[400] : color) 
                        : (isMovingLeft ? Colors.green[400] : color))
                    : color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (title.contains('Kanan') 
                          ? (isMovingRight ? Colors.green : color) 
                          : (isMovingLeft ? Colors.green : color)).withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isLandscape ? 12 : 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Range dan current value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                range,
                style: TextStyle(
                  fontSize: isLandscape ? 9 : 9,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withOpacity(0.3), width: 0.5),
                ),
                child: Text(
                  '${value.toInt()}°',
                  style: TextStyle(
                    fontSize: isLandscape ? 10 : 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: isLandscape ? 8 : 8),
          
          // Slider
          Expanded(
            child: VolumeSlider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return SizedBox(
      width: isLandscape ? 80 : double.infinity,
      child: ElevatedButton(
        onPressed: _resetServos,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 16 : 24,
            vertical: isLandscape ? 8 : 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
          shadowColor: Colors.green.withOpacity(0.3),
        ),
        child: Text(
          'RESET',
          style: TextStyle(
            fontSize: isLandscape ? 10 : 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isLandscape ? 4.0 : 12.0),
          child: isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout(),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      children: [
        // Servo Controllers di atas
        SizedBox(
          height: 140,
          child: Row(
            children: [
              Expanded(
                child: _buildServoController(
                  title: 'Servo Kanan',
                  range: '90° - 180°',
                  color: Colors.blue,
                  value: targetPositionRight,
                  min: 90,
                  max: 180,
                  onChanged: _moveServoRight,
                  onChangeEnd: _moveServoRight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildServoController(
                  title: 'Servo Kiri',
                  range: '0° - 90°',
                  color: Colors.purple,
                  value: targetPositionLeft,
                  min: 0,
                  max: 90,
                  onChanged: _moveServoLeft,
                  onChangeEnd: _moveServoLeft,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Row untuk Reset Button dan Soil Moisture Card
        Row(
          children: [
            Expanded(
              child: _buildResetButton(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SoilMoistureCard(
                moistureValue: soilMoisture,
                isConnected: _isConnected,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        // Car Controller di bawah
        Expanded(
          child: CarControlWidget(
            onAction: _sendCarAction,
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Row(
        children: [
          // Left: Car Controller - Flex 2 untuk balance
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange[200]!, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: CarControlWidget(
                onAction: _sendCarAction,
              ),
            ),
          ),
          
          // Center Column: Soil Moisture Card di atas, Reset Button di bawah
          Column(
            children: [
              // Soil Moisture Card - DI ATAS RESET
              Expanded(
                flex: 2,
                child: SoilMoistureCard(
                  moistureValue: soilMoisture,
                  isConnected: _isConnected,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Reset Button Section - DI BAWAH
              Container(
                width: 100,
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[300]!, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Reset Button tanpa icon
                    SizedBox(
                      width: 80,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: _resetServos,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'RESET',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Status text
                    Text(
                      'Reset Servos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 7,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Right: Servo Controllers - Flex 2 untuk balance
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[200]!, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Servo Controllers
                  Expanded(
                    child: _buildServoController(
                      title: 'Servo Kanan',
                      range: '90°-180°',
                      color: Colors.blue[700]!,
                      value: targetPositionRight,
                      min: 90,
                      max: 180,
                      onChanged: _moveServoRight,
                      onChangeEnd: _moveServoRight,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: _buildServoController(
                      title: 'Servo Kiri',
                      range: '0°-90°',
                      color: Colors.purple[700]!,
                      value: targetPositionLeft,
                      min: 0,
                      max: 90,
                      onChanged: _moveServoLeft,
                      onChangeEnd: _moveServoLeft,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}