import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/controllers/auth_controller.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Put AuthController into memory immediately
    final AuthController authController = Get.put(AuthController());

    // Trigger auth check after frame callback to avoid build issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Small delay for the animation
      Future.delayed(const Duration(seconds: 3), () {
        authController.checkAuth();
      });
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade900, Colors.green.shade600, Colors.green.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Decorative Elements
            _buildAnimatedDecor(size: 300, top: -50, right: -50),
            _buildAnimatedDecor(size: 200, bottom: -50, left: -50),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                TweenAnimationBuilder(
                  duration: const Duration(seconds: 1),
                  tween: Tween<double>(begin: 0, end: 1),
                  curve: Curves.elasticOut,
                  builder: (context, double value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: Container(
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 15)),
                      ],
                    ),
                    child: SizedBox(
                       width: MediaQuery.of(context).size.width * 1.1,
                       height: MediaQuery.of(context).size.width * 1.1,
                       child: ClipOval(
                        child: Image.asset(
                          'assets/images/splash_logo.png', 
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Animated Text
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child),
                    );
                  },
                  child: const Column(
                    children: [
                      Text(
                        'VoteBondhu',
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'DEMOCRACY IN YOUR HANDS',
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 3),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 60),
                
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedDecor({required double size, double? top, double? left, double? right, double? bottom}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Opacity(
        opacity: 0.1,
        child: Container(
          width: size, height: size,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
