import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/controllers/auth_controller.dart';
import 'dart:ui';

class LoginPage extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade900, Colors.green.shade500, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Floating animated circles for depth
          _buildAnimatedCircle(top: -50, left: -50, size: 200, color: Colors.green.shade700),
          _buildAnimatedCircle(bottom: -100, right: -100, size: 300, color: Colors.green.shade300),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  
                  // Logo with Entrance Animation
                  TweenAnimationBuilder(
                    duration: const Duration(seconds: 1),
                    tween: Tween<double>(begin: 0, end: 1),
                    curve: Curves.elasticOut,
                    builder: (context, double value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.how_to_vote, size: 80, color: Colors.green),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // App Name
                  const Text(
                    'VoteBondhu',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  const Text(
                    'Your Democracy, Your Voice',
                    style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  
                  const SizedBox(height: 50),

                  // Glassmorphism Form Container
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.5)),
                        ),
                        child: Column(
                          children: [
                            _buildAnimatedInput(
                              index: 1,
                              child: TextField(
                                controller: authController.emailCtrl,
                                decoration: _buildInputDecoration('Email', Icons.email),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Obx(() => _buildAnimatedInput(
                              index: 2,
                              child: TextField(
                                controller: authController.passwordCtrl,
                                decoration: _buildInputDecoration('Password', Icons.lock).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      authController.isPasswordVisible.value 
                                      ? Icons.visibility 
                                      : Icons.visibility_off,
                                      color: Colors.green,
                                    ),
                                    onPressed: authController.togglePasswordVisibility,
                                  ),
                                ),
                                obscureText: !authController.isPasswordVisible.value,
                              ),
                            )),
                            const SizedBox(height: 30),
                            
                            // Login Button
                            _buildAnimatedInput(
                              index: 3,
                              child: SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: authController.login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade700,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    elevation: 5,
                                  ),
                                  child: const Text(
                                    'LOGIN NOW',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 15),
                            
                            // Guest Login
                            _buildAnimatedInput(
                              index: 4,
                              child: TextButton(
                                onPressed: authController.loginAsGuest,
                                child: Text(
                                  'Continue as Guest',
                                  style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Signup Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("New to VoteBondhu? ", style: TextStyle(color: Colors.black54)),
                      InkWell(
                        onTap: () => Get.toNamed('/signup'),
                        child: Text(
                          "Sign Up Free",
                          style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.green.shade700),
      prefixIcon: Icon(icon, color: Colors.green),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.transparent)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.green, width: 2)),
    );
  }

  Widget _buildAnimatedCircle({double? top, double? left, double? right, double? bottom, required double size, required Color color}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: TweenAnimationBuilder(
        duration: const Duration(seconds: 10),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Opacity(
            opacity: 0.2,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedInput({required int index, required Widget child}) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index * 200)),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}
