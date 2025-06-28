import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:math'; // UNTUK MATH FUNCTIONS
import '../widgets/volume_slider.dart';
import '../widgets/car_control_widget.dart';
import '../widgets/joystick_widget.dart'; // GUNAKAN YANG TERPISAH

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
  
  // Car control values
  double carX = 0.0;
  double carY = 0.0;
  
  // Connection status
  bool _isConnected = false;
  
  // Listeners
  StreamSubscription? _servoRightListener;
  StreamSubscription? _servoLeftListener;
  StreamSubscription? _carListener;
  StreamSubscription? _connectionListener;
  Timer? _updateTimerRight;
  Timer? _updateTimerLeft;
  Timer? _updateTimerCar;
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
    _carListener?.cancel();
    _connectionListener?.cancel();
    _updateTimerRight?.cancel();
    _updateTimerLeft?.cancel();
    _updateTimerCar?.cancel();
    super.dispose();
  }

  void _initializeDatabase() async {
    if (_hasInitialized) return;
    
    try {
      // Initialize servos and car
      await _database.child('servo_right').set({
        'position': 90,
        'timestamp': ServerValue.timestamp,
      });
      
      await _database.child('servo_left').set({
        'position': 90,
        'timestamp': ServerValue.timestamp,
      });
      
      await _database.child('car_control').set({
        'x': 0.0,
        'y': 0.0,
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
    // Connection status
    _connectionListener = _database.child('.info/connected').onValue.listen((event) {
      final connected = event.snapshot.value as bool? ?? false;
      if (mounted && _isConnected != connected) {
        setState(() {
          _isConnected = connected;
        });
      }
    });
    
    // Servo listeners
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
    
    // Car listener
    _carListener = _database.child('car_control').onValue.listen((event) {
      if (event.snapshot.exists && mounted) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final x = (data['x'] ?? 0.0).toDouble();
        final y = (data['y'] ?? 0.0).toDouble();
        
        if (x != carX || y != carY) {
          setState(() {
            carX = x;
            carY = y;
          });
        }
      }
    });
  }

  // Servo methods
  void _moveServoRight(double position) {
    _updateTimerRight?.cancel();
    
    if (mounted) {
      setState(() {
        targetPositionRight = position;
        isMovingRight = true;
      });
    }
    
    _updateTimerRight = Timer(const Duration(milliseconds: 200), () {
      _sendToFirebaseRight(position);
    });
  }

  void _sendToFirebaseRight(double position) async {
    try {
      await _database.child('servo_right').update({
        'position': position.toInt(),
        'timestamp': ServerValue.timestamp,
      });
      
      Timer(const Duration(milliseconds: 500), () {
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
    
    _updateTimerLeft = Timer(const Duration(milliseconds: 200), () {
      _sendToFirebaseLeft(position);
    });
  }

  void _sendToFirebaseLeft(double position) async {
    try {
      await _database.child('servo_left').update({
        'position': position.toInt(),
        'timestamp': ServerValue.timestamp,
      });
      
      Timer(const Duration(milliseconds: 500), () {
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

  // Car control methods
  void _moveJoystick(double x, double y) {
    _updateTimerCar?.cancel();
    
    if (mounted) {
      setState(() {
        carX = x;
        carY = y;
      });
    }
    
    _updateTimerCar = Timer(const Duration(milliseconds: 100), () {
      _sendToFirebaseCar(x, y);
    });
  }

  void _sendToFirebaseCar(double x, double y) async {
    try {
      await _database.child('car_control').update({
        'x': double.parse(x.toStringAsFixed(2)),
        'y': double.parse(y.toStringAsFixed(2)),
        'timestamp': ServerValue.timestamp,
      });
    } catch (error) {
      _showMessage('Car Control Error: $error', Colors.red);
    }
  }

  // RESET HANYA SERVO (TANPA JOYSTICK)
  void _resetServos() {
    setState(() {
      targetPositionRight = 90.0;
      currentPositionRight = 90.0;
      targetPositionLeft = 90.0;
      currentPositionLeft = 90.0;
      // TIDAK reset carX dan carY untuk joystick
    });
    
    // Send reset commands hanya untuk servo
    _moveServoRight(90.0);
    _moveServoLeft(90.0);
    // TIDAK kirim reset command untuk car/joystick
    
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

  // Build servo controller widget
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
    
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isLandscape ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          range,
          style: TextStyle(
            fontSize: isLandscape ? 10 : 12,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: isLandscape ? 6 : 16),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Servo & Car Controller',
          style: TextStyle(fontSize: isLandscape ? 16 : 20),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        toolbarHeight: isLandscape ? 44 : 56,
        actions: [
          Container(
            padding: const EdgeInsets.all(6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isConnected ? Icons.wifi : Icons.wifi_off,
                  color: _isConnected ? Colors.green : Colors.red,
                  size: isLandscape ? 14 : 18,
                ),
                const SizedBox(width: 4),
                Text(
                  _isConnected ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: _isConnected ? Colors.green : Colors.red,
                    fontSize: isLandscape ? 9 : 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isLandscape ? 6.0 : 16.0),
          child: isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout(),
        ),
      ),
    );
  }

  // Portrait Layout
  Widget _buildPortraitLayout() {
    return Column(
      children: [
        // Servo Controllers Row
        Expanded(
          flex: 3,
          child: Row(
            children: [
              // Servo Kanan
              Expanded(
                child: _buildServoController(
                  title: 'Servo Kanan',
                  range: '90° - 180°',
                  color: Colors.blue,
                  value: targetPositionRight,
                  min: 90,
                  max: 180,
                  onChanged: (value) {
                    setState(() {
                      targetPositionRight = value;
                    });
                  },
                  onChangeEnd: _moveServoRight,
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Servo Kiri
              Expanded(
                child: _buildServoController(
                  title: 'Servo Kiri',
                  range: '0° - 90°',
                  color: Colors.purple,
                  value: targetPositionLeft,
                  min: 0,
                  max: 90,
                  onChanged: (value) {
                    setState(() {
                      targetPositionLeft = value;
                    });
                  },
                  onChangeEnd: _moveServoLeft,
                ),
              ),
            ],
          ),
        ),
        
        // RESET BUTTON DI TENGAH
        const SizedBox(height: 16),
        _buildResetButton(),
        const SizedBox(height: 16),
        
        // Car Controller (TANPA SERVO POSITION CARD)
        Expanded(
          flex: 2,
          child: CarControlWidget(
            onJoystickChanged: _moveJoystick,
            currentX: carX,
            currentY: carY,
          ),
        ),
        
        const SizedBox(height: 16),
      ],
    );
  }

  // Landscape Layout (HAPUS SERVO POSITION CARD)
  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        // Left: Servo Controllers
        Expanded(
          flex: 2,
          child: Row(
            children: [
              // Servo Kanan
              Expanded(
                child: _buildServoController(
                  title: 'Servo Kanan',
                  range: '90° - 180°',
                  color: Colors.blue,
                  value: targetPositionRight,
                  min: 90,
                  max: 180,
                  onChanged: (value) {
                    setState(() {
                      targetPositionRight = value;
                    });
                  },
                  onChangeEnd: _moveServoRight,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Servo Kiri
              Expanded(
                child: _buildServoController(
                  title: 'Servo Kiri',
                  range: '0° - 90°',
                  color: Colors.purple,
                  value: targetPositionLeft,
                  min: 0,
                  max: 90,
                  onChanged: (value) {
                    setState(() {
                      targetPositionLeft = value;
                    });
                  },
                  onChangeEnd: _moveServoLeft,
                ),
              ),
            ],
          ),
        ),
        
        // Center: Reset Button SAJA (HAPUS POSITION CARD)
        Flexible( // GUNAKAN Flexible AGAR TIDAK OVERFLOW
          flex: 1,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160), // BATASI LEBAR BUTTON
              child: _buildResetButton(),
            ),
          ),
        ),
        
        // Right: Car Controller
        Expanded(
          flex: 1,
          child: CarControlWidget(
            onJoystickChanged: _moveJoystick,
            currentX: carX,
            currentY: carY,
          ),
        ),
      ],
    );
  }

  // RESET BUTTON HANYA UNTUK SERVO
  Widget _buildResetButton() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Container(
      width: isLandscape ? null : double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: _resetServos,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 20 : 32,
            vertical: isLandscape ? 12 : 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
        ),
        child: Text(
          'RESET SERVOS',
          style: TextStyle(
            fontSize: isLandscape ? 12 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// HAPUS DUPLICATE JOYSTICK WIDGET - gunakan yang di widgets/joystick_widget.dart