import 'dart:async';
import 'package:flutter/material.dart';

class ElectionCountdownWidget extends StatefulWidget {
  const ElectionCountdownWidget({super.key});

  @override
  State<ElectionCountdownWidget> createState() => _ElectionCountdownWidgetState();
}

class _ElectionCountdownWidgetState extends State<ElectionCountdownWidget> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;
  final DateTime _electionDate = DateTime(2026, 2, 12, 8, 0, 0); // Feb 12, 2026, 8:00 AM

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeLeft();
    });
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    setState(() {
      _timeLeft = _electionDate.difference(now);
      if (_timeLeft.isNegative) {
        _timeLeft = Duration.zero;
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeLeft.isNegative || _timeLeft == Duration.zero) {
      return const Text(
         "Election Day is Here!",
         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
      );
    }

    final days = _timeLeft.inDays;
    final hours = _timeLeft.inHours % 24;
    final minutes = _timeLeft.inMinutes % 60;
    final seconds = _timeLeft.inSeconds % 60;

    return Column(
      children: [
        const Text(
          "Countdown to Election Day",
          style: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimeSegment(days, "Days"),
            _buildSeparator(),
            _buildTimeSegment(hours, "Hrs"),
            _buildSeparator(),
            _buildTimeSegment(minutes, "Min"),
            _buildSeparator(),
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 500),
              tween: Tween<double>(begin: 0.8, end: 1.0),
              builder: (context, double scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              key: ValueKey(seconds), // Rebuild on change for pulse
              child: _buildTimeSegment(seconds, "Sec"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSegment(int value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ":",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
      ),
    );
  }
}
