import 'package:flutter/material.dart';

class SocialActionButton extends StatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final Color baseColor;
  final Color activeColor;
  final bool isActive;
  final VoidCallback onTap;

  const SocialActionButton({
    super.key,
    required this.icon,
    this.activeIcon,
    required this.label,
    this.baseColor = Colors.grey,
    this.activeColor = Colors.blue,
    this.isActive = false,
    required this.onTap,
  });

  @override
  State<SocialActionButton> createState() => _SocialActionButtonState();
}

class _SocialActionButtonState extends State<SocialActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive ? widget.activeColor : widget.baseColor;
    final iconData = widget.isActive ? (widget.activeIcon ?? widget.icon) : widget.icon;

    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                iconData,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                color: color,
                fontWeight: widget.isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
