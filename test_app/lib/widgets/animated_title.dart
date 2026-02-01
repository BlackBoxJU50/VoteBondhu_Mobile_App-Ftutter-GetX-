import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedTitle extends StatefulWidget {
  final String text;
  final double fontSize;
  final Color color;

  const AnimatedTitle({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.color = Colors.white,
  });

  @override
  State<AnimatedTitle> createState() => _AnimatedTitleState();
}

class _AnimatedTitleState extends State<AnimatedTitle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Text(
            widget.text,
            style: GoogleFonts.righteous(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.bold,
              color: widget.color.withOpacity(_glowAnimation.value),
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: widget.color.withOpacity(0.3),
                  blurRadius: 10 * _glowAnimation.value,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
