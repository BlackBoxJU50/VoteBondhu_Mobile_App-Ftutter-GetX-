import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/controllers/games_controller.dart';

class WheelOfFortunePage extends StatefulWidget {
  const WheelOfFortunePage({super.key});

  @override
  State<WheelOfFortunePage> createState() => _WheelOfFortunePageState();
}

class _WheelOfFortunePageState extends State<WheelOfFortunePage> with SingleTickerProviderStateMixin {
  final GamesController _gamesController = Get.find<GamesController>();
  late AnimationController _controller;
  late Animation<double> _animation;
  
  final List<int> _prizes = [10, 50, 0, 100, 20, 0, 200, 50];
  final List<Color> _colors = [
    Colors.red, Colors.blue, Colors.grey, Colors.green, 
    Colors.orange, Colors.grey, Colors.amber, Colors.blue
  ];

  double _angle = 0;
  bool _isSpinning = false;
  int? _lastWin;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    );
  }

  void _spin() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _lastWin = null;
    });

    // Random spin: 5-10 full rotations + random angle
    double randomRotation = (5 + Random().nextInt(5)) * 2 * pi;
    double randomAngle = Random().nextDouble() * 2 * pi;
    double totalRotation = randomRotation + randomAngle;

    _animation = Tween<double>(
      begin: _angle % (2 * pi),
      end: _angle + totalRotation,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));

    _controller.forward(from: 0).then((_) {
      _angle += totalRotation;
      _calculateWin();
      setState(() {
        _isSpinning = false;
      });
    });
  }

  void _calculateWin() {
    // Determine which segment is at the top (angle 0)
    // The wheel rotated 'totalRotation'.
    // One segment is 2*pi / length
    double sectorSize = 2 * pi / _prizes.length;
    // Normalized angle (0 to 2*pi)
    double normalizedAngle = (2 * pi - (_angle % (2 * pi))) % (2 * pi);
    int index = (normalizedAngle / sectorSize).floor();
    
    int win = _prizes[index];
    _lastWin = win;
    if (win > 0) {
      _gamesController.addPoints(win);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wheel of Fortune')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Spin to Win Points!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Stack(
              alignment: Alignment.center,
              children: [
                // The Wheel
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animation.value,
                      child: CustomPaint(
                        size: const Size(300, 300),
                        painter: WheelPainter(prizes: _prizes, colors: _colors),
                      ),
                    );
                  },
                ),
                // The Pointer
                const Positioned(
                  top: -10,
                  child: Icon(Icons.arrow_drop_down, size: 50, color: Colors.black),
                ),
                // Center Hub
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                ),
              ],
            ),
            const SizedBox(height: 50),
            if (_lastWin != null)
              _lastWin! > 0 
                ? Text('You Won $_lastWin Points!', style: const TextStyle(fontSize: 28, color: Colors.green, fontWeight: FontWeight.bold))
                : const Text('Try Again!', style: TextStyle(fontSize: 28, color: Colors.red)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isSpinning ? null : _spin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(_isSpinning ? 'Spinning...' : 'SPIN NOW', style: const TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<int> prizes;
  final List<Color> colors;

  WheelPainter({required this.prizes, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;
    double sectorAngle = 2 * pi / prizes.length;
    Rect rect = Rect.fromCircle(center: Offset(radius, radius), radius: radius);

    for (int i = 0; i < prizes.length; i++) {
      final paint = Paint()..color = colors[i];
      canvas.drawArc(rect, i * sectorAngle - pi / 2, sectorAngle, true, paint);

      // Draw text
      canvas.save();
      canvas.translate(radius, radius);
      canvas.rotate(i * sectorAngle + sectorAngle / 2 - pi / 2);
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${prizes[i]}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(radius * 0.6, -textPainter.height / 2));
      canvas.restore();
    }
    
    // Border
    final borderPaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 4;
    canvas.drawCircle(Offset(radius, radius), radius, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
